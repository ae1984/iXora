/* a_foreing1.p
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
        03.02.2012  Luiza  - в свифт макет добавила дату валютирования и бик банка
        06/02/2012  Luiza  - перекомпиляция
        08/02/2012  Luiza  -  добавила вывод номера документа
        17.02.2012  Lyubov - зашила символы кассплана согласно ТЗ № 1268
        06/03/2012  Luiza  - добавила возможность выбора валюты комиссии
        07/03/2012  Luiza  - изменила передачу параметров при вызове printord
        11.03.2012  damir - добавил печать оперционного ордера, printvouord.p.
        12/03/2012  Luiza - добавила подключение comm
        13/03/2012  Luiza - если rmz документ не создался все откатываем.
        14/03/2012  Luiza - если нет банка корресп тип для 56 поля ставим "N"
        19/03/2012 Luiza  - если тестовая база клиента finmon не вызываем
        20/03/2012 Luiza  - вызов функции isProductionServer выполняем в a_fimnon.i
        02.04.2012 Lyubov - подправила алгоритм проставления символа кассплана
        05/04/2012 Luiza  - изменила заполнение поля 50 для не росс руб
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        17/04/2012 Luiza - добавила код комиссии 262
        24/04/2012 luiza - изменила создание мини карточки
        24/04/2012 evseev - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
        03/05/2012 Luiza  - добавила поле срок действия УЛ
        05.05.2012 damir  - добавлены a_foreign1printapp.i. Новые форматы заявлений.
        07/05/2012 Luiza  - в процедуре swift_open вызываем prtpp
        08/05/2012 Luiza  - в процедуре swift_open вызываем tswprns
        14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
        15/05/2012 Luiza  - увеличила формат валюты до 2-х знаков
        05.06.2012 damir  - перекомпиляция.
        28/06/2012 Luiza  - изменила формат для вывода на эран номера транзакции
        10/07/2012 dmitriy - вывод на экран клиента
        12/07/2012 dmitriy - вывод на экран клиента только для филиалов, прописанных в sysc = "CifScr"
        25/072012  Luiza   - изменила проверку суммы при работе с ЕК
        26/07/2012 Luiza   - слово ЕК заменила ЭК
        31/07/2012 Luiza  - возможность выбора валюты для комиссии
        17/08/2012 Luiza  - согласно СЗ добавила проверку курса на момент транзакции
        04/09/2012 Luiza - согласно СЗ для бик FOBAKZKA транспорт 5
        10/09/2012 Luiza подключила {srvcheck.i}
        13/09/2012 Luiza отменила ecxlusive-lock для crc.
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        23.11.2012 Lyubov - ТЗ № 1573, изменила список видов документов, увеличина кол-во строк для b-doc
        11.12.2012 Lyubov - ТЗ № 1618, проставление символа кас. плана 030 при внесении суммы в тг
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.Перекомпиляция в связи с изменениями в a_foreign1printapp.i.
        18/01/2013 Luiza - ТЗ 1595 Изменение счета ГК 1858 изменила шаблон обмена на jou0069
        11/03/2012 Luiza - ТЗ 1623 проверка контрольного разряда ИИН
        13/02/2013 Luiza - заменила шаблон jou0007 на jou0048
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        05/04/2013 Luiza -  ТЗ № 1764 проверка признака блокирования валют при обменных операциях
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        06/08/2013 Luiza - ТЗ 1997 Расширение поля «Код тарифа»
        22/10/2013 Luiza - ТЗ 2003
*/


{global.i}

{adres.f}
{chbin.i}

define input parameter new_document as logical.
def new shared var  s-remtrz like remtrz.remtrz.
def new shared var m_pid like bank.que.pid.
def new shared var v-text as char.
def new shared var m_hst as char.
def new shared var m_copy as char.
def new shared var u_pid as cha.

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

def var v-tmpl as char no-undo.
def var v-conv as logi no-undo init yes.

def shared var v_u as int no-undo.
define variable m_sub as character initial "jou".
def var v_tmpl as char no-undo.
def var vdel as char no-undo initial "^".
def var v_param as char no-undo.
def var vparam as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
define new shared variable s-jh like jh.jh.
def var v_dt1 as int .
def var v_kt1 as int init 287032.
def var v_dt2 as int init 287032.
def var v_kt2 as int init 255120.
def var v_dt3 as int init 255120.
def var v_kt3 as int init 105220.
def var v_dtk as int .
def var v_ktk as int init 460122.
def var v_arp1 as char no-undo.
def var v_arp2 as char no-undo.
def  var v_title as char no-undo. /*наименование платежа */
def  var v-doc as char no-undo format "x(9)".
def  var v_doc as char no-undo format "x(10)".
def  var v_docdoc as char no-undo format "x(9)".
def  var v_dtype as char init "Заявление на перевод в иностранной валюте".
def  var v_dock as char no-undo format "x(10)".
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
def  var v_doctype as char no-undo.
def  var v_doc_num as char no-undo.
def  var  v_docwho as char no-undo.
def  var v_docdt as date no-undo.
def  var v_docdtf as date no-undo.
def  var v_addr as char no-undo format "x(75)".
def  var v_tel as char no-undo format "x(27)".
def  var v-bplace as char no-undo.
def  var v-bdt1 as date no-undo.
def  var v_public as char no-undo. /* признак ИПДЛ */
def  new shared var v_oper as char no-undo format "x(140)".
def  var v_oper1 as char no-undo format "x(140)".
def  var v_oper2 as char no-undo format "x(50)".
/*def  var v_oper3 as char no-undo format "x(50)".*/
def  var v_knp as char no-undo.
def  var v_rez1 as char no-undo.
def  var v_rez2 as char no-undo.
def new shared var v_crc as int  no-undo format "9".
def var v_sum as decimal no-undo format ">>>,>>>,>>>,>>>,>>9.99".
def var v_crcv as int  no-undo format "9".
def  var v_sumv as decimal no-undo format ">>>,>>>,>>>,>>>,>>9.99".
def  var v_sumt as decimal no-undo format ">>>,>>>,>>>,>>>,>>9.99".
def  var v_sumt1 as decimal no-undo format ">>>,>>>,>>>,>>>,>>9.99".
def  var v_sum_lim as decimal no-undo. /* сумма*/

def  var v_crck as int  no-undo format "9" init 1.
def  var v_sumk as decimal no-undo format ">>>,>>>,>>>,>>9.99".
def  var v_sumkv as decimal no-undo format ">>>,>>>,>>>,>>9.99".
def  var v_sumkt as decimal no-undo format ">>>,>>>,>>>,>>9.99".
def  var v_sumkt1 as decimal no-undo format ">>>,>>>,>>>,>>9.99".
def  var v_arp as char no-undo.
def  var v_ja as logi no-undo format "Да/Нет" init yes.
def  var v_label as char no-undo.
def  var vj-label as char no-undo.
def  var v-cifmin as char no-undo.
def  var v_comcode as char no-undo format "x(5)".
def  var v_ben as char no-undo format "x(3)".
def  var com_rec as recid.
def  var v_index as int.
def  var v_ind as int.
def  var v_length as int.
def  var v_benName as char no-undo.
def var v_trx as int no-undo.
define variable jou_p as character NO-UNDO.
define variable yn as logical no-undo.
define variable com_tmpl as character NO-UNDO.
define variable contrl  as logical no-undo.
def var vdummy as char no-undo.
def var templ-com as char no-undo.
def var v_tarif as char no-undo.
define variable v_cash   as logical no-undo.
define variable v_acc   as logical no-undo.
define variable v_sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
def new shared var v_bank as char format "x(50)" init "" no-undo.
def new shared var v_numch1 as char format "x(50)" init "" no-undo.
def new shared var v_bank1 as char format "x(50)" init "" no-undo.
def new shared var v_bank2 as char format "x(50)" init "" no-undo.
def new shared var v_chpol as char format "x(50)" init "" no-undo.
def new shared var v_innpol as char format "x(12)" init "" no-undo.
def new shared var v_namepol as char format "x(50)" init "" no-undo.
def new shared var v_swcod as char format "x(1)"  init "D" no-undo.
def new shared var v_swcity as char format "x(35)" init "" no-undo.
def new shared var v_swcnt as char format "x(35)" init "" no-undo.
def new shared var v_swcod1 as char format "x(1)"  init "D" no-undo.
def new shared var v_swcity1 as char format "x(35)" init "" no-undo.
def new shared var v_swcnt1 as char format "x(35)" init "" no-undo.
def new shared var v_swbic as char format "x(35)" no-undo.
def new shared var v_swbic1 as char format "x(35)" no-undo.
def new shared var v_countr1 as char  format "x(2)" no-undo.
def var v_eng as logic.
def var v-sts as integ.
def var v_er1 as int init 0 no-undo. /* признак ошибки*/
def var l-ans    as logical no-undo.
def var v-dat2 as date format "99/99/9999".

define variable m_buy   as decimal.
define variable m_sell  as decimal.
def var v_rate as decim.
def var v_rate1 as decim.
def var v_bn as int.
def var v_sn as int.
define new shared variable vrat  as decimal decimals 4.
def var v-cur as logic no-undo.

/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-crc_valk as char no-undo format "xxx".
def var v-crc_valv as char no-undo format "xxx".
def var v-chEKv as char format "x(20)". /* счет ЭК*/
def var v-chEK as char format "x(20)". /* счет ЭК*/
def var v-chEK1 as char format "x(20)". /* счет ЭК*/
def var v-chEKk as char format "x(20)". /* счет ЭК for comis*/
/*------------------------------------*/


def var v_kbe as char.
def var v_bnk as char.

def var cbo_dep as int.
def var ind as int.
def var ss as char.
def var v_joudock as char.
def var v_rmzdoc as char.
def var v_joutrx as int.
def var v_jouktrx as int.
def var v_rmztrx as int.
def var v_upd as logi.
define variable v-cash   as logical no-undo.
define variable v-acc   as logical no-undo.
def shared var v-joudoc as char no-undo format "x(10)".
def shared var v-Get_Nal as logic.

/* для комиссии*/
def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.
def var v_sumc as decim format ">>>>>>>>>>>>>>9.99".
def  var v_crccode as char no-undo.
def var famlist as char init "".
def var I as int init 0.
def var v-int as decim.
def var v-mod as decim.
def var v-modc as decim.
def var v-int1 as decim.
def var v-mod1 as decim.
def var v-modc1 as decim.
def var v_sum1 as decim.
def var v-ind as int.
def var v-len as int.

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
def var v-knpval as char no-undo.
def  var v-benName as char no-undo.

define button but label " "  NO-FOCUS.
/*----------------*/

def stream v-out.
def var v-file      as char init "Application.htm".
def var v-inputfile as char init "".
def var v-naznplat  as char.
def var v-str       as char.
def var decAmount   as deci decimals 2.
def var strAmount   as char init "".
def var temp        as char init "".
def var str1        as char init "".
def var str2        as char init "".
def var strTemp     as char init "".
def var numpassp    as char. /*Номер Удв*/
def var whnpassp    as char. /*Когда выдан*/
def var whopassp    as char. /*Кем выдан*/
def var perpassp    as char. /*Срок действия*/
def buffer b-sernumdoc for sernumdoc.

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
def var TRBANKBIK as char.
def var TVALDATE as char.
def var sr-ans as logic.
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

define stream rep.

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

function rus-eng1 returns char (str as char).
    define var outstr as char.
    def var rus as char extent 32 init
    ["А","Б","В","Г","Д","Е", "Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф", "Х","Ц","Ч","Ш","Щ","Ъ","Ы", "Ь", "Э", "Ю", "Я"].
    def var eng as char    extent 32 init
    ["A","B","V","G","D","E","J","Z","I","i","K","L","M","N","O","P","R","S","T", "U","F", "H","C","c","Q","q","x","Y","X","e","u","a"].
    def var i as integer.
    def var j as integer.
    def var ns as log init false.
    def var slen as int.
    str = caps(str).
    slen = length(str).

    repeat i=1 to slen:
     repeat j=1 to 32:
       if substr(str,i,1) = rus[j] then
       do:
          outstr = outstr + eng[j].
          ns = true.
       end.
     end.
     if not ns then outstr = outstr + substr(str,i,1).
     ns = false.
    end.
    return outstr.
end.

function rus-eng2 returns char (str2 as char).
    define var outstr2 as char.
    def var rus2 as char extent 32 init
    ["А","Б","В","Г","Д","Е", "Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф", "Х","Ц", "Ч", "Ш", "Щ", "Ъ","Ы", "Ь", "Э", "Ю", "Я"].
    def var eng2 as char  extent 32 init
    ["A","B","V","G","D","E","ZH","Z","I","J","K","L","M","N","O","P","R","S","T","U","F","KH","C","CH","SH","SCH","","Y","","E","YU","YA"].

    def var i2 as integer.
    def var j2 as integer.
    def var ns2 as log init false.
    def var slen2 as int.
    str2 = caps(str2).
    slen2 = length(str2).

    repeat i2 = 1 to slen2:
     repeat j2 = 1 to 32:
       if substr(str2,i2,1) = rus2[j2] then
       do:
          outstr2 = outstr2 + eng2[j2].
          ns2 = true.
       end.
     end.
     if not ns2 then outstr2 = outstr2 + substr(str2,i2,1).
     ns2 = false.
    end.
    return outstr2.
end.

def buffer b-sysc for sysc.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
v_bnk = trim(sysc.chval).
/*find first ppoint no-lock no-error.
cbo_dep = ppoint.dep.
 для Almaty определяем сп
v_dep = 1.
if v_bnk = "TXB16" then do:
    find last ofchis where ofchis.ofc = g-ofc and ofchis.regdt <= g-today use-index ofchis no-lock no-error.
    if avail ofchis then v_dep = ofchis.depart. else v_dep = 1.
end.*/

/* для типа комиссии  */
define temp-table tmpben
       field ttt as char
       field des as char.
create tmpben. tmpben.ttt = "OUR". tmpben.des = "Комиссия за счет отправителя".
create tmpben. tmpben.ttt = "BEN". tmpben.des = "Комиссия за счет бенефициара".
/*create tmpben. tmpben.ttt = "SHA". tmpben.des = "Комиссия за счет бенефициара и отправителя".*/


/* для комиссии*/
define temp-table tarhelp like tarif2.
 for each tarif2 where (/*tarif2.str5 = "107" or tarif2.str5 = "253" or*/ tarif2.str5 = "108" or tarif2.str5 = "262") and tarif2.stat  = "r"  no-lock:
    create tarhelp.
    buffer-copy tarif2 to tarhelp.
end.

/*---------------------------------------------*/

def var v_bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v_bin = sysc.loval.

if v_bin  then v_label = " ИИН            :". else v_label = " РНН            :".
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
    v-joudoc    label " Документ" format "x(10)" skip
    " Заявление на перевод в иностранной валюте" skip
    v_label v_rnn  no-label colon 17 format "x(12)" validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip
    v_lname     label " Фамилия        " format "x(20)"  validate(trim(v_lname) <> "", "Заполните фамилию") skip
    v_name      label " Имя            " format "x(20)"  validate(trim(v_name) <> "", "Заполните имя") skip
    v_mname     label " Отчество       " format "x(20)" skip
    v_rez       label " Резидентство   " validate(v_rez = "19" or v_rez = "29", "19-(физ.лицо/резидент)  29-(физ.лицо/нерезидент), F2-помощь") format "x(2)"
    v_countr   label  "      Код страны" validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false
                     and codfr.code <> "msc" and  codfr.code = v_countr no-lock), "Нет такого кода страны! F2-помощь") format "x(2)" skip
    v_doctype  label  " Вид документа  " validate((v_rez = "19" and lookup(substring(trim(v_doctype),1,2),"01,02,04,05") > 0) or (v_rez = "29"
                                        and lookup(substring(trim(v_doctype),1,2),"03") > 0),"Не правильный вид документа, F2-помощь" )  format "x(30)" skip
    v_doc_num  label  " Номер документа" help "Введите номер докумета удостов. личность" format "x(10)" validate(trim(v_doc_num) <> "", "Заполните номер документа") skip
    v_docwho   label  " Выдан          " help " Кем выдан документ удостов. личность"  format "x(30)" validate(trim(v_docwho) <> "", "Заполните кем выдан документ") skip
    v_docdt    label  " Дата выдачи    " format "99/99/9999" help " Ведите дату выдачи документа удостов. личость в формате дд/мм/гг " validate(trim(v_docdt) <> "", "Заполните дату выдачи документа") skip
    v_docdtf    label  " Срок действия  " format "99/99/9999" help " Ведите срок действия документа удостов. личость в формате дд/мм/гг " /*validate(trim(v_docdtf) <> "", "Заполните срок действия документа")*/ skip
    v_public   label  " Принадл к ИПДЛ "  format "x(1)"  help '1-не является 2- является 3-Аффилир. с иност. публич.' validate(can-find (codfr where codfr.codfr = 'publicf' and codfr.code = v_public no-lock),'Неверный признак! 1-не является 2- является 3-Аффилир. с иност. публич.') skip
    v-bdt1     label  ' Дата рождения  '  format "99/99/9999" validate(v-bdt1 <> ?,'Введите дату!') skip
    v-bplace   label  ' Место рождения '  format "x(30)" validate(trim(v-bplace) <> '','Введите место рождения!') skip
    v_addr     label  " Адрес          " help "Адрес проживания" validate(trim(v_addr) <> "", "Заполните адрес проживания") format "x(30)" skip
    v_tel      label  " Телефон        " help "Введите номер телефона" format "x(30)" skip
    v_crc      label  " Валюта перевода" help "Введите код валюты, F2-помощь" format ">9" validate(can-find(first crc where crc.crc = v_crc and v_crc <> 1 and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
    v_sum      label  " Сумма перевода " help " Введите сумму перевода" validate(v_sum > 0,"Проверьте значение суммы!") format ">>>,>>>,>>>,>>>,>>9.99" skip
    v_sumv     label  " Сумма перев в валюте "  help " Введите сумму внесения в валюте" validate(v_sumv <= v_sum,"Не может быть больше суммы перевода!") format ">>>,>>>,>>>,>>>,>>9.99"  skip
    v_sumt     label  " Сумма перевод в тенге"  format ">>>,>>>,>>>,>>>,>>9.99"  skip
    v_ben      label  " Тип опл комисс " validate((v_ben = "OUR" or v_ben = "BEN" /*or v_ben = "SHA"*/), "Неверный тип комиссии должно быть OUR или BEN ") format "x(3)" help "тип комиссии должен быть OUR, BEN или SHA" skip
    v_comcode  label  " Код комиссии   " validate((v_ben = "BEN" and v_comcode = "107") or ((v_ben = "OUR" and (v_comcode = "108" or v_comcode = "262")) or (v_ben = "OUR" and v_comcode = "253")), "Неверный код комиссии должно быть 107, 108, 262 или 253") format "x(5)"
    v_comname  no-label colon 22 format "x(25)" skip
    v_crck     label  " Валюта комиссии" help "Введите код валюты, F2-помощь"  format ">9" validate(can-find(first crc where crc.crc = v_crck and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
    v_sumk     label  " Сумма комиссии " help " Введите сумму комиссии" format ">>>,>>>,>>>,>>>,>>9.99" skip
    v_sumkv    label  " Сумма комисс в валюте" validate(v_sumkv <= v_sumk,"Не может быть больше суммы комиссии!") format ">>>,>>9.99" skip
    v_sumkt    label  " Сумма комисс в тенге " format ">>>,>>9.99" skip
    v_oper     label  " Назнач. платежа" format "x(27)" skip
    v_knp      label  " КНП            "  format "x(3)"  skip

WITH  SIDE-LABELS column 1 row 3 TITLE "ОТПРАВИТЕЛЬ" width 50 FRAME f_main.
form
                      "           ВНУТРЕННИЕ ПЛАТЕЖИ " skip
    v_dt1       label " Дебет Г/К  "
    v-joudoc    label "Ном докум" colon 40 skip
    v_kt1       label " Кредит Г/К "
    v_joutrx    label "Проводка " colon 40 skip
    v_arp1      label " АРП (Кт)   " format "x(20)" skip
                      "           ДАННЫЕ ПРОВОДКИ КОМИССИИ " skip
    v_dtk       label " Дебет Г/К  " skip
    v_ktk       label " Кредит Г/К " skip
                      "           ВНЕШНИЙ ПЛАТЕЖ " but skip
    v_dt2       label " Дебет Г/К  "
    v_rmzdoc    label "Ном докум"  colon 40 skip
    v_arp2      label " АРП (Дт)   " format "x(20)" skip
    v_kt2       label " Кредит Г/К "
    v_rmztrx    label "Проводка " colon 40 skip(1)
vj-label no-label v_ja no-label
WITH  SIDE-LABELS  column 53 row 21 TITLE "ДАННЫЕ ПРОВОДКИ ПЕРЕВОДА" width 57 FRAME Frame3.


form
    v_countr1 label "Код страны получения " validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false
                     and codfr.code <> "msc" and  codfr.code = v_countr1 no-lock), "Нет такого кода страны! F2-помощь") format "x(2)" skip
    v_swbic     label "Бик банка-корресп" format "x(30)"  skip
                      "Наименование банка-корресп-та:" skip
    v_bank      no-label format "x(50)"  skip
                      "Ном счета банка получателя в банке-корресп:" skip
    v_numch1     no-label  format "x(50)" skip

    v_swbic1    label "Бик банка получателя" format "x(30)" skip
                      "Наименование банка получат в банке-корресп:" skip
    v_bank1     no-label validate(trim(v_bank1) <> "" , "Введите наименование") format "x(50)" skip
    v_bank2     no-label  format "x(50)" skip
                      "Номер счета  получателя в банке получателя:" skip
    v_chpol     no-label  format "x(50)"  skip
                      "Наименование получателя: " skip
    v_namepol   no-label format "x(50)"  skip
    v_innpol    label "ИНН получателя "  format "x(12)" skip
    v-dat2      label "Дата валютирования " validate (v-dat2 >= today, " Проверьте дату")
    v_kbe       label "Кбе " colon 40 help "1 знак-признак резидентства, 2 знак-сектор экономики(без пробелов)" validate(v_kbe <> "" and integer(v_kbe) < 30, "Неверный Кбе") format "x(2)"  /*colon 35*/ skip
WITH  SIDE-LABELS  column 53 row 3 TITLE "ПОЛУЧАТЕЛЬ" width 57 FRAME Frame2.

form
     v_oper1 VIEW-AS EDITOR SIZE 68 by 6
     with frame detpay column 2 row 23 overlay  title "Назначение платежа" .


DEFINE QUERY q-rez FOR tmprez.
DEFINE BROWSE b-rez QUERY q-rez
       DISPLAY tmprez.des label "Резидентство " format "x(30)" WITH  3 DOWN.
DEFINE FRAME f-rez b-rez  WITH overlay 1 COLUMN SIDE-LABELS row 12 COLUMN 40 width 45 NO-BOX.

DEFINE QUERY q-ben FOR tmpben.
DEFINE BROWSE b-ben QUERY q-ben
       DISPLAY tmpben.ttt label "Тип комиссии " format "x(3)" tmpben.des format "x(40)" label "Описание" WITH  3 DOWN.
DEFINE FRAME f-ben b-ben  WITH overlay 1 COLUMN SIDE-LABELS row 12 COLUMN 20 width 70 NO-BOX.


DEFINE QUERY q-country FOR codfr.
DEFINE BROWSE b-country QUERY q-country
       DISPLAY codfr.code label "Код " format "x(3)" codfr.name[1] label "Наименование " format "x(30)"  WITH  10 DOWN.
DEFINE FRAME f-country b-country  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 40 width 50 NO-BOX.


DEFINE QUERY q-doc FOR tmpdoc.
DEFINE BROWSE b-doc QUERY q-doc
       DISPLAY tmpdoc.des label "Тип документа " format "x(35)" WITH  5 DOWN.
DEFINE FRAME f-doc b-doc  WITH overlay 1 COLUMN SIDE-LABELS row 14 COLUMN 40 width 50 NO-BOX.

define frame f-iin v_iin label "ИИН" format "x(12)" validate(length(v_iin) = 12 or trim(v_iin) = "-", "Длина меньше 12 знаков") help "Введите БИН" with overlay SIDE-LABELS row 8 column 20  width 30.
/*frame for help */

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("FR1"). else run a_help-joudoc1 ("RF1").
    v-joudoc = frame-value.
end.

on help of v_rez in frame f_main do:
    OPEN QUERY  q-rez FOR EACH tmprez no-lock.
    ENABLE ALL WITH FRAME f-rez.
    wait-for return of frame f-rez
    FOCUS b-rez IN FRAME f-rez.
    v_rez = substring(tmprez.des,1,2).
    hide frame f-rez.
    displ v_rez with frame f_main.
end.
on help of v_ben in frame f_main do:
    OPEN QUERY  q-ben FOR EACH tmpben no-lock.
    ENABLE ALL WITH FRAME f-ben.
    wait-for return of frame f-ben
    FOCUS b-ben IN FRAME f-ben.
    v_ben = tmpben.ttt.
    hide frame f-ben.
    displ v_ben with frame f_main.
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
on help of v_countr1 in frame frame2 do:
    OPEN QUERY  q-country FOR EACH codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc" no-lock.
    ENABLE ALL WITH FRAME f-country.
    wait-for return of frame f-country
    FOCUS b-country IN FRAME f-country.
    v_countr1 = codfr.code.
    hide frame f-country.
    displ v_countr1 with frame frame2.
end.

on help of v_crc in frame f_main do:
    run help-crc1.
end.
on help of v_crck in frame f_main do:
    run help-crc1.
end.

DEFINE QUERY q-tar FOR tarhelp.

DEFINE BROWSE b-tar QUERY q-tar
       DISPLAY tarhelp.str5 label "Код тарифа " format "x(3)" tarhelp.pakalp label "Наименование   " format "x(40)"
       WITH  15 DOWN.
DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 85 NO-BOX.

on help of v_comcode in frame f_main do:
    OPEN QUERY  q-tar FOR EACH tarhelp no-lock.
    ENABLE ALL WITH FRAME f-tar.
    wait-for return of frame f-tar
    FOCUS b-tar IN FRAME f-tar.
    v_comcode = tarhelp.str5.
    hide frame f-tar.
    displ v_comcode with frame f_main.
end.

on end-error of b-ben in frame f-ben do:
    hide frame f-ben.
   undo, return.
end.
on END-ERROR of frame f_main do:
  hide frame frame3 no-pause.
  hide frame frame2 no-pause.
  hide frame f_main no-pause.
end.
on END-ERROR of frame frame2 do:
  hide frame f_main no-pause.
  hide frame frame2 no-pause.
  hide frame frame3 no-pause.
end.
on END-ERROR of frame frame3 do:
  hide frame f_main no-pause.
  hide frame frame2 no-pause.
  hide frame frame3 no-pause.
  return.
end.
on "END-ERROR" of frame f-country do:
  hide frame f-country no-pause.
end.
on choose of but in frame  frame3 do:
end.

function crc-conv2 returns decimal (sum as decimal, c1 as int, c2 as int).
define buffer bcrc1 for crc.
define buffer bcrc2 for crc.
if c1 <> c2 then
   do:
      find last bcrc1 where bcrc1.crc = c1 no-lock no-error.
      find last bcrc2 where bcrc2.crc = c2 no-lock no-error.
      return sum * bcrc1.rate[1] / bcrc2.rate[1].
   end.
   else return sum.
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

function crc-conv1 returns decimal (sum as decimal, c1 as int, c2 as int).
define buffer bcrc1 for crc.
define buffer bcrc2 for crc.
if c1 <> c2 then
   do:
      find last bcrc1 where bcrc1.crc = c1 no-lock no-error.
      find last bcrc2 where bcrc2.crc = c2 no-lock no-error.
      return sum * bcrc1.rate[2] / bcrc2.rate[2].
   end.
   else return sum.
end.

if v-ek = 1 then v_dt1 = 100100. else v_dt1 = 100500.
if v-ek = 1 then v_dtk = 100100. else v_dtk = 100500.

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    clear frame frame2.
    clear frame frame3.
    vj-label  = " Сохранить новый документ?...........".
    v_title = "ПЕРЕВОДЫ В ИН.ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА (отправление)".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    v_oper = "".
    displ v-joudoc v_label format "x(18)" no-label with frame f_main.
    run save_doc.
end.  /* end new document */

else do:   /* редактирование документа   */
    v_title = "ПЕРЕВОДЫ В ИН.ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА (отправление)".
    run view_doc.
    if keyfunction (lastkey) = "end-error" then do:
        return.
    end.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                    if joudop.type <> "FR1" and joudop.type <> "RF1" then do:
                        message substitute ("Документ не относится к типу отправление перевода в ин валюте без открытия счета") view-as alert-box.
                        return.
                    end.
                    if v-ek = 1 and joudop.type = "RF1" then do:
                        message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                        return.
                    end.
                    if v-ek = 2 and joudop.type = "FR1" then do:
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
    v-cifmin = "". v_rez = "". v_crccode = "". v_sumc = 0. v_iin = "".
    v_lname = "". v_name = "". v_mname = "". v_rez = "". v_countr = "". v_doctype = "". v_doc_num = "".
    v_docwho = "". v_docdt = ?. v_docdtf = ?. v_public = "".  v-bplace = "".  v-bdt1 = ?. v_addr = "". v_tel = "".
    v_lname1 = "". v_name1 = "". v_mname1 = "". v_rez1 = "". v_countr1 = "". v_crc = 0. v_sum = 0. v_crck = 0. v_comcode = "". v_ben = "".
    displ v-joudoc with frame f_main.
    pause 0.
end.
if trim(v_rnn) <> "-" then do:
    if v_bin = no then do:
        find last cifmin where cifmin.rnn = v_rnn no-lock no-error.
        if available cifmin then do:
            v_iin = cifmin.iin.
            update v_iin with frame f-iin.
         end.
    end.
    if v_bin then find last cifmin where cifmin.iin = v_rnn no-lock no-error.
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
        if v_bin then find first rnn where rnn.bin = v_rnn no-lock no-error.
        else find first rnn where rnn.trn = v_rnn no-lock no-error.
        if available rnn then do:
            if not v_bin then do:
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
    displ v_label v_rnn   with frame f_main.
    update v_lname v_name v_mname v_rez with frame f_main.
end.
else do:
    clear frame f_main.
    displ v-joudoc with frame f_main.
    pause 0.
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
        displ v-joudoc v_label v_rnn  v_lname v_name v_mname v_rez v_lname with frame f_main.
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
    update v_doctype help " Вид документа удостовер. личность, F2-помощь " v_doc_num v_docwho v_docdt v_docdtf v_public v-bdt1 v-bplace with frame f_main.
end.
else do:*/
    if v_rez = "19" and v_u <> 2 then v_countr = "KZ".
    update  v_countr with frame f_main.
    find first stoplist where stoplist.code = v_countr no-lock no-error.
    if avail stoplist and stoplist.sts <> 9 then do:
        message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
        return.
    end.
    update v_doctype help " Вид документа удостовер. личность, F2-помощь " v_doc_num v_docwho v_docdt v_docdtf v_public v-bdt1 v-bplace with frame f_main.
/*end.
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
displ v_addr with frame f_main.
update v_tel with frame f_main.
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

/* расчет суммы внесения  */
v_sumv = 0.
if v-ek = 2 then do:
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
    pause 0.
end.
if v_crc = 4 then do:
    v_ben = "OUR".
    v_comcode = "253".
    displ v_ben with frame f_main.
end.
else do:
    /*update v_ben help "тип комиссии должен быть OUR, BEN или SHA" with frame f_main.*/
    update v_ben help "тип комиссии должен быть OUR или BEN " with frame f_main.
    v_ben = caps(v_ben).
    if v_ben <> "OUR"  then v_comcode = "107".
    else update v_comcode with frame f_main.
end.
find first tarif2 where tarif2.str5  = trim(v_comcode)  and tarif2.stat  = "r" no-lock no-error.
v_comname = tarif2.pakalp.
displ v_comcode v_comname v_oper with frame f_main.

/*if v-ek = 1 then update v_crck with frame f_main.
else v_crck = v_crc.
displ v_crck with frame f_main.
pause 0.*/
update v_crck with frame f_main.
if v_crck <> v_crc and v_crck <> 1 then do:
    repeat:
        message "Код валюты комиссии может быть в тенге или в валюте проводки".
        update v_crck with frame f_main.
        if v_crck = v_crc or v_crck = 1 then leave.
    end.
end.
if keyfunction (lastkey) = "end-error" then do:
    hide all.
    if this-procedure:persistent then delete procedure this-procedure.
    return.
end.
 /* вычисление суммы комиссии-----------------------------------*/
v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
run perev ("",input v_comcode, input v_sum, input v_crc, input v_crck,"", output v-amt, output tproc, output pakal).
v_sumk = v-amt.
/*------------------------------------------------------------*/
update v_sumk with frame f_main.
if v-ek = 2 and v_crck <> 1 then do:
    /* сумма внесения комиссии  */
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
    displ v_sumkt  with frame f_main.
    pause 0.
 end.
 v_oper1 = v_oper.
 repeat:
    update v_oper1 no-label go-on("return") with frame detpay.
    if length(v_oper1) > 140 then message 'Назначение платежа превышает 140 символов, для внесения большего количества символов, обратитесь к сотрудникам ДПС!'.
    else leave.
 end.
 /*if substring(v_oper1,1,17) = "Personal transfer" then v_oper = v_oper1.
 else v_oper = "Personal transfer " + v_oper1.*/
 v_oper = v_oper1.
 displ v_oper  with frame f_main.
 update v_knp with frame f_main.

update v_countr1 with frame frame2.
find first stoplist where stoplist.code = v_countr1 no-lock no-error.
if avail stoplist and stoplist.sts <> 9 then do:
    message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
    return.
end.
def var v-stoplist as logic.
v-stoplist = no.
run fil_swift("", output v-stoplist).
    hide frame f-swift.
    hide frame f-swift1.
    hide frame f-swift2.
    hide frame f-numch2.
    hide frame f-numch3.
    hide frame f-numch4.
if v-stoplist = yes then do:
    hide all.
    return.  /*  не заполнен свифт, значит операцию прерываем */
end.

v-dat2 = g-today.
displ v_swbic v_bank v_numch1 v_swbic1 v_bank1 v_bank2 v_chpol v_namepol v_innpol v-dat2 with frame frame2.
update v-dat2 v_kbe with frame frame2.
if caps(trim(v_countr1)) <> "RU" then do:
    v_oper1 = v_oper.
    repeat:
        if length(v_oper1) > 140 then message 'Максимальное количество символов 140, необходимо сократить детали платежа!'.
        v_eng = no.
        run eng(v_oper1, output v_eng).
        if v_eng = yes and v_crc <> 4 and substring(v_swbic1,1,8) <> v-clecod then message "В назначении платежа есть символы русского алфавита, необходимо исправить набрав на англ. яз.".
        if (v_eng = no or (v_eng = yes and v_crc = 4)or (v_eng = yes and  v_swbic1 begins v-clecod)) and length(v_oper1) <= 140 then leave.
        update v_oper1 no-label go-on("return") with frame detpay.
    end.
    v_oper = v_oper1.
end.


/* find arp  ------------------------------------------------*/
find first arp where arp.gl = v_dt2 and arp.crc = v_crc and length(arp.arp) >= 20 and arp.des MATCHES "*исх*" and not arp.des  MATCHES "*СП*" no-lock no-error.
if available arp then do:
    v_arp1 = arp.arp.
    v_arp2 = v_arp1.
    displ v_dt1 format "999999" v_kt1 format "999999" v_arp1
    v_dt2 format "999999" v_kt2 format "999999" v_arp2
    v_dtk format "999999" v_ktk format "999999" with frame frame3.
end.
else do:
    message "Счет кредита в ARP не найден, продолжение невозможно!" view-as alert-box.
    return.
end.
displ vj-label format "x(35)" no-label with frame frame3.
update v_ja no-label with frame frame3.
do transaction on error undo, return:
    if v_ja then do:
        /*подключение comm */
        find sysc where sysc.sysc = 'CMHOST' no-lock no-error.
        if avail sysc then connect value (sysc.chval) no-error.

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
        if v_bin = no then do: cifmin.iin = v_iin. cifmin.rnn = v_rnn. end.
        else cifmin.iin = v_rnn.
        cifmin.docnum = v_doc_num.
        cifmin.docdt = v_docdt.
        cifmin.docdtf = v_docdtf.
        cifmin.publicf = v_public.
        cifmin.bdt = v-bdt1.
        cifmin.bplace = v-bplace.
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
        if v_rez = "19" then cifmin.res = "1". else cifmin.res = "0".
        find current cifmin no-lock no-error.
        /* create joudoc */
        /*release joudoc.*/

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

            find first crc where crc.crc = v_crck no-lock.
            v-crc_valk = crc.code.
            for each arp where arp.gl = 100500 and arp.crc = v_crck no-lock.
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

            find sernumdoc where sernumdoc.transfer = v-joudoc no-lock no-error.
            if not avail sernumdoc then do:
                create sernumdoc.
                assign
                sernumdoc.fname     = g-fname
                sernumdoc.progtrans = "a_foreign1".
                find last b-sernumdoc where b-sernumdoc.whn = g-today and b-sernumdoc.progtrans = "a_foreign1" no-lock no-error.
                if avail b-sernumdoc then assign sernumdoc.numtrans = b-sernumdoc.numtrans + 1.
                else sernumdoc.numtrans = 1.
                assign
                sernumdoc.transfer  = v-joudoc
                sernumdoc.whn       = g-today
                sernumdoc.who       = g-ofc
                sernumdoc.tim       = time.
            end.
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
        joudoc.cracc = v_arp1.
        joudoc.crcur = v_crc.
        joudoc.comamt = v_sumk.
        if v-ek = 2 then joudoc.comacctype = "4". else joudoc.comacctype = "1".
        if v-ek = 2 then joudoc.comacc = v-chEKk. else joudoc.comacc = "".
        joudoc.comcur = v_crck.
        joudoc.comcode = v_comcode.
        joudoc.bas_amt = "D".
        joudoc.remark[1] = v_oper.
        joudoc.chk = 0.
        joudoc.info = v_lname + " " + v_name + " " + v_mname.
        joudoc.perkod = v_rnn.
        joudoc.passp = v_doc_num + "," + v_docwho.
        joudoc.passpdt = v_docdt.
        joudoc.kfmcif = v-cifmin.
        joudoc.benName = trim(v_namepol) .
        if v_sum <> v_sumv or v_sumk <> v_sumkv then do:
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
        joudop.patt = trim(v_namepol) + "^" + v_innpol + "^" + v_kbe + "^" +
                        v_chpol + "^" + v_bank1 + "^" + v_swbic1 + "^" + v_knp.
        if v-ek = 1 then joudop.type = "FR1". else joudop.type = "RF1".
        joudop.lname = v_kbe + "^" + string(v_sum) + "^" + string(v_crc) + "^" + string(v_sumk) + "^" + string(v_crck)
                    + "^" + v_comcode + "^" + v_knp + "^" + v_ben .  /*  doch.sub  */
        joudop.fname = v_swcod + "^" + v_swbic + "^" + v_swcity + "^" + v_swcnt + "^" + v_swcod1 + "^" + v_swbic1 + "^" +
            v_swcity1 + "^" + v_swcnt1 + "^" + v_countr1 + "^" + string(v-dat2). /* doch.param1 */
        joudop.mname = trim(v_bank) + "^" + trim(v_numch1) + "^" + trim(v_bank1) + "^" + trim(v_bank2). /*  doch.info[2]   */
        joudop.rez1 = trim(v_chpol) + "^" + trim(v_innpol) + "^" + trim(v_namepol).  /*  doch.info[3]  */
        find current joudop no-lock no-error.
        displ v-joudoc with frame f_main.

        /*----------------------------------------------------------------------------*/
    end. /* end if v_ja then do:*/
end. /* transaction */
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
        if joudop.type <> "FR1" and joudop.type <> "RF1" then do:
            message substitute ("Документ не относится к типу отправление перевода в ин валюте без открытия счета") view-as alert-box.
            hide all.
            return.
        end.
        if v-ek = 1 and joudop.type = "RF1" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            hide all.
            return.
        end.
        if v-ek = 2 and joudop.type = "FR1" then do:
            message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
            hide all.
            return.
        end.
    end.
    if available joudoc then do:
        if joudoc.jh > 1 and v_u = 2 then do:
            message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
            hide all.
            return.
        end.
        if joudoc.who ne g-ofc and v_u = 2 then do:
            message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
            hide all.
            return.
        end.
    end.
    v_joutrx = joudoc.jh.
    v-cifmin = joudoc.kfmcif.
    v_arp1 = joudoc.cracc.
    v_kbe = entry(1,joudop.lname,vdel).
    v_sum = decim(entry(2,joudop.lname,vdel)).
    v_crc = integer(entry(3,joudop.lname,vdel)).
    v_sumk = decim(entry(4,joudop.lname,vdel)).
    v_crck = integer(entry(5,joudop.lname,vdel)).
    v_comcode = entry(6,joudop.lname,vdel).
    v_knp = entry(7,joudop.lname,vdel).
    v_ben = entry(8,joudop.lname,vdel).
    find first tarif2 where tarif2.str5  = trim(v_comcode)  and tarif2.stat  = "r" no-lock no-error.
    v_comname = tarif2.pakalp.
    v_swcod = entry(1,joudop.fname,vdel).
    v_swbic = entry(2,joudop.fname,vdel).
    v_swcity = entry(3,joudop.fname,vdel).
    v_swcnt = entry(4,joudop.fname,vdel).
    v_swcod1 = entry(5,joudop.fname,vdel).
    v_swbic1 = entry(6,joudop.fname,vdel).
    v_swcity1 = entry(7,joudop.fname,vdel).
    v_swcnt1 = entry(8,joudop.fname,vdel).
    v_countr1 = entry(9,joudop.fname,vdel).
    if NUM-ENTRIES(joudop.fname,vdel) > 9 then v-dat2 = date(entry(10,joudop.fname,"^")).
    v_sumv = joudop.amt.
    v_sumt = joudop.amt1.
    v_sumkv = joudop.amt2.
    v_sumkt = joudop.amt3.


  if  v_countr1 = "KZ" then v_rez1 = "1". else v_rez1 = "0".

    v_oper = joudoc.remark[1].
    v_bank = caps(entry(1,joudop.mname,vdel)).
    v_numch1 = caps(entry(2,joudop.mname,vdel)).
    v_bank1 = caps(entry(3,joudop.mname,vdel)).
    v_bank2 = caps(entry(4,joudop.mname,vdel)).
    v_chpol = caps(entry(1,joudop.rez1,vdel)).
    v_innpol = caps(entry(2,joudop.rez1,vdel)).
    v_namepol = caps(entry(3,joudop.rez1,vdel)).
    if NUM-ENTRIES(joudop.doc1,vdel) >= 1 then do:
        v_rmzdoc = entry(1,joudop.doc1,"^").
        v_rmztrx = integer(entry(2,joudop.doc1,"^")).
    end.
    find last cifmin where cifmin.cifmin = v-cifmin no-lock no-error.
    if not avail cifmin then do:
        message "CIFMIN-код клиента не найден, продолжение невозможно!" view-as alert-box.
        return.
    end.
    v_lname = cifmin.fam.
    v_name = cifmin.name.
    v_mname = cifmin.mname.
    if v_bin then v_rnn = cifmin.iin.
    else  do:
        v_rnn = cifmin.rnn.
        v_iin = cifmin.iin.
    end.
    v_doc_num = cifmin.docnum.
    v_docdt = cifmin.docdt.
    v_docdtf = cifmin.docdtf.
    v_public = cifmin.publicf.
    v-bdt1 = cifmin.bdt.
    v-bplace = cifmin.bplace.
    v_docwho = cifmin.docwho.
    v_addr = cifmin.addr.
    v_tel = cifmin.tel.
    v_doctype = cifmin.doctype.
    if cifmin.res = "1" then v_rez = "19". else v_rez = "29".
    v_countr = cifmin.public.
    v_arp2 = v_arp1.

    displ v_label v_rnn v_lname v_name v_mname v_rez v_countr v_doctype v_doc_num v_docwho v_docdt v_docdtf v_public v-bdt1 v-bplace
            v_addr v_tel v_crc  v_sum v_sumv v_sumt v_ben v_comcode v_comname v_crck v_sumk v_sumkv v_sumkt v_oper v_knp with frame f_main.
    displ /*v_lname1 v_name1 v_mname1 v_rez1 */ v_countr1 v_swbic v_bank v_numch1 v_swbic1 v_bank1 v_bank2
            v_chpol v_innpol v_namepol v-dat2 v_kbe with frame frame2.
    displ v_dt1 format "999999" v-joudoc format "x(10)" v_kt1 format "999999"  v_joutrx format "zzzzzzzzz" v_arp1
    v_dt2 format "999999" v_rmzdoc  v_arp2 v_kt2 format "999999" v_rmztrx format "zzzzzzzzz"
    v_dtk format "999999"  v_ktk format "999999" with frame frame3.
    s-remtrz = v_rmzdoc.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = "ПЕРЕВОДЫ В ИН.ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА (отправление)".
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
            displ vj-label format "x(35)" no-label with frame frame3.
            update v_ja no-label with frame frame3.
            if v_ja then do:
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
        hide all.
    end.
    return.
end procedure.

procedure Create_transaction:
    vj-label  = " Выполнить транзакцию?..................".
    v_title = " ПЕРЕВОДЫ В ИН.ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА (отправление перевода)".
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
    if  v_swbic1 = "" or v_bank1 = "" or v_chpol = "" or v_namepol = "" then do:
        message "Свифт макет заполнен не корректно. Выполните команду 'Редактировать'" view-as alert-box.
        return.
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
            /*run savelog("checkrate", "a_foreign1 ; docnum = " + v-joudoc  + "crc = " + string(crc.crc) + " rate doc: "  + string(joudoc.srate)  + " ; rate in table crc: " + string(crc.rate[3]) )  .*/
            if joudoc.srate <> crc.rate[3] then do:
                inf1 = true.
                v_sumt1 = v_sum - v_sumv.
                v_sumt = 0.
                m_buy = 0.
                m_sell = 0.
                v_rate = 0.
                v_rate1 = 0.
                v_bn = 0.
                v_sn = 0.
                run conv(input 1, input v_crc, input true,
                    input true, input-output v_sumt, input-output v_sumt1,
                    output v_rate1, output v_rate, output v_sn,
                    output v_bn, output m_sell, output m_buy).
            end.
        end.
        if joudop.amt3 <> 0  then do:
            /*run savelog("checkrate", "a_foreign1 комиссия ; docnum = " + v-joudoc  + "crc = " + string(crc.crc) + " rate doc: "  + string(joudoc.srate)  + " ; rate in table crc: " + string(crc.rate[3]) )  .*/
            find first crc where crc.crc = v_crck no-lock.
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
                v_sumkt = 0.
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
    v_doc = v-joudoc.
    v-knpval = v_knp.
    v_lname1 = trim(v_namepol) .
    enable but with frame frame3.
    pause 0.
    {a_finmon.i}
    view frame f_main.
    view frame frame2.
    view frame frame3.
    disable but with frame frame3.
    if keyfunction (lastkey) = "end-error" then do:
        message "Транзакция прервана!" view-as alert-box.
        return.
    end.
    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.

    displ vj-label format "x(35)" no-label with frame frame3.
    pause 0.
    v_ja = yes.
    update v_ja no-label with frame frame3.
    if not v_ja  then do:
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide all no-pause.
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

        if v_sum = v_sumv then do:
            v-tmpl = "JOU0055".
            v_param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_arp1 + vdel + v_oper
                    + vdel + substr(v_rez,1,1) + vdel + substr(v_kbe,1,1) + vdel + substr(v_rez,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
        else do:
            v-tmpl = "JOU0055".
            v_param = v-joudoc + vdel + string(v_sumv) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_arp1 + vdel + v_oper + "/сумма внесения в валюте"
                    + vdel + substr(v_rez,1,1) + vdel + substr(v_kbe,1,1) + vdel + substr(v_rez,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            v-tmpl = "JOU0069".
            v_param = v-joudoc + vdel + string(v_sumt) + vdel + "1" + vdel + v-chEK1 + vdel + "обмен валюты" +
                    vdel + "1" + vdel + "1" + vdel + "9" + vdel + "9" + vdel + "223" /*+ vdel + string(v_sum - v_sumv)*/ + vdel +
                    string(v_crc) + vdel + v-chEK .
            run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            v-tmpl = "JOU0055".
            v_param = v-joudoc + vdel + string(v_sum - v_sumv) + vdel + string(v_crc) + vdel + v-chEK + vdel + v_arp1 + vdel + v_oper
                    + vdel + substr(v_rez,1,1) + vdel + substr(v_kbe,1,1) + vdel + substr(v_rez,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end. /* end if v_crc = v_crcv */

            /* комиссия*/
            if v_sumk <> 0 then do:
                if v_crck = 1 then do:
                    v-tmpl = "jou0053".
                    v_param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crck) + vdel + v-chEK1 + vdel + string(v_ktk) + vdel + "Комиссия за " + v_comname + vdel + substring(v_rez,1,1) + vdel + substring(v_rez,2,1).
                    run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                end.
                else do:
                    if v_sumk = v_sumkv then do:
                        v-tmpl = "jou0053".
                        v_param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crc) + vdel + v-chEK + vdel + string(v_ktk) + vdel + "Комиссия за " + v_comname + vdel + substring(v_rez,1,1) + vdel + substring(v_rez,2,1).
                        run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                            message rdes.
                            pause.
                            undo, return.
                        end.
                    end.
                    else do:
                        v-tmpl = "jou0053".
                        v_param = v-joudoc + vdel + string(v_sumkv) + vdel + string(v_crc) + vdel + v-chEK + vdel + string(v_ktk) + vdel + "Комиссия за " + v_comname + "/сумма внесения в валюте" + vdel + substring(v_rez,1,1) + vdel + substring(v_rez,2,1).
                        run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                            message rdes.
                            pause.
                            undo, return.
                        end.
                        v-tmpl = "JOU0069".
                        v_param = v-joudoc + vdel + string(v_sumkt) + vdel + "1" + vdel + v-chEK1 + vdel + "обмен валюты" +
                                vdel + "1" + vdel + "1" + vdel + "9" + vdel + "9" + vdel + "223" /*+ vdel + string(v_sumk - v_sumkv)*/ + vdel +
                                string(v_crck) + vdel + v-chEK .
                        run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                            message rdes.
                            pause.
                            undo, return.
                        end.
                        v-tmpl = "jou0053".
                        v_param = v-joudoc + vdel + string(v_sumk - v_sumkv) + vdel + string(v_crc) + vdel + v-chEK + vdel + string(v_ktk) + vdel + "Комиссия за " + v_comname + "/сумма внесения в валюте" + vdel + substring(v_rez,1,1) + vdel + substring(v_rez,2,1).
                        run trxgen (v-tmpl, vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                            message rdes.
                            pause.
                            undo, return.
                        end.
                    end.  /* else do */
                end.
            end.
            find first arp no-lock no-error.

            find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error.
            joudoc.jh = s-jh.
            if v_sum <> v_sumv or v_sumk <> v_sumkv then do:
                find first crc where  crc.crc = v_crc no-lock no-error.
                joudoc.srate = crc.rate[3].
                joudoc.sn = 1.
            end.
            joudoc.brate = 1.
            find current joudoc no-lock no-error.
            find first jh where jh.jh = s-jh exclusive-lock.
            jh.party = v-joudoc.
            if jh.sts < 5 then jh.sts = 5.
            for each jl of jh:
                if jl.sts < 5 then jl.sts = 5.
            end.
            run chgsts(m_sub, v-joudoc, "trx").

            if v-noord = yes then run printvouord(2).
    end.
    /* CASH 100100-------------------------------------------------*/

    if v-ek = 1 then do:
        v_param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v_arp1 + vdel + v_oper + vdel +
                              substring(v_rez,1,1) + vdel + substring(v_kbe,1,1) + vdel + substring(v_rez,2,1) + vdel + substring(v_kbe,2,1) + vdel + v_knp.
        run trxgen ("jou0048", vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        /* комиссия*/
        if v_sumk <> 0 then do:
             v_param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crck) + vdel + string(v_ktk) + vdel + "Комиссия за " + v_comname + vdel +
                                  substring(v_rez,1,1) + vdel + "9".
            run trxgen ("jou0025", vdel, v_param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause 1000.
                undo, return.
            end.
        end.

        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error.
        if available joudoc then joudoc.jh = s-jh.
        find first joudoc no-lock no-error.

        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            return.
        end.
        run chgsts("jou", v-joudoc, "trx").
        run chgsts("jou", v-joudoc, "cas").
        if v-noord = yes then run printvouord(2).
    end. /* v-ek = 1*/

        v_joutrx = s-jh.

        /* создаем rmz документ*/
        def var v-transp as int init 4.
        if v_swbic1 begins "FOBAKZKA" then  v-transp = 5.
        run rmzcre (1, v_sum, v_arp1, v_rnn, v_lname + " " + v_name + " " + v_mname, "VALOUT", v_chpol, v_namepol, v_innpol,
        ' ', no, v_knp, v_rez, v_kbe, v_oper, 'O', 1, v-transp, g-today).

        v_rmzdoc = return-value.
        if v_rmzdoc = "" then undo,return.
        find first crc where crc.crc = v_crc no-lock no-error.
        if not avail crc then do:
            message "Не найден код валюты. Обратитесь к разработчику." view-as alert-box.
            return.
        end.
        /* запишем код банка*/
        find first remtrz where remtrz.remtrz = v_rmzdoc exclusive-lock no-error.
        if avail remtrz then do:
            remtrz.scbank = v_bnk.
            v_rmztrx = remtrz.jh1.
            remtrz.kfmcif = v-cifmin.
            remtrz.svca = v_sumk.
            v_sumc = v_sumk.
            if v_ben <> "OUR" then remtrz.bi = caps(crc.code) + " " + trim(string(round(crc-conv(decimal(v_sumc), v_crck, v_crc),2),">>>>>>>>>>>>>>9.99")).
            remtrz.svcgl = v_dtk.
            remtrz.svcrc = v_crck.
            remtrz.svccgl = v_ktk.
            remtrz.svccgr = integer(v_comcode).
            remtrz.info[9] = string(g-today).
            remtrz.info[10] = string(v_kt2).
            remtrz.jh3 = v_joutrx. /* в out_Gcps.p проверим акцептована ли кассиром проводка v_joutrx  */
            remtrz.source = "O". /* код создания платежа*/
            remtrz.ptype = "N".
            remtrz.valdt2 = v-dat2.
        end.
        find first remtrz no-lock.
        find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = v_rmzdoc and sub-cod.d-cod = "iso3166" exclusive-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            sub-cod.acc = v_rmzdoc.
            sub-cod.sub = "rmz".
            sub-cod.d-cod  = "iso3166".
            sub-cod.ccode = v_countr1.
        end.
        else do:
            sub-cod.rdt = g-today.
            sub-cod.ccode = v_countr1.
        end.
        find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = v_rmzdoc and sub-cod.d-cod = "eknp" exclusive-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            sub-cod.acc = v_rmzdoc.
            sub-cod.sub = "rmz".
            sub-cod.d-cod  = "eknp".
            sub-cod.ccode = "eknp".
            sub-cod.rcode = v_rez + "," + v_kbe + "," + v_knp.
        end.
        else do:
            sub-cod.rdt = g-today.
            sub-cod.ccode = "eknp".
            sub-cod.rcode = v_rez + "," + v_kbe + "," + v_knp.
        end.

        find current sub-cod no-lock no-error.
        l-ans = no.
        run yn(""," Есть Документ Основание ? ","","", output l-ans).
        if l-ans then do:
           /* Автоматически проставим признак */
           find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc   = v_rmzdoc and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.
           if avail sub-cod then do:
                sub-cod.acc      = v_rmzdoc.
                sub-cod.sub      = 'rmz'.
                sub-cod.d-cod    = 'zdcavail'.
                sub-cod.ccode    = string(1).
                sub-cod.rdt      = g-today.
           end.
           else do:
                create sub-cod.
                sub-cod.acc      = v_rmzdoc.
                sub-cod.sub      = 'rmz'.
                sub-cod.d-cod    = 'zdcavail'.
                sub-cod.ccode    = string(1).
                sub-cod.rdt      = g-today.
           end.
            find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v_rmzdoc and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
            if avail sub-cod then do:
                sub-cod.acc      = v_rmzdoc.
                sub-cod.sub      = 'rmz'.
                sub-cod.d-cod    = 'zsgavail'.
                sub-cod.ccode    = 'msc'.
                sub-cod.rdt      = g-today.
            end.
            else do:
                create sub-cod.
                sub-cod.acc      = v_rmzdoc.
                sub-cod.sub      = 'rmz'.
                sub-cod.d-cod    = 'zsgavail'.
                sub-cod.ccode    = 'msc'.
                sub-cod.rdt      = g-today.
            end.
           find first sub-cod no-lock  no-error.
           release sub-cod.
        end. /*l-ans = true*/
        else do:
           find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc   = v_rmzdoc and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.
           if avail sub-cod then do:
                sub-cod.acc      = v_rmzdoc.
                sub-cod.sub      = 'rmz'.
                sub-cod.d-cod    = 'zdcavail'.
                sub-cod.ccode    = string(2).
                sub-cod.rdt      = g-today.
           end.
           else do:
                create sub-cod.
                sub-cod.acc      = v_rmzdoc.
                sub-cod.sub      = 'rmz'.
                sub-cod.d-cod    = 'zdcavail'.
                sub-cod.ccode    = string(2).
                sub-cod.rdt      = g-today.
           end.
            l-ans = no.
            run yn(""," Есть запись разрешающая предоставлять информацию в правоохранительные органы","","", output l-ans).
            if l-ans then do:
                /* Автоматически проставим признак */
                find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v_rmzdoc and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
                if avail sub-cod then do:
                    sub-cod.acc      = remtrz.remtrz.
                    sub-cod.sub      = 'rmz'.
                    sub-cod.d-cod    = 'zsgavail'.
                    sub-cod.ccode    = string(1).
                    sub-cod.rdt      = g-today.
                end.
                else do:
                    create sub-cod.
                    sub-cod.acc      = v_rmzdoc.
                    sub-cod.sub      = 'rmz'.
                    sub-cod.d-cod    = 'zsgavail'.
                    sub-cod.ccode    = string(1).
                    sub-cod.rdt      = g-today.
                end.
                find first sub-cod no-lock  no-error.
                release sub-cod.
            end.
            else undo, return.
        end.
        /*-----------------------------*/
        s-remtrz = v_rmzdoc.
        run rmzque .

        find first joudop where joudop.docnum = v-joudoc exclusive-lock.
        joudop.doc1 = v_rmzdoc + "^" + string(v_rmztrx).
        find current joudop no-lock.
        v_sumc = v_sumk.
        v_sumc = round(crc-conv(v_sumc, v_crck, v_crc),2).

        /*-----------------------------------*/
        /*переносим данные в свифт макет*/
        if num-entries(v_addr) = 7 then do:
            v-country2 = entry(1,v_addr).
            ind = index(v-country2,"(").
            if num-entries(v-country2,'(') = 2 then v-country_cod = substr(entry(2,entry(1,v_addr),'('),1,2).
        end.
        /* for RU  */
        if v_crc = 4 then do:
            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "50".
            swbody.type = "F".
            if v_rez = "19" then swbody.content[1] = "TXID/KZ/" + v_rnn. else swbody.content[1] = "CCPT/" + v_countr + "/" + v_doc_num.
            /* перевод на англ буквы*/
            swbody.content[2] = "1/" + rus-eng1(v_lname) + " " + rus-eng1(v_name) + " " + rus-eng1(v_mname).
            swbody.content[3] = "2/" + rus-eng1(entry(4,v_addr)) + "," + rus-eng1(entry(5,v_addr)) + "," + rus-eng1(entry(6,v_addr)).
            swbody.content[4] = "3/" + v-country_cod + "/" + rus-eng1(entry(3,v_addr)) + "," + v-index.

            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "57".
            swbody.type = "D".
            swbody.content[1] = "//RU" + v_swbic1.
            if length(v_bank1) <= 35 then do:
                swbody.content[2] = rus-eng1(v_bank1).
                if trim(v_bank2) = "" then swbody.content[3] = rus-eng1(v_swcity1).
                else do:
                    swbody.content[3] = rus-eng1(v_bank2).
                    swbody.content[4] = rus-eng1(v_swcity1).
                end.
            end.
            else do:
                swbody.content[2] = rus-eng1(substring(v_bank1,1,35)).
                swbody.content[3] = rus-eng1(substring(v_bank1,36,35)).
                if trim(v_bank2) = "" then swbody.content[4] = rus-eng1(v_swcity1).
                else do:
                    swbody.content[4] = rus-eng1(v_bank2).
                    swbody.content[5] = rus-eng1(v_swcity1).
                end.
            end.

            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "59".
            /*swbody.type = "D".*/
            if substring(v_chpol,1,1) = "/" then swbody.content[1] = v_chpol.
            else swbody.content[1] = "/" + v_chpol.
            if trim(v_innpol) = "" then do:
                if length(v_namepol) <= 35 then swbody.content[2] = rus-eng1(v_namepol).
                else do:
                    swbody.content[2] = rus-eng1(substring(v_namepol,1,35)).
                    swbody.content[3] = rus-eng1(substring(v_namepol,36,35)).
                    swbody.content[4] = rus-eng1(substring(v_namepol,71,35)).
                end.

            end.
            else do:
                swbody.content[2] = "INN" + v_innpol.
                if length(v_namepol) <= 35 then swbody.content[3] = rus-eng1(v_namepol).
                else do:
                    swbody.content[3] = rus-eng1(substring(v_namepol,1,35)).
                    swbody.content[4] = rus-eng1(substring(v_namepol,36,35)).
                end.
            end.
            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "70".
            v_oper2 = "(VOXXXXX)" + v_oper.
            swbody.content[1] = rus-eng1(substring(v_oper2,1,35)).
            swbody.content[2] = rus-eng1(substring(v_oper2,36,35)).
            swbody.content[3] = rus-eng1(substring(v_oper2,71,35)).
            swbody.content[4] = rus-eng1(substring(v_oper2,106,35)).
        end.
        else do:
            /*create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "50".
            swbody.content[1] = "/" + v_arp2.

            run rus-eng(input v_lname, output v_lname1).
            run rus-eng(input v_name, output v_name1).
            run rus-eng(input v_mname, output v_mname1).
            swbody.content[2] = v_lname1 + " " + v_name1 + " " + v_mname1.

            run rus-eng(input entry(4,v_addr), output v_lname1).
            run rus-eng(input entry(5,v_addr), output v_name1).
            run rus-eng(input entry(6,v_addr), output v_mname1).
            swbody.content[3] = v_lname1 + "," + v_name1 + "," + v_mname1.
            run rus-eng(input entry(3,v_addr), output v_lname1).
            swbody.content[4] = v_lname1 + "," + v-country_cod + "," + v-index.*/

            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "50".
            swbody.type = "F".
            if v_rez = "19" then swbody.content[1] = "TXID/KZ/" + v_rnn. else swbody.content[1] = "CCPT/" + v_countr + "/" + v_doc_num.
            /* перевод на англ буквы*/
            swbody.content[2] = "1/" + rus-eng2(v_lname) + " " + rus-eng2(v_name) + " " + rus-eng2(v_mname).
            swbody.content[3] = "2/" + rus-eng2(entry(4,v_addr)) + "," + rus-eng2(entry(5,v_addr)) + "," + rus-eng2(entry(6,v_addr)).
            swbody.content[4] = "3/" + v-country_cod + "/" + rus-eng2(entry(3,v_addr)) + "," + v-index.

            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "56".
            if v_swbic <> "" then swbody.type = v_swcod.
            else swbody.type = "N".
            swbody.content[1] = v_numch1.
            swbody.content[2] = v_swbic.
            if length(v_bank) <= 35 then do:
                swbody.content[3] = v_bank.
                swbody.content[4] = v_swcity + " " + v_swcnt.
            end.
            else do:
                swbody.content[3] = substring(v_bank,1,35).
                swbody.content[4] = substring(v_bank,36,35).
                swbody.content[5] = v_swcity + " " + v_swcnt.
            end.

            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "57".
            swbody.type = v_swcod1.
            swbody.content[2] = v_swbic1.
            if length(v_bank1) <= 35 then do:
                swbody.content[3] = v_bank1.
                swbody.content[4] = v_swcity1 + " " + v_swcnt1.
            end.
            else do:
                swbody.content[3] = substring(v_bank1,1,35).
                swbody.content[4] = substring(v_bank1,36,35).
                swbody.content[5] = v_swcity1 + " " + v_swcnt1.
            end.

            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "59".
            /*swbody.type = "D".*/
            if substring(v_chpol,1,1) = "/" then swbody.content[1] = v_chpol.
            else swbody.content[1] = "/" + v_chpol.
            if trim(v_innpol) = "" then do:
                if length(v_namepol) <= 35 then swbody.content[2] = v_namepol.
                else do:
                    swbody.content[2] = substring(v_namepol,1,35).
                    swbody.content[3] = substring(v_namepol,36,35).
                    swbody.content[4] = substring(v_namepol,71,35).
                end.

            end.
            else do:
                swbody.content[2] = "INN" + v_innpol.
                if length(v_namepol) <= 35 then swbody.content[3] = v_namepol.
                else do:
                    swbody.content[3] = substring(v_namepol,1,35).
                    swbody.content[4] = substring(v_namepol,36,35).
                end.
            end.
            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "70".
            swbody.content[1] = substring(v_oper,1,35).
            swbody.content[2] = substring(v_oper,36,35).
            swbody.content[3] = substring(v_oper,71,35).
            swbody.content[4] = substring(v_oper,106,35).
        end.


        if v_ben <> "OUR" then do:
            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "71".
            swbody.type = "A".
            swbody.content[1] = v_ben.
            /*find first crc where crc.crc = v_crc no-lock no-error.
            if not avail crc then do:
                message "Не найден код валюты. Обратитесь к разработчику." view-as alert-box.
                return.
            end.*/
            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "71".
            swbody.type = "F".
            v_sumc = v_sumk.
            swbody.content[1] = caps(crc.code) + " " + trim(string(round(crc-conv2(decimal(v_sumc), v_crck, v_crc),2),">>>>>>>>>>>>>>9.99")).

            create swbody.
            swbody.rmz = v_rmzdoc.
            swbody.swfield = "33".
            swbody.type = "B".
            v_sumc = v_sumk.
            v_sumc = round(crc-conv2(decimal(v_sumc), v_crck, v_crc) + v_sum ,2).
            swbody.content[1] = caps(crc.code) + " " + trim(string(round(v_sumc,2),">>>>>>>>>>>>>>9.99")).
        end.
        find first swbody no-lock.
        s-jh = v_joutrx.
        v_upd = no.
        /* копируем заполненные данные по ФМ в реальные таблицы*/
        if v-kfm then do:
            run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
            hide all.
            view frame f_main.
            view frame frame2.
            view frame frame3.
        end.
        /**/
        MESSAGE "ДОКУМЕНТЫ СФОРМИРОВАНЫ " view-as alert-box.
        displ  v-joudoc format "x(10)" v_joutrx format "zzzzzzzzz"
        v_rmzdoc format "x(10)" v_rmztrx  format "zzzzzzzzz" with frame frame3.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if v_sumt <> 0 or v_sumkt <> 0 or v_crc = 1 or v_crck = 1 then do:
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
                if jl.gl = 100500 then find first b-jl where b-jl.jh = jl.jh and b-jl.ln = if jl.dc = 'D' then jl.ln + 1 else jl.ln - 1 no-lock no-error.
                if avail b-jl and lookup(string(b-jl.gl),'185800,185900,285800,285900') > 0 then v-conv = false.
                if v_countr1 = "KZ" then do:
                    if jl.dc = "c" and (jl.cam = v_sumkt and v_sumkt <> 0) or (v_crck = 1 and jl.cam = v_sumk and v_sumk <> 0) then jlsach.sim = if v-conv = yes then 100 else 030.
                    if jl.dc = "d" and (jl.dam = v_sumkt and v_sumkt <> 0) or (v_crck = 1 and jl.dam = v_sumk and v_sumk <> 0) then jlsach.sim = if v-conv = yes then 100 else 030.
                    if jl.dc = "c" and jl.cam = v_sumt and v_sumt <> 0 then jlsach.sim = if v-conv = yes then 050 else 030.
                    if jl.dc = "d" and jl.dam = v_sumt and v_sumt <> 0 then jlsach.sim = if v-conv = yes then 050 else 030.
                end.
                else do:
                    if jl.dc = "c" and (jl.cam = v_sumkt and v_sumkt <> 0) or (v_crck = 1 and jl.cam = v_sumk and v_sumk <> 0) then jlsach.sim = if v-conv = yes then 100 else 030.
                    if jl.dc = "d" and (jl.dam = v_sumkt and v_sumkt <> 0) or (v_crck = 1 and jl.dam = v_sumk and v_sumk <> 0) then jlsach.sim = if v-conv = yes then 100 else 030.
                    if jl.dc = "c" and jl.cam = v_sumt and v_sumt <> 0 then jlsach.sim = if v-conv = yes then 060 else 030.
                    if jl.dc = "d" and jl.dam = v_sumt and v_sumt <> 0 then jlsach.sim = if v-conv = yes then 060 else 030.
                end.
                release jlsach.
            end.
        end.
    view frame f_main.
    view frame frame2.
    view frame frame3.
    if v-noord = no then run vou_bankt(1, 2, joudoc.info).
    else run printord(s-jh,"").
        s-jh = v_joutrx.

end procedure.

procedure Delete_transaction:
    if v-joudoc = "" then undo, retry.
    find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box.
        return.
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
            return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then do:
            message "Свод кассы завершен, удалить нельзя" view-as alert-box.
            return.
        end.
    end.
    find first remtrz where remtrz.remtrz = v_rmzdoc no-lock no-error.
    if not available remtrz  then do:
        message "RMZ документ не найден, продолжение не возможно." view-as alert-box.
        return.
    end.
    find first que where que.remtrz = v_rmzdoc no-lock no-error.
    if available que and (que.pid <> "O" and que.pid <> "31")then do:
        message "RMZ документ уже отправлен, для продолжения в меню 6.3.9 измените номер очереди на 31." view-as alert-box.
        return.
    end.
    else do:
        if remtrz.jh2 > 1 then do:
            message "Проведена вторая проводка RMZ документа, для продолжения удалите ее в меню 6.3.9." view-as alert-box.
            return.
        end.
    end.

        v_er1 = 0.
        run Delete_transaction1.
        if v_er1 <> 0 and v_er1 <> 3 then return.
        v_er1 = 0.
        run Delete_transaction2.
        if v_er1 <> 0 then return.
        /*v-joudoc = v_docdoc.*/
        find first jh where jh.jh = v_joutrx no-lock no-error.
        if available jh and index(jh.party,"deleted") > 0 then do:
            v_joutrx = ?.
            message "Транзакция JOU документа удалена." view-as alert-box.
        end.
        find first jh where jh.jh = v_rmztrx no-lock no-error.
        if available jh and index(jh.party,"deleted") > 0 then do:
            v_rmzdoc = ?.
            v_rmztrx = ?.
            find first joudop where joudop.docnum = v-joudoc exclusive-lock.
            joudop.doc1 = "".
            find first joudop where joudop.docnum = v-joudoc no-lock.
            message "Транзакция RMZ документа удалена." view-as alert-box.
        end.
        view frame f_main.
        view frame frame2.
        view frame frame3.

        display v_joutrx v_rmzdoc v_rmztrx with frame frame3.

end procedure.


procedure Delete_transaction1:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакции по JOU документу не существует." view-as alert-box.
        pause 3.
        v_er1 = 3.
        return.
    end.

    /* ------------storno joudoc-----------------*/
        quest = false.
        if jh.jdt lt g-today then do:
            message substitute ("Дата проведения транзакции &1.  Сторно?", jh.jdt) update quest.
            if not quest then do:
                v_er1 = 1.
                return.
            end.
             /* -------------------------for cashofc, by sasco, 18.10.01 -------- */
            for each jl where jl.jh eq joudoc.jh no-lock:
                if not avail jl then message "Не найдена запись в JL для JOUDOC.JH -> CASHOFC".
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
                v_er1 = 1.
                return.
            end.
            run x-jlvo.
        end.
        /* ------------storno ?????????-----------------*/
        else do:
            message "Удалиться транзакция JOU документа,вы уверены ?" update quest.
            if not quest then do:
                v_er1 = 1.
                return.
            end.
            v-sts = jh.sts.

            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                v_er1 = 1.
                return.
            end.
            hide all.
            run trxdel (input s-jh, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                if rcode = 50 then do:
                    view frame f_main.
                    view frame frame2.
                    view frame frame3.
                end.
                message rdes.
                if rcode = 50 then do:
                    run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                    view frame f_main.
                    view frame frame2.
                    view frame frame3.
                    return.
                end.
                else do:
                    view frame f_main.
                    view frame frame2.
                    view frame frame3.
                    return.
                end.
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

        /*end.  transaction */
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        release joudoc.
        run chgsts("JOU", v-joudoc, "new").
end procedure.


procedure Delete_transaction2:
    if v_rmzdoc eq "" then undo, retry.
    find remtrz where remtrz.remtrz eq v_rmzdoc no-lock no-error.
    if not avail remtrz then undo, retry.
    if remtrz.jh1 eq ? then do:
        message "Транзакции по RMZ документу не существует." view-as alert-box.
        pause 3.
        v_er1 = 1.
        return.
    end.
        /*удаление rmz документа--------------------------------------------------------------------------------------------*/
        s-remtrz = v_rmzdoc.
        m_pid = "O".
        hide all.
        run rmzcano.
        view frame f_main.
        view frame frame2.
        view frame frame3.
        find first jh where jh.jh = v_rmztrx no-lock no-error.
        if available jh and index(jh.party,"deleted") > 0 then do:
            for each remtrz where remtrz.remtrz = v_rmzdoc exclusive-lock.
                delete remtrz.
            end.
            for each cursts where cursts.sub = "rmz" and cursts.acc = v_rmzdoc exclusive-lock.
                delete cursts.
            end.
            for each substs where substs.sub = "rmz" and substs.acc = v_rmzdoc exclusive-lock.
                delete substs.
            end.
            for each sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = v_rmzdoc exclusive-lock.
                delete sub-cod.
            end.
            for each swbody where swbody.rmz = v_rmzdoc exclusive-lock.
                delete swbody.
            end.
            for each que where que.remtrz = v_rmzdoc exclusive-lock.
                delete que.
            end.
        end.
end procedure.


procedure Screen_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh = ? then do:
        message "Транзакции jou документа не существует." view-as alert-box.
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
    /*run vou_bankt(1, 2, joudoc.info).*/
    if v-noord = no then run vou_bankt(1, 2, joudoc.info).
    else do:
        run printord(s-jh,"").
    end.
    end. /* transaction */
end procedure.

procedure print_statement:
    {a_foreign1printapp.i}
end procedure.

procedure eng:
    define input parameter t as char.
    def output parameter ch as logic.
	def var rus as char extent 33 init ["А","Б","В","Г","Д","Е", "Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф", "Х","Ц", "Ч", "Ш", "Щ",  "Ъ","Ы", "Ь", "Э", "Ю", "Я"].
	def var i as integer.
	def var j as integer.
	t = caps(t).
	i = 1.
    ch = no.
	repeat:
	 do j = 1 to 33:
	    if substr(t,i,1) = rus[j] then ch = yes.
	 end.
	 i = i + 1.
	 if i > length(t) then leave.
	end.
end procedure.

procedure ciffind:
define input parameter vv as char .
define output parameter result  as char.
result = "".
famlist = "".

    if v_bin then do:
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
    v-Get_Nal = yes.

   /* vj-label  = " Выполнить прием наличных?..................".
    s-jh = joudoc.jh.
    enable but with frame frame3.
    pause 0.
    def var v-errmsg as char init "".
    def var v-rez as logic init false.
    run csstampf(s-jh, v-nomer, output v-errmsg, output v-rez ).
    view frame f_main.
    disable but with frame frame3.
    if  v-errmsg <> "" or not v-rez then do:
        if v-errmsg <> "" then message  v-errmsg view-as alert-box error.
        undo, return.
    end.
    run chgsts(m_sub, v-joudoc, "rdy").
    message "Проводка отштампована " view-as alert-box.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").*/
end procedure.

procedure swift_open:
    run tswprns.
end procedure.

/** Признаки **/
procedure a_subcod:
    run subcodj (v-joudoc, "jou").
    view frame f_main.
    view frame frame2.
    view frame frame3.
end procedure.

procedure sc:
/*--------------------------------------------------------------*/

    def var curPage as int.
    def var posPage as int.

    TCIFNAME = "TCIFNAME=" + UrlEncode(v_lname) + " " + UrlEncode(v_name) + " " + UrlEncode(v_mname).
    TINN = "TINN=" + v_rnn.
    TKOD = "TKOD=" + v_rez.
    TSUMM = "TSUMM=" + replace(trim(string(v_sum,'->>>>>>>>>>>>>>9.99')),'.',',').
    TCRC = "TCRC=" + getcrc(v_crc).
    TKBE = "TKBE=" + v_kbe.
    TRBANK = "TRBANK=" + UrlEncode(v_bank).
    TREM = "TREM=" + UrlEncode(v_oper).
    TKNP = "TKNP=" + v_knp.
    TRECNAME = "TRECNAME=" + UrlEncode(v_namepol).
    TRECINN = "TRECINN=" + v_innpol.
    TRECAAA = "TRECAAA=" + v_chpol.
    TRBANK = "TRBANK=" + UrlEncode(v_bank1).
    TRBANKBIK = "TRBANKBIK=" + v_swbic1.
    TVALDATE = "TVALDATE=" + string(v-dat2, "99.99.9999").
    TCOMSUMM = "TCOMSUMM=" + string(v_sumk, "->>>>>>>>>>>>>>9.99").

    v-res111 = TCIFNAME + "&" + TINN + "&" + TKOD + "&" + TSUMM + "&" + TCRC + "&" + TKBE + "&" + TREM + "&" + TKNP + "&" +
                TRECNAME + "&" + TRECINN + "&" + TRECAAA + "&" + TRBANK + "&" + TRBANKBIK + "&" + TCOMSUMM + "&" + TVALDATE.

    CurPage = 1.
    PosPage = 1.
    MaxPage = 2.

    Pages = "1 из " + string(MaxPage).
    DISPLAY Pages Mask WITH FRAME Form1.

    run to_screen("transfer", v-res111).

    ON CHOOSE OF next-button
    DO:
        PosPage = PosPage + 1.
        if PosPage > MaxPage then PosPage = MaxPage.
        Pages = string(PosPage) + " из " + string(MaxPage).

        if PosPage = 1 then do:
            run to_screen("transfer", v-res111).
        end.
        else do:
            run to_screen("paytrans2", v-res111).
        end.
        DISPLAY Pages Mask WITH FRAME Form1.
    END.

    ON CHOOSE OF prev-button
    DO:
        PosPage = PosPage - 1.
        if PosPage <= 0 then PosPage = 1.
        Pages = string(PosPage) + " из " + string(MaxPage).

        if PosPage = 1 then do:
            run to_screen("transfer", v-res111).
        end.
        else do:
            run to_screen("paytrans2", v-res111).
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
    run a_stamp(joudoc.jh).
    pause 0.
    hide all.
    view frame f_main.
    view frame frame2.
    view frame frame3.

end.

