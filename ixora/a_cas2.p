/* a_cas2.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
         Расходная операция со счета клиента наличными
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
        10/02/2012 Luiza - запрещаем комиссию в долг
        14/02/2012 Luiza  - изменила выделение дробной части для комиссии
        17.02.2012  Lyubov - При пополнении счета ЮЛ (счет ГК 221510, 221710, 221910) зашила символ 300;
                             При пополнении счета ФЛ (счет ГК 220620, 220720) зашила символ 220, по счету ГК 220530 - 270;
                             Добавила выбор кассплана через F2 (счет ГК 220310, ГК 220420, ГК 220520)
        23.02.2012 aigul -  Добавила букву И в Вид опл.комиссии
        06/03/2012 Luiza - добавила код тарифа 430 для юр лиц
        07/03/2012 Luiza - заменила шаблон jou0016 на jou0062
        12.03.2012 Lyubov - для ГК 220420 убрала поиск по F2, зашила символ 220
        11.03.2012 damir - добавил печать оперционного ордера, printvouord.p.
        19/03/2012 Luiza  - если тестовая база клиента finmon не вызываем
        20/03/2012 Luiza  - вызов функции isProductionServer выполняем в a_fimnon.i
        09/04/2012 Luiza  - тариф зависит от валюты счета и для счетов 220620 220720 добавила контроль
        10/04/2012 Luiza  - изменила рассылку сообщений
        11/04/2012 Luiza  - для счетов 220520 220530 добавила контроль для суммы больше 1000$
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        24/04/2012 Luiza - отображаем полное название клиента
        07/05/2012 Luiza  - добавила процедуру defclparam
        08/05/2012 Luiza  - перед транзакцией ищем ГЛ счета
        11/05/2012 Luiza  - view формы при рассылке вынесла за цикл
        14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
        15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
        25/06/2012 dmitriy - замена: find first gram --> find last gram
        26/06/2012 Luiza - изменила заполнение поля passp
        09/07/2012 dmitriy - в поиск чековых книжек добавил поиск по cif-коду
        10/07/2012 dmitriy - вывод на экран клиента
        12/07/2012 dmitriy - вывод на экран клиента только для филиалов, прописанных в sysc = "CifScr"
        25/072012  Luiza   - изменила проверку суммы при работе с ЕК
        26/07/2012 Luiza   - слово ЕК заменила ЭК
        30/07/2012 Luiza - Изменила  поиск наименования  комиссии по коду комиссии при открытии документа
        10/09/2012 Luiza подключила {srvcheck.i}
        25/09/2012 dmitriy - ТЗ 1456 выбор листов ЧК через F2, проверка на уже использованные листы
                           - при удалении транзакции возврат листа ЧК в список неиспользованных
                           - изменил алгоритм для выбора филиалов, прописанных в sysc = "CifScr"
        27/09/2012 dmitriy - измененил сообщение по удалению/восстановлению чеков
        03/10/2012 dmitriy - сообщение "Данный чек уже использован" только для чеков, зарегистрированных после 25/09/2012
        11/10/2012 Luiza   - при контроле для суммы больше 1000$ убрала условие v-ek = 1
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        23.11.2012 Lyubov - ТЗ 1584, символ касплана вводится до тех пор, пока общая сумма не повпадет с контрольной
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        23/01/2013 Luiza  - ТЗ №1649 добавила счет 279940
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        26/03/2013 Luiza - ТЗ № 1767 добавила код тарифа 470
        05/04/2013 Luiza - ТЗ № 1764 проверка признака блокирования валют при обменных операциях
        10/04/2013 Luiza - ТЗ № 1515 Оповещение менеджера о клиенте
        15/05/2013 Luiza - ТЗ № 1826 Добавление евро для 100500
        20/05/2013 Luiza - ТЗ 1309
        10/06/2013 Luiza - ТЗ 1727 проверка на 30 млн тенге при расходе со счета клиента наличными
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        06/08/2013 Luiza - ТЗ 1997 Расширение поля «Код тарифа»
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
        01/11/2013 Luiza - ТЗ 1932 добавление кода тарифа 949
        06/11/2013 Luiza - ТЗ 2188 счет 220420
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
def  var v_sum_lim as decimal no-undo. /* сумма*/

def  var v_sumk as decimal no-undo. /* сумма комиссии*/
def var v_arp as char format "x(20)" no-undo. /* счет карточка ARP*/
def  var v_dt as int  no-undo format "999999". /* Дт 100100*/
def  var v_kt as int no-undo format "999999". /* КТ 287051*/
def new shared var s-lon like lon.lon.
/*def new shared var v-num as integer no-undo.*/
def var v-crc as int  no-undo .  /* Валюта*/
def var vv-crc as char  no-undo .  /* Валюта*/
def var v-crck as int  no-undo .  /* Валюта comiss*/
def var v-chet as char format "x(20)". /* счет клиента*/
def var v-chetk as char format "x(20)". /* счет клиента for comiss*/
def var v-cif as char format "x(6)". /* cif клиент*/
def  var v_lname as char no-undo format "x(20)".
def  var v_mname as char no-undo format "x(20)".
def var v_name as char format "x(20)". /*  клиент*/
def var v_namek as char format "x(30)". /*  клиент*/
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
/*def var v-rnn as char no-undo.*/
def shared var v-joudoc as char no-undo format "x(10)".
def shared var v-Get_Nal as logic.

def new shared var v_doc as char format "x(10)" no-undo.
def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var v-name as char.
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
def var v-chk as int init 0.
def var v-ser as char init "а1".
def var v-nal as decim.
def var v_sim as int.
def var v_des as char.
define new shared variable vrat  as decimal decimals 4.
def var v-gl as int no-undo.
def var v-cur as logic no-undo.

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
def var v_rnn as char.
def var v_rnnp as char.
def var v-label as char format "x(22)".
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
def var v-knpval as char no-undo.

/*---------------------------*/
define new shared variable s-aaa like aaa.aaa.
def var v-badd1  as char.
def var v-badd2  as char.
def var v-badd3  as char.
def var v-beg as date.
def var id       as inte.
def var v-plat   as char init 'u'.
def var v-fio    like cif-heir.fio.
def var v-idcard like cif-heir.idcard.
def var v-jssh   like cif-heir.jss.
def var v-begz as date.
def var v-begz1 as date.

def temp-table wupl
    field id    as   inte
    field upl   as   inte
    field badd1 as   char
    field badd2 as   char
    field badd3 as   char
    field finday like uplcif.finday
    field coregdt as date
index main is primary unique upl.

def temp-table wheir
    field id     as   inte
    field fio    as   char
    field idcard as   char
    field jss    as   char
    field ratio  as   char
    field will-date as date
index main fio.
/*----------------------------------*/


/* для комиссии*/
def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.

/* экран клиента */
DEF VAR TCIFNAME AS CHAR.
DEF VAR TAAA AS CHAR.
DEF VAR TSUMM AS CHAR.
DEF VAR TCOMSUMM AS CHAR.
DEF VAR TREM AS CHAR.
def var v-sel as int.
def var i as int.
def var del-page as logi  format "Да/Нет".

define temp-table wrk-chk
    field chk as char
    index idx is primary chk ascending.

def var s1 as char.
def var s2 as char.
def var str-pages as char.

{yes-no.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */
{comm-txb.i}
{get-dep.i}
{findstr.i}
{kfm.i "new"}
{checkdebt.i &file = "bank"}
{keyord.i}

{srvcheck.i}

/*проверка банка*/
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).

def var v-chk1 as char no-undo.
find first bookcod where bookcod.bookcod = 'a_cas2'
                     and bookcod.code    = 'chk'
                     no-lock no-error.
if not avail bookcod or trim(bookcod.name) = "" then do:
    message "В справочнике <bookcod> код <chk> отсутствует список  для определения допустимых счетов ГК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
v-chk1 = bookcod.name.

def var v-glchk1 as char no-undo.
find first bookcod where bookcod.bookcod = 'a_cas2'
                     and bookcod.code    = 'glchk'
                     no-lock no-error.
if not avail bookcod or trim(bookcod.name) = "" then do:
    message "В справочнике <bookcod> код <glchk> отсутствует список счетов ГК для контроля свыше 1000$!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
v-glchk1 = bookcod.name.

def var v-bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v-label =  " ИИН/БИН клиента     :". else v-label =  " РНН  клиента        :".
if v-bin  then v-labelp = " ИИН/БИН получателя  :". else v-labelp = " РНН  получателя     :".

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
          return sum * bcrc1.rate[3] / bcrc2.rate[3].
       end.
       else return sum.
    end.

define button but label " "  NO-FOCUS.
{chk12_innbin.i}
   form
        v-joudoc label " Документ            " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"           but skip
        v-chet   label " Счет клиента        "  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-chet and lookup(string(aaa.gl),v-chk1) > 0 no-lock),
                "Неверный счет ГК счета клиента!") skip
        v_namek   label " Клиент              "  format "x(60)" skip
        v-label no-label v_rnn  colon 22 no-label format "x(12)" validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip
        v-chk    label " Номер чека          "  format "9999999" validate(can-find(first checks where checks.nono <= v-chk and checks.lidzno >= v-chk no-lock),"Неверный номер чека") skip
        v-ser    label " Cерия чековой книжки"  format "x(2)" validate(can-find(first checks where checks.ser = v-ser no-lock),"Неверный номер серии") skip
        v-crc    label " Валюта              " format ">9" validate(can-find(first crc where crc.crc = v-crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum    LABEL " Сумма               " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_lname  label " ФИО получателя      " validate(trim(v_lname) <> "", "Введите Фамилию плательщика ") format "x(50)" skip
       /* v_name   label " Имя получателя      " validate(trim(v_name) <> "", "Введите Имя плательщика ") format "x(20)" skip
        v_mname  label " Отчество получателя " validate(trim(v_mname) <> "", "Введите Отчество плательщика ") format "x(20)" skip*/
        v_doc_num label " Документ            " help "Введите номер докумета удостов. личность" format "x(30)" validate(trim(v_doc_num) <> "", "Заполните номер документа") skip
        /*v_docwho  label " Выдан               " help " Кем выдан документ удостов. личность"  format "x(20)" validate(trim(v_docwho) <> "", "Заполните кем выдан документ") skip
        v_docdt   label " Дата выдачи         " format "99/99/9999" help " Ведите дату выдачи документа удостов. личость в формате дд/мм/гггг " validate(trim(v_docdt) <> "", "Заполните дату выдачи документа") skip*/
        v-labelp no-label v_rnnp  colon 22 no-label  help "Введите ИИН или '-'" format "x(12)" validate((chk12_innbin(v_rnnp)),'Неправильно введён БИН/ИИН') skip
        v-oplcom1 label " Вид опл.комиссии     " format "x(15)" skip
        v-chetk label  " Счет комиссии       " format "x(20)" skip
        v-crck   label " Валюта комиссии     " help "Введите код валюты комиссии, F2-помощь"   format ">9" validate(v-crck  = v-crc or v-crck = 1,"Может быть в валюте проводки илив тенге!") skip
        v_tar    LABEL " Код тарифа комиссии " format "x(5)" validate(((v_tar = "429" or v_tar = "028" or v_tar = "402" or v_tar = "949") and cif.type = "P" and v-crc = 1)
                                                   or ((v_tar = "419" or v_tar = "119" or v_tar = "422" ) and cif.type = "P" and v-crc <> 1)
                                                   or ((v_tar = "409" or v_tar = "439" or v_tar = "430" or  v_tar = "470") and cif.type = "B" and v-crc = 1)
                                                   or (v_tar = "430" and cif.type = "B" and v-crc <> 1)
                                                   ,"Неверный код тарифа комиссии")  help " Введите код тарифа комиссии, F2 помощь"
        v_comname  no-label colon 32 format "x(25)" skip
        /* v_sumk   LABEL " Сумма комиссии      " validate(v_sumk > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip*/
        v_sumk   LABEL " Сумма комиссии      " validate((v_sumk > 0 and can-find(first tarif2 where tarif2.str5 = v_tar  and not (tarif2.proc = 0 and tarif2.min = 0 and tarif2.max = 0) no-lock))
                                                    or (v_sumk = 0 and can-find(first tarif2 where tarif2.str5 = v_tar   and tarif2.proc = 0 and tarif2.min = 0 and tarif2.max = 0 no-lock))
                                                    or v_sumk = v-amt, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        v_code  label  " КОД                 " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label  " КБе                 "  skip
        v_knp   label  " КНП                 "  skip
        v_oper  label  " Назначение платежа  "  skip
        v_oper1 no-label colon 22 skip
        v_oper2 no-label colon 22 skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME f_main.


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
       DISPLAY tarif2.str5 label "Код тарифа " format "x(3)" tarif2.pakalp label "Наименование   " format "x(30)"
       WITH  15 DOWN.
DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.

/*lyubov*/
    form
      jl.ln label '#' format 'zzz'
      vv-crc label 'Валюта'
      jlsach.amt label ' Сумма '
      /*jlsach.sim label 'Код' format '999' validate((aaa.gl = 220520 and (string(jlsach.sim) = "220" or string(jlsach.sim) = "290")) or
                                             ((aaa.gl = 220310) and lookup(string(jlsach.sim), "210,270,290,300") > 0), "Неверный символ кассплана")*/
      jlsach.sim label 'Код' format '999' validate(can-find(first cashpl where cashpl.sim = jlsach.sim  and cashpl.sim > 100 and cashpl.act no-lock),"Неверный символ кассплана!")
      v_des label ' Описание        ' format 'x(38)' skip
      with centered 10 down frame frm123.

DEFINE QUERY q-sc FOR cashpl.

DEFINE BROWSE b-sim QUERY q-sc
       DISPLAY cashpl.sim label "Символ " format "999" cashpl.des label "Описание" format "x(45)"
       WITH  15 DOWN.
DEFINE FRAME f-sim b-sim  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.

on help of jlsach.sim in frame frm123 do:
/* 010, 070, 090, 100 */
    OPEN QUERY  q-sc FOR EACH cashpl where cashpl.sim > 100 and cashpl.act no-lock use-index sim.
    ENABLE ALL WITH FRAME f-sim.
    wait-for return of frame f-sim
    FOCUS b-sim IN FRAME f-sim.
    jlsach.sim = cashpl.sim.
    v_des = cashpl.des.
    hide frame f-sim.
    displ jlsach.sim v_des with frame frm123.
end.
/*lyubov*/

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

/*DEFINE QUERY q-chk FOR checks.

DEFINE BROWSE b-chk QUERY q-chk
       DISPLAY checks.lidz label "Номер " format "9999999" checks.regdt label "Дата регистр" checks.ser label "серия " format "x(2)"
       WITH  15 DOWN.
DEFINE FRAME f-chk b-chk  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 35 width 35 NO-BOX.

on help of v-chk in frame f_main do:
    OPEN QUERY  q-chk FOR EACH checks where checks.cif = v-cif no-lock.
    ENABLE ALL WITH FRAME f-chk.
    wait-for return of frame f-chk
    FOCUS b-chk IN FRAME f-chk.
    v-chk = checks.lidz.
    hide frame f-chk.
    displ v-chk with frame f_main.
end.
*/
define frame f_cus
        v_lname    label " Плательщик " format "x(50)" skip
        /*v_name     label " Имя          " format "x(20)" skip
        v_mname    label " Отчество        " format "x(20)" skip*/
        v_doc_num  label " Документ   "  format "x(30)" skip
        /*v_docwho   label " Выдан           "  format "x(20)" skip
        v_docdt    label " Дата выдачи     "  format "99/99/9999" skip*/
        v-labelp no-label v_rnnp  no-label colon 13 format "x(12)" validate(length(v_rnn) = 12 or trim(v_rnn) = "-", "Длина меньше 12 знаков") skip
    with title "ПЛАТЕЛЬЩИК" row 10 centered overlay side-labels.

on help of v_lname in frame f_cus do:
   id = 0.
   run choise_upl.
   if v-badd1 <> '' then v_lname = v-badd1.
   if v-badd2 <> '' then v_doc_num = v-badd2 + " " + v-badd3.
   displ v_lname v_doc_num v-labelp v_rnnp with frame f_cus.
end.

define frame f_heir
        v_lname    label " Плательщик          " format "x(50)" skip
        /*v_name     label " Имя          " format "x(20)" skip
        v_mname    label " Отчество        " format "x(20)" skip*/
        v_doc_num  label " Документ            "  format "x(30)" skip
        /*v_docwho   label " Выдан           "  format "x(20)" skip
        v_docdt    label " Дата выдачи     "  format "99/99/9999" skip*/
        v-labelp no-label format "x(22)" v_rnnp no-label colon 22 format "x(12)" validate(length(v_rnn) = 12 or trim(v_rnn) = "-", "Длина меньше 12 знаков") skip
        v-begz1 label    " Дата выд. завещания " format "99/99/9999" skip
    with title "НАСЛЕДНИК" row 10 centered overlay side-labels.

on help of v_lname in frame f_heir do:
   id = 0.
   run choise_heir.
   if v-fio    <> '' then v_lname   = v-fio.
   if v-idcard <> '' then v_doc_num  = v-idcard.
   v_rnnp = v-jssh.
   v-begz1 = v-begz.
   displ v_lname v_doc_num v-labelp v_rnnp v-begz1 with frame f_heir.
end.

  on help of v_tar in frame f_main do:
        if cif.type = "P" and v-crc = 1 then  OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "429" or tarif2.str5 = "028" or tarif2.str5 = "402" or tarif2.str5 = "949") and tarif2.stat  = "r" no-lock.
        if cif.type = "P" and v-crc <> 1 then OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "419" or tarif2.str5 = "119" or tarif2.str5 = "422") and tarif2.stat  = "r" no-lock.
        if cif.type = "B" and v-crc = 1 then OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "409" or tarif2.str5 = "439" or tarif2.str5 = "430" or tarif2.str5 = "470" ) and tarif2.stat  = "r" no-lock.
        if cif.type = "B" and v-crc <> 1 then OPEN QUERY  q-tar FOR EACH tarif2 where tarif2.str5 = "430" and tarif2.stat  = "r" no-lock.
        ENABLE ALL WITH FRAME f-tar.
        wait-for return of frame f-tar
        FOCUS b-tar IN FRAME f-tar.
        v_tar = tarif2.str5.
        hide frame f-tar.
    displ v_tar with frame f_main.
  end.

on help of v-crc in frame f_main do:
    run help-crc1.
end.
on help of v-crck in frame f_main do:
    run help-crc1.
end.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("CS2"). else run a_help-joudoc1 ("EK2").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
on choose of but in frame  f_main do:
end.
on "END-ERROR" of frame f-help do:
  hide frame f-help no-pause.
end.
on "END-ERROR" of frame f-tar do:
  hide frame f-tar no-pause.
end.
on "END-ERROR" of frame f-knp do:
  hide frame f-knp no-pause.
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
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-chet = aaa.aaa.
            hide frame f-help.
            displ v-chet with frame f_main.
        end.
        else do:
            v-chet = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            displ v-chet with frame f_main.
            return.
        end.
    end.
    else DELETE PROCEDURE phand.
end.


/*----------- выбор номера ЧК -----------------*/

        def var v-book as int.
        DEFINE QUERY q-book FOR checks.

        DEFINE BROWSE b-book QUERY q-book
               DISPLAY checks.nono checks.lidzno label "Выбор ЧК"
               WITH  15 DOWN.
        DEFINE FRAME f-book b-book  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 40 width 25 NO-BOX.

        DEFINE QUERY q-chk FOR wrk-chk.

        DEFINE BROWSE b-chk QUERY q-chk
               DISPLAY wrk-chk.chk label "№ чека " format "x(7)"
               WITH  15 DOWN.
        DEFINE FRAME f-chk b-chk  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 62 width 20 NO-BOX.

        on help of v-chk in frame f_main do:
            /* выбор ЧК */
            OPEN QUERY  q-book FOR EACH checks where checks.cif = v-cif no-lock.
            ENABLE ALL WITH FRAME f-book.
            wait-for return of frame f-book
            FOCUS b-book IN FRAME f-book.
            v-book = checks.nono.

            find last checks where checks.nono = v-book no-lock no-error.
            if avail checks then do:
                empty temp-table wrk-chk.
                do i = 1 to num-entries(checks.pages, "|"):
                    create wrk-chk.
                    wrk-chk.chk = entry(i, checks.pages, "|").
                end.
            end.

            /* выбор листа ЧК */
            OPEN QUERY  q-chk FOR EACH wrk-chk no-lock .
            ENABLE ALL WITH FRAME f-chk.
            wait-for return of frame f-chk
            FOCUS b-chk IN FRAME f-chk.
            if avail wrk-chk then v-chk = int(wrk-chk.chk).
            else v-chk = 0.

            hide frame f-chk.
            hide frame f-book.
            displ v-chk with frame f_main.
        end.
/*---------------------------------------------*/


/*  help for cif */
/*on help of v-cif in frame f_main do:
    hide frame f-help.
    v-cif = "".
    run h-cif PERSISTENT SET phand.
    v-cif = frame-value.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        v_name  = cif.name.
        displ v-cif v_name with frame f_main.
    end.
    DELETE PROCEDURE phand.
end.*/

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = "Расходная операция со счета клиента наличными  ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
        /*if v-ec = "7" then v_oper = "Выплата по чеку Nr." + string(v-chk). else  v_oper = "Выплата".*/
        if v-chk > 0 then v_oper = "Выплата по чеку Nr." + string(v-chk). else  v_oper = "Выплата".
        displ v-joudoc format "x(10)" with frame f_main.
        v-ja = yes.
        v-chet = "".
        v_sum = 0.
        v-crc = ?.
        /*v_oper = "Выплата".*/
        v_oper1 = "".
        v_oper2 = "".
        v-crck = ?.
        v_sumk = ?.
        v_tar = "".
        v-chetk = "".
        v-chk = 0.
        v_lname = "".
        v_name = "".
        v_namek = "".
        v_mname = "".
        v_doc_num = "".
        v_docwho = "".
        v_docdt = ?.
        v_rnnp = "".
        v-oplcom1 = "".
        run save_doc.
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = "Расходная операция со счета клиента наличными ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        vj-label  = " Сохранить изменения документа?...........".
        run view_doc.
        find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if available joudoc then do:
            find joudop where joudop.docnum = v-joudoc no-lock no-error.
            if available joudop then do:
                if joudop.type <> "CS2"  and joudop.type <> "EK2"then do:
                    message substitute ("Документ не относится к типу расходная операция со счета клиента наличными  ") view-as alert-box.
                    return.
                end.
                if v-ek = 1 and joudop.type = "EK2" then do:
                    message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                    return.
                end.
                if v-ek = 2 and joudop.type = "CS2" then do:
                    message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
                    return.
                end.
            end.
            if joudoc.who ne g-ofc then do:
                message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
                return.
            end.
        end.
        run save_doc.

        /* удаление записи из kfmoper  */
        find first kfmoper where kfmoper.operDoc = v-joudoc exclusive-lock no-error.
        if available kfmoper then delete kfmoper.
        find first kfmoper where kfmoper.operDoc = v-joudoc no-lock no-error.
        /*------------------------------------------------------------------------------*/

    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc with  frame f_main.
    update  v-chet help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v-crc = aaa.crc.
        v-gl = aaa.gl.
        if v-ek = 2 then do:
            find first codfr where codfr.codfr = 'ekcrc' and codf.code = string(v-crc) no-lock no-error.
            if not avail codfr then do:
                message "Не допустимый код валюты для работы с ЭК! Используйте счет 100100." view-as alert-box error.
                undo.
            end.
        end.
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
        if cif.type = "P" then v_namek = trim(trim(cif.prefix) + " " + trim(cif.name)). else v_namek = trim(trim(cif.prefix) + " " + trim(cif.name)).
        if v-bin then v_rnn = cif.bin. else v_rnn = cif.jss.
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

 /*Ограничение доступа пользователей*/
    s-aaa = v-chet.

  find last cifsec where cifsec.cif = cif.cif no-lock no-error.
  if avail cifsec then do:
     find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then do:
        message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = cif.cif
          ciflog.sectime = time
          ciflog.menu = "15.2.2. Расходная операция со счета клиента наличным".
          return.
     end.
     else do:
          create ciflogu.
          assign
            ciflogu.ofc = g-ofc
            ciflogu.jdt = today
            ciflogu.sectime = time
            ciflogu.cif = cif.cif
            ciflogu.menu = "15.2.2. Расходная операция со счета клиента наличным".
     end.
  end.
/*Ограничение доступа пользователей*/
    run aaa-aas.

    if aaa.sta = "C" then do:
        message "Счет закрыт.".
        pause 3.
        undo, retry.
    end.

    find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
        if available aas then do:
            message "ОСТАНОВКА ПЛАТЕЖЕЙ!".
            pause 3.
            undo,retry.
        end.


    displ v_namek v-label v_rnn v-crc  v_code v_oper v-labelp v_rnnp vj-label format "x(35)" no-label with frame f_main.
    pause 0.
    /* ИНФОРМАЦИЯ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА */
    if trim(cif.reschar[20]) <> "" or trim(cif.reschar[17]) <> "" then run a_mescif(trim(cif.cif)).

    if cif.type <> "P" then do:
    update v-chk v-ser  with frame f_main.
    v-ser = lower(v-ser).
     if lookup(substr(v-ser, 1 ,1),"q,a,z,w,s,x,e,d,c,r,f,v,t,g,b,y,h,n,u,j,m,i,k,l,o,p") <> 0 then do:
        message "Необходимо ввести серию русскими буквами"  view-as alert-box title "".  undo,retry.
     end.
      find last gram where gram.nono le v-chk and gram.lidzno ge v-chk and gram.ser <> "" and gram.ser = v-ser and gram.cif = cif.cif no-lock no-error.
            if not available gram then find last gram where gram.nono le v-chk and gram.lidzno ge v-chk and gram.ser = ""  and gram.cif = cif.cif no-lock no-error.
            if not available gram then do:
                message "Чека с таким номером нет в системе. " +
                    " Введите другой номер.".
                undo, retry.
            end.
            if gram.anuatz eq "*" then do:
                message "Чековая книжка аннулирована.".
                undo, retry.
            end.
            if gram.cif eq "" then do:
                message "Указанная чековая книжка еще не продана.".
                undo, retry.
            end.

            find first checks where checks.nono <= v-chk and checks.lidzno >= v-chk and checks.cif = cif.cif and checks.pages <> "" and checks.regdt > 09/25/12 no-lock no-error.
            if avail checks then do:
                if index(checks.pages, string(v-chk)) = 0 then do:
                    message "Данный чек уже использован" view-as alert-box.
                    undo, retry.
                end.
            end.

        if gram.cif ne "" then do:
            find cif where cif.cif eq gram.cif no-lock no-error.
                if not available cif then do:
                    message substitute ("Клиент с кодом &1 не найден.", gram.cif).
                    undo, retry.
                end.

            if v-cif ne gram.cif then do:
                message substitute ("Чек N&1 клиенту не принадлежит", v-chk).
                undo, retry.
            end.
        end.
    end.
    update  v_sum /*v_lname v_name v_mname v_doc_num v_docwho v_docdt v_rnnp no-label v_tar */ with frame f_main.
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
    /*---------------------------------------------------------------------------------------*/
        v-plat = "".
        if cif.type = "B" and substr(string(aaa.gl),1,4) <> "2204" then update v_lname /*v_name v_mname*/ v_doc_num /*v_docwho v_docdt*/ v_rnnp with frame f_main.
        else do:
            if yes-no ('', 'Получателем является владелец счета ?') then do:
                find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnchf" no-lock no-error.
                if available sub-cod and trim(sub-cod.rcode) <> "" then v_lname = sub-cod.rcode.
                else v_lname = cif.name.
                v_doc_num = cif.pss.
                if v-bin then do:
                    v_rnnp = cif.bin.
                    update v_lname /*v_name v_mname*/ v_doc_num /*v_docwho v_docdt v-labelp */ v_rnnp with frame f_main.
                end.
                else do:
                    v_rnnp = cif.jss.
                    update v_lname /*v_name v_mname*/ v_doc_num /*v_docwho v_docdt*/  v_rnnp with frame f_main.
                end.
            end.
            else do:
                repeat /* on endkey undo, retry */ :
                    if cif.type = "B" and substr(string(aaa.gl),1,4) <> "2204" then do:
                        message 'u - Уполномоченное лицо, n - Наследник, t - третье лицо'.
                        update v-plat no-label skip
                              with frame fplat centered row 5 title ' Задайте параметр '.
                        hide frame fplat.
                        if v-plat ne 'u' and v-plat ne 'n' and v-plat ne 't' then displ 'Выберите U, N или T !'.
                        else leave.
                    end.
                    if cif.type = "B" and substr(string(aaa.gl),1,4) = "2204" then do:
                        message 'u - Уполномоченное лицо, t - третье лицо'.
                        update v-plat no-label skip
                              with frame fplat centered row 5 title ' Задайте параметр '.
                        hide frame fplat.
                        if v-plat ne 'u' and v-plat ne 't' then displ 'Выберите U или T !'.
                        else leave.
                    end.
                    if cif.type = "P" and (substr(string(aaa.gl),1,4) = "2206" or substr(string(aaa.gl),1,4) = "2207" or substr(string(aaa.gl),1,4) = "2205") then do:
                        message 'u - Уполномоченное лицо, n - Наследник'.
                        update v-plat no-label skip
                              with frame fplat centered row 5 title ' Задайте параметр '.
                        hide frame fplat.
                        if v-plat ne 'u' and v-plat ne 'n' then displ 'Выберите U или N !'.
                        else leave.
                    end.
                end.
                if keyfunction (lastkey) = "end-error" then undo.
                if v-plat eq 'u' then do:
                    find first uplcif where uplcif.cif = v-cif and uplcif.dop = s-aaa no-error.
                    if avail uplcif then do:
                        v_lname   = ''.
                        v_doc_num  = ''.
                        v_rnnp  = ''.
                       /* message (' Укажите данные уполномоченного лица ! ').
                        update v_lname v_doc_num v_rnnp with frame f_cus.
                        hide frame f_cus.
                        display v_lname v_doc_num v-label v_rnnp with frame f_main.*/
                       id = 0.
                       run choise_upl.
                       if v-badd1 <> '' then v_lname = v-badd1.
                       if v-badd2 <> '' then v_doc_num = v-badd2 + " " + v-badd3.
                        displ v_lname v_doc_num  v_rnnp with frame f_main.
                        if  v_lname   = '' then do:
                           message skip " Уполномоченное лицо не выбрано! " skip(1) view-as
                           alert-box button ok title "".
                           undo, retry.
                        end.
                        update v_rnnp with frame f_main.
                        /*pause 0.*/
                        v_oper = "Выплата по доверенности от " + string(v-beg).
                    end.
                    else do:
                        message skip " У клиента нет уполномоченных лиц ! " skip(1) view-as
                        alert-box button ok title "".
                        undo, retry.
                    end. /* uplcif */
                end.
                if v-plat eq 'n' then  do:
                    find first cif-heir where cif-heir.cif = v-cif and cif-heir.aaa = s-aaa no-error.
                    if avail cif-heir then do:
                        message (' Укажите данные наследника ! ').
                        v_lname   = ''.
                        v_doc_num  = ''.
                        v_rnnp  = ''.
                        /*update v_lname v_doc_num  v_rnnp v-begz1 format "99/99/9999" with frame f_heir.
                        hide frame f_heir.
                        display v_lname v_doc_num v-label v_rnnp with frame f_main.*/
                           id = 0.
                           run choise_heir.
                           if v-fio    <> '' then v_lname   = v-fio.
                           if v-idcard <> '' then v_doc_num  = v-idcard.
                           v_rnnp = v-jssh.
                           v-begz1 = v-begz.
                           displ v_lname v_doc_num  with frame f_main.
                           if  v_lname   = '' then do:
                               message skip " Наследник не выбран! " skip(1) view-as
                               alert-box button ok title "".
                               update v_lname v_doc_num with frame f_main.
                           end.
                           update v_rnnp  with frame f_main.
                        /*pause 0.*/
                        v_oper = "Выплата по завещанию от " + string(v-begz1).
                    end.
                    else do:
                        message skip " У клиента нет наследников ! " skip(1) view-as
                        alert-box button ok title "".
                        undo, retry.
                    end. /* cif-heir */
                end.
                if v-plat eq 't' or v-plat = "" then do:
                    v_lname   = ''.
                    v_doc_num  = ''.
                    v_rnnp = ''.
                    update v_lname v_doc_num v_rnnp with frame f_main.
                end.
            end. /* владелец счета? */
        end.
        if lookup(string(aaa.gl),"220620,220720,221510,221710,221910,220530") <> 0 then do: /*при снятии депозита комиссия 0  */
            v_tar = "302".
            v_sumk = 0.
            v-crck = v-crc.
            displ v_tar v_sumk v-crck with frame f_main.
            pause 0.
        end.
        else do:
            repeat:
                run sel1("Выберите вид оплаты комиссии", "1 - с кассы/ЭК |2 - со счета").
                if keyfunction(lastkey) = "end-error" then return.
                v-oplcom1 = return-value.
                if v-oplcom1 = '' then return.
                v-chetk = "".
                /*v-crck = v-crc.*/
                displ v-oplcom1 v-chetk v-crck with frame f_main.
                v-oplcom = entry(1,v-oplcom1," ").
                if v-oplcom = "1" then update v-crck with frame f_main.
                if v-oplcom = "2" then do:
                    def var I as int init 0.
                    def var aaalist as char init "".

                    v-crck = 0.
                    FOR EACH aaa where aaa.cif = v-cif no-lock, crc where aaa.crc  = crc.crc no-lock.
                       find lgr where lgr.lgr = aaa.lgr no-lock.
                       if not available lgr or lgr.led = 'ODA' then next.
                       if aaa.sta <> "C" and aaa.sta <> "E" then do:
                            I = I + 1.
                            if aaalist <> "" then aaalist = aaalist + "|".
                            aaalist = aaalist + aaa.aaa + " " + string(crc.crc) + " " + crc.code + " " + string(aaa.cbal - aaa.hbal,"-zzzzzzzzzzzz9.99").
                        end.
                    end.

                    if I > 0 then do:
                       run sels("Выберите счет для снятия комиссии", aaalist).
                       if keyfunction(lastkey) = "end-error" then return.
                       v-chetk = entry(1,return-value," ").
                       v-crck = integer(entry(2,return-value," ")).
                    end.
                    displ v-chetk v-crck with frame f_main.
                    aaalist = "".
                end. /* v-oplcom = "2" */
                if cif.type = "B" /* значит юр лицо */  and v-crc = 1 then  v_tar = "409".
                if cif.type = "B" /* значит юр лицо */  and v-crc <> 1 then  v_tar = "430".
                if cif.type = "P" /* значит физ лицо */  and v-crc = 1 then  v_tar = "429".
                if cif.type = "P" /* значит физ лицо */  and v-crc <> 1 then  v_tar = "419".
                update v_tar with frame f_main.
                find first tarif2 where tarif2.str5 = trim(v_tar)  and tarif2.stat  = "r" no-lock no-error.
                if avail tarif2 then do:
                    v_comname = tarif2.pakalp.
                    v_kt = tarif2.kont.
                    displ v_comname with frame f_main.
                     /* вычисление суммы комиссии-----------------------------------*/
                    v-crctrf = 0. tmin1 = tarif2.min. tmax1 = tarif2.max. v-amt = 0. tproc = tarif2.proc.
                    run perev (v-chet,input v_tar, input v_sum, input v-crc, input v-crck,v-cif, output v-amt, output tproc, output pakal).
                    v_sumk = v-amt.
                    /*------------------------------------------------------------*/
                end.
                repeat:
                    v_sumk = v-amt.
                    update v_sumk  with frame f_main.
                    if v-amt <> 0 and v_sumk = 0 then undo.
                    leave.
                end.
                if keyfunction (lastkey) = "end-error" then undo.
                displ v_sumk v-crck with frame f_main.
                if v-oplcom = "1" then leave.
                if v-oplcom = "2" then do:
                    find first aaa where aaa.aaa = v-chetk no-lock no-error.
                    if v-chetk = v-chet then do:
                        if v_sumk + v_sum > aaa.cbal - aaa.hbal then MESSAGE "Ошибка, на выбранном счете недостаточно средств!" VIEW-AS alert-box error.
                        else leave.
                    end.
                    else do:
                        find first aaa where aaa.aaa = v-chetk no-lock no-error.
                        if v_sumk > aaa.cbal - aaa.hbal then MESSAGE "Ошибка, на выбранном счете недостаточно средств!" VIEW-AS alert-box error.
                        else leave.
                    end.
                    run checkdebt(g-today, v-chetk, v_tar, "bank").  /* проверка задолжности клиента  */
                end. /* if v-oplcom  = 2*/
            end. /* repeat  */
        end. /* else */

      /*if v-ec = "7" then v_oper = "Выплата по чеку Nr." + string(v-chk).*/
      if v-chk > 0 then v_oper = "Выплата по чеку Nr." + string(v-chk).
      update v_code v_kbe v_knp v_oper v_oper1 v_oper2 v-ja with frame f_main.
      if keyfunction (lastkey) = "end-error" then undo.
      if v-ja then do:
        /*---------------экран клиента-------------------------*/
        find first cmp no-lock no-error.
        find first sysc where sysc.sysc = "CifScr" no-lock no-error.
        if avail sysc and index(sysc.chval, string(cmp.code)) > 0 then do:
            TCIFNAME = v_namek.
            TAAA = v-chet.
            find first crc where crc.crc = v-crc no-lock no-error.
            TSUMM = string(v_sum) + " " + crc.code.
            find first crc where crc.crc = v-crck no-lock no-error.
            TCOMSUMM = string(v_sumk) + " " + crc.code.
            TREM = trim(v_oper) + trim(v_oper1) + trim(v_oper2).

            run to_screen("cifacc","TCIFNAME=" + TCIFNAME + "&TAAA=" + TAAA + "&TSUMM=" + TSUMM + "&TCOMSUMM=" + TCOMSUMM + "&TREM=" + TREM).

            run sel2 ("Экран клиента","Закрыть экран клиента" , output v-sel).
            if v-sel = 1 then run to_screen( "default","").
        end.
        /*-----------------------------------------------------*/
        if v-ek = 2 then do:
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

            find first crc where crc.crc = v-crck no-lock.
            v-crc_valk = crc.code.
            for each arp where arp.gl = 100500 and arp.crc = v-crck no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                if avail sub-cod then do:
                    v-chEKk = arp.arp.
                    /*v-sumarp = arp.dam[1] - arp.cam[1].*/
                end.
            end.
            if v-chEKk = '' then do:
                message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_valk + " !" view-as alert-box title " ОШИБКА ! ".
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
            joudoc.dracctype = "2".
            joudoc.dracc = v-chet.
            joudoc.drcur = v-crc.
            joudoc.cramt = v_sum.
            if v-ek = 2 then joudoc.cracctype = "4". else joudoc.cracctype = "1".
            if v-ek = 2 then joudoc.cracc = v-chEK. else joudoc.cracc = "".
            joudoc.crcur = v-crc.
            joudoc.comcode = v_tar.
            joudoc.comamt = v_sumk.
            joudoc.comcur = v-crck.
            if v-oplcom = "1" then do:
                if v-ek = 2 then joudoc.comacctype = "4". else joudoc.comacctype = "1".
                if v-ek = 2 then joudoc.comacc = v-chEKk. else joudoc.comacc = "".
            end.
            else do:
                joudoc.comacctype = "2".
                joudoc.comacc = v-chetk.
            end.
            joudoc.info = v_lname. /* + " " + v_name + " " + v_mname.*/
            if num-entries(trim(v_doc_num),",") > 1 or num-entries(trim(v_doc_num)," ") <= 1 then joudoc.passp = trim(v_doc_num).
            else joudoc.passp = entry(1,trim(v_doc_num)," ") + "," + substring(trim(v_doc_num),index(trim(v_doc_num)," "), length(v_doc_num)).
            /*joudoc.passpdt = v_docdt .*/
            joudoc.perkod = v_rnnp.
            joudoc.remark[1] = v_oper.
            joudoc.remark[2] = v_oper1.
            joudoc.rescha[3] = v_oper2.
            joudoc.chk = v-chk.
            joudoc.benname = v_namek.

            run chgsts("JOU", v-joudoc, "new").
            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            if v-ek = 1 then joudop.type = "CS2". else joudop.type = "EK2".
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
    displ v-joudoc with frame f_main.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        if joudop.type <> "CS2"  and joudop.type <> "EK2"then do:
            message substitute ("Документ не относится к типу расходная операция со счета клиента наличными  ") view-as alert-box.
            return.
        end.
        if v-ek = 1 and joudop.type = "EK2" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            return.
        end.
        if v-ek = 2 and joudop.type = "CS2" then do:
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
    v-chet = joudoc.dracc.
    v_sum = joudoc.dramt.
    v-crc = joudoc.drcur.
    v_oper = joudoc.remark[1].
    v_oper1 = joudoc.remark[2].
    v_oper2 = joudoc.rescha[3].
    v-crck = joudoc.comcur.
    v_sumk = joudoc.comamt.
    v_tar = joudoc.comcode.
    v-chetk = joudoc.comacc.
    v_lname = joudoc.info.
    /*v_name = entry(2,joudoc.info," ").
    v_mname = entry(3,joudoc.info," ").*/
    v_doc_num = joudoc.passp.
    /*v_docwho = entry(2,joudoc.passp,",").
    v_docdt  = joudoc.passpdt.*/
    v_rnnp = joudoc.perkod.
    if joudoc.comacctype = "1" or joudoc.comacctype = "4" then v-oplcom1 = "1 - с кассы/ЭК". else v-oplcom1 = "2 - со счета".
    if joudoc.comacctype = "1" or joudoc.comacctype = "4"  then v-oplcom = "1". else v-oplcom = "2".
    find first tarif2 where tarif2.str5 = trim(v_tar)  and tarif2.stat  = "r"  no-lock no-error.
    if avail tarif2 then do:
        v_comname = tarif2.pakalp.
        v_kt = tarif2.kont.
     end.
     v-chk = joudoc.chk.
     find first checks where checks.lidz = v-chk no-lock no-error.
     if avail checks then v-ser = checks.ser. else v-ser = "".
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
    end.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        if cif.type = "P" then v_namek = trim(trim(cif.prefix) + " " + trim(cif.name)). else v_namek = trim(trim(cif.prefix) + " " + trim(cif.name)).
        if v-bin then v_rnn = cif.bin. else v_rnn = cif.jss.
    end.
    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then do:
        v_code = entry(1,sub-cod.rcode,',').
        v_kbe = entry(2,sub-cod.rcode,',').
        v_knp = entry(3,sub-cod.rcode,',').
    end.

    v-ja = yes.
    v_title = " Расходная операция со счета клиента наличными ".
    displ v-joudoc v_trx v-chet v_namek v-label v_rnn v-chk v-ser v-crc v_sum v_lname /*v_name v_mname*/ v_doc_num
    /*v_docwho v_docdt*/  v-labelp v_rnnp v-oplcom1 v-chetk v-crck v_tar v_comname v_sumk v_code v_kbe v_knp  v_oper v_oper1 v_oper2 with  frame f_main.
end procedure.

Procedure Delete_document.
        vj-label  = " Удалить документ?..................".
        v_title = " Расходная операция со счета клиента наличными ".
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
            find first kfmoper where kfmoper.operDoc = joudoc.docnum and kfmoper.operType = "cs" no-lock no-error.
            if available kfmoper then do:
                message "Есть запись в службе комплаенс, удалять документ запрещено." view-as alert-box.
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
    return.
end procedure.

procedure Create_transaction:
        vj-label = " Выполнить транзакцию?..................".
        v_title = "  Расходная операция со счета клиента наличными ".
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

    find first cursts no-lock no-error.
    release cursts.

    /* фин мониторинг*/

    v_rez = v_code.
    v-knpval = v_knp.
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
    if keyfunction (lastkey) = "end-error" then do:
        v-ja = no.
        return.
    end.
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
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then v-gl = aaa.gl.

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

        find first crc where crc.crc = v-crck no-lock.
        v-crc_valk = crc.code.
        for each arp where arp.gl = 100500 and arp.crc = v-crck no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then do:
                v-chEKk = arp.arp.
                /*v-sumarp = arp.dam[1] - arp.cam[1].*/
            end.
        end.
        if v-chEKk = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_valk + " !" view-as alert-box title " ОШИБКА ! ".
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
            v-tmpl = "JOU0047".
         /* формир v-param для trxgen.p */
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-chet + vdel + v-chEK + vdel +
                        (v_oper + v_oper1 + v_oper2) + vdel + substring(v_kbe,1,1)
                        + vdel + substring(v_kbe,2,1) + vdel + v_knp + vdel + "0" + vdel + string(v-crc).
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
        else do:
            /* обрабатываем целую часть */
            v-tmpl = "JOU0047".
         /* формир v-param для trxgen.p */
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-chet + vdel + v-chEK + vdel +
                        (v_oper + v_oper1 + v_oper2) + vdel + substring(v_kbe,1,1)
                        + vdel + substring(v_kbe,2,1) + vdel + v_knp + vdel + "0" + vdel + string(v-crc).
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
        /* для комиссии--------------------------------------------*/
        if v_sumk <> 0 then do:
            if v-oplcom  = "1" then do:  /* комиссия с ЭК 100500      */
                if v-crck = 1 then do:  /* комиссия в тенге  */
                    v-tmpl = "jou0053".
                    v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v-crck) + vdel + v-chEKk + vdel + string(v_kt) + vdel + "Комиссия за " + v_comname + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                end.
                else do:
                    /*---------------выделяем дробную часть комиссии ----------------------------------------------*/
                    if v-crck <> 1 then do:
                        if v-crck = 4 then do:
                            v_sum1 = decim(entry(1,string(v_sumk),".")) / 100 .
                            v-mod1 = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 100) + (v_sumk - decim(entry(1,string(v_sumk),"."))).
                        end.
                        else do:
                            v_sum1 = decim(entry(1,string(v_sumk),".")) / 10 .
                            v-mod1 = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 10) + (v_sumk - decim(entry(1,string(v_sumk),"."))).
                        end.
                        v-int  = v_sumk - v-mod1.
                        v-modc = round(crc-conv(decimal(v-mod1), v-crck, 1),2).

                        /* проверка блокировки курса --------------------------------*/
                        if v-mod1 <> 0 then do:
                            v-cur = no.
                            run a_cur(input v-crck, output v-cur).
                            if v-cur then undo, return.
                        end.
                        /*------------------------------------------------------------*/
                    end.
                    /*------------------------------------------------------------------------------------------*/
                    if v-mod1 = 0 then do:
                        v-modc = round(crc-conv(decimal(v_sumk), v-crck, 1),2).
                        v-tmpl = "jou0053".
                        v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v-crck) + vdel + v-chEKk + vdel + string(v_kt) + vdel + "Комиссия за " + v_comname + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
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
                        v-param = v-joudoc + vdel + string(v-int) + vdel + string(v-crck) + vdel + v-chEKk + vdel + string(v_kt) + vdel + "Комиссия за " + v_comname + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
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
                                string(v-crck) + vdel + v-chEKk .
                        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                            message rdes.
                            pause.
                            undo, return.
                        end.
                        v-tmpl = "jou0053".
                        v-param = v-joudoc + vdel + string(v-mod1) + vdel + string(v-crck) + vdel + v-chEKk + vdel + string(v_kt) + vdel + "Комиссия за " + v_comname +
                        vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                            message rdes.
                            pause.
                            undo, return.
                        end.
                    end.
                end.
            end.
            else run comis_chet.   /* комиссия с счета   */
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
        if v-crc = 1 and v-crck = 1 then joudoc.brate = 1.
        else do:
            if v-crc = 1 then find first crc where  crc.crc = v-crck no-lock no-error.
            else find first crc where  crc.crc = v-crc no-lock no-error.
            joudoc.brate = crc.rate[2].
            joudoc.bn = 1.
        end.
        joudoc.srate = 1.
        find current joudoc no-lock no-error.
        run printvouord(2).
    end.
    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
        /* для суммы расхода        */
        v-tmpl = "JOU0062".
        v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-chet + vdel +
                    (v_oper + v_oper1 + v_oper2) + vdel + substring(v_kbe,1,1)
                    + vdel + substring(v_kbe,2,1) + vdel + v_knp + vdel + "0" + vdel + string(v-crc).
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        /* для комиссии--------------------------------------------*/
        if v_sumk <> 0 then do:
            if v-oplcom  = "1" then do:  /* комиссия с кассы      */
                v-tmpl = "jou0025".
                v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v-crck) + vdel + string(v_kt) +
                vdel + "Комиссия за " + v_comname + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
            end.
            else run comis_chet.  /* комиссия со счета  */
        end.

        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        find current joudoc no-lock no-error.
        run printvouord(2).
    end.  /* end v-ek = 1 ---------*/
        /*---------------------------------------------------------*/
    pause 1 no-message.
    /* копируем заполненные данные по ФМ в реальные таблицы*/
    /*if v-kfm then do:
        run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
        hide all.
        view frame f_main.
    end.*/
    /**/
    run chgsts(m_sub, v-joudoc, "trx").
    if v-chk = 0 then run chgsts("jou", v-joudoc, "cas").

    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.
    find first crc where crc.crc = v-crc no-lock.
    v_sum_lim = round(crc-conv(decimal(1000), 2, v-crc),2).
    if lookup(string(v-gl),v-glchk1) > 0 and v_sum >= v_sum_lim then  do:
        MESSAGE "Необходим контроль в п.м. 2.4.1.10! 'Контроль документов'!" view-as alert-box.
        for each sendod no-lock.
            run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
                "Добрый день!\n\n Необходимо отконтролировать расх. операцию \n со сбер/счета по суммам превышающую 1000 долл.США \n Сумма: " + string(v_sum) +
                "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
                string(time,"HH:MM"), "1", "","" ).
        end.
        hide all.
        view frame f_main.
        pause 0.
        run chgsts(m_sub, v-joudoc, "bad").

    end.
    if v-chk > 0 then do:
        MESSAGE "Необходим контроль в п.м. 2.4.1.1! 'Контроль документов'!" view-as alert-box.
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
    end.

    if (v-crc <> 1 or v-crck <> 1) and substring(v_code,2,1) <> "9" then do:
        message "Платеж должен пройти контроль Департаментом Валютного контроля 9.9 !"  view-as alert-box.
        run mail("DVKG@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
            "Добрый день!\n\n Необходимо отконтролировать расход наличных денег со счета клиента \n Сумма: " + string(v_sum) +
            "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
            string(time,"HH:MM"), "1", "","" ).
        hide all.
        view frame f_main.
        pause 0.
    end.
    v_trx = s-jh.
    display v_trx with frame f_main.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if v-ek = 1 then do:
        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
    end.

        /*run x0-cont1.
        hide all no-pause.*/
        if v-crc = 1 or v-mod <> 0 then do:
            find first jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = 100100 or jl.gl = 100500) no-lock no-error.
            if avail jl then do:
                find first aaa where aaa.aaa = v-chet no-lock no-error.
                if avail aaa /*and v_sumk = 0*/ then do:
                    if lookup(string(aaa.gl),"220620,220720,220420") <> 0 then do:
                        create jlsach .
                        jlsach.jh = s-jh.
                        if jl.dc = "d" then jlsach.amt = jl.dam .
                                       else jlsach.amt = jl.cam .
                        jlsach.ln = jl.ln .
                        jlsach.lnln = 1.
                        jlsach.sim = 220 .
                    end.

                    else if lookup(string(aaa.gl),"221510,221710,221910") <> 0 then do:
                        create jlsach .
                        jlsach.jh = s-jh.
                        if jl.dc = "d" then jlsach.amt = jl.dam .
                                       else jlsach.amt = jl.cam .
                        jlsach.ln = jl.ln .
                        jlsach.lnln = 1.
                        jlsach.sim = 300 .
                    end.
                    else if aaa.gl = 220530 then do:
                        create jlsach .
                        jlsach.jh = s-jh.
                        if jl.dc = "d" then jlsach.amt = jl.dam .
                                       else jlsach.amt = jl.cam .
                        jlsach.ln = jl.ln .
                        jlsach.lnln = 1.
                        jlsach.sim = 270 .
                    end.
                    else if lookup(string(aaa.gl),v-chk1) <> 0 then do:
                        def var v-amtk as deci.
                        def var v-amtt as deci.
                        def var v-amts as deci.
                        def var n      as int init 1.
                        v-amtk = if jl.dc = "d" then jl.dam else jl.cam.
                        v-amtt = v-amtk.
                        vv-crc = getcrc(jl.crc).
                        repeat while v-amts < v-amtk :
                            view frame frm123.
                            create jlsach.
                            assign jlsach.jh   = s-jh
                                   jlsach.amt  = v-amtt
                                   jlsach.ln   = jl.ln
                                   jlsach.lnln = n.
                            displ jl.ln vv-crc jlsach.amt with frame frm123.
                            update jlsach.amt jlsach.sim  with frame frm123.
                            v-amts = v-amts + jlsach.amt.
                            v-amtt = v-amtk - v-amts.
                            release jlsach.
                            n = n + 1.
                            down with frame frm123.
                        end.
                        hide all no-pause.
                    end.
                release jlsach.
                end.
            end.
        hide all no-pause.
        end.
        if (v-crck = 1 or v-mod1 <> 0) and v_sumk <> 0 and v-oplcom = "1" then do:
            find last jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = 100100 or jl.gl = 100500) no-lock no-error.
            if avail jl then do:
                create jlsach .
                jlsach.jh = s-jh.
                if jl.dc = "d" then jlsach.amt = jl.dam .
                               else jlsach.amt = jl.cam .
                jlsach.ln = jl.ln .
                jlsach.lnln = 1.
                jlsach.sim = 100 .
            end.
        release jlsach.
        hide all no-pause.
        end.
        view frame f_main.

    /*run vou_bankt(1, 1, joudoc.info).*/
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").
end procedure.

procedure Delete_transaction:
    if v-joudoc eq "" then undo, retry.
    find first joudoc where joudoc.docnum eq v-joudoc  exclusive-lock no-error no-wait.
    if not avail joudoc then do:
        if locked joudoc then message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ!" view-as alert-box error.
        else message "ДОКУМЕНТА НЕТ!" view-as alert-box error.
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

        /* удаление записи из kfmoper  */
        find first kfmoper where kfmoper.operDoc = joudoc.docnum exclusive-lock no-error.
        if available kfmoper then delete kfmoper.
        find first kfmoper where kfmoper.operDoc = joudoc.docnum no-lock no-error.
        /*------------------------------------------------------------------------------*/

        joudoc.jh   = ?.
        v_trx = ?.
        display v_trx with frame f_main.

    end. /* transaction */

    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    /*------- возврат/удаление чека в список неиспользованных --------*/
    del-page = no.
    find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk no-lock no-error.
    if avail checks then message "Чек испорчен ?" view-as alert-box question buttons yes-no title "" update del-page as logical.
    if del-page = yes then do:
            find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk and checks.pages <> "" no-lock no-error.
            if avail checks and index(checks.pages, string(joudoc.chk)) > 0 then do:
                if index(checks.pages, string(joudoc.chk)) > 0 then do:
                    s1 = substr(checks.pages, 1, index(checks.pages, string(joudoc.chk)) - 1).
                    s2 = substr(checks.pages, index(checks.pages, string(joudoc.chk)) + length(string(joudoc.chk)) + 1).
                    str-pages = s1 + s2.
                end.
            end.
            do transaction:
                find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk and checks.pages <> "" exclusive-lock no-error.
                if avail checks and index(checks.pages, string(joudoc.chk)) > 0 then do:
                    checks.pages = str-pages.
                    find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk no-lock no-error.
                end.
            end.
    end.
    if del-page = no then
    do transaction:
        find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk exclusive-lock no-error.
        if avail checks and index(checks.pages, string(joudoc.chk)) = 0 then
        checks.pages = checks.pages + string(joudoc.chk) + "|".
        find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk no-lock no-error.
    end.
    /*-----------------------------------------------------------*/

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
    else do:
        run printvouord(2).
        run printord(s-jh,"").
    end.
    end. /* transaction */
end procedure.

procedure choise_upl.  /* 16.09.2004 saltanat - процедура выбора уполномоченного лица */
for each wupl.
delete wupl.
end.
v-badd1 = ''. v-badd2 = ''. v-badd3 = ''.

upper:
for each uplcif where uplcif.cif = v-cif and dop = s-aaa and uplcif.finday > g-today.
  for each wupl.
  if (wupl.badd1 = uplcif.badd[1]) and (wupl.badd2 = uplcif.badd[2]) and
     (wupl.badd3 = uplcif.badd[3]) then next upper.
  end.
  if uplcif.badd[1] <> '' then do:
  id = id + 1.
  create wupl.
  assign wupl.id = id
            wupl.upl    = uplcif.upl
            wupl.badd1  = uplcif.badd[1]
            wupl.badd2  = uplcif.badd[2]
            wupl.badd3  = uplcif.badd[3]
            wupl.finday = uplcif.finday
            wupl.coregdt = uplcif.coregdt.
  end.
end.
find first wupl no-error.
if not avail wupl then do:
   message skip " У клиента нет уполномоченных лиц ! " skip(1) view-as
   alert-box button ok title "".
   return.
end.
   {itemlist.i
    &file = "wupl"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " wupl.id    label 'N' format 'zz9'
                 wupl.badd1 label 'Ф.И.О.' format 'x(20)'
                 wupl.badd2 label 'Паспорт.данные'
                 wupl.badd3 label 'Кем/Когда выдан' format 'x(20)'
                 wupl.finday label 'Дата окон.дов.'
               "
    &chkey = "id"
    &chtype = "integer"
    &index  = "main"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
  if wupl.finday >= g-today then do:
  v-badd1  = wupl.badd1.
  v-badd2  = wupl.badd2.
  v-badd3  = wupl.badd3.
  v-beg    = wupl.coregdt.
  end.
  else
  Message ('У уполномоченного лица истек срок доверенности ! ').
end procedure.

procedure choise_heir.
for each wheir.
delete wheir.
end.
v-fio = ''. v-idcard = ''. v-jssh = ''.
upper:
for each cif-heir where cif-heir.cif = v-cif.
  for each wheir.
  if (wheir.fio    = cif-heir.fio) and
     (wheir.idcard = cif-heir.idcard) and
     (wheir.jss    = cif-heir.jss) then next upper.
  end.
  if cif-heir.fio <> '' then do:
  id = id + 1.
  create wheir.
  assign wheir.id     = id
         wheir.fio    = cif-heir.fio
         wheir.idcard = cif-heir.idcard
         wheir.jss    = cif-heir.jss
         wheir.ratio  = cif-heir.ratio
         wheir.will-date  = cif-heir.will-date.
  end.
end.
find first wheir no-error.
if not avail wheir then do:
   message skip " У клиента нет наследников ! " skip(1) view-as
   alert-box button ok title "".
   return.
end.
   {itemlist.i
    &file = "wheir"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " wheir.id     label 'N'
                 wheir.fio    label 'Ф.И.О.' format 'x(20)'
                 wheir.idcard label 'Удостоверение' format 'x(12)'
                 wheir.jss    label 'ИИН/БИН' format 'x(12)'
                 wheir.ratio  label 'Доля' format 'x(10)'
                 wheir.will-date  label 'Дата'
               "
    &chkey = "id"
    &chtype = "integer"
    &index  = "main"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
  v-fio    = wheir.fio.
  v-idcard = wheir.idcard.
  v-jssh   = wheir.jss.
  v-begz   =  wheir.will-date.
end procedure.

procedure comis_chet.  /* комиссия с счета   */
        v-tmpl = "jou0026".
     /* формир v-param для trxgen.p */
        v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v-crck) + vdel + v-chetk + vdel + string(v_kt) +
        vdel + "Комиссия за " + v_comname.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
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
    if (v-crc <> 1 or v-crck <> 1) and substring(v_code,2,1) <> "9" then do:
        if not avail cursts and cursts.valaks <> "val" then do :      message "Документ подлежит валютному контролю в п.м. 9.11 " view-as alert-box.
          undo, return.
        end.
    end.
    if not avail cursts or (avail cursts and cursts.sts <> "cas") then do :      message "Документ не отконтролирован " view-as alert-box.
      undo, return.
    end.
    v-Get_Nal = yes.

   /* vj-label  = " Выполнить выдачу наличных?..................".
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
      message "Проводка уже отштампована " view-as alert-box.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").*/
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
    if (v-crc <> 1 or v-crck <> 1) and substring(v_code,2,1) <> "9" then do:
        if not avail cursts and cursts.valaks <> "val" then do :      message "Документ подлежит валютному контролю в п.м. 9.11 " view-as alert-box.
          undo, return.
        end.
    end.
    if not avail cursts or (avail cursts and cursts.sts <> "cas") then do :      message "Документ не отконтролирован " view-as alert-box.
      undo, return.
    end.
    run a_stamp(joudoc.jh).
    pause 0.
    hide all.
    view frame f_main.
end.
