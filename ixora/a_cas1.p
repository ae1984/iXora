/* a_cas1.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Взнос наличных денег на счет клиента
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
        10/02/2012  Luiza - изменила выделение дробной части для комиссии
        14/02/2012  Luiza  - при выделение дробной части для комиссии v_crc поменяла на v_crck
        17.02.2012  Lyubov - При пополнении счета ЮЛ (счет ГК 221510, 221710, 221910) зашила символ 100;
                             При пополнении счета ФЛ (счет ГК 220620, 220720) зашила символ 020;
                             Добавила выбор кассплана через F2 (счет ГК 220310, ГК 220420, ГК 220520)
        23.02.2012 aigul -  Добавила букву И в Вид опл.комиссии
        07/03/2012 Luiza  - изменила передачу параметров при вызове printord
        12.03.2012 Lyubov - для ГК 220420 убрала поиск по F2, зашила символ 020
        19/03/2012 Luiza  - если тестовая база клиента finmon не вызываем
        20/03/2012 Luiza  - вызов функции isProductionServer выполняем в a_fimnon.i
        27/03/2012 Luiza  - добавила удаление спец инстр при удалении транзакции
        29/03/2012 Luiza  - отменила конвертацию дробных
        03/04/2012 Luiza  - добавила счет 279940
        09/04/2012 Luiza  - тариф зависит от валюты счета
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        24/04/2012 Luiza - отображаем полное название клиента
        27/04/2012 Luiza - добавила счет 287080
        02/05/2012 evseev - логирование значения aaa.hbal
        07/05/2012 Luiza  - добавила процедуру defclparam
        14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
        15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
        26/06/2012 Luiza - изменила заполнение поля passp
        28/06/2012 Luiza - удалила лишние транзакц блоки
        10/07/2012 dmitriy - вывод на экран клиента
        12/07/2012 dmitriy - вывод на экран клиента только для филиалов, прописанных в sysc = "CifScr"
        25/072012  Luiza   - изменила проверку суммы при работе с ЭК
        26/07/2012 Luiza   - слово ЕК заменила ЭК
        14/08/2012 Luiza  - добавила release cif для обновления признака контроля cif
        10/09/2012 Luiza подключила {srvcheck.i}
        19/09/2012 Luiza изменила текст для mail при поступлении средств на заблокир счет
        27/09/2012 Luiza добавила очищение joudoc.vo в момент сохранения документа.
        05/10/2012 Luiza изменила присвоение кода тарифа 302 для юр лиц согласно СЗ от 05/10/2012
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        10/04/2013 Luiza ТЗ № 1515 Оповещение менеджера о клиенте
        15/05/2013 Luiza - ТЗ № 1826 Добавление евро для 100500
        20/05/2013 Luiza  - ТЗ 1309
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        06/08/2013 Luiza - ТЗ 1997 Расширение поля «Код тарифа»
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
def var v_arp as char format "x(20)" no-undo. /* счет карточка ARP*/
def  var v_dt as int  no-undo format "999999". /* Дт 100100*/
def  var v_kt as int no-undo format "999999". /* КТ 287051*/
def new shared var s-lon like lon.lon.
def new shared var v-num as integer no-undo.
def var v-crc as int  no-undo .  /* Валюта*/
def var vv-crc as char  no-undo .  /* Валюта*/
def var v-crck as int  no-undo .  /* Валюта comiss*/
def var v-chet as char format "x(20)". /* счет клиента*/
def var v-chetk as char format "x(20)". /* счет клиента for comiss*/
def var v-cif as char format "x(6)". /* cif клиент*/
def  var v_lname as char no-undo format "x(20)".
def  var v_mname as char no-undo format "x(20)".
def var v_name as char format "x(20)". /*  клиент*/
def var v_namek as char format "x(60)". /*  клиент*/
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
def  var v_doc_num as char no-undo.
def  var  v_docwho as char no-undo.
def  var v_docdt as date no-undo.
def var v_rnn as char no-undo.
def var v_rnnp as char no-undo.
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
def  var v-bplace as char no-undo.
def var ss-jh as int.
def var v_sim as int.
def var v_des as char.

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
def var v-clname2 as char no-undo.
def var v-clfam2 as char no-undo.
def var v-clmname2 as char no-undo.
def var v-addr as char no-undo.
def var v-country2 as char.
def var famlist as char init "".
define new shared variable vrat  as decimal decimals 4.

/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-crc_valk as char no-undo format "xxx".
def var v-chEK as char format "x(20)". /* счет ЭК*/
def var v-chEK1 as char format "x(20)". /* счет ЭК для тенге*/
def var v-chEKk as char format "x(20)". /* счет ЭК для комиссии*/

/*------------------------------------*/


def var v-rnn as char no-undo.
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
/*---------------------------*/
define new shared variable s-aaa like aaa.aaa.
def var v-badd1  as char.
def var v-badd2  as char.
def var v-badd3  as char.
def var id       as inte.
def var v-plat   as char init 'u'.
def var v-fio    like cif-heir.fio.
def var v-idcard like cif-heir.idcard.
def var v-jssh   like cif-heir.jss.

def temp-table wupl
    field id    as   inte
    field upl   as   inte
    field badd1 as   char
    field badd2 as   char
    field badd3 as   char
    field finday like uplcif.finday
index main is primary unique upl.

def temp-table wheir
    field id     as   inte
    field fio    as   char
    field idcard as   char
    field jss    as   char
    field ratio  as   char
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

define variable vvv-cash   as int.
find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
vvv-cash = sysc.inval.


{yes-no.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */
{comm-txb.i}
{get-dep.i}
{findstr.i}
{kfm.i "new"}
def var v-knpval as char no-undo.
{checkdebt.i &file = "bank"}
{keyord.i}
{srvcheck.i}

/*function isProductionServer returns logical.
    def var res as logical no-undo.
    res = no.
    def var v-text as char no-undo.
    input through "hostname | awk -F'.' '\{print $1\}'".
    repeat:
        import unformatted v-text.
        v-text = trim(v-text).
        if v-text <> '' then leave.
    end.
    if v-text = "ixora01" then res = yes.
    return res.
end function.*/

/*проверка банка*/
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).

def var v-chk1 as char no-undo.
find first bookcod where bookcod.bookcod = 'a_cas1'
                     and bookcod.code    = 'chk'
                     no-lock no-error.
if not avail bookcod or trim(bookcod.name) = "" then do:
    message "В справочнике <bookcod> код <chk> отсутствует список  для определения допустимых счетов ГК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
v-chk1 = bookcod.name.

def var v-bin as logi init no.
def var v-label as char format "x(25)".
def var v-labelp as char format "x(25)".
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v-label =  " ИИН/БИН клиента        :". else v-label =  " РНН клиента            :".
if v-bin  then v-labelp = " ИИН/БИН плательщика    :". else v-labelp = " РНН плательщика        :".

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
        v-joudoc label " Документ               " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"          but skip
        v-chet   label " Счет клиента           "  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-chet and lookup(string(aaa.gl),v-chk1) > 0 no-lock),
                "Неверный счет ГК счета клиента!") skip

        v_namek   label " Клиент                 "  format "x(60)" skip
        v-label no-label v_rnn  colon 25 no-label format "x(12)" validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip
        v-crc    label " Валюта                 " format ">9" validate(can-find(first crc where crc.crc = v-crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum    LABEL " Сумма                  " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_lname  label " ФИО плательщика        " validate(trim(v_lname) <> "", "Введите Фамилию плательщика ") format "x(50)" skip
        /*v_name   label " Имя плательщика        " validate(trim(v_name) <> "", "Введите Имя плательщика ") format "x(20)" skip
        v_mname  label " Отчество плательщика   " validate(trim(v_mname) <> "", "Введите Отчество плательщика ") format "x(20)" skip*/
        v_doc_num  label " Документ               " help "Введите номер докумета удостов. личность" format "x(30)" validate(trim(v_doc_num) <> "", "Заполните номер документа") skip
       /* v_docwho   label " Выдан                  " help " Кем выдан документ удостов. личность"  format "x(20)" validate(trim(v_docwho) <> "", "Заполните кем выдан документ") skip
        v_docdt    label " Дата выдачи            " format "99/99/9999" help " Ведите дату выдачи документа удостов. личость в формате дд/мм/гггг " validate(trim(v_docdt) <> "", "Заполните дату выдачи документа") skip*/
        v-labelp no-label v_rnnp  colon 25 no-label  help "Введите ИИН " format "x(12)" validate((chk12_innbin(v_rnnp)),'Неправильно введён БИН/ИИН') skip
        v-oplcom1 label " Вид опл.комиссии       " format "x(15)" skip
        v-chetk label  " Счет комиссии          " format "x(20)" skip(1)
        v-crck   label " Валюта комиссии        " format ">9" validate(can-find(first crc where crc.crc = v-crck and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_tar    LABEL " Код тарифа комиссии    " format "x(5)" validate(((v_tar = "450" or v_tar = "431") and cif.type = "P" and v-crc = 1)
                                                   or ((v_tar = "459" or v_tar = "125" or v_tar = "431") and cif.type = "P" and v-crc <> 1)
                                                   or ((v_tar = "403" or v_tar = "436" or v_tar = "401") and cif.type = "B" and v-crc = 1)
                                                   or (v_tar = "456" and cif.type = "B" and v-crc <> 1)
                                                   ,"Неверный код тарифа комиссии")  help " Введите код тарифа комиссии, F2 помощь"
        v_comname  no-label colon 32 format "x(25)" skip
        v_sumk   LABEL " Сумма комиссии         " validate((v_sumk > 0 and can-find(first tarif2 where tarif2.str5 = v_tar  and not (tarif2.proc = 0 and tarif2.min = 0 and tarif2.max = 0) no-lock))
                                                    or (v_sumk = 0 and can-find(first tarif2 where tarif2.str5 = v_tar   and tarif2.proc = 0 and tarif2.min = 0 and tarif2.max = 0 no-lock))
                                                    or v_sumk = v-amt, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        v_code  label  " КОД                    " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label  " КБе                    "  skip
        v_knp   label  " КНП                    "  skip
        v_oper  label  " Назначение платежа     "  skip
        v_oper1 no-label colon 25 skip
        v_oper2 no-label colon 25 skip(1)
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
      /*v_sim label 'Код' format '999' validate((aaa.gl = 220520 and (string(v_sim) = "20" or string(v_sim) = "90")) or
                                             ((aaa.gl = 220310) and lookup(string(v_sim), "10,70,90,100") > 0), "Неверный символ кассплана")*/
      v_sim label 'Код' format '999' validate(can-find(first cashpl where cashpl.sim = v_sim and cashpl.sim <= 100 and cashpl.act no-lock),"Неверный символ кассплана!")
      v_des label ' Описание        ' format 'x(38)'
      with centered 10 down frame frm123.

DEFINE QUERY q-sc FOR cashpl.

DEFINE BROWSE b-sim QUERY q-sc
       DISPLAY cashpl.sim label "Символ " format "999" cashpl.des label "Описание" format "x(45)"
       WITH  15 DOWN.
DEFINE FRAME f-sim b-sim  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.

on help of v_sim in frame frm123 do:
/* 010, 070, 090, 100 */
    OPEN QUERY  q-sc FOR EACH cashpl where cashpl.sim <= 100 and cashpl.act no-lock use-index sim.
    ENABLE ALL WITH FRAME f-sim.
    wait-for return of frame f-sim
    FOCUS b-sim IN FRAME f-sim.
    v_sim = cashpl.sim.
    v_des = cashpl.des.
    hide frame f-sim.
    displ v_sim v_des with frame frm123.
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

on help of v-crc in frame f_main do:
    run help-crc1.
end.
on help of v-crck in frame f_main do:
    run help-crc1.
end.
on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("CS1"). else run a_help-joudoc1 ("EK1").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f-help do:
  hide frame f-help no-pause.
end.
on "END-ERROR" of frame f-tar do:
  hide frame f-tar no-pause.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
on choose of but in frame  f_main do:
end.

define frame f_cus
        v_lname    label " Плательщик " format "x(50)" skip
        /*v_name     label " Имя          " format "x(20)" skip
        v_mname    label " Отчество        " format "x(20)" skip*/
        v_doc_num  label " Документ   "  format "x(30)" skip
        /*v_docwho   label " Выдан           "  format "x(20)" skip
        v_docdt    label " Дата выдачи     "  format "99/99/9999" skip*/
        v_rnnp      label " ИИН/БИН плательщика" format "x(12)" validate(length(v_rnnp) = 12 or trim(v_rnnp) = "-", "Длина меньше 12 знаков") skip
    with title "ПЛАТЕЛЬЩИК" row 10 centered overlay side-labels.

on help of v_lname in frame f_cus do:
   id = 0.
   run choise_upl.
   if v-badd1 <> '' then v_lname = v-badd1.
   if v-badd2 <> '' then v_doc_num = v-badd2 + " " + v-badd3.
   displ v_lname v_doc_num  v_rnnp with frame f_cus.
end.

define frame f_heir
        v_lname    label " Плательщик " format "x(50)" skip
        /*v_name     label " Имя          " format "x(20)" skip
        v_mname    label " Отчество        " format "x(20)" skip*/
        v_doc_num  label " Документ   "  format "x(30)" skip
        /*v_docwho   label " Выдан           "  format "x(20)" skip
        v_docdt    label " Дата выдачи     "  format "99/99/9999" skip*/
        v_rnnp     label " ИИН/БИН плательщика" format "x(12)" validate(length(v_rnnp) = 12 or trim(v_rnnp) = "-", "Длина меньше 12 знаков") skip
    with title "НАСЛЕДНИК" row 10 centered overlay side-labels.

on help of v_lname in frame f_heir do:
   id = 0.
   run choise_heir.
   if v-fio    <> '' then v_lname   = v-fio.
   if v-idcard <> '' then v_doc_num  = v-idcard.
   v_rnnp = v-jssh.
   displ v_lname v_doc_num  v_rnnp with frame f_heir.
end.

  on help of v_tar in frame f_main do:
  /* 450, 459, 125, 420, 431, 403, 436, 401, 456 */
        if cif.type = "P" and v-crc = 1 then  OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "450" or tarif2.str5 = "431") and tarif2.stat  = "r" no-lock.
        if cif.type = "P" and v-crc <> 1 then OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "459" or tarif2.str5 = "125" or tarif2.str5 = "431") and tarif2.stat  = "r" no-lock.
        if cif.type = "B" and v-crc = 1 then OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "403" or tarif2.str5 = "436" or tarif2.str5 = "401") and tarif2.stat  = "r" no-lock.
        if cif.type = "B" and v-crc <> 1 then OPEN QUERY  q-tar FOR EACH tarif2 where tarif2.str5 = "456" and tarif2.stat  = "r" no-lock.
        ENABLE ALL WITH FRAME f-tar.
        wait-for return of frame f-tar
        FOCUS b-tar IN FRAME f-tar.
        v_tar = tarif2.str5.
        hide frame f-tar.
    displ v_tar with frame f_main.
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
    v_title = "Взнос наличных денег на счет клиента ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
       v_oper = "Пополнение счета".
        displ v-joudoc format "x(10)" with frame f_main.
        v-ja = yes.
        v-chet = "".
        v_sum = 0.
        v-crc = ?.
        v_oper1 = "".
        v_oper2 = "".
        v-crck = ?.
        v_sumk = ?.
        v_tar = "".
        v-chetk = "".
        v_lname = "".
        v_name = "".
        v_namek = "".
        v_mname = "".
        v_doc_num = "".
        v_docwho = "".
        v_docdt = ?.
        v_rnnp = "".
        v-oplcom1 = "".
        do transaction:
            run save_doc.
        end.
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = "Взнос наличных денег на счет клиента".
    run view_doc.
    if v_u = 2 then do:       /* update */
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                     if joudop.type <> "CS1"  and joudop.type <> "EK1" then do:
                        message substitute ("Документ не относится к типу взнос наличных денег на счет клиента ") view-as alert-box.
                        return.
                    end.
                    if v-ek = 1 and joudop.type = "EK1" then do:
                        message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                        return.
                    end.
                    if v-ek = 2 and joudop.type = "CS1" then do:
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
            do transaction:
                run save_doc.
            end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc with  frame f_main.
    update  v-chet help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v-crc = aaa.crc.
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
        if cif.geo = "021" then v_kbe = "1" + v-ec.
        else do:
            if   cif.geo = "022" then v_kbe = "2" + v-ec.
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
          ciflog.menu = "15.2.1. Взнос наличных денег на счет клиента".
          return.
     end.
     else do:
          create ciflogu.
          assign
            ciflogu.ofc = g-ofc
            ciflogu.jdt = today
            ciflogu.sectime = time
            ciflogu.cif = cif.cif
            ciflogu.menu = "15.2.1. Взнос наличных денег на счет клиента".
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
    update v_sum /*v_lname v_name v_mname v_doc_num v_docwho v_docdt v_rnnp*/ with frame f_main.
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
        if cif.type <> "P" and substr(string(aaa.gl),1,4) <> "2204" then update v_lname /*v_name v_mname*/ v_doc_num /*v_docwho v_docdt*/ v_rnnp  with frame f_main.
        else do:
            if yes-no ('', 'Плательщиком является владелец счета ?') then do:
                find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnchf" no-lock no-error.
                if available sub-cod and trim(sub-cod.rcode) <> "" then v_lname = sub-cod.rcode.
                else v_lname = cif.name.
                v_doc_num = cif.pss.
                if v-bin then v_rnnp = cif.bin. else v_rnnp = cif.jss.
                display v_lname /*v_name v_mname*/ v_doc_num /*v_docwho v_docdt v-label*/  v_rnnp with frame f_main.
                pause 0.
            end.
            else do:
                repeat /* on endkey undo, retry */ :
                    if cif.type = "B" then do:
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
                    end.
                    else do:
                        if  aaa.gl <> 287080 and  (cif.type = "P" and (substr(string(aaa.gl),1,4) <> "2206" and substr(string(aaa.gl),1,4) <> "2207" and substr(string(aaa.gl),1,4) <> "2205")) then do:
                            message 'u - Уполномоченное лицо, n - Наследник'.
                            update v-plat no-label skip
                                  with frame fplat centered row 5 title ' Задайте параметр '.
                            hide frame fplat.
                            if v-plat ne 'u' and v-plat ne 'n' then displ 'Выберите U или N !'.
                            else leave.
                        end.
                        else do:
                            message 'u - Уполномоченное лицо, t - третье лицо'.
                            update v-plat no-label skip
                                  with frame fplat centered row 5 title ' Задайте параметр '.
                            hide frame fplat.
                            if v-plat ne 'u' and v-plat ne 't' then displ 'Выберите U или T !'.
                            else leave.
                        end.
                    end.
                end.
                if keyfunction (lastkey) = "end-error" then undo.

                if v-plat eq 'u' then do:
                    find first uplcif where uplcif.cif = v-cif and uplcif.dop = s-aaa no-error.
                    if avail uplcif then do:
                        v_lname   = ''.
                        v_doc_num  = ''.
                        v_rnnp  = ''.
                        /*message (' Укажите данные уполномоченного лица ! ').
                        update v_lname v_doc_num v_rnnp with frame f_cus.
                        hide frame f_cus.
                        display v_lname v_doc_num v-label v_rnnp with frame f_main.*/
                       id = 0.
                       run choise_upl.
                       if v-badd1 <> '' then v_lname = v-badd1.
                       if v-badd2 <> '' then v_doc_num = v-badd2 + " " + v-badd3.
                       displ v_lname v_doc_num v_rnnp with frame f_main.
                       if  v_lname   = '' then do:
                           message skip " Уполномоченное лицо не выбрано! " skip(1) view-as
                           alert-box button ok title "".
                           undo, retry.
                       end.
                        update v_rnnp with frame f_main.
                        /*pause 0.*/
                    end.
                    else do:
                        message skip " У клиента нет уполномоченных лиц ! " skip(1) view-as
                        alert-box button ok title "".
                        undo, retry.
                    end. /* uplcif */
                end.
                if v-plat eq 'n' then do:
                    find first cif-heir where cif-heir.cif = v-cif and cif-heir.aaa = s-aaa no-error.
                    if avail cif-heir then do:
                        message (' Укажите данные наследника ! ').
                        v_lname   = ''.
                        v_doc_num  = ''.
                        v_rnnp  = ''.
                       /* update v_lname v_doc_num  v_rnnp with frame f_heir.
                        hide frame f_heir.
                        display v_lname v_doc_num v-label v_rnnp with frame f_main.*/
                           id = 0.
                           run choise_heir.
                           if v-fio    <> '' then v_lname   = v-fio.
                           if v-idcard <> '' then v_doc_num  = v-idcard.
                           v_rnnp = v-jssh.
                           displ v_lname v_doc_num  v_rnnp with frame f_main.
                           if  v_lname   = '' then do:
                               message skip " Наследник не выбран! " skip(1) view-as
                               alert-box button ok title "".
                               undo, retry.
                           end.
                        update v_rnnp with frame f_main.
                        /*pause 0.*/
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
                    v_rnnp  = ''.
                    update v_lname v_doc_num v_rnnp with frame f_main.
                end.

            end. /* владелец счета? */
        end.
        /*----------------------------------------------------------------------------------------*/
        if aaa.gl = 287080 or lookup(string(aaa.gl),"220620,220720,221510,221710,221910") <> 0 then do: /*при пополнении депозита комиссия 0  */
            if lookup(string(aaa.gl),"287080,221510,221710,221910") <> 0 then v_tar = "302". else v_tar = "450".
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
                 if v-oplcom = "1" then leave.
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
                       if keyfunction(lastkey) = "end-error" then do:
                            hide frame f_main.
                            return.
                       end.
                       v-chetk = entry(1,return-value," ").
                       v-crck = integer(entry(2,return-value," ")).
                    end.
                    displ v-chetk v-crck with frame f_main.
                     aaalist = "".

                    if v-crc <> v-crck then do:
                         find crc where crc.crc = v-crck no-lock no-error.
                         if not available crc then do:
                            message "Ошибка, не найден код валюты"  view-as alert-box error.
                            return.
                         end.
                         find first tarif2 where tarif2.str5 = trim(v_tar) and tarif2.stat = 'r' no-lock no-error.
                         if avail tarif2 then do:
                            v_sumk = tarif2.ost.
                            if tarif2.proc > 0 then do:
                               v_sumk = (v_sum / 100) * tarif2.proc * crc.rate[1].
                               if tarif2.min > 0 then do:
                                  if v_sumk < tarif2.min then v_sumk = tarif2.min.
                               end.
                            end.
                            v_sumk = v_sumk / crc.rate[1].
                         end.
                         displ v_sumk v-crck with frame f_main.
                         find first aaa where aaa.aaa = v-chetk no-lock no-error.
                         if v_sumk > aaa.cbal - aaa.hbal then do:
                            MESSAGE "Ошибка, на выбранном счете недостаточно средств, ~nсумму комиссии записать в долг?" VIEW-AS
                            ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
                            IF b THEN leave.
                         end.
                         else leave.
                    end.
                    if v-crc = v-crck then do:
                         find first aaa where aaa.aaa = v-chetk no-lock no-error.
                         if v_sumk > aaa.cbal - aaa.hbal then do:
                            MESSAGE "Ошибка, на выбранном счете недостаточно средств, ~nсумму комиссии записать в долг?" VIEW-AS
                            ALERT-BOX QUESTION BUTTONS YES-NO UPDATE bb AS LOGICAL.
                            IF bb THEN leave.
                         end.
                        else leave.
                    end.
                end.  /* if v-oplcom  = 2*/

                run checkdebt(g-today, v-chetk, v_tar, "bank"). /* проверка задолжности клиента  */
            end. /*end repeat*/
            if v-oplcom = "1" then update v-crck with frame f_main.
            if cif.type = "B" /* значит юр лицо */  and v-crc = 1 then  v_tar = "403".
            if cif.type = "B" /* значит юр лицо */  and v-crc <> 1 then  v_tar = "456".
            if cif.type = "P" /* значит физ лицо */  and v-crc = 1 then  v_tar = "450".
            if cif.type = "P" /* значит физ лицо */  and v-crc <> 1 then  v_tar = "459".
            update v_tar with frame f_main.
            find first tarif2 where tarif2.str5 = trim(v_tar) and tarif2.stat  = "r" no-lock no-error.
            if avail tarif2 then do:
                v_comname = tarif2.pakalp.
                v_kt = tarif2.kont.
                displ v_comname with frame f_main.
            end.
             /* вычисление суммы комиссии-----------------------------------*/
           /* v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
            run perev ("",input v_tar, input v_sum, input v-crc, input v-crck,"", output v-amt, output tproc, output pakal).*/
            v-crctrf = 0. tmin1 = tarif2.min. tmax1 = tarif2.max. v-amt = 0. tproc = tarif2.proc.
            run perev (v-chet,input v_tar, input v_sum, input v-crc, input v-crck,v-cif, output v-amt, output tproc, output pakal).
            v_sumk = v-amt.
           /*------------------------------------------------------------*/
            repeat:
                update v_sumk  with frame f_main.
                if v-amt <> 0 and v_sumk = 0 then undo.
                leave.
            end.
            if keyfunction (lastkey) = "end-error" then undo.
         end.  /* end v_sumk > 0 .........*/

     if substring(v_kbe,2,1) = "7" /* значит юр лицо */ then  v_knp = "311".
     update v_code v_kbe v_knp v_oper v_oper1 v_oper2 v-ja with frame f_main.
     if v-ja then do:
        /*---------------экран клиента-------------------------*/
        find first cmp no-lock no-error.
        find first sysc where sysc.sysc = "CifScr" no-lock no-error.
        if avail sysc then do:
            do i = 1 to num-entries(sysc.chval, "|"):
                if entry(i, sysc.chval, "|") = string(cmp.code) then do:
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
            end.
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
        /*do transaction:*/
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
            if v-ek = 2 then joudoc.dracctype = "4". else joudoc.dracctype = "1".
            if v-ek = 2 then joudoc.dracc = v-chEK. else joudoc.dracc = "".
            joudoc.drcur = v-crc.
            joudoc.cramt = v_sum.
            joudoc.cracctype = "2".
            joudoc.crcur = v-crc.
            joudoc.cracc = v-chet.
            joudoc.comcode = v_tar.
            joudoc.comamt = v_sumk.
            joudoc.comcur = v-crck.
            joudoc.vo = "".
            if v-oplcom = "1" then do:
                if v-ek = 2 then joudoc.comacctype = "4". else joudoc.comacctype = "1".
                if v-ek = 2 then joudoc.comacc = v-chEKk. else joudoc.comacc = "".
            end.
            else do:
                joudoc.comacctype = "2".
                joudoc.comacc = v-chetk.
            end.
            joudoc.info = v_lname .
            if num-entries(trim(v_doc_num),",") > 1 or num-entries(trim(v_doc_num)," ") <= 1 then joudoc.passp = trim(v_doc_num).
            else joudoc.passp = entry(1,trim(v_doc_num)," ") + "," + substring(trim(v_doc_num),index(trim(v_doc_num)," "), length(v_doc_num)).
            joudoc.perkod = v_rnnp.
            joudoc.remark[1] = v_oper.
            joudoc.remark[2] = v_oper1.
            joudoc.rescha[3] = v_oper2.
            joudoc.chk = 0.
            joudoc.benname = v_namek.
            run chgsts("JOU", v-joudoc, "new").
            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            if v-ek = 1 then joudop.type = "CS1". else joudop.type = "EK1".
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
        /* end.*//*end trans-n*/
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
        if joudop.type <> "CS1"  and joudop.type <> "EK1" then do:
            message substitute ("Документ не относится к типу взнос наличных денег на счет клиента ") view-as alert-box.
            return.
        end.
        if v-ek = 1 and joudop.type = "EK1" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            return.
        end.
        if v-ek = 2 and joudop.type = "CS1" then do:
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
    v-chet = joudoc.cracc.
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
    v_doc_num = joudoc.passp.
    v_rnnp = joudoc.perkod.
    if joudoc.comacctype = "1" or joudoc.comacctype = "4"  then v-oplcom1 = "1 - с кассы/ЭК". else v-oplcom1 = "2 - со счета".
    if joudoc.comacctype = "1" or joudoc.comacctype = "4" then v-oplcom = "1". else v-oplcom = "2".

    find first tarif2 where tarif2.str5 = trim(v_tar)  and tarif2.stat  = "r" no-lock no-error.
    if avail tarif2 then do:
        v_comname = tarif2.pakalp.
        v_kt = tarif2.kont.
     end.
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
    v_title = " Взнос наличных денег на счет клиента ".
    displ v-joudoc v_trx v-chet v_namek v-label v_rnn v-crc v_sum v_lname  v_doc_num  v-labelp v_rnnp v-oplcom1 v-chetk v-crck v_tar
    v_comname v_sumk v_code v_kbe v_knp  v_oper v_oper1 v_oper2 with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = " Взнос наличных денег на счет клиента ".
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
    v_title = "  Взнос наличных денег на счет клиента".
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
    find first cif where cif.cif = v-cif no-lock.

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
        v-tmpl = "JOU0046".
       /* формир v-param для trxgen.p */
        v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-chEK + vdel + v-chet + vdel +
                    (v_oper + v_oper1 + v_oper2) + vdel + substring(v_code,1,1)
                    + vdel + substring(v_code,2,1) + vdel + v_knp + vdel + string(v_sum).
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode <> 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
         /* заблокируем сумму пополнения  до контроля --------------------------------------------------*/

         create aas.

         find last aas_hist where aas_hist.aaa = v-chet no-lock no-error.
         if available aas_hist then aas.ln = aas_hist.ln + 1. else aas.ln = 1.

         aas.sic = 'HB'.
         aas.chkdt = g-today.
         aas.chkno = 0.
         aas.chkamt  = v_sum.
         aas.payee = 'Пополнение счета клиента через ЭК 100500 |' + TRIM(STRING(s-jh, "zzzzzzzzzz9")) .
         aas.aaa = v-chet .
         aas.who = g-ofc.
         aas.whn = g-today.
         aas.regdt = g-today.
         aas.tim = time.

         if aas.sic = 'HB' then do:
             find first aaa where aaa.aaa = v-chet exclusive-lock.
             if avail aaa then do:
                run savelog("aaahbal", "a_cas1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
                aaa.hbal = aaa.hbal + aas.chkamt.
             end.
         end.

         FIND FIRST ofc WHERE ofc.ofc = g-ofc NO-LOCK no-error.
         if avail ofc then do:
           aas.point = ofc.regno / 1000 - 0.5.
           aas.depart = ofc.regno MODULO 1000.
         end.

         CREATE aas_hist.

         find first aaa where aaa.aaa = v-chet no-lock no-error.
         IF AVAILABLE aaa THEN DO:
            FIND FIRST cif WHERE cif.cif= v-cif USE-INDEX cif NO-LOCK NO-ERROR.
            IF AVAILABLE cif THEN DO:
               aas_hist.cif= cif.cif.
               aas_hist.name= trim(trim(cif.prefix) + " " + trim(cif.name)).
            END.
         END.

         aas_hist.aaa= aas.aaa.
         aas_hist.ln= aas.ln.
         aas_hist.sic= aas.sic.
         aas_hist.chkdt= aas.chkdt.
         aas_hist.chkno= aas.chkno.
         aas_hist.chkamt= aas.chkamt.
         aas_hist.payee= aas.payee.
         aas_hist.expdt= aas.expdt.
         aas_hist.regdt= aas.regdt.
         aas_hist.who= aas.who.
         aas_hist.whn= aas.whn.
         aas_hist.tim= aas.tim.
         aas_hist.del= aas.del.
         aas_hist.chgdat= g-today.
         aas_hist.chgtime= time.
         aas_hist.chgoper= 'A'.
         release aas.
         release aas_hist.

        /*----------------------------------------------------------*/
       /* для комиссии--------------------------------------------*/
        if v_sumk <> 0 then do:
            if v-oplcom  = "1" then do:  /* комиссия с ЭК 100500      */
                v-tmpl = "jou0053".
                v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v-crck) + vdel + v-chEKk + vdel + string(v_kt) + vdel + "Комиссия за " + v_comname + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
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
        if v-crc = 1 and v-crck = 1 then joudoc.srate = 1.
        else do:
            if v-crc = 1 then find first crc where  crc.crc = v-crck no-lock no-error.
            else find first crc where  crc.crc = v-crc no-lock no-error.
            joudoc.srate = crc.rate[3].
            joudoc.sn = 1.
        end.
        joudoc.brate = 1.
        find current joudoc no-lock no-error.
        run chgsts(m_sub, v-joudoc, "trx").


    end. /* end v-ek = 2  */

    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
            v-tmpl = "JOU0004".
         /* формир v-param для trxgen.p */
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-chet + vdel +
                        (v_oper + v_oper1 + v_oper2) + vdel + substring(v_code,1,1)
                        + vdel + substring(v_code,2,1) + vdel + v_knp + vdel + string(v_sum).
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
                    v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v-crck) + vdel + string(v_kt) + vdel + "Комиссия за(пополнение счета) " + v_comname + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1).
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                end.
                else run comis_chet.   /* комиссия со счета  */
            end.
            find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
            joudoc.jh = s-jh.
            find current joudoc no-lock no-error.
            run chgsts(m_sub, v-joudoc, "trx").
    end.  /* end v-ek = 1 ---------*/
    /*---------------------------------------------------------*/
    pause 1 no-message.
    find first aas where aas.aaa = joudoc.cracc no-lock no-error.
    if avail aas then do:
        find first crc where crc.crc = joudoc.crcur no-lock no-error.
        if avail crc then do:
            find first cif where cif.cif = aas.cif no-lock no-error.
            if avail cif then do:
                for each sysc where sysc.sysc = "bnkadr" no-lock:
                    run mail(entry(5, sysc.chval, "|"), "BANK <abpk@metrocombank.kz>",
                    "Поступление средств на заблокированный счет",
                    "На заблокированный счет " + v-chet + " поступила сумма  " + string(joudoc.cramt) + " " + crc.code + ", " +
                     v-cif + ", " + v_namek, "", "", "").
                    hide all.
                    view frame f_main.
                end.
            end.
        end.
    end.
    /* копируем заполненные данные по ФМ в реальные таблицы*/
    if v-kfm then do:
        run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
        hide all.
        view frame f_main.
    end.
    /**/
    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.
    v_trx = s-jh.
    display v_trx with frame f_main.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if v-ek = 1 then do:
        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
        run chgsts("jou", v-joudoc, "cas").
    end.

        if v-crc = 1  then do:
            find first jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = 100100 or jl.gl = 100500) no-lock no-error.
            if avail jl then do:
                find first aaa where aaa.aaa = v-chet no-lock no-error.
                if avail aaa /*and v_sumk = 0*/ then do:
                    if aaa.gl = 287080 then do:
                        run x0-cont1.
                        hide all no-pause.
                    end.
                    else do:
                        if lookup(string(aaa.gl),"220620,220720,220420") <> 0 then do:
                            create jlsach .
                            jlsach.jh = s-jh.
                            if jl.dc = "d" then jlsach.amt = jl.dam .
                                           else jlsach.amt = jl.cam .
                            jlsach.ln = jl.ln .
                            jlsach.lnln = 1.
                            jlsach.sim = 020 .
                        end.

                        else if lookup(string(aaa.gl),"221510,221710,221910") <> 0 then do:
                            create jlsach .
                            jlsach.jh = s-jh.
                            if jl.dc = "d" then jlsach.amt = jl.dam .
                                           else jlsach.amt = jl.cam .
                            jlsach.ln = jl.ln .
                            jlsach.lnln = 1.
                            jlsach.sim = 100 .
                        end.
                        else if lookup(string(aaa.gl),v-chk1) <> 0 then do:
                            create jlsach .
                            jlsach.jh = s-jh.
                            if jl.dc = "d" then jlsach.amt = jl.dam .
                                           else jlsach.amt = jl.cam .
                            jlsach.ln = jl.ln .
                            jlsach.lnln = 1.
                             vv-crc = getcrc(jl.crc).
                            displ jl.ln vv-crc jlsach.amt with frame frm123.
                            display '<Enter> - изменить,<F9> - добавить,<F10> - удалить,<F2>-помощь,<F4>-выход ' with row 22 centered no-box.
                            update v_sim with frame frm123.
                            jlsach.sim = v_sim.
                            hide all no-pause.
                        end.
                    end.
                    release jlsach.
                end.
            end.
        hide all no-pause.
        end.

        if v-crck = 1  and v_sumk <> 0 and v-oplcom = "1" then do:
            find last jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = 100100 or jl.gl = 100500) no-lock no-error.
            if avail jl then do:
                create jlsach .
                jlsach.jh = s-jh.
                if jl.dc = "d" then jlsach.amt = jl.dam .
                               else jlsach.amt = jl.cam .
                jlsach.ln = jl.ln .
                jlsach.lnln = 1.
                jlsach.sim = 100 .
            release jlsach.
            end.
        hide all no-pause.
        end.
        view frame f_main.

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
    ss-jh = joudoc.jh.

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
            /* удаление сумм записанных в долг */
            for each bxcif where bxcif.cif = v-cif and bxcif.jh = v_trx exclusive-lock.
                delete bxcif.
            end.

        end.

        joudoc.jh   = ?.
        v_trx = ?.
        display v_trx with frame f_main.


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
    /* удаляем спец инструкции----------------------------------------------*/
    def var v-payee1 as char.

    v-payee1 = "Пополнение счета клиента через ЭК 100500 |" + TRIM(STRING(ss-jh, "zzzzzzzzzz9")).
    find aas where aas.aaa = v-chet and aas.payee = v-payee1 and aas.chkamt = v_sum exclusive-lock no-error.
    if  avail aas then do:
       find aaa where aaa.aaa = v-chet exclusive-lock no-error.
       if avail aaa then do:
           for each aas_hist where aas_hist.aaa = aas.aaa and
                                   aas_hist.ln = aas.ln and
                                   aas_hist.chkamt = aas.chkamt and
                                   aas_hist.payee = aas.payee:
              delete aas_hist.
           end.

           run savelog("aaahbal", "a_cas1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
           aaa.hbal = aaa.hbal - aas.chkamt.
           delete aas.
           release aaa.
        end.
    end.
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

        s-jh = joudoc.jh.
        run vou_word (2, 1, joudoc.info).
end procedure.

procedure print_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

        s-jh = joudoc.jh.
    /*run vou_bankt(2, 1, joudoc.info).*/
    if v-noord = no then run vou_bankt(2, 1, joudoc.info).
    else run printord(s-jh,"").
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
            wupl.finday = uplcif.finday.
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
         wheir.ratio  = cif-heir.ratio.
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
                 wheir.jss    label 'ИИН' format 'x(12)'
                 wheir.ratio  label 'Доля' format 'x(10)'
               "
    &chkey = "id"
    &chtype = "integer"
    &index  = "main"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
  v-fio    = wheir.fio.
  v-idcard = wheir.idcard.
  v-jssh   = wheir.jss.
end procedure.

procedure comis_chet.  /* комиссия с счета   */
    find first aaa where aaa.aaa = v-chetk no-lock no-error.
    if v_sumk > aaa.cbal - aaa.hbal then do:
        MESSAGE "На выбранном счете недостаточно средств, ~nсумма комиссии запишется в долг" VIEW-AS  ALERT-BOX.
       /* проводка комиссии сформируется после акцепта кассира, когда сумма пополнения счета поступит на счет .
        см. программу x1-cash.p */
        v-tmpl = "JOU0026".
        v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v-crck) + vdel + v-chetk + vdel + string(v_kt) + vdel +
                    "Комиссия за " + v_comname.
        repeat:
            if index (v-param, "&") <= 0 then leave.
            if index (v-param, "&") > 0 then do:
              v-param = substring(v-param,1,index(v-param,"&") - 1) + substring(v-param,index(v-param,"&") + 1,(length(v-param) - index(v-param,"&"))).
            end.
        end.
        find first joudoc where joudoc.docnum = v-joudoc exclusive-lock no-error.

        if available joudoc then joudoc.vo = v-tmpl + "&" + v-param + "&" + "cif" + "&" + v-joudoc. /* в данном поле сохраняем параметры для транзакции проводки комиссии*/
        else do:
            message "jou документ не найден".
            pause.
            undo, return.
        end.
        find current joudoc no-lock no-error.
    end.
    else do:
        v-tmpl = "jou0026".
     /* формир v-param для trxgen.p */
        v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v-crck) + vdel + v-chetk + vdel + string(v_kt) + vdel + "Комиссия за(пополнение счета) " + v_comname.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
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
    run a_stamp(joudoc.jh).
    pause 0.
    hide all.
    view frame f_main.
end.
