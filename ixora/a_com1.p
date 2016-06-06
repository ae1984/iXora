/* a_com1.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Автоматизация удержания комиссии с счета клиента
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        07.12.2011 Luiza
 * CHANGES
        06/02/2012 - перекомпиляция в связи с изменениями a_finmon.i
        07/02/2012 Luiza - добавила код тарифа 304
        21/02/2012 evseev - добавил код тарифа 191
        07/03/2012 Luiza  - изменила передачу параметров при вызове printord
        11.03.2012 damir - добавил печать оперционного ордера, printvouord.p.
        04.04.2012 damir - добавил печать оперционного ордера, printvouord.p при нажатии кнопки <печать>.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        03.05.2012 aigul - добавила списание комиссии за ЭЦП
        07/05/2012 Luiza - код тарифа 469
        15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
        03/07/2012 Luiza - добавила тарифы 152,155,169
        02/11/2012 Luiza - добавила тариф 058
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        10/04/2013 Luiza ТЗ 1515
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        06/08/2013 Luiza - ТЗ 1997 Расширение поля «Код тарифа»
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
        27.09.2013 damir - Внедрено Т.З. № 1693.
        30.09.2013 damir - Внедрено Т.З. № 2120.
        29/10/2013 Luiza - ТЗ 2161
*/


{mainhead.i}

define input parameter new_document as logical.
define variable m_sub           as character initial "jou".
def shared var v_u as int no-undo.

def var v-tmpl as char no-undo.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var v-param1 as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v_title as char no-undo. /*наименование платежа */
def  var v_sum as decimal no-undo. /* сумма*/
def  var v_sumk as decimal no-undo. /* сумма комиссии*/
def var v_arp as char format "x(20)" no-undo. /* счет карточка ARP*/
def  var v_dt as int  no-undo format "999999". /* Дт 100100*/
def  var v_kt as int no-undo format "999999". /* КТ 287051*/
def new shared var s-lon like lon.lon.
def new shared var v-num as integer no-undo.
def var v_crc as int  no-undo .  /* Валюта*/
def var v-chet as char format "x(20)". /* счет клиента*/
def var v-cif as char format "x(6)". /* cif клиент*/
def var v_name as char format "x(30)". /*  клиент*/
def var v_pakalp as char format "x(30)". /*  комиссия*/
def var v-cif1 as char format "x(6)". /*  клиент*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v_tar as char no-undo format "x(5)".  /* tarif*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_oper as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_oper1 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_filial as char format "x(30)".   /* название филиала*/
def var vparr as char no-undo.
def new shared var v-joudoc as char format "x(10)" no-undo.
def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var v-name as char.
def var v-templ as char.
define var v_codfrn as char init " ".
def var v_codfr as char format "x(2)" init "10". /*код операций  табл codfr для doch.codfr */
def var v-ec as char format "x(1)" no-undo.
def var v_trx as int no-undo.
def  var vj-label as char no-undo.
define new shared variable s-jh like jh.jh.
define variable v-cash   as logical no-undo.
define variable v-acc   as logical no-undo.
define variable v-sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
define variable listtar as char.

/* для комиссии*/
def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.

def var v-arp as char.
def var v-chk-comm as logical.
/*проверка банка*/
def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).
{keyord.i}


/*listtar = "191, 193, 180, 230,212, 258, 227, 233, 236, 238, 450, 429, 243, 244, 245, 029, 193, 181, 208, 209, 217, 213, 239, 159, 459,
            125, 161, 419, 262, 107, 108, 253, 213, 239, 304, 159, 420, 424, 028, 119, 809, 810, 809, 940, 980, 117, 924, 457, 442, 120, 146,
            040, 199, 402, 422, 431, 710, 711, 755, 754, 038, 740, 701,102, 104, 154, 109, 163, 214, 215, 019, 017, 202, 222, 111,
            112, 147, 403, 436, 401, 409, 439, 151, 102, 192, 153, 024, 204, 205, 218, 123, 132, 158, 456, 430, 804, 802, 803, 137,
            177, 039, 120, 440, 146, 040, 940, 980,  117, 976, 901, 902, 903, 905, 906, 907, 908, 909, 910, 981, 982, 987, 993,
            994, 988, 993, 994, 989, 984, 990, 985, 986, 126, 199, 970, 995, 996, 971, 997, 998, 999, 910, 911, 972, 960, 961, 962,
            963, 964, 965, 966, 967, 968, 969, 952, 953, 954, 955, 956, 957, 958, 959, 941, 942, 943, 944, 945, 946, 947, 983, 468, 057,
            469,152,155,169,058,105,106".

define temp-table temp-tarif2 like tarif2.
for each tarif2 where tarif2.stat  = "r" no-lock:
    if index(listtar, tarif2.str5) > 0 then do:
        create temp-tarif2.
        buffer-copy tarif2 to temp-tarif2.
    end.
end.*/

   form
        v-joudoc label " Документ        " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"skip
        v-chet  label " Счет клиента    "  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-chet no-lock),"Неверный счет клиента") skip
        v_name  label " Клиент          "   format "x(30)" skip
        /*v_sum   LABEL " Сумма платежа   " validate(v_sum >= 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip*/
        v_crc   label " Валюта комиссии " format ">9" validate(can-find(first crc where crc.crc = v_crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_tar   LABEL " Код тарифа      " format "x(5)"validate(can-find(first tarif2 where tarif2.str5 = v_tar and tarif2.stat  = "r" no-lock),"Неверный код тарифа комиссии")  help " Введите код тарифа комиссии"
        v_kt    label " ГК комиссии     " colon 50  format "999999" skip
        v_sumk  LABEL " Сумма комиссии  " validate(v_sumk > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        v_code  label " КОД             " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label " КБе             "  skip
        v_knp   label " КНП             "  skip
        v_oper  label " Назначение      "  skip
        v_oper1 no-label colon 1 skip
        v_oper2 no-label colon 1 skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 70 FRAME f_main.


/* help for cif */
DEFINE VARIABLE phand AS handle.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
/*  help for cif */

DEFINE QUERY q-tar FOR tarif2.

DEFINE BROWSE b-tar QUERY q-tar
       DISPLAY tarif2.str5 label "Код тарифа " format "x(5)" tarif2.pakalp label "Наименование   " format "x(55)"
       WITH  15 DOWN.
DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 35 width 100 NO-BOX.

/*обработка F4*/

on end-error of b-tar in frame f-tar do:
    hide frame f-tar.
   undo, return.
end.

on help of v-joudoc in frame f_main do:
    run a_help-joudoc1 ("CM1").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

  on help of v_tar in frame f_main do:
        OPEN QUERY  q-tar FOR EACH tarif2 where tarif2.stat  = "r" no-lock.
        ENABLE ALL WITH FRAME f-tar.
        wait-for return of frame f-tar
        FOCUS b-tar IN FRAME f-tar.
        v_tar = tarif2.str5.
        hide frame f-tar.
    displ v_tar with frame f_main.
  end.
on "END-ERROR" of frame f-tar do:
  hide frame f-tar no-pause.
end.

/*  help for cif */
on help of v-chet in frame f_main do:
    on "END-ERROR" of frame f-help do:
    end.
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                        each lgr where aaa.lgr = lgr.lgr  and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-chet = aaa.aaa.
            hide frame f-help.
        end.
        else do:
            v-chet = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
        end.
        displ  v-chet with frame f_main.
    end.
    DELETE PROCEDURE phand.
end.
/*  help for cif */

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = " УДЕРЖАНИЕ КОМИССИИ СО СЧЕТА КЛИЕНТА ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    do transaction:
        v_oper = "Комиссия за ".
        displ v-joudoc format "x(10)" with frame f_main.
        v_kbe = "14".
        v_knp = "840".
        v_sum = 0.
        v_sumk = 0.
        v-ja = yes.
        v-chet = "".
        v-cif = "".
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = " УДЕРЖАНИЕ КОМИССИИ СО СЧЕТА КЛИЕНТ ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                    if joudop.type <> "CM1" then do:
                        message substitute ("Документ не относится к типу удержание комиссии со счета клиента") view-as alert-box.
                        return.
                    end.
                end.
                if joudoc.jh ne ? then do:
                    message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
                    return.
                end.
                if joudoc.who ne g-ofc then do:
                    message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
                    return.
                end.
            end.
            run save_doc.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc  v_kbe v_knp  with  frame f_main.
    update  v-chet help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v_crc = aaa.crc.
    end.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        if cif.bin = '' then do:
            if g-today < 01/01/13 then message ' ИИН/БИН отсутсвует в карточке клиента, запросите у клиента документ с ИИН/БИН и внесите данные в АБС. ' view-as alert-box title " ВНИМАНИЕ ! ".
            else do:
                message ' Операции без ИИН/БИН невозможны. ' view-as alert-box title " ВНИМАНИЕ ! ".
                return.
            end.
        end.
        if cif.type = "P" then v_name  = trim(trim(cif.prefix) + " " + trim(cif.name)). else v_name  = trim(trim(cif.prefix) + " " + trim(cif.sname)).
        if cif.type = "P" then v-ec = "9".
        else do:
            find last sub-cod where sub-cod.acc = v-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
            if available sub-cod then v-ec = sub-cod.ccode.
            else do:
                message "В справочнике неверно заполнен сектор экономики клиента. Обратитесь к администратору" view-as alert-box.
                undo, return.
            end.
        end.
        if cif.geo = "021" then v_code = "1" + v-ec.
        else do:
            if   cif.geo = "022" then v_code = "2" + v-ec.
            else do:
                message "В справочнике неверно заполнен ГЕО-КОД клиента. Обратитесь к администратору" view-as alert-box.
                undo, return.
            end.
        end.
    end.
    displ v_name v_crc  v_code vj-label format "x(35)" no-label with frame f_main.
    update /*v_sum*/ v_tar with frame f_main.
    if trim(v_tar) = "041" then v_knp = "890".
    displ v_knp with frame f_main.
    find first tarif2 where tarif2.str5 = trim(v_tar) and tarif2.stat  = "r" no-lock no-error.
    if avail tarif2 then do:
        v_oper = "Комиссия за " + tarif2.pakalp.
        if trim(v_tar) = "041" then v_oper = trim(replace(v_oper,"Комиссия за","")).
        if length(trim(v_oper)) > 45 then do:
            v_oper1  = substring(trim(v_oper),46,55).
            v_oper = substring(trim(v_oper),1,45).
        end.
        v_kt = tarif2.kont.
        displ v_kt v_oper v_oper1 with frame f_main.
    end.
     /* вычисление суммы комиссии-----------------------------------*/
    /*v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
    run perev ("",input v_tar, input v_sum, input v_crc, input v_crc,"", output v-amt, output tproc, output pakal).*/
    v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
    run perev (v-chet,input v_tar, input v_sum, input v_crc, input v_crc,v-cif, output v-amt, output tproc, output pakal).
    v_sumk = v-amt.
    if trim(v_tar) = "041" then v_sumk = 0.00.
    /*------------------------------------------------------------*/

    update v_sumk v_oper1 v_oper2 v-ja with frame f_main.
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
           /* joudoc.dramt = v_sum.*/
            joudoc.dracctype = "2".
            joudoc.dracc = v-chet.
            joudoc.drcur = v_crc.
            /*joudoc.cramt = v_sum.*/
            joudoc.cracctype = "5".
            joudoc.crcur = v_crc.
            joudoc.comamt = v_sumk.
            joudoc.comacctype = "2".
            joudoc.comacc = v-chet.
            joudoc.comcur = v_crc.
            joudoc.comcode = v_tar.
            joudoc.comvo = "09".
            joudoc.info = v_name.
            joudoc.remark[1] = v_oper.
            joudoc.remark[2] = v_oper1 + "^" + v_oper2.
            joudoc.chk = 0.
            joudoc.rescha[2] = v_code.
            run chgsts("JOU", v-joudoc, "new").
            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            joudop.type = "CM1".
            find current joudop no-lock no-error.
            displ v-joudoc with frame f_main.
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
    displ v-joudoc with frame f_main.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        if joudop.type <> "CM1" then do:
            message substitute ("Документ не относится к типу удержание комиссии со счета клиента") view-as alert-box.
            return.
        end.
    end.
    if not (joudoc.dracctype = "2" and joudoc.cracctype = "5") then do:
        message substitute ("Документ не относится к типу удержание комиссии со счета клиента") view-as alert-box.
        return.
    end.
    if joudoc.jh ne ? and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        return.
    end.
    v_trx = joudoc.jh.
    v-chet = joudoc.dracc.
    /*v_sum = joudoc.dramt.*/
    v_crc = joudoc.drcur.
    v_sumk = joudoc.comamt.
    v_oper = joudoc.remark[1].
    v_oper1 = entry(1,joudoc.remark[2],"^").
    if num-entries(joudoc.remark[2],"^") > 1 then v_oper2 = entry(2,joudoc.remark[2],"^").
    v_code = joudoc.rescha[2].
    v_kbe = "14".
    v_knp = "840".
    v_tar = joudoc.comcode.
    if trim(v_tar) = "041" then v_knp = "890".
    find first tarif2 where tarif2.str5 = trim(v_tar) and tarif2.stat  = "r" no-lock no-error.
    if avail tarif2 then do:
        /*v_oper = "Комиссия за " + tarif2.pakalp.*/
        v_kt = tarif2.kont.
    end.
        find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v_crc = aaa.crc.
    end.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        if cif.type = "P" then v_name  = trim(trim(cif.prefix) + " " + trim(cif.name)). else v_name  = trim(trim(cif.prefix) + " " + trim(cif.sname)).
        if cif.type = "P" then v-ec = "9".
        else do:
            find last sub-cod where sub-cod.acc = v-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
            if available sub-cod then v-ec = sub-cod.ccode.
            else do:
                message "В справочнике неверно заполнен сектор экономики клиента. Обратитесь к администратору" view-as alert-box.
                undo, return.
            end.
        end.
        if cif.geo = "021" then v_code = "1" + v-ec.
        else do:
            if   cif.geo = "022" then v_code = "2" + v-ec.
            else do:
                message "В справочнике неверно заполнен ГЕО-КОД клиента. Обратитесь к администратору" view-as alert-box.
                undo, return.
            end.
        end.
    end.
    v-ja = yes.
    v_title = " УДЕРЖАНИЕ КОМИССИИ СО СЧЕТА КЛИЕНТА ".
    displ v-joudoc v_trx v-chet v_name v_kbe v_knp v_crc /*v_sum */ v_tar v_kt v_sumk v_code v_oper v_oper1 v_oper2 no-label with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = "  УДЕРЖАНИЕ КОМИССИИ СО СЧЕТА КЛИЕНТА ".
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
    v_title = "  УДЕРЖАНИЕ КОМИССИИ СО СЧЕТА КЛИЕНТА ".
    run view_doc.
    if keyfunction (lastkey) = "end-error" then undo, return.
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

    /*find first cursts no-lock no-error.
    release cursts.
    find cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc no-lock no-error.
    if available cursts then do:
        if cursts.sts <> "con" then do:
            message "Документ должен пройти контроль в п.м. 2.4.1.1! 'Контроль документов'!" view-as alert-box.
            undo, return.
        end.
    end.
    else do:
            message "Не найден статус документа, обратитесь к разработчику!" view-as alert-box.
            undo, return.
    end.

    do transaction:
        run checkarp (joudoc.docnum).
    end.
    if return-value = 'no' then return.
    if return-value = 'con' then do:
        message "Документ должен пройти дополнительный контроль!" view-as alert-box.
        return.
    end.

    find first jouset where jouset.drnum eq joudoc.dracctype and jouset.crnum eq joudoc.cracctype no-lock no-error.
    if not available jouset or jouset.proc eq "" then do:
        message "РЕЖИМ НЕ РАБОТАЕТ." view-as alert-box.
        undo, return.
    end.*/

    v-ja = yes.
    displ vj-label no-label format "x(35)"  with frame f_main.
    pause 0.
    update v-ja  with frame f_main.
    if not v-ja then undo, return.

    /* проставление вида документа */
    find first sub-cod where sub-cod.sub = 'jou' and sub-cod.acc = v-joudoc and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.sub = 'jou'.
        sub-cod.acc = v-joudoc.
        sub-cod.d-cod = 'pdoctng'.
        sub-cod.ccode = "01" /* Платежное поручение */.
        sub-cod.rdt = g-today.
    end.

    do transaction on error undo, retry :
        v_oper = v_oper + " " + v_oper1 + " " + v_oper2.
        /* формир v-param для trxgen.p */
        if v_kt = 460828 then do:
            v-chk-comm = yes.
            find first aaa where aaa.aaa = v-chet no-lock no-error.
            if avail aaa then do:
                if v_sumk > aaa.cbal - aaa.hbal then do:
                    MESSAGE "Ошибка, на выбранном счете недостаточно средств ~nдля списания комиссии" VIEW-AS ALERT-BOX.
                    v-chk-comm = no.
                end.
                if not (aaa.gl = 220310 or aaa.gl = 220420 or aaa.gl = 220520) then do:
                    MESSAGE "Комиссию можно снять только со счетов открытых на счетах ГК 220310, 220420, 220520 в тенге" VIEW-AS ALERT-BOX.
                    v-chk-comm = no.
                end.
            end.
            if v-chk-comm then do:
                /*"Комиссия за выпуск электронной цифровой подписи (ЭЦП)"*/
                find first arp where arp.gl = 287082 no-lock no-error.
                if avail arp then v-arp = arp.arp.
                v-param = string(v_sumk) + vdel + "1" + vdel + v-chet + vdel + v-arp + vdel + v_oper  + vdel + "840".
                s-jh = 0.
                run trxgen ("jou0068", vdel, v-param, "cif", v-chet, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
                run chgsts(m_sub, v-joudoc, "trx").
                pause 1 no-message.
            end.
        end.
        else do:
            v-tmpl = "jou0026".
            v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crc) + vdel + v-chet + vdel + string(v_kt) + vdel + v_oper.
            s-jh = 0.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            run chgsts(m_sub, v-joudoc, "trx").
            pause 1 no-message.
        end.
        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        find current joudoc no-lock no-error.
        MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.
        v_trx = s-jh.
        display v_trx with frame f_main.
        if v-noord = yes then run printvouord(2).
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        /* проставляем статус 6 */
        run trxsts (input s-jh, input 6, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return .
        end.
        run chgsts(m_sub, v-joudoc, "rdy").

        if v-noord = no then run vou_bank(1).
        else run printord(s-jh,"").
    end. /* transaction */
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
    find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
    find cursts where cursts.sub eq "jou" and cursts.acc eq v-joudoc use-index subacc no-lock no-error.

    find jh where jh.jh eq joudoc.jh no-lock no-error.

    for each jl where jl.jh eq s-jh no-lock:
        if jl.gl eq sysc.inval and (jl.sts eq 6 or cursts.sts eq "rdy") then do on endkey undo, return:
            message "Транзакция акцептована кассиром. Удалить нельзя.".
            pause 3.
            undo, return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then do:
            message "Свод кассы завершен, удалить нельзя" view-as alert-box.
            undo, return.
        end.
    end.
    /* ------------storno ?????????-----------------*/
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
        if v-noord = no then run vou_bank(1).
        else do:
            run printvouord(2).
            run printord(s-jh,"").
        end.
    end. /* transaction */
end procedure.

procedure PrintPayDoc:
    {PrintPayDoc.i}
end procedure.


