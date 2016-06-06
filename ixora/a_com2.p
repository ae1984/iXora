/* a_com2.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Автоматизация удержания комиссии без открытия счета
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
        07/02/2012  Luiza - внесла изменения, если код тарифа 120 первая строка назначения платежа редактируется
        14/02/2012  Luiza - x0-cont вызывается если v-mod1 <> 0
        17.02.2012  Lyubov - списании комиссии без открытия счета символ кассплана 200 заменила на 100;
        07/03/2012 Luiza  - изменила передачу параметров при вызове printord
        19/03/2012 Luiza  - если тестовая база клиента finmon не вызываем
        20/03/2012 Luiza  - вызов функции isProductionServer выполняем в a_fimnon.i
        26/03/2012 Luiza  - перекомпиляция
        10/04/2012 Luiza  - объединила поля ФИО
        11/04/2012 Luiza  - для ФИО собираем данные из полей
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        03.05.2012 aigul - добавила списание комиссии за ЭЦП
        07/05/2012 Luiza - код тарифа 469
        14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
        15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
        04/06/2012 Luiza - исправила списание комиссии за ЭЦП для ЭК
        26/06/2012 Luiza - в поле joudoc.passp пробел заменила на ","
        03/07/2012 Luiza - добавила тарифы 152,155,169
        25/072012  Luiza - изменила проверку суммы при работе с ЕК
        26/07/2012 Luiza   - слово ЕК заменила ЭК
        10/09/2012 Luiza подключила {srvcheck.i}
        02/11/2012 Luiza - добавила тариф 058
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        05/04/2013 Luiza -  ТЗ № 1764 проверка признака блокирования валют при обменных операциях
        10/04/2013 Luiza - ТЗ 1515
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        06/08/2013 Luiza - ТЗ 1997 Расширение поля «Код тарифа»
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
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
def  var v_sum_lim as decimal no-undo. /* сумма*/

def  var v_sumk as decimal no-undo. /* сумма комиссии*/
def var v_arp as char format "x(20)" no-undo. /* */
def  var v_dt as int  no-undo format "999999". /* Дт 100100*/
def  var v_kt as int no-undo format "999999". /* КТ */
def new shared var s-lon like lon.lon.
def new shared var v-num as integer no-undo.
def var v_crc as int  no-undo .  /* Валюта*/
def var v-chet as char format "x(20)". /* счет клиента*/
def var v-cif as char format "x(6)". /* cif клиент*/
def var v_pakalp as char format "x(30)". /*  комиссия*/
def var v-cif1 as char format "x(6)". /*  клиент*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v_tar as char no-undo format "x(5)".  /* tarif*/
def var v-ja as logi no-undo format "Да/Нет" init yes.
def var v_oper as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_oper1 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_filial as char format "x(30)".   /* название филиала*/
def var vparr as char no-undo.
def shared var v-joudoc as char no-undo format "x(10)".
def shared var v-Get_Nal as logic.
def var v-cur as logic no-undo.

define new shared variable s-jh like jh.jh.
define variable v-cash   as logical no-undo.
define variable v-acc   as logical no-undo.
define variable v-sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
define new shared variable vrat  as decimal decimals 4.


/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-crc_valk as char no-undo format "xxx".
def var v-chEK as char format "x(20)". /* счет ЭК*/
def var v-chEK1 as char format "x(20)". /* счет ЭК*/
def var v-chEKk as char format "x(20)". /* счет ЭК for comis*/
/*------------------------------------*/

/* for finmon */
def var v-monamt as deci no-undo.
def var v-monamt2 as deci no-undo.
def buffer b-jl for jl.
def buffer bb-jl for jl.
def var v-oper as char no-undo.
def var v-cltype as char no-undo.
def var v_rez as char no-undo.
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
def var v-rnn as char no-undo.
def var v-clname2 as char no-undo.
def var v-clfam2 as char no-undo.
def var v-clmname2 as char no-undo.
def var v-addr as char no-undo.
def var v-country22 as char.
def var v-knpval as char no-undo.
def  var v-benName as char no-undo.
def  var v_doc as char no-undo format "x(10)".
def  var v-bplace as char no-undo.
def  var v-bdt1 as date no-undo.
def  var v_doctype as char no-undo.
def  var v_addr as char no-undo format "x(75)".
def  var v_tel as char no-undo format "x(27)".
def  var v_countr as char no-undo format "x(2)".
def  var v_countr1 as char no-undo format "x(2)".
def  var v_lname1 as char no-undo format "x(20)".
def  var v_name1 as char no-undo format "x(20)".
def  var v_mname1 as char no-undo format "x(20)".
def  var v_public as char no-undo. /* признак ИПДЛ */

/*------------------------------------------*/

def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var v-name as char.
def var v-templ as char.
define var v_codfrn as char init " ".
def var v_codfr as char format "x(2)" init "11". /*код операций  табл codfr для doch.codfr */
def var v-ec as char format "x(1)" no-undo.
def  var v-label as char no-undo.
def  var v_rnn as char no-undo format "x(12)".
def  var v_iin as char no-undo format "x(12)".
def  var v_lname as char no-undo format "x(20)".
def  var v_name as char no-undo format "x(20)".
def  var v_mname as char no-undo format "x(20)".
def  var v_doc_num as char no-undo.
def  var v_docdt as date no-undo.
def  var v_docwho as char no-undo.
def var v-bin as logi init no.
def  var v-cifmin as char no-undo.
def var v_trx as int no-undo.
def  var vj-label as char no-undo.
def var v-int as decim.
def var v-mod as decim.
def var v-modc as decim.
def var v-int1 as decim.
def var v-mod1 as decim.
def var v-modc1 as decim.
def var v_sum1 as decim.
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


{findstr.i}
{kfm.i "new"}



def buffer b-sysc for sysc.
/*проверка банка*/
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).

find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.

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

{keyord.i}

{srvcheck.i}

/*listtar = "193, 180, 230,212, 258, 227, 233, 236, 238, 450, 429, 243, 244, 245, 029, 193, 181, 208, 209, 217, 213, 239, 159, 459,
            125, 419, 262, 107, 108, 161, 253, 213, 239, 304, 159, 420, 424, 028, 119, 809, 810, 809, 940, 980, 117, 924, 457, 442, 120, 146,
            040, 199, 402, 422, 431, 710, 711, 755, 754, 038, 740, 701,102, 104, 154, 109, 163, 214, 215, 019, 017, 202, 222, 111,
            112, 147, 403, 436, 401, 409, 439, 151, 102, 192, 153, 024, 204, 205, 218, 123, 132, 158, 456, 430, 804, 802, 803, 137,
            177, 039, 120, 440, 146, 040, 940, 980, 983, 117, 976, 901, 902, 903, 905, 906, 907, 908, 909, 910, 981, 982, 987, 993,
            994, 988, 993, 994, 989, 984, 990, 985, 986, 126, 199, 970, 995, 996, 971, 997, 998, 999, 910, 911, 972, 960, 961, 962,
            963, 964, 965, 966, 967, 968, 969, 952, 953, 954, 955, 956, 957, 958, 959, 941, 942, 943, 944, 945, 946, 947, 468, 057,
            469,152,155,169,058,105,106".

define temp-table temp-tarif2 like tarif2.
for each tarif2 where tarif2.stat  = "r"  no-lock:
    if index(listtar, tarif2.str5) > 0 then do:
        create temp-tarif2.
        buffer-copy tarif2 to temp-tarif2.
    end.
end.*/

{chk12_innbin.i}
define button but label " " no-focus .
   form
       v-joudoc label " Документ        " format "x(9)"  v_trx label "           ТРН " format "zzzzzzzzz"     but skip
        /*v_sum   LABEL " Сумма платежа   " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip*/
        v_crc   label " Валюта комиссии " help "Введите код валюты, F2-помощь" format ">9" validate(can-find(first crc where crc.crc = v_crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_tar   LABEL " Код тарифа      " format "x(5)"validate(can-find(first tarif2 where tarif2.str5 = v_tar and tarif2.stat  = "r" no-lock),"Неверный код тарифа комиссии")  help " Введите код тарифа комиссии"
        v_kt    label "ГК комиссии " colon 50  format "999999" skip
        v_sumk  LABEL " Сумма комиссии  " validate(v_sumk > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        v_code  label " КОД             " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label " КБе             " skip
        v_knp   label " КНП             " skip
        v_oper  label " Назначение      "  format "x(47)" skip
        v_oper1 no-label colon 1 format "x(55)" skip
        v_oper2 no-label colon 1 format "x(55)" skip(1)
        v-label no-label v_rnn  no-label colon 16 format "x(12)" validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip
        v_lname label " ФИО/Наименование" format "X(60)"  validate(trim(v_lname) <> "", "Заполните ФИО/получателя") skip
        /*v_name  label " Имя             " format "X(20)"  validate(trim(v_name) <> "", "Заполните имя") skip
        v_mname label " Отчество        " format "X(20)" skip*/
        v_doc_num  label " Номер документа " help "Введите номер докумета удостов. личность" format "x(40)" /*validate(trim(v_doc_num) <> "", "Заполните номер документа")*/ skip
        v_docdt  label  " Дата выдачи     " format "99/99/9999" help " Для ввода пустого значения наберите знак вопроса '?' " /*validate(trim(v_docdt) <> "", "Заполните дату выдачи документа")*/ skip
        v_docwho  label " Выдан           " help " Кем выдан документ удостов. личность"  format "x(20)" /*validate(trim(v_docwho) <> "", "Заполните кем выдан документ")*/ skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 90 FRAME f_main.



DEFINE QUERY q-tar FOR tarif2.

DEFINE BROWSE b-tar QUERY q-tar
       DISPLAY tarif2.str5 label "Код тарифа " format "x(5)" tarif2.pakalp label "Наименование   " format "x(55)"
       WITH  15 DOWN.
DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 35 width 100 NO-BOX.

DEFINE FRAME f-doch
     v-joudoc  v-rdt  v-name format "x(20)" v-templ format "x(7)"
     with overlay row 6  col 1  no-label
     title "НОМ-ДОКУМ. ДАТА-ОПЕР. ИСПОЛНИТЕЛЬ       Шаблон ".

/*обработка F4*/

on end-error of b-tar in frame f-tar do:
    hide frame f-tar.
   undo, return.
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

on help of v_crc in frame f_main do:
    run help-crc1.
end.

on "END-ERROR" of frame f-tar do:
  hide frame f-tar no-pause.
end.

on choose of but in frame  f_main do:
end.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("CM2"). else run a_help-joudoc1 ("MC2").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = " УДЕРЖАНИЕ КОМИССИИ БЕЗ ОТКРЫТИЯ СЧЕТА ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    do transaction:
        v_oper = "Комиссия за ".
        displ v-joudoc format "x(10)" with frame f_main.
        v_code = "".
        v_kbe = "14".
        v_knp = "840".
        v_sum = 0.
        v_sumk = 0.
        v-ja = yes.
        v_crc = 0.
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */

else do:   /* редактирование документа   */
    v_title = " УДЕРЖАНИЕ КОМИССИИ БЕЗ ОТКРЫТИЯ СЧЕТА ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                    if joudop.type <> "CM2" and joudop.type <> "MC2" then do:
                        message substitute ("Документ не относится к типу удержание комиссии") view-as alert-box.
                        return.
                    end.
                    if v-ek = 1 and joudop.type = "MC2" then do:
                        message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                        return.
                    end.
                    if v-ek = 2 and joudop.type = "CM2" then do:
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
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    if v-ek = 1 then v_dt = 100100. else v_dt = 100500.
    if v-bin  then v-label = " ИИН/БИН          :". else v-label = " РНН              :".
    displ v-joudoc  v_kbe v_knp v-label no-label with  frame f_main.
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
    update v_tar with frame f_main.
    find first tarif2 where tarif2.str5 = trim(v_tar) and tarif2.stat  = "r" no-lock no-error.
    if avail tarif2 then do:
        v_oper = "Комиссия за " + tarif2.pakalp.
        v_kt = tarif2.kont.
     /* вычисление суммы комиссии-----------------------------------*/
    v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
    run perev ("",input v_tar, input v_sum, input v_crc, input v_crc,"", output v-amt, output tproc, output pakal).
    v_sumk = v-amt.
    /*------------------------------------------------------------*/
        if length(trim(v_oper)) > 45 then do:
            v_oper1  = substring(trim(v_oper),46,55).
            v_oper = substring(trim(v_oper),1,45).
        end.
        displ  v_sumk v_kt v_oper v_oper1 with frame f_main.
    end.

    update v_sumk with frame f_main.
    if v-ek = 2 then do:
        find first codfr where codfr.codfr = 'limek' and codfr.code = string(v_crc) no-lock no-error.
        if not avail codfr then do:
            message "В справ-ке <codfr> отсутствует запись суммы лимита для данной валюты по ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
            undo.
        end.
        else do:
            if v_sumk > decim(trim(codfr.name[1])) then do:
                find first crc where crc.crc = v_crc no-lock no-error.
                message "Ошибка, сумма превышает лимит суммы при работе с ЭК "  + trim(codfr.name[1]) + " " + crc.code  view-as alert-box error.
                undo.
            end.
        end.
    end.
    if v_tar = "120" then update v_code v_oper v_oper1 v_oper2 v_rnn with frame f_main.
    else update v_code v_oper1 v_oper2 v_rnn with frame f_main.
    v_lname = "".
    v_doc_num = "".
    v_docdt = ?.
    v_docwho = "".
    if trim(v_rnn) <> "-" then do:
        if v-bin then find last cifmin where cifmin.iin = v_rnn no-lock no-error.
        else find last cifmin where cifmin.rnn = v_rnn no-lock no-error.
        if available cifmin then do:
            v-cifmin = cifmin.cifmin.
            v_lname = trim(cifmin.fam) + " " + trim(cifmin.name) + " " + trim(cifmin.mname).
            /*v_name = cifmin.name.
            v_mname = cifmin.mname.*/
            v_doc_num = cifmin.docnum.
            v_docdt = cifmin.docdt.
            v_docwho = cifmin.docwho.
            update v_lname /*v_name v_mname*/ v_doc_num v_docdt v_docwho with frame f_main.

            /*find current cifmin exclusive-lock.
            cifmin.cifmin = v-cifmin.
            cifmin.fam = v_lname.
            cifmin.name = v_name.
            cifmin.mname = v_mname.
            cifmin.docnum = v_doc_num.
            cifmin.docdt = v_docdt.
            cifmin.docwho = v_docwho.
            find current cifmin no-lock.*/

            display vj-label no-label format "x(35)"  with frame f_main.
            update v-ja with frame f_main.
        end.
        else do:
            if v-bin then find first rnn where rnn.bin = v_rnn no-lock no-error.
            else find first rnn where rnn.trn = v_rnn no-lock no-error.
            if available rnn then do:
                v_lname = rnn.lname + " " + trim(rnn.fname) + " " + trim(rnn.mname).
                /*v_name = rnn.fname.
                v_mname = rnn.mname.*/
                /*v_doc_num = cifmin.docnum.*/
                v_docdt = rnn.datepas.
                v_docwho = rnn.orgpas.
                update v_lname /*v_name v_mname*/ v_doc_num v_docdt v_docwho with frame f_main.

                /*find current rnn exclusive-lock.
                rnn.lname = v_lname.
                rnn.fname = v_name.
                rnn.mname = v_mname.

                rnn.datepas = v_docdt.
                rnn.orgpas = v_docwho.
                find current rnn no-lock.*/

                display vj-label no-label format "x(35)"  with frame f_main.
          end.
            else do:
                displ  v_rnn vj-label no-label format "x(35)" with frame f_main.
                update v_lname /*v_name v_mname*/ v_doc_num v_docdt v_docwho v-ja with frame f_main.
            end.
        end.
    end.
    else do:
        displ  v_rnn  vj-label format "x(35)" no-label with frame f_main.
        pause 0.
        update v_lname /*v_name v_mname*/ v_doc_num v_docdt v_docwho v-ja with frame f_main.
    end.
    if v-ja then do:
        do transaction:
            if v-ek = 2 then do:
                find first crc where crc.crc = v_crc no-lock.
                v-crc_val = crc.code.
                for each arp where arp.gl = 100500 and arp.crc = v_crc no-lock.
                    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                    if avail sub-cod then do:
                        v-chEKk = arp.arp.
                        /*v-sumarp = arp.dam[1] - arp.cam[1].*/
                    end.
                end.
                if v-chEKk = '' then do:
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
            /*joudoc.dramt = v_sum.*/
            if v-ek = 2 then joudoc.dracctype = "4". else joudoc.dracctype = "1".
            if v-ek = 2 then joudoc.dracc = v-chEK. else joudoc.dracc = "".
            joudoc.drcur = v_crc.
            /*joudoc.cramt = v_sum.*/
            joudoc.cracctype = "5".
            joudoc.cracc = "".
            joudoc.crcur = v_crc.
            joudoc.comamt = v_sumk.
            if v-ek = 2 then joudoc.comacctype = "4". else joudoc.comacctype = "1".
            if v-ek = 2 then joudoc.comacc = v-chEKk. else joudoc.comacc = "".
            joudoc.comacc = "".
            joudoc.comcur = v_crc.
            joudoc.comcode = v_tar.
            joudoc.remark[1] = v_oper.
            joudoc.remark[2] = v_oper1 + "^" + v_oper2.
            joudoc.chk = 0.
            joudoc.info = v_lname /* + " " + v_name + " " + v_mname */.
            joudoc.passp = v_doc_num + "," + v_docwho.
            joudoc.passpdt = v_docdt .
            joudoc.perkod = v_rnn.
            joudoc.rescha[2] = v_code.
            run chgsts("JOU", v-joudoc, "new").
            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            if v-ek = 1 then joudop.type = "CM2". else joudop.type = "MC2".
            find current joudop no-lock no-error.
            displ v-joudoc with frame f_main.
            /* create sub-cod.
            sub-cod.acc = v-joudoc.
            sub-cod.sub = "rmz".
            sub-cod.d-cod = "iso3166".
            sub-cod.ccode = v_countr1.*/
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
        if joudop.type <> "CM2" and joudop.type <> "MC2" then do:
            message substitute ("Документ не относится к типу удержание комиссии") view-as alert-box.
            return.
        end.
        if v-ek = 1 and joudop.type = "MC2" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            return.
        end.
        if v-ek = 2 and joudop.type = "CM2" then do:
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
    v_trx = joudoc.jh.
    /*v_sum = joudoc.dramt.*/
    v_crc = joudoc.drcur.
    v_sumk = joudoc.comamt.
    v_oper = joudoc.remark[1].
    v_oper1 = entry(1,joudoc.remark[2],"^").
    v_oper2 = entry(2,joudoc.remark[2],"^").
    v_lname = joudoc.info.
    /*v_lname = entry(1,joudoc.info," ").
    v_name  = entry(2,joudoc.info," ").
    v_mname = entry(3,joudoc.info," ").*/
    v_doc_num = entry(1,joudoc.passp,",").
    v_docwho = entry(2,joudoc.passp,",").
    v_docdt = joudoc.passpdt.
    v_rnn = joudoc.perkod.
    v_code = joudoc.rescha[2].
    v_kbe = "14".
    v_knp = "840".
    v_tar = joudoc.comcode.
    v-ja = yes.
    v_title = " УДЕРЖАНИЕ КОМИССИИ БЕЗ ОТКРЫТИЯ СЧЕТА ".
    if v-ek = 1 then v_dt = 100100. else v_dt = 100500.
    if v-bin  then v-label = " ИИН              :". else v-label = " РНН              :".
    find first tarif2 where tarif2.str5 = trim(v_tar) and tarif2.stat  = "r" no-lock no-error.
    if avail tarif2 then do:
        /*v_oper = "Комиссия за " + tarif2.pakalp.*/
        v_kt = tarif2.kont.
    end.
    displ v-joudoc v_trx v_kbe v_knp v_crc /*v_sum*/  v_tar v_kt v_sumk v_code v_oper v_oper1 v_oper2 v-label v_rnn no-label
            v_lname /*v_name v_mname*/ v_doc_num v_docdt v_docwho with  frame f_main.
end procedure.


Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = " УДЕРЖАНИЕ КОМИССИИ БЕЗ ОТКРЫТИЯ СЧЕТА ".
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
    v_title = " УДЕРЖАНИЕ КОМИССИИ БЕЗ ОТКРЫТИЯ СЧЕТА ".
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
    end.*/

    v_doc = v-joudoc.
    v-knpval = v_knp.
    v_lname1 = v_lname.
    v_name1 = v_name.
    v_mname1 = v_mname.
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
    displ vj-label format "x(35)" no-label with frame f_main.
    update v-ja no-label with frame f_main.
    if not v-ja  then do:
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
        sub-cod.ccode = "01" /* Платежное поручение */.
        sub-cod.rdt = g-today.
    end.

    v_oper = v_oper + " " + v_oper1 + " " + v_oper2.
    /*EK 100500------------------------------------------------------*/
    if v-ek = 2 then do:
        for each arp where arp.gl = 100500 and arp.crc = 1 no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then do:
                v-chEK1 = arp.arp.
            end.
        end.
        if v-chEK1 = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте KZT!" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.

        find first crc where crc.crc = v_crc no-lock.
        v-crc_val = crc.code.
        for each arp where arp.gl = 100500 and arp.crc = v_crc no-lock.
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

        s-jh = 0.
        /* для комиссии--------------------------------------------*/
        if v_sumk <> 0 then do:
            if v_crc = 1 then do:  /* комиссия в тенге  */
                    if v_kt = 460828 then do:
                        find first arp where arp.gl = 287082 no-lock no-error.
                        if avail arp then v_arp = arp.arp.
                        v-tmpl = "jou0055".
                        v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_arp + vdel + v_oper
                        + vdel + substring(v_code,1,1) + vdel + "1" + vdel + substring(v_code,2,1) + vdel + "4" + vdel + "840".
                        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    end.
                    else do:
                        v-tmpl = "jou0053".
                        v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crc) + vdel + v-chEK + vdel + string(v_kt) + vdel + v_oper
                        + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    end.
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                /*end.*/
            end.
            else do:
                /*---------------выделяем дробную часть комиссии ----------------------------------------------*/
                if v_crc <> 1 then do:
                    if v_crc = 4 then do:
                        v_sum1 = decim(entry(1,string(v_sumk),".")) / 100 .
                        v-mod1 = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 100) + (v_sumk - decim(entry(1,string(v_sumk),"."))).
                    end.
                    else do:
                        v_sum1 = decim(entry(1,string(v_sumk),".")) / 10 .
                        v-mod1 = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 10) + (v_sumk - decim(entry(1,string(v_sumk),"."))).
                    end.
                    v-int  = v_sumk - v-mod1.
                    v-modc = round(crc-conv(decimal(v-mod1), v_crc, 1),2).
                    /*v-int = decim(entry(1,string(v_sumk),".")).
                    v-mod1 = v_sumk - decim(entry(1,string(v_sumk),".")).
                    v-modc = round(crc-conv(decimal(v-mod1), v_crc, 1),2).*/

                    /* проверка блокировки курса --------------------------------*/
                    if v-mod1 <> 0 then do:
                        v-cur = no.
                        run a_cur(input v_crc, output v-cur).
                        if v-cur then undo, return.
                    end.
                end.
                /*------------------------------------------------------------------------------------------*/
                if v-mod1 = 0 then do:
                    v-tmpl = "jou0053".
                    v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crc) + vdel + v-chEK + vdel + string(v_kt) + vdel + v_oper + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                end.
                else do:
                    /* обрабатываем целую часть */
                    v-tmpl = "jou0053".
                    v-param = v-joudoc + vdel + string(v-int) + vdel + string(v_crc) + vdel + v-chEK + vdel + string(v_kt) +
                    vdel + v_oper + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                    /* обрабатываем конвертируем дробную часть */
                    v-tmpl = "JOU0063".
                    v-param = v-joudoc + vdel + string(v-modc) + vdel + "1" + vdel + v-chEK1 + vdel + "обмен валюты" +
                            vdel + "1" + vdel + "1" + vdel + "9" + vdel + "9" + vdel + "223" /*+ vdel + string(v-mod1)*/ + vdel +
                            string(v_crc) + vdel + v-chEK .
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                    v-tmpl = "jou0053".
                    v-param = v-joudoc + vdel + string(v-mod1) + vdel + string(v_crc) + vdel + v-chEK + vdel + string(v_kt) +
                    vdel + v_oper + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                end.
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

        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error.
        joudoc.jh = s-jh.
        if v_crc = 1 then joudoc.srate = 1.
        else do:
            find first crc where  crc.crc = v_crc no-lock no-error.
            joudoc.srate = crc.rate[3].
            joudoc.sn = 1.
        end.
        joudoc.brate = 1.
        find current joudoc no-lock no-error.
        run chgsts(m_sub, v-joudoc, "trx").

        /*enable but with frame f_main.
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
        run chgsts(m_sub, v-joudoc, "rdy").*/
    end. /* end v-ek = 2  */

    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
        if v_kt = 460828 then do:
            find first arp where arp.gl = 287082 no-lock no-error.
            if avail arp then v-chEK = arp.arp.
            v_kt = 287082.
            v-tmpl = "jou0027".
            v-param = string(v_sumk) + vdel + string(v_crc) +
            vdel + v-chEK + vdel + v_oper + vdel + substring(v_code,1,1) + vdel + "1" + vdel + substring(v_code,2,1) + vdel + "4" + vdel + "840" .
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        end.
        else do:
            v-tmpl = "jou0025".
            v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crc) + vdel + string(v_kt) + vdel + v_oper + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        end.
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        run chgsts(m_sub, v-joudoc, "trx").
        run chgsts("jou", v-joudoc, "cas").
        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error.
        joudoc.jh = s-jh.
        if v_crc = 1 then joudoc.srate = 1.
        else do:
            find first crc where  crc.crc = v_crc no-lock no-error.
            joudoc.srate = crc.rate[3].
            joudoc.sn = 1.
        end.
        joudoc.brate = 1.
        find current joudoc no-lock no-error.
        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
    end. /* v-ek = 1 */

        pause 1 no-message.
        /* копируем заполненные данные по ФМ в реальные таблицы*/
        if v-kfm then do:
            run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
            hide all.
            view frame f_main.
        end.
        /**/
        MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) /* + " ~nНеобходим контроль документа в п.м. 2.4.1.1 "*/ view-as alert-box.
        v_trx = s-jh.
        display v_trx with frame f_main.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if v_crc = 1 or v-mod1 <> 0  then do:
            hide all no-pause.
            /*run x0-cont1.
            hide all no-pause.*/

            for each jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = 100500 or jl.gl = 100100) no-lock:
                create jlsach .
                jlsach.jh = s-jh.
                if jl.dc = "c" then jlsach.amt = jl.cam .
                               else jlsach.amt = jl.dam .
                jlsach.ln = jl.ln .
                jlsach.lnln = 1.
                jlsach.sim = 100 .
            release jlsach.
            end.
            view frame f_main.
        end.

    /*run vou_bankt(1, 1, joudoc.info).*/
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
    /*run vou_bankt(1, 1, joudoc.info).*/
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").
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
    v-Get_Nal = yes.

    /*vj-label  = " Выполнить прием наличных?..................".
    s-jh = joudoc.jh.
    enable but with frame f_main.
    pause 0.
    def var v-errmsg as char init "".
    def var v-rez as logic init false.
    run csstampf(s-jh, v-nomer, output v-errmsg, output v-rez ).
    view frame f_main.
    disable but with frame f_main.
    if  v-errmsg <> "" or not v-rez then do:
        message  v-errmsg view-as alert-box error.
        undo, return.
    end.
    run chgsts(m_sub, v-joudoc, "rdy").
    message "Проводка отштампована " view-as alert-box.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").*/
end procedure.

procedure create_100100:
    run a_create100100(v-joudoc).
end.

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

    run a_stamp(joudoc.jh).
    pause 0.
    hide all.
    view frame f_main.
end.
