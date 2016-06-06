/* a_obmen1.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        обмен валют
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
 * AUTHOR
        16.05.2011 Luiza
 * CHANGES
        06/02/2012 - перекомпиляция в связи с изменениями a_finmon.i
        07/03/2012 Luiza  - изменила передачу параметров при вызове printord
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        25.04.2012 aigul - сделала строгий выбор суммы для льготных курсов
        14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
        26/06/2012 Luiza - в поле joudoc.passp "^" заменила на ","
        10/07/2012 dmitriy - изменил вывод на экран клиента
        12/07/2012 dmitriy - вывод на экран клиента только для филиалов, прописанных в sysc = "CifScr"
        25/072012  Luiza   - изменила проверку суммы при работе с ЕК
        17/08/2012 Luiza  - согласно СЗ добавила проверку курса на момент транзакции и  шаблон jou0064 для спец курса
        24/08/2012 Luiza   - слово ЕК заменила ЭК
        13/09/2012 Luiza - отменила ecxlusive-lock для crc и если есть десятичные операция проводится через 100100
        08/11/2012 Luiza  - изменение символов касплана по СЗ от 07/11/2012
        15/01/2013 Luiza   - ТЗ 1595 Изменение счета ГК 1858
        26/03/2013 Luiza -  ТЗ 1714 изменения проставления кассплана
        05/04/2013 Luiza -  ТЗ № 1764 проверка признака блокирования валют при обменных операциях
        14/05/2013 Luiza -  ТЗ № 1838 заполнение миникарточки при обмене наличности >= 1000$
        15/05/2013 Luiza -  ТЗ 1826 добавление евро для 100500
        19/06/2013 Luiza -  ТЗ 1887 добавление ИИН в миникарточку при обмене наличности >= 1000$
        18/07/2013 Luiza -  ТЗ 1967 откат по F4
        06/09/2013 Luiza -  ТЗ 2077
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
def  var v_sum2 as decimal no-undo. /* сумма*/

def  var v_sum1 as decimal no-undo. /* сумма комиссии*/
def var v_crc as int  no-undo .  /* Валюта*/
def var v_crc1 as int  no-undo .  /* Валюта*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_oper as char no-undo format "x(45)".  /* Назначение платежа*/
def shared var v-joudoc as char no-undo format "x(10)".
def shared var v-Get_Nal as logic.

def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var v-name as char.
def var v-templ as char.
define var v_codfrn as char init " ".
def var v_trx as int no-undo.
def  var vj-label as char no-undo.
define new shared variable s-jh like jh.jh.
define variable v-cash   as logical no-undo.
define variable v-sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
def var v_rnn as char.
def var v-label as char.
def var v_rate as decim.
def var v_rate1 as decim.
def var v_bn as int.
def var v_sn as int.
def new shared var v-crclgt as decimal.
def new shared var v-dateb as date.
def new shared var v-lgcurs as logical init False.
define new shared variable vrat  as decimal decimals 4.
define variable m_buy   as decimal.
define variable m_sell  as decimal.
define variable vparam  as character.
def var v_st as char.
def var v_st1 as char.
def var v-passp as char.
def var v-passpwho as char.
def var v_int as decim.
def var v_mod as decim.
def var v-typ as char.
def var v-crc as int.
def var v-cur as logic no-undo.
define variable yn      as logical no-undo.

/* for finmon */
def var v_doc as char .
def var v_doc_num as char format "x(30)".
def  var v_lname as char no-undo format "x(20)".
def  var v_mname as char no-undo format "x(20)".
def  var v_name as char no-undo format "x(20)".
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
def var v-num as inte no-undo.
def var v-operId as integer no-undo.
def var v-kfm as logi no-undo init no.
def var v-numprt as char no-undo.
def var v-mess as integer no-undo.
def var v-dtbth as date no-undo.
def var v-bdt as char no-undo.
def var v-regdt as date no-undo.
def var v-rnn as char no-undo.
def var v-clname2 as char no-undo.
def var v-clfam2 as char no-undo.
def var v-clmname2 as char no-undo.
def var v-addr as char no-undo.
def var v-country2 as char.
def var famlist as char init "".
def var v_rnnp as char.
def var v-labelp as char format "x(22)".
def  var  v_docwho as char no-undo.
def  var v_docdt as date no-undo.
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
def  var v-bplace as char no-undo.

/*---------------------------*/

/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-crc_val1 as char no-undo format "xxx".
def var v-chEK as char format "x(20)". /* счет ЭК*/
def var v-chEK1 as char format "x(20)". /* счет ЭК*/
def var v-chEKk as char format "x(20)". /* счет ЭК for comis*/
/*------------------------------------*/
def var zcrc as int.
def var zamt as decim.
def var zbasamt as char.

find sysc where sysc.sysc = "obmcon" no-lock no-error. /* пороговая сумма */
if available sysc and sysc.inval >= 1 and sysc.deval > 0 then do:
    zcrc = sysc.inval.
    zamt = sysc.deval.
 end.
else do :
    message "В справочнике <sysc> отсутствует код <obmcon> для определения контрольной суммы!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.

/* screen    */
def shared var v-res111 as char.
def var TSUMM1 as char.
def var TCRC1 as char.
def var TSUMM2 as char.
def var TCRC2 as char.
def var TRATE as char.
def var sr-ans as logic.
def var i as int.

{chk12_innbin.i}

if v-ek = 2 then do:
    find first codfr where codfr.codfr = 'ekcrc' no-lock no-error.
    if not avail codfr then do:
        message "В справочнике <codfr> отсутствует код <ekcrc> для определения допустимых валют при работе с ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
        return.
    end.
end.

    function getcrc returns char(cc as int).
        find first crc where crc.crc = cc no-lock no-error.
        if avail crc then return crc.code.
        else return "".
    end.

    function crc-conv returns decimal (sum as decimal, c1 as int, c2 as int).
    define buffer bcrc1 for crc.
    define buffer bcrc2 for crc.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 no-lock no-error.
          return sum * bcrc1.rate[2] / bcrc2.rate[3].
       end.
       else return sum.
    end.

    function crc-conv1 returns decimal (sum as decimal, c1 as int, c2 as int).
    define buffer bcrc1 for crc.
    define buffer bcrc2 for crc.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 no-lock no-error.
          return sum * bcrc1.rate[2] / bcrc2.rate[3].
       end.
       else return sum.
    end.

DEFINE QUERY q-tar FOR tarif2.

DEFINE BROWSE b-tar QUERY q-tar
       DISPLAY tarif2.str5 label "Код тарифа " format "x(3)" tarif2.pakalp label "Наименование   " format "x(30)"
       WITH  15 DOWN.
DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.

/*проверка банка*/
def buffer b-sysc for sysc.
/*def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).*/
{keyord.i}
{to_screen.i}

define button but label " "  NO-FOCUS.

   form
        v-joudoc label " Документ      " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz" but skip(1)
        " ________ДЕБЕT___________"   "________КРЕДИТ__________" colon 48 skip(1)
        v_crc    label " Валюта дебета " format "z9" validate(can-find(first crc where crc.crc = v_crc and crc.sts <> 9 no-lock),"Неверный код валюты!")
        v_crc1   label " Валюта кредита " colon 65 format "z9" validate(can-find(first crc where crc.crc = v_crc1 and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum    LABEL " Сумма         " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа"
        v_sum1   LABEL " Сумма          " colon 65 /* validate(v_sumk > 0, "Hеверное значение суммы")*/ format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        v_rate   label " Курс покупки  " format "999.9999" "KZT /" v_bn format "zzzzzzz" no-label space(1) v-crc_val no-label
        v_rate1  label " Курс продажи   " colon 65 format "999.9999" "KZT /" v_sn format "zzzzzzz" no-label space(1) v-crc_val1 no-label skip(1)
        v_code   label " КОД           " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_knp    label " КНП           "  skip
        v_oper   label " Назначение платежа"  skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS column 5 ROW 7 TITLE v_title width 100 FRAME f_main.




/*обработка F4*/
on choose of but in frame  f_main do:
end.

on "END-ERROR" of but in frame f_main do:
end.


on help of v_crc in frame f_main do:
    run help-crc1.
end.

on help of v_crc1 in frame f_main do:
    run help-crc1.
end.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("OBM"). else run a_help-joudoc1 ("BOM").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
on "END-ERROR" of v-ja in frame f_main do:
  view frame f_main.
  undo, return.
end.


{yes-no.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */
{comm-txb.i}
{get-dep.i}
{findstr.i}
{kfm.i "new"}
def var v-knpval as char no-undo.
v-knpval = "119".


if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = " ОБМЕННЫЕ ОПЕРАЦИИ ЧЕРЕЗ ЭК ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    /* do transaction:*/
        v_oper = "Обмен валюты ".
        displ v-joudoc format "x(10)" with frame f_main.
        v_code = "19".
        v_sum = 0.
        v_sum1 = 0.
        v-ja = yes.
        run save_doc.
    /*end.*/  /* end transaction    */
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = " ОБМЕННЫЕ ОПЕРАЦИИ ЧЕРЕЗ ЭК ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        /*do transaction:*/
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                    if joudop.type <> "OBM" and joudop.type <> "BOM" then do:
                        message substitute ("Документ не относится к типу Обмен валюты через ЭК ") view-as alert-box.
                        return.
                    end.
                    if v-ek = 1 and joudop.type = "BOM" then do:
                        message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                        return.
                    end.
                    if v-ek = 2 and joudop.type = "OBM" then do:
                        message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
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
            run save_doc.
        /*end.*/
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc   v_code v_oper with  frame f_main.
   /* L_1:*/
    repeat /*on endkey undo, next L_1*/ :
        repeat:
            update v_crc  with frame f_main.
            if v-ek = 2 then do:
                find first codfr where codfr.codfr = 'ekcrc' and codf.code = string(v_crc) no-lock no-error.
                if not avail codfr then do:
                    message "Не допустимый код валюты для работы с ЭК! Используйте счет 100100." view-as alert-box error.
                    undo.
                end.
                else leave.
            end.
            else leave.
        end.
        if keyfunction (lastkey) = "end-error" then return.
        repeat:
            update v_crc1  with frame f_main.
            if v-ek = 2 then do:
                find first codfr where codfr.codfr = 'ekcrc' and codf.code = string(v_crc1) no-lock no-error.
                if not avail codfr then do:
                    message "Не допустимый код валюты для работы с ЭК! Используйте счет 100100." view-as alert-box error.
                    undo.
                end.
                else leave.
            end.
            else leave.
        end.
        if keyfunction (lastkey) = "end-error" then undo.
       message "  F2 - ПОМОЩЬ  ".
            if v_crc = v_crc1 then do:
                message "ОДИНАКОВЫЕ КОДЫ ВАЛЮТ." view-as alert-box error.
                undo, retry.
            end.
            if v_crc <> 1 and v_crc1 <> 1 then do:
                message "Данная операция невыполнима! ~nНеверный код валюты" view-as alert-box error.
                undo, retry.
            end.
            else leave.
    end.
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    v_sum1 = 0.

    if v_crc = 1 then do:
        v_sum = 0.
        update v_sum1  with frame f_main.
        find first codfr where codfr.codfr = 'limek' and codfr.code = string(v_crc1) no-lock no-error.
        if not avail codfr then do:
            message "В справ-ке <codfr> отсутствует запись суммы лимита для данной валюты по ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
            undo.
        end.
        else do:
            if v_sum1 > decim(trim(codfr.name[1])) then do:
                find first crc where crc.crc = v_crc1 no-lock no-error.
                message "Ошибка, сумма превышает лимит суммы при работе с ЭК "  + trim(codfr.name[1]) + " " + crc.code  view-as alert-box error.
                undo.
            end.
        end.
    end.
    else do:
        v_sum1 = 0.
        update v_sum  with frame f_main.
        find first codfr where codfr.codfr = 'limek' and codfr.code = string(v_crc) no-lock no-error.
        if not avail codfr then do:
            message "В справ-ке <codfr> отсутствует запись суммы лимита для данной валюты по ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
            undo.
        end.
        else do:
            if v_sum > decim(trim(codfr.name[1])) then do:
                find first crc where crc.crc = v_crc no-lock no-error.
                message "Ошибка, сумма превышает лимит суммы при работе с ЭК "  + trim(codfr.name[1]) + " " + crc.code  view-as alert-box error.
                undo.
            end.
        end.
    end.
    /* проверка блокировки курса --------------------------------*/
    v-cur = no.
    if v_crc = 1 then run a_cur(input v_crc1, output v-cur).
    else run a_cur(input v_crc, output v-cur).
    if v-cur then undo,return.
    /*------------------------------------------------------------*/

    find first crc where crc.crc = v_crc no-lock.
    if v_crc = 1 then v_rate = crc.rate[3]. else v_rate = crc.rate[2].
    v-crc_val = crc.code.
    /*v_sum1  = round(crc-conv(decimal(v_sum), v_crc, v_crc1),2).
    v_bn = 1.*/

    find first crc where crc.crc = v_crc1 no-lock.
    if v_crc1 = 1 then v_rate1 = crc.rate[2]. else v_rate1 = crc.rate[3].
    v-crc_val1 = crc.code.
    /*v_sum1  = round(crc-conv1(decimal(v_sum), v_crc, v_crc1),2).
    v_sn = 1.*/
    if v_crc = 1 then v_knp = "223". else v_knp = "213".
    MESSAGE 'Внимание! Курс обмена льготный?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE otv AS LOGICAL.
    if otv = true then do:
        if v_crc = 1 then run kzn_lg(True, True, v_sum1, "C", v_crc1).
        else run kzn_lg(True, False, v_sum, "D", v_crc).
        if v-crclgt = 0 then do:
            MESSAGE "Ошибка, проверьте запись льготного курса в п.м.7.3.3. " VIEW-AS ALERT-BOX .
            return.
        end.
        if g-today > v-dateb then do:
          MESSAGE "Внимание: срок действия данного курса истек. " VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "".
          return.
        end.
        vrat = v-crclgt.
        if vrat = 0 then return.

        if v_u = 2 then run check_rate.

        if v_crc = 1 then run conv-obm(input v_crc1, input v_crc,
         input-output v_sum1, input-output v_sum,
         output v_rate1, output v_rate,
         output v_sn,output v_bn,
         output m_sell, output m_buy).

        else run conv-obm(input v_crc, input v_crc1,
         input-output v_sum, input-output v_sum1,
         output v_rate, output v_rate1,
         output v_bn,output v_sn,
         output m_buy, output m_sell).

        displ v_sum  v_sum1 v_rate v_bn v-crc_val  v_rate1 v_sn v-crc_val1 v_knp vj-label with frame f_main.
    end.
    else do:

        run conv(input v_crc, input v_crc1, input true,
            input true, input-output v_sum, input-output v_sum1,
            output v_rate, output v_rate1, output v_bn,
            output v_sn, output m_buy, output m_sell).
        displ v_sum  v_sum1 v_rate v_bn v-crc_val  v_rate1 v_sn v-crc_val1 v_knp vj-label with frame f_main.
    end.


    if v-ek = 2 then do:
        if v_crc1 = 2 or v_crc1 = 3 then do:
            v_int = decim(entry(1,string(v_sum1),".")) / 10 .
            v_mod = ((v_int - decim(entry(1,string(v_int),"."))) * 10) + (v_sum1 - decim(entry(1,string(v_sum1),"."))).
            if v_mod <> 0 then do:
                message "Данную операцию проведите через счет 100100"  view-as alert-box error.
                undo, return.
            end.
        end.
        if v_crc1 = 4 then do:
            v_int = decim(entry(1,string(v_sum1),".")) / 100 .
            v_mod = ((v_int - decim(entry(1,string(v_int),"."))) * 100) + (v_sum1 - decim(entry(1,string(v_sum1),"."))).
            if v_mod <> 0 then do:
                message "Данную операцию проведите через счет 100100"  view-as alert-box error.
                undo, return.
            end.
        end.
        if v_crc = 2 or v_crc = 3 then do:
            v_int = decim(entry(1,string(v_sum),".")) / 10 .
            v_mod = ((v_int - decim(entry(1,string(v_int),"."))) * 10) + (v_sum - decim(entry(1,string(v_sum),"."))).
            if v_mod <> 0 then do:
                message "Данную операцию проведите через счет 100100"  view-as alert-box error.
                undo, return.
            end.
        end.
        if v_crc = 4 then do:
            v_int = decim(entry(1,string(v_sum),".")) / 100 .
            v_mod = ((v_int - decim(entry(1,string(v_int),"."))) * 100) + (v_sum - decim(entry(1,string(v_sum),"."))).
            if v_mod <> 0 then do:
                message "Данную операцию проведите через счет 100100"  view-as alert-box error.
                undo, return.
            end.
        end.

    end.
    update v-ja with frame f_main.
    if v-ja then do:
        do transaction:
            if v-ek = 2 then do:
                find first crc where crc.crc = v_crc no-lock.
                v-crc_val = crc.code.
                for each arp where arp.gl = 100500 and arp.crc = v_crc no-lock.
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

                find first crc where crc.crc = v_crc1 no-lock.
                v-crc_val1 = crc.code.
                for each arp where arp.gl = 100500 and arp.crc = v_crc1 no-lock.
                    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                    if avail sub-cod then do:
                        v-chEK1 = arp.arp.
                        /*v-sumarp = arp.dam[1] - arp.cam[1].*/
                    end.
                end.
                if v-chEK1 = '' then do:
                    message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_val1 + " !" view-as alert-box title " ОШИБКА ! ".
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
            joudoc.dramt = v_sum.
            joudoc.brate = v_rate.
            joudoc.bn = v_bn.
            if v-ek = 2 then joudoc.dracctype = "4". else joudoc.dracctype = "1".
            if v-ek = 2 then joudoc.dracc = v-chEK. else joudoc.dracc = "".
            joudoc.drcur = v_crc.
            joudoc.cramt = v_sum1.
            joudoc.srate = v_rate1.
            joudoc.sn = v_sn.
            if v-ek = 2 then joudoc.cracctype = "4". else joudoc.dracctype = "1".
            joudoc.crcur = v_crc1.
            if v-ek = 2 then joudoc.cracc = v-chEK1.  else joudoc.dracc = "".
            joudoc.remark[1] = v_oper.
            joudoc.chk = 0.
            joudoc.bas_amt = "D".
            if vrat > 0 then joudoc.sts = "SPC". else  joudoc.sts = "".
            run chgsts("JOU", v-joudoc, "new").

            find first crc where crc.crc = zcrc no-lock no-error.
            if v_crc = 1 then if v_sum / crc.rate[1] >= zamt then run control_sum_passp.
            if v_crc <> 1 then if v_sum1 / crc.rate[1] >= zamt then run control_sum_passp.

            if keyfunction (lastkey) = "end-error" then do:
                message "Данные не сохраняться, повторить ?" update yn.
                if not yn then do:
                    hide all.
                    view frame f_main.
                     undo,return.
                end.
                else undo.
            end.
            joudoc.passp = v-passp + "," + v-passpwho.
            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            if v-ek = 1 then joudop.type = "OBM". else joudop.type = "BOM".
            find current joudop no-lock no-error.
            displ v-joudoc with frame f_main.
            if vrat > 1 then do:
                MESSAGE "Необходим контроль в п.м. 2.4.1.1! 'Контроль документов'!"  view-as alert-box.
                for each sendod no-lock.
                    run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
                    "Добрый день!\n\n Необходимо отконтролировать обменную операцию по спец курсу \n Сумма: " + string(v_sum) +
                    "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
                    string(time,"HH:MM"), "1", "","" ).
                end.
                hide all.
                view frame f_main.
            end.

            find first cmp no-lock no-error.
            find first sysc where sysc.sysc = "CifScr" no-lock no-error.
            if avail sysc then do:
                do i = 1 to num-entries(sysc.chval, "|"):
                    if entry(i, sysc.chval, "|") = string(cmp.code) then do:
                        run sc.
                        sr-ans = yes.
                        run yn(""," Закрыть экран клиента?","","", output sr-ans).
                        if sr-ans then run to_screen( "default","").
                    end.
                end.
            end.
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
        if joudop.type <> "OBM" and joudop.type <> "BOM" then do:
            message substitute ("Документ не относится к типу Обмен валюты через ЭК ") view-as alert-box.
            return.
        end.
        if v-ek = 1 and joudop.type = "BOM" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            return.
        end.
        if v-ek = 2 and joudop.type = "OBM" then do:
            message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
            return.
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
    v_trx  = joudoc.jh.
    v_sum  = joudoc.dramt.
    v_crc  = joudoc.drcur.
    v_oper = joudoc.remark[1].
    v_sum1 = joudoc.cramt.
    v_crc1 = joudoc.crcur.
    v_rate = joudoc.brate.
    v_rate1 = joudoc.srate.
    v_sn   = joudoc.sn.
    v_bn   = joudoc.bn.
    v_oper = joudoc.remark[1].
    v-passp = entry(1,joudoc.passp,",").
    if NUM-ENTRIES(joudoc.passp,",") > 1 then v-passpwho = entry(2,joudoc.passp,",").
    if joudoc.sts = "SPC" then do:
        if v_crc = 1 then vrat = joudoc.srate. else vrat = joudoc.brate.
    end.
    if v_crc = 1 then v_knp = "223". else v_knp  = "213".
    v_code = "19".
    find first crc where crc.crc = v_crc no-lock.
    v-crc_val = crc.code.
    find first crc where crc.crc = v_crc1 no-lock.
    v-crc_val1 = crc.code.
    v-ja = yes.
    v_title = " ОБМЕННЫЕ ОПЕРАЦИИ ЧЕРЕЗ ЭК ".
    displ v-joudoc v_trx  v_crc v_sum v_rate v_bn v-crc_val v_crc1 v_sum1 v_rate1 v_sn v-crc_val1 v_code v_knp v_oper with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = "  ОБМЕННЫЕ ОПЕРАЦИИ ЧЕРЕЗ ЭК ".
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
    v_title = "  ОБМЕННЫЕ ОПЕРАЦИИ ЧЕРЕЗ ЭК ".
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
    if vrat > 1  then do:
        find cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc exclusive-lock no-error.
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
    end.
    /* проверка курса валюты ----------------------------------------------------------------*/
    if joudoc.sts <> "SPC" then do:
        if joudoc.drcur = 1 then do:
            find first crc where crc.crc = joudoc.crcur no-lock.
            if joudoc.srate <> crc.rate[3] then do:
                v_sum = 0.
                message "Изменился курс продажи валют, сумма будет пересчитана." view-as alert-box.
                run conv(input v_crc, input v_crc1, input true,
                    input true, input-output v_sum, input-output v_sum1,
                    output v_rate, output v_rate1, output v_bn,
                    output v_sn, output m_buy, output m_sell).
                displ v_sum  v_sum1 v_rate v_bn v-crc_val  v_rate1 v_sn v-crc_val1 v_knp vj-label with frame f_main.
                find first joudoc where joudoc.docnum = v-joudoc exclusive-lock.
                joudoc.srate = crc.rate[3].
                joudoc.dramt = v_sum.
                find first joudoc where joudoc.docnum = v-joudoc no-lock.
                return.
            end.
        end.
        else do:
            find first crc where crc.crc = joudoc.drcur no-lock.
            if joudoc.brate <> crc.rate[2] then do:
                v_sum1 = 0.
                message "Изменился курс покупки валют, сумма будет пересчитана." view-as alert-box.
                 run conv(input v_crc, input v_crc1, input true,
                    input true, input-output v_sum, input-output v_sum1,
                    output v_rate, output v_rate1, output v_bn,
                    output v_sn, output m_buy, output m_sell).
                 displ v_sum  v_sum1 v_rate v_bn v-crc_val  v_rate1 v_sn v-crc_val1 v_knp vj-label with frame f_main.
                find first joudoc where joudoc.docnum = v-joudoc exclusive-lock.
                joudoc.brate = crc.rate[2].
                joudoc.cramt = v_sum1.
                find first joudoc where joudoc.docnum = v-joudoc no-lock.
                return.
           end.
        end.
    end.
    /*---------------------------------------------------------------------------------------*/
    enable but with frame f_main.
    pause 0.
    v-knpval = v_knp.
    v_doc = v-joudoc.
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
    if not v-ja then undo, return.

        s-jh = 0.

    /*EK 100500------------------------------------------------------*/
    if v-ek = 2 then do:
        for each arp where arp.gl = 100500 and arp.crc = v_crc no-lock.
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

        for each arp where arp.gl = 100500 and arp.crc = v_crc1 no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then do:
                v-chEK1 = arp.arp.
                /*v-sumarp = arp.dam[1] - arp.cam[1].*/
            end.
        end.
        if v-chEK1 = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_val1 + " !" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.
        find first arp no-lock no-error.
        s-jh = 0.
            if v_crc = 1 /* and vrat > 1*/ then do:
                v-tmpl = "JOU0064".
                v-param = v-joudoc /* + vdel + string(v_sum)*/ + vdel + string(v_crc) + vdel + v-chEK + vdel + v_oper +
                        vdel + "1" + vdel + "1" + vdel + "9" + vdel + "9" + vdel + v_knp + vdel + string(v_sum1) + vdel +
                        string(v_crc1) + vdel + v-chEK1 .
                /*run trxgen-obm (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).*/
                run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).

            end.
            else do:
                v-tmpl = "JOU0063".
                v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_oper +
                        vdel + "1" + vdel + "1" + vdel + "9" + vdel + "9" + vdel + v_knp /* + vdel + string(v_sum1)*/ + vdel +
                        string(v_crc1) + vdel + v-chEK1 .
                run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).

            end.

            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        find first arp no-lock no-error.

        find first jh where jh.jh = s-jh exclusive-lock.
        jh.party = v-joudoc.
        if jh.sts < 5 then jh.sts = 5.
        for each jl of jh:
            if jl.sts < 5 then jl.sts = 5.
        end.
        find current jh no-lock.

        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error .
        joudoc.jh = s-jh.
        find current joudoc no-lock no-error.
        run chgsts(m_sub, v-joudoc, "trx").
    end.

        for each jl where jl.jh eq s-jh and jl.crc = 1 and jl.gl = 100500 no-lock:
            create jlsach .
            jlsach.jh = s-jh.
            if jl.dc = "d" and jl.dam > 0  then do:
                jlsach.amt = jl.dam .
                jlsach.ln = jl.ln .
                jlsach.lnln = 1.
                jlsach.sim = 030 .
           end.
           else do:
               jlsach.amt = jl.cam .
               jlsach.ln = jl.ln .
               jlsach.lnln = 1.
               jlsach.sim = 230 .
           end.
        end.
        hide all no-pause.
        view frame f_main.


    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.
    v_trx = s-jh.
    display v_trx with frame f_main.
    if v-noord = no then run vou_bankt(0, 1, joudoc.info).
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
        run vou_word (0, 1, joudoc.info).
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
        if v-noord = no then run vou_bankt(0, 1, joudoc.info).
        else run printord(s-jh,"").

    end. /* transaction */
end procedure.

procedure control_sum_passp:
    /* если сумма больше или равна 1000USD проверять паспорт и фамилию */

    define variable mcrc like crc.crc.
    define variable mamt like joudoc.dramt.
    define variable zcrc like crc.crc.
    define variable zamt like joudoc.dramt.

    define frame f_cus
       joudoc.info colon 14 label "ФИО, Инициалы" format "x(60)"  skip
       joudoc.perkod colon 14 label "ИИН" format "x(12)" validate((chk12_innbin(joudoc.perkod)),'Неправильно введён ИИН') skip
       "------------------Документ удостоверяющий личность------------------" at 2 skip
       v-passp colon 14 label "Номер"  format "x(40)" skip
       joudoc.passpdt colon 14 label "Дата выдачи" format "99/99/9999" skip
       v-passpwho  colon 14 label "Кем выдан" format "x(40)"
       with centered row 7 side-label title "ВВЕДИТЕ ДАННЫЕ" width 78.

    if joudoc.bas_amt eq "D" then do:
        mamt = joudoc.dramt.
        mcrc = joudoc.drcur.
    end.
    else if joudoc.bas_amt eq "C" then do:
        mamt = joudoc.cramt.
        mcrc = joudoc.crcur.
    end.

    find sysc where sysc.sysc = "obmcon" no-lock no-error.
    if avail sysc
       then
         do:
            zcrc = sysc.inval.
            zamt = sysc.deval.
         end.
       else
         do:
            message "не определена переменная sysc obmcon" skip "берутся значения по умолчанию 1000 USD" view-as alert-box.
            zcrc = 2.
            zamt = 1000.
         end.

     if mcrc <> zcrc
        then
          do:
             find crc where crc.crc = zcrc no-lock.
             zcrc = 1.
             zamt = zamt * crc.rate[1].

             find crc where crc.crc = mcrc no-lock.
             mcrc = 1.
             mamt = mamt * crc.rate[1].
          end.

         if mamt > zamt then
            do:
               repeat on error undo, retry:
                  update joudoc.info joudoc.perkod v-passp joudoc.passpdt v-passpwho with frame f_cus.
                 if (trim(joudoc.info) eq '') or (trim(joudoc.perkod) eq '') or (trim(v-passp) eq '') or (trim(v-passpwho) eq '') or joudoc.passpdt = ?
                    then retry.
                    else leave.
               end.
            end.

end procedure.

procedure check_rate:
    if vrat > 0 then run conv-obm(input v_crc, input v_crc1, input-output v_sum, input-output v_sum1, output v_rate, output v_rate1,
             output v_bn,output v_sn, output m_buy, output m_sell).

    else run conv(input v_crc, input v_crc1, input true,input true, input-output v_sum, input-output v_sum1,
            output v_rate, output v_rate1, output v_bn, output v_sn, output m_buy, output m_sell).


    if v_rate <> joudoc.brate then do:
        message substitute
            ("ИЗМЕНИЛСЯ  &1  КУРС ПОКУПКИ. СУММА БУДЕТ ПЕРЕСЧИТАНА.", v-crc_val).
    end.

    if v_rate1 <> joudoc.srate then do:
            message substitute
                ("ИЗМЕНИЛСЯ  &1  КУРС ПРОДАЖИ. СУММА БУДЕТ ПЕРЕСЧИТАНА.", v-crc_val1).
    end.
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
    v-Get_Nal = yes.

    /*vj-label  = " Выполнить прием/выдачу наличных?..................".
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
    else run printord(s-jh,"").*/
    /*if v-noord = yes then run printbks(string(s-jh) + "#", "TRX").*/
end procedure.

/*--------------------------------------------------------------*/
procedure sc:
    TSUMM1 = "TSUMM1=" + replace(trim(string(v_sum,'->>>>>>>>>>>>>>9.99')),'.',',') + " "  + getcrc(v_crc).
    TSUMM2 = "TSUMM2=" + replace(trim(string(v_sum1,'->>>>>>>>>>>>>>9.99')),'.',',') + " "  + getcrc(v_crc1).
    if v_crc = 1 then TRATE  = "TRATE=" + string(v_rate1).
    else TRATE  = "TRATE=" + string(v_rate).
    v-res111 = /*TCRC1 + "&" + TCRC2 + "&" +*/ TSUMM1 + "&" + TSUMM2 + "&" + TRATE.
    run to_screen("change", v-res111).
end procedure.
/*--------------------------------------------------------------*/

