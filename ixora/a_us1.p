/* a_us1.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
         Переводы cо счета клиентa в  ин.валюте
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
        07/02/2012 Luiza - добавила код тарифа 304
        08/02/2012 Luiza - добавила удаление очереди при удалении документа и вывод свифта
        05/03/2012 Luiza - добавила заполнение  поля 50 в свифт макете  swbody.swfield = "50".
        06/03/2012 Luiza - добавила заполнение  поля 59 в свифт макете  swbody.swfield = "59".
        07/03/2012 Luiza  - изменила передачу параметров при вызове printord
        13/03/2012 Luiza  - для усткамена новые коды комиссии
        14/03/2012 Luiza - если нет банка корресп тип для 56 поля ставим "N"
        29/03/2012 Luiza  - добавила вывод сообщения о создании транзакции с номером проводки
        05/04/2012 Luiza  - изменила применение транлитерации для 50 поля в случае не росс рубл
        06/04/2012 Luiza  - изменила применение транлитерации для 70 поля
        11/04/2012 Luiza  - отменила автом проставл кода страны
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        26.04.2012 aigul - добавила ГК2204 для обхода проверки
        05.05.2012 damir - добавлены a_us2printapp.i,a_usprintapp.i. Новые форматы заявлений.
        08.05.2012 damir - изменения в a_usprintapp.i,a_us2printapp.i. Перекомпиляция.
        11.05.2012 aigul - исправила проверку для ГК2204
        11/05/2012 Luiza - при реактировании удаляем запись в vcdocs и добавила счет 222330
        15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
        21/05/2012 Luiza - согласно СЗ для Устькамена отменила тип комиссии SHA
        30/05/2012 Luiza - добавила проверку в пользу третьих лиц
        31.05.2012 aigul - сделала исключения для ГК 2206-2217
        05.06.2012 damir - перекомпиляция.
        17/09/2012 Luiza - переход на ИИН
        19/09/2012 Luiza - если для 50 поля swbody.content[] = ? заменяю на ""
        24/09/2012 Luiza - проверка на нулевую сумму комиссии
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.Перекомпиляция в связи с изменениями в a_usprintapp.i,a_us2printapp.i.
        23/01/2013 Luiza - ТЗ №1665 Изменение кодов тарифов для ВКО для юр лиц
        23/01/2013 Lyubov - ТЗ №1665, убрала исключение TXB14 для кода тарифа SHA
        01/04/2013 Luiza - ТЗ  1789 при сравнении ИИН/БИН отправителя и получателя учитывать наличие ключевых слов “/RNN/”.
        10/04/2013 Luiza ТЗ № 1515 Оповещение менеджера о клиенте
        15/05/2013 Luiza - ТЗ № 1826
        06/08/2013 Luiza - ТЗ 1997 Расширение поля «Код тарифа»
        07/08/2013 Luiza - ТЗ 1997 перекомпиляция
        07/10/2013 Luiza - *ТЗ 1956
        08/10/2013 Luiza - перекомпиляция
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
/*def new shared var v-num as integer no-undo.*/
def var v_crck as int  no-undo .  /* Валюта comiss*/
def var v-crcp as int  no-undo .  /* Валюта */
def var v-pnp as char format "x(20)". /* счет клиента*/
def var v-chetk as char format "x(20)". /* счет клиента for comiss*/
def var v-glk as int.
def var v-chetp as char format "x(20)". /* счет клиента */
def var v-cif as char format "x(6)". /* cif клиент*/
def var v-addr as char format "x(100)". /* adress клиент*/
def var v-cifp as char format "x(6)". /* cif клиент*/
def var v_name as char format "x(30)". /*  клиент*/
def var v_names as char format "x(30)". /*  клиент*/
def var v_namep as char format "x(30)". /*  клиент*/
def var v_pakalp as char format "x(30)". /*  комиссия*/
def var v-cif1 as char format "x(6)". /*  клиент*/
def var v-jss as char format "x(12)". /*  рнн клиента*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v_tar as int .  /* tarif*/
def var v_tarname as char no-undo format "x(3)".  /* tarif*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_oper1 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper3 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper5 as char no-undo .  /* Назначение платежа*/
def var v_doc_num as char format "x(30)".
def var v-rnn as log no-undo.
def new shared var s-remtrz like remtrz.remtrz.
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
def var v-reg5 as char format "x(12)".
def var v-bin5 as char format "x(12)".
def var ourbank like bankl.bank no-undo.
def var v-cashgl like gl.gl no-undo.
def var v-gl as int.
def var tt1 as char format "x(60)" no-undo.
def var tt2 as char format "x(60)" no-undo.
def var bila like aaa.cbal label "ОСТАТОК" 	no-undo.
def buffer xaaa  for aaa.
def buffer b-cif for cif.
def buffer b-aaa for aaa.
def buffer d-aaa for aaa.
def buffer d-cif for cif.
def var l-ans as logical no-undo.
def new shared var s-aaa like aaa.aaa.
def var v-oplcom as char.
def var v-viddoc as char.
def var v_sumc as decim format ">>>>>>>>>>>>>>9.99".
def  var v_ben as char no-undo format "x(3)".
def var lll as int.

def  new shared  var v_bank as char format "x(50)" no-undo.
def  new shared  var v_numch1 as char format "x(50)" no-undo.
def  new shared  var v_bank1 as char format "x(50)" no-undo.
def  new shared  var v_bank2 as char format "x(50)" no-undo.
def  new shared  var v_chpol as char format "x(50)" no-undo.
def  new shared  var v_innpol as char format "x(12)" no-undo.
def  new shared  var v_namepol as char format "x(50)" no-undo.
def  new shared  var v_oper as char format "x(140)" no-undo.
def  new shared  var v_swcod as char format "x(1)"  no-undo.
def  new shared  var v_swcity as char format "x(35)" no-undo.
def  new shared  var v_swcnt as char format "x(35)" no-undo.
def  new shared  var v_swcod1 as char format "x(1)"  no-undo.
def  new shared  var v_swcity1 as char format "x(35)" no-undo.
def  new shared  var v_swcnt1 as char format "x(35)" no-undo.
def  new shared  var v_swbic as char format "x(35)" no-undo.
def  new shared  var v_swbic1 as char format "x(35)" no-undo.
def  new shared  var v_countr1 as char format "x(35)" no-undo.
def  new shared  var v_crc as int no-undo.
def var v-dat2 as date format "99/99/9999".

def var v-chk as logical initial no.
def var v-sum-usd as decimal.
def var v-select as char.
def var v-prov as logic.
def var v-sts1 as logical initial no.

/* для комиссии*/
def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.

def stream v-out.
def var v-file      as char init "Applicforeign.htm".
def var v-inputfile as char init "".
def var v-naznplat  as char.
def var v-str       as char.
def var i           as inte.
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

/*проверка банка*/
def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
ourbank = sysc.chval.


def var v-chk1 as char no-undo.
find first bookcod where bookcod.bookcod = 'a_kz1'
                     and bookcod.code    = 'chk'
                     no-lock no-error.
if not avail bookcod or trim(bookcod.name) = "" then do:
    message "В справочнике <bookcod> код <chk> отсутствует список  для определения допустимых счетов ГК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
v-chk1 = bookcod.name.


/* для типа комиссии  */
define temp-table tmpben
       field ttt as char
       field des as char.
create tmpben. tmpben.ttt = "OUR". tmpben.des = "Комиссия за счет отправителя".
create tmpben. tmpben.ttt = "BEN". tmpben.des = "Комиссия за счет бенефициара".
create tmpben. tmpben.ttt = "SHA". tmpben.des = "Комиссия за счет бенефициара и отправителя".

function crc-conv returns decimal (sum as decimal, c1 as int, c2 as int).
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

find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
if not avail sysc then do:
	message " Запись RMCASH отсутствует в файле sysc. " .
	return.
end.
v-cashgl = sysc.inval .


find last sysc where sysc.sysc = 'PRI_PS' no-lock no-error.
if not avail sysc or sysc.chval = '' then do:
	message " Запись PRI_PS отсутствует в файле sysc !! " view-as alert-box.
	return.
end.

/*def var v-bin as logi init no.*/

define button but label " "  NO-FOCUS.
s-ourbank = trim(sysc.chval).

def var v-ref as char.
def var v-priory as char init "o".
def var v-transp as int.

{lgps.i}
pause 0.
/* для использования BIN */
{chk12_innbin.i}
pause 0.
{chbin.i}
pause 0.

{comchk.i}
pause 0.
{keyord.i}

function chkkomiss1 returns logical (p-value as decimal).
  def var v-msgs as char init " Сумма комиссии выходит за пределы установленного тарифа!".

  /* вообще проверяем тарифы только для валютных платежей */
  if v_crck = 1 then return true.

  /* если не задан код комиссии - ничего не проверяем */
  if v_tar = 0 then return true.


  /* заодно проверим, чтобы комиссия за счет отправителя соответствовала  */
  if not chkkomcod (v_tar) then do:
    return false.
  end.

  /* проверка сумм */
  if (p-value < v-komissmin) or (v-komissmax > 0 and p-value > v-komissmax) then do:
    v-msgerr = v-msgs.
    return false.
  end.

  return true.
end.

def var v_label1 as char format "x(20)".
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v_label1 = " ИИН/БИН           :". else v_label1 = " РНН               :".

   form
        s-remtrz label " Документ          " format "x(10)"    v_trx label   "                     ТРН " format "zzzzzzzzz"           but skip
        v-viddoc label " Вид документа     " validate(can-find(first codfr where codfr.codfr = 'pdoctng' no-lock), "Нет такого кода вида документов! F2-помощь") format "x(2)" help "F2 - помощь" skip
        v-ref    label " Nr.плат.поруч     " format "x(9)" validate (v-ref <> "" or v-ref = "б/н" ,"если платежное поручение без номера наберите 'б/н'! ") help "Если ПлПоруч без номера наберите 'б/н'!Иначе только цифры" skip
        v-priory label " Приоритет         " validate(v-priory = "o" or v-priory = "s", "Hеверный приоритет") format "x(1)" skip
        v-pnp    label " Счет клиента      "  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-pnp and aaa.crc <> 1 and lookup(string(aaa.gl),v-chk1) > 0 no-lock),
                "Неверный счет ГК счета клиента!") skip
        v_name   label " Отправитель       "  format "x(50)" skip
        /*v-reg5   label "      РНН          " format "x(12)" validate(length(v-reg5) = 12 , "Введите 12 цифр РНН !") skip*/
        v_label1 no-label v-bin5  no-label  format "x(12)" validate((chk12_innbin(v-bin5)),'Неправильно введён БИН/ИИН') skip(1)
        v_crc    label " Валюта перевода   " format ">9" validate(can-find(first crc where crc.crc = v_crc and v_crc <> 1 and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum    LABEL " Сумма             " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_code  label  " КОД               " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label  " КБе               "  validate(length(v_kbe) = 2, "Hеверное значение КБе") skip
        v_knp   label  " КНП               "  validate(can-find(first codfr where codfr.codfr = "spnpl" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_knp no-lock), "Нет такого кода КНП! F2-помощь") skip
        v_countr1 label " Страна получения  " validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_countr1 no-lock), "Нет такого кода страны! F2-помощь") format "x(2)" skip
        v_oper  label  " Назнач.платежа    "   format "x(35)" skip
        v_oper1 no-label colon 20 format "x(35)" skip
        v_oper2 no-label colon 20  format "x(35)" skip
        v_oper3 no-label colon 20  format "x(35)" skip(1)
        v_crck   label " Валюта комиссии   " help "Введите код валюты комиссии, F2-помощь"   format ">9" validate(can-find(first crc where crc.crc = v_crck and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_ben    label " Оплата комиссии   " validate((v_ben = "OUR" or v_ben = "BEN" or v_ben = "SHA") , "Неверный тип оплаты комиссии должно быть OUR, BEN или SHA") format "x(3)" help "тип комиссии должен быть OUR, BEN или SHA" skip
        v_tar    LABEL " Код тарифа        " format ">>999" validate(((v_tar = 208 or v_tar = 209) and cif.type = "P" and (v_crc <> 1))
                                                   or (v_tar = 217 and cif.type = "P" and v_crc = 4)
                                                   or ((v_tar = 204 or v_tar = 205 or v_tar = 304) and cif.type = "B" and (v_crc <> 1) /*and ourbank <> "TXB14"*/)
                                                   /*or ((v_tar = 305 or v_tar = 306 or v_tar = 306) and cif.type = "B" and (v_crc <> 1) and ourbank = "TXB14")*/
                                                   or (v_tar = 218 and cif.type = "B" and v_crc = 4)
                                                   ,"Неверный код тарифа комиссии")  help " Введите код тарифа комиссии, F2 помощь"
        v_tarname   label "Наим.тариф" format "x(26)" at 37 skip
        v_sumk   label " Сумма комиссии    " validate((v-amt > 0 and v_sumk > 0) or (v-amt = 0 and v_sumk = 0), "Hеверное значение суммы") format ">>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        v-oplcom label " Тип оплаты комис. " format "x(30)" skip
        v-chetk  label " Счет комиссии     "  help "F2-помощь" format "x(21)" skip
        v-dat2   label " Дата валютирования" validate (v-dat2 >= today, " Проверьте дату") skip
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 2
    TITLE v_title width 80 FRAME f_main.

form
     v_oper5 no-label VIEW-AS EDITOR SIZE 68 by 6
     with frame detpay row 23 overlay centered title "Детали платежа" .

/* help for cif */
DEFINE VARIABLE phand AS handle.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
/*  help for cif */

DEFINE QUERY q-country FOR codfr.
DEFINE BROWSE b-country QUERY q-country
       DISPLAY codfr.code label "Код " format "x(3)" codfr.name[1] label "Наименование " format "x(30)"  WITH  10 DOWN.
DEFINE FRAME f-country b-country  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 40 width 50 NO-BOX.

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

DEFINE QUERY q-ben FOR tmpben.
DEFINE BROWSE b-ben QUERY q-ben
       DISPLAY tmpben.ttt label "Тип комиссии " format "x(3)" tmpben.des format "x(40)" label "Описание" WITH  3 DOWN.
DEFINE FRAME f-ben b-ben  WITH overlay 1 COLUMN SIDE-LABELS row 12 COLUMN 20 width 70 NO-BOX.
on help of v_ben in frame f_main do:
    OPEN QUERY  q-ben FOR EACH tmpben no-lock.
    ENABLE ALL WITH FRAME f-ben.
    wait-for return of frame f-ben
    FOCUS b-ben IN FRAME f-ben.
    v_ben = tmpben.ttt.
    hide frame f-ben.
    displ v_ben with frame f_main.
end.


DEFINE QUERY q-viddoc FOR codfr.
DEFINE BROWSE b-viddoc QUERY q-viddoc
       DISPLAY codfr.code label "Код  " format "x(3)" codfr.name[1] label "Наименование   " format "x(60)"
       WITH  15 DOWN.
DEFINE FRAME f-viddoc b-viddoc  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 35 width 85 NO-BOX.

on help of v-viddoc in frame f_main do:
    OPEN QUERY  q-viddoc FOR EACH codfr where codfr.codfr = "pdoctng" and codfr.code <> "msc" no-lock.
    ENABLE ALL WITH FRAME f-viddoc.
    wait-for return of frame f-viddoc
    FOCUS b-viddoc IN FRAME f-viddoc.
    v-viddoc = codfr.code.
    hide frame f-viddoc.
    displ v-viddoc with frame f_main.
end.

DEFINE QUERY q-tar FOR tarif2.
DEFINE BROWSE b-tar QUERY q-tar
       DISPLAY tarif2.str5 label "Код тарифа " format "x(3)" tarif2.pakalp label "Наименование   " format "x(30)"
       WITH  15 DOWN.
DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.

on help of v_crc in frame f_main do:
    run help-crc1.
end.
on help of s-remtrz in frame f_main do:
    run h-remtrz.
    s-remtrz = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
on "END-ERROR" of v-pnp in frame f_main do:
  return.
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

on "END-ERROR" of frame f-viddoc do:
  hide frame f-viddoc no-pause.
end.

on "END-ERROR" of frame f-country do:
  hide frame f-country no-pause.
end.

on help of v_countr1 in frame f_main do:
    OPEN QUERY  q-country FOR EACH codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc"  no-lock.
    ENABLE ALL WITH FRAME f-country.
    wait-for return of frame f-country
    FOCUS b-country IN FRAME f-country.
    v_countr1 = codfr.code.
    /*v_country = codfr.name[1]. */
    hide frame f-country.
    displ v_countr1  with frame f_main.
end.

/*  help for cif */
on help of v-pnp in frame f_main do:
    on "END-ERROR" of frame f-help do:
    end.
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
  DELETE PROCEDURE phand.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.crc <> 1 and aaa.sta <> "C" and aaa.sta <> "E" no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.crc <> 1  and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-pnp = aaa.aaa.
            hide frame f-help.
            displ v-pnp with frame f_main.
      end.
        else do:
            v-pnp = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            displ v-pnp with frame f_main.
            return.
        end.
    end.
end.

on help of v-chetk in frame f_main do:
    hide frame f-help.
    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    if not avail aaa then do:
        v-cif1 = "".
        run h-cif PERSISTENT SET phand.
        hide frame xf.
        v-cif1 = frame-value.
       DELETE PROCEDURE phand.
    end.
    else v-cif1 = aaa.cif.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc = v_crck and length(aaa.aaa) >= 20 no-lock no-error.
        if available aaa then do:
           OPEN QUERY  q-help FOR EACH aaa where aaa.cif = v-cif1 and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc = v_crck and length(aaa.aaa) >= 20 no-lock,
                            each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-chetk = aaa.aaa.
            hide frame f-help.
        end.
        else do:
            v-chetk = "".
            message "В данном пункте возможно осуществлять  операции только по счетам клиентов.".
        end.
        displ  v-chetk with frame f_main.
        return.
    end.
    else DELETE PROCEDURE phand.
end.

on help of v_tar in frame f_main do:
        if cif.type = "P" and (v_crc <> 1) then  OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "208" or tarif2.str5 = "209") and tarif2.stat  = "r" no-lock.
        if cif.type = "P" and v_crc = 4 then OPEN QUERY  q-tar FOR EACH tarif2 where tarif2.str5 = "217" and tarif2.stat  = "r" no-lock.
        if cif.type = "B" and (v_crc <> 1) /*and ourbank <> "TXB14"*/  then OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "204" or tarif2.str5 = "205" or tarif2.str5 = "304") and tarif2.stat  = "r" no-lock.
        /*if cif.type = "B" and (v_crc <> 1) and ourbank = "TXB14"  then OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "305" or tarif2.str5 = "306") and tarif2.stat  = "r" no-lock.*/
        if cif.type = "B" and v_crc = 4 then OPEN QUERY  q-tar FOR EACH tarif2 where tarif2.str5 = "218" and tarif2.stat  = "r" no-lock.
    ENABLE ALL WITH FRAME f-tar.
    wait-for return of frame f-tar
    FOCUS b-tar IN FRAME f-tar.
    v_tar = int(tarif2.str5).
    hide frame f-tar.
    displ v_tar with frame f_main.
end.

on help of v_crck in frame f_main do:
    run help-crc1.
end.

on help of v-priory in frame f_main do:
                  run uni_help1("urgency",'*').
end.

function CheckRNN returns char(input p-str as char).
    def var v-res as char.
    v-res = "".

    if index(trim(p-str),"/RNN/") > 0 then v-res = v-res + substr(trim(p-str),1,index(trim(p-str),"/RNN/") - 1) + " " +
    substr(trim(p-str),index(trim(p-str),"/RNN/") + 17,length(p-str)).
    else v-res = v-res + p-str.

    return v-res.
end function.

function CutRNN returns char(input p-str as char).
    def var v-res as char.
    v-res = "".

    if index(trim(p-str),"/RNN/") > 0 then v-res = v-res + substr(trim(p-str),index(trim(p-str),"/RNN/") + 5,12).
    else v-res = v-res + p-str.

    return v-res.
end function.

m_pid = "O".
if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = "Переводы по счетам клиентов в  ин.валюте ".
    run n-remtrz.   /*получили новый номер для rmz в переменной s-remtrz***/
    find first nmbr no-lock no-error.
    do transaction:
        v_oper = "" .
        displ s-remtrz format "x(10)" with frame f_main.
        v-ja = yes.
        v-pnp = "".
        v_sum = 0.
        v_crc = ?.
        v_oper5 = "".
        v_oper1 = "".
        v_oper2 = "".
        v_oper3 = "".
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = "Переводы по счетам клиентов в  ин.валюте ".
    run view_doc ("").
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc("").
            find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
            if available remtrz then do:
                /*if remtrz.sts <> "US1" then do:
                    message substitute ("Документ не относится к типу переводы по счетам клиентов в  ин.валюте  ") view-as alert-box.
                    return.
                end.*/
                if remtrz.jh1 ne ? then do:
                    message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
                    return.
                end.
                if remtrz.rwho ne g-ofc then do:
                    message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box.
                    return.
                end.
                for each vccontrs where vccontrs.cif = v-cif no-lock.
                    find first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dnnum = substr(s-remtrz,4,6) no-error.
                    if available vcdocs then do:
                        delete vcdocs.
                        find first vcdocs no-lock no-error.
                        leave.
                    end.
                end.
            end.
            run save_doc.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ s-remtrz v_label1 with  frame f_main.

    update  v-viddoc  with frame f_main.
    /*L_1:*/
    repeat /* on endkey undo, next L_1*/ :
        update v-ref  with frame f_main.
        if v-ref = 'б/н' then leave.
        if integer(v-ref) > 0 then leave.
        message "номер платежного поручения не может содержать текст!" view-as alert-box error.
        /*undo, retry.*/
    end.
    if keyfunction (lastkey) = "end-error" then undo.
    update v-priory with frame f_main.
    if v-priory = "s" then v-transp = 2.
    else v-transp = 1.
    update v-pnp help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    /*------------------------------------------------------------*/
    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v_crc = aaa.crc.
        v-gl = aaa.gl.
        find first cif where cif.cif = v-cif no-lock no-error.
        if avail cif then do:
            if cif.bin = '' then do:
                if g-today < 01/01/13 then message ' ИИН/БИН отсутсвует в карточке клиента, запросите у клиента документ с ИИН/БИН и внесите данные в АБС. ' view-as alert-box title " ВНИМАНИЕ ! ".
                else do:
                    message ' Операции без ИИН/БИН невозможны. ' view-as alert-box title " ВНИМАНИЕ ! ".
                    return.
                end.
            end.
            v-addr = cif.addr[1].
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
        find last cifsec where cifsec.cif = cif.cif no-lock no-error.
        if avail cifsec then do:
            find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
            if not avail cifsec then do:
                create ciflog.
                assign
                    ciflog.ofc = g-ofc
                    ciflog.jdt = today
                    ciflog.cif = cif.cif
                    ciflog.sectime = time
                    ciflog.menu = "Регистрация исходящих платежей".
                release ciflog.
                message "Клиент не Вашего Департамента." view-as alert-box buttons ok.
                undo,retry.
            end.
            else do:
                create ciflogu.
                assign
                    ciflogu.ofc = g-ofc
                    ciflogu.jdt = today
                    ciflogu.sectime = time
                    ciflogu.cif = cif.cif
                    ciflogu.menu = "Регистрация исходящих платежей".
                release ciflogu.
            end.
        end.
    end.
    /******************************/
            find aaa where aaa.aaa = v-pnp no-lock no-error. /* new */
            if avail aaa then find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
            if not available aaa then do:
                bell.
                {mesg.i 2203}.
                undo,retry.
            end.
            else
            if avail lgr and lgr.led = "ODA" then do:
                message " Счет типа ODA   ".
                pause.
                undo,retry.
            end.
            run aaa-aas.
            find first aas where aas.aaa = v-pnp and aas.sic = 'SP' no-lock no-error.
            if available aas then do: pause. undo,retry. end.
            if aaa.crc <> v_crc then do:
                bell.
                {mesg.i 9813}.
                undo,retry.
            end.
            if aaa.sta = "C" then do:
                bell.
                {mesg.i 6207}.
                undo,retry.
            end.
            find cif of aaa no-lock no-error.
            tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
            tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
            v_name = trim(tt1) + ' ' + trim(tt2).
			/*BIN*/
            if v-bin = no then do:
                v-reg5 = trim(substr(cif.jss,1,13)).
                v-bin5 = trim(substr(cif.jss,1,13)).
            end.
            else do:
                v-bin5 = trim(substr(cif.bin,1,13)).
                v-reg5 = trim(substr(cif.jss,1,13)).
            end.
            disp /*v-reg5*/ v-bin5 with frame f_main.
            pause 0.
            if v-bin then v_name = trim(v_name) + ' /RNN/' + trim(v-bin5). /* потом поменять на IDN */
            else v_name = trim(v_name) + ' /RNN/' + trim(v-reg5).
   /* hide frame ggg1.
    hide frame ggg.*/
    displ v_name v-bin5 /*v-reg5*/ v_crc  v_code /*v_oper vj-label  format "x(35)" no-label*/ with frame f_main.
    pause 0.
    /* ИНФОРМАЦИЯ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА */
    if trim(cif.reschar[20]) <> "" or trim(cif.reschar[17]) <> "" then run a_mescif(trim(cif.cif)).

    update v_sum  v_code v_kbe v_knp with frame f_main.
    if substring(v_kbe,1,1)  = "1" then do:
        v_countr1 = "". /* "KZ".*/
        update v_countr1 with frame f_main.
        pause 0.
        /*update v_oper v_oper1 v_oper2 v_oper3 with frame f_main.*/
        v_oper5 = v_oper + v_oper1 + v_oper2 + v_oper3.
        repeat:
            update v_oper5 go-on("return") with frame detpay.
            if length(v_oper5) > 140 then message 'назначение платежа превышает 140 символов, для внесения большего количества символов, обратитесь к сотрудникам ДПС!'.
            else leave.
        end.
        v_oper = substring(v_oper5,1,35).
        v_oper1 = substring(v_oper5,36,35).
        v_oper2 = substring(v_oper5,71,35).
        v_oper3 = substring(v_oper5,106,35).
        displ  v_oper v_oper1 v_oper2 v_oper3 with frame f_main.
        pause 0.
    end.
    else do:
        update v_countr1  with frame f_main.
        find first stoplist where stoplist.code = v_countr1 no-lock no-error.
        if avail stoplist and stoplist.sts <> 9 then do:
            message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
            return.
        end.
        v_oper5 = v_oper + v_oper1 + v_oper2 + v_oper3.
        repeat:
            update v_oper5 go-on("return") with frame detpay.
            if length(v_oper5) > 140 then message 'назначение платежа превышает 140 символов, для внесения большего количества символов, обратитесь к сотрудникам ДПС!'.
            else leave.
        end.
        v_oper = substring(v_oper5,1,35).
        v_oper1 = substring(v_oper5,36,35).
        v_oper2 = substring(v_oper5,71,35).
        v_oper3 = substring(v_oper5,106,35).
        displ  v_oper v_oper1 v_oper2 v_oper3 with frame f_main.
        pause 0.
    end.
    do transaction:
        if new_document then do:
            create remtrz.
            remtrz.remtrz = s-remtrz.
        end.
        else find remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
        remtrz.ptype = "N".
        remtrz.rdt = g-today.
        remtrz.rtim = time.
        remtrz.amt = v_sum.
        remtrz.payment = v_sum.
        remtrz.ord = v_name.
        if remtrz.ord = ? then do:
           run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "a_us1.p 853", "1", "", "").
        end.
        remtrz.chg = 7. /* to  outgoing process */
        remtrz.cover = v-transp.
        remtrz.ref = v-ref.
        remtrz.outcode = 3.
        remtrz.fcrc = v_crc.
        remtrz.tcrc = v_crc.
        remtrz.detpay[1] = v_oper + v_oper1 + v_oper2 + v_oper3.
        /*remtrz.detpay[2] = v_oper1.
        remtrz.detpay[3] = v_oper2.
        remtrz.detpay[4] = v_oper3.*/
        remtrz.sbank = ourbank.
        remtrz.valdt1 = g-today.
        remtrz.rwho = g-ofc.
        remtrz.tlx = no.
        remtrz.dracc = v-pnp.
        remtrz.drgl = v-gl.
        remtrz.sacc = v-pnp.
        remtrz.sqn = trim(ourbank) + "." + trim(s-remtrz) + ".." + v-ref.
        remtrz.scbank = trim(ourbank).
        remtrz.source = "O".
        find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
        if not avail sub-cod then do:
            create sub-cod.
            sub-cod.sub = 'rmz'.
            sub-cod.acc = s-remtrz.
            sub-cod.d-cod = 'pdoctng'.
            sub-cod.ccode = v-viddoc.
            sub-cod.rdt = g-today.
        end.
        find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" exclusive-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            sub-cod.acc = s-remtrz.
            sub-cod.sub = "rmz".
            sub-cod.d-cod  = "eknp".
            sub-cod.ccode = "eknp".
        end.
        sub-cod.rdt = g-today.
        sub-cod.rcode = v_code + "," + v_kbe + "," + v_knp.
        find current sub-cod no-lock no-error.
        find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "iso3166" exclusive-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            sub-cod.acc = s-remtrz.
            sub-cod.sub = "rmz".
            sub-cod.d-cod  = "iso3166".
            sub-cod.ccode = v_countr1.
        end.
        sub-cod.rdt = g-today.
        sub-cod.ccode = v_countr1.
        find current sub-cod no-lock no-error.
        if v-priory = 's' then do:
            find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" exclusive-lock no-error.
            if not avail sub-cod then create sub-cod.
            sub-cod.acc = s-remtrz.
            sub-cod.sub = "rmz".
            sub-cod.d-cod  = "urgency".
            sub-cod.ccode = "s".
            find current sub-cod no-lock no-error.
        end.
        run rmzque .
        pause 0.

        run chgsts(input "rmz", remtrz.remtrz, "new").
    end.
end procedure.


procedure view_doc:
    define input parameter s as char.
    if s = "" then update s-remtrz help "Введите номер документа, F2-помощь" with frame f_main.
    else s-remtrz = s.
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if trim(s-remtrz) = "" then undo, return.
    displ s-remtrz v_label1 with frame f_main.
    pause 0.
    find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
    if not available remtrz then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    if remtrz.fcrc = 1 then do:
        message substitute ("Не валютный платеж") view-as alert-box.
        return.
    end.
    /*if remtrz.sts <> "US1" then do:
        message substitute ("Документ не относится переводы по счетам клиентов в  ин.валюте") view-as alert-box.
        return.
    end.*/
    if remtrz.jh1 ne ? and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
        return.
    end.
    if remtrz.rwho ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box.
        return.
    end.
    v_trx = remtrz.jh1.
    v_sum = remtrz.amt.
    v_name = remtrz.ord.
    v-ref = remtrz.ref.
    /*v-transp = remtrz.cover.*/
    v_crc = remtrz.fcrc.
    /*v_oper = detpay[1].
    v_oper1 = detpay[2].
    v_oper2 = detpay[3].
    v_oper3 = detpay[4].*/
    v_oper = substring(remtrz.detpay[1],1,35).
    v_oper1 = substring(remtrz.detpay[1],36,35).
    v_oper2 = substring(remtrz.detpay[1],71,35).
    v_oper3 = substring(remtrz.detpay[1],106,35).
    v-pnp  = remtrz.dracc.
    /*v-transp = remtrz.cover.*/
    v_crck = remtrz.svcrc.
    v-chetk = remtrz.svcaaa.
    v-glk = remtrz.svcgl.
    v_sumk = remtrz.svca.
    v_tar = remtrz.svccgr.
    v-dat2 = remtrz.valdt2.
    v_ben = remtrz.bi.

    if remtrz.svcaaa = "" then v-oplcom = "1 - с кассы". else v-oplcom = "2 - со счета".
    find first tarif2 where tarif2.str5 = trim(string(v_tar))  and tarif2.stat  = "r" no-lock no-error.
    if avail tarif2 then v_tarname = tarif2.pakalp.
    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v_crc = aaa.crc.
    end.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        if v-bin = no then do:
            v-bin5 = trim(substr(cif.jss,1,13)).
            v-reg5 = trim(substr(cif.jss,1,13)).
        end.
        else do:
            v-bin5 = trim(substr(cif.bin,1,13)).
            v-reg5 = trim(substr(cif.jss,1,13)).
        end.
        v-addr = cif.addr[1].
    end.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then do:
        v_code = entry(1,sub-cod.rcode,',').
        v_kbe = entry(2,sub-cod.rcode,',').
        v_knp = entry(3,sub-cod.rcode,',').
    end.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "pdoctng" no-lock no-error.
    if avail sub-cod then v-viddoc = sub-cod.ccode.

    find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" no-lock no-error.
    if not avail sub-cod then v-priory = 'o'.
    else v-priory = sub-cod.ccode.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "iso3166" no-lock no-error.
    if avail sub-cod then v_countr1 = sub-cod.ccode.
    v-ja = yes.
    v_title = " Переводы по счетам клиентов в  ин.валюте ".
/* данные свифта  */

    find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "56" no-lock no-error.
    if  avail swbody then do:
        v_numch1 = swbody.content[1].
        v_swbic = swbody.content[2].
        v_bank = swbody.content[3].
        v_swcity = swbody.content[4].
    end.

    find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "57" no-lock no-error.
    if avail swbody then do:
        v_swcod1 = swbody.type.
        if v_crc = 4 then do:
            v_swbic1 = substring(swbody.content[1],5,50).
            v_bank1 = swbody.content[2].
            v_bank2 = swbody.content[3].
         end.
         else do:
            v_swbic1 = swbody.content[2].
            v_bank1 = swbody.content[3].
            v_swcity1 = swbody.content[4].
        end.
    end.
    find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "59" no-error.
    if avail swbody then do:
        v_chpol = swbody.content[1].
        if swbody.content[2] begins "INN" then do:
            v_innpol = substring(swbody.content[2],4,12).
            v_namepol = swbody.content[3] + swbody.content[4] + swbody.content[5].
        end.
        else v_namepol = swbody.content[2] + swbody.content[3] + swbody.content[4].
    end.

    find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "71" no-lock no-error.
    if  avail swbody then do:
        v_ben = swbody.content[1].
    end.

    displ s-remtrz v_trx v-pnp v_name v-viddoc v-ref v-priory /*v-reg5*/ v-bin5 v_crc v_sum  v_code v_kbe v_knp  v_countr1 v_oper
        v_oper1 v_oper2 v_oper3  v_crck /*v-transp*/ v-oplcom v_ben v_tar v_tarname v_sumk v-chetk v-dat2 with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = " Переводы по счетам клиентов в  ин.валюте ".
        run view_doc ("").
        find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
        if available remtrz then do:
            if not (remtrz.jh1 eq 0 or remtrz.jh1 eq ?) then do:
                message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box.
                undo, return.
            end.
            if remtrz.rwho ne g-ofc then do:
               message substitute ("Документ принадлежит &1. Удалять нельзя.", remtrz.rwho) view-as alert-box.
               undo, return.
            end.
            displ vj-label no-label format "x(35)"  with frame f_main.
            pause 0.
            update v-ja  with frame f_main.
            if v-ja then do:
                for each vccontrs where vccontrs.cif = v-cif no-lock.
                    find first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dnnum = substr(s-remtrz,4,6) no-error.
                    if available vcdocs then do:
                        delete vcdocs.
                        find first vcdocs no-lock no-error.
                        leave.
                    end.
                end.
                find remtrz where remtrz.remtrz = s-remtrz no-error.
                if available remtrz then delete remtrz.
                find first remtrz no-lock no-error.
                for each substs where substs.sub = "rmz" and  substs.acc = s-remtrz exclusive-lock.
                    delete substs.
                end.
                find first substs  no-error.

                find cursts where cursts.sub = "rmz" and  cursts.acc = s-remtrz exclusive-lock no-error.
                if available cursts then delete cursts.
                find first cursts no-lock no-error.

                for each sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz exclusive-lock.
                    delete sub-cod.
                end.
                for each que where que.remtrz = s-remtrz exclusive-lock.
                    delete que.
                end.
            end.
        end.
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide message.
        hide frame f_main.
    end. /* end transaction */
    return.
end procedure.

procedure Create_transaction:
    vj-label = " Выполнить транзакцию?..................".
    v_title = "  Переводы по счетам клиентов в  ин.валюте ".
    run view_doc (s-remtrz).
    find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
    if remtrz.jh1 ne ? and remtrz.jh1 <> 0 then do:
        message "Транзакция уже проведена." view-as alert-box.
        undo, return.
    end.
    if remtrz.rdt ne g-today then do:
        message substitute ("Документ создан &1 .", remtrz.rdt) view-as alert-box.
        undo, return.
    end.
    if remtrz.rwho ne g-ofc then do:
        message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box.
        undo, return.
    end.
    if  v_swbic1 = "" or v_bank1 = "" or v_chpol = "" or v_namepol = "" then do:
        message "Свифт макет заполнен не корректно. Выполните команду 'Редактировать'" view-as alert-box.
        undo, return.
    end.
    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
    if lgr.led = "TDA" or lgr.led = "CDA" then do:
       if v_crc = 4 then v_names = rus-eng1(substring(v_name,1,length(v_name) - (length(v_name) - INDEX( v_name, "/" ) + 1))).
       else v_names = rus-eng2(substring(v_name,1,length(v_name) - (length(v_name) - INDEX( v_name, "/" ) + 1))).
       if v-bin then do:
           if v_innpol <> v-bin5 or trim(v_names) <> trim(v_namepol) then do:
                message "Переводные операции в пользу третьих лиц, ~nпредусмотрены только с текущих счетов
                        ~nнаименов. получат в свифте должно быть ~n" +  trim(v_names) view-as alert-box.
                return.
            end.
       end.
       else do:
           if trim(v_names) <> trim(v_namepol) then do:
                message "Переводные операции в пользу третьих лиц, ~nпредусмотрены только с текущих счетов
                        ~nнаименов. получат в свифте должно быть ~n" +  trim(v_names) view-as alert-box.
                return.
            end.
       end.
       if trim(v_knp) <> "321" then do:
            message "Переводные операции с сбер. счетов, ~nпредусмотрены только с КНП = 321"  view-as alert-box.
            undo, return.
       end.
    end.
    enable but with frame f_main.
    pause 0.
    run ispognt.
    /*----заполнение поля 50-в свифт макете--------*/
    if v_crc = 4 then do:
        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "50" no-error.
        if not avail swbody then do:
           create swbody.
           swbody.rmz = s-remtrz.
           swbody.swfield = "50".
        end.
        swbody.content[1] = "/" + v-pnp.
        swbody.content[2] = rus-eng1(entry(1,v_name,"/")).
        swbody.content[3] = rus-eng1(entry(2,v_name,"/")) + rus-eng1(entry(3,v_name,"/")).
        swbody.content[4] = rus-eng1(entry(4,v-addr)) + "," + rus-eng1(entry(5,v-addr)) + "," + rus-eng1(entry(6,v-addr)).
        swbody.content[5] = rus-eng1(entry(1,v-addr)) + "," + rus-eng1(entry(2,v-addr)) + "," + rus-eng1(entry(3,v-addr)) + "," + entry(7,v-addr).
        lll = 1.
        do while lll <= 6:
            if swbody.content[lll] = ? then swbody.content[lll] = "".
            lll = lll + 1.
        end.
    end.
    else do:
        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "50" no-error.
        if not avail swbody then do:
           create swbody.
           swbody.rmz = s-remtrz.
           swbody.swfield = "50".
        end.
        swbody.content[1] = "/" + v-pnp.
        swbody.content[2] = rus-eng2(entry(1,v_name,"/")).
        swbody.content[3] = rus-eng2(entry(2,v_name,"/")) + rus-eng2(entry(3,v_name,"/")).
        swbody.content[4] = rus-eng2(entry(4,v-addr)) + "," + rus-eng2(entry(5,v-addr)) + "," + rus-eng2(entry(6,v-addr)).
        swbody.content[5] = rus-eng2(entry(1,v-addr)) + "," + rus-eng2(entry(2,v-addr)) + "," + rus-eng2(entry(3,v-addr)) + "," + entry(7,v-addr).
        lll = 1.
        do while lll <= 6:
            if swbody.content[lll] = ? then swbody.content[lll] = "".
            lll = lll + 1.
        end.
    end.
   /*------------------------*/
    disable but with frame f_main.
    if remtrz.jh1 > 0 and substrin(v-oplcom,1,1) = "2" then do:
        v_trx = remtrz.jh1.
        run trxsts (input v_trx, input 6, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return .
        end.
        MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(v_trx) view-as alert-box.
        run chgsts(input "rmz", remtrz.remtrz, "rdy").
        view frame f_main.
        displ v_trx with frame f_main.
    end.
end procedure.

procedure Delete_transaction:
    if s-remtrz eq "" then undo, retry.
    find remtrz where remtrz.remtrz eq s-remtrz.
    if locked remtrz then do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if remtrz.jh1 eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if remtrz.rwho ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box.
        pause 3.
        undo, return.
    end.
    s-jh = remtrz.jh1.
    run rmzcano.
    hide all no-pause.
    view frame f_main.
    pause 0.

end procedure.

procedure Screen_transaction:
    if s-remtrz eq "" then undo, retry.
    find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.

    if remtrz.jh1 eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = remtrz.jh1.
        run vou_word (2, 1, "").
    end. /* transaction */
end procedure.

procedure print_transaction:
    if s-remtrz eq "" then undo, retry.
    find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.

    if remtrz.jh1 eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = remtrz.jh1.
        run printord(s-jh,"").
    end. /* transaction */
end procedure.

procedure print_statement:
    find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
    if avail remtrz then do:
        find aaa where aaa.aaa eq v-pnp no-lock no-error.
        if avail aaa and (substr(trim(string(aaa.gl)),1,4) begins "2205" or substr(trim(string(aaa.gl)),1,4) begins "2206" or
        substr(trim(string(aaa.gl)),1,4) begins "2207") then do:
            {a_usprintapp.i}
        end.
        if avail aaa and ((substr(trim(string(aaa.gl)),1,4) begins "2203") or (substr(trim(string(aaa.gl)),1,4) begins "2204"))
        then do:
            {a_us2printapp.i}
        end.
    end.
end procedure.

procedure part2:
    view frame f_main.
        update v_crck  with frame f_main.
        if cif.type = "P" /* значит физ лицо */  and (v_crc <> 1) then  v_tar = 209.
        if cif.type = "P" /* значит физ лицо */  and v_crc = 4 then  v_tar = 217.
        if cif.type = "B" /* значит юр лицо */  and (v_crc <> 1)  /*and ourbank <> "TXB14"*/ then  v_tar = 205.
        /*if cif.type = "B" and (v_crc <> 1)  and ourbank = "TXB14" then  v_tar = 305.*/
        if cif.type = "B" /* значит юр лицо */  and v_crc = 4 then  v_tar = 218.
        if v_crc = 4 then v_ben = "OUR".
		update v_ben v_tar validate (chkkomcod (v_tar), v-msgerr) with frame f_main.
		if v_tar > 0 then do:
			run comiss2 (output v-komissmin, output v-komissmax).
			find first tarif2 where tarif2.str5 = trim(string(v_tar)) and tarif2.stat = 'r' no-lock no-error.
			if avail tarif2 then do:
                v_tarname = tarif2.pakalp.
                remtrz.svccgl = tarif2.kont.
             /* вычисление суммы комиссии-----------------------------------*/
            /*v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
            run perev ("",input string(v_tar), input v_sum, input v_crc, input v_crck,"", output v-amt, output tproc, output pakal).*/
                v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
                run perev (v-pnp,input v_tar, input v_sum, input v_crc, input v_crck,v-cif, output v-amt, output tproc, output pakal).
            v_sumk = v-amt.
            /*------------------------------------------------------------*/
            end.
			display v_tar v_tarname v_sumk with frame f_main.
		 end.
         update v_sumk  with frame f_main.
         repeat:
             run sel1("Выберите вид оплаты комиссии", "1 - с кассы|2 - со счета").
             if keyfunction(lastkey) = "end-error" then do:
                  hide frame f_main no-pause.
                  return.
             end.
             v-oplcom = return-value.
             if v-oplcom = '' then return.
             displ v-oplcom with frame f_main.
             if substrin(v-oplcom,1,1) = "1" then do:
                v-chetk = "".
                displ v-chetk with frame f_main.
                remtrz.svcaaa = "".
                remtrz.svcgl = 100100.
                leave.
             end.
             else do: /* если комиссия с счета*/
                def var I as int init 0.
                def var aaalist as char init "".
                find first aaa where aaa.cif = v-cif and aaa.crc = v_crck no-lock no-error.
                if not avail aaa then do:
                    MESSAGE "Ошибка, счета для снятия комиссии указанной валюты нет" VIEW-AS ALERT-BOX.
                    undo.
                end.
                FOR EACH aaa where aaa.cif = v-cif and aaa.crc = v_crck no-lock, crc where crc.crc  = v_crck no-lock.
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
                end.
                displ v-chetk with frame f_main.
                pause 0.
                 aaalist = "".

                 find first aaa where aaa.aaa = v-chetk no-lock no-error.
                 if v_sumk > aaa.cbal - aaa.hbal then do:
                    MESSAGE "Ошибка, на выбранном счете недостаточно средств ~nдля списания комиссии" VIEW-AS ALERT-BOX.
                 end.
                 else leave.
                s-aaa = v-chetk.
                run aaa-aas.
                find first aas where aas.aaa = s-aaa no-lock no-error.
                if avail aas then pause.
                find first aas where aas.aaa = s-aaa and aas.sic = 'SP'no-lock no-error.
                if available aas then do: pause. undo,retry. end.
                find cif of aaa no-lock.
                tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
                tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
                pause 0.
                /*BIN*/
            end. /* else do:  если комиссия с счета*/
         end.
       /*displ v_crck v_tar v_tarname v_sumk v-chetk  with frame f_main.*/
        if string(v-dat2)= ? or string(v-dat2)= "" then v-dat2 = g-today.
        update v-dat2 with frame f_main.
        remtrz.svcrc = v_crck.
        remtrz.svcaaa = v-chetk.
        remtrz.svca = v_sumk.
        remtrz.svccgr = v_tar.
        remtrz.valdt2 = v-dat2.
        def var v-stoplist as logic init no.
        pause 0.
    /*Вывод контрактов/ПС*/
    def buffer b-ncrchis for ncrchis.
    find first vcdocs where vcdocs.dnnum = s-remtrz no-lock no-error.
    if not avail vcdocs then do:
        find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
        if avail remtrz then do:
            find last ncrchis where ncrchis.rdt <= remtrz.rdt and ncrchis.crc = 2 no-lock no-error.
            if avail ncrchis then do:
                find last b-ncrchis where b-ncrchis.rdt <= remtrz.rdt and b-ncrchis.crc = remtrz.tcrc no-lock
                no-error.
                if avail b-ncrchis then v-sum-usd = remtrz.amt * b-ncrchis.rate[1] / ncrchis.rate[1].
            end.
            if v_knp = '710' or v_knp = '780'  then do:
                find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
                if avail aaa then do:
                    find first cif where cif.cif = aaa.cif and cif.type = 'b' no-lock no-error.
                    if avail cif then do:
                        if remtrz.fcrc <> 1 then do:
                         run sel ('Сделайте выбор:', ' 1. Выбор контракта/паспорта сделки | 2. Без контракта ').
                         v-select = return-value.
                         if v-select = '1' and remtrz.fcrc <> 1 then do:
                            run vcshowct(cif.cif, remtrz.remtrz, remtrz.rdt,remtrz.tcrc, remtrz.amt, v_knp, output v-prov).
                            if v-prov = no then return.
                         end.
                         if v-select = '' then return.
                        end.
                    end.
                end.
            end.
            if (int(v_knp) >= 810 and int(v_knp) <= 890) /*and v-sum-usd > 50000*/ then do:
                find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
                if avail aaa then do:
                    find first cif where cif.cif = aaa.cif and cif.type = 'b' no-lock no-error.
                    if avail cif then do:
                         if remtrz.fcrc <> 1 then do:
                             run sel ('Сделайте выбор:', ' 1. Выбор контракта/паспорта сделки | 2. Без контракта ').
                             v-select = return-value.
                             if v-select = '1'  then do:
                                run vcshowct(cif.cif, remtrz.remtrz, remtrz.rdt,remtrz.tcrc, remtrz.amt, v_knp, output v-prov).
                                if v-prov = no then return.
                             end.
                             if v-select = '' then return.
                         end.
                    end.
                end.
            end.
            if remtrz.tcrc <> 1 then do:
                v-sum-usd = 0.
                find last ncrchis where ncrchis.rdt <= remtrz.rdt and ncrchis.crc = 2 no-lock no-error.
                if avail ncrchis then do:
                    find last b-ncrchis where b-ncrchis.rdt <= remtrz.rdt and b-ncrchis.crc = remtrz.tcrc no-lock
                    no-error.
                    if avail b-ncrchis then v-sum-usd = remtrz.amt * b-ncrchis.rate[1] / ncrchis.rate[1].
                end.
                v-sts1 = no.
                if substr(v_code,1,1) = "1" and substr(v_code,2,1) = "9" then do:
                    if (v-sum-usd >= 100000) and (v_knp = '510' or v_knp = '520'  or v_knp = '540' or  v_knp matches '8*')
                    then v-sts1 = yes.
                    if v-sum-usd >= 100000 and (v_knp = '722')
                    then v-sts1 = yes.
                    if v-sum-usd >= 500000 and (v_knp = '560')
                    then v-sts1 = yes.
                    if (v_knp = '311' or v_knp = '321') and v_countr1 <> "KZ" then v-sts1 = yes.
                    if (v-sts1 and (remtrz.drgl <> 220520 and remtrz.drgl <> 220420
                        and substr(string(remtrz.drgl),1,4) <> '2203'
                        and substr(string(remtrz.drgl),1,4) <> '2206' and substr(string(remtrz.drgl),1,4) <> '2207'
                        and substr(string(remtrz.drgl),1,4) <> '2215' and substr(string(remtrz.drgl),1,4) <> '2217'
                        and substr(string(remtrz.drgl),1,4) <> '2219')) then do:
                        message "Данный перевод подлежит уведомлению НБРК," skip
                        "необходимо открытие счета клиенту!" view-as alert-box title "Внимание!".
                        return.
                    end.
                end.
            end.
        end.
    end.
    find first vcdocs where vcdocs.dnnum = substr(s-remtrz,4,6) no-lock no-error.
    if avail vcdocs then do:
        find first vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
        if avail vccontrs then do:
           v_swbic = vccontrs.bankcsw.
           v_bank = vccontrs.bankc.
           v_swbic1 = vccontrs.bankbsw.
           v_bank1 = vccontrs.bankb.
           v_chpol = vccontrs.bankbacc.
           v_innpol = vccontrs.inn.
           find first vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
           if avail vcpartner then v_namepol = vcpartner.name.
         end.
     end.
    /* заполнение свифта------------------------------------------------------ */
    run fil_swift("", output v-stoplist).
    hide frame f-swift.
    hide frame f-swift1.
    hide frame f-swift2.
    hide frame f-numch2.
    hide frame f-numch3.

    if v-stoplist = yes then do:
        hide all.
        return.  /*  не заполнен свифт, значит операцию прерываем */
    end.

    find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
    if avail remtrz then do:
        remtrz.bb[1] = v_swbic1.
        remtrz.bb[2] = v_bank1.
        remtrz.bn[1] = v_namepol.
        remtrz.ba = v_chpol.
        remtrz.bi = v_ben.
    end.
    find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
    /*переносим данные в свифт макет*/
    if remtrz.fcrc = 4 then do:

        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "57" no-error.
        if not avail swbody then do:
           create swbody.
           swbody.rmz = s-remtrz.
           swbody.swfield = "57".
        end.
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

        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "59" no-error.
        if not avail swbody then do:
           create swbody.
           swbody.rmz = s-remtrz.
           swbody.swfield = "59".
        end.
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
                swbody.content[5] = rus-eng1(substring(v_namepol,71,35)).
            end.
        end.
    end.
    else do:
        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "56" no-error.
        if not avail swbody then do:
           create swbody.
           swbody.rmz = s-remtrz.
           swbody.swfield = "56".
        end.
        if v_swbic <> "" then swbody.type = "A".
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

        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "57" no-error.
        if not avail swbody then do:
           create swbody.
           swbody.rmz = s-remtrz.
           swbody.swfield = "57".
        end.
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

        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "59" no-error.
        if not avail swbody then do:
           create swbody.
           swbody.rmz = s-remtrz.
           swbody.swfield = "59".
        end.
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
                swbody.content[5] = substring(v_namepol,71,35).
            end.
        end.
    end.
    if v_ben <> "OUR" then do:
        find first crc where crc.crc = v_crc no-lock.

        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "33" no-error.
        if not avail swbody then do:
           create swbody.
           swbody.rmz = s-remtrz.
           swbody.swfield = "33".
        end.
        swbody.type = "B".
        v_sumc = v_sumk.
        v_sumc = round(crc-conv(decimal(v_sumc), v_crck, v_crc) + v_sum ,2).
        swbody.content[1] = caps(crc.code) + " " + trim(string(round(v_sumc,2),">>>>>>>>>>>>>>9.99")).

    end.
    find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "70" no-error.
    if not avail swbody then do:
       create swbody.
       swbody.rmz = s-remtrz.
       swbody.swfield = "70".
    end.
    v_oper5 = v_oper + v_oper1 + v_oper2 + v_oper3.
    if remtrz.fcrc = 4 then do:
        swbody.content[1] = rus-eng1(substring(v_oper5,1,35)).
        swbody.content[2] = rus-eng1(substring(v_oper5,36,35)).
        swbody.content[3] = rus-eng1(substring(v_oper5,71,35)).
        swbody.content[4] = rus-eng1(substring(v_oper5,106,35)).
    end.
    else do:
        swbody.content[1] = rus-eng2(substring(v_oper5,1,35)).
        swbody.content[2] = rus-eng2(substring(v_oper5,36,35)).
        swbody.content[3] = rus-eng2(substring(v_oper5,71,35)).
        swbody.content[4] = rus-eng2(substring(v_oper5,106,35)).

    end.

    if v_ben <> "OUR" then do:
        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "71" and swbody.type  = "A" no-error.
        if not avail swbody then do:
            create swbody.
            swbody.rmz = s-remtrz.
            swbody.swfield = "71".
            swbody.type = "A".
        end.
        swbody.content[1] = v_ben.

        find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "71" and swbody.type  = "F" no-error.
        if not avail swbody then do:
            create swbody.
            swbody.rmz = s-remtrz.
            swbody.swfield = "71".
            swbody.type = "F".
        end.
        v_sumc = v_sumk.
        swbody.content[1] = caps(crc.code) + " " + trim(string(round(crc-conv(decimal(v_sumc), v_crck, v_crc),2),">>>>>>>>>>>>>>9.99")).
    end.

    find first swbody no-lock.
    release swbody .

    hide frame f-swift.
end procedure.

procedure swift_open:
    run tswprns.
end procedure.

