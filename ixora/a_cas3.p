/* a_cas3.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
         Внутренние платежи со счета клиента (счет ---> счет)
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
        05/03/2012 Luiza  - увеличила допустимое количество симолов в назначении платежа до 482 символов для тенге
        07/03/2012 Luiza  - изменила передачу параметров при вызове printord
        11.03.2012 damir  - добавил печать оперционного ордера, printvouord.p.
        20/03/2012 Luiza  - вызов функции isProductionServer выполняем в a_fimnon.i
        10/04/2012 Luiza  - изменила рассылку сообщений
        13.04.2012 damir  - изменил формат с "yes/no" на "да/нет".
        02/05/2012 evseev - логирование значения aaa.hbal
        05.05.2012 damir  - добавлены a_cas3printapp.i,a_cas3printapp2.i. Новые форматы заявлений.
        05.06.2012 damir  - перекомпиляция.
        25/06/2012 Luiza  - после сообщения о необходимости контроля, рисет форму f_main.
        28/06/2012 Luiza - удалила лишние транзакц блоки
        24/08/2012 Luiza - проверка переводов в пользу третьих лиц
        10/09/2012 Luiza подключила {srvcheck.i}
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        26/11/2012 по СЗ не отправляем на вал контроль переводы между собственными счетами
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.Перекомпиляция в связи с изменениями в a_cas3printapp.i,a_cas3printapp2.i.
        02.01.2013 damir - Переход на ИИН/БИН.Перекомпиляция в связи с изменениями в a_cas3printapp.i.
        10/04/2013 Luiza ТЗ № 1515 Оповещение менеджера о клиенте
        18/07/2013 Luiza - ТЗ 1967 откат по F4
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
/*def new shared var v-num as integer no-undo.*/
def var v-crc as int  no-undo .  /* Валюта*/
def var v-crck as int  no-undo .  /* Валюта comiss*/
def var v-crcp as int  no-undo .  /* Валюта */
def var v-chet as char format "x(20)". /* счет клиента*/
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
def var v_oper5 as char no-undo format "x(200)".  /* Назначение платежа*/
def var v_doc_num as char format "x(30)".
/*def var v-rnn as char no-undo.*/
def new shared var v-joudoc as char format "x(10)" no-undo.
def new shared var v_doc as char format "x(10)" no-undo.
def new shared var s-cif like cif.cif.
def new shared var flg1 as log.
def var ss-jh as int.
def var v-gl as int.
def var v-glp as int.
def var aaatype as char.

def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var v-name as char.
def var v-templ as char.
define var v_codfrn as char init " ".
def var v-ec as char format "x(1)" no-undo.
def var v-ec1 as char format "x(1)" no-undo.
def var v_trx as int no-undo.
def  var vj-label as char no-undo.
define new shared variable s-jh like jh.jh.
define variable v-cash   as logical no-undo.
define variable v-acc   as logical no-undo.
define variable v-sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
def var v-oplcom as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/
def var v-oplcom1 as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/

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
def var v_rnn as char.
def var v_rnnp as char.
def var v-label as char.
def var v-labelp as char.
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
def  var v_lname as char no-undo format "x(20)".
def  var v_mname as char no-undo format "x(20)".
def var v-ref as char.
def var v-viddoc as char.
def var v-crc_val as char no-undo format "xxx".

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
def var v-file      as char init "Application3.htm".
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


define button but label " ".
s-ourbank = trim(sysc.chval).
def var v-bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v-label =  " ИИН/БИН         :". else v-label = " РНН             :".
if v-bin  then v-labelp = " ИИН/БИН         :". else v-labelp = " РНН             :".
{chk12_innbin.i}
   form
        v-joudoc label " Документ              " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"           but skip
        v-viddoc label " Вид документа         " validate(can-find(first codfr where codfr.codfr = 'pdoctng' no-lock), "Нет такого кода вида документов! F2-помощь") format "x(2)" help "F2 - помощь" skip
        v-ref    label " Nr.плат.поруч         " format "x(9)" validate (v-ref <> "" or v-ref = "б/н" ,"если платежное поручение без номера наберите 'б/н'! ") help "Если ПлПоруч без номера наберите 'б/н'!Иначе только цифры"  skip
        v-chet   label " Счет клиента(плательщ)"  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-chet and lookup(string(aaa.gl),"220520,220420,220310,220620,220720,221510,221710,221910") > 0 no-lock),
                "Введите счет клиента открытого на сч ГК 220520,220420,220310,220620,220720,221510,221710,221910") skip
        v_name   label " Клиент                "  format "x(60)" skip
        v-label no-label v_rnn  no-label format "x(12)" colon 24 validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip
        v-crc    label " Валюта сч.(плательщ)  " format "9" validate(can-find(first crc where crc.crc = v-crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum    LABEL " Сумма                 " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v-chetp  label " Счет клиента(получат) "  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-chetp and lookup(string(aaa.gl),"220520,220420,220310,220620,220720,221510,221710,221910") > 0 no-lock),
                "Введите счет клиента открытого на сч ГК 220520,220420,220310,220620,220720,221510,221710,221910") skip
        v_namep  label " Клиент                "  format "x(60)" skip
        v-labelp no-label v_rnnp  no-label format "x(12)" colon 24 validate((chk12_innbin(v_rnnp)),'Неправильно введён БИН/ИИН') skip
        v-crcp   label " Валюта сч.(получат)   " format "9" validate(can-find(first crc where crc.crc = v-crcp and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_code  label  " КОД                   " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label  " КБе                   "  skip
        v_knp   label  " КНП                   "  skip
        v_oper  label  " Назначение платежа    " format "x(50)" skip
        v_oper1 no-label  format "x(75)" skip
        v_oper2 no-label  format "x(75)" skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME f_main.

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
on help of v-joudoc in frame f_main do:
    run a_help-joudoc1 ("CS3").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
on choose of but in frame  f_main do:
    hide all.
    if this-procedure:persistent then delete procedure this-procedure.
    return.
end.
on "END-ERROR" of v-chet in frame f_main do:
  return.
end.

on "END-ERROR" of frame f-help do:
  hide frame f-help no-pause.
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
    DELETE PROCEDURE phand.
end.
on help of v-chetp in frame f_main do:
    on "END-ERROR" of frame f-help do:
    end.
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and aaa.crc = v-crc and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and aaa.crc = v-crc and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-chetp = aaa.aaa.
            hide frame f-help.
            displ v-chetp with frame f_main.
        end.
        else do:
            v-chetp = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            displ v-chetp with frame f_main.
            return.
        end.
    end.
    DELETE PROCEDURE phand.
end.

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = "Внутренние платежи со счета клиента ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    displ v-joudoc format "x(10)" with frame f_main.
    v-ja = yes.
    v-chet = "".
    v-chetp = "".
    v_sum = 0.
    v-crc = ?.
    v_oper = "".
    v_oper1 = "".
    v_oper2 = "".
    run save_doc.
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = "Внутренние платежи со счета клиента ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        vj-label  = " Сохранить изменения документа?...........".
        run view_doc.
        find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if available joudoc then do:
            find joudop where joudop.docnum = v-joudoc no-lock no-error.
            if available joudop then do:
                if joudop.type <> "CS3" then do:
                    message substitute ("Документ не относится к типу внутренние платежи со счета клиента  ") view-as alert-box.
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
    displ v-joudoc with  frame f_main.
    update v-viddoc v-ref v-chet help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v-crc = aaa.crc.
        v-gl = aaa.gl.
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
        find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
        if available lgr then aaatype = lgr.led.
        if cif.type = "P" then v_name  = trim(trim(cif.prefix) + " " + trim(cif.name)). else v_name  = trim(trim(cif.prefix) + " " + trim(cif.sname)).
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
    else do:
        message "Не найден cif клиента. Обратитесь к администратору" view-as alert-box.
        undo, return.
    end.
    displ v_name v-label v_rnn no-label v-crc  v_code v_oper vj-label format "x(35)" no-label with frame f_main.
    pause 0.
    /* ИНФОРМАЦИЯ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА */
    if trim(cif.reschar[20]) <> "" or trim(cif.reschar[17]) <> "" then run a_mescif(trim(cif.cif)).

    find first crc where crc.crc = v-crc no-lock.
    v-crc_val = crc.code.
    update v_sum  with frame f_main.
    repeat:
        update v-chetp help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
        find first aaa where aaa.aaa = v-chetp no-lock no-error.
        if avail aaa then do:
            v-cifp = aaa.cif.
            v-crcp = aaa.crc.
            v-glp = aaa.gl.
        end.
        find first cif where cif.cif = v-cifp no-lock no-error.
        if avail cif then do:
        if cif.type = "P" then v_namep = trim(trim(cif.prefix) + " " + trim(cif.name)). else v_namep = trim(trim(cif.prefix) + " " + trim(cif.sname)).
            if v-bin then v_rnnp = cif.bin. else v_rnnp = cif.jss.
            if cif.type = "P" then v-ec1 = "9".
            else do:
                find last sub-cod where sub-cod.acc = v-cifp and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                if available sub-cod then v-ec1 = sub-cod.ccode.
                else do:
                    message "В справочнике неверно заполнен сектор экономики клиента. Обратитесь к администратору" view-as alert-box.
                    undo, return.
                end.
            end.
            if cif.geo = "021" then v_kbe = "1" + v-ec1.
            else do:
                if   cif.geo = "022" then v_kbe = "2" + v-ec1.
                else do:
                    message "В справочнике неверно заполнен ГЕО-КОД клиента. Обратитесь к администратору" view-as alert-box.
                    undo, return.
                end.
            end.
        end.
        if v-chet <> v-chetp then leave.
        else do:
            message " Счет плательщика равен счету получателя" view-as alert-box.
            undo.
        end.
        if v-crc = v-crcp then leave.
        else message " Валюта счета получателя отличается от валюты счета плательщика" view-as alert-box.
    end.
    if keyfunction(lastkey) = "end-error" then return.
    displ v_namep v-labelp v_rnnp no-label v-crcp  v_kbe with frame f_main.
    v_oper = "Внутренние платежи со счета клиента".
    update v_code v_kbe v_knp /*v_oper v_oper1 v_oper2 v-ja */ with frame f_main.

    /* проверка-------------------------------*/
    if aaatype = "TDA" or aaatype = "CDA" then do:
       if v_rnn <> v_rnnp  then do:
            message "Переводные операции в пользу третьих лиц, ~nпредусмотрены только с текущих счетов"  view-as alert-box.
            undo.
        end.
       if trim(v_knp) <> "321" then do:
            message "Переводные операции с сбер. счетов, ~nпредусмотрены только с КНП = 321"  view-as alert-box.
            undo.
       end.
    end.

    if v-crc <> 1 and substring(v_code,1,1) = "1" and substring(v_kbe,1,1) = "1" and (substring(string(v-gl),1,4) = "2203" or substring(string(v-gl),1,4) = "2204") and (substring(string(v-glp),1,4) = "2203" or substring(string(v-glp),1,4) = "2204") then do:
      message " Платежи в ин валюте между резидентами запрещены" view-as alert-box.
      undo.
    end.
    /*----------------------------------------------------------------------------------------*/
    v_oper5 = v_oper + v_oper1 + v_oper2.
    repeat:
        if v-crc = 1 then do:
            update v_oper5 go-on("return") with frame detpay.
            if length(v_oper5) > 482 then message 'Назначение платежа превышает 482 символа!'.
            else leave.
        end.
        else do:
            update v_oper5 go-on("return") with frame detpay.
            if length(v_oper5) > 140 then message 'Назначение платежа превышает 140 символов!'.
            else leave.
        end.
    end.
    v_oper = substring(v_oper5,1,50).
    v_oper1 = substring(v_oper5,51,75).
    v_oper2 = substring(v_oper5,126,75).
    displ  v_oper v_oper1 v_oper2 with frame f_main.
    update v-ja with frame f_main.
      if v-ja then do:
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
        joudoc.cracctype = "2".
        joudoc.crcur = v-crcp.
        joudoc.cracc = v-chetp.
        joudoc.remark[1] = v_oper.
        joudoc.remark[2] = v_oper1.
        joudoc.rescha[3] = v_oper2.
        joudoc.chk = 0.
        joudoc.num = v-ref.
        joudoc.info = v_name.
        run chgsts("JOU", v-joudoc, "new").
        find current joudoc no-lock no-error.
        joudop.who = g-ofc.
        joudop.whn = g-today.
        joudop.tim = time.
        joudop.type = "CS3".
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

        find first sub-cod where sub-cod.sub = 'jou' and sub-cod.acc = v-joudoc and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
        if not avail sub-cod then do:
            create sub-cod.
            sub-cod.sub = 'jou'.
            sub-cod.acc = v-joudoc.
            sub-cod.d-cod = 'pdoctng'.
        end.
        sub-cod.ccode = v-viddoc.
        sub-cod.rdt = g-today.
        displ v-joudoc with frame f_main.

        if v-crc <> 1 or substring(v_code,1,1) = "2" or substring(v_kbe,1,1) = "2" and v-cif <> v-cifp then do:
            message "Платеж должен пройти контроль Департаментом Валютного контроля 9.11 !"  view-as alert-box.
            run mail ("DVKG@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
                "Добрый день!\n\n Необходимо отконтролировать внутренний перевод со счета клиента \n Сумма: " + string(v_sum) +
                "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
                string(time,"HH:MM"), "1", "","" ).
                hide all.
                view frame f_main.
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
    if trim(v-joudoc) = "" then undo, return.
    displ v-joudoc with frame f_main.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        if joudop.type <> "CS3" then do:
            message substitute ("Документ не относится внутренние платежи со счета клиента ") view-as alert-box.
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
    v-chet = joudoc.dracc.
    v-chetp = joudoc.cracc.
    v_sum = joudoc.dramt.
    v-crc = joudoc.drcur.
    v-crcp = joudoc.crcur.
    v_oper = joudoc.remark[1].
    v_oper1 = joudoc.remark[2].
    v_oper2 = joudoc.rescha[3].
    v-ref = joudoc.num.
    find first crc where crc.crc = v-crc no-lock.
    v-crc_val = crc.code.

    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v-gl = aaa.gl.
    end.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        if cif.type = "P" then v_name  = trim(trim(cif.prefix) + " " + trim(cif.name)). else v_name  = trim(trim(cif.prefix) + " " + trim(cif.sname)).
        if v-bin then v_rnn = cif.bin. else v_rnn = cif.jss.
    end.
    find first aaa where aaa.aaa = v-chetp no-lock no-error.
    if avail aaa then do:
        v-cifp = aaa.cif.
        v-crcp = aaa.crc.
        v-glp = aaa.gl.
    end.
    find first cif where cif.cif = v-cifp no-lock no-error.
    if avail cif then do:
        if cif.type = "P" then v_namep  = trim(trim(cif.prefix) + " " + trim(cif.name)). else v_namep  = trim(trim(cif.prefix) + " " + trim(cif.sname)).
        if v-bin then v_rnnp = cif.bin. else v_rnnp = cif.jss.
    end.
    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then do:
        v_code = entry(1,sub-cod.rcode,',').
        v_kbe = entry(2,sub-cod.rcode,',').
        v_knp = entry(3,sub-cod.rcode,',').
    end.
    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "pdoctng" no-lock no-error.
    if avail sub-cod then do:
        v-viddoc = entry(1,sub-cod.ccode,',').
    end.

    v-ja = yes.
    v_title = " Внутренние платежи со счета клиента ".
    displ v-joudoc v-viddoc v-ref v_trx v-chet v_name v-label v_rnn no-label v-crc v_sum v-chetp v_namep v-labelp v_rnnp no-label v-crcp  v_code v_kbe v_knp  v_oper v_oper1 v_oper2 with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = " Внутренние платежи со счета клиента ".
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
    v_title = "  Внутренние платежи со счета клиента ".
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
    if joudoc.rescha[2] = "" and (v-crc <> 1  or substring(v_code,1,1) = "2" or substring(v_kbe,1,1) = "2")  and v-cif <> v-cifp  then do:
        message "Документ подлежит валютному контролю в п.м. 9.11 " view-as alert-box.
        undo, return.
    end.

    /*комплаенс*/
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
    displ vj-label format "x(35)" no-label with frame f_main.
    pause 0.
    update v-ja no-label with frame f_main.
    if not v-ja  then do:
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide frame f_main.
        return.
    end.

    /* для суммы пополнения        */
    s-jh = 0.
    v-tmpl = "JOU0022".
 /* формир v-param для trxgen.p */
    v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-chet + vdel + v-chetp + vdel
                + (v_oper + v_oper1 + v_oper2) + vdel + v_knp.
    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message rdes.
        pause.
        undo, return.
    end.
    run chgsts(m_sub, v-joudoc, "trx").
    pause 1 no-message.
    find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
    joudoc.jh = s-jh.
    find current joudoc no-lock no-error.

    if v-noord = yes then run printvouord(2).
     /* заблокируем нужную сумму до контроля */

     create aas.

     find last aas_hist where aas_hist.aaa = v-chetp no-lock no-error.
     if available aas_hist then aas.ln = aas_hist.ln + 1. else aas.ln = 1.

     aas.sic = 'HB'.
     aas.chkdt = g-today.
     aas.chkno = 0.
     aas.chkamt  = v_sum.
     aas.payee = 'Внутренний платеж со счета клиента |' + TRIM(STRING(s-jh, "zzzzzzzzzz9")) .
     aas.aaa = v-chetp .
     aas.who = g-ofc.
     aas.whn = g-today.
     aas.regdt = g-today.
     aas.tim = time.

     if aas.sic = 'HB' then do:
         find first aaa where aaa.aaa = v-chetp exclusive-lock.
         if avail aaa then do:
            run savelog("aaahbal", "a_cas3 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
            aaa.hbal = aaa.hbal + aas.chkamt.
         end.
     end.

     FIND FIRST ofc WHERE ofc.ofc = g-ofc NO-LOCK no-error.
     if avail ofc then do:
       aas.point = ofc.regno / 1000 - 0.5.
       aas.depart = ofc.regno MODULO 1000.
     end.

     CREATE aas_hist.

     find first aaa where aaa.aaa = v-chetp no-lock no-error.
     IF AVAILABLE aaa THEN DO:
        FIND FIRST cif WHERE cif.cif= v-cifp USE-INDEX cif NO-LOCK NO-ERROR.
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
    v_trx = s-jh.
    display v_trx with frame f_main.
    pause 0.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) + "~nДанный документ подлежит контролю в п.м. 2.4.1.3" view-as alert-box.
    for each sendod no-lock.
        run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
        "Добрый день!\n\n Необходимо отконтролировать внутренний платеж \n Сумма: " + string(v_sum) +
        "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
        string(time,"HH:MM"), "1", "","" ).
    end.
    hide all.
    view frame f_main.
    pause 0.
    run chgsts("jou", v-joudoc, "bac").
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
        undo, return.
    end.

    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box.
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
    find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
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
            /* ------------------------------------------------------------------*/
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
    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    run jou-aasdel2 (joudoc.cracc, joudoc.cramt, ss-jh).
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
    else do:
        run printord(s-jh,"").
    end.
end procedure.

procedure print_statement:
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if avail joudoc then do:
        find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
        if avail aaa and (substr(trim(string(aaa.gl)),1,4) begins "2205" or substr(trim(string(aaa.gl)),1,4) begins "2206" or
        substr(trim(string(aaa.gl)),1,4) begins "2207") then do:
            if v-crc = 1 then do:
                {a_cas3printapp.i}
            end.
            else do:
                {a_cas3printapp2.i}
            end.
        end.
    end.
end procedure.

procedure prtppp1:
    define var o_err  as log init false. /* Customer's Account  */

    def var in_cif like cif.cif                   no-undo.
    def var in_acc like aaa.aaa                   no-undo.
    def var in_jh   as char init ""               no-undo.
    def var in_ln   as char init ""               no-undo.
    def var crccode like crc.code                 no-undo.
    def var p_mem   as char init "" format "x"    no-undo.  /* " Мемориальный ордер" Put mem.ord.                */
    def var p_memf  as char init "" format "x"    no-undo.  /* " Мемориальный ордер" Put mem.ord.                */
    def var p_pld   as char init "" format "x"    no-undo.  /*   Дебетовое платежное поручениеPut plat.por. deb. */
    def var p_uvd   as char init "" format "x"    no-undo.  /*   Кредитовое уведомление Put plat.por. deb.       */
    def var v-ok    as log                        no-undo.
    def var in_command as char init "prit"        no-undo.
    def var in_destination as char init "dok.img" no-undo.
    def var partkom as char                       no-undo.
    def var vans    as log init true              no-undo.
    def var m-rtn   as log                        no-undo.
    def var s-rem   as char                       no-undo.
    def var v-cifname as char format "x(40)"      no-undo.

    find first jl where jl.acc = joudoc.cracc and jl.jh = joudoc.jh no-lock no-error.
    if not avail jl then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.
    in_acc = jl.acc.
    in_jh  = string(jl.jh).
    in_ln =  string(jl.ln).
    p_mem="".
    p_memf="".
    p_pld="1".


    unix silent rm -f value("dok.img").

    display " Ждите, производится формирование документа по операции " in_jh with frame c3 no-label . pause 0.
    run vipdokln(in_jh,in_ln,in_acc,p_mem,p_memf,p_pld,p_uvd,output o_err).
    if opsys <> "UNIX" then return "0".
    if in_command <> ? then do:
        partkom = in_command + " " + in_destination.
    end.
    else do:
        find first ofc where ofc.ofc = userid("bank") no-lock no-error.
        if available ofc and ofc.expr[3] <> ""
        then do:
             partkom = ofc.expr[3] + " " + in_destination.
        end.
        else return "0".
    end.
    unix silent cptwin value("dok.img") winword.
    pause 0.
    hide frame c3.
    /*view frame f_main.*/
end procedure.
