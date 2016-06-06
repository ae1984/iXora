/* a_cas2arp.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
         расходная операция с АРП счета
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        02.02.2011 Luiza
 * CHANGES
        19/03/2012 Luiza  - если тестовая база клиента finmon не вызываем
        20/03/2012 Luiza  - вызов функции isProductionServer выполняем в a_fimnon.i
        28.03.2012 damir  - добавил печать оперционного ордера, printvouord.p.
        29/03/2012 Luiza  - изменила наименование поля в форме на РНН получателя
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        07/05/2012 Luiza  - добавила процедуру defclparam
        10/05/2012 Luiza  - добавила контроль после транзакции
        14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
        15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
        28/06/2012 Luiza - изменила заполнение поля passp
        25/072012  Luiza   - изменила проверку суммы при работе с ЕК
        26/07/2012 Luiza   - слово ЕК заменила ЭК
        11/09/2012 Luiza - переход на ИИН и подключила {srvcheck.i}
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        05/04/2013 Luiza -  ТЗ № 1764 проверка признака блокирования валют при обменных операциях
        10/07/2013 Luiza -  ТЗ 1948 курс обмена валюты сохраняем в поле brate
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа

*/



define input parameter new_document as logical.
define variable m_sub           as character initial "jou".
def shared var v_u as int no-undo.
define shared var g-ofc  as char.


def var v-tmpl as char no-undo.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var v-param1 as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v_title as char no-undo. /*наименование платежа */
def  var v_sum as decimal no-undo. /* сумма*/
def  var v_sumk as decimal no-undo. /* сумма комиссии*/
def  var v_sumc as decimal no-undo.
def  var v_dt as int  no-undo format "999999". /* Дт 100100*/
def  var v_kt as int no-undo format "999999". /* КТ 287051*/
def new shared var s-lon like lon.lon.
def new shared var v-num as integer no-undo.
def var v-crc as int  no-undo .  /* Валюта*/
def var v-crck as int  no-undo .  /* Валюта comiss*/
def var v-arp as char format "x(20)". /* счет arp */
def var v-arpk as char format "x(20)". /* счет arp for comiss*/
def var v-cif as char format "x(6)". /* cif клиент*/
def var v_lname as char format "x(30)". /*  клиент*/
def var v_pakalp as char format "x(30)". /*  комиссия*/
def var v-cif1 as char format "x(6)". /*  клиент*/
def var v-jss as char format "x(12)". /*  рнн клиента*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v_tar as char no-undo format "x(3)".  /* tarif*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_oper as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_oper1 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_doc_num as char format "x(30)".
def  var  v_docwho as char no-undo.
def  var v_docdt as date no-undo.
def var v-rnn as char no-undo.
def shared var v-joudoc as char no-undo format "x(10)".
def shared var v-Get_Nal as logic.
def var v-cur as logic no-undo.

def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var v-name as char.
def var v_name as char.
def var v-templ as char.
define var v_codfrn as char init " ".
def var v-ec as char format "x(1)" no-undo.
def var v_trx as int no-undo.
def  var vj-label as char no-undo.
define new shared variable s-jh like jh.jh.
define variable v-cash   as logical no-undo.
define variable v-acc   as logical no-undo.
define variable v-sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
def var v-oplcom as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/
def var v-oplcom1 as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/
def var v-nal as decim.
def  var v_sum_lim as decimal no-undo. /* сумма*/
def var v-arpname as char.
def new shared var v_doc as char format "x(10)" no-undo.
def  var v-bplace as char no-undo.
define new shared variable vrat  as decimal decimals 4.


/* for finmon */
def var v-monamt as deci no-undo.
def var v-monamt2 as deci no-undo.
def buffer b-jl for jl.
def buffer bb-jl for jl.
def var v-oper as char no-undo.
def var v-cltype as char no-undo.
def var v-res as char no-undo.
def var v-res2 as char no-undo.
def var v-FIO1U as char no-undo.
def var v-publicf  as char no-undo.
def var v-OKED as char no-undo.
def var v-prtEmail as char no-undo.
def var v-prtFLNam as char no-undo.
def var v-prtFFNam as char no-undo.
def var v-prtFMNam as char no-undo.
def var v-prtOKPO  as char no-undo.
def var v-prtPhone as char no-undo.
def var v-clnameU as char no-undo.
def var v-prtUD as char no-undo.
def var v-prtUdN as char no-undo.
def var v-prtUdIs as char no-undo.
def var v-prtUdDt as char no-undo.
def var v-opSumKZT as char no-undo.
/*def var v-num as inte no-undo.*/
def var v-operId as integer no-undo.
def var v-kfm as logi no-undo init no.
def var v-numprt as char no-undo.
def var v-mess as integer no-undo.
def var v-dtbth as date no-undo.
def var v-bdt as char no-undo.
def var v-regdt as date no-undo.
def var v_rnn as char no-undo.
def var v-clname2 as char no-undo.
def var v-clfam2 as char no-undo.
def var v-clmname2 as char no-undo.
def var v-addr as char no-undo.
def var v-country2 as char.
def var famlist as char init "".
def var v-knpval as char no-undo.
def var v_mname as char no-undo.
def  var v-bdt1 as date no-undo.
def var v_rez as char.
def  var v_countr as char no-undo format "x(2)".
def  var v_countr1 as char no-undo format "x(2)".
def  var v_lname1 as char no-undo format "x(20)".
def  var v_name1 as char no-undo format "x(20)".
def  var v_mname1 as char no-undo format "x(20)".
def var v_addr as char.
def var v_tel as char.
def var v_public as char.
def var v_doctype as char.
def var v-cifmin as char.


/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-crc_valk as char no-undo format "xxx".
def var v-chEK as char format "x(20)". /* счет ЭК*/
def var v-chEK1 as char format "x(20)". /* счет ЭК для тенге*/
def var v-chEKk as char format "x(20)". /* счет ЭК для комиссии*/

/*------------------------------------*/

/*проверка банка*/
{yes-no.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */
{comm-txb.i}
{get-dep.i}
{findstr.i}
{kfm.i "new"}
{checkdebt.i &file = "bank"}
{keyord.i}

{srvcheck.i}

def var v_bin as logi init no.
def var v_label as char format "x(25)".
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v_bin = sysc.loval.
if v_bin  then v_label = " ИИН получателя         :". else v_label = " РНН получателя         :".

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.

if v-ek = 2 then do:
    find first codfr where codfr.codfr = 'ekcrc' no-lock no-error.
    if not avail codfr then do:
        message "В справочнике <codfr> отсутствует код <ekcrc> для определения допустимых валют при работе с ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
        return.
    end.
end.

    function crc-conv returns decimal (sum as decimal, c1 as int, c2 as int).
    define buffer bcrc1 for crc.
    define buffer bcrc2 for crc.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 no-lock no-error.
          return sum * bcrc1.rate[3] / bcrc2.rate[3].
       end.
       else return sum.
    end.

define button but label " "  NO-FOCUS.
s-ourbank = trim(sysc.chval).
{chk12_innbin.i}
   form
        v-joudoc  label " Документ               " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"           but skip
        v-arp     label " АРП счет               "  format "x(20)" validate(can-find(sub-cod where sub-cod.acc = v-arp and sub-cod.sub = "arp"
                        and sub-cod.d-cod = "clsa" and sub-cod.ccode = "msc" /*first arp where arp.arp = v-arp*/  no-lock),"Неверный  АРП счет или счет закрыт!")
        v-arpname no-label  colon 50 format "x(30)" skip
        v-crc     label " Валюта                 " format ">9" validate(can-find(first crc where crc.crc = v-crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum     LABEL " Сумма                  " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_lname   label " ФИО получателя         " format "x(60)" skip
        v_doc_num label " № докум. и дата выдачи " help "Введите номер докумета удостов. личность и дату выдачи документа" format "x(50)" validate(trim(v_doc_num) <> "", "Заполните номер документа") skip
        v_label no-label  v_rnn  no-label         help "Введите РНН или '-'" format "x(12)" validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip
        v_code   label  " КОД                    " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe    label  " КБе                    "  skip
        v_knp    label  " КНП                    "  skip
        v_oper   label  " Назначение платежа  "  skip
        v_oper1 no-label colon 22 skip
        v_oper2 no-label colon 22 skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME f_main.


/* help for cif */
/*DEFINE VARIABLE phand AS handle.
DEFINE QUERY q-help FOR arp.

DEFINE BROWSE b-help QUERY q-help
       DISPLAY arp.arp label "Счет ARP " format "x(20)" arp.des label "Наименование   " format "x(29)"
       arp.gl label "Счет Г/К" format "999999" arp.crc label "Вл " format "z9"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 35 width 69 NO-BOX.*/
/*  help for cif */

DEFINE QUERY q-knp FOR codfr.

DEFINE BROWSE b-knp QUERY q-knp
       DISPLAY codfr.code label "Код  " format "x(3)" codfr.name[1] label "Наименование   " format "x(60)"
       WITH  15 DOWN.
DEFINE FRAME f-knp b-knp  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 35 width 85 NO-BOX.

on help of v_knp in frame f_main do:
    OPEN QUERY  q-knp FOR EACH codfr where codfr.codfr = "spnpl" no-lock.
    ENABLE ALL WITH FRAME f-knp.
    wait-for return of frame f-knp
    FOCUS b-knp IN FRAME f-knp.
    v_knp = codfr.code.
    hide frame f-knp.
    displ v_knp with frame f_main.
end.


on help of v-crc in frame f_main do:
    run help-crc1.
end.
on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("CS5"). else run a_help-joudoc1 ("EK5").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

on choose of but in frame  f_main do:
end.

/*on "END-ERROR" of frame f-help do:
  hide frame f-help no-pause.
end.*/


/*on help of v-arp in frame f_main do:
    OPEN QUERY  q-help FOR EACH arp where arp.gl = 287031 or arp.gl = 287032  and length(arp.arp) >=20 no-lock.
    ENABLE ALL WITH FRAME f-help.
    wait-for return of frame f-help
    FOCUS b-help IN FRAME f-help.
    v-arp = arp.arp.
    hide frame f-help.
    displ v-arp with frame f_main.
end.*/


if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = "Расходная операция с АРП счета ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    v_oper = "".
    displ v-joudoc format "x(10)" v_label with frame f_main.
    v-ja = yes.
    v-arp = "".
    v_sum = 0.
    v-crc = ?.
    v_oper1 = "".
    v_oper2 = "".
    v-crck = ?.
    v_sumk = ?.
    v_tar = "".
    v_lname = "".
    v_doc_num = "".
    v_rnn = "".
    run save_doc.
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = "Расходная операция с АРП счета ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        vj-label  = " Сохранить изменения документа?...........".
        run view_doc.
        find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if available joudoc then do:
            find joudop where joudop.docnum = v-joudoc no-lock no-error.
            if available joudop then do:
                 if joudop.type <> "CS5"  and joudop.type <> "EK5" then do:
                    message substitute ("Документ не относится к типу расходная операция с АРП счета") view-as alert-box.
                    return.
                end.
                if v-ek = 1 and joudop.type = "EK5" then do:
                    message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                    return.
                end.
                if v-ek = 2 and joudop.type = "CS5" then do:
                    message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
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
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc v_label with  frame f_main.
    update  v-arp help "АПР счет; F2- помощь; F4-выход" with frame f_main.
    find first arp where arp.arp = v-arp no-lock no-error.
    if avail arp then do:
        v-arpname = arp.des.
        v-crc = arp.crc.
    end.
    displ v-arpname v-crc v_oper vj-label format "x(35)" no-label with frame f_main.
    if v-ek = 2 then do:
        find first codfr where codfr.codfr = 'ekcrc' and codf.code = string(v-crc) no-lock no-error.
        if not avail codfr then do:
            message "Не допустимый код валюты для работы с ЭК! Используйте счет 100100." view-as alert-box error.
            undo.
        end.
    end.
    update v_sum v_lname v_doc_num v_rnn with frame f_main.
    if v-ek = 2 then do:
        find first codfr where codfr.codfr = 'limek' and codfr.code = string(v-crc) no-lock no-error.
        if not avail codfr then do:
            message "В справ-ке <codfr> отсутствует запись суммы лимита для данной валюты по ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
            undo.
        end.
        else do:
            if v_sum > decim(trim(codfr.name[1])) then do:
                find first crc where crc.crc = v-crc no-lock no-error.
                message "Ошибка, сумма превышает лимит суммы при работе с ЭК "  + trim(codfr.name[1]) + " " + crc.code  view-as alert-box error.
                undo.
            end.
        end.
     end.
     update v_code v_kbe v_knp v_oper v_oper1 v_oper2 v-ja with frame f_main.
     if v-ja then do:
        if v-ek = 2 then do:
            find first crc where crc.crc = v-crc no-lock.
            v-crc_val = crc.code.
            for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                if avail sub-cod then do:
                    v-chEK = arp.arp.
                end.
            end.
            if v-chEK = '' then do:
                message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
                undo, return.
            end.

            find first arp no-lock no-error.
        end.

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
        joudoc.cramt = v_sum.
        if v-ek = 2 then joudoc.cracctype = "4". else joudoc.cracctype = "1".
        if v-ek = 2 then joudoc.cracc = v-chEK. else joudoc.cracc = "".
        joudoc.crcur = v-crc.

        joudoc.dramt = v_sum.
        joudoc.dracctype = "4".
        joudoc.drcur = v-crc.
        joudoc.dracc = v-arp.
        joudoc.info = v_lname .
        if num-entries(trim(v_doc_num),",") > 1 or num-entries(trim(v_doc_num)," ") <= 1 then joudoc.passp = trim(v_doc_num).
        else joudoc.passp = entry(1,trim(v_doc_num)," ") + "," + substring(trim(v_doc_num),index(trim(v_doc_num)," "), length(v_doc_num)).
        joudoc.perkod = v_rnn.
        joudoc.remark[1] = v_oper.
        joudoc.remark[2] = v_oper1.
        joudoc.rescha[3] = v_oper2.
        joudoc.chk = 0.
        run chgsts("JOU", v-joudoc, "new").
        find current joudoc no-lock no-error.
        joudop.who = g-ofc.
        joudop.whn = g-today.
        joudop.tim = time.
        if v-ek = 1 then joudop.type = "CS5". else joudop.type = "EK5".
        find current joudop no-lock no-error.

        find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" exclusive-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            sub-cod.acc = v-joudoc.
            sub-cod.sub = "jou".
            sub-cod.d-cod  = "eknp".
            sub-cod.ccode = "eknp".
        end.
        sub-cod.rdt = g-today.
        sub-cod.rcode = v_code + "," + v_kbe + "," + v_knp.
        displ v-joudoc with frame f_main.
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
    displ v-joudoc v_label with frame f_main.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, retry.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
         if joudop.type <> "CS5"  and joudop.type <> "EK5" then do:
            message substitute ("Документ не относится к типу расходная операция с АРП счета") view-as alert-box.
            return.
        end.
        if v-ek = 1 and joudop.type = "EK5" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            return.
        end.
        if v-ek = 2 and joudop.type = "CS5" then do:
            message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
            return.
        end.
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
    v-arp = joudoc.dracc.
    v_sum = joudoc.dramt.
    v-crc = joudoc.drcur.
    v_oper = joudoc.remark[1].
    v_oper1 = joudoc.remark[2].
    v_oper2 = joudoc.rescha[3].
    v_lname = joudoc.info.
    v_doc_num = joudoc.passp.
    v_rnn = joudoc.perkod.
    find first arp where arp.arp = v-arp no-lock no-error.
    if avail arp then do:
        v-arpname = arp.des.
    end.
    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then do:
        v_code = entry(1,sub-cod.rcode,',').
        v_kbe = entry(2,sub-cod.rcode,',').
        v_knp = entry(3,sub-cod.rcode,',').
    end.


    v-ja = yes.
    v_title = " Расходная операция с АРП счета ".
    displ v-joudoc v_trx v-arp v-arpname  v-crc v_sum v_lname v_doc_num v_rnn v_code v_kbe v_knp  v_oper v_oper1 v_oper2 with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = " Расходная операция с АРП счета ".
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
                find first substs  no-error.
                find cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc no-error.
                if available cursts then delete cursts.
                find first cursts no-lock no-error.

                find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp"  no-error.
                if avail sub-cod then delete sub-cod.
                find first sub-cod no-lock.
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
    v_title = "  Расходная операция с АРП счета ".
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


    /* фин мониторинг*/
    v_rez = v_code.
    v-knpval = "119".
    v_doc = v-joudoc.
    enable but with frame f_main.
    pause 0.
    {a_finmon.i}
    disable but with frame f_main.
    if keyfunction (lastkey) = "end-error" then do:
        message "Транзакция прервана!" view-as alert-box.
        return.
    end.
    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.

    v-ja = yes.
    displ vj-label no-label format "x(35)"  with frame f_main.
    pause 0.
    update v-ja  with frame f_main.
    if not v-ja or keyfunction (lastkey) = "end-error" then do:
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide frame f_main.
        return.
    end.
    /* проставление вида документа */
    find first sub-cod where sub-cod.sub = 'jou' and sub-cod.acc = v-joudoc and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.sub = 'jou'.
        sub-cod.acc = v-joudoc.
        sub-cod.d-cod = 'pdoctng'.
        sub-cod.ccode = "12" /* Платежный ордер */.
        sub-cod.rdt = g-today.
    end.

    def var v-int as decim.
    def var v-mod as decim.
    def var v-modc as decim.
    def var v-int1 as decim.
    def var v-mod1 as decim.
    def var v-modc1 as decim.
    def var v_sum1 as decim.
    /*EK 100500------------------------------------------------------*/
    if v-ek = 2 then do:
        for each arp where arp.gl = 100500 and arp.crc = 1 no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then do:
                v-chEK1 = arp.arp.
                /*v-sumarp = arp.dam[1] - arp.cam[1].*/
            end.
        end.
        if v-chEK1 = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте KZT!" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.

        find first crc where crc.crc = v-crc no-lock.
        v-crc_val = crc.code.
        for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then do:
                v-chEK = arp.arp.
                /*v-sumarp = arp.dam[1] - arp.cam[1].*/
            end.
        end.
        if v-chEK = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.

        find first arp no-lock no-error.
        s-jh = 0.
        /*---------------выделяем дробную часть  ----------------------------------------------*/
        if v-crc <> 1 then do:
            if v-crc = 4 then do:
                v_sum1 = decim(entry(1,string(v_sum),".")) / 100 .
                v-mod = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 100) + (v_sum - decim(entry(1,string(v_sum),"."))).
            end.
            else do:
                v_sum1 = decim(entry(1,string(v_sum),".")) / 10 .
                v-mod = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 10) + (v_sum - decim(entry(1,string(v_sum),"."))).
            end.
            v-int  = v_sum - v-mod.
            v-modc = round(crc-conv(decimal(v-mod), v-crc, 1),2).
            /*v-int = decim(entry(1,string(v_sum),".")).
            v-mod = v_sum - decim(entry(1,string(v_sum),".")).
            v-modc = round(crc-conv(decimal(v-mod), v-crc, 1),2).*/

            /* проверка блокировки курса --------------------------------*/
            if v-mod <> 0 then do:
                v-cur = no.
                run a_cur(input v-crc, output v-cur).
                if v-cur then undo, return.
            end.
            /*------------------------------------------------------------*/
        end.
        /*------------------------------------------------------------------------------------------*/
        if v-crc = 1 or v-mod = 0 then do:  /* дробной части нет  */
            v-tmpl = "JOU0056".
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-arp + vdel + v-chEK + vdel + (v_oper + v_oper1 + v_oper2)
                    + vdel + substr(v_code,1,1) + vdel + substr(v_kbe,1,1) + vdel + substr(v_code,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.  /*  if v-crc = 1 or v-mod = 0 then do*/
        else do:
            /* обрабатываем целую часть */
            v-tmpl = "JOU0056".
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-arp + vdel + v-chEK + vdel + (v_oper + v_oper1 + v_oper2)
                    + vdel + substr(v_code,1,1) + vdel + substr(v_kbe,1,1) + vdel + substr(v_code,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            /* обрабатываем конвертируем дробную часть */
            v-tmpl = "JOU0063".
            v-param = v-joudoc + vdel + string(v-mod) + vdel + string(v-crc) + vdel + v-chEK + vdel + "обмен валюты" +
                    vdel + "1" + vdel + "1" + vdel + "9" + vdel + "9" + vdel + "213" /*+ vdel + string(v-modc)*/ + vdel +
                    "1" + vdel + v-chEK1 .
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.


        find first arp no-lock no-error.

        find first jh where jh.jh = s-jh exclusive-lock.
        jh.party = v-joudoc.
        if jh.sts < 5 then jh.sts = 5.
        for each jl of jh:
            if jl.sts < 5 then jl.sts = 5.
        end.
        find current jh no-lock.

        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        if v-crc = 1 then joudoc.brate = 1.
        else do:
            find first crc where  crc.crc = v-crc no-lock no-error.
            joudoc.brate = crc.rate[2].
            joudoc.sn = 1.
        end.
        joudoc.srate = 1.
        find current joudoc no-lock no-error.
        if v-noord = yes then run printvouord(2).
    end. /* end v-ek = 2  */

    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
        s-jh = 0.
        v-tmpl = "JOU0001".
        v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-arp + vdel +
                    (v_oper + v_oper1 + v_oper2) + vdel + substring(v_code,1,1)
                    + vdel + substring(v_kbe,1,1) + vdel + substring(v_code,2,1)
                    + vdel + substring(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        if v-noord = yes then run printvouord(2).
    end.

    /*---------------------------------------------------------*/
    run chgsts(m_sub, v-joudoc, "trx").
    pause 1 no-message.
    find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
    joudoc.jh = s-jh.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    /* копируем заполненные данные по ФМ в реальные таблицы*/
    if v-kfm then do:
        run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
        hide all.
        view frame f_main.
    end.
    /**/
    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) + "~nНеобходим контроль в п.м. 2.4.1.1! 'Контроль документов'!" view-as alert-box.
    for each sendod no-lock.
        run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
            "Добрый день!\n\n Необходимо отконтролировать расход наличных денег со счета клиента \n Сумма: " + string(v_sum) +
            "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
            string(time,"HH:MM"), "1", "","" ).
    end.
    hide all.
    view frame f_main.
    pause 0.
    run chgsts(m_sub, v-joudoc, "bac").
    v_trx = s-jh.
    display v_trx with frame f_main.
    pause 0.

    if v-ek = 1 then do:
        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
    end.

    if v-crc = 1 or v-mod <> 0 then do:
        hide all no-pause.
        run x0-cont1.
        view frame f_main.
    end.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").

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
    if v-ek = 1 then find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
    if v-ek = 2 then find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
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
        if v-noord = no then run vou_bankt(2, 1, joudoc.info).
        else do:
            run printvouord(2).
            run printord(s-jh,"").
        end.
    end. /* transaction */
end procedure.

procedure Get_Nal:
    run view_doc.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh < 1 or joudoc.jh = ? then do:
        message "Транзакция не проведена." view-as alert-box.
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
    find cursts where cursts.acc = v-joudoc and cursts.sub = "jou" no-lock no-error.
    if avail cursts and cursts.sts = "rdy" then do :
      message "Проводка уже отштампована " view-as alert-box.
      undo, return.
    end.
    if not avail cursts or (avail cursts and cursts.sts <> "cas") then do :      message "Документ не отконтролирован " view-as alert-box.
      undo, return.
    end.
    v-Get_Nal = yes.

    /*vj-label  = " Выполнить выдачу наличных?..................".
    s-jh = joudoc.jh.
    enable but with frame f_main.
    pause 0.
    def var v-errmsg as char init "".
    def var v-rez as logic init false.
    run csstampf(s-jh, v-nomer, output v-errmsg, output v-rez ).
    view frame f_main.
    disable but with frame f_main.
    if  v-errmsg <> "" or not v-rez then do:
        if v-errmsg <> "" then message  v-errmsg view-as alert-box error.
        undo, return.
    end.
    run chgsts(m_sub, v-joudoc, "rdy").
    message "Проводка отштампована " view-as alert-box.

    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord("").*/
end procedure.

procedure create_100100:
    run a_create100100(v-joudoc).
end.

procedure defclparam.

    v-cltype = ''.
    v-res = ''.
    v-res2 = ''.
    v-publicf = ''.
    v-FIO1U = ''.
    v-OKED = ''.
    v-prtOKPO = ''.
    v-prtEmail = ''.
    v-prtPhone = ''.
    v-prtFLNam = ''.
    v-prtFFNam = ''.
    v-prtFMNam = ''.
    v-clnameU = ''.
    v-prtUD = ''.
    v-prtUdN = ''.
    v-prtUdIs = ''.
    v-prtUdDt = ''.
    v-bdt = ''.
    v-bplace = ''.

    if cif.type = 'B' then do:
        if cif.cgr <> 403 then v-cltype = '01'.
        if cif.cgr = 403 then v-cltype = '03'.
    end.
    else v-cltype = '02'.

    if cif.geo = '021' then do:
        v-res = 'KZ'.
        v-res2 = '1'.
    end.
    else do:
        v-res2 = '0'.
        if num-entries(cif.addr[1]) = 7 then do:
            v-country2 = entry(1,cif.addr[1]).
            if num-entries(v-country2,'(') = 2 then v-res = substr(entry(2,v-country2,'('),1,2).
        end.
    end.
    find first cif-mail where cif-mail.cif = cif.cif no-lock no-error.
    if avail cif-mail then v-prtEmail = cif-mail.mail.
    v-prtPhone = cif.tel.

    if v-cltype = '01' then do:
        v-clnameU = trim(cif.prefix) + ' ' + trim(cif.name).
        v-prtOKPO = cif.ssn.
    end.
    else v-clnameU = ''.

    if v-cltype = '02' or v-cltype = '03'then do:
        if v-cltype = '02' then do:
            if num-entries(trim(cif.name),' ') > 0 then v-prtFLNam = entry(1,trim(cif.name),' ').
            if num-entries(trim(cif.name),' ') >= 2 then v-prtFFNam = entry(2,trim(cif.name),' ').

            if num-entries(trim(cif.name),' ') >= 3 then v-prtFMNam = entry(3,trim(cif.name),' ').
        end.
        else do:
            find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
            if avail sub-cod and sub-cod.ccode <> 'msc' then do:
                if num-entries(trim(sub-cod.rcode),' ') > 0 then v-prtFLNam = entry(1,trim(sub-cod.rcode),' ').
                if num-entries(trim(sub-cod.rcode),' ') >= 2 then v-prtFFNam = entry(2,trim(sub-cod.rcode),' ').
                if num-entries(trim(sub-cod.rcode),' ') >= 3 then v-prtFMNam = entry(3,trim(sub-cod.rcode),' ').
            end.
        end.

        if cif.geo = '021' then v-prtUD = '01'.
        else v-prtUD = '11'.

        if num-entries(cif.pss,' ') > 1 then v-prtUdN = entry(1,cif.pss,' ').
        else v-prtUdN = cif.pss.

        if num-entries(cif.pss,' ') >= 2 then v-prtUdDt = entry(2,cif.pss,' ').
        if num-entries(cif.pss,' ') >= 3 then v-prtUdIs = entry(3,cif.pss,' ').
        if num-entries(cif.pss,' ') > 3 then v-prtUdIs = entry(3,cif.pss,' ') + ' ' + entry(4,cif.pss,' ').

        find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "publicf" use-index dcod no-lock no-error.
        if avail sub-cod and sub-cod.ccode <> 'msc' then v-publicf = sub-cod.ccode.

        v-bdt = string(cif.expdt,'99/99/9999').
        v-bplace = cif.bplace.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-FIO1U = sub-cod.rcode.

    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-OKED = sub-cod.ccode.
end procedure.

procedure Stamp_transaction:
    find first optitsec where optitsec.proc = "a_stamp" and lookup(g-ofc,optitsec.ofcs) > 0 no-lock no-error.
    if not avail optitsec then do :
      message "Нет доступа к меню 'Штамп'! " view-as alert-box.
      undo, return.
    end.
    if joudoc.jh < 1 or joudoc.jh = ? then do:
        message "Транзакция не проведена." view-as alert-box.
        undo, return.
    end.
    if joudoc.whn ne g-today then do:
        message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box.
        undo, return.
    end.
    /*if joudoc.who ne g-ofc then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        undo, return.
    end.*/
    find cursts where cursts.acc = v-joudoc and cursts.sub = "jou" no-lock no-error.
    if avail cursts and cursts.sts = "rdy" then do :
      message "Проводка уже отштампована " view-as alert-box.
      undo, return.
    end.
    if not avail cursts or (avail cursts and cursts.sts <> "cas") then do :      message "Документ не отконтролирован " view-as alert-box.
      undo, return.
    end.

    run a_stamp(joudoc.jh).
    pause 0.
    hide all.
    view frame f_main.
end.
