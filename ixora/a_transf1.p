/* a_transf1.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        форма формирования переводных операций.
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
                03.02.2012  Luiza - добавила вывод признаков subcod
                06/02/2012  Luiza перекомпиляция
                08/02/2012  Luiza  -  добавила вывод номера документа
                09/02/2012  Luiza  -  для to_screen выводим не код резидентства, а текст
                17.02.2012  Lyubov - зашила символы кассплана согласно ТЗ № 1268
                05/03/2012  Luiza  - добавила условие при поиске кода cifmin if v_rnn <> ""
                06/03/2012  Luiza  - добавила номер перевода вводим только для ЗК
                07/03/2012  Luiza  - комиссию по быстрой почте исправила с 2% на 1.5%
                11.03.2012 damir - добавил печать оперционного ордера, printvouord.p.
                19/03/2012 Luiza  - если тестовая база клиента finmon не вызываем
                20/03/2012 Luiza  - вызов функции isProductionServer выполняем в a_fimnon.i
                10/04/2012 Luiza  - изменила рассылку сообщений
                13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
                24/04/2012 luiza - изменила создание мини карточки
                03/05/2012 Luiza  - добавила поле срок действия УЛ
                03/05/2012 Luiza  - при импорте ЗК v-countr редактируется
                07/05/2012 Luiza  - v-countr для KZ редактируется
                14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
                15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
                13/06/2012 Luiza - в процедуру save_date добавила  подключение comm
                28/06/2012 Luiza - отменила лишиние транзакционные блоки
                02/07/2012 Luiza - перенесла конец (команду end) условия  if v_crc = 1 or v_sum = v_sumv перед joudoc.jh = .......
                05/07/2012 Luiza - при ЗК и для Китая редактируются поля  v-sw v-bank v-branch v-chet
                10/07/2012 dmitriy - вывод на экран клиента
                12/07/2012 dmitriy - вывод на экран клиента только для филиалов, прописанных в sysc = "CifScr"
                26/07/2012 Luiza   - слово EK заменила ЭК
                17/08/2012 Luiza  - согласно СЗ добавила проверку курса на момент транзакции
                03/09/2012 Luiza - согласно СЗ при импорте ЗК ФИО редактируется
                10/09/2012 Luiza подключила {srvcheck.i}
                13/09/2012 Luiza отменила ecxlusive-lock для crc.
                20/09/2012 Luiza по СЗ закомен расчет комиссии для быстрой почты
                08/11/2012 Luiza - команда импорт для Юнистрим
                13/11/2012 Luiza - присвоение v_docdtf = ? при мпорте Юнистрим
                16/11/2012 добавила обработку статуса KFMONLINE
                            if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
                23.11.2012 Lyubov - ТЗ № 1573, изменила список видов документов, увеличина кол-во строк для b-doc
                28/11/2012 Luiza - ТЗ 1599 при импорте Юнистрим вид документа не редактируем
                29/11/2012 Luiza - ТЗ 1599 при импорте Юнистрим проверка вида докум и признака резид
                11.12.2012 Lyubov - ТЗ № 1618, проставление символа кас. плана 030 при внесении суммы в тг
                03/01/2013 Luiza - увеличила формат номера перевода v-transf до 20 символов ТЗ 1632
                18/01/2013 Luiza - ТЗ 1595 Изменение счета ГК 1858 изменила шаблон обмена на jou0069
                11/02/2013 Luiza - ТЗ 1623 проверка контрольного разряда ИИН
                12/02/2013 Luiza - ТЗ 1623 при импорте ЗК или ЮН если нет ИИН проставляем "-"
                27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
                05/04/2013 Luiza -  ТЗ № 1764 проверка признака блокирования валют при обменных операциях
                02.07.2013 damir - Внедрено Т.З. № 1936. Закоментил строку 2027.
                18/07/2013 Luiza - ТЗ 1967 откат по F4
                22/10/2013 Luiza - ТЗ 2003
*/

{global.i}
{adres.f}
define input parameter new_document as logical.
def input parameter Doc as class QPayClass.
def input parameter Docu as class UPayClass.
define variable m_sub           as character initial "jou".
def var v-tmpl as char no-undo.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var vparam as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
define new shared variable s-jh like jh.jh.
def shared var v_u as int no-undo.
def shared var v_dt as int no-undo.
def shared var v_kt as int no-undo.
def shared var v_dtk as int no-undo.
def shared var v_ktk as int no-undo.
def shared var v-select3 as integer no-undo.
def shared var v-select31 as integer no-undo.
def shared var v-sys as char no-undo.
def  var v_codfr as char format "x(1)" init "1".
def  var v_title as char no-undo. /*наименование платежа */
def  shared var v-joudoc as char no-undo format "x(10)".
def  var v_doc as char no-undo format "x(10)".
def  var v_rnn as char no-undo format "x(12)".
def  var v_iin as char no-undo format "x(12)".
def  var v_lname as char no-undo format "x(20)".
def  var v_name as char no-undo format "x(20)".
def  var v_mname as char no-undo format "x(20)".
def  var v_lname1 as char no-undo format "x(20)".
def  var v_name1 as char no-undo format "x(20)".
def  var v_mname1 as char no-undo format "x(20)".
def  var  v_rez as char no-undo format "x(2)".
def  var  v_r as char no-undo format "x(1)".
def  var  v_r1 as char no-undo format "x(1)".
def  var v_country as char no-undo format "x(20)".
def  var v_country1 as char no-undo format "x(20)".
def  var v_countr as char no-undo format "x(2)".
def  var v_countr1 as char no-undo format "x(2)".
def  var v_public as char no-undo. /* признак ИПДЛ */
def  var v_doctype as char no-undo.
def  var v_doc_num as char no-undo.
def  var  v_docwho as char no-undo.
def  var v_docdt as date no-undo.
def  var v_docdtf as date no-undo.
def  var v_addr as char no-undo format "x(75)".
def  var v_tel as char no-undo format "x(27)".
def  var v_oper as char no-undo format "x(50)".
def  var v_oper1 as char no-undo format "x(50)".
def  var v_knp as char no-undo init "119".
def  var v_rez1 as char no-undo.
def  var v_crc as int  no-undo format "9".
def  var v_sumv as decimal no-undo.
def  var v_sumt as decimal no-undo.
def  var v_sumt1 as decimal no-undo.
def  var v_crcv as int  no-undo format "9".
def  var v_sum as decimal no-undo.
def  var v_sum_lim as decimal no-undo. /* сумма*/
def  var v-conv as logi no-undo init yes. /*обмен валюты*/
define variable m_buy   as decimal.
define variable m_sell  as decimal.
def var v_rate as decim.
def var v_rate1 as decim.
def var v_bn as int.
def var v_sn as int.
define new shared variable vrat  as decimal decimals 4.
def shared var v-Get_Nal as logic.
def var v-cur as logic no-undo.

 /* для золотой короны  */
 def var p-tr-state as char.
 def var p-err as log no-undo init yes.
 def var p-errdes as char no-undo init ''.

 def var v-sw as char.
 def var v-bank as char.
 def var v-branch as char.
 def var v-chet as char.



def  var v_crck as int  no-undo format "9".
def  var v_sumk as decimal no-undo.
def  var v_sumkv as decimal no-undo.
def  var v_sumkt as decimal no-undo.
def  var v_sumkt1 as decimal no-undo.
def  var v_crccode as char no-undo format "x(3)".
def  var v_arp as char no-undo.
def  var v_arp1 as char no-undo.
def  var v-ja as logi no-undo format "Да/Нет" init yes.
def  var v-label as char no-undo.
def  var vj-label as char no-undo.
def  var v-cifmin as char no-undo.
def  var v-bplace as char no-undo.
def  var v-bdt1 as date no-undo.
def  var v_comcode as char no-undo format "x(3)".
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


/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-crc_valv as char no-undo format "xxx".
def var v-crc_valk as char no-undo format "xxx".
def var v-chEK as char format "x(20)". /* счет ЭК*/
def var v-chEKv as char format "x(20)". /* счет ЭК*/
def var v-chEK1 as char format "x(20)". /* счет ЭК*/
def var v-chEKk as char format "x(20)". /* счет ЭК для комиссии*/
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
def var famlist as char init "".


def var I as int init 0.
def var v_arpname as char format "x(30)".
def var v-int as decim.
def var v-mod as decim.
def var v-modc as decim.
def var v-int1 as decim.
def var v-mod1 as decim.
def var v-modc1 as decim.
def var v-error as logic.
def var v-transf as char.


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
def var TSYSTEM  as char.
def var sr-ans as logic.
def var TRECCOUNTRY as char.
def button prev-button label "Предыдущая".
def button next-button label "Следующая".
def button close-button label "Закрыть".
def var CurPage as int.
def var PosPage as int.
def var MaxPage as int.
def var phand AS handle.
def var Mask as char label "шаблон".
def var Pages as char label "страница".

define frame Form1
    Mask format "x(25)" skip
    Pages skip
    "----------------------------------" skip
    prev-button next-button close-button
    WITH SIDE-LABELS centered overlay row 20 TITLE "Экран клиента".

{yes-no.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */
{comm-txb.i}
{get-dep.i}
{findstr.i}
{kfm.i "new"}
{keyord.i}
{to_screen.i}
{srvcheck.i}

if v-ek = 2 then do:
    find first codfr where codfr.codfr = 'ekcrc' no-lock no-error.
    if not avail codfr then do:
        message "В справочнике <codfr> отсутствует код <ekcrc> для определения допустимых валют при работе с ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
        return.
    end.
end.

def var v-knpval as char no-undo.
v-knpval = "119".

define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.

def buffer b-sysc for sysc.
def var v-bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v-label = " ИИН             :". else v-label = " РНН              :".
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
    v-joudoc    label " Документ" format "x(10)"       v_trx label "                        ТРН " format "zzzzzzzzz"  skip
                     "           ОТПРАВИТЕЛЬ"
                     "                                           ПОЛУЧАТЕЛЬ" SKIP
    v-label v_rnn  no-label format "x(12)" validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН')
    v_lname1    label "                       Фамилия         " format "X(20)" validate(trim(v_lname1) <> "", "Заполните фамилию") skip

    v_lname     label " Фамилия          " format "X(20)"  validate(trim(v_lname) <> "", "Заполните фамилию")
    v_name1     label "              Имя             " format "X(20)" validate(trim(v_name1) <> "", "Заполните имя") skip

    v_name      label " Имя              " format "X(20)"  validate(trim(v_name) <> "", "Заполните имя")
    v_mname1    label "              Отчество        " format "X(20)" skip

    v_mname     label " Отчество         " format "X(20)"
    v_rez1      label "              Резиденство     " validate(v_rez1 = "19" or v_rez1 = "29", "19-(физ.лицо/резидент), 29-(физ.лицо/нерезидент), F2-помощь") format "x(2)"skip

    v_rez       label " Резидентство     " validate(v_rez = "19" or v_rez = "29", "19-(физ.лицо/резидент)  29-(физ.лицо/нерезидент), F2-помощь") format "x(2)"
    v_countr1   label "                                Страна получения" validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_countr1 no-lock), "Нет такого кода страны! F2-помощь") format "x(2)" skip
     /*v-cn       no-label colon 74 format "x(20)" skip*/

    v_countr    label " Cтрана           " validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_countr no-lock), "Нет такого кода страны! F2-помощь") format "x(2)"
    v-sw       label "                                Свифт           "  format "X(11)" skip
    v_doctype  label " Вид документа    " validate((v_rez = "19" and lookup(substring(trim(v_doctype),1,2),"01,02,04,05") > 0) or (v_rez = "29"
                                        and lookup(substring(trim(v_doctype),1,2),"03") > 0),"Не правильный вид документа, F2-помощь" )  format "x(30)"
    v-bank     label "    Банк получателя "  format "X(23)" skip
    v_doc_num  label " Номер документа  " help "Введите номер докумета удостов. личность" format "x(30)" validate(trim(v_doc_num) <> "", "Заполните номер документа")
    v-branch   label "    Отделение       "  format "X(20)" skip
    v_docwho   label " Выдан            " help " Кем выдан документ удостов. личность"  format "x(30)" validate(trim(v_docwho) <> "", "Заполните кем выдан документ")
    v-chet     label "    Счет получателя "  format "X(20)" skip
    v_docdt    label " Дата выдачи      " format "99/99/9999" help " Введите дату выдачи документа удостов. личость в формате дд/мм/гггг " validate(trim(v_docdt) <> "", "Заполните дату выдачи документа")
    v_docdtf   label " Срок действия    " colon 50 format "99/99/9999" help " Введите срок действия документа удостов. личость в формате дд/мм/гг " /*validate(trim(v_docdtf) <> "", "Заполните срок действия документа")*/ skip
    v_public   label " Принадл к ИПДЛ   "  format "x(1)"  help '1-не является 2- является 3-Аффилир. с иност. публич.' validate(can-find (codfr where codfr.codfr = 'publicf' and codfr.code = v_public no-lock),'Неверный признак! 1-не является 2- является 3-Аффилир. с иност. публич.') skip
    v-bdt1     label ' Дата рождения    '  format "99/99/9999" validate(v-bdt1 <> ?,'Введите дату!') skip
    v-bplace   label ' Место рождения   '  format "x(40)" validate(trim(v-bplace) <> '','Введите место рождения!') skip
    v_addr     label " Адрес            " help "Адрес проживания" validate(trim(v_addr) <> "", "Заполните адрес проживания") skip
    v_tel      label " Телефон          " help "Введите номер телефона" skip
    v_knp      label " КНП              " format "x(3)"  skip
    v_oper     label " Назнач. платежа  "   format "x(50)" skip
    v-transf    label " Номер перевода   " format "X(20)"  validate(trim(v-transf) <> "", "Заполните номер перевода") skip
    /* v_oper1    no-label format "x(50)" colon 19 skip*/
                     "           ДАННЫЕ ПРОВОДКИ ПЕРЕВОДА "  but skip
    v_crc      label " Валюта перевода  " help "Введите код валюты, F2-помощь" format ">9"
                validate(can-find(first crc where (crc.crc = v_crc and crc.sts <> 9 and v-select3 <> 1 and v_crc <> 1)
                or (crc.crc = v_crc and crc.sts <> 9 and v-select3 = 1 and (v_crc = 1 or v_crc = 2)) no-lock),"Неверный код валюты!")
    /*v_crcv     label " Валюта внесения         " colon 70 help "Введите код валюты, F2-помощь" format "9" validate(v_crcv = 1 or v_crcv = v_crc ,"Только в тенге или в валюте перевода!") skip*/
    v_sumv     label " Сумма внесения в валюте " colon 70 help " Введите сумму внесения" validate(v_sumv <= v_sum,"Не может быть больше суммы перевода!") format ">>>,>>>,>>>,>>>,>>9.99"  skip
    v_sum      label " Сумма перевода   " help " Введите сумму перевода" validate(v_sum > 0,"Проверьте значение суммы!") format ">>>,>>>,>>>,>>>,>>9.99"
    v_sumt     label " Сумма внесения в тенге  " colon 70 help " Введите сумму внесения" format ">>>,>>>,>>>,>>>,>>9.99"  skip
    v_dt       label " Дебет Г/К        " skip
    v_kt       label " Кредит Г/К       "
    v_arp      label " АРП (Кт)" format "X(20)" colon 37 v_arpname no-label colon 60 skip
                     "           ДАННЫЕ ПРОВОДКИ КОМИССИИ " skip
    v_crck     label " Валюта комиссии  " help "Введите код валюты, F2-помощь"   format ">9" validate(can-find(first crc where crc.crc = v_crck and crc.sts <> 9 no-lock),"Неверный код валюты!")
    v_sumkv    label " Сумма внесения комиссии в валюте" validate(v_sumkv <= v_sumk,"Не может быть больше суммы комиссии!") format ">>>,>>9.99" colon 79 skip
    v_sumk     label " Сумма комиссии   "  help " Введите сумму комиссии"  validate(v_sumk > 0,"Проверьте значение суммы!") format ">>>,>>>,>>>,>>>,>>9.99"
    v_sumkt    label " Сумма внесения комиссии в тенге " format ">>>,>>9.99" colon 79 skip
    v_dtk      label " Дебет Г/К        " skip
    v_ktk      label " Кредит Г/К       "
    v_arp1     label " АРП (Кт)" format "X(20)" colon 37 skip
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

/* для cifmin*/
/*DEFINE QUERY q-tar FOR cifmin.
DEFINE BROWSE b-tar QUERY q-tar
       DISPLAY cifmin.rnn label "РНН " format "x(12)" cifmin.iin label "ИНН " format "x(12)" cifmin.fam label "Фамилия   " format "x(20)" cifmin.name label "Имя   " format "x(15)" cifmin.mname label " Отчество  " format "x(15)" WITH  7 DOWN.
DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 10 width 90 NO-BOX.*/

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
/*on help of v_crcv in frame f_main do:
    run help-crc1.
end.*/
on help of v_crck in frame f_main do:
    run help-crc1.
end.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("TR1" + string(v-select3)). else run a_help-joudoc1 ("RT1" + string(v-select3)).
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
  return.
end.
on "END-ERROR" of v_crck in frame f_main do:
  return.
end.
on "END-ERROR" of frame f-country do:
  hide frame f-country no-pause.
end.

on choose of but in frame  f_main do:
end.
on "END-ERROR" of but in frame f_main do:
    undo, return.
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


if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = " БЫСТРЫЕ ПЕРЕВОДЫ (отправление перевода)" + v-sys.
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    v_oper = "Материальная помощь(отправление перевода) ".
    v_oper1 = "".
    displ v-joudoc v-label format "x(18)" no-label with frame f_main.

    if VALID-OBJECT(Doc) and v-select3 = 3 then run import_doc.
    else do:
        if VALID-OBJECT(Docu) and v-select3 = 4 then run import_docu.
        else run save_doc.
    end.

end.  /* end new document */

else do:   /* редактирование документа   */
    v_title = " БЫСТРЫЕ ПЕРЕВОДЫ (отправление перевода) " + v-sys.
    run view_doc.
    if keyfunction (lastkey) = "end-error" then do:
        return.
    end.
    if v_u = 2 then do:       /* update */
        vj-label  = " Сохранить изменения документа?...........".
        v_title = " БЫСТРЫЕ ПЕРЕВОДЫ (отправление перевода)" + v-sys.
        /*run view_doc.*/
        find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if available joudoc then do:
            find joudop where joudop.docnum = v-joudoc no-lock no-error.
            if available joudop then do:
                if joudop.type <> "TR1" + string(v-select3)  and joudop.type <> "RT1" + string(v-select3) then do:
                    message "Документ не относится к типу отправление быстрых перевода системой " + v-sys view-as alert-box.
                    return.
                end.
                if v-ek = 1 and joudop.type = "RT1" + string(v-select3) then do:
                    message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                    return.
                end.
                if v-ek = 2 and joudop.type = "TR1" + string(v-select3) then do:
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

procedure import_docu:
 if Docu:TransferStatus <> 10 then do:
   message "Неверный тип документа.~nДолжен быть документ на отправку!" view-as alert-box.
   return.
 end.
  v-cifmin = "".
  v_rnn = Docu:sender_proffession.
  v_rez = string(Docu:PayerIsResident).
  v_lname = Docu:PayerSname.
  v_name = Docu:PayerFname.
  v_mname =  Docu:PayerMname.
  v_countr =  Docu:sender_country.
  v_doctype =  Docu:PayerCType.
  v_doc_num =  trim(Docu:PayerSerialNumber + " " + Docu:PayerCNumber).
  v_docwho =  Docu:PayerIssuer.
  v_docdt = DATE(int(substring(Docu:PayerIssueDate,6,2)), int(substring(Docu:PayerIssueDate,9,2)), int(substring(Docu:PayerIssueDate,1,4))).
  if int(substring(Docu:sender_docexp,1,4)) = 1899 then v_docdtf = ?.
  else v_docdtf = DATE(int(substring(Docu:sender_docexp,6,2)), int(substring(Docu:sender_docexp,9,2)), int(substring(Docu:sender_docexp,1,4))).
  v_public =  "1".
  v-bdt1 =  DATE(int(substring(Docu:PayerBirthDate,6,2)), int(substring(Docu:PayerBirthDate,9,2)), int(substring(Docu:PayerBirthDate,1,4))).
  v_addr = Docu:sender_state + "," +   Docu:sender_city  + "," +   Docu:sender_street + "," +   Docu:sender_house  + "," +    Docu:sender_flat  + "," +  Docu:sender_zip.
  v-bplace = Docu:sender_birthPlace.
  v_tel =  Docu:PayerPhone.
  v_knp =  "119".
  v_rez1 =  string(Docu:PayeeIsResident).
  v_lname1 = Docu:PayeeSname.
  v_name1 =  Docu:PayeeFname.
  v_mname1 =  Docu:PayeeMname.
  v_countr1 =  Docu:ToCountry.
  v_crc =  Docu:PayCRC.
  v_sum =  Docu:PayAmount.
  v_crck =  Docu:PayCRC.
  v_sumk =  Docu:Comission.
  v-transf = Docu:UIN.
  if v_rnn = "" then v_rnn = "-".
  if not chk12_innbin(v_rnn) then do:
    message "Неверный ИИН/БИН." view-as alert-box error.
    return.
  end.
  if v_countr1 = "CN" then v-chet = Docu:PayeeAccount.
    if v-ek = 2 then do:
        find first codfr where codfr.codfr = 'ekcrc' and codf.code = string(v_crc) no-lock no-error.
        if not avail codfr then do:
            message "Не допустимый код валюты для работы с ЭК! Используйте счет 100100." view-as alert-box error.
            return.
        end.
    end.
   displ v_rnn v_rez v_lname v_name v_mname
        v_countr v_doctype v_doc_num v_docwho
        v_docdt v_docdtf v_public v-bplace v-bdt1 v_addr
        v_tel v_knp v_oper v_rez1 v_lname1 v_name1 v_mname1
        v_countr1 v-transf v_crc v_sum v_sumv v_crck v_sumk  with frame f_main.
        if v_countr1 = "CN" then displ v-sw v-bank v-branch v-chet with frame f_main.
    /* проверка признака резид и вида документа  */
    if (v_rez = "29" and substring(trim(v_doctype),1,2) <> "03" ) or (v_rez = "19" and substring(trim(v_doctype),1,2) = "03" ) then do:
        message "Ошибка, документ не сохранится!~n Не соответствие признака резиденства и вида документа!" view-as alert-box error.
        return.
    end.
   if v_rnn <> "" then do:
       if v-bin then find last cifmin where cifmin.iin = v_rnn no-lock no-error.
        else find last cifmin where cifmin.rnn = v_rnn no-lock no-error.
        if available cifmin then v-cifmin = cifmin.cifmin.
    end.


    if v-bin then find first rnn where rnn.bin = v_rnn no-lock no-error.
    else find first rnn where rnn.trn = v_rnn no-lock no-error.
    if available rnn then do:
     if v_lname <> rnn.lname or v_name <> rnn.fname or v_mname = rnn.mname then do:
       message "Несоответствие данных о плательшике!" view-as alert-box.
       /*что нибудь можно сделать*/
     end.
    end.
    else do:
      /*message "Нет данных в таблице РНН!" view-as alert-box.*/
      /*тоже возможна ситуация*/
    end.

    find first arp where arp.gl = v_kt and arp.crc = v_crc and length(arp.arp) >= 20 no-lock no-error.
    if available arp then do:
        v_arp = arp.arp.
        v_arpname = arp.des.
        displ v_dt format "999999" v_kt format "999999" v_arp v_arpname with frame f_main.
    end.
    else do:
        message "ARP счет кредита не найден, продолжение невозможно!" view-as alert-box.
        undo,return.
    end.

    find first arp where arp.gl = v_ktk and arp.crc = v_crck and length(arp.arp) >= 20 no-lock no-error.
    if available arp then do:
        v_arp1 = arp.arp.
        displ v_dt format "999999" v_kt format "999999" v_arp v_arpname with frame f_main.
    end.
    else do:
        message "ARP счет кредита комиссии не найден, продолжение невозможно!" view-as alert-box.
        undo,return.
    end.
    displ v_dtk format "999999" v_ktk format "999999" v_arp1  with frame f_main.
    displ v-joudoc vj-label  no-label with frame f_main.
    update  v_countr /*v_doctype*/ v_public  with frame f_main.

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

    run make-comm.

    update v-ja no-label with frame f_main.
    if v-ja then do:
        run gen-jou.
    end.

end procedure.

procedure import_doc:
 if Doc:TransferStatus <> 2 then do:
   message "Неверный тип документа.~nДолжен быть документ на отправку!" view-as alert-box.
   return.
 end.

  v-cifmin = "".
  v_rnn = Doc:PayerINN.
  v_rez = Doc:PayerKbeKod.
  v_lname = Doc:PayerSname.
  v_name = Doc:PayerFname.
  v_mname =  Doc:PayerMname.
  v_countr =  Doc:GetISO3166(Doc:FromCountryISO).
  v_doctype =  Doc:PayerCType.
  v_doc_num =  Doc:PayerSerialNumber + " " + Doc:PayerCNumber.
  v_docwho =  Doc:PayerIssuer.
  v_docdt =  Doc:PayerIssueDateDT.
  v_docdtf = ?.
  v_public =  "1".
  v-bplace =  Doc:PayerBirthCountry + Doc:PayerBirthCity.
  v-bdt1 =  DATE(Doc:PayerBirthDate).
  v_addr =  Doc:PayerRegCountry + "," + Doc:PayerRegCity + "," + Doc:PayerRegAddress.
  v_tel =  Doc:PayerPhone.
  v_knp =  Doc:PayerKNP.
  v_oper =  Doc:GetTransferStatus().
  v_rez1 =  Doc:PayeeKbeKod.
  v_lname1 =  Doc:PayeeSname.
  v_name1 =  Doc:PayeeFname.
  v_mname1 =  Doc:PayeeMname.
  v_countr1 =  Doc:GetISO3166(Doc:ToCountryISO).
  v_crc =  Doc:GetCRCCode(Doc:PayFundsCRC).
  /*v_crcv =  Doc:GetCRCCode(Doc:PayFundsCRC).*/
  v_sum =  Doc:PayFunds.
  v_crck =  Doc:GetCRCCode(Doc:ComissionCRC).
  v_sumk =  Doc:Comission.
  v-transf = Doc:UIN.
  if v_rnn = "" then v_rnn = "-".
  if not chk12_innbin(v_rnn) then do:
    message "Неверный ИИН/БИН." view-as alert-box error.
    return.
  end.
  if v_countr1 = "CN" then do:
      v-sw = "".
      v-bank = "BANK OF CHINA".
      v-branch = Doc:Payeemessage.
      v-chet = Doc:PayeeAccount.
   end.
    if v-ek = 2 then do:
        find first codfr where codfr.codfr = 'ekcrc' and codf.code = string(v_crc) no-lock no-error.
        if not avail codfr then do:
            message "Не допустимый код валюты для работы с ЭК! Используйте счет 100100." view-as alert-box error.
            return.
        end.
    end.
   displ v_rnn v_rez v_lname v_name v_mname
        v_countr v_doctype v_doc_num v_docwho
        v_docdt v_docdtf v_public v-bplace v-bdt1 v_addr
        v_tel v_knp v_oper v_rez1 v_lname1 v_name1 v_mname1
        v_countr1 v-transf v_crc /*v_crcv*/ v_sum v_sumv v_crck v_sumk  with frame f_main.
    if v_countr1 = "CN" then displ v-sw v-bank v-branch v-chet with frame f_main.

   if v_rnn <> "" then do:
       if v-bin then find last cifmin where cifmin.iin = v_rnn no-lock no-error.
        else find last cifmin where cifmin.rnn = v_rnn no-lock no-error.
        if available cifmin then v-cifmin = cifmin.cifmin.
    end.


    if v-bin then find first rnn where rnn.bin = v_rnn no-lock no-error.
    else find first rnn where rnn.trn = v_rnn no-lock no-error.
    if available rnn then do:
     if v_lname <> rnn.lname or v_name <> rnn.fname or v_mname = rnn.mname then do:
       message "Несоответствие данных о плательшике!" view-as alert-box.
       /*что нибудь можно сделать*/
     end.
    end.
    else do:
      /*message "Нет данных в таблице РНН!" view-as alert-box.*/
      /*тоже возможна ситуация*/
    end.

    find first arp where arp.gl = v_kt and arp.crc = v_crc and length(arp.arp) >= 20 no-lock no-error.
    if available arp then do:
        v_arp = arp.arp.
        v_arpname = arp.des.
        displ v_dt format "999999" v_kt format "999999" v_arp v_arpname with frame f_main.
    end.
    else do:
        message "ARP счет кредита не найден, продолжение невозможно!" view-as alert-box.
        undo,return.
    end.

    find first arp where arp.gl = v_ktk and arp.crc = v_crck and length(arp.arp) >= 20 no-lock no-error.
    if available arp then do:
        v_arp1 = arp.arp.
        displ v_dt format "999999" v_kt format "999999" v_arp v_arpname with frame f_main.
    end.
    else do:
        message "ARP счет кредита комиссии не найден, продолжение невозможно!" view-as alert-box.
        undo,return.
    end.
    displ v_dtk format "999999" v_ktk format "999999" v_arp1  with frame f_main.
    displ v-joudoc vj-label  no-label with frame f_main.
    update v_lname v_name v_mname v_countr v_docdtf v_public  v-bplace v_lname1 v_name1 v_mname1 v_rez1 /*v_crcv*/  with frame f_main.

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

    run make-comm.

    update v-ja no-label with frame f_main.
    if v-ja then do:
        run gen-jou.
    end.

end procedure.

procedure save_doc:
    if v_u = 2 and v-select3 = 3 and VALID-OBJECT(Doc) then do: /*ZK */
        update v_lname v_name v_mname v_countr v_docdtf v_public  v-bplace v_lname1 v_name1 v_mname1 v_rez1  with frame f_main.
        if v_crc <> 1 and v-ek = 2 then do:
            update v_sumv with frame f_main.
            v_sumt = 0.
            if v_sumv <> v_sum then do:
                /* проверка блокировки курса --------------------------------*/
                v-cur = no.
                run a_cur(input v_crc, output v-cur).
                if v-cur then undo, return.
                /*------------------------------------------------------------*/
                v_sumt1 = v_sum - v_sumv.
                m_buy = 0.
                m_sell = 0.
                v_rate = 0.
                v_rate1 = 0.
                v_bn = 0.
                v_sn = 0.
                v_sumt = 0.
                run conv(input 1, input v_crc, input true,
                    input true, input-output v_sumt, input-output v_sumt1,
                    output v_rate1, output v_rate, output v_sn,
                    output v_bn, output m_sell, output m_buy).
            end.
            displ v_sumt  with frame f_main.
            update v_sumkv with frame f_main.
            v_sumkt = 0.
            if v_sumkv <> v_sumk then do:
                /* проверка блокировки курса --------------------------------*/
                v-cur = no.
                run a_cur(input v_crck, output v-cur).
                if v-cur then undo, return.
                /*------------------------------------------------------------*/
                v_sumkt1 = v_sumk - v_sumkv.
                m_buy = 0.
                m_sell = 0.
                v_rate = 0.
                v_rate1 = 0.
                v_bn = 0.
                v_sn = 0.
                v_sumkt = 0.
                run conv(input 1, input v_crck, input true,
                    input true, input-output v_sumkt, input-output v_sumkt1,
                    output v_rate1, output v_rate, output v_sn,
                    output v_bn, output m_sell, output m_buy).
            end.
            displ v_sumkt vj-label format "x(35)" no-label with frame f_main.
        end.
    end.
    else do:
        if v_u = 2 and v-select3 = 4 and VALID-OBJECT(Docu)  then do:  /* unistrim  */
            update v_countr /*v_doctype*/ v_public  with frame f_main.
            if v_crc <> 1 and v-ek = 2 then do:
                update v_sumv with frame f_main.
                v_sumt = 0.
                if v_sumv <> v_sum then do:
                /* проверка блокировки курса --------------------------------*/
                v-cur = no.
                run a_cur(input v_crc, output v-cur).
                if v-cur then undo, return.
                /*------------------------------------------------------------*/
                    v_sumt1 = v_sum - v_sumv.
                    m_buy = 0.
                    m_sell = 0.
                    v_rate = 0.
                    v_rate1 = 0.
                    v_bn = 0.
                    v_sn = 0.
                    v_sumt = 0.
                    run conv(input 1, input v_crc, input true,
                        input true, input-output v_sumt, input-output v_sumt1,
                        output v_rate1, output v_rate, output v_sn,
                        output v_bn, output m_sell, output m_buy).
                end.
                displ v_sumt  with frame f_main.
                update v_sumkv with frame f_main.
                v_sumkt = 0.
                if v_sumkv <> v_sumk then do:
                /* проверка блокировки курса --------------------------------*/
                v-cur = no.
                run a_cur(input v_crck, output v-cur).
                if v-cur then undo, return.
                /*------------------------------------------------------------*/
                    v_sumkt1 = v_sumk - v_sumkv.
                    m_buy = 0.
                    m_sell = 0.
                    v_rate = 0.
                    v_rate1 = 0.
                    v_bn = 0.
                    v_sn = 0.
                    v_sumkt = 0.
                    run conv(input 1, input v_crck, input true,
                        input true, input-output v_sumkt, input-output v_sumkt1,
                        output v_rate1, output v_rate, output v_sn,
                        output v_bn, output m_sell, output m_buy).
                end.
                displ v_sumkt vj-label format "x(35)" no-label with frame f_main.
            end.
        end.
        else do:
            update v_rnn no-label with frame f_main.
            if new_document then do:
                clear frame f_main.
                v-cifmin = "". v_rez = "". v_iin = "". v-transf = "".
                v_lname = "". v_name = "". v_mname = "". v_rez = "". v_countr = "". v_doctype = "". v_doc_num = "".
                v_docwho = "". v_docdt = ?. v_docdtf = ?. v_public = "".  v-bplace = "".  v-bdt1 = ?. v_addr = "". v_tel = "".
                v_lname1 = "". v_name1 = "". v_mname1 = "". v_rez1 = "". v_countr1 = "". v_crc = 0. v_sum = 0. v_sumkv = 0. v_sumk = 0. v_crck = 0.
                displ v-joudoc with frame f_main.
                pause 0.
            end.
            if trim(v_rnn) <> "-" then do:
                /*if v-bin = no then do:
                    find last cifmin where cifmin.rnn = v_rnn no-lock no-error.
                    if available cifmin then do:
                        v_iin = cifmin.iin.
                        update v_iin with frame f-iin.
                     end.
                end.*/
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
                        /*if not v-bin then do:
                            v_iin = rnn.bin.
                            update v_iin with frame f-iin.
                        end.*/
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
                    update v_name v_mname v_rez /*v_rez1*/ with frame f_main.
                end.
            end.
            /*if v_rez = "19" then do:
                v_countr = "KZ".
                displ v_countr with frame f_main.
                update v_doctype help " Вид документа удостовер. личность, F2-помощь " v_doc_num v_docwho v_docdt v_docdtf v_public v-bdt1 v-bplace  with frame f_main.
            end.
            else do:*/
            if v_rez = "19" and v_u <> 2 then v_countr = "KZ".
                update v_countr with frame f_main.
                find first stoplist where stoplist.code = v_countr no-lock no-error.
                if avail stoplist and stoplist.sts <> 9 then do:
                    message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
                    return.
                end.
                update v_doctype help " Вид документа удостовер. личность, F2-помощь " v_doc_num v_docwho v_docdt v_docdtf v_public v-bdt1 v-bplace  with frame f_main.
            /* end.
            repeat:
                if v_rez = "29" and v_countr = "KZ" then message "По отправителю неправильный код страны или код резидентства" view-as alert-box.
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
            displ v_addr /*v_oper*/ v_knp with frame f_main.
            update v_tel v_oper  v_lname1 v_name1 v_mname1 v_rez1 v_countr1 with frame f_main.
            find first stoplist where stoplist.code = v_countr1 no-lock no-error.
            if avail stoplist and stoplist.sts <> 9 then do:
                message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
                return.
            end.
            if v_countr1 = "CN" and v-select3 = 3 then update v-sw v-bank v-branch v-chet with frame f_main.
            /*if v-select3 = 3 then*/ update v-transf with frame f_main.
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
        end.
    end.  /* else do:*/

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
    v_crck = v_crc.
    displ v_crck with frame f_main.
    v-error = no.
    run make-comm.
    if v-error  then return.

    update v-ja no-label with frame f_main.
    if v-ja then do:
       run gen-jou.
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
    end.
end procedure.

procedure view_doc:
    update v-joudoc help "Введите номер документа, F2-помощь" with frame f_main.

    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    displ v-joudoc with frame f_main.
    pause 0.
    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    if available joudoc then do:
        find joudop where joudop.docnum = v-joudoc no-lock no-error.
        if available joudop then do:
            if joudop.type <> "TR1" + string(v-select3)  and joudop.type <> "RT1" + string(v-select3) then do:
                message "Документ не относится к типу отправление быстрых перевода системой " + v-sys view-as alert-box.
                return.
            end.
            if v-ek = 1 and joudop.type = "RT1" + string(v-select3) then do:
                message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                return.
            end.
            if v-ek = 2 and joudop.type = "TR1" + string(v-select3) then do:
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
    end.
    v_trx = joudoc.jh.
    v_sum = joudoc.dramt.
    v_crc = joudoc.drcur.
    v_arp = joudoc.cracc.
    v_sumk = joudoc.comamt.
    v_arp1 = joudoc.comacc.
    v_crck = joudoc.comcur.
    v_oper = joudoc.remark[1].
    v-transf = joudoc.transf.
    /*v_comcode = joudoc.comcode.*/
    /*v_oper = substring(joudoc.remark[1],1,38).
    v_oper1 = substring(joudoc.remark[1],39,length(joudoc.remark[1]) - 39).*/
    v-cifmin = joudoc.kfmcif.
    v-benName = trim(joudop.lname).
    if num-entries(v-benName) = 5 then do:
        v_lname1 = entry(1,v-benName).
        v_name1 = entry(2,v-benName).
        v_mname1 = entry(3,v-benName).
        v_countr1 = entry(4,v-benName).
        v_rez1 = entry(5,v-benName).
     end.
     else v_lname1 = v-benName.
    if v_countr1 = "CN" and (v-select3 = 3  or v-select3 = 4) then do:
        v-sw = entry(1,joudop.mname,"^").
        v-bank = entry(2,joudop.mname,"^").
        v-branch = entry(3,joudop.mname,"^").
        v-chet = entry(4,joudop.mname,"^").
        /*displ v-sw v-bank v-branch v-chet with frame f_main.*/
    end.
    find last cifmin where cifmin.cifmin = v-cifmin no-lock no-error.
    if not avail cifmin then do:
        message "CIFMIN-код клиента не найден, продолжение невозможно!" view-as alert-box.
        undo.
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
    v-bdt1 = cifmin.bdt.
    v-bplace  = cifmin.bplace.
    v_docwho = cifmin.docwho.
    v_addr = cifmin.addr.
    v_tel = cifmin.tel.
    v_doctype = cifmin.doctype.
    if cifmin.res = "1" then v_rez = "19". else v_rez = "29".
    v_countr = cifmin.public.
    v_public = cifmin.publicf.
    find first arp where arp.arp = v_arp and arp.crc = v_crc no-lock no-error.
    if available arp then do:
        v_arpname = arp.des.
        if v_kt <> arp.gl then do:
            message "Счет Г/К по кредиту не совпадает с типом системы перевода, продолжение невозможно!" view-as alert-box.
            return.
        end.
    end.
    else do:
        message "Счет кредита в ARP не найден, продолжение невозможно!" view-as alert-box.
        undo.
    end.
    find first joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        v_sumv = joudop.amt.
        v_sumt = joudop.amt1.
        v_sumkv = joudop.amt2.
        v_sumkt = joudop.amt3.
    end.
    else do:
        message "Не найдена валюта внесения, продолжение невозможно!" view-as alert-box.
        undo.
    end.
    displ v-label format "x(18)" no-label v_rnn format "x(12)" no-label v_trx v_lname v_name v_mname   v_doc_num v_docdt v_docdtf v_public v-bdt1 v-bplace
            v_docwho v_addr v_tel v_knp v_doctype v_rez v_countr
          v_lname1 v_name1 v_mname1 v_rez1 v_countr1 v-transf v_crc /*v_crcv*/ v_sum v_sumv v_sumt v_sumkv v_sumkt v_crck v_sumk
          v_oper /*v_oper1*/ v_dt v_dtk v_kt v_ktk v_arp v_arpname v_arp1 /*v_comcode*/ with frame f_main.
    pause 0.
    if v_countr1 = "CN" and (v-select3 = 3  or v-select3 = 4) then displ v-sw v-bank v-branch v-chet with frame f_main.
    pause 0.
    if v_crc <> v_crck then displ /*v_crccode*/ v_sumkv  with frame f_main.
    pause 0.
end procedure.

Procedure Delete_document.
    vj-label  = " Удалить документ?..................".
    v_title = " БЫСТРЫЕ ПЕРЕВОДЫ (отправление перевода)" + v-sys.
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
        pause 0.
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
end procedure.

procedure Create_transaction:
    vj-label  = " Выполнить транзакцию?..................".
    v_title = " БЫСТРЫЕ ПЕРЕВОДЫ (отправление перевода)" + v-sys.
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
    if v-select3 = 3  or v-select3 = 4   then do:
        find first cursts no-lock no-error.
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
    if joudop.amt1 <> 0 or joudop.amt3 <> 0 then do:
        /* проверка блокировки курса --------------------------------*/
        if joudop.amt1 <> 0 then do:
            v-cur = no.
            run a_cur(input v_crc, output v-cur).
            if v-cur then undo, return.
        end.
        if joudop.amt3 <> 0 then do:
            v-cur = no.
            run a_cur(input v_crck, output v-cur).
            if v-cur then undo, return.
        end.
        /*------------------------------------------------------------*/
        def var inf1 as logic.
        def var inf3 as logic.
        inf1 = false.
        inf3 = false.
        if joudop.amt1 <> 0  then do:
            find first crc where crc.crc = v_crc no-lock.
            /*run savelog("checkrate", "a_transf1 ; docnum = " + v-joudoc  + "crc = " + string(crc.crc) + " rate doc: "  + string(joudoc.srate)  + " ; rate in table crc: " + string(crc.rate[3]) )  .*/
            if joudoc.srate <> crc.rate[3] then do:
                inf1 = true.
                v_sumt1 = v_sum - v_sumv.
                m_buy = 0.
                m_sell = 0.
                v_rate = 0.
                v_rate1 = 0.
                v_bn = 0.
                v_sn = 0.
                v_sumt = 0.
                run conv(input 1, input v_crc, input true,
                    input true, input-output v_sumt, input-output v_sumt1,
                    output v_rate1, output v_rate, output v_sn,
                    output v_bn, output m_sell, output m_buy).
            end.
        end.
        if joudop.amt3 <> 0  then do:
            find first crc where crc.crc = v_crck no-lock.
            /*run savelog("checkrate", "a_transf1 комиссия ; docnum = " + v-joudoc  + "crc = " + string(crc.crc) + " rate doc: "  + string(joudoc.srate)  + " ; rate in table crc: " + string(crc.rate[3]) )  .*/
            if joudoc.srate <> crc.rate[3] then do:
                inf3 = true.
                v_sumkt1 = v_sumk - v_sumkv.
                v_sumkt = 0.
                m_buy = 0.
                m_sell = 0.
                v_rate = 0.
                v_rate1 = 0.
                v_bn = 0.
                v_sn = 0.
                run conv(input 1, input v_crck, input true,
                    input true, input-output v_sumkt, input-output v_sumkt1,
                    output v_rate1, output v_rate, output v_sn,
                    output v_bn, output m_sell, output m_buy).
            end.
        end.
        if inf1 or inf3 then do:
            message "Изменился курс покупки валют, сумма в тенге будет пересчитана." view-as alert-box.
            displ v_sumt v_sumkt with frame f_main.
            find first joudoc where joudoc.docnum = v-joudoc exclusive-lock.
            joudoc.srate = crc.rate[3].
            find first joudoc where joudoc.docnum = v-joudoc no-lock.
            find first joudop where joudop.docnum = v-joudoc exclusive-lock.
            if inf1 then joudop.amt1 = v_sumt.
            if inf3 then joudop.amt3 = v_sumkt.
            find first joudop where joudop.docnum = v-joudoc no-lock.
            return.
        end.
    end.
    /*---------------------------------------------------------------------------------------*/
    /*комплаенс*/
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
    pause 0.
    update v-ja no-label with frame f_main.
    if not v-ja  then do:
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide frame f_main.
        return.
    end.
    if v_rez = "19" then v_r = "1". else v_r = "2".
    if v_rez1 = "19" then v_r1 = "1". else v_r1 = "2".

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
            /*------------------------------------------------------------------------------------------*/
        if v_crc = 1 or v_sum = v_sumv then do:
            v-tmpl = "JOU0055".
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_arp + vdel + v_oper + vdel + v_r + vdel + v_r1 + vdel + "9" + vdel + "9" + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
        else do:
            v-tmpl = "JOU0055".
            v-param = v-joudoc + vdel + string(v_sumv) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_arp + vdel + v_oper
                + vdel + v_r + vdel + v_r1 + vdel + "9"  + vdel + "9" + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            /* обрабатываем конвертируем сумму в тенге */
            v-tmpl = "JOU0069".
            v-param = v-joudoc + vdel + string(v_sumt) + vdel + "1" + vdel + v-chEK1 + vdel + "обмен валюты" +
                    vdel + v_r + vdel + v_r + vdel + "9" + vdel + "9" + vdel + "223" /*+ vdel + string(v_sum - v_sumv)*/ + vdel +
                    string(v_crc) + vdel + v-chEK .
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.

            v-tmpl = "JOU0055".
            v-param = v-joudoc + vdel + string(v_sum - v_sumv) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_arp + vdel + v_oper
                + vdel + v_r + vdel + v_r1 + vdel + "9" + vdel + "9" + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.

            /* для комиссии--------------------------------------------*/
            if v_sumk <> 0 then do:
                if v_crck = 1 or v_sumk = v_sumkv then do:
                    v-tmpl = "jou0055".
                    v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crck) + vdel + v-chEK + vdel + v_arp + vdel +
                    "Комиссия за: " + v_oper + vdel + v_r + vdel + v_r1 + vdel + "9" + vdel + "9" + vdel + v_knp.
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                end.
                else do:
                    v-tmpl = "jou0055".
                    v-param = v-joudoc + vdel + string(v_sumkv) + vdel + string(v_crck) + vdel + v-chEK + vdel + v_arp + vdel +
                    "Комиссия за: " + v_oper + vdel + v_r + vdel + "1" + vdel + "9" + vdel + "4" + vdel + "840".
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                    /* обрабатываем конвертируем сумму комиссии в тенге */
                    v-tmpl = "JOU0069".
                    v-param = v-joudoc + vdel + string(v_sumkt) + vdel + "1" + vdel + v-chEK1 + vdel + "обмен валюты" +
                            vdel + v_r + vdel + v_r + vdel + "9" + vdel + "9" + vdel + "223" /*+ vdel + string(v_sumk - v_sumkv)*/ + vdel +
                            string(v_crc) + vdel + v-chEK .
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                    v-tmpl = "JOU0055".
                    v-param = v-joudoc + vdel + string(v_sumk - v_sumkv) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_arp + vdel + "Комиссия за: " + v_oper
                        + vdel + v_r + vdel + "1" + vdel + "9" + vdel + "4" + vdel + "840".
                    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                end.
            end.
            find first arp no-lock no-error.

        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error .
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
      run chgsts(m_sub, v-joudoc, "trx").
    end.

    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do :
        s-jh = 0.
            v-tmpl = "JOU0007".
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v_arp + vdel + v_oper +
            vdel + v_r + vdel + v_r1 + vdel + "9" + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.

        /** komisija **/
        if joudoc.comamt ne 0 then do:
            v-tmpl = "JOU0054".
            v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crck) + vdel + v_arp + vdel + "Комиссия за: " + v_oper +
            vdel + v_r + vdel + "1" + vdel + "9" + vdel + "4" + vdel + "840".
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
        run chgsts(m_sub, v-joudoc, "trx").
        run chgsts("jou", v-joudoc, "cas").
        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error .
        joudoc.jh = s-jh.
        find current joudoc no-lock no-error.
        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
    end.  /* end v-ek = 1 ---------*/
       /*---------------------------------------------------------*/
    pause 1 no-message.
    /* копируем заполненные данные по ФМ в реальные таблицы*/
    if v-kfm then do:
        run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
        hide all no-pause.
        view frame f_main.
    end.
    /**/
    v_trx = s-jh.

    if v_sumt <> 0 or v_sumkt <> 0 or v_crc = 1 or v_crck = 1 then do:
        /*x0-cont*/
        for each jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = 100500 or jl.gl = 100100) no-lock:
            if jl.gl = 100500 then find first b-jl where b-jl.jh = jl.jh and b-jl.ln = if jl.dc = 'D' then jl.ln + 1 else jl.ln - 1 no-lock no-error.
            if avail b-jl and lookup(string(b-jl.gl),'185800,185900,285800,285900') > 0 then v-conv = false.

            create jlsach .
            jlsach.jh = s-jh.
           if jl.dc = "d" then jlsach.amt = jl.dam .
                          else jlsach.amt = jl.cam .
            jlsach.ln = jl.ln .
            jlsach.lnln = 1.
            if v_countr1 = "KZ" then do:
                if jl.dc = "c" and jl.cam = v_sumkt and v_sumkt <> 0 then jlsach.sim = if v-conv = yes then 100 else 030.
                if jl.dc = "d" and jl.dam = v_sumkt and v_sumkt <> 0 then jlsach.sim = if v-conv = yes then 100 else 030.
                if jl.dc = "c" and jl.cam = v_sumt and v_sumt <> 0 then jlsach.sim = if v-conv = yes then 050 else 030.
                if jl.dc = "d" and jl.dam = v_sumt and v_sumt <> 0 then jlsach.sim = if v-conv = yes then 050 else 030.

                if jl.dc = "c" and jl.cam = v_sumk and v_sumk <> 0 then jlsach.sim = if v-conv = yes then 100 else 030.
                if jl.dc = "d" and jl.dam = v_sumk and v_sumk <> 0 then jlsach.sim = if v-conv = yes then 100 else 030.
                if jl.dc = "c" and jl.cam = v_sum and v_sum <> 0 then jlsach.sim = if v-conv = yes then 050 else 030.
                if jl.dc = "d" and jl.dam = v_sum and v_sum <> 0 then jlsach.sim = if v-conv = yes then 050 else 030.
            end.
            else do:
                if jl.dc = "c" and jl.cam = v_sumkt and v_sumkt <> 0 then jlsach.sim = if v-conv = yes then 100 else 030.
                if jl.dc = "d" and jl.dam = v_sumkt and v_sumkt <> 0 then jlsach.sim = if v-conv = yes then 100 else 030.
                if jl.dc = "c" and jl.cam = v_sumt and v_sumt <> 0 then jlsach.sim = if v-conv = yes then 060 else 030.
                if jl.dc = "d" and jl.dam = v_sumt and v_sumt <> 0 then jlsach.sim = if v-conv = yes then 060 else 030.

                if jl.dc = "c" and jl.cam = v_sumk and v_sumk <> 0 then jlsach.sim = if v-conv = yes then 100 else 030.
                if jl.dc = "d" and jl.dam = v_sumk and v_sumk <> 0 then jlsach.sim = if v-conv = yes then 100 else 030.
                if jl.dc = "c" and jl.cam = v_sum and v_sum <> 0 then jlsach.sim = if v-conv = yes then 060 else 030.
                if jl.dc = "d" and jl.dam = v_sum and v_sum <> 0 then jlsach.sim = if v-conv = yes then 060 else 030.
            end.
            release jlsach.
        end.
    end.
    if v-noord = yes then run printvouord(2).
    if v-noord = yes then run printord(s-jh,"").
    display v_trx with frame f_main.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.

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

    s-jh = joudoc.jh.
    run vou_word(2, 1, joudoc.info).
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
        message "".
        run sel1("Выберите Фамилию", famlist).
        if keyfunction(lastkey) = "end-error" then return.
        result = entry(1,return-value," ").
        hide message no-pause.
    end.
end procedure.


procedure gen-jou:
    /*подключение comm */
    find sysc where sysc.sysc = 'CMHOST' no-lock no-error.
    if avail sysc then connect value (sysc.chval) no-error.
    if v-cifmin = "" then do:
            create cifmin.
            cifmin.cifmin = 'cm' + string(next-value(cmnum),'99999999').
            v-cifmin = cifmin.cifmin.
            cifmin.rwhn = g-today.
            cifmin.rwho = g-ofc.
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
    cifmin.publicf = v_public.
    cifmin.doctype = v_doctype.
    cifmin.fam = v_lname.
    cifmin.name = v_name.
    cifmin.mname = v_mname.
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
            end.
        end.
        if v-chEK = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.

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
        find first arp no-lock no-error.
    end.

    if new_document then do:
        create joudoc.
        joudoc.docnum = v-joudoc.
        create joudop.
        joudop.docnum = v-joudoc.
        if VALID-OBJECT(Doc) and v-select3 = 3 then joudoc.rescha[5] = "ZK " + string(Doc:TransferStatus) + " " + Doc:UIN.

        if VALID-OBJECT(Docu) and v-select3 = 4 then joudoc.rescha[5] = "UN " + string(Docu:TransferStatus) + " " + Docu:UIN.
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
    joudoc.drcur = v_crc.
    joudoc.cramt = v_sum.
    joudoc.cracctype = "4".
    joudoc.cracc = v_arp.
    joudoc.crcur = v_crc.
    joudoc.comamt = v_sumk.
    if v-ek = 2 then joudoc.comacctype = "4". else joudoc.comacctype = "1".
    joudoc.comacc = v_arp.
    joudoc.comcur = v_crck.
    joudoc.comcode = "302". /*v_comcode.*/
    joudoc.bas_amt = "D".
    joudoc.remark[1] = v_oper. /* + v_oper1.*/
    joudoc.chk = 0.
    if v-ek = 1 then joudop.type = "TR1" + string(v-select3). else joudop.type = "RT1" + string(v-select3).
    joudoc.transf = v-transf.
    joudoc.info = v_lname + " " + v_name + " " + v_mname.
    joudoc.passp = v_doc_num + "," + v_docwho.
    joudoc.perkod = v_rnn.
    joudoc.passpdt = v_docdt.
    joudoc.kfmcif = v-cifmin.
    joudoc.benName = trim(v_lname1) + " " + trim(v_name1) + " " + trim(v_mname1).
    if v_crc = 1 then joudoc.srate = 1.
    else do:
        find first crc where  crc.crc = v_crc no-lock no-error.
        joudoc.srate = crc.rate[3].
        joudoc.sn = 1.
    end.
    joudoc.brate = 1.
    run chgsts("JOU", v-joudoc, "new").
    find current joudoc no-lock no-error.
    joudop.who = g-ofc.
    joudop.whn = g-today.
    joudop.tim = time.
    joudop.amt = v_sumv.
    joudop.amt1 = v_sumt.
    joudop.amt2 = v_sumkv.
    joudop.amt3 = v_sumkt.
    joudop.lname = trim(v_lname1) + "," + trim(v_name1) + "," + trim(v_mname1) + "," + trim(v_countr1) + "," + trim(v_rez1).
    if v_countr1 = "CN" and (v-select3 = 3  or v-select3 = 4) then joudop.mname = trim(v-sw) + "^" + trim(v-bank) + "^" + trim(v-branch) + "^" + trim(v-chet).

    find current joudop no-lock no-error.
    displ v-joudoc with frame f_main.
    pause 0.
    if v-select3 = 3 or v-select3 = 4 then do:
        MESSAGE "Необходим контроль в п.м. 2.4.1.1! 'Контроль документов'!"  view-as alert-box.
        for each sendod no-lock.
            run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
            "Добрый день!\n\n Необходимо отконтролировать отправление быстрого перевода \n Сумма: " + string(v_sum) +
            "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
            string(time,"HH:MM"), "1", "","" ).
        end.
        hide all.
        view frame f_main.
    end.
end procedure.

procedure make-comm:
    find first arp where arp.gl = v_kt and arp.crc = v_crc and length(arp.arp) >= 20 no-lock no-error.
    if available arp then do:
        v_arp = arp.arp.
        v_arpname = arp.des.
        displ v_dt format "999999" v_kt format "999999" v_arp v_arpname with frame f_main.
    end.
    else do:
        message "ARP счет кредита не найден, продолжение невозможно!" view-as alert-box.
        v-error = yes.
        return.
    end.
    v_arp1 = v_arp.
    displ v_dtk format "999999" v_ktk format "999999" v_arp1 v_arpname with frame f_main.
    /*if v-select3 = 3 and v_countr1 <> "CN" then v_sumk = round((v_sum * 0.015),2).*/ /*золотая корона*/
    if v-select3 = 3 and v_countr1 = "CN" then v_sumk = round(crc-conv(25, 2, v_crck),2). /*золотая корона для Китая 25 долларов US*/
    /*if v-select3 = 2 then do: */ /* быстрая почта*/
       /* v_sumk = round((v_sum * 0.014),2).
        if round(crc-conv(decimal(v_sumk), v_crck, 2),2) < 5  then v_sumk = round(crc-conv(5, 2, v_crck),2).
    end.*/
    update v_sumk  with frame f_main.
    if v_crc <> 1 and v-ek = 2 then do:
        update v_sumv with frame f_main.
        v_sumt = 0.
        if v_sumv <> v_sum then do:
            /* проверка блокировки курса --------------------------------*/
            v-cur = no.
            run a_cur(input v_crc, output v-cur).
            if v-cur then do:
                v-error = yes.
                 return.
            end.
            /*------------------------------------------------------------*/
            v_sumt1 = v_sum - v_sumv.
            m_buy = 0.
            m_sell = 0.
            v_rate = 0.
            v_rate1 = 0.
            v_bn = 0.
            v_sn = 0.
            v_sumt = 0.
            run conv(input 1, input v_crc, input true,
                input true, input-output v_sumt, input-output v_sumt1,
                output v_rate1, output v_rate, output v_sn,
                output v_bn, output m_sell, output m_buy).
        end.
        displ v_sumt  with frame f_main.
        update v_sumkv with frame f_main.
        v_sumkt = 0.
        if v_sumkv <> v_sumk then do:
            /* проверка блокировки курса --------------------------------*/
            v-cur = no.
            run a_cur(input v_crck, output v-cur).
            if v-cur then do:
                v-error = yes.
                 return.
            end.
            /*------------------------------------------------------------*/
            v_sumkt1 = v_sumk - v_sumkv.
            m_buy = 0.
            m_sell = 0.
            v_rate = 0.
            v_rate1 = 0.
            v_bn = 0.
            v_sn = 0.
            v_sumkt = 0.
            run conv(input 1, input v_crck, input true,
                input true, input-output v_sumkt, input-output v_sumkt1,
                output v_rate1, output v_rate, output v_sn,
                output v_bn, output m_sell, output m_buy).
        end.
        displ v_sumkt  with frame f_main.
    end.
    displ v-joudoc vj-label  no-label with frame f_main.

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
        if v-errmsg <> "" then message  v-errmsg view-as alert-box error.
        undo, return.
    end.
    run chgsts(m_sub, v-joudoc, "rdy").
    message "Проводка отштампована " view-as alert-box.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").*/
end procedure.

/** Признаки **/
procedure a_subcod:
    run subcodj (v-joudoc, "jou").
    view frame f_main.
end procedure.

/*--------------------------------------------------------------*/
procedure sc:

    TCIFNAME = "TCIFNAME=" + UrlEncode(v_lname) + " " + UrlEncode(v_name) + " " + UrlEncode(v_mname).
    TINN = "TINN=" + v_rnn.
    TKOD = "TKOD=" + v_rez.
    /*TSUMM = "TSUMM=" + string(v_sum).*/
    TSUMM = "TSUMM=" + replace(trim(string(v_sum,'->>>>>>>>>>>>>>9.99')),'.',',').
    TCRC = "TCRC=" + getcrc(v_crc).
    /*TCOMSUMM = "TCOMSUMM=" + string(v_sumk).*/
    TCOMSUMM = "TCOMSUMM=" + replace(trim(string(v_sumk,'->>>>>>>>>>>9.99')),'.',',').
    TCOMCRC = "TCOMCRC=" + getcrc(v_crck).
    TRECNAME = "TRECNAME=" + UrlEncode(v_lname1) + " " + UrlEncode(v_name1) + " " + UrlEncode(v_mname1).
    TKBE = "TKBE=" + v_rez1.
    TRECAAA = "TRECAAA=" + v-chet.
    TRBANK = "TRBANK=" + UrlEncode(v-bank).
    TREM = "TREM=" + UrlEncode(v_oper).
    TKNP = "TKNP=" + v_knp.
    TSYSTEM  = "TSYSTEM=" + substring(v-sys,11,20).

    find first codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc" and codfr.code = v_countr1 no-lock no-error.
    if avail codfr then
    TRECCOUNTRY = "TRECCOUNTRY=" + codfr.name[1].

    v-res111 = TCIFNAME + "&" + TINN + "&" + TKOD + "&" + TSUMM + "&" + TCRC + "&" + TCOMSUMM + "&" + TCOMCRC + "&" + TRECNAME + "&" + TKBE + "&" + TRECAAA + "&" + TRBANK + "&" + TREM + "&" + TKNP + "&" + TSYSTEM + "&" + TRECCOUNTRY.

    CurPage = 1.
    PosPage = 1.
    MaxPage = 2.

    Pages = "1 из " + string(MaxPage).
    DISPLAY Pages Mask WITH FRAME Form1.

    run to_screen("qtransfer1", v-res111).

    ON CHOOSE OF next-button
    DO:
        PosPage = PosPage + 1.
        if PosPage > MaxPage then PosPage = MaxPage.
        Pages = string(PosPage) + " из " + string(MaxPage).

        if PosPage = 1 then do:
            run to_screen("qtransfer1", v-res111).
        end.
        else do:
            run to_screen("qtransfer2", v-res111).
        end.
        DISPLAY Pages Mask WITH FRAME Form1.
    END.

    ON CHOOSE OF prev-button
    DO:
        PosPage = PosPage - 1.
        if PosPage <= 0 then PosPage = 1.
        Pages = string(PosPage) + " из " + string(MaxPage).

        if PosPage = 1 then do:
            run to_screen("qtransfer1", v-res111).
        end.
        else do:
            run to_screen("qtransfer1", v-res111).
        end.
        DISPLAY Pages Mask WITH FRAME Form1.
    END.

    ON CHOOSE OF close-button
    DO:
        run to_screen( "default","").
        apply "endkey" to frame Form1.
        hide frame Form1.
        return.
    END.


    DISPLAY Pages prev-button next-button close-button WITH FRAME Form1.
    ENABLE next-button  prev-button  close-button WITH FRAME Form1.

    WAIT-FOR endkey of frame Form1.
    hide frame Form1.
end procedure.
/*--------------------------------------------------------------*/

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
