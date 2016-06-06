/* a_kz1.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
         Переводы по счетам клиентов в тенге
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
        07/02/2012 Luiza - изменила label  поля v-nbank на "Получатель"
        08/02/2012 Luiza - добавила удаление очереди при удалении документа.
        05/03/2012 Luiza - увеличила допустимое количество симолов в назначении платежа до 482 символов
        07/03/2012 Luiza - изменила передачу параметров при вызове printord
        29/03/2012 Luiza - добавила вывод сообщения о создании транзакции с номером проводки
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        05.05.2012 damir - добавлены a_kzprintapp.i. Новые форматы заявлений.
        11/05/2012 Luiza - добавила счет 222330
        30/05/2012 Luiza - добавила проверку кнп в пользу третьих лиц с сбер счетов
        05.06.2012 damir - перекомпиляция.
        17/09/2012 Luiza - переход на ИИН
        18/10/2012 Luiza - проверка переводов в пользу третьих лиц
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        19.12.2011 Luiza  - добавила отображение на экране поля detpay[2]
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.Перекомпиляция в связи с изменениями в a_kzprintapp.i.
        02.01.2013 damir - Переход на ИИН/БИН.Перекомпиляция в связи с изменениями в a_kzprintapp.i.
        09/01/2013 Luiza - проверка БИН налоговых органов ТЗ 1634
        04/03/2013 Luiza - ТЗ 1736
        01/04/2013 Luiza - ТЗ 1789 при сравнении ИИН/БИН отправителя и получателя учитывать наличие ключевых слов “/RNN/”.
        10/04/2013 Luiza ТЗ № 1515 Оповещение менеджера о клиенте
        15/05/2013 Luiza - ТЗ № 1826
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
def var v-crc as int  no-undo .  /* Валюта*/
def var v-crck as int  no-undo .  /* Валюта comiss*/
def var v-crcp as int  no-undo .  /* Валюта */
def var v-pnp as char format "x(20)". /* счет клиента*/
def var v-chetk as char format "x(20)". /* счет клиента for comiss*/
def var v-chetp as char format "x(20)". /* счет клиента */
def var v-cif as char format "x(6)". /* cif клиент*/
def var v-cifp as char format "x(6)". /* cif клиент*/
def var v_name as char format "x(30)". /*  клиент*/
def var v_namep as char format "x(30)". /*  клиент*/
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
def var v_oper3 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper5 as char no-undo .  /* Назначение платежа*/
def var v_doc_num as char format "x(30)".
def var v-rnn as log no-undo.
def shared var s-remtrz like remtrz.remtrz.
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
def var v-countr as char.
def var v-viddoc as char.
def var v-ks     as char format 'x(6)'. /* v-ba */

def var  v-rnnp as char.
def var  check-rnnp as char.
def var  v-lbank as char.
def var  v-nbank  as char.
def var  v-date  as date.
def var  v-pol1  as char.
def var  v-pol2  as char.
def var  v-pol3   as char.

def stream v-out.
def var v-file      as char init "Application.htm".
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
s-ourbank = trim(sysc.chval).

def var v-chk1 as char no-undo.
find first bookcod where bookcod.bookcod = 'a_kz1'
                     and bookcod.code    = 'chk'
                     no-lock no-error.
if not avail bookcod or trim(bookcod.name) = "" then do:
    message "В справочнике <bookcod> код <chk> отсутствует список  для определения допустимых счетов ГК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
v-chk1 = bookcod.name.

find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
if not avail sysc then do:
	message " Запись RMCASH отсутствует в файле sysc. " .
	return.
end.
v-cashgl = sysc.inval .


find last sysc where sysc.sysc = 'PRI_PS' no-lock no-error.
if not avail sysc or sysc.chval = '' then do:
	display ' Запись PRI_PS отсутствует в файле sysc !! '.
	pause. undo.
end.

/*def var v-bin as logi init no.*/

define button but label " "  NO-FOCUS.

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

def var v_label as char format "x(20)".
def var v_label1 as char format "x(20)".
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v_label = " ИИН/БИН получателя:". else v_label = " РНН получателя    :".
if v-bin  then v_label1 = " ИИН/БИН           :". else v_label1 = " РНН               :".

   form
        s-remtrz label " Документ          " format "x(10)"    v_trx label   "                     ТРН " format "zzzzzzzzz"           but skip
        v-viddoc label " Вид документа     " validate(can-find(first codfr where codfr.codfr = 'pdoctng' no-lock), "Нет такого кода вида документов! F2-помощь") format "x(2)" help "F2 - помощь" skip
        v-ref    label " Nr.плат.поруч     " format "x(9)" validate (v-ref <> "" or v-ref = "б/н" ,"если платежное поручение без номера наберите 'б/н'! ") help "Если ПлПоруч без номера наберите 'б/н'!Иначе только цифры" skip
        v-priory label " Приоритет         " validate(v-priory = "o" or v-priory = "s", "Hеверный приоритет") format "x(1)" skip
        v-pnp    label " Счет клиента      "  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-pnp  and aaa.crc = 1 and lookup(string(aaa.gl),v-chk1) > 0 no-lock),
                "Неверный счет ГК счета клиента!") skip
        v_name   label " Отправитель       "  format "x(53)" skip
        /*v-reg5   label "      РНН          " format "x(12)" validate(length(v-reg5) = 12 , "Введите 12 цифр РНН !") skip*/
        v_label1 no-label v-bin5  no-label    format "x(12)" validate((chk12_innbin(v-bin5)),'Неправильно введён БИН/ИИН') skip(1)
        v-crc    label " Валюта перевода   " format "9" validate(can-find(first crc where crc.crc = v-crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum    LABEL " Сумма             " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_code  label  " КОД               " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label  " КБе               "  validate(length(v_kbe) = 2, "Hеверное значение КБе") skip
        v_knp   label  " КНП               "  validate(can-find(first codfr where codfr.codfr = "spnpl" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_knp no-lock), "Нет такого кода КНП! F2-помощь") skip
        v-countr label " Страна            " validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v-countr no-lock), "Нет такого кода страны! F2-помощь") format "x(2)" skip
        v_oper  label  " Назнач.платежа    "   format "x(55)" skip
        v_oper1 no-label colon 20 format "x(55)" skip
        v_oper2 no-label colon 20  format "x(55)" skip
        v_oper3 no-label colon 20  format "x(55)" skip(1)
        v_label no-label v-rnnp  no-label   format "x(55)" validate((chk12_innbin(v-rnnp)),'Неправильно введён БИН/ИИН') /*validate(length(v-rnnp) = 12 , "Введите 12 цифр РНН !")*/ skip
        v-chetp label  " Cчет получателя   " format "x(20)" skip
        v-lbank label  " Бик банка получат " format "x(10)" skip
        v-nbank label  " Получатель        " format "x(50)" skip
        v-date  label  " Дата валютирования" skip
        v-transp label " Трансп.           " format "9" validate(v-transp = 2 or v-transp = 1 or v-transp = 4, "Hеверный трансп") help "1)Клиринг 2)Гросс 4)SWIFT" skip
        v-pol1   label " Получатель[1]     " format "x(35)" skip
        v-pol2   label " Получатель[2]     " format "x(35)" skip
        v-pol3   label " Получатель[3]     " format "x(35)" skip
        v-ks     label " КодБК             " format "x(6)" skip(1)

        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 3   TITLE v_title width 80 FRAME f_main.


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

on help of v-crc in frame f_main do:
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
on "END-ERROR" of frame f-country do:
  hide frame f-country no-pause.
end.
on "END-ERROR" of frame f-viddoc do:
  hide frame f-viddoc no-pause.
end.


on help of v-countr in frame f_main do:
    OPEN QUERY  q-country FOR EACH codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc"  no-lock.
    ENABLE ALL WITH FRAME f-country.
    wait-for return of frame f-country
    FOCUS b-country IN FRAME f-country.
    v-countr = codfr.code.
    /*v_country = codfr.name[1]. */
    hide frame f-country.
    displ v-countr  with frame f_main.
end.

/*  help for cif */
on help of v-pnp in frame f_main do:
    on "END-ERROR" of frame f-help do:
    end.
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20  and aaa.crc = 1 and aaa.sta <> "C" and aaa.sta <> "E" no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20  and aaa.crc = 1 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
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
    else DELETE PROCEDURE phand.
end.
on help of v-priory in frame f_main do:
                  run uni_help1("urgency",'*').
end.

{replacebnk.i}

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

m_pid = "P".
if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = "Переводы по счетам клиентов в тенге ".
    find first nmbr no-lock no-error.
    run n-remtrz.   /*получили новый номер для rmz в переменной s-remtrz***/
    find first nmbr no-lock no-error.
    do transaction:
        v_oper = "" .
        displ s-remtrz format "x(10)" with frame f_main.
        v-ja = yes.
        v-pnp = "".
        v_sum = 0.
        v-crc = ?.
        v_oper5 = "".
        v_oper1 = "".
        v_oper2 = "".
        v_oper3 = "".
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = "Переводы по счетам клиентов в тенге ".
    s-remtrz = "".
    run view_doc ("").
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc("").
            find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
            if available remtrz then do:
                /*if remtrz.sts <> "KZ1" then do:
                    message substitute ("Документ не относится к типу переводы по счетам клиентов в тенге  ") view-as alert-box.
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
            end.
            run save_doc.
            run rmzoutg.
            run part2.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ s-remtrz v_label1 v_label with  frame f_main.
/*L_1:*/
    update  v-viddoc  with frame f_main.

    repeat /* on endkey undo, next L_1*/ :
        update v-ref  with frame f_main.
        if v-ref = 'б/н' then leave.
        if integer(v-ref) > 0 then leave.
        message "номер платежного поручения не может содержать текст!" view-as alert-box error.
        /*undo, return.*/
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
        v-crc = aaa.crc.
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
            if aaa.crc <> v-crc then do:
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
                v-bin5 = trim(substr(cif.jss,1,13)).
                v-reg5 = trim(substr(cif.jss,1,13)).
            end.
            else do:
                v-bin5 = trim(substr(cif.bin,1,13)).
                v-reg5 = trim(substr(cif.jss,1,13)).
            end.
            disp /*v-reg5*/ v-bin5 with frame f_main.
            pause 0.
            if v-bin then v_name = trim(v_name) + ' /RNN/' + trim(v-bin5). /* потом поменять на IDN */
            else v_name = trim(v_name) + ' /RNN/' + trim(v-reg5).

    displ v_name v-bin5 /*v-reg5*/ v-crc  v_code /*v_oper vj-label format "x(35)" no-label*/ with frame f_main.
    pause 0.
    /* ИНФОРМАЦИЯ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА */
    if trim(cif.reschar[20]) <> "" or trim(cif.reschar[17]) <> "" then run a_mescif(trim(cif.cif)).

    update v_sum  with frame f_main.
    update v_code v_kbe v_knp with frame f_main.
    if substring(v_kbe,1,1)  = "1" then do:
        v-countr = "KZ".
        displ v-countr with frame f_main.
        pause 0.
        v_oper5 = v_oper + v_oper1 + v_oper2 + v_oper3.
        repeat:
            update v_oper5 go-on("return") with frame detpay.
            if length(v_oper5) > 482 then message 'Назначение платежа превышает 482 символа!'.
            else leave.
        end.
        v_oper = substring(v_oper5,1,55).
        v_oper1 = substring(v_oper5,56,55).
        v_oper2 = substring(v_oper5,111,55).
        v_oper3 = substring(v_oper5,166,55).
        displ  v_oper v_oper1 v_oper2 v_oper3 with frame f_main.
        pause 0.
    end.
    else do:
        update v-countr  with frame f_main.
        find first stoplist where stoplist.code = v-countr no-lock no-error.
        if avail stoplist and stoplist.sts <> 9 then do:
            message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
            return.
        end.
        /*update v_oper v_oper1 v_oper2 v_oper3 with frame f_main.*/
        v_oper5 = trim(v_oper) + trim(v_oper1) + trim(v_oper2) + trim(v_oper3).
        repeat:
            update v_oper5 go-on("return") with frame detpay.
            if length(v_oper5) > 482 then message 'Назначение платежа превышает 482 символа!'.
            else leave.
        end.
        v_oper = substring(v_oper5,1,55).
        v_oper1 = substring(v_oper5,56,55).
        v_oper2 = substring(v_oper5,111,55).
        v_oper3 = substring(v_oper5,166,55).
        displ  v_oper v_oper1 v_oper2 v_oper3 with frame f_main.
        pause 0.
    end.

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
              run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "a_kz1.p 624", "1", "", "").
            end.

            remtrz.chg = 7. /* to  outgoing process */
            remtrz.cover = v-transp.
            remtrz.ref = v-ref.
            remtrz.outcode = 3.
            remtrz.fcrc = v-crc.
            remtrz.tcrc = v-crc.
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
            remtrz.source = "P".
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
                sub-cod.rcode = v_code + "," + v_kbe + "," + v_knp.
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
                sub-cod.ccode = v-countr.
            end.
            sub-cod.rdt = g-today.
            sub-cod.ccode = v-countr.
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
            release sub-cod.
            run rmzque .
            pause 0.
            release que.
            run chgsts(input "rmz", remtrz.remtrz, "new").
            /*remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999')
                    + '    ' + remtrz.remtrz + '-S' + trim(remtrz.sbank) +
                    fill(' ' , 12 - length(trim(remtrz.sbank))) +
                    (trim(remtrz.dracc) +
                    fill(' ' , 10 - length(trim(remtrz.dracc))))
                    + substring(string(g-today),1,2) + substring(string(g-today),4,2)
                    + substring(string(g-today),7,2).*/
            find current remtrz no-lock no-error.
            displ s-remtrz with frame f_main.
            {vccheckp.i}.
            pause 0.
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
    displ s-remtrz v_label1 v_label with frame f_main.
    pause 0.
    find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
    if not available remtrz then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    if remtrz.fcrc <>  1 then do:
        message substitute ("Не тенговый платеж") view-as alert-box.
        return.
    end.
    /*if remtrz.sts <> "KZ1" then do:
        message substitute ("Документ не относится переводы по счетам клиентов в тенге") view-as alert-box.
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
    v-transp = remtrz.cover.
    v-crc = remtrz.fcrc.
    /*v_oper = detpay[1].
    v_oper1 = detpay[2].
    v_oper2 = detpay[3].
    v_oper3 = detpay[4].*/
    v_oper = substring(remtrz.detpay[1],1,55).
    v_oper1 = substring(remtrz.detpay[1],56,55).
    v_oper2 = substring(remtrz.detpay[1],111,55).
    v_oper3 = substring(remtrz.detpay[1],166,55) + " " + trim(remtrz.detpay[2])  + " " + trim(remtrz.detpay[3]).
    v-pnp  = remtrz.dracc.
    /*if v-bin then do:
        if index(remtrz.bn[3], "/IDN/") <= 0 then v-rnnp = substring(remtrz.bn[3],1,12).
        else  = substring(remtrz.bn[3],index(remtrz.bn[3], "/IDN/") + 5,12).
    end.
    else do:
        if index(remtrz.bn[3], "/RNN/") <= 0 then v-rnnp = substring(remtrz.bn[3],1,12).
        else v-rnnp = substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).
    end.*/
    v-rnnp = substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).
    v-chetp = remtrz.ba.
    v-lbank = remtrz.rbank.
    v-nbank  = remtrz.bb[1].
    v-date   = remtrz.valdt2.
    v-transp = remtrz.cover.
    v-pol1 =  remtrz.bn[1].
    v-pol2 =  remtrz.bn[2].
    v-pol3 =  remtrz.bn[3].
    if index(remtrz.ba, "/") <= 0 then v-ks = "" .
    else v-ks = substring(remtrz.ba,index(remtrz.ba, "/") + 1,6).

    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v-crc = aaa.crc.
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
    end.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "pdoctng" no-lock no-error.
    if avail sub-cod then v-viddoc = sub-cod.ccode.

    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then do:
        v_code = entry(1,sub-cod.rcode,',').
        v_kbe = entry(2,sub-cod.rcode,',').
        v_knp = entry(3,sub-cod.rcode,',').
    end.
    find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" no-lock no-error.
    if not avail sub-cod then v-priory = 'o'.
    else v-priory = sub-cod.ccode.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "iso3166" no-lock no-error.
    if avail sub-cod then v-countr = sub-cod.ccode.
    v-ja = yes.
    v_title = " Переводы по счетам клиентов в тенге ".
    displ s-remtrz v_trx v-pnp v_name  v-viddoc v-ref v-priory /*v-reg5*/ v-bin5 v-crc v_sum  v_code v_kbe v_knp  v-countr v_oper
         v_oper1 v_oper2 v_oper3  v-rnnp v-chetp v-lbank v-nbank v-date v-transp v-pol1 v-pol2 v-pol3 v-ks with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = " Переводы по счетам клиентов в тенге ".
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
                find remtrz where remtrz.remtrz = s-remtrz no-error.
                if available remtrz then delete remtrz.
                find first remtrz no-lock no-error.
                for each substs where substs.sub = "rmz" and  substs.acc = s-remtrz exclusive-lock.
                    delete substs.
                end.
                find first substs  no-error.

                find cursts where cursts.sub = "rmz" and  cursts.acc = s-remtrz  exclusive-lock no-error.
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
    v_title = "  Переводы по счетам клиентов в тенге ".
    run view_doc (s-remtrz).
    if v-rnnp = "" or v-chetp = "" then do:
        message "Не заполнены данные получателя" view-as alert-box.
        undo, return.
    end.

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
    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
    if lgr.led = "TDA" or lgr.led = "CDA" then do:
        if index(remtrz.bn[3], "/RNN/") <= 0 then check-rnnp = substring(remtrz.bn[3],1,12).
        else check-rnnp = substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).
        if check-rnnp <> v-bin5 /*or substring(v_name,1,length(v-pol1)) <> v-pol1 */ then do:
            message "Переводные операции в пользу третьих лиц, ~nпредусмотрены только с текущих счетов"  view-as alert-box.
            undo, return.
        end.
        if trim(v_knp) <> "321" then do:
            message "Переводные операции с сбер. счетов, ~nпредусмотрены только с КНП = 321"  view-as alert-box.
            undo, return.
        end.
    end.
    /* проверка БИН налоговых органов */
    if v_kbe = "11" and v_knp begins "9" then do:
        if index(remtrz.bn[3], "/RNN/") <= 0 then check-rnnp = substring(remtrz.bn[3],1,12).
        else check-rnnp = substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).
        find first taxnk where taxnk.bin = check-rnnp no-lock no-error.
        if not available taxnk then do:
            message "БИН отсутствует в справочнике налоговых органов, операция невозможна!" view-as alert-box.
            return.
        end.
        if substring(remtrz.ba,1,20) <> "KZ24070105KSN0000000" then do:
            message "Неверный счет получателя, операция невозможна!" view-as alert-box.
            return.
        end.
         if remtrz.rbank <> "KKMFKZ2A" then do:
            message "Неверный БИК получателя, операция невозможна!" view-as alert-box.
            return.
        end.
    end.
    enable but with frame f_main.
    pause 0.
    run ispognt.
    disable but with frame f_main.
    if remtrz.jh1 > 0 then do:
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
            {a_kzprintapp.i}
        end.
    end.
end procedure.

procedure part2:
    view frame f_main.
    /*if v-bin then do:
        if index(remtrz.bn[3], "/IDN/") <= 0 then v-rnnp = substring(remtrz.bn[3],1,12).
        else v-rnnp = substring(remtrz.bn[3],index(remtrz.bn[3], "/IDN/") + 5,12).
    end.
    else do:
        if index(remtrz.bn[3], "/RNN/") <= 0 then v-rnnp = substring(remtrz.bn[3],1,12).
        else v-rnnp = substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).
    end.*/

    /* проверка БИН налоговых органов */
    if v_kbe = "11" and v_knp begins "9" then do:
        if index(remtrz.bn[3], "/RNN/") <= 0 then check-rnnp = substring(remtrz.bn[3],1,12).
        else check-rnnp = substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).
        find first taxnk where taxnk.bin = check-rnnp no-lock no-error.
        if not available taxnk then do:
            message "БИН отсутствует в справочнике налоговых органов, операция невозможна!" view-as alert-box.
            return.
        end.
        if substring(remtrz.ba,1,20) <> "KZ24070105KSN0000000" then do:
            message "Неверный счет получателя, операция невозможна!" view-as alert-box.
            return.
        end.
         if remtrz.rbank <> "KKMFKZ2A" then do:
            message "Неверный БИК получателя, операция невозможна!" view-as alert-box.
            return.
        end.
    end.
    /*-----------------------------------------------------------------------*/
    if index(remtrz.bn[3], "/RNN/") <= 0 then v-rnnp = substring(remtrz.bn[3],1,12).
    else v-rnnp = substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).
    v-chetp = remtrz.ba.
    v-lbank = remtrz.rbank.
    v-nbank  = remtrz.bb[1].
    v-date   = remtrz.valdt2.
    v-transp = remtrz.cover.
    v-pol1 =  remtrz.bn[1].
    v-pol2 =  remtrz.bn[2].
    v-pol3 =  remtrz.bn[3].
    if index(remtrz.ba, "/") <= 0 then v-ks = "" .
    else v-ks = substring(remtrz.ba,index(remtrz.ba, "/") + 1,6).
    v_oper = substring(remtrz.detpay[1],1,55).
    v_oper1 = substring(remtrz.detpay[1],56,55).
    v_oper2 = substring(remtrz.detpay[1],111,55).
    v_oper3 = substring(remtrz.detpay[1],166,55).

    displ v-rnnp v-chetp v-lbank v-nbank v-date v-transp v-pol1 v-pol2 v-pol3 v-ks v_oper
            v_oper1 v_oper2 v_oper3  vj-label no-label with frame f_main.

    update v-ja with frame f_main.
    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
    if lgr.led = "TDA" or lgr.led = "CDA" then do:
       if v-rnnp <> v-bin5 /*or substring(v_name,1,length(v-pol1)) <> v-pol1*/ then message "Переводные операции в пользу третьих лиц, ~nпредусмотрены только с текущих счетов"  view-as alert-box.
    end.
    if not v-ja and v_u = 1 then do:
        find current remtrz no-lock no-error.
        find remtrz where remtrz.remtrz = s-remtrz no-error.
        if available remtrz then delete remtrz.
        find first remtrz no-lock no-error.

        for each substs where substs.sub = "rmz" and  substs.acc = s-remtrz.
            delete substs.
        end.

        find first que where que.remtrz = s-remtrz no-error.
        if available que then delete que.
        find first que  no-error.

        find cursts where cursts.sub = "rmz" and  cursts.acc = s-remtrz no-error.
        if available cursts then delete cursts.
        find first cursts no-lock no-error.

        for each sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz.
            delete sub-cod.
        end.
    end.
end procedure.

procedure prtppp1:
    run connib.
    run prtppp.
    if connected ('ib') then disconnect 'ib'.
end procedure.

