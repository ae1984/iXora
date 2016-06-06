/* sload.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Загрузка платежей для интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM IB
 * AUTHOR
        09/10/09 id00004
 * CHANGES
        22.07.2010 id00004 добавил корректное завершение процессов
        06.10.2010 id00004 добавил рассылку писем от пользователей в "разрезе" обслуживающих менеджеров
        15.02.2011 id00004 добавил транслитерацию писем с названиями на русском языке
        16.03.2011 id00004 добавил обработку ЗА счет отправителя, получателя для валютных платежей
        14.06.2011 id00004 для типа сообщения Cancellation(отзыв) не ставим статус на обработке, сразу исполнен или отвергнут.
        07.10.2011 id00004 добавил srvcheck.i
        08.11.2011 id00004 добавил обработку БИК для RUR
        06.06.2012 evseev - отструктурировал код
        17.07.2012 evseev - ТЗ-1349
        01.08.2012 evseev - изменил логирование
        10.09.2012 evseev - добавил CODEPAGE-CONVERT
        13.09.2012 evseev - перекомпиляция
        17.09.2012 evseev - логирование
        19.09.2012 evseev recompile
        11.10.2012 Lyubov - ТЗ 1528, для файлов по зачислению remtrz.rsub = arp
        25.12.2012 Lyubov - исправлена передача парметров в snx1, два раза передавалось название банка-бенефициара
        02.01.2013 damir - Переход на ИИН/БИН.
        22.01.2013 evseev - ТЗ-1659
        13.02.2013 zhasulan - ТЗ 1694, добавил функцию replace2Space
        22.08.2013 evseev  tz-1868
        01.11.2013 evseev  tz926
        08.11.2013 zhassulan - ТЗ 1417, новые поля ИНН и КПП для рубл.платежей
        14.11.2013 zhassulan - ТЗ 1313, добавлено: тип комиссии SHA, код комиссии 304
*/
/*--------------------------------------------------------------------------------------------------------
  НЕ МЕНЯТЬ ПРОГРАММЫ БЕЗ ЧЕТКОГО ПОНИМАНИЯ ПРОЦЕССА Т.К ТЕГИ XML ВЗАИМОСВЯЗАНЫ ДЛЯ РАЗНЫХ ТИПОВ ПЛАТЕЖЕЙ
  ИЗМЕНЕНИЕ ОБРАБОТКИ ДЛЯ ОДНОГО ТИПА ПЛАТЕЖА МОЖЕТ ПОВЛИЯТЬ ИЛИ ИСКАЗИТЬ РЕКВИЗИТЫ ПЛАТЕЖА ДРУГОГО ТИПА
---------------------------------------------------------------------------------------------------------*/

{global.i}
{srvcheck.i}
def var v-payment-order  as char.
{xml.i}

def var m_id               as char.
def var m_BANK_ID          as char.
def var m_NUM_DOC          as char.
def var m_DATE_DOC         as char.
def var m_PAYER_NAME       as char.
def var m_PAYER_RNN        as char.
def var m_PAYER_ACCOUNT    as char.
def var m_PAYER_CODE       as char.
def var m_PAYER_BANK_BIC   as char.
def var m_PAYER_BANK_NAME  as char.
def var m_PRIORITY         as char.
def var m_THEME            as char.
def var m_MESSAGE_BODY     as char.
def var m_CLIENT_COMMENTS  as char.
def var m_STATUS           as char.
def var m_TOTAL_COUNT      as char.
def var m_FILE_NAME        as char extent 15.
def var m_FILE_SIZE        as char extent 15.
def var m_DATA             as longchar extent 15.
def var ii                 as integer.
def var i-inx              as integer.
def var i-stn              as integer.
def var jj                 as integer.
define buffer b-netbank for netbank.

ii = 0.
{msg_xml.i}

def var v-payment-kz       as char.
def var v-payment-ps       as char.
def var v-ptype            as integer.
def var v-socialpayment-ps as char.
def var v-taxpayment-ps    as char.
def var v-CancelVAL        as char.
def var v-CancelDocId      as char.
def var v-payment-cr       as char.
def var v-payment-ex       as char.
def var v-rnn              as char.
def var v-state            as char.
def var v-aaa              as char.
def var v-rspnt            as char.
def var v-amount           as char.
def var v-rcptbik          as char.
def var v-rcptbank         as char.
def var v-rcptname         as char.
def var v-rcptdetails      as char.
def var v-knp              as char.
def var v-priority         as char.
def var v-numdoc           as char.
def var v-rsptrnn          as char.
def var v-valdate          as date.
def var v-intbic           as char.
def var v-comacc           as char.
def var v-intname          as char.
def var v-kbe              as char.
def var v-datedoc          as date.
def var v-purchacc         as char.
def var v-saleacc          as char.
def var v-comissacc        as char.
def var v-clientrnn        as char.
def var v-ispurchase       as char.
def var v-purchaseamt      as char.
def var v-comision-type    as char .
def var v-rubik            as char .
def var v-intent           as char .

def var v-RCPT_BANK_BIC_TYPE as char .
def var v-INTERMED_BANK_BIC_TYPE as char .

def var v-rusInn           as char.
def var v-rusKpp           as char.

def var v-saleamt          as char.
def var v-purposetype      as char.
def var v-payerbankBic     as char.
def var v-clientbankBic    as char.
def var v-pensia           as longchar.
def var rdes               as char.
def var v-sts              as char.
def var v-des              as char.
def var v-urgency          as char.
def var v-payerischarge    as char.
def var l-doctax           as logical.
def var v-reterr           as integer.
def  var lbnstr            as char .
def var v-ba               as char .
def var v-pri              as char .
def var v-kbk              as char .
def var v-cifname          as char .
def var v-ref              as integer.
def var rsts               as integer.
def var v-body             as char.
def var v-file             as char.
def var v-chtxt            as char .
def var v-chtxt1           as char .


def var v-mail             as char .
def var v-errorr           as integer .
def var v-payissocial      as char .
def new shared var sv_aaa  as char.
def new shared var sv_rnn  as char.
def new shared var sv_bic  as char.

function replace2Space returns char (input inText as char) forward.

def var v-terminate as logi no-undo.
v-terminate = no.

def buffer b-aaa for aaa.
def buffer b-txb for txb.

define var ptpsession      as handle.
define var consumerH       as handle.
define var replyMessage    as handle.
define var sm              as decimal.
define var sm1             as decimal.
define new shared var d_gtday as date.
d_gtday = g-today .
rsts = 0.

DEFINE NEW GLOBAL SHARED VAR JMS-MAXIMUM-MESSAGES AS INT INIT 500.
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setBrokerURL in ptpsession ("tcp://172.16.3.5:2507").
else run setBrokerURL in ptpsession ("tcp://172.16.2.77:2507").

run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').
run beginSession in ptpsession.
run createXMLMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (THIS-PROCEDURE, "requestHandler", output consumerH).
run receiveFromQueue in ptpsession ("SYNC2ABS", ?, consumerH).
run startReceiveMessages in ptpsession.
run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).
message "Процесс корректно завершен".
run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deletesession in ptpsession no-error.


procedure requestHandler:
    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.
    def var pNames as char no-undo.
    def var pID    as char no-undo.
    def var msgText as char no-undo.
    message "193. **********************************".
    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end. else do:
        pNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).
        hide message no-pause.

        DEFINE VAR memptrDoc AS MEMPTR.
        DEFINE VAR hdoc AS HANDLE.
        DEFINE VAR hRoot AS HANDLE.
        DEFINE VAR xmlText AS CHAR.
        DEFINE VAR indx AS INT.

        CREATE X-DOCUMENT hdoc.
        CREATE X-NODEREF hRoot.

        SET-SIZE(memptrDoc) = 2097152. /* больше этого объема сообщение прийти не может ограничение на стороне java-кода*/
        indx = 1.

        DO WHILE NOT DYNAMIC-FUNCTION('endOfStream' IN requestH):
           xmlText = DYNAMIC-FUNCTION('getTextSegment':U IN requestH).
           xmlText = trim(replace(xmlText,"UTF-8","windows-1251")).
           PUT-STRING(memptrDoc, indx) = xmlText.
           indx = indx + LENGTH(xmlText).
        END.

        RUN deleteMessage IN requestH.

        def var v-payment-details as char.
        def var v-kzrcptname as char.

        v-payment-details = "".
        v-kzrcptname = "".
        v-payment-details = substr(xmlText, INDEX(xmlText, '<PAYMENT_DETAILS>') + 17, INDEX(xmlText, '</PAYMENT_DETAILS>')  - (INDEX(xmlText, '<PAYMENT_DETAILS>') + 17) ) no-error.
        v-payment-details = replace2Space(v-payment-details).
        v-kzrcptname = substr(xmlText, INDEX(xmlText, '<RCPT_NAME>') + 11, INDEX(xmlText, '</RCPT_NAME>')  - (INDEX(xmlText, '<RCPT_NAME>') + 11) ) no-error.
        hdoc:LOAD("memptr", memptrDoc, FALSE).
        hdoc:GET-DOCUMENT-ELEMENT(hRoot).
        v-payissocial = "" .
        v-state = "".
        v-payment-kz = "0".
        v-payment-ps = "0".
        v-payment-cr = "0".
        v-payment-ex = "0".
        v-socialpayment-ps = "0".
        v-taxpayment-ps = "0".
        v-payment-order = "0".
        /*
            <CURRENCY_EXCHANGE>
                <ID exclude="yes">125850</ID>
                <BANK_ID exclude="yes">1</BANK_ID>
                <REJECT_REASON/>
                <NUM_DOC>10</NUM_DOC>
                <DATE_DOC>13.07.2012</DATE_DOC>
                <CLIENT_NAME>ТОО ПАЦИФИКА</CLIENT_NAME>
                <CLIENT_IDN>600400593966</CLIENT_IDN>
                <CLIENT_PHONE>2777968</CLIENT_PHONE>
                <CLIENT_ADDRESS>Казахстан,Алматы,Аль-Фараби,13/1 Нурлы-Тау,зд.3В,050059</CLIENT_ADDRESS>
                <IS_RESIDENT>0</IS_RESIDENT>
                <PRIORITY>1</PRIORITY>
                <SALE_ACCOUNT>KZ19470172215A506416</SALE_ACCOUNT>
                <SALE_AMOUNT></SALE_AMOUNT>
                <PURCHASE_ACCOUNT>KZ07470272203A019000</PURCHASE_ACCOUNT>
                <PURCHASE_AMOUNT>111.00</PURCHASE_AMOUNT>
                <PURCHASE_PURPOSE_TYPE/>
                <PURCHASE_PURPOSE/>
                <CURRENCY>USD</CURRENCY>
                <COMMISSION_ACCOUNT>KZ19470172215A506416</COMMISSION_ACCOUNT>
                <IS_PURCHASE>1</IS_PURCHASE>
                <CLIENT_BIC>FOBAKZKA</CLIENT_BIC>
                <INTENT>212421</INTENT>
            </CURRENCY_EXCHANGE>
        */
        run get-node (hdoc,
            "ID", /*1*/
            "CANCEL_CURRENCY", /*2*/
            "CANCEL_DOC_ID" , /*3*/
            "IS_SOCIAL", /*4*/
            "PAYMENT", /*5*/
            "PS_PAYMENT", /*6*/
            "CURRENCY_PAYMENT", /*7*/
            "CURRENCY_EXCHANGE", /*8*/
            "PAYER_IDN", /*9*/
            "CLIENT_IDN", /*10*/
            "PAYER_ACCOUNT", /*11*/
            "RCPT_ACCOUNT", /*12*/
            "AMOUNT", /*13*/
            "RCPT_BANK_BIC", /*14*/
            "RCPT_BANK_NAME", /*15*/
            "RCPT_NAME", /*16*/
            "DESTINATION_CODE", /*17*/
            "PAYMENT_DETAILS", /*18*/
            "PRIORITY", /*19*/
            "NUM_DOC", /*20*/
            "RCPT_IDN", /*21*/
            "VALUE_DATE", /*22*/
            "INTERMED_BANK_BIC", /*23*/
            "INTERMED_BANK_NAME", /*24*/
            "RCPT_CODE", /*25*/
            "COMMISSION_ACCOUNT", /*26*/
            "DATE_DOC", /*27*/
            "PURCHASE_ACCOUNT", /*28*/
            "SALE_ACCOUNT", /*29*/
            "IS_PURCHASE", /*30*/
            "KBK", /*31*/
            "PURCHASE_PURPOSE", /*32*/
            "PURCHASE_AMOUNT", /*33*/
            "SALE_AMOUNT", /*34*/
            "PAYER_BANK_BIC", /*35*/
            "CLIENT_BIC", /*36*/
            "IS_CHARGE", /*37*/
            "ATTACHMENT", /*38*/
            "COMMISSION_TYPE", /*39*/
            "RUBIC_ACCOUNT", /*40*/
            "INTENT", /*41*/
            "RCPT_BANK_BIC_TYPE", /*42*/
            "INTERMED_BANK_BIC_TYPE", /*43*/
            "RUS_INN", /*44*/
            "RUS_KPP", /*45*/
            output v-state,                /*ID             */ /*1*/
            output v-CancelVAL,        /*CANCEL_CURRENCY    */ /*2*/
            output v-CancelDocId,      /*CANCEL_DOC_ID      */ /*3*/
            output v-payissocial,      /*IS_SOCIAL          */ /*4*/
            output v-payment-kz,       /*PAYMENT            */ /*5*/
            output v-payment-ps,       /*PS_PAYMENT         */ /*6*/
            output v-payment-cr,       /*CURRENCY_PAYMENT   */ /*7*/
            output v-payment-ex,       /*CURRENCY_EXCHANGE  */ /*8*/
            output v-rnn,              /*PAYER_IDN          */ /*9*/
            output v-clientrnn,        /*CLIENT_IDN         */ /*10*/
            output v-aaa,              /*PAYER_ACCOUNT      */ /*11*/
            output v-rspnt,            /*RCPT_ACCOUNT       */ /*12*/
            output v-amount,           /*AMOUNT             */ /*13*/
            output v-rcptbik,          /*RCPT_BANK_BIC      */ /*14*/
            output v-rcptbank,         /*RCPT_BANK_NAME     */ /*15*/
            output v-rcptname,         /*RCPT_NAME          */ /*16*/
            output v-knp,              /*DESTINATION_CODE   */ /*17*/
            output v-rcptdetails,      /*PAYMENT_DETAILS    */ /*18*/
            output v-priority,         /*PRIORITY           */ /*19*/
            output v-numdoc,           /*NUM_DOC            */ /*20*/
            output v-rsptrnn,          /*RCPT_IDN           */ /*21*/
            output v-valdate,          /*VALUE_DATE         */ /*22*/
            output v-intbic,           /*INTERMED_BANK_BIC  */ /*23*/
            output v-intname,          /*INTERMED_BANK_NAME */ /*24*/
            output v-kbe,              /*RCPT_CODE          */ /*25*/
            output v-comacc,           /*COMMISSION_ACCOUNT */ /*26*/
            output v-datedoc,          /*DATE_DOC           */ /*27*/
            output v-purchacc,         /*PURCHASE_ACCOUNT   */ /*28*/
            output v-saleacc,          /*SALE_ACCOUNT       */ /*29*/
            output v-ispurchase,       /*IS_PURCHASE        */ /*30*/
            output v-kbk,              /*KBK                */ /*31*/
            output v-purposetype,      /*PURCHASE_PURPOSE_TYPE*/ /*32*/
            output v-purchaseamt,      /*PURCHASE_AMOUNT    */ /*33*/
            output v-saleamt,          /*SALE_AMOUNT        */ /*34*/
            output v-payerbankBic,     /*PAYER_BANK_BIC     */ /*35*/
            output v-clientbankBic,    /*CLIENT_BIC         */ /*36*/
            output v-payerischarge,    /*IS_CHARGE          */ /*37*/
            output v-pensia,           /*ATTACHMENT         */ /*38*/
            output v-comision-type,    /*COMMISSION_TYPE    */ /*39*/
            output v-rubik,            /*RUBIC_ACCOUNT      */ /*40*/
            output v-intent,           /* INTENT */ /*41*/
            output v-RCPT_BANK_BIC_TYPE,                 /*RCPT_BANK_BIC_TYPE*/ /*42*/
            output v-INTERMED_BANK_BIC_TYPE,   /*INTERMED_BANK_BIC_TYPE*/ /*43*/
            output v-rusInn,           /*RUS_INN*/ /*44*/
            output v-rusKpp            /*RUS_KPP*/ /*45*/    ) no-error.

        v-state         = CODEPAGE-CONVERT(v-state        ,"kz-1048","utf-8").
        v-CancelVAL     = CODEPAGE-CONVERT(v-CancelVAL    ,"kz-1048","utf-8").
        v-CancelDocId   = CODEPAGE-CONVERT(v-CancelDocId  ,"kz-1048","utf-8").
        v-payissocial   = CODEPAGE-CONVERT(v-payissocial  ,"kz-1048","utf-8").
        v-payment-kz    = CODEPAGE-CONVERT(v-payment-kz   ,"kz-1048","utf-8").
        v-payment-ps    = CODEPAGE-CONVERT(v-payment-ps   ,"kz-1048","utf-8").
        v-payment-cr    = CODEPAGE-CONVERT(v-payment-cr   ,"kz-1048","utf-8").
        v-payment-ex    = CODEPAGE-CONVERT(v-payment-ex   ,"kz-1048","utf-8").
        v-rnn           = CODEPAGE-CONVERT(v-rnn          ,"kz-1048","utf-8").
        v-clientrnn     = CODEPAGE-CONVERT(v-clientrnn    ,"kz-1048","utf-8").
        v-aaa           = CODEPAGE-CONVERT(v-aaa          ,"kz-1048","utf-8").
        v-rspnt         = CODEPAGE-CONVERT(v-rspnt        ,"kz-1048","utf-8").
        v-amount        = CODEPAGE-CONVERT(v-amount       ,"kz-1048","utf-8").
        v-rcptbik       = CODEPAGE-CONVERT(v-rcptbik      ,"kz-1048","utf-8").
        v-rcptbank      = CODEPAGE-CONVERT(v-rcptbank     ,"kz-1048","utf-8").
        v-rcptname      = CODEPAGE-CONVERT(v-rcptname     ,"kz-1048","utf-8").
        v-knp           = CODEPAGE-CONVERT(v-knp          ,"kz-1048","utf-8").
        v-rcptdetails   = CODEPAGE-CONVERT(v-rcptdetails  ,"kz-1048","utf-8").
        v-priority      = CODEPAGE-CONVERT(v-priority     ,"kz-1048","utf-8").
        v-numdoc        = CODEPAGE-CONVERT(v-numdoc       ,"kz-1048","utf-8").
        v-rsptrnn       = CODEPAGE-CONVERT(v-rsptrnn      ,"kz-1048","utf-8").
        v-intbic        = CODEPAGE-CONVERT(v-intbic       ,"kz-1048","utf-8").
        v-intname       = CODEPAGE-CONVERT(v-intname      ,"kz-1048","utf-8").
        v-kbe           = CODEPAGE-CONVERT(v-kbe          ,"kz-1048","utf-8").
        v-comacc        = CODEPAGE-CONVERT(v-comacc       ,"kz-1048","utf-8").
        v-purchacc      = CODEPAGE-CONVERT(v-purchacc     ,"kz-1048","utf-8").
        v-saleacc       = CODEPAGE-CONVERT(v-saleacc      ,"kz-1048","utf-8").
        v-ispurchase    = CODEPAGE-CONVERT(v-ispurchase   ,"kz-1048","utf-8").
        v-kbk           = CODEPAGE-CONVERT(v-kbk          ,"kz-1048","utf-8").
        v-purposetype   = CODEPAGE-CONVERT(v-purposetype  ,"kz-1048","utf-8").
        v-purchaseamt   = CODEPAGE-CONVERT(v-purchaseamt  ,"kz-1048","utf-8").
        v-saleamt       = CODEPAGE-CONVERT(v-saleamt      ,"kz-1048","utf-8").
        v-payerbankBic  = CODEPAGE-CONVERT(v-payerbankBic ,"kz-1048","utf-8").
        v-clientbankBic = CODEPAGE-CONVERT(v-clientbankBic,"kz-1048","utf-8").
        v-payerischarge = CODEPAGE-CONVERT(v-payerischarge,"kz-1048","utf-8").
        v-comision-type = CODEPAGE-CONVERT(v-comision-type,"kz-1048","utf-8").
        v-rubik         = CODEPAGE-CONVERT(v-rubik        ,"kz-1048","utf-8").
        v-intent        = CODEPAGE-CONVERT(v-intent       ,"kz-1048","utf-8").
        v-RCPT_BANK_BIC_TYPE        = CODEPAGE-CONVERT(v-RCPT_BANK_BIC_TYPE       ,"kz-1048","utf-8").
        v-INTERMED_BANK_BIC_TYPE        = CODEPAGE-CONVERT(v-INTERMED_BANK_BIC_TYPE       ,"kz-1048","utf-8").
        v-rusInn        = CODEPAGE-CONVERT(v-rusInn       ,"kz-1048","utf-8").
        v-rusKpp        = CODEPAGE-CONVERT(v-rusKpp       ,"kz-1048","utf-8").

        v-rcptdetails   = replace2Space(v-rcptdetails).

        message string(today).
        message "***********************************************".
        message "                    ID = "  string(v-state          ).
        message "       CANCEL_CURRENCY = "  string(v-CancelVAL      ).
        message "         CANCEL_DOC_ID = "  string(v-CancelDocId    ).
        message "             IS_SOCIAL = "  string(v-payissocial    ).
        message "               PAYMENT = "  string(v-payment-kz     ).
        message "            PS_PAYMENT = "  string(v-payment-ps     ).
        message "      CURRENCY_PAYMENT = "  string(v-payment-cr     ).
        message "     CURRENCY_EXCHANGE = "  string(v-payment-ex     ).
        message "             PAYER_IDN = "  string(v-rnn            ).
        message "            CLIENT_IDN = "  string(v-clientrnn      ).
        message "         PAYER_ACCOUNT = "  string(v-aaa            ).
        message "          RCPT_ACCOUNT = "  string(v-rspnt          ).
        message "                AMOUNT = "  string(v-amount         ).
        message "         RCPT_BANK_BIC = "  string(v-rcptbik        ).
        message "        RCPT_BANK_NAME = "  string(v-rcptbank       ).
        message "             RCPT_NAME = "  string(v-rcptname       ).
        message "      DESTINATION_CODE = "  string(v-knp            ).
        message "       PAYMENT_DETAILS = "  string(v-rcptdetails    ).
        message "              PRIORITY = "  string(v-priority       ).
        message "               NUM_DOC = "  string(v-numdoc         ).
        message "              RCPT_IDN = "  string(v-rsptrnn        ).
        message "            VALUE_DATE = "  string(v-valdate        ).
        message "     INTERMED_BANK_BIC = "  string(v-intbic         ).
        message "    INTERMED_BANK_NAME = "  string(v-intname        ).
        message "             RCPT_CODE = "  string(v-kbe            ).
        message "    COMMISSION_ACCOUNT = "  string(v-comacc         ).
        message "              DATE_DOC = "  string(v-datedoc        ).
        message "      PURCHASE_ACCOUNT = "  string(v-purchacc       ).
        message "          SALE_ACCOUNT = "  string(v-saleacc        ).
        message "           IS_PURCHASE = "  string(v-ispurchase     ).
        message "                   KBK = "  string(v-kbk            ).
        message "      PURCHASE_PURPOSE = "  string(v-purposetype    ).
        message "       PURCHASE_AMOUNT = "  string(v-purchaseamt    ).
        message "           SALE_AMOUNT = "  string(v-saleamt        ).
        message "        PAYER_BANK_BIC = "  string(v-payerbankBic   ).
        message "            CLIENT_BIC = "  string(v-clientbankBic  ).
        message "             IS_CHARGE = "  string(v-payerischarge  ).
        message "            ATTACHMENT = "  string(v-pensia <> ""   ).
        message "       COMMISSION_TYPE = "  string(v-comision-type  ).
        message "         RUBIC_ACCOUNT = "  string(v-rubik          ).
        message "                INTENT = "  string(v-intent         ).
        message "    RCPT_BANK_BIC_TYPE = "  string(v-RCPT_BANK_BIC_TYPE          ).
        message "INTERMED_BANK_BIC_TYPE = "  string(v-INTERMED_BANK_BIC_TYPE         ).
        message "               RUS_INN = "  string(v-rusInn         ).
        message "               RUS_KPP = "  string(v-rusKpp         ).
        message "***********************************************".


        if (v-payment-details <> v-rcptdetails) and (length(v-payment-details) = length(v-rcptdetails))  and INDEX(v-rcptdetails, '?') <> 0   then do:
            v-rcptdetails = v-payment-details.
        end.
        if (v-kzrcptname <> v-rcptname) and (length(v-kzrcptname) = length(v-rcptname))  and INDEX(v-rcptname, '?') <> 0   then do:
            v-rcptname = v-kzrcptname.
        end.
        pause 0.
        if v-purchaseamt = ? then v-purchaseamt = "0.00".

        /*ОТПРАВКА ПИСЕМ МЕНЕДЖЕРАМ---------------------------------------------------------------------*/
        def var v-str as char.
        def var fNameout as char.
        if (v-payment-order <> " " and v-payment-order <> "0")  then do:
           message "line 450.".
           jj = 0.
           run get-valuenode(hdoc) no-error.

           v-file = "". v-body = "". v-errorr = 0. v-str = "".
           m_PAYER_NAME    = CODEPAGE-CONVERT(m_PAYER_NAME       ,"kz-1048","utf-8").
           m_MESSAGE_BODY  = CODEPAGE-CONVERT(m_MESSAGE_BODY     ,"kz-1048","utf-8").
           m_THEME         = CODEPAGE-CONVERT(m_THEME            ,"kz-1048","utf-8").
           message "        m_PAYER_NAME = "  string(m_PAYER_NAME        ).
           message "      m_MESSAGE_BODY = "  string(m_MESSAGE_BODY      ).
           message "             m_THEME = "  string(m_THEME             ).
           do jj = 1 to integer(m_TOTAL_COUNT):
              message "     m_FILE_NAME[jj] ="  m_FILE_NAME[jj].
              run replname(m_FILE_NAME[jj], output fNameout).
              m_FILE_NAME[jj] = fNameout.
              message "   repl m_FILE_NAME[jj] ="  m_FILE_NAME[jj].
              m_FILE_NAME[jj] = CODEPAGE-CONVERT(m_FILE_NAME[jj],"1251","koi8-r").
              message "   conv m_FILE_NAME[jj] ="  m_FILE_NAME[jj].

              v-chtxt1 = "". i-stn = 0.
              output to value(m_FILE_NAME[jj]) no-map no-convert. /*BINARY.*/
              do i-stn = 1 to length(m_DATA[jj]):
                 export hex-decode(substr(m_DATA[jj],i-stn,15000)).
                 i-stn = i-stn + 14999.
              end.
              output close .
              if jj = 1 then v-file = m_FILE_NAME[jj].
              else v-file = v-file + ";" + m_FILE_NAME[jj].
           end.
           v-body = "Клиент: " + m_PAYER_NAME + "\n-----------------------------------------\n\n" + m_MESSAGE_BODY.
           find first comm.txb where comm.txb.mfo = m_PAYER_BANK_BIC and comm.txb.consolid no-lock no-error.
           if not avail comm.txb then do:
              v-errorr = 1.
              v-des = "Ошибка определения филиала банка" .
           end.
           if v-errorr = 0 then do:
               if m_PAYER_ACCOUNT <> "" then do:
                  run mail("id00787@metrocombank.kz", "КЛИЕНТ ИНТЕРНЕТ-БАНКИНГА <netbank@metrocombank.kz>", m_THEME, v-body , "1", "",v-file).
                  for each gate where gate.name = "" no-lock:
                      if gate.txb = "TXB" + substr(m_PAYER_ACCOUNT,19,2) then do:
                         run mail(gate.email, "КЛИЕНТ ИНТЕРНЕТ-БАНКИНГА <netbank@metrocombank.kz>", m_THEME, v-body , "1", "",v-file).
                      end.
                  end.
               end.
               run createXMLMessage in ptpsession (output requestH).
               run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
               run appendText in requestH ("<DOC>").
               run appendText in requestH ("<MESSAGE_ORDER>").
               run appendText in requestH ("<ID>" + m_id + "</ID>").
               run appendText in requestH ("<STATUS>5</STATUS>").
               run appendText in requestH ("<DESCRIPTION>Исполнен</DESCRIPTION>").
               run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
               run appendText in requestH ("</MESSAGE_ORDER>").
               run appendText in requestH ("</DOC>").
               RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?).
               RUN deleteMessage IN requestH.
           end. else do:
               run createXMLMessage in ptpsession (output requestH).
               run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
               run appendText in requestH ("<DOC>").
               run appendText in requestH ("<MESSAGE_ORDER>").
               run appendText in requestH ("<ID>" + m_id + "</ID>").
               run appendText in requestH ("<STATUS>6</STATUS>").
               run appendText in requestH ("<DESCRIPTION>" + v-des + "</DESCRIPTION>").
               run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
               run appendText in requestH ("</MESSAGE_ORDER>").
               run appendText in requestH ("</DOC>").
               RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?).
               RUN deleteMessage IN requestH.
           end.
          return.
        end.
        /*ОТПРАВКА ПИСЕМ МЕНЕДЖЕРАМ END---------------------------------------------------------------------*/

        DELETE OBJECT hdoc.
        DELETE OBJECT hRoot.
        if v-saleamt = ? then v-saleamt = "0.00".
        put unformatted string(time, "hh:mm:ss") skip.
        if v-kbk = ? then v-kbk = "".
        def var vtmp as char.
        if v-ispurchase = "0" then do:
           vtmp = "" .
           vtmp = v-saleamt .
           v-saleamt = v-purchaseamt.
           v-purchaseamt = vtmp.
           /*Этот кусок переделать когда Анвар исправит ошибку в java коде*/
           if v-comacc = v-purchacc then
              v-comacc = v-saleacc.
           else if v-comacc = v-saleacc then v-comacc = v-purchacc.
           /*Этот кусок переделать когда Анвар исправит ошибку в java коде*/
        end.

        find last netbank where netbank.id = v-state exclusive-lock no-error.
        if not avail netbank then do:  /*убрать*/
          create netbank.
                 netbank.rem[4] = string(g-today).
                 netbank.id = v-state.
                 netbank.sts = "4".
                 netbank.rem[1] = "На обработке".
                 netbank.rem[2] = v-numdoc.
        end.

        message v-state.
        v-sts = "4" .
        v-des = "На обработке".

        /*логику не меняем пока Анвар не исправит ошибки в Java коде*/
        if (v-payment-kz = " " or v-payment-kz = "0") and (v-payment-cr = " "  or v-payment-cr = "0") and (v-payment-ex = " "  or v-payment-ex = "0") then do:
        end. else do:
           message "line 559.".
           {errorreply.i}
        end.
        /*логику не меняем пока Анвар не исправит ошибки в Java коде*/

        /*ОТЗЫВ ПЛАТЕЖА---------------------------------------------------------------------*/
        def var v-cancelvalue as char.
        if (v-payment-kz = " " or v-payment-kz = "0") and (v-payment-cr = " "  or v-payment-cr = "0") and (v-payment-ex = " "  or v-payment-ex = "0") then do:
           message 'line 503'.
           find last b-netbank where b-netbank.id = v-CancelDocId exclusive-lock no-error.
           if avail b-netbank then do:
              find first comm.txb where comm.txb.bank = b-netbank.txb and comm.txb.consolid no-lock no-error.
              if not avail comm.txb then do:
                 message 'line 508'.
                 netbank.sts = "6".
                 netbank.rem[1] = "ОШИБКА:Отзываемый платеж не найден " + v-CancelDocId.
                 netbank.type = 3.
                 run createXMLMessage in ptpsession (output requestH).
                 run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                 run appendText in requestH ("<DOC>").
                 run appendText in requestH ("<CANCELLATION>").
                 run appendText in requestH ("<ID>" + v-state + "</ID>").
                 run appendText in requestH ("<STATUS>6</STATUS>").
                 run appendText in requestH ("<DESCRIPTION>Отвергнут</DESCRIPTION>").
                 run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
                 run appendText in requestH ("</CANCELLATION>").
                 run appendText in requestH ("</DOC>").
                 RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?).
                 RUN deleteMessage IN requestH.
                 release netbank.
                 release b-netbank.
                 return.
              end. else do:
                 message 'line 528'.
                 if connected ("txb") then disconnect "txb".
                 connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                 if b-netbank.rmz begins "rmz" then
                    run rollpayment(b-netbank.rmz, output v-cancelvalue).
                 else
                    run rollconv(b-netbank.rmz, output v-cancelvalue).

                 if v-cancelvalue = "ok" then do:
                    netbank.sts = "5".
                    netbank.rem[1] = "Отозван" + v-CancelDocId.
                    if b-netbank.rmz begins "rmz" then
                       netbank.type = 3.
                    else
                       netbank.type = 5. /*отзыв исполнен*/

                    netbank.rmz = "OTZ" + b-netbank.rmz.
                    netbank.txb = b-netbank.txb.
                    run createXMLMessage in ptpsession (output requestH).
                    run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                    run appendText in requestH ("<DOC>").
                    run appendText in requestH ("<CANCELLATION>").
                    run appendText in requestH ("<ID>" + v-state + "</ID>").
                    run appendText in requestH ("<STATUS>5</STATUS>").
                    run appendText in requestH ("<DESCRIPTION>Обработан</DESCRIPTION>").
                    run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
                    run appendText in requestH ("</CANCELLATION>").
                    run appendText in requestH ("</DOC>").
                    RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?).
                    RUN deleteMessage IN requestH.

                    run createXMLMessage in ptpsession (output requestH).
                    run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                    run appendText in requestH ("<DOC>").

                    if b-netbank.rmz begins "rmz" then do:
                       if v-CancelVAL = "KZT" then  run appendText in requestH ("<PAYMENT>").
                       else run appendText in requestH ("<CURRENCY_PAYMENT>").
                    end. else do:
                       run appendText in requestH ("<CURRENCY_EXCHANGE>").
                    end.
                    run appendText in requestH ("<ID>" + v-CancelDocId + "</ID>").
                    run appendText in requestH ("<STATUS>6</STATUS>").
                    if b-netbank.rmz begins "rmz" then do:
                       if v-CancelVAL = "KZT" then run appendText in requestH ("</PAYMENT>").
                       else  run appendText in requestH ("</CURRENCY_PAYMENT>").
                    end. else do:
                       run appendText in requestH ("</CURRENCY_EXCHANGE>").
                    end.
                    run appendText in requestH ("<DESCRIPTION>Отвергнут по причине отзыва </DESCRIPTION>").
                    run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
                    run appendText in requestH ("</DOC>").
                    RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?).
                    RUN deleteMessage IN requestH.
                    release netbank.
                    release b-netbank.
                    return.
                 end. else do:
                    netbank.sts = "6".
                    netbank.rem[1] = "ОШИБКА:Отзываемый платеж не найден " + v-CancelDocId.
                    netbank.type = 3.
                    run createXMLMessage in ptpsession (output requestH).
                    run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                    run appendText in requestH ("<DOC>").
                    run appendText in requestH ("<CANCELLATION>").
                    run appendText in requestH ("<ID>" + v-state + "</ID>").
                    run appendText in requestH ("<STATUS>6</STATUS>").
                    run appendText in requestH ("<DESCRIPTION>Отвергнут</DESCRIPTION>").
                    run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
                    run appendText in requestH ("</CANCELLATION>").
                    run appendText in requestH ("</DOC>").
                    RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?).
                    RUN deleteMessage IN requestH.
                    release netbank.
                    release b-netbank.
                    return.
                 end.
              end.
           end. /* if avail netbank */
        end.
        /*END ОТЗЫВ ПЛАТЕЖА---------------------------------------------------------------------*/

        /*Проверка если такой платеж уже проведен*/
        find last netbank where netbank.id = v-state and netbank.sts = "4" exclusive-lock no-error.
        if not avail netbank then return.
        /*Проверка если такой платеж уже проведен*/

        /*ПЛАТЕЖ НА ТЕРРИТОРИИ РК---------------------------------------------------------------------*/
        if (v-payment-kz <> " " and v-payment-kz <> "0") then do:
           message "line 681.".
           if connected ("txb") then disconnect "txb".
           find first comm.txb where comm.txb.bank = "TXB" + substr(v-aaa,19,2) and comm.txb.consolid no-lock no-error.
           if not avail comm.txb then do:
              message "line 685.".
              v-sts = "6".
              v-des = "Ошибка определения филиала банка" .
              netbank.sts = v-sts.
              netbank.rem[1] = v-des.
              {sync2netbank.i}
              return.
           end. else do:
              netbank.txb = txb.bank.
              netbank.type = 1.
           end.

           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           rdes = ''.
           if v-priority = "1"  then v-urgency = "U". else  v-urgency = "N".
           v-ref =  next-value(Exflow,ib).
           if v-payerischarge = "1" then l-doctax = true. else l-doctax = false.
           /*если пенсионный извлекаем содержимое MT102*/
           if v-payissocial = "1" and v-pensia <> "" then do:
              v-chtxt = "".
              output to value(v-aaa + "_" + string(v-numdoc) + ".txt").
              do i-inx = 1 to length(v-pensia):
                 v-chtxt = "".
                 v-chtxt = substr(v-pensia,i-inx,15000) .
                 v-chtxt = string(hex-decode(v-chtxt)).
                 put unformatted v-chtxt.
                 i-inx = i-inx + 14999.
              end.
              if length(v-chtxt) >= 2 then do:
                 if substr(v-chtxt, length(v-chtxt) - 1, 2) = "-}" then do:
                    put unformatted  skip.
                 end.
              end.
             output close .
           end.
           /*если пенсионный извлекаем содержимое MT102*/
           message 'line 653'.
           run snx1( string(v-kbk), /*1*/
                     string(v-numdoc), /*2*/
                     1, /*3*/
                     if v-payissocial = "1" then 3 else 0, /*4*/
                     v-valdate , /*5*/
                     1   , /*6*/
                     decimal(v-amount), /*7*/
                     v-aaa, /*8*/
                     v-rcptbank, /*9*/
                     "" , /*10*/
                     "" , /*11*/
                     "" , /*12*/
                     "" , /*13*/
                     v-rsptrnn, /*14*/
                     v-rcptname, /*15*/
                     "" , /*16*/
                     "" , /*17*/
                     trim(v-rspnt), /*18*/
                     trim(v-rcptdetails), /*19*/
                     "" , /*20*/
                     "" , /*21*/
                     "" , /*22*/
                     "BEN" , /*23*/
                     today , /*24*/
                     "" , /*25*/
                     v-urgency, /*26*/
                     l-doctax, /*27*/
                     "" , /*28*/
                     "" , /*29*/
                     "" , /*30*/
                     "" , /*31*/
                     v-comacc , /*32*/
                     string(v-rnn), /*33*/
                     "" , /*34*/
                     "" , /*35*/
                     if substr(v-kbe,1,1) = "1" then '/BENRES/R' else '/BENRES/N' , /*36*/
                     substr(v-kbe,2,1), /*37*/
                     v-knp , /*38*/
                     v-rcptbik , /*39*/
                     g-today, /*40*/
                     v-intbic , /*41*/
                     0, /*42*/
                     v-state, /*43*/
                     v-datedoc, /*44*/
                     v-purposetype, /*45*/
                     "", /*46*/
                     v-intent, /*47*/
                     "", /*48*/
                     "", /*49*/
                     "", /*50*/

                     output rdes,  output v-reterr, output v-ba, output v-pri, output rsts, output v-cifname).

           if rdes <> "" and rdes begins "rmz" then do:
              netbank.rmz = rdes.
              netbank.sts = "100".

              if can-do('KZ41470142860A037116,KZ05470142860A020401,KZ77470142860A019202,KZ80470142860A020603,KZ41470142860A018104,KZ56470142860A022005,KZ80470142860A020506,KZ82470142860A022507,KZ88470142860A022108,KZ95470142860A021109,KZ68470142860A021110,KZ58470142860A020611,KZ44470142860A022512,KZ53470142860A020313,KZ85470142860A023714,KZ10470142860A023415',v-ba) then do:
                  find first remtrz where remtrz.remtrz = netbank.rmz exclusive-lock no-error.
                  if avail remtrz then remtrz.rsub = 'arp'.
                  find current remtrz no-lock no-error.
              end.

              message "line 711. " + string(rdes).
              /*отправка уведомлений менеджерам*/
              for each gate where gate.name = "" no-lock:
                  if gate.txb = comm.txb.bank then do:
                     if  substr(v-aaa,10,4) = "2215" or  substr(v-aaa,10,4) = "2217" then do:
                         run mail(gate.email, v-cifname + " <netbank@metrocombank.kz>", "ВНИМАНИЕ: ПЛАТЕЖ С ДЕПОЗИТА ", "RMZ : " + rdes   + "\n Необходимо разблокировать сумму" , "1", "","").
                     end. else do:
                         run mail(gate.email, v-cifname + " <netbank@metrocombank.kz>", "Заявка на проведение платежа", "RMZ : " + rdes   + "\n Необходимо проверить реквизиты" , "1", "","").
                     end.
                  end.
              end.
              /*отправка уведомлений менеджерам*/
           end. else do:
              message "line 724. Ошибка" .
              v-sts = "6".
              v-des =  rdes.
              netbank.sts = "6".
              netbank.rem[1] = v-des.
              {sync2netbank.i}
              return.
           end.
           if connected ("txb")  then disconnect "txb".
        end.
        /*END ПЛАТЕЖ НА ТЕРРИТОРИИ РК---------------------------------------------------------------------*/

        /*МЕЖДУНАРОДНЫЙ ПЛАТЕЖ----------------------------------------------------------------------------*/
        if v-payment-cr <> " "  and v-payment-cr <> "0"   then do:
           def var inn_kpp as char.
           if trim(v-rusInn) <> '' and v-rusInn <> ? then do:
               inn_kpp = "INN" + trim(v-rusInn).
               if trim(v-rusKpp) <> '' and v-rusKpp <> ? then inn_kpp = inn_kpp + ".".
           end.
           if trim(v-rusKpp) <> '' and v-rusKpp <> ? then inn_kpp = inn_kpp + "KPP" + trim(v-rusKpp).
           message "line 809.".
           if connected ("txb") then disconnect "txb".
           find first comm.txb where comm.txb.bank = "TXB" + substr(v-aaa,19,2) and comm.txb.consolid no-lock no-error.
           if not avail comm.txb then do:
              message "line 813.".
              v-sts = "6".
              v-des = "Ошибка определения филиала банка" .
              netbank.sts = v-sts.
              netbank.rem[1] = v-des.
              {sync2netbank.i}
              return.
           end. else do:
              netbank.txb = txb.bank.
              netbank.type = 2.
           end.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           rdes = ''.

           /* 0-BEN, 1-OUR, 2-SHA */
           def var v-cur_comission_type as char.
           if v-comision-type = "0" then v-cur_comission_type = "BEN".
           else if v-comision-type = "2" then v-cur_comission_type = "SHA".
           else v-cur_comission_type = "OUR".

           if v-priority = "1"  then v-urgency = "U". else  v-urgency = "N".
           v-ref =  next-value(Exflow).
           v-ptype = 2.
           find first b-txb where b-txb.mfo = v-rcptbik and b-txb.consolid no-lock no-error.
           if avail b-txb then do:
              v-ptype = 5.
              if substr(v-aaa,19,2) <> substr(v-rspnt,19,2)  then do:
                 v-ptype = 1.
              end.
           end.

           message 'line 760'.
           run snx1(string(v-kbk), /*1*/
                    string(v-numdoc), /*2*/
                    v-ptype , /*3*/
                    0, /*4*/
                    v-valdate, /*5*/
                    "", /*6*/
                    decimal(v-amount), /*7*/
                    v-aaa, /*8*/
                    v-rcptbank, /*9*/
                    ""/*v-rcptbank*/, /*10*/
                    "", /*11*/
                    "", /*12*/
                    v-intname , /*13*/
                    "", /*14*/
                    v-rcptname, /*15*/
                    "", /*16*/
                    "", /*17*/
                    v-rspnt, /*18*/
                    v-rcptdetails, /*19*/
                    "", /*20*/
                    "", /*21*/
                    "", /*22*/
                    v-cur_comission_type, /*23*/
                    today , /*24*/
                    "", /*25*/
                    v-urgency, /*26*/
                    false, /*27*/
                    "SWIFT" , /*28*/
                    v-rcptbik , /*29*/
                    "", /*30*/
                    "", /*31*/
                    v-comacc , /*32*/
                    string(v-rnn), /*33*/
                    "", /*34*/
                    "", /*35*/
                    if substr(v-kbe,1,1) = "1" then '/BENRES/R' else '/BENRES/N' , /*36*/
                    substr(v-kbe,2,1) , /*37*/
                    v-knp, /*38*/
                    if v-ptype = 1 then v-rcptbik else "", /*39*/
                    g-today, /*40*/
                    v-intbic, /*41*/
                    0, /*42*/
                    v-state, /*43*/
                    v-datedoc, /*44*/
                    v-purposetype, /*45*/
                    v-rubik, /*46*/
                    v-intent, /*47*/
                    v-RCPT_BANK_BIC_TYPE, /*48*/
                    v-INTERMED_BANK_BIC_TYPE, /*49*/
                    inn_kpp, /*50*/

                    output rdes,  output v-reterr, output v-ba, output v-pri, output rsts, output v-cifname).
           if rdes <> "" and rdes begins "rmz" then do:
              find last remtrz where remtrz.remtrz = rdes no-lock no-error.
              v-sts = "4".
              v-des = "Докумен" + rdes + " находится на контроле у менеджера" .
              netbank.rmz = rdes.
              netbank.sts = "100".
              message "line 821. " + string(rdes).
              for each gate where gate.name = "" no-lock:
                  if gate.txb = comm.txb.bank then do:
                     run mail(gate.email, v-cifname + " <netbank@metrocombank.kz>", "Заявка на проведение валютного платежа", "RMZ : " + rdes   + "\n Необходимо проверить реквизиты" , "1", "","").
                  end.
              end.
           end. else do:
              message "line 828. Ошибка" .
              v-sts = "6".
              v-des = "Ошибка в реквизитах" .
              netbank.sts = "6".
              netbank.rem[1] = v-des.
              {sync2netbank.i}
              return.
           end.
           if connected ("txb")  then disconnect "txb".
        end.
        /*END МЕЖДУНАРОДНЫЙ ПЛАТЕЖ----------------------------------------------------------------------------*/

        /*КОНВЕРТАЦИЯ_РЕКОНВЕРТАЦИЯ----------------------------------------------------------------------------*/
        if v-payment-ex <> " "  and v-payment-ex <> "0" then do:
           message "line 915.".
           sv_rnn = v-clientrnn.
           sv_aaa = v-saleacc.
           sv_bic = "".
           sv_bic = "190501914". /*убрать при переходе на новые БИКи*/
           if sv_bic <> "" then do:
              if connected ("txb") then disconnect "txb".
              find first comm.txb where comm.txb.bank = "TXB" + substr(v-saleacc,19,2) and comm.txb.consolid no-lock no-error.
              if not avail comm.txb then do:
                 message "line 924.".
                 v-sts = "6".
                 v-des = "Ошибка определения филиала банка" .
                 netbank.sts = v-sts.
                 netbank.rem[1] = v-des.
                 {sync2netbank.i}
                 return.
              end. else do:
                 netbank.txb = txb.bank.
                 netbank.type = 0.
              end.
              if connected ("txb") then disconnect "txb".
              connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
              rdes = ''.
              if v-priority = "0" then v-urgency = "N". else v-urgency = "U".
              message 'line 859'.
              run snx1( string(v-kbk), /*1*/
                        string(v-numdoc), /*2*/
                        9, /*3*/
                        if v-ispurchase = "1" then "1" else "2", /*4*/
                        v-valdate, /*5*/
                        0, /*6*/
                        decimal(v-saleamt), /*7*/
                        v-saleacc, /*8*/
                        v-rcptbank, /*9*/
                        v-rcptbank, /*10*/
                        "", /*11*/
                        "", /*12*/
                        v-intname , /*13*/
                        "", /*14*/
                        v-rcptname, /*15*/
                        "", /*16*/
                        "", /*17*/
                        v-purchacc, /*18*/
                        v-rcptdetails, /*19*/
                        "", /*20*/
                        "", /*21*/
                        "", /*22*/
                        "OUR", /*23*/
                        today, /*24*/
                        "", /*25*/
                        v-urgency, /*26*/
                        false, /*27*/
                        "SWIFT" , /*28*/
                        v-rcptbik , /*29*/
                        "", /*30*/
                        "" , /*31*/
                        v-comacc , /*32*/
                        string(v-rnn), /*33*/
                        "", /*34*/
                        "" , /*35*/
                        '/BENRES/' , /*36*/
                        '', /*37*/
                        v-knp, /*38*/
                        "", /*39*/
                        g-today, /*40*/
                        v-intbic, /*41*/
                        decimal(v-purchaseamt), /*42*/
                        v-state, /*43*/
                        v-datedoc, /*44*/
                        v-purposetype, /*45*/
                        "", /*46*/
                        v-intent, /*47*/
                        "", /*48*/
                        "", /*49*/
                        "", /*50*/

                        output rdes,  output v-reterr, output v-ba, output v-pri, output rsts, output v-cifname).
              if rsts = 0  then do:
                 netbank.rmz = rdes.
                 netbank.sts = "100".
                 message "line 916. " + string(rdes).
                 for each gate where gate.name = "" no-lock:
                     if gate.txb = comm.txb.bank then do:
                        run mail(gate.email, v-cifname + " <netbank@metrocombank.kz>", "Конвертация ", "Документ : " + rdes   + "\n Необходимо проверить реквизиты" , "1", "","").
                     end.
                 end.
              end. else do:
                 message "line 923. Ошибка" .
                 v-sts = "6".
                 v-des = "Ошибка в реквизитах" .
                 netbank.sts = "6".
                 netbank.rem[1] = v-des.
                 {sync2netbank.i}
                 return.
              end.
              if connected ("txb")  then disconnect "txb".
           end.
        end.
        /*END КОНВЕРТАЦИЯ_РЕКОНВЕРТАЦИЯ----------------------------------------------------------------------------*/
    end.
    find last netbank no-lock no-error.
    message "1004. **********************************".
end.

function inWait returns logical.
    return not(v-terminate).
end.

/*ПРОЦЕДУРА ДЛЯ КОНВЕРТАЦИИ HEX в CHAR-----------------------------------------------------------------------*/
Procedure Hex2Char.
  def input  parameter HexValue as char.
  def output parameter CharValue  as char.
  DEF VAR charset   AS CHAR FORMAT "x(1)" LABEL "Character".
  DEF VAR asc-value AS INT label "ASCII".
  DEF VAR rem       AS INT.
  DEF VAR r         AS INT.
  DEF VAR hx        AS CHAR FORMAT "x(4)" LABEL "Hexadecimal".
  DEF VAR str       AS CHAR.
  def var v-i as integer.
  v-i = 1.
  REPEAT:
    hx = substr(HexValue, v-i, 2) .
    v-i = v-i + 2.
    if v-i > length(HexValue) then leave.
    str        = SUBSTRING(hx,1,1).
    asc-value  = INT(str) * 16.
    str = CAPS(SUBSTRING(hx,2,1)).
    IF str GE "A" THEN DO:
       r      = KEYCODE(str) - KEYCODE("A").
       rem = 10 + r.
    END. ELSE rem = INT(str).
    asc-value  = asc-value + rem.
    charset = CHR(asc-value).
    CharValue = CharValue + charset.
  END.
End procedure.

/*ПРОЦЕДУРА ДЛЯ ТРАНСЛИТЕРАЦИИ-------------------------------------------------------------------------------*/
Procedure replName.
  def input  parameter fNamein as char.
  def output parameter fNameout  as char.
  fNameout = fNamein.
  def var v-rusletter as char init "а,б,в,г,д,е,ё,ж,з,и,й,к,л,м,н,о,п,р,с,т,у,ф,х,ц,ч,ш,щ,ъ,ы,ь,э,ю,я".
  def var v-engletter as char init "a,b,v,g,d,e,e,g,z,i,i,k,l,m,n,o,p,r,s,t,u,f,h,s,ch,sh,ch,-,-,-,-,u,ya".
  def var i-lettr as integer.
  do i-lettr = 1 to num-entries(v-rusletter):
     fNameout = replace(fNameout, ENTRY(i-lettr, v-rusletter), ENTRY(i-lettr, v-engletter) ).
  end.
  fNameout = replace(fNameout," ","").
  fNameout = trim(fNameout).
end.

/* ФУНКЦИЯ ДЛЯ ЗАМЕНЫ СИМВОЛА TAB И ПЕРЕНОСА СТРОКИ НА ПРОБЕЛ */
function replace2Space returns char (input inText as char).
   DEFINE VAR i AS INT NO-UNDO.
   DEFINE VAR currentChar AS CHAR NO-UNDO.
   DO i = 1 TO LENGTH(inText):
      currentchar = substring(inText,i,1).
      if currentchar = chr(9) then inText = replace(inText,currentchar,chr(32)). /* TAB на пробел */
      if currentchar = chr(10) then inText = replace(inText,currentchar,chr(32)). /* Перенос строки на пробел */
   END.
   RETURN inText.
end function.
/* КОНЕЦ ФУНКЦИИ */