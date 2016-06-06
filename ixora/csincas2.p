/* csincas2.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Автоматизация пополнения электронного кассира
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR

 * CHANGES
                07.12.2011 Luiza
                09/02/2012 Luiza - изменила проставление кода кассплана
*/


{classes.i}
{cm18_abs.i}


define input parameter new_document as logical.
define            variable m_sub       as character initial "jou".
define shared     variable v_u         as integer   no-undo.
define            variable v-deb       as character init "". /*like gl.gl no-undo.*/
define            variable v-cre       as character init "". /*like gl.gl no-undo.*/
define            variable v-arp       like arp.arp no-undo.
define            variable v-arp100200 like arp.arp no-undo.
define /*shared*/ variable v-dep       as character no-undo.
define /*shared*/ variable v-depname   as character no-undo.
define            variable v-nomer     like cslist.nomer no-undo.
define            variable v-tmpl      as character no-undo.
define new shared variable v-joudoc    as character format "x(10)" no-undo.
define            variable v-sum       as decimal   no-undo.
define            variable v-sumarp    as decimal   no-undo.
define            variable v-crc       like crc.crc.
define            variable v-crc_val   as character no-undo format "xxx" init "KZT".
define            variable v-kod       as character no-undo init "14".
define            variable v-kbe       as character no-undo init "14".
define            variable v-knp       as character no-undo init "890".
define            variable v-tit       as character.
define            variable v-rem       as character init "Инкассация ЭК N " no-undo .
define            variable sumstr      as character.
define            variable v-ja        as logi      no-undo /*format "Да/Нет" */ init yes.
define new shared variable s-jh        like jh.jh.
define            variable v-glrem     as character no-undo.
define            variable v-param     as character no-undo.
define            variable vdel        as character no-undo initial "^".
define            variable rcode       as integer   no-undo.
define            variable rdes        as character no-undo.
define new shared variable v_doc       as character.
define            variable v_trx       as integer   no-undo.
define            variable vj-label    as character no-undo.
define            variable v_title     as character no-undo. /*наименование платежа */
define            variable quest       as logical   format "yes/no" no-undo.
define            variable v-sts       like jh.sts no-undo.
{keyord.i}

define variable s-ourbank as character no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not available sysc or sysc.chval = "" then
do:
    message "There is no record OURBNK in bank.sysc file !" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).


v-rem = "Пополнение ЭК ".
v_title = "Пополнение ЭК ".
format
    v-joudoc label " Документ        " format "x(10)"  v_trx label "  ТРН " format "zzzzzzzzz"      skip
    v-depname label " ЦОК             " format "x(30)"  skip
    v-nomer  label " Номер ЭК        "  skip
    v-crc    label " Валюта          " validate(can-find(crc where crc.crc = v-crc no-lock), " Введите валюту! F2 - помощь.") help "F2 - справочник" v-crc_val no-labels skip
    v-arp    label " Тр. счет 100500 " skip
    v-sumarp label " Текущий остаток " format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-sum    label " Сумма           " validate(v-sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-rem    label " Примечание      " format "x(50)" skip
    v-kod    label " Код             " format "x(2)" skip
    v-kbe    label " Кбе             " format "x(2)" skip
    v-knp    label " КНП             " format "x(3)" skip(1)
    "           ДАННЫЕ ПРОВОДКИ  "  skip
    v-deb    label " Дебет Г/К       " format "x(35)" skip
    v-cre    label " Кредит Г/К      " format "x(35)" skip(1)
    vj-label no-labels v-ja no-labels
    with  side-labels centered row 7 title v_title width 80 frame f_main.

on help of v-crc in frame f_main
    do:
        run help-crc1.
    end.
on help of v-joudoc in frame f_main
    do:
        run a_help-joudoc1("CSI2").
        v-joudoc = frame-value.
    end.
on "END-ERROR" of frame f_main
    do:
        hide frame f_main no-pause.
    end.


if new_document then
do:  /* создание нового документа  */
    run SelectSafe(s-ourbank,Base:dep-id, output v-nomer).
    if v-nomer = "" then
    do:
        message "Нет доступного ЭК!" view-as alert-box.
        hide frame f_main.
        return.
    end.

    if Base:dep-id = 1 then v-dep = '514'.
    else v-dep = "A" + string(Base:dep-id,'99').
    v-depname = Base:b-addr.

    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    release nmbr.
    do transaction:
        display v-joudoc format "x(10)" with frame f_main.
        v-sum = 0.
        v-ja = yes.
        v-crc = 1.
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */

else
do:   /* редактирование документа   */
    run view_doc.
    if v_u = 2 then
    do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then
            do:

                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then
                do:

                    if  joudop.type <> "CSI2" then
                    do:
                        message substitute ("Документ не относится к типу пополнение электронного кассира(счет 100200)") view-as alert-box.
                        return.
                    end.

                end.
                if joudoc.jh > 1 then
                do:
                    message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
                    return.
                end.
                if joudoc.who ne g-ofc then
                do:
                    message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
                    return.
                end.
            end.
            run save_doc.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:

    display v-nomer v-depname v-crc v-crc_val v-sum v-rem v-kod v-kbe v-knp vj-label no-labels with frame f_main.
    update v-crc with frame f_main.
    find first crc where crc.crc = v-crc no-lock no-error.
    if available crc then v-crc_val = crc.code.
    v-rem = v_title + v-nomer.
    display v-crc_val v-rem  with frame f_main.

    for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
        if available sub-cod then
        do:
            v-arp = arp.arp.
            v-sumarp = arp.dam[1] - arp.cam[1].
        end.
    end.

    if v-arp = "" then
    do:
        message "Не настроен счет ЭЛ КАССИРА в валюте " v-crc_val " !" view-as alert-box title " ОШИБКА ! ".
        undo.
    end.

    for each arp where arp.gl = 100200 and arp.crc = v-crc no-lock.
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = "obmen1002" no-lock no-error.
        if available sub-cod then
        do:
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp and sub-cod.ccode = v-dep no-lock no-error.
            if available sub-cod then
            do:
                v-arp100200 = arp.arp.
            /*v-sumarp = arp.dam[1] - arp.cam[1].*/
            end.
        end.
    end.
    if v-arp100200 = "" then
    do:
        message "Не настроен арп счет 100200 в валюте " v-crc_val " !" view-as alert-box title " ОШИБКА ! ".
        undo.
    end.


    v-deb = "100500   АРП " + v-arp.
    v-cre = "100200   АРП " + v-arp100200.


    display v-arp v-sumarp v-deb v-cre v-ja with frame f_main.

    repeat:
        update v-sum with frame f_main.
        leave.
    end.
    if keyfunction (lastkey) = "end-error" then undo.

    update v-ja no-labels with frame f_main.
    if keyfunction (lastkey) = "end-error" then undo.
    if v-ja then
    do:
        do transaction:
            if new_document then
            do:
                create joudoc.
                joudoc.docnum = v-joudoc.
                create joudop.
                joudop.docnum = v-joudoc.
            end.
            else
            do:
                find joudoc where joudoc.docnum = v-joudoc exclusive-lock.
                find joudop where joudop.docnum = v-joudoc exclusive-lock.
            end.
            joudoc.who = g-ofc.
            joudoc.whn = g-today.
            joudoc.tim = time.

            /* 100200 */
            joudoc.dracctype = "4".
            joudoc.dracc = v-arp.
            joudoc.cracctype = "4".
            joudoc.cracc = v-arp100200.

            joudoc.drcur = v-crc.
            joudoc.dramt = v-sum.
            joudoc.cramt = v-sum.
            joudoc.crcur = v-crc.
            joudoc.remark[1] = v-rem .
            joudoc.chk = 0.
            joudoc.bas_amt = "D".
            run chgsts("JOU", v-joudoc, "new").
            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            joudop.type = "CSI2".
            joudop.amt = v-sumarp.
            joudop.doc1 = v-nomer.
            joudop.lname = v-dep.
            joudop.mname = v-depname.
            find current joudop no-lock no-error.
            display v-joudoc with frame f_main.
            pause 0.
        end. /*end trans-n*/
    end.
end procedure.

procedure view_doc:
    update v-joudoc help "Введите номер документа, F2-помощь" with frame f_main.
    if keyfunction (lastkey) = "end-error" then
    do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if trim(v-joudoc) = "" then undo, return.
    display v-joudoc with frame f_main.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then
    do:
        message "Документ не найден." view-as alert-box.
        undo, retry.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then
    do:

        if  joudop.type <> "CSI2" then
        do:
            message substitute ("Документ не относится к типу пополнение электронного кассира(счет 100200)") view-as alert-box.
            return.
        end.

    end.
    if joudoc.jh > 1 and v_u = 2 then
    do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then
    do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        return.
    end.
    v-nomer   = joudop.doc1.
    v-sumarp  = joudop.amt.
    v-dep     = joudop.lname.
    v-depname = joudop.mname.
    v-crc     = joudoc.drcur.
    v-arp = joudoc.dracc.
    v-arp100200 = joudoc.cracc.
    v-sum     = joudoc.dramt.
    v-rem     = joudoc.remark[1].
    v_trx     = joudoc.jh.

    find first crc where crc.crc = v-crc no-lock no-error.
    if available crc then v-crc_val = crc.code.
    v-deb = "100500   АРП " + joudoc.dracc.
    v-cre = "100200   АРП " + joudoc.cracc.

    display v_trx v-nomer v-depname v-crc v-crc_val v-arp v-sumarp v-sum v-rem v-kod v-kbe v-knp v-deb v-cre with frame f_main.
end procedure.


procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        run view_doc.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if available joudoc then
        do:
            if not (joudoc.jh eq 0 or joudoc.jh eq ?) then
            do:
                message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box.
                undo, return.
            end.
            if joudoc.who ne g-ofc then
            do:
                message substitute (
                    "Документ принадлежит &1. Удалять нельзя.", joudoc.who) view-as alert-box.
                undo, return.
            end.
            display vj-label no-labels format "x(35)"  with frame f_main.
            pause 0.
            v-ja = no.
            update v-ja  with frame f_main.
            if v-ja then
            do:
                find joudoc where joudoc.docnum = v-joudoc no-error.
                if available joudoc then delete joudoc.
                find first joudoc no-lock no-error.
                for each substs where substs.sub = "jou" and  substs.acc = v-joudoc.
                    delete substs.
                end.
                find first substs no-lock no-error.
                find cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc no-error.
                if available cursts then delete cursts.
                find first cursts no-lock no-error.
            end.
        end.
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide message.
        hide frame f_main.
    end.
    return.
end procedure.

procedure Create_transaction:

    vj-label = " Выполнить транзакцию?..................".
    run view_doc.

    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh ne ? and joudoc.jh <> 0 then
    do:
        message "Транзакция уже проведена." view-as alert-box.
        undo, return.
    end.
    if joudoc.whn ne g-today then
    do:
        message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box.
        undo, return.
    end.
    if joudoc.who ne g-ofc then
    do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        undo, return.
    end.

    v-ja = yes.
    display vj-label no-labels format "x(35)"  with frame f_main.
    pause 0.
    update v-ja  with frame f_main.
    if not v-ja then undo, return.



    v-tmpl = "jou0066".
    v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-arp + vdel + v-arp100200 + vdel + v-rem + vdel + '1' + vdel + '1' + vdel + '4' + vdel + '4' + vdel + '890'.



    s-jh = 0.
    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then
    do:
        message rdes.
        pause.
        undo, return.
    end.

    find first jh where jh.jh = s-jh exclusive-lock.
    jh.party = v-joudoc.
    if jh.sts < 5 then jh.sts = 5.
    for each jl of jh:
        if jl.sts < 5 then jl.sts = 5 .
    end.
    find current jh no-lock.

    find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error.
    joudoc.jh = s-jh.
    find current joudoc no-lock no-error.
    run chgsts(m_sub, v-joudoc, "trx").
    run SetKassPl("CASHGL500",s-jh,100).

    message "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) + " ~nНеобходим акцепт документа в п.м. 4.3.4 " view-as alert-box.
    v_trx = s-jh.
    display v_trx with frame f_main.

    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").


/*
    find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
    for each jl where jl.jh eq s-jh no-lock:
        if (jl.gl = sysc.inval or jl.gl = 100100) and jl.crc = 1 then
        do:
            create jlsach .
            jlsach.jh = s-jh.
            if jl.dc = "D" then jlsach.amt = jl.dam . else jlsach.amt = jl.cam .
            jlsach.ln = jl.ln .
            jlsach.lnln = 1.
            jlsach.sim = 100 .

        end.
    end.
    release jlsach.
    */
    for each csofc where csofc.nomer = v-nomer no-lock.
        run mail   (csofc.ofc + "@metrocombank.kz",
            "METROCOMBANK <mkb@metrocombank.kz>",
            v-rem,
            "Добрый день!\n\n Необходимо отконтролировать пополнение электронного кассира \n N: " + v-nomer +
            "\n Сумма: " + string(v-sum) + "  " + v-crc_val + "\n Проводка :" + string(s-jh) + "\n Пополнил :" + g-ofc + "\n " + string(g-today) + "  " + string(time,"HH:MM"), "1", "","" ).
    end.
    hide all.
    view frame f_main.
end procedure.

procedure Delete_transaction:

    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc.
    if locked joudoc then
    do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if joudoc.jh eq ? then
    do:
        message "Транзакция не существует." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if joudoc.who ne g-ofc then
    do:
        message "Этот документ не ваш." view-as alert-box.
        pause 3.
        undo, return.
    end.
    s-jh = joudoc.jh.

    quest = false.
    find sysc where sysc.sysc = 'CASVOD' no-lock no-error.
    if available sysc then
    do:
        if sysc.loval = yes and sysc.daval = g-today then quest = true. /* блок кассы */
    end.
    find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
    find cursts where cursts.sub eq "jou" and cursts.acc eq v-joudoc use-index subacc no-lock no-error.

    find jh where jh.jh eq joudoc.jh no-lock no-error.

    for each jl where jl.jh eq s-jh no-lock:
        if jl.gl eq sysc.inval and (jl.sts eq 6 or cursts.sts eq "rdy") then
        do on endkey undo, return:
            message "Транзакция акцептована кассиром. Удалить нельзя." view-as alert-box.
            undo, return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then
        do:
            message "Свод кассы завершен, удалить нельзя" view-as alert-box.
            undo, return.
        end.
    end.

    for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock:
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
        if available sub-cod  then
        do:
            if arp.dam[1] - arp.cam[1] - v-sum < 0 then
                message "Удаление транзакции приведет к отрицательному остатку ~nАРП счета " + arp.arp view-as alert-box.
        end.
    end.



    do transaction on error undo, return:

        quest = false.
        if jh.jdt lt g-today then
        do:

            message substitute ("Дата проведения транзакции &1.  Сторно?", jh.jdt) update quest.
            if not quest then undo, return.
            for each jl where jl.jh eq joudoc.jh no-lock:
                if jl.gl eq sysc.inval and jl.sts = 6 then
                do:
                    find cashofc where cashofc.whn eq jl.jdt and cashofc.ofc eq jl.teller and cashofc.crc eq jl.crc and
                        cashofc.sts eq 2 exclusive-lock no-error.
                    if available cashofc then
                    do:
                        cashofc.amt = cashofc.amt + jl.cam - jl.dam.
                    end.
                    else
                    do:
                        create cashofc.
                        assign
                            cashofc.whn = jl.jdt
                            cashofc.ofc = jl.teller
                            cashofc.crc = jl.crc
                            cashofc.who = g-ofc
                            cashofc.sts = 2
                            cashofc.amt = jl.cam - jl.dam.
                    end.
                    release cashofc.
                end.
            end.
            run jou-aasdel (joudoc.cracc, joudoc.cramt, joudoc.jh).

            run jou42-blkdel (joudoc.jh).

            run trxstor(input joudoc.jh, input 6, output s-jh, output rcode, output rdes).
            if rcode ne 0 then
            do:
                message rdes.
                undo, return.
            end.
            run x-jlvo.

        end.
        else
        do:

            message "Вы уверены ?" update quest.
            if not quest then undo, return.

            v-sts = jh.sts.

            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then
            do:
                message rdes.
                undo, return.
            end.

            run trxdel (input s-jh, input true, output rcode, output rdes).
            if rcode ne 0 then
            do:
                if rcode = 50 then
                do:
                    hide all.
                    view frame f_main.
                end.
                message rdes.
                if rcode = 50 then
                do:
                    run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                    return.
                end.
                else undo, return.
            end.


            for each jl where jl.jh eq joudoc.jh no-lock:
                if not available jl then message "NOT FOUND JL WITH JOUDOC.JH -> CASHOFC".
                else
                    if jl.gl eq sysc.inval and jl.sts = 6 then
                    do:
                        find cashofc where cashofc.whn eq jl.jdt and
                            cashofc.ofc eq jl.teller and
                            cashofc.crc eq jl.crc and
                            cashofc.sts eq 2 /* current status */
                            exclusive-lock no-error.
                        if available cashofc then cashofc.amt = cashofc.amt + jl.cam - jl.dam.
                else do:
                create cashofc.
                cashofc.whn = jl.jdt.
                cashofc.ofc = jl.teller.
                cashofc.crc = jl.crc.
                cashofc.sts = 2.
                cashofc.amt = jl.cam - jl.dam.
            end.
            release cashofc.
        end.
    end.

end.

joudoc.jh   = ?.
v_trx = ?.
display v_trx with frame f_main.

end.

do transaction:
    run comm-dj(joudoc.docnum).

    find sysc where sysc.sysc = "ourbnk" no-lock no-error.
    find arpcon where arpcon.arp = joudoc.dracc and
        arpcon.sub = 'jou' and
        arpcon.txb = sysc.chval
        no-lock no-error.
    if available arpcon then
    do:
        for each substs where substs.sub = 'jou' and
            substs.acc = joudoc.docnum and
            substs.sts = arpcon.new-sts:
            delete substs.
        end.

        find cursts where cursts.sub = 'jou' and cursts.acc = joudoc.docnum no-error.

        if available cursts then
        do:
            find last substs where substs.sub = 'jou' and substs.acc = joudoc.docnum no-lock no-error.
            assign
                cursts.sts = substs.sts.
        end.
    end.
end. /* transaction */
find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
release joudoc.
run chgsts("JOU", v-joudoc, "new").
message "Транзакция удалена." view-as alert-box.

end procedure.

procedure Screen_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then
    do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = joudoc.jh.
        run vou_word (2, 1, joudoc.info).
    end. /* transaction */
end procedure.

procedure print_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then
    do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = joudoc.jh.
        /*run vou_bankt(2, 1, joudoc.info).*/
        if v-noord = no then run vou_bankt(2, 1, joudoc.info).
        else run printord(s-jh,"").

    end. /* transaction */
end procedure.