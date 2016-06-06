/* a_foreign3.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        отмена перевода без открытия счета.
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
        06/02/2012 Luiza  -  добавила процедуру a_subcod
        08/02/2012 Luiza  -  добавила вывод номера документа
        09/02/2012 Luiza  -  отменила поиск crc по v_crck, так как комиссии нет
        17.02.2012  Lyubov - зашила символы кассплана согласно ТЗ № 1268
        07/03/2012 Luiza  - изменила передачу параметров при вызове printord
        11.03.2012 damir - добавил печать оперционного ордера, printvouord.p.
        19/03/2012 Luiza  - если тестовая база клиента finmon не вызываем
        20/03/2012 Luiza  - вызов функции isProductionServer выполняем в a_fimnon.i
        10/04/2012 Luiza  - изменила рассылку сообщений
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        24/04/2012 luiza - изменила создание мини карточки
        03/05/2012 Luiza  - добавила поле срок действия УЛ
        14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
        15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
        28/06/2012 Luiza  - изменила формат для вывода на эран номера транзакции
        25/072012  Luiza   - изменила проверку суммы при работе с EK
        26/07/2012 Luiza   - слово EK заменила ЭК
        10/09/2012 Luiza подключила {srvcheck.i}
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        23.11.2012 Lyubov - ТЗ № 1573, изменила список видов документов, увеличина кол-во строк для b-doc
        11/03/2012 Luiza - ТЗ 1623 проверка контрольного разряда ИИН
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        05/04/2013 Luiza -  ТЗ № 1764 проверка признака блокирования валют при обменных операциях
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        22/10/2013 Luiza - ТЗ 2003 конвертация при выплате перевода
*/
{global.i}
{adres.f}
define input parameter new_document as logical.
define variable m_sub           as character initial "jou".
def var v-tmpl as char no-undo.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var vparam as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
define new shared variable s-jh like jh.jh.
def shared var v_u as int no-undo.
def  var v_dt as int no-undo init 287032.
def  var v_kt as int no-undo .
def  var v_dtk as int no-undo.
def  var v_ktk as int no-undo init 460122.
def  var v_codfr as char format "x(1)" init "1".
def  var v_title as char no-undo. /*наименование платежа */
def  shared var v-joudoc as char no-undo format "x(10)".
def shared var v-Get_Nal as logic.
def var v-cur as logic no-undo.

def  var v_doc as char no-undo format "x(10)".
def  var v-joudock as char no-undo format "x(10)".
def  var v_rnn as char no-undo format "x(12)".
def  var v_iin as char no-undo format "x(12)".
def  var v_lname as char no-undo format "x(20)".
def  var v_name as char no-undo format "x(20)".
def  var v_mname as char no-undo format "x(20)".
def  var v_lname1 as char no-undo format "x(20)".
def  var v_name1 as char no-undo format "x(20)".
def  var v_mname1 as char no-undo format "x(20)".
def  var  v_rez as char no-undo format "x(2)".
def  var v_country as char no-undo format "x(20)".
def  var v_country1 as char no-undo format "x(20)".
def  var v_countr as char no-undo format "x(2)".
def  var v_countr1 as char no-undo format "x(2)".
def  var v_doctype as char no-undo.
def  var v_doc_num as char no-undo.
def  var  v_docwho as char no-undo.
def  var v_docdt as date no-undo.
def  var v_docdtf as date no-undo.
def  var v_addr as char no-undo format "x(75)".
def  var v_tel as char no-undo format "x(27)".
def  var v_oper as char no-undo format "x(50)".
def  var v_oper1 as char no-undo format "x(50)".
def  var v_public as char no-undo. /* признак ИПДЛ */
def  var v_knp as char no-undo init "119".
def  var v_rez1 as char no-undo.
def  var v_crc as int  no-undo format "9".
def  var v_sum as decimal no-undo.
def  var v_sum_lim as decimal no-undo. /* сумма*/
def  var v_sumv as decimal no-undo format ">>>,>>>,>>>,>>>,>>9.99".
def  var v_sumt as decimal no-undo format ">>>,>>>,>>>,>>>,>>9.99".
def  var v_sumt1 as decimal no-undo format ">>>,>>>,>>>,>>>,>>9.99".

def  var v_crck as int format "9".
def  var v_sumk as decimal no-undo.
def  var v_arp as char no-undo.
def  var v_arp1 as char no-undo.
def  var v-ja as logi no-undo format "Да/Нет" init yes.
def  var v-label as char no-undo.
def  var vj-label as char no-undo.
def  var v-cifmin as char no-undo.
def  var v-bplace as char no-undo.
def  var v-bdt1 as date no-undo.

def  var v_comcode as char no-undo format "x(3)" init "424".
def new shared var com_rec as recid.
def  var v-length as int.
def  var v-benName as char no-undo.
def var v_trx as int no-undo.
define variable jou_p as character NO-UNDO.
define variable yn as logical no-undo.
define variable com_tmpl as character NO-UNDO.
define variable contrl  as logical no-undo.
def var vdummy as char no-undo.
def var templ-com as char no-undo.
def var v-tarif as char no-undo.
define variable v-cash   as logical no-undo.
define variable v-acc   as logical no-undo.
define variable v-sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
define variable m_buy   as decimal.
define variable m_sell  as decimal.
def var v_rate as decim.
def var v_rate1 as decim.
def var v_bn as int.
def var v_sn as int.
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
def var v-country22 as char.
define button but label " "  NO-FOCUS.


def var v_joutrx as int.
def var v_jouktrx as int.

def var v_bnk as char.
/*def var v_dep as int format "99".*/

/* для комиссии*/
def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.
def var famlist as char init "".
def var I as int init 0.
def var v_arpname as char format "x(30)".
def var v-int as decim.
def var v-mod as decim.
def var v-modc as decim.
def var v-int1 as decim.
def var v-mod1 as decim.
def var v-modc1 as decim.
def var v_sum1 as decim.

/* screen    */
def shared var v-res111 as char.
def var TCIFNAME as char.
def var TINN as char.
def var TKOD as char.
def var TSUMM as char.
def var TCRC as char.
def var TCOMSUMM as char.
def var TCOMCRC as char.
def var TREM as char.
def var TKNP as char.
def var TRECAAA as char.
def var TRECNAME as char.
def var TRECINN as char.
def var TKBE as char.
def var TRBANK as char.
def var sr-ans as logic.

{yes-no.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */
{comm-txb.i}
{get-dep.i}
{findstr.i}
{kfm.i "new"}
{keyord.i}
{to_screen.i}

if v-ek = 2 then do:
    find first codfr where codfr.codfr = 'ekcrc' no-lock no-error.
    if not avail codfr then do:
        message "В справочнике <codfr> отсутствует код <ekcrc> для определения допустимых валют при работе с ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
        return.
    end.
end.

{srvcheck.i}

def var v-knpval as char no-undo.
v-knpval = "119".
/*------------------------*/

def buffer b-sysc for sysc.
v_bnk = trim(sysc.chval).
/*find first ppoint no-lock no-error.
cbo_dep = ppoint.dep.*/
/* для Almaty определяем сп
v_dep = 1.
if v_bnk = "TXB16" then do:
    find last ofchis where ofchis.ofc = g-ofc and ofchis.regdt <= g-today use-index ofchis no-lock no-error.
    if avail ofchis then v_dep = ofchis.depart. else v_dep = 1.
end.*/

define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.

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

def var v-bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.

if v-bin  then v-label = " ИИН             :". else v-label = " РНН             :".
def temp-table tmprez
    field des as char.
    create tmprez. tmprez.des = "19-(физ.лицо/резидент)".
    create tmprez. tmprez.des = "29-(физ.лицо/нерезидент)".

def temp-table tmpdoc
    field code as int
    field des as char.
    create tmpdoc. tmpdoc.code = 19. tmpdoc.des = "01-Удостов. личности гражданина РК".
    create tmpdoc. tmpdoc.code = 19. tmpdoc.des = "02-Паспорт гражданина РК".
    create tmpdoc. tmpdoc.code = 19. tmpdoc.des = "04-Вид на жительство иностраца в РК".
    create tmpdoc. tmpdoc.code = 19. tmpdoc.des = "05-Удостов. лица без гражданства".
    create tmpdoc. tmpdoc.code = 29. tmpdoc.des = "03-Паспорт иностранного госуд-ва".
    /*create tmpdoc. tmpdoc.code = 29. tmpdoc.des = "04-Вид на жительство иностраца в РК".
    create tmpdoc. tmpdoc.code = 29. tmpdoc.des = "05-Удостов. лица без гражданства".*/
{chk12_innbin.i}
form
    v-joudoc    label " Документ" format "x(10)"  skip
                     "           ПОЛУЧАТЕЛЬ"
                     "                                           ОТПРАВИТЕЛЬ" SKIP
    v-label v_rnn  no-label format "x(12)" validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН')
    v_lname1    label "                       Фамилия         " format "X(20)" validate(trim(v_lname1) <> "", "Заполните фамилию") skip

    v_lname     label " Фамилия          " format "X(20)"  validate(trim(v_lname) <> "", "Заполните фамилию")
    v_name1     label "              Имя             " format "X(20)" validate(trim(v_name1) <> "", "Заполните имя") skip

    v_name      label " Имя              " format "X(20)"  validate(trim(v_name) <> "", "Заполните имя")
    v_mname1    label "              Отчество        " format "X(20)" skip

    v_mname     label " Отчество         " format "X(20)"
    v_rez1      label "              Резиденство     " validate(v_rez1 = "19" or v_rez1 = "29", "19-(физ.лицо/резидент), 29-(физ.лицо/нерезидент), F2-помощь") format "x(2)"skip

    v_rez       label " Резидентство     " validate(v_rez = "19" or v_rez = "29", "19-(физ.лицо/резидент)  29-(физ.лицо/нерезидент), F2-помощь") format "x(2)"
    v_countr1   label "                        Страна отправления      " validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_countr1 no-lock), "Нет такого кода страны! F2-помощь") format "x(2)" skip
     /*v_country1  label "  Страна"  format "x(15)" skip */
    v_countr   label " Код страны       " validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_countr no-lock), "Нет такого кода страны! F2-помощь") format "x(2)" skip
    v_doctype  label " Вид документа    " validate((v_rez = "19" and lookup(substring(trim(v_doctype),1,2),"01,02,04,05") > 0) or (v_rez = "29"
                                        and lookup(substring(trim(v_doctype),1,2),"03") > 0),"Не правильный вид документа, F2-помощь" )  format "x(30)" skip
    v_doc_num  label " Номер документа  " help "Введите номер докумета удостов. личность" format "x(10)" validate(trim(v_doc_num) <> "", "Заполните номер документа") skip
    v_docwho   label " Выдан            " help " Кем выдан документ удостов. личность"  format "x(20)" validate(trim(v_docwho) <> "", "Заполните кем выдан документ") skip
    v_docdt    label " Дата выдачи      " format "99/99/9999" help " Ведите дату выдачи документа удостов. личость в формате дд/мм/гггг " validate(trim(v_docdt) <> "", "Заполните дату выдачи документа") skip
    v_docdtf   label " Срок действия    " format "99/99/9999" help " Ведите срок действия документа удостов. личость в формате дд/мм/гг " /*validate(trim(v_docdtf) <> "", "Заполните срок действия документа")*/ skip
    v_public   label " Принадл к ИПДЛ   "  format "x(1)"  help '1-не является 2- является 3-Аффилир. с иност. публич.' validate(can-find (codfr where codfr.codfr = 'publicf' and codfr.code = v_public no-lock),'Неверный признак! 1-не является 2- является 3-Аффилир. с иност. публич.') skip
    v-bdt1     label ' Дата рождения    '  format "99/99/9999" validate(v-bdt1 <> ?,'Введите дату!') skip
    v-bplace   label ' Место рождения   '  format "x(40)" validate(trim(v-bplace) <> '','Введите место рождения!') skip
    v_addr     label " Адрес            " help "Адрес проживания" validate(trim(v_addr) <> "", "Заполните адрес проживания") skip
    v_tel      label " Телефон          " help "Введите номер телефона" skip
    v_oper     label " Назнач. платежа  "   format "x(70)" skip
    /*v_oper1    no-label format "x(50)" colon 19 skip*/
    v_crc      label " Валюта перевода  " help "Введите код валюты, F2-помощь" format ">9" validate(can-find(first crc where crc.crc = v_crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
    v_sum      label " Сумма перевода   " help " Введите сумму перевода" validate(v_sum > 0,"Проверьте значение суммы!") format ">>>,>>>,>>>,>>>,>>9.99" skip
    v_knp      label " КНП              " format "999"
    v_sumv     label " Сумма выплаты в валюте" colon 75 help " Введите сумму выплаты в валюте" validate(v_sumv <= v_sum,"Не может быть больше суммы перевода!") format ">>>,>>>,>>>,>>>,>>9.99"  skip
    v_sumt     label " Сумма выплаты в тенге "  colon 75 format ">>>,>>>,>>>,>>>,>>9.99"  skip

                     "                               ДАННЫЕ ПРОВОДКИ ПЕРЕВОДА " but skip
    v_dt       label " Дебет Г/К  "
    v_joutrx    label "Проводка " colon 60 skip
    v_arp      label " АРП (Дт)   " format "x(20)"  v_arpname no-label colon 45 skip
    v_kt       label " Кредит Г/К " skip
    vj-label no-label v-ja no-label
WITH  SIDE-LABELS column 3 row 2 TITLE v_title width 100 FRAME f_main.

DEFINE QUERY q-rez FOR tmprez.
DEFINE BROWSE b-rez QUERY q-rez
       DISPLAY tmprez.des label "Резидентство " format "x(30)" WITH  3 DOWN.
DEFINE FRAME f-rez b-rez  WITH overlay 1 COLUMN SIDE-LABELS row 12 COLUMN 40 width 45 NO-BOX.

DEFINE QUERY q-doc FOR tmpdoc.
DEFINE BROWSE b-doc QUERY q-doc
       DISPLAY tmpdoc.des label "Тип документа " format "x(35)" WITH  5 DOWN.
DEFINE FRAME f-doc b-doc  WITH overlay 1 COLUMN SIDE-LABELS row 14 COLUMN 40 width 50 NO-BOX.

DEFINE QUERY q-country FOR codfr.
DEFINE BROWSE b-country QUERY q-country
       DISPLAY codfr.code label "Код " format "x(3)" codfr.name[1] label "Наименование " format "x(30)"  WITH  10 DOWN.
DEFINE FRAME f-country b-country  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 40 width 50 NO-BOX.

define frame f-iin v_iin label "ИИН" format "x(12)" validate(length(v_iin) = 12 or trim(v_iin) = "-", "Длина меньше 12 знаков") help "Введите БИН" with overlay SIDE-LABELS row 8 column 20  width 30.

on help of v_rez in frame f_main do:
    OPEN QUERY  q-rez FOR EACH tmprez no-lock.
    ENABLE ALL WITH FRAME f-rez.
    wait-for return of frame f-rez
    FOCUS b-rez IN FRAME f-rez.
    v_rez = substring(tmprez.des,1,2).
    hide frame f-rez.
    displ v_rez with frame f_main.
end.
on help of v_rez1 in frame f_main do:
    OPEN QUERY  q-rez FOR EACH tmprez no-lock.
    ENABLE ALL WITH FRAME f-rez.
    wait-for return of frame f-rez
    FOCUS b-rez IN FRAME f-rez.
    v_rez1 = substring(tmprez.des,1,2).
    hide frame f-rez.
    displ v_rez1 with frame f_main.
end.
on help of v_doctype in frame f_main do:
    OPEN QUERY  q-doc FOR EACH tmpdoc where tmpdoc.code = integer(v_rez) no-lock.
    ENABLE ALL WITH FRAME f-doc.
    wait-for return of frame f-doc
    FOCUS b-doc IN FRAME f-doc.
    v_doctype = tmpdoc.des.
    hide frame f-doc.
    displ v_doctype with frame f_main.
end.
on help of v_countr in frame f_main do:
    OPEN QUERY  q-country FOR EACH codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc"  no-lock.
    ENABLE ALL WITH FRAME f-country.
    wait-for return of frame f-country
    FOCUS b-country IN FRAME f-country.
    v_countr = codfr.code.
    /*v_country = codfr.name[1]. */
    hide frame f-country.
    displ v_countr  with frame f_main.
end.
on help of v_countr1 in frame f_main do:
    OPEN QUERY  q-country FOR EACH codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc" no-lock.
    ENABLE ALL WITH FRAME f-country.
    wait-for return of frame f-country
    FOCUS b-country IN FRAME f-country.
    v_countr1 = codfr.code.
   /*v_country1 = codfr.name[1].*/
    hide frame f-country.
    displ v_countr1 with frame f_main.
end.

on help of v_crc in frame f_main do:
    run help-crc1.
end.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("FR3"). else run a_help-joudoc1 ("RF3").
    v-joudoc = frame-value.
end.

on help of v_public in frame f_main do:
    {itemlist.i
    &file = "codfr"
    &frame = "row 6 centered scroll 1 20 down overlay width 91 "
    &where = " codfr.codfr = 'publicf' "
    &flddisp = " codfr.code label 'Код' format 'x(8)' codfr.name[1] label 'Значение' format 'x(80)' "
    &chkey = "code"
    &index  = "cdco_idx"
    &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v_public = codfr.code.
    display v_public with frame f_main.
end.

on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
on "END-ERROR" of frame f-country do:
  hide frame f-country no-pause.
end.
on choose of but in frame  f_main do:
end.

if v-ek = 1 then v_kt = 100100. else v_kt = 100500.

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = " ПЕРЕВОДЫ  БЕЗ ОТКРЫТИЯ СЧЕТА (отмена перевода)".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    do transaction:
        v_oper = "Материальная помощь(отмена перевода) ".
        displ v-joudoc v-label format "x(18)" no-label with frame f_main.
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */

else do:   /* редактирование документа   */
    v_title = "ПЕРЕВОДЫ  БЕЗ ОТКРЫТИЯ СЧЕТА (отмена перевода) ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            v_title = " ПЕРЕВОДЫ  БЕЗ ОТКРЫТИЯ СЧЕТА (отмена перевода)".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                    if joudop.type <> "FR3" and joudop.type <> "RF3" then do:
                        message substitute ("Документ не относится к типу отмена перевода") view-as alert-box.
                        return.
                    end.
                    if v-ek = 1 and joudop.type = "RF3" then do:
                        message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                        return.
                    end.
                    if v-ek = 2 and joudop.type = "FR3" then do:
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
    update v_rnn no-label with frame f_main.
    if new_document then do:
        clear frame f_main.
        v-cifmin = "". v_rez = "". v_iin = "".
        v_lname = "". v_name = "". v_mname = "". v_rez = "". v_countr = "". v_doctype = "". v_doc_num = "".
        v_docwho = "". v_docdtf = ?.  v_docdt = ?. v_public = "".  v-bplace = "".  v-bdt1 = ?. v_addr = "". v_tel = "".
        v_lname1 = "". v_name1 = "". v_mname1 = "". v_rez1 = "". v_countr1 = "". v_crc = 0. v_sum = 0. v_crck = 0.
        displ v-joudoc with frame f_main.
        pause 0.
    end.
    if trim(v_rnn) <> "-" then do:
        if v-bin = no then do:
            find last cifmin where cifmin.rnn = v_rnn no-lock no-error.
            if available cifmin then do:
                v_iin = cifmin.iin.
                update v_iin with frame f-iin.
             end.
        end.
        if v-bin then find last cifmin where cifmin.iin = v_rnn no-lock no-error.
        else find last cifmin where cifmin.rnn = v_rnn no-lock no-error.
        if available cifmin then do:
            v-cifmin = cifmin.cifmin.
            v_lname = cifmin.fam.
            v_name = cifmin.name.
            v_mname = cifmin.mname.
            v_doctype = cifmin.doctype.
            v_doc_num = cifmin.docnum.
            v_docdt = cifmin.docdt.
            v_docdtf = cifmin.docdtf.
            v_docwho = cifmin.docwho.
            v_public = cifmin.publicf.
            v_countr = cifmin.public.
            v_docwho = cifmin.docwho.
            v_addr = cifmin.addr.
            v-adres = v_addr.
            v_tel = cifmin.tel.
            v-bdt1 = cifmin.bdt.
            v-bplace = cifmin.bplace.
            if cifmin.res = "1" then v_rez = "19". else v_rez = "29".
        end.
        else do:
            if v-bin then find first rnn where rnn.bin = v_rnn no-lock no-error.
            else find first rnn where rnn.trn = v_rnn no-lock no-error.
            if available rnn then do:
                if not v-bin then do:
                    v_iin = rnn.bin.
                    update v_iin with frame f-iin.
                end.
                v_lname = rnn.lname.
                v_name = rnn.fname.
                v_mname = rnn.mname.
                v_doctype = "".
                v_doc_num = rnn.nompas.
                v_docdt = rnn.datepas.
                v_docdtf = ?.
                v_docwho = rnn.orgpas.
                v_addr = trim(rnn.dist1) + "," + trim(rnn.raj1) + "," + trim(rnn.city1) + "," + trim(rnn.street1) + "," + trim(rnn.housen1) + "," + trim(rnn.apartn1).
                v_tel = trim(rnn.citytel) + "," + trim(rnn.humtel).
            end.
            else clear frame f_main.
        end.
        displ v-label v_rnn   with frame f_main.
        update v_lname v_name v_mname v_rez with frame f_main.
    end.
    else do:
        clear frame f_main.
        update v_lname with frame f_main.
        v-cifmin = "".
        run ciffind(input v_lname, output v-cifmin).
        find last cifmin where cifmin.cifmin = v-cifmin no-lock no-error.
        if available cifmin then do:
            v_iin = cifmin.iin.
            v_lname = cifmin.fam.
            v_name = cifmin.name.
            v_mname = cifmin.mname.
            v_doctype = cifmin.doctype.
            v_doc_num = cifmin.docnum.
            v_docdt = cifmin.docdt.
            v_docdtf = cifmin.docdtf.
            v_docwho = cifmin.docwho.
            v_public = cifmin.publicf.
            v_countr = cifmin.public.
            v_docwho = cifmin.docwho.
            v_addr = cifmin.addr.
            v-adres = v_addr.
            v_tel = cifmin.tel.
            v-bdt1 = cifmin.bdt.
            v-bplace = cifmin.bplace.
            if cifmin.res = "1" then v_rez = "19". else v_rez = "29".
            /*update v_iin with frame f-iin.*/
            displ v-joudoc v-label v_rnn  v_lname v_name v_mname v_rez v_lname with frame f_main.
        end.
        else do:
            /*v_iin = "".
            update v_iin with frame f-iin.*/
            update v_name v_mname v_rez with frame f_main.
        end.
    end.
    /*if v_rez = "19" then do:
        v_countr = "KZ".
        displ v_countr with frame f_main.
        update   v_doctype help " Вид документа удостовер. личность, F2-помощь " v_doc_num v_docwho v_docdt v_docdtf v_public v-bdt1 v-bplace  with frame f_main.
    end.
    else do:*/
        if v_rez = "19" and v_u <> 2 then v_countr = "KZ".

        update  v_countr with frame f_main.
        find first stoplist where stoplist.code = v_countr no-lock no-error.
        if avail stoplist and stoplist.sts <> 9 then do:
            message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
            return.
        end.
        update v_doctype help " Вид документа удостовер. личность, F2-помощь " v_doc_num v_docwho v_docdt v_docdtf v_public v-bdt1 v-bplace  with frame f_main.
    /*end.
    repeat:
        if v_rez = "29" and v_countr = "KZ" then message "По получателю неправильный код страны или код резидентства" view-as alert-box.
        else leave.
        update v_countr with frame f_main.
    end.*/
    if v-cifmin = "" then do:
        if v_countr = "kz" then v-adres = "КАЗАХСТАН (KZ),,,,,,".
        else  do:
            find first codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc" and  codfr.code = v_countr no-lock no-error.
            if available codfr then v-adres = codfr.name[1] + " (" + v_countr + "),,,,,,". else v-adres = "(" + v_countr + "),,,,,,".
        end.
    end.
    {adres.i}
    v_addr = v-adres.
    displ v_addr  v_knp with frame f_main.
    update v_tel v_oper /*v_oper1*/ with frame f_main.
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
    if keyfunction (lastkey) = "end-error" then undo.
    update v_sum with frame f_main.
    if v-ek = 2 then do:
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

    v_lname1 = v_lname.
    v_name1 = v_name.
    v_mname1 = v_mname.
    v_rez1 = v_rez.
    v_countr1 = v_countr.
    displ v_lname1 v_name1 v_mname1 v_rez1 v_countr1 with frame f_main.

    if v-ek = 2 then run chksum.  /* расчет суммы внесения  */
    if v-cur then undo, return.

    for each arp where arp.gl = v_dt and arp.crc = v_crc and length(arp.arp) >= 20 and arp.des MATCHES "*исх*" and not arp.des  MATCHES "*СП*" no-lock.
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.ccode = "msc" no-lock no-error.
        if avail sub-cod then v_arp = arp.arp.
    end.
    if  v_arp <> ""  then do:
        find first arp where arp.arp = v_arp no-lock.
        v_arpname = arp.des.
        find first arp no-lock no-error.
        displ v_dt format "999999" v_arp v_arpname v_kt format "999999"  with frame f_main.
    end.
    else do:
        message "ARP счет дебета не найден, продолжение невозможно!" view-as alert-box.
        undo.
    end.
    displ vj-label format "x(35)" no-label with frame f_main.
    pause 0.
    update v-ja no-label with frame f_main.
    if v-ja then do:
        if v-cifmin = "" then do:
            create cifmin.
            cifmin.cifmin = 'cm' + string(next-value(cmnum),'99999999').
            v-cifmin = cifmin.cifmin.
            cifmin.rwho = g-ofc.
            cifmin.rwhn = g-today.
        end.
        else do:
            find last cifmin where cifmin.cifmin = v-cifmin exclusive-lock no-error.
            if not available cifmin or trim(cifmin.fam) <> trim(v_lname) or trim(cifmin.name) <> trim(v_name) or
                trim(cifmin.mname) <> trim(v_mname) or cifmin.bdt <> v-bdt1 or trim(v_doc_num) <> trim(cifmin.docnum) then do:
                create cifmin.
                cifmin.cifmin = 'cm' + string(next-value(cmnum),'99999999').
                v-cifmin = cifmin.cifmin.
                cifmin.rwho = g-ofc.
                cifmin.rwhn = g-today.
            end.
        end.
        if v-bin = no then do: cifmin.iin = v_iin. cifmin.rnn = v_rnn. end.
        else cifmin.iin = v_rnn.
        cifmin.docnum = v_doc_num.
        cifmin.docdt = v_docdt.
        cifmin.docdtf = v_docdtf.
        cifmin.docwho = v_docwho.
        cifmin.addr = v_addr.
        cifmin.tel = v_tel.
        cifmin.chwho = g-ofc.
        cifmin.chwhn = g-today.
        cifmin.public = v_countr.
        cifmin.doctype = v_doctype.
        cifmin.fam = v_lname.
        cifmin.name = v_name.
        cifmin.mname = v_mname.
        cifmin.publicf = v_public.
        cifmin.bdt = v-bdt1.
        cifmin.bplace = v-bplace.
        if v_rez = "19" then cifmin.res = "1". else cifmin.res = "0".
        find current cifmin no-lock no-error.

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
        joudoc.dracctype = "4".
        joudoc.drcur = v_crc.
        joudoc.cramt = v_sum.
        if v-ek = 2 then joudoc.cracctype = "4". else joudoc.cracctype = "1".
        if v-ek = 2 then joudoc.cracc = v-chEK. else joudoc.cracc = "".
        joudoc.dracc = v_arp.
        joudoc.crcur = v_crc.
        joudoc.bas_amt = "D".
        joudoc.remark[1] = trim(v_oper) /*+ " " + trim(v_oper1) */ .
        joudoc.chk = 0.
        joudoc.info = v_lname + " " + v_name + " " + v_mname.
        joudoc.perkod = v_rnn.
        joudoc.passp = v_doc_num + "," + v_docwho.
        joudoc.passpdt = v_docdt.
        joudoc.kfmcif = v-cifmin.
        joudoc.benName = v_lname1 + " " + v_name1 + " " + v_mname1.
        joudop.who = g-ofc.
        joudop.whn = g-today.
        joudop.tim = time.
        joudop.lname = v_lname1 + "," + v_name1 + "," + v_mname1 + "," + v_countr1 + "," + v_rez1.
        joudop.patt = trim(v_lname1) + " " + trim(v_name1) + " " + trim(v_mname1) + "^" + "" + "^" + v_rez1 + "^" +
                        "" + "^" + "" + "^" + "" + "^" + v_knp.
        joudop.amt = v_sumv.
        joudop.amt1 = v_sumt.
        if v-ek = 1 then joudop.type = "FR3". else joudop.type = "RF3".
        find current joudop no-lock no-error.
        if v_sum <> v_sumv then do:
            find first crc where  crc.crc = v_crc no-lock no-error.
            joudoc.brate = crc.rate[2].
            joudoc.bn = 1.
        end.
        joudoc.srate = 1.
        run chgsts("JOU", v-joudoc, "new").
        find current joudoc no-lock no-error.
    end.
    run sc.
    sr-ans = yes.
    run yn(""," Закрыть экран клиента?","","", output sr-ans).
    if sr-ans then run to_screen( "default","").
end procedure.

procedure view_doc:
    update v-joudoc help "Введите номер документа, F2-помощь" with frame f_main.

    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    displ v-joudoc with frame f_main.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        if joudop.type <> "FR3" and joudop.type <> "RF3" then do:
            message substitute ("Документ не относится к типу отмена перевода") view-as alert-box.
            return.
        end.
        if v-ek = 1 and joudop.type = "RF3" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            return.
        end.
        if v-ek = 2 and joudop.type = "FR3" then do:
            message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
            return.
        end.
    end.
    if available joudoc then do:
        if joudoc.jh > 1 and v_u = 2 then do:
            message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
            return.
        end.
        if joudoc.who ne g-ofc and v_u = 2 then do:
            message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
            return.
        end.
    end.
    v_joutrx = joudoc.jh.
    v_sum = joudoc.dramt.
    v_crc = joudoc.drcur.
    v_arp = joudoc.dracc.
    v_oper = joudoc.remark[1].
    /*v_oper1 = substring(joudoc.remark[1],51,length(joudoc.remark[1]) - 51).*/
    v-cifmin = joudoc.kfmcif.
    find first joudop where joudop.docnum = v-joudoc no-lock no-error.
    v-benName = trim(joudop.lname).
    if num-entries(v-benName) = 5 then do:
        v_lname1 = entry(1,v-benName).
        v_name1 = entry(2,v-benName).
        v_mname1 = entry(3,v-benName).
        v_countr1 = entry(4,v-benName).
        v_rez1 = entry(5,v-benName).
     end.
     else v_lname1 = v-benName.
    v_sumv = joudop.amt.
    v_sumt = joudop.amt1.
    find last cifmin where cifmin.cifmin = v-cifmin no-lock no-error.
    if not avail cifmin then do:
        message "CIFMIN-код клиента не найден, продолжение невозможно!" view-as alert-box.
        return.
    end.
    v_lname = cifmin.fam.
    v_name = cifmin.name.
    v_mname = cifmin.mname.
    if v-bin then v_rnn = cifmin.iin.
    else  do:
        v_rnn = cifmin.rnn.
        v_iin = cifmin.iin.
    end.
    v_doc_num = cifmin.docnum.
    v_docdt = cifmin.docdt.
    v_docdtf = cifmin.docdtf.
    v_docwho = cifmin.docwho.
    v-bdt1 = cifmin.bdt.
    v-bplace = cifmin.bplace.
    v_addr = cifmin.addr.
    v_tel = cifmin.tel.
    v_doctype = cifmin.doctype.
    if cifmin.res = "1" then v_rez = "19". else v_rez = "29".
    v_countr = cifmin.public.
    v_public = cifmin.publicf.

    find first arp where arp.arp = v_arp no-lock no-error.
    if available arp then do:
        v_arpname = arp.des.
        if v_dt <> arp.gl then do:
            message "Счет Г/К по дебету не совпадает с типом  перевода, продолжение невозможно!" view-as alert-box.
            return.
        end.
    end.
    else do:
        message "Счет дебета в ARP не найден, продолжение невозможно!" view-as alert-box.
        return.
    end.
    displ v-label format "x(18)" no-label v_rnn format "x(12)" no-label  v_lname v_name v_mname   v_doc_num v_docdt v_docdtf
            v_docwho v_addr v_tel v_doctype v_rez v_countr v_public v-bdt1 v-bplace v_crc v_sum  v_knp
          v_oper /*v_oper1 */ v_lname1 v_name1 v_mname1 v_rez1 v_countr1 v_sumv v_sumt v_dt v_joutrx format "zzzzzzzzz" v_kt  v_arp v_arpname  with frame f_main.

end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = " ПЕРЕВОДЫ В ИН.ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА (отмена перевода)".
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
            displ vj-label format "x(35)" no-label with frame f_main.
            update v-ja no-label with frame f_main.
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
    vj-label  = " Выполнить транзакцию?..................".
    v_title = " ПЕРЕВОДЫ В ИН.ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА (отмена перевода)".
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

    /* проверка курса валюты ----------------------------------------------------------------*/
    if joudop.amt1 <> 0 then do:
        /* проверка блокировки курса --------------------------------*/
        if joudop.amt1 <> 0 then do:
            v-cur = no.
            run a_cur(input v_crc, output v-cur).
            if v-cur then undo, return.
        end.
        /*------------------------------------------------------------*/
        def var inf1 as logic.
        inf1 = false.
        if joudop.amt1 <> 0  then do:
            find first crc where crc.crc = v_crc no-lock.
            if joudoc.brate <> crc.rate[2] then do:
                inf1 = true.
                v_sumt1 = v_sum - v_sumv.
                v_sumt = 0.
                m_buy = 0.
                m_sell = 0.
                v_rate = 0.
                v_rate1 = 0.
                v_bn = 0.
                v_sn = 0.
                run conv( input v_crc,  input 1,input true,
                    input true, input-output v_sumt1, input-output v_sumt,
                    output v_rate1, output v_rate, output v_sn,
                    output v_bn, output m_sell, output m_buy).
            end.
        end.
        if inf1 then do:
            message "Изменился курс покупки валют, сумма в тенге будет пересчитана." view-as alert-box.
            displ v_sumt  with frame f_main.
            find first joudoc where joudoc.docnum = v-joudoc exclusive-lock.
            joudoc.brate = crc.rate[2].
            find first joudoc where joudoc.docnum = v-joudoc no-lock.
            find first joudop where joudop.docnum = v-joudoc exclusive-lock.
            if inf1 then joudop.amt1 = v_sumt.
            find first joudop where joudop.docnum = v-joudoc no-lock.
            return.
        end.
    end.
    /*---------------------------------------------------------------------------------------*/
    /* фин контроль*/
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

        find first arp no-lock no-error.
            s-jh = 0.
            if v_sumv = v_sum  or v_crc = 1 then do:
             /* формир v-param для trxgen.p */
                v-tmpl = "JOU0056".
                v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v_arp + vdel + v-chEK + vdel + v_oper + vdel + substring(v_rez1,1,1) + vdel + substring(v_rez,1,1) + vdel + "9" + vdel + "9" + vdel + v_knp.
                run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
            end.
            else do:
                v-tmpl = "JOU0056".
                v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v_arp + vdel + v-chEK + vdel + v_oper + vdel + substring(v_rez1,1,1) + vdel + substring(v_rez,1,1) + vdel + "9" + vdel + "9" + vdel + v_knp.
                run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.
                /* обрабатываем конвертируем сумму в тенге */
                v-tmpl = "JOU0063".
                v-param = v-joudoc + vdel + string(v_sum - v_sumv) + vdel + string(v_crc) + vdel + v-chEK + vdel + "обмен валюты" +
                        vdel + substring(v_rez,1,1) + vdel + substring(v_rez1,1,1) + vdel + "9" + vdel + "9" + vdel + "213" + vdel +
                        "1" + vdel + v-chEK1 .
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
                if jl.sts < 5 then jl.sts = 5.
            end.
            find current jh no-lock.
            find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error .
            joudoc.jh = s-jh.
            if v_crc = 1  then joudoc.brate = 1.
            else do:
                find first crc where  crc.crc = v_crc no-lock no-error.
                joudoc.brate = crc.rate[2].
                joudoc.bn = 1.
            end.
            joudoc.srate = 1.
            find current joudoc no-lock no-error.
            run chgsts(m_sub, v-joudoc, "bac").
    end.
    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
        v-tmpl = "JOU0001".
        v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v_arp + vdel + v_oper + vdel +
                              substring(v_rez1,1,1) + vdel + substring(v_rez,1,1) + vdel + "9" + vdel + "9" + vdel + v_knp.

        run trxgen ("JOU0001", vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.

        run chgsts(m_sub, v-joudoc, "trx").
        run chgsts("jou", v-joudoc, "bac").
        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock.
        joudoc.jh = s-jh.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
    end.
    /* копируем заполненные данные по ФМ в реальные таблицы*/
    if v-kfm then do:
        run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
        hide all.
        view frame f_main.
    end.
    /**/
    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) + " ~nНеобходим контроль в п.м. 2.4.1.1! 'Контроль документов'!" view-as alert-box.
    find first crc where crc.crc = v_crc no-lock.
    v-crc_val = crc.code.
    for each sendod no-lock.
        run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
        "Добрый день!\n\n Необходимо отконтролировать отмену перевода без открытия счета \n Сумма: " + string(v_sum) +
        "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
        string(time,"HH:MM"), "1", "","" ).
    end.
    hide all.
    view frame f_main.

    v_joutrx = s-jh.
    display v_joutrx format "zzzzzzzzz"  with frame f_main.
    if v-noord = yes then run printvouord(2).
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if avail joudoc then do:
        /*run vou_bankt(1, 1, joudoc.info).*/
        if v-noord = no then run vou_bankt(1, 2, joudoc.info).
        else run printord(s-jh,"").
    end.
    else do:
        message "Не найден  документ " + v-joudoc + ", обратитесь к разработчику!" view-as alert-box.
        undo, return.
    end.

    hide all no-pause.
        /*run x0-cont1.
        hide all no-pause.*/
        for each jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = 100500 or jl.gl = 100100) no-lock:
            create jlsach .
            jlsach.jh = s-jh.
            jlsach.amt = jl.cam .
            jlsach.ln = jl.ln .
            jlsach.lnln = 1.
            jlsach.sim = 300.
        release jlsach.
        end.
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
                    hide frame f_main.

            run trxdel (input s-jh, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                 if rcode = 50 then do:
                    hide all.
                    view frame f_main.
                end.
                message rdes.
                if rcode = 50 then do:
                    run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                    hide frame f_main.

                    view frame f_main.
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
        v_joutrx = ?.
        display v_joutrx with frame f_main.

    end. /* transaction */

    do transaction:
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
        message "Транзакция не существует.".
        run x-vou (input v-joudoc, input "jou").
        undo, return.
    end.

    do transaction:
        s-jh = joudoc.jh.
    if avail joudoc then do:
        /*run vou_bankt(2, 2, joudoc.info).*/
        if v-noord = no then run vou_bankt(2, 2, joudoc.info).
        else run printord(s-jh,"").
    end.
    end. /* transaction */
end procedure.

procedure deffilial.
     v-cltype = '01'.
     v-res = 'KZ'.
     v-res2 = '1'.

     find first codfr where codfr.codfr = 'DKPODP' and codfr.code = '1' no-lock no-error.
     if avail codfr then v-FIO1U = codfr.name[1].

     v-OKED = '65'.
     /*пока пустое, т.к. у филиала 12-значный ОКПО */
     v-prtOKPO = cmp.addr[3].

     find first cmp no-lock no-error.
     v-prtPhone = cmp.tel.
     v-rnn = cmp.addr[2].
     v-addr = cmp.addr[1].

     find sysc where sysc.sysc = "bnkadr" no-lock no-error.
     if avail sysc then do:
        v-prtEmail = entry(5, sysc.chval, "|") no-error.
        v-addr = v-addr + ',' + entry(1, sysc.chval, "|") no-error.
     end.

     find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.

end procedure.

procedure defclparam.

    v-cltype = ''.
    v-res = ''.
    v-res2 = ''.
    v_public = ''.
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
            v-country22 = entry(1,cif.addr[1]).
            if num-entries(v-country22,'(') = 2 then v-res = substr(entry(2,v-country22,'('),1,2).
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
        if avail sub-cod and sub-cod.ccode <> 'msc' then v_public = sub-cod.ccode.

        v-bdt = string(cif.expdt,'99/99/9999').
        v-bplace = cif.bplace.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-FIO1U = sub-cod.rcode.

    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-OKED = sub-cod.ccode.
end procedure.

procedure print_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует.".
        undo, return.
    end.
        s-jh = joudoc.jh.
        /*run vou_bankt(2, 2, joudoc.info).*/
        if v-noord = no then run vou_bankt(2, 2, joudoc.info).
        else do:
            run printvouord(2).
            run printord(s-jh,"").
        end.
end procedure.

procedure ciffind:
define input parameter vv as char .
define output parameter result  as char.
result = "".
famlist = "".

    if v-bin then do:
        FOR EACH cifmin where cifmin.iin = v_rnn and cifmin.fam = v_lname no-lock.
            I = I + 1.
            if famlist <> "" then famlist = famlist + "|".
            famlist = famlist + cifmin.cifmin + " " + cifmin.fam + " " + cifmin.name + " " + cifmin.mname + " " + string(bdt).
        end.
    end.

    else do:
        FOR EACH cifmin where cifmin.rnn = v_rnn and cifmin.fam = v_lname no-lock.
            I = I + 1.
            if famlist <> "" then famlist = famlist + "|".
            famlist = famlist + cifmin.cifmin + " " + cifmin.fam + " " + cifmin.name + " " + cifmin.mname + " " + string(bdt).
        end.
    end.
    if I > 0 then do:
       run sel1("Выберите Фамилию", famlist).
        if keyfunction(lastkey) = "end-error" then return.
       result = entry(1,return-value," ").
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
    if v-noord = yes then run printbks(string(s-jh) + "#", "TRX").
      message "Проводка уже отштампована " view-as alert-box.*/
end procedure.

procedure a_subcod:
    run subcodj (v-joudoc, "jou").
    view frame f_main.
end procedure.

procedure sc:
/*--------------------------------------------------------------*/
    TCIFNAME = "TCIFNAME=" + UrlEncode(v_lname1) + " " + UrlEncode(v_name1) + " " + UrlEncode(v_mname1).
    /*TRECINN = "TRECINN=" + v_rnn.*/
    TKOD = "TKOD=" + v_rez1.
    TSUMM = "TSUMM=" + replace(trim(string(v_sum,'->>>>>>>>>>>>>>9.99')),'.',',').
    TCRC = "TCRC=" + getcrc(v_crc).
    TRECNAME = "TRECNAME=" + UrlEncode(v_lname) + " " + UrlEncode(v_name) + " " + UrlEncode(v_mname).
    TKBE = "TKBE=" + v_rez.
    TREM = "TREM=" + UrlEncode(v_oper).
    TKNP = "TKNP=" + v_knp.

    v-res111 = TCIFNAME + "&" + TINN + "&" + TKOD + "&" + TSUMM + "&" + TCRC + "&" + TRECNAME + "&" +
            TKBE + "&" + TREM + "&" + TKNP.
    run to_screen("transfer", v-res111).
/*--------------------------------------------------------------*/

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

    if not avail cursts or (avail cursts and cursts.sts <> "cas") then do :      message "Документ не отконтролирован " view-as alert-box.
      undo, return.
    end.

    run a_stamp(joudoc.jh).
    pause 0.
    hide all.
    view frame f_main.
end.

procedure chksum:
    on "END-ERROR" of frame f_main do:
       v-cur = yes .
    end.
    if v_crc <> 1 then do:
        /* расчет суммы внесения  */
        v_sumv = 0.
        repeat:
            update v_sumv with frame f_main.
            v_sumt = 0.
            v_sumt1 = 0.
            v-mod = 0.
            if v_sumv <> 0 then do:
                if v_crc = 4 then do:
                    v_sum1 = decim(entry(1,string(v_sumv),".")) / 100 .
                    v-mod = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 100) + (v_sumv - decim(entry(1,string(v_sumv),"."))).
                end.
                else do:
                    v_sum1 = decim(entry(1,string(v_sumv),".")) / 10 .
                    v-mod = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 10) + (v_sumv - decim(entry(1,string(v_sumv),"."))).
                end.
                if v-mod <> 0 then do:
                    if v_crc = 4 then  message "Укажите сумму кратную 100" view-as alert-box.
                    else  message "Укажите сумму кратную 10" view-as alert-box.
                    v_sum1 = 0.
                end.
                v_sumt = 0.
            end.

            if v-mod = 0 then do:
                /* проверка блокировки курса --------------------------------*/
                v-cur = no.
                run a_cur(input v_crc, output v-cur).
                if v-cur then undo, return.

                /*------------------------------------------------------------*/
                v_sumt1 = v_sum - v_sumv.
                v_sumt = 0.
                m_buy = 0.
                m_sell = 0.
                v_rate = 0.
                v_rate1 = 0.
                v_bn = 0.
                v_sn = 0.
                run conv( input v_crc,  input 1,input true,
                    input true, input-output v_sumt1, input-output v_sumt,
                    output v_rate1, output v_rate, output v_sn,
                    output v_bn, output m_sell, output m_buy).
                leave.
            end.
        end. /*repeat */
        displ v_sumt  with frame f_main.
        pause 0.
    end. /*if v_crc <> 1 and v-ek = 2 then*/
end procedure.
