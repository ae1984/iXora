/* csincas2.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Автоматизация выгрузки электронного кассира
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


/*{global.i}*/
{classes.i}
{cm18_abs.i}


define input parameter new_document as logical.
define variable m_sub           as character initial "jou".
def shared var v_u as int no-undo.
def  var v-dep as char no-undo.
def  var v-depname as char no-undo.

def var v-nomer like cslist.nomer no-undo.
def var v-tmpl as char no-undo.
def new shared var v-joudoc as char format "x(10)" no-undo.

def var v-kod as char no-undo init "14".
def var v-kbe as char no-undo init "14".
def var v-knp as char no-undo init "890".
def var v-tit as char.
def var v-rem as char init "Инкассация ЭК N " no-undo .
def var Real-summ as deci extent 4.

def var v-ja as logi no-undo /*format "Да/Нет" */ init yes.

def new shared var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.

def var rez as log.
def var v_trx as int no-undo.
def  var vj-label as char no-undo.
def var v_title as char no-undo. /*наименование платежа */
define variable quest as logical format "yes/no" no-undo.
define variable v-sts like jh.sts  no-undo.
{keyord.i}

def temp-table wrk_jh no-undo
  field crc as int
  field gl_deb as char
  field acc_deb as char
  field gl_cre as char
  field acc_cre as char
  field acc_cre_bal as deci
  field acc_cre_summ as deci .

define query q_list for wrk_jh .
 define browse b_list query q_list no-lock
   display wrk_jh.gl_deb   format "x(6)"  label "Дебет Г/К"
           wrk_jh.acc_deb  format "x(20)" label "Дебет АРП"
           wrk_jh.gl_cre   format "x(6)"  label "Кредит Г/К"
           wrk_jh.acc_cre  format "x(20)" label "Кредит АРП"
          /* wrk_jh.acc_cre_bal  format ">>>,>>>,>>9.99" label "Остаток"*/
           wrk_jh.acc_cre_summ format ">>>,>>>,>>9.99" label "Сумма"
           GetCRC(wrk_jh.crc) format "x(3)" label "Валюта"
          with  4  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).


v-rem = "Выгрузка ЭК ".
v_title = "Выгрузка ЭК ".
form
    v-joudoc label " Документ        " format "x(10)"  v_trx label "  ТРН " format "zzzzzzzzz"      skip
    v-depname label " ЦОК             " format "x(30)"  skip
    v-nomer  label " Номер ЭК        "  skip
           "                                   ДАННЫЕ ПРОВОДКИ  "  skip
    b_list skip
    v-rem    label " Примечание      " format "x(50)" skip
    v-kod    label " Код             " format "x(2)" skip
    v-kbe    label " Кбе             " format "x(2)" skip
    v-knp    label " КНП             " format "x(3)" skip(1)

    vj-label no-label v-ja no-label
WITH  SIDE-LABELS CENTERED ROW 7 TITLE v_title width 92 FRAME f_main.


on help of v-joudoc in frame f_main do:
    run a_help-joudoc1("VSI2").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.


if new_document then do:  /* создание нового документа  */
    run SelectSafe(s-ourbank,Base:dep-id, output v-nomer).
    if v-nomer = "" then do:
      message "Нет доступного ЭК!" view-as alert-box.
      hide frame f_main.
      return.
    end.

    if Base:dep-id = 1 then v-dep = '514'.
    else v-dep = "A" + string(Base:dep-id,'99').
    v-depname = Base:b-addr.

    run incas10(v-nomer, output Real-summ,output rez)  .
    if not rez then return.
    run CreateTransTemplate(output rez).
    if not rez then do:
     hide frame f_main no-pause.
     return.
    end.

    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    release nmbr.
    do transaction:
        displ v-joudoc format "x(10)" with frame f_main.
        v-ja = yes.
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */
else do:   /* редактирование документа   */
    run view_doc.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:

                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:

                        if joudop.type <> "VSI2" then do:
                            message substitute ("Документ не относится к типу выгрузка электронного кассира(счет 100200)") view-as alert-box.
                            return.
                        end.

                end.
                if joudoc.jh > 1 then do:
                    message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
                    return.
                end.
                if joudoc.who ne g-ofc then do:
                    message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
                    return.
                end.
            end.
           /* run save_doc.*/
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    v-rem = v_title + v-nomer.
    open query q_list for each wrk_jh .
    displ v-nomer v-depname b_list v-rem v-kod v-kbe v-knp vj-label v-ja no-label with frame f_main.

    update v-ja no-label with frame f_main.
    if keyfunction (lastkey) = "end-error" then undo.
    if v-ja then do:
        do transaction:
            if new_document then do:
                create joudoc.
                joudoc.docnum = v-joudoc.
                create joudop.
                joudop.docnum = v-joudoc.
            end.
            else do:
                find joudoc where joudoc.docnum = v-joudoc exclusive-lock.
                find joudop where joudop.docnum = v-joudoc exclusive-lock.
            end.
            joudoc.who = g-ofc.
            joudoc.whn = g-today.
            joudoc.tim = time.

            joudoc.dracctype = "4".
            joudoc.cracctype = "4".


            joudoc.remark[1] = v-rem .
            joudoc.chk = 0.
            joudoc.bas_amt = "D".
            run chgsts("JOU", v-joudoc, "new").

            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            joudop.type = "VSI2".


            joudop.doc1 = v-nomer.
            joudop.lname = v-dep.
            joudop.mname = v-depname.
            find current joudop no-lock no-error.
            displ v-joudoc with frame f_main.
            pause 0.
         end. /*end trans-n*/
    end.
end procedure.

procedure view_doc:
    update v-joudoc help "Введите номер документа, F2-помощь" with frame f_main.
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if trim(v-joudoc) = "" then undo, return.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, retry.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
           if  joudop.type <> "VSI2" then do:
                message substitute ("Документ не относится к типу выгрузка электронного кассира(счет 100200)") view-as alert-box.
                return.
           end.
    end.


    v-nomer = joudop.doc1.
    v-dep =   joudop.lname.
    v-depname = joudop.mname.
    find first sm18data where sm18data.txb = s-ourbank and
                             sm18data.safe = v-nomer and
                             sm18data.who_cr = g-ofc and
                             sm18data.state = 0 and
                             sm18data.oper_id = 10 and
                             sm18data.jh = 0 no-lock no-error.
    if avail sm18data then do:
      run incas10(v-nomer, output Real-summ,output rez)  .
      if not rez then return.
      run CreateTransTemplate(output rez).
      if not rez then do:
       hide frame f_main no-pause.
       return.
      end.
    end.
    else do:
      if joudoc.jh > 1 then do:
         run CreateTransForJH(joudoc.jh, output rez).
         if not rez then do:
          hide frame f_main no-pause.
          return.
         end.
      end.
    end.


    if joudoc.jh > 1 and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        return.
    end.
    v-nomer   = joudop.doc1.
    v-dep     = joudop.lname.
    v-depname = joudop.mname.
    v-rem     = joudoc.remark[1].
    v_trx     = joudoc.jh.

    open query q_list for each wrk_jh .
    displ v_trx v-nomer v-depname b_list v-rem v-kod v-kbe v-knp  with frame f_main.
end procedure.


Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        run view_doc.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if available joudoc then do:
            if not (joudoc.jh eq 0 or joudoc.jh eq ?) then do:
                message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box.
                undo, return.
            end.
            if joudoc.who ne g-ofc then do:
               message substitute (
                  "Документ принадлежит &1. Удалять нельзя.", joudoc.who) view-as alert-box.
               undo, return.
            end.
            displ vj-label no-label format "x(35)"  with frame f_main.
            pause 0.
            v-ja = no.
            update v-ja  with frame f_main.
            if v-ja then do:
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

                find first sm18data where sm18data.txb = s-ourbank and
                             sm18data.safe = v-nomer and
                             sm18data.who_cr = g-ofc and
                             sm18data.state = 0 and
                             sm18data.oper_id = 10 exclusive-lock no-error.
                if avail sm18data then do:
                 delete sm18data.
                 release sm18data.
                end.
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
   /* run view_doc.*/

    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh ne ? and joudoc.jh <> 0 then do:
        message "Транзакция уже проведена." view-as alert-box.
        undo, return.
    end.
    if joudoc.whn ne g-today then do:
        message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box.
        undo, return.
    end.
    if joudoc.who ne g-ofc then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        undo, return.
    end.

    v-ja = yes.
    displ vj-label no-label format "x(35)"  with frame f_main.
    pause 0.
    update v-ja  with frame f_main.
    if not v-ja then undo, return.

    s-jh = 0.


    for each  wrk_jh by wrk_jh.crc.
        v-tmpl = "jou0067".
        v-param = string(wrk_jh.acc_cre_summ) + vdel +
                  string(wrk_jh.crc) + vdel +
                  wrk_jh.acc_deb + vdel +
                  wrk_jh.acc_cre + vdel +
                  v-rem + vdel + '1' + vdel + '1' + vdel + '4' + vdel + '4' + vdel + '890'.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
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
        find first sm18data where sm18data.safe = v-nomer and
                             sm18data.who_cr = g-ofc and
                             sm18data.state = 0 and
                             sm18data.oper_id = 10 exclusive-lock no-error.
        if avail sm18data then do:
           sm18data.jh = s-jh.
           release sm18data.
        end.
        else message "Не найдена текущая операция инкассации!" view-as alert-box.

        run SetKassPl("CASHGL500",s-jh,280).

        MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) + " ~nНеобходим акцепт документа в п.м. 4.3.4 " view-as alert-box.
        v_trx = s-jh.
        display v_trx with frame f_main.
        if v-noord = no then run vou_bankt(1, 1, joudoc.info).
        else run printord(s-jh,"").

/*
        find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
        for each jl where jl.jh eq s-jh no-lock:
            if (jl.gl = sysc.inval or jl.gl = 100100) and jl.crc = 1 then do:
                create jlsach .
                jlsach.jh = s-jh.
                if jl.dc = "D" then jlsach.amt = jl.dam . else jlsach.amt = jl.cam .
                jlsach.ln = jl.ln .
                jlsach.lnln = 1.
                jlsach.sim = 280 .

            end.
        end.
        release jlsach.
*/
        for each csofc where csofc.nomer = v-nomer no-lock.
             run mail   (csofc.ofc + "@metrocombank.kz",
                        "METROCOMBANK <mkb@metrocombank.kz>",
                        v-rem,
                        "Добрый день!\n\n Необходимо отконтролировать инкассацию электронного кассира N: " + v-nomer +
                        "~n Проводка :" + string(s-jh) + "\n Инкассатор :" + g-ofc + "\n " + string(g-today) + "  " + string(time,"HH:MM"), "1", "","" ).
        end.
        hide all.
        view frame f_main.
end procedure.

procedure Delete_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc.
    if locked joudoc then do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box.
        pause 3.
        undo, return.
    end.
    s-jh = joudoc.jh.

    /* проверка свода кассы */
    quest = false.
    find sysc where sysc.sysc = 'CASVOD' no-lock no-error.
    if avail sysc then do:
       if sysc.loval = yes and sysc.daval = g-today then quest = true. /* блок кассы */
    end.
    find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
    find cursts where cursts.sub eq "jou" and cursts.acc eq v-joudoc use-index subacc no-lock no-error.

    find jh where jh.jh eq joudoc.jh no-lock no-error.

    for each jl where jl.jh eq s-jh no-lock:
        if jl.gl eq sysc.inval and (jl.sts eq 6 or cursts.sts eq "rdy") then do on endkey undo, return:
            message "Транзакция акцептована кассиром. Удалить нельзя." view-as alert-box.
            undo, return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then do:
            message "Свод кассы завершен, удалить нельзя" view-as alert-box.
            undo, return.
        end.
    end.

     do transaction on error undo, return:
        quest = false.
        if jh.jdt lt g-today then do:
            message substitute ("Дата проведения транзакции &1.  Сторно?", jh.jdt) update quest.
            if not quest then undo, return.
             /* -------------------------for cashofc, by sasco, 18.10.01 -------- */
            for each jl where jl.jh eq joudoc.jh no-lock:
                if not avail jl then message "NOT FOUND JL WITH JOUDOC.JH -> CASHOFC".
                else
                if jl.gl eq sysc.inval and jl.sts = 6 then do:
                    find cashofc where cashofc.whn eq jl.jdt and
                                       cashofc.ofc eq jl.teller and
                                       cashofc.crc eq jl.crc and
                                       cashofc.sts eq 2 /* current status */
                                       exclusive-lock no-error.
                    if avail cashofc then cashofc.amt = cashofc.amt + jl.cam - jl.dam.
                    else do:
                        create cashofc.
                        assign cashofc.whn = jl.jdt
                               cashofc.ofc = jl.teller
                               cashofc.crc = jl.crc
                               cashofc.who = g-ofc
                               cashofc.sts = 2
                               cashofc.amt = jl.cam - jl.dam.
                    end.
                    release cashofc.
                end.
            end.
            /* ------------------------------------------------------------------*/
            /* sasco - снятие блокировки с суммы */
            /* (которая для контроля старшим менеджером в 2.13) */
            run jou-aasdel (joudoc.cracc, joudoc.cramt, joudoc.jh).

            /* 13.10.2003 nadejda - поискать эту транзакцию в списке блокированных сумм валютного контроля и убрать пометку о зачислении суммы на счет клиента */
            run jou42-blkdel (joudoc.jh).

            run trxstor(input joudoc.jh, input 6, output s-jh, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.
            run x-jlvo.
        end.
        /* ------------storno ?????????-----------------*/
        else do:
            message "Вы уверены ?" update quest.
            if not quest then undo, return.

            v-sts = jh.sts.

            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.

            run trxdel (input s-jh, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                 if rcode = 50 then do:
                    hide all.
                    view frame f_main.
                end.
                message rdes.
                if rcode = 50 then do:
                    run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                    return.
                end.
                else undo, return.
            end.

           /* -------------------------for cashofc, by sasco, 18.10.01 -------- */
            for each jl where jl.jh eq joudoc.jh no-lock:
                if not avail jl then message "NOT FOUND JL WITH JOUDOC.JH -> CASHOFC".
                else
                if jl.gl eq sysc.inval and jl.sts = 6 then do:
                    find cashofc where cashofc.whn eq jl.jdt and
                                       cashofc.ofc eq jl.teller and
                                       cashofc.crc eq jl.crc and
                                       cashofc.sts eq 2 /* current status */
                                       exclusive-lock no-error.
                    if avail cashofc then cashofc.amt = cashofc.amt + jl.cam - jl.dam.
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

    end. /* transaction */

    do transaction:
        run comm-dj(joudoc.docnum).

        /* sasco - удалить записи о контроле для arpcon */
        find sysc where sysc.sysc = "ourbnk" no-lock no-error.
        /* найдем arpcon со счетом по дебету */
        find arpcon where arpcon.arp = joudoc.dracc and
                          arpcon.sub = 'jou' and
                          arpcon.txb = sysc.chval
                          no-lock no-error.
        if avail arpcon then do:
            /* удалим статус контроля из истории платежа */
            for each substs where substs.sub = 'jou' and
                                  substs.acc = joudoc.docnum and
                                  substs.sts = arpcon.new-sts:
                delete substs.
            end.

            find cursts where cursts.sub = 'jou' and cursts.acc = joudoc.docnum no-error.

            if avail cursts then do:
               find last substs where substs.sub = 'jou' and substs.acc = joudoc.docnum no-lock no-error.
               assign cursts.sts = substs.sts.
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

    if joudoc.jh eq ? then do:
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

    if joudoc.jh eq ? then do:
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

procedure CreateTransTemplate:
   def output param v-ret as log.
   def var i as int.
   def var v-arp as char.
   def var v-arp100200 as char.
   def var v-sumarp as deci.
   do i = 1 to 4:
    if Real-Summ[i] > 0 then do:
       for each arp where arp.gl = 100500 and arp.crc = i no-lock.
         find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
         if avail sub-cod then do:
            v-arp = arp.arp.
            v-sumarp = arp.dam[1] - arp.cam[1].
         end.
       end.
       if v-arp = "" then do:
         message "Не настроен счет ЭЛ КАССИРА в валюте " GetCRC(i) " !" view-as alert-box title " ОШИБКА ! ".
         v-ret = false.
         return.
       end.
       for each arp where arp.gl = 100200 and arp.crc = i no-lock.
         find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = "obmen1002" no-lock no-error.
         if avail sub-cod then do:
           find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp and sub-cod.ccode = v-dep no-lock no-error.
           if avail sub-cod then do:
              v-arp100200 = arp.arp.
           end.
         end.
       end.
       if v-arp100200 = "" then do:
         message "Не настроен арп счет 100200 в валюте " GetCRC(i) " !" view-as alert-box title " ОШИБКА ! ".
         v-ret = false.
         return.
       end.

       if Real-Summ[i] > v-sumarp then do:
         message "Сумма операции превышает текущий остаток по арп счету " GetCRC(i) view-as alert-box title " ОШИБКА ! ".
         v-ret = false.
         return.
       end.

       create wrk_jh.
              wrk_jh.crc = i.
              wrk_jh.gl_deb = "100200".
              wrk_jh.acc_deb = v-arp100200.
              wrk_jh.gl_cre = "100500".
              wrk_jh.acc_cre = v-arp.
              wrk_jh.acc_cre_bal = v-sumarp.
              wrk_jh.acc_cre_summ = Real-Summ[i].
    end.
   end.
   v-ret = true.
end procedure.

procedure CreateTransForJH:
    def input  param v-jh as int.
    def output param v-ret as log.
    def var i-count as int.
    def buffer b-jl for jl.
    for each jl where jl.jh = v-jh no-lock:
      i-count = i-count + 1.
    end.
    if i-count = 0 then do: v-ret = false. return. end.
    for each jl where jl.jh = v-jh no-lock by jl.ln:
      if jl.dc = 'D' then do:
         create wrk_jh.
                wrk_jh.crc = jl.crc.
                wrk_jh.gl_deb = string(jl.gl).
                wrk_jh.acc_deb = jl.acc.
         find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock.
                wrk_jh.gl_cre = string(b-jl.gl).
                wrk_jh.acc_cre = b-jl.acc.
                wrk_jh.acc_cre_summ = b-jl.cam.
      end.
    end.
    v-ret = true.
end procedure.