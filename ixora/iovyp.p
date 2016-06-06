/* iovyp.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Формирование выписок для интернет-банкинга.
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
        29/04/2011 id00004 добавил отображение выписки по входящим платежам
        18/05/2011 id00004 добавил группирование по Дебету Кредиту
        07/10/2011 id00004 добавил определение сервера боевая или тестовая srvcheck.i
        13/10/2011 id00004 закомментировал отправку сообщений на очередь ttt
        18/11/2011 id00004 добавил формирование xml только для входящих если пришел запрос с пунктов pdf, excel
        27/12/2011 id00004 добавил переменную для перехода на ИИН-БИН
        27/01/2012 id00004 добавил отображение jou в выписке по входящим
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
        07.11.2012 evseev - отструктурировал код. добавил логирование.
        16.11.2012 berdibekov - КОд, КБЕ, РНН
        21.11.2012 berdibekov - отображение выписки по исходящие платежи
        11.12.2012 berdibekov - закомментировал строку RUN sendToQueue IN ptpsession ("test1", replyH, ?, ?, ?).
        02.01.2013 damir - Переход на ИИН/БИН.
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Перекомпиляция в связи с изменением iovyp.i.
        12.09.2013 k.gitalov ИБФЛ
*/
{global.i}
{srvcheck.i}
{chbin.i}
{iovypshared.i "new"}

def buffer b-aaa for aaa.

define variable ptpsession as handle.
define variable consumerH as handle.
define variable replyMessage as handle.
define  variable sm as decimal .
define  variable sm1 as decimal .
define  variable smd as decimal .
define  variable smd1 as decimal .
def var v-terminate as logi no-undo.
def var v-clecod as char no-undo.
def var g_date as date.

def temp-table t-docout no-undo
  field oper_code as integer
  field num_doc   as char     /* ???? */
  field deal_type as char
  field deal_code as char
  field date_doc  as date
  field name      as char
  field account   as char
  field dam       as deci
  field cam       as deci
  field bank_bic  as char
  field bank_name as char
  field des       as char
  field knp       as char
  field kbe as char             /*KBE*/
  field kod as char             /*КОд*/
  field rnn as char             /*РНН*/
  field nominale  as deci
  field tim as integer
  field crc as char
  index idx is primary oper_code.

v-terminate = no.
{sysc.i}
v-clecod = get-sysc-cha("clecod").

function conv returns char (input str as char).
    def var utf_str as char no-undo.
    utf_str = "".
    input through value("koi2utfs """ + str + """").
    import unformatted utf_str.
    return (utf_str).
end function.
 d_gtday = g-today .
 g_date  = g-today .

/* уПЪДБЕН ПВЯЕЛФ УЕУУЙЙ */
run  jms/ptpsession.p persistent set ptpsession ("-H localhost -S 5162 ").

if isProductionServer() then do:
    run setBrokerURL in ptpsession ("tcp://172.16.3.5:2507").
end. else do:
    run setBrokerURL in ptpsession ("tcp://172.16.2.77:2507").
end.

run setUser in ptpsession ('Administrator').
run setPassword in ptpsession ('Administrator').

run beginSession in ptpsession.

/* дМС ЧУЕИ ПФЧЕФОЩИ УППВЭЕОЙК ЙУРПМШЪХЕН ПДЙО ПВЯЕЛФ */
run createXMLMessage in ptpsession (output replyMessage).

/* УППВЭЕОЙС ЙЪ ЧИПДСЭЕК ПЮЕТЕДЙ */
run createMessageConsumer in ptpsession (
                              THIS-PROCEDURE,   /* ДБООБС РТПГЕДХТБ */
                             "requestHandler",  /* ЧОХФТЕООСС РТПГЕДХТБ */
                              output consumerH).

run receiveFromQueue in ptpsession ("EXTRACT",   /* ПЮЕТЕДШ ЧИПДСЭЙИ УППВЭЕОЙК */
                                     ?,           /* ОЕ ЖЙМШФТХЕН */
                                     consumerH).  /* ХЛБЪБФЕМШ ОБ ПВТБВПФЮЙЛ УППВЭЕОЙК */

/* ъБРХУЛБЕН РПМХЮЕОЙЕ ЪБРТПУПЧ */
run startReceiveMessages in ptpsession.

/* пВТБВБФЩЧБЕН ЪБРТПУЩ ВЕУЛПОЕЮОП */
run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).
message "Процесс корректно завершен".
run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deletesession in ptpsession no-error.


procedure requestHandler:
    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    def var msgText as char no-undo.
    def var pNames as char no-undo.
    def var pBalance as char no-undo.
    def var pAccount as char no-undo init ''.
    def var pBic as char no-undo init ''.
    def var pFromDate as date no-undo init ?.
    def var pToDate as date no-undo init ?.
    def var pToDate1 as char no-undo init ?.
    def var pStart as integer no-undo init 0.
    def var pLimit as integer no-undo init 0.
    def var pSortField as char no-undo init ''.
    def var pSortDir as char no-undo init ''.

    def var rdes as char no-undo.
    def var totalCount as integer no-undo.
    def var totalCount1 as integer no-undo.
    def var v-okpo as char no-undo.
    def var bankName as char no-undo.
    def var bankRNN as char no-undo.
    def var clientCode as char no-undo.
    def var clientName as char no-undo.
    def var clientRNN as char no-undo.
    def var operDate as char no-undo.
    def var i as integer no-undo.
    def var pEXTID as char no-undo.
    def var pInbound as char no-undo.
    def var pgroupDbCr as char no-undo.

    def var prmz as char no-undo.

    def var ss as char no-undo.

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end. else do:
        pNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).
        hide message no-pause.
        message pNames.

        if lookup("account",pNames)  > 0 then pAccount   = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "account").
        if lookup("bic",pNames)      > 0 then pBic       = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "bic").
        if lookup("fromDate",pNames) > 0 then pFromDate  = date(DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "fromDate")) no-error.
        if lookup("toDate",pNames)   > 0 then pToDate1   = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "toDate") no-error.
        if lookup("start",pNames)    > 0 then pStart     = DYNAMIC-FUNCTION('getIntProperty':U IN requestH, "start").
        if lookup("limit",pNames)    > 0 then pLimit     = DYNAMIC-FUNCTION('getIntProperty':U IN requestH, "limit").
        if lookup("sort",pNames)     > 0 then pSortField = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "sort").
        if lookup("dir",pNames)      > 0 then pSortDir   = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "dir").
        if lookup("EXT_ID",pNames)   > 0 then pEXTID     = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "EXT_ID").
        if lookup("type",pNames)     > 0 then pBalance   = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "type").
        if lookup("inbound",pNames)  > 0 then pInbound   = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "inbound").
        if lookup("groupDbCr",pNames)> 0 then pgroupDbCr = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "groupDbCr").
        if lookup("rmz",pNames)      > 0 then prmz       = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "rmz").

        message "********************************************************".
        message string(today).
        message string(time,'HH:MM:SS').
        message "********************************************************".
        message "  account = " + string(pAccount  ).
        message "      bic = " + string(pBic      ).
        message " fromDate = " + string(pFromDate ).
        message "   toDate = " + string(pToDate1  ).
        message "    start = " + string(pStart    ).
        message "    limit = " + string(pLimit    ).
        message "     sort = " + string(pSortField).
        message "      dir = " + string(pSortDir  ).
        message "   EXT_ID = " + string(pEXTID    ).
        message "     type = " + string(pBalance  ).
        message "  inbound = " + string(pInbound  ).
        message "groupDbCr = " + string(pgroupDbCr).
        message "      rmz = " + string(prmz      ).
        message "********************************************************".

        run deleteMessage in requestH.
        
        if pBalance = "INBOUND_PAYMENT" then do:
           find first comm.txb where comm.txb.bank = "TXB" + substr(pAccount,19,2) and comm.txb.consolid no-lock no-error.
           if not avail comm.txb then do:
              replyH = replyMessage.
              run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + conv("Ошибка соединения с БД") + "</error>").
              return.
           end.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           for each t-payment:
               delete t-payment.
           end.
           run rmzfind(prmz).
           find last t-payment no-lock no-error.
           if not avail t-payment then do:
              message "не заполнена таблица t-doc для платежа".
              return.
           end.
           replyH = replyMessage.
           run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
           run appendText in replyH ("<DOC>").
           run appendText in replyH ("<NUM_DOC>" +  t-payment.num_doc + "</NUM_DOC>").
           run appendText in replyH ("<DATE_DOC>" +  string(t-payment.date_doc) + "</DATE_DOC>").
           run appendText in replyH ("<PAYER_NAME><![CDATA[" + t-payment.payer_name   + "]]></PAYER_NAME>").
           run appendText in replyH ("<PAYER_IDN>" + t-payment.payer_rnn  + "</PAYER_IDN>").
           run appendText in replyH ("<PAYER_ACCOUNT>" + t-payment.payer_account  + "</PAYER_ACCOUNT>").
           run appendText in replyH ("<PAYER_CODE>" + t-payment.payer_code  + "</PAYER_CODE>").
           run appendText in replyH ("<AMOUNT>" +  t-payment.amount  + "</AMOUNT>").
           run appendText in replyH ("<VALUE_DATE>" +  string(t-payment.value_date) + "</VALUE_DATE>").
           run appendText in replyH ("<PAYER_BANK_BIC>" +  t-payment.payer_bank_bic + "</PAYER_BANK_BIC>").
           run appendText in replyH ("<PAYER_BANK_NAME><![CDATA[" + t-payment.payer_bank_name  + "]]></PAYER_BANK_NAME>").
           run appendText in replyH ("<RCPT_NAME>" + t-payment.rcpnt_name  + "</RCPT_NAME>").
           run appendText in replyH ("<RCPT_IDN>" +  t-payment.rcpnt_rnn + "</RCPT_IDN>").
           run appendText in replyH ("<RCPT_ACCOUNT>" +  t-payment.rcpnt_account + "</RCPT_ACCOUNT>").
           run appendText in replyH ("<RCPT_CODE>" +  t-payment.rcpnt_code + "</RCPT_CODE>").
           run appendText in replyH ("<RCPT_BANK_NAME>" + rcpnt_bank_name  + "</RCPT_BANK_NAME>").
           run appendText in replyH ("<RCPT_BANK_BIC>" +  t-payment.rcpnt_bank_bic  + "</RCPT_BANK_BIC>").
           run appendText in replyH ("<PAYMENT_DETAILS><![CDATA[" +  t-payment.payments_details + "]]></PAYMENT_DETAILS>").
           run appendText in replyH ("<DESTINATION_CODE>" +  t-payment.destination_code  + "</DESTINATION_CODE>").
           run appendText in replyH ("<KBK></KBK>").
           run appendText in replyH ("<TAX_PERCENTAGE></TAX_PERCENTAGE>").
           run appendText in replyH ("</DOC>").

	   message "328.".
           return.
        end.

        if pToDate1 = "null" then pToDate = g-today. else pToDate = date(pToDate1).
        /*run deleteMessage in requestH.*/

        if pBalance = "BALANCE" or pBalance = "BALANCE_EXT" or  pBalance = "DEPOSIT" or  pBalance = "CREDIT" or  pBalance = "INKNALOG"   then do:
           if pAccount = '' then do:
              if substr(pEXTID, 1, 1) = "A" then pAccount = "00000000000000000000" . /* ЦО        */
              if substr(pEXTID, 1, 1) = "T" then pAccount = "00000000000000000016" . /* Алм филиал */
              if substr(pEXTID, 1, 1) = "B" then pAccount = "00000000000000000001" . /* Актобе    */
              if substr(pEXTID, 1, 1) = "C" then pAccount = "00000000000000000002" . /* Костанай  */
              if substr(pEXTID, 1, 1) = "D" then pAccount = "00000000000000000003" . /* Тараз     */
              if substr(pEXTID, 1, 1) = "E" then pAccount = "00000000000000000004" . /* Уральск   */
              if substr(pEXTID, 1, 1) = "F" then pAccount = "00000000000000000005" . /* Караганда */
              if substr(pEXTID, 1, 1) = "H" then pAccount = "00000000000000000006" . /*  Семей*/
              if substr(pEXTID, 1, 1) = "K" then pAccount = "00000000000000000007" . /*  */
              if substr(pEXTID, 1, 1) = "L" then pAccount = "00000000000000000008" . /*  */
              if substr(pEXTID, 1, 1) = "M" then pAccount = "00000000000000000009" . /*  Павлодар*/
              if substr(pEXTID, 1, 1) = "N" then pAccount = "00000000000000000010" . /* Петропавловск */
              if substr(pEXTID, 1, 1) = "O" then pAccount = "00000000000000000011" . /* Атырау */
              if substr(pEXTID, 1, 1) = "P" then pAccount = "00000000000000000012" . /* Актау */
              if substr(pEXTID, 1, 1) = "Q" then pAccount = "00000000000000000013" . /* Жесказган */
              if substr(pEXTID, 1, 1) = "R" then pAccount = "00000000000000000014" . /* Усть каменогорск */
              if substr(pEXTID, 1, 1) = "S" then pAccount = "00000000000000000015" . /* Шымкент */
           end.
        end.

        find first comm.txb where comm.txb.bank = "TXB" + substr(pAccount,19,2) and comm.txb.consolid no-lock no-error.
        if not avail comm.txb then do:
           if pFromDate <> ? then do:
              replyH = replyMessage.
              run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + conv("пЫЙВЛБ ПРТЕДЕМЕОЙС ЖЙМЙБМБ ВБОЛБ") + "</error>").
              return.
           end.
        end.

        if pBalance = "BALANCE"  then do:
           for each t-accnt:
               delete t-accnt.
           end.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           empty temp-table t-doc.
           rdes = '' .
           run iovyp3(pEXTID).
           replyH = replyMessage.
           run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
           run appendText in replyH ("<CATALOG>").
           for each t-accnt:
               if t-accnt.total_balance begins "." then t-accnt.total_balance = "0" + t-accnt.total_balance.
               if t-accnt.available_balance begins "." then t-accnt.available_balance = "0" + t-accnt.available_balance.
               if t-accnt.freeze begins "." then t-accnt.freeze = "0" + t-accnt.freeze.
               if t-accnt.recent begins "." then t-accnt.recent = "0" + t-accnt.recent.
               run appendText in replyH ("<ACCOUNT>").
               run appendText in replyH ("<NUMBER>" +  t-accnt.numder + "</NUMBER>").
               run appendText in replyH ("<CURRENCY>" +  t-accnt.currency + "</CURRENCY>").
               run appendText in replyH ("<AVAILABLE_BALANCE>" +  t-accnt.available_balance + "</AVAILABLE_BALANCE>").
               run appendText in replyH ("<TOTAL_BALANCE>" + t-accnt.total_balance  + "</TOTAL_BALANCE>").
               run appendText in replyH ("<FREEZE>" +  t-accnt.freeze + "</FREEZE>").
               run appendText in replyH ("<RECENT>" +  t-accnt.recent + "</RECENT>").
               run appendText in replyH ("</ACCOUNT>").
               message " t-accnt.numder = " + string(t-accnt.numder).
               message " t-accnt.total_balance = " + string(t-accnt.total_balance).
           end.
           run appendText in replyH ("</CATALOG>").
           message "393.".
        end.

        if pBalance = "BALANCE_EXT"  then do:
           for each t-accnt:
               delete t-accnt.
           end.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           empty temp-table t-doc.
           rdes = '' .
           run iovyp3(pEXTID).
           replyH = replyMessage.
           run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
           run appendText in replyH ("<CATALOG>").
           for each t-accnt:
              if t-accnt.total_balance begins "." then t-accnt.total_balance = "0" + t-accnt.total_balance.
              if t-accnt.available_balance begins "." then t-accnt.available_balance = "0" + t-accnt.available_balance.
              if t-accnt.freeze begins "." then t-accnt.freeze = "0" + t-accnt.freeze.
              if t-accnt.recent begins "." then t-accnt.recent = "0" + t-accnt.recent.
              run appendText in replyH ("<ACCOUNT_EXT>").
              run appendText in replyH ("<NUMBER>" +  t-accnt.numder + "</NUMBER>").
              run appendText in replyH ("<CURRENCY>" +  t-accnt.currency + "</CURRENCY>").
              run appendText in replyH ("<AVAILABLE_BALANCE>" +  t-accnt.available_balance + "</AVAILABLE_BALANCE>").
              run appendText in replyH ("<TOTAL_BALANCE>" +  t-accnt.total_balance + "</TOTAL_BALANCE>").
              run appendText in replyH ("<FREEZE>" +  t-accnt.freeze + "</FREEZE>").
              run appendText in replyH ("<FLOAT_BALANCE>" + "0.00" +  "</FLOAT_BALANCE>").
              run appendText in replyH ("<OPENED_CREDIT_LINE>" + "0.00"  + "</OPENED_CREDIT_LINE>").
              run appendText in replyH ("<USED_CREDIT_LINE>" + "0.00"  + "</USED_CREDIT_LINE>").
              run appendText in replyH ("<RECENT>" +  t-accnt.recent + "</RECENT>").
              run appendText in replyH ("</ACCOUNT_EXT>").
           end.
           run appendText in replyH ("</CATALOG>").
           message "426.".
        end.

        if pBalance = "INKNALOG"  then do:
           for each t-ink:
               delete t-ink.
           end.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           empty temp-table t-doc.
           rdes = '' .
           run iovyp6(pEXTID).
           replyH = replyMessage.
           run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
           run appendText in replyH ("<CATALOG>").
           run appendText in replyH ("<TOTAL_COUNT>2</TOTAL_COUNT>").
           for each t-ink:
               if t-ink.summa begins "." then t-ink.summa = "0" + t-ink.summa.
               run appendText in replyH ("<ACCOUNT>").
               run appendText in replyH ("<NUMBER>" + t-ink.aaa + "</NUMBER>").
               run appendText in replyH ("<CURRENCY>" + t-ink.currency + "</CURRENCY>").
               run appendText in replyH ("<DATETIME>" + string(t-ink.datetime) + "</DATETIME>").
               run appendText in replyH ("<SUMMA>" + string(t-ink.summa) + "</SUMMA>").
               run appendText in replyH ("<KBK>" +  string(t-ink.kbk) + "</KBK>").
               run appendText in replyH ("<NUM>" +  string(t-ink.num) + "</NUM>").
               run appendText in replyH ("<VID>" +  string(t-ink.vid_operacii) + "</VID>").
               run appendText in replyH ("<STATUS>" + string(t-ink.ink_status) +  "</STATUS>").
               run appendText in replyH ("</ACCOUNT>").
           end.
           run appendText in replyH ("</CATALOG>").
           message "456.".
        end.

        if pBalance = "DEPOSIT"  then do:
           for each t-accnt-depo:
               delete t-accnt-depo.
           end.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           empty temp-table t-doc.
           rdes = '' .
           run iovyp4(pEXTID).
           replyH = replyMessage.
           run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
           run appendText in replyH ("<CATALOG>").
           run appendText in replyH ("<TOTAL_COUNT>2</TOTAL_COUNT>").
           for each t-accnt-depo:
               if t-accnt-depo.total_balance begins "." then t-accnt.total_balance = "0" + t-accnt.total_balance.
               if t-accnt-depo.available_balance begins "." then t-accnt.available_balance = "0" + t-accnt.available_balance.
               if t-accnt-depo.freeze begins "." then t-accnt-depo.freeze = "0" + t-accnt-depo.freeze.
               if t-accnt-depo.recent begins "." then t-accnt-depo.recent = "0" + t-accnt-depo.recent.
               run appendText in replyH ("<ACCOUNT>").
               run appendText in replyH ("<NUMBER>" + t-accnt-depo.numder + "</NUMBER>").
               run appendText in replyH ("<CURRENCY>" + t-accnt-depo.currency + "</CURRENCY>").
               run appendText in replyH ("<AVAILABLE_BALANCE>" + t-accnt-depo.available_balance + "</AVAILABLE_BALANCE>").
               run appendText in replyH ("<TOTAL_BALANCE>" + t-accnt-depo.total_balance + "</TOTAL_BALANCE>").
               run appendText in replyH ("<FREEZE>" +  t-accnt-depo.freeze + "</FREEZE>").
               run appendText in replyH ("<INTEREST_RATE>" + t-accnt-depo.intrate +  "</INTEREST_RATE>").
               run appendText in replyH ("<ACCRUED_RATE>" + t-accnt-depo.accrate + "</ACCRUED_RATE>").
               run appendText in replyH ("<INTEREST_PAID>" + t-accnt-depo.intpaid + "</INTEREST_PAID>").
               run appendText in replyH ("</ACCOUNT>").
           end.
           run appendText in replyH ("</CATALOG>").
           message "489.".
        end.

        if pBalance = "CREDIT"  then do:
           for each t-accnt-depo:
               delete t-accnt-depo.
           end.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           empty temp-table t-doc.
           rdes = '' .
           run iovyp5(pEXTID).
           replyH = replyMessage.
           run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
           run appendText in replyH ("<CATALOG>").
           run appendText in replyH ("<TOTAL_COUNT>2</TOTAL_COUNT>").
           for each t-accnt-depo:
               if t-accnt-depo.total_balance begins "." then t-accnt.total_balance = "0" + t-accnt.total_balance.
               if t-accnt-depo.available_balance begins "." then t-accnt.available_balance = "0" + t-accnt.available_balance.
               if t-accnt-depo.freeze begins "." then t-accnt-depo.freeze = "0" + t-accnt-depo.freeze.
               if t-accnt-depo.recent begins "." then t-accnt-depo.recent = "0" + t-accnt-depo.recent.
               run appendText in replyH ("<ACCOUNT>").
               run appendText in replyH ("<NUMBER>" + t-accnt-depo.numder + "</NUMBER>").
               run appendText in replyH ("<CURRENCY>" + t-accnt-depo.currency + "</CURRENCY>").
               run appendText in replyH ("<INTEREST_RATE>" + t-accnt-depo.intrate + "</INTEREST_RATE>").
               run appendText in replyH ("<CONTRACT>" + t-accnt-depo.available_balance + "</CONTRACT>").
               run appendText in replyH ("<LOAN_AMOUNT>" + t-accnt-depo.freeze + "</LOAN_AMOUNT>").
               run appendText in replyH ("<BALANCE>" + t-accnt-depo.total_balance + "</BALANCE>").
               run appendText in replyH ("<START_DATE>" + t-accnt-depo.accrate + "</START_DATE>").
               run appendText in replyH ("<END_DATE>" + t-accnt-depo.intpaid + "</END_DATE>").
               run appendText in replyH ("<AUX_ACC>" + t-accnt-depo.aux_acc + "</AUX_ACC>").
               run appendText in replyH ("</ACCOUNT>").
           end.
           run appendText in replyH ("</CATALOG>").
           message "522.".
        end.

       if pBalance <> "BALANCE" and pBalance <> "BALANCE_EXT" and  pBalance <> "DEPOSIT" and  pBalance <> "CREDIT" and  pBalance <> "INKNALOG"   then do:
          if pFromDate <> ? then do:
             if connected ("txb") then disconnect "txb".
             connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
          end.
          empty temp-table t-doc.
          rdes = ''.
          sm = 0. sm1 = 0.
          /*ГРАФИК ПОГАШЕНИЯ*/
          /*=============================*/
          def var debt as decimal.
          def var crdt as decimal.
          if pFromDate = ? then do:
             def var v-txv as char.
             if substr(pEXTID, 1, 1) = "A" then v-txv = "00" . /* ЦО        */
             if substr(pEXTID, 1, 1) = "T" then v-txv = "16" . /* Алм филиал */
             if substr(pEXTID, 1, 1) = "B" then v-txv = "01" . /* Актобе    */
             if substr(pEXTID, 1, 1) = "C" then v-txv = "02" . /* Костанай  */
             if substr(pEXTID, 1, 1) = "D" then v-txv = "03" . /* Тараз     */
             if substr(pEXTID, 1, 1) = "E" then v-txv = "04" . /* Уральск   */
             if substr(pEXTID, 1, 1) = "F" then v-txv = "05" . /* Караганда */
             if substr(pEXTID, 1, 1) = "H" then v-txv = "06" . /*  Семей*/
             if substr(pEXTID, 1, 1) = "K" then v-txv = "07" . /*  */
             if substr(pEXTID, 1, 1) = "L" then v-txv = "08" . /*  */
             if substr(pEXTID, 1, 1) = "M" then v-txv = "09" . /*  Павлодар*/
             if substr(pEXTID, 1, 1) = "N" then v-txv = "10" . /* Петропавловск */
             if substr(pEXTID, 1, 1) = "O" then v-txv = "11" . /* Атырау */
             if substr(pEXTID, 1, 1) = "P" then v-txv = "12" . /* Актау */
             if substr(pEXTID, 1, 1) = "Q" then v-txv = "13" . /* Жесказган */
             if substr(pEXTID, 1, 1) = "R" then v-txv = "14" . /* Усть каменогорск */
             if substr(pEXTID, 1, 1) = "S" then v-txv = "15" . /* Шымкент */
             find first comm.txb where comm.txb.bank = "TXB" + v-txv and comm.txb.consolid no-lock no-error.
             if connected ("txb") then disconnect "txb".
             connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
             pFromDate = 06.08.2010. pToDate = 06.08.2010.
             for each cred:
                delete cred.
             end.
             run iovyp23(pEXTID, g_date,pAccount,output rdes,output totalCount,output v-okpo,output bankName,output bankRNN,output clientCode,output clientName, output clientRNN, output sm, output sm1).
             if connected ("txb")  then disconnect "txb".
             if rdes <> '' then do:
                replyH = replyMessage.
                run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + conv(rdes) + "</error>").
                return.
             end.
             debt = 0.
             crdt = 0.
             replyH = replyMessage.
             
             define variable TstMsg as char.
             define variable BufferData as longchar.
             
            
            /*
             run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
             run appendText in replyH ("<CATALOG>").
             run appendText in replyH ("<TOTAL_COUNT>" +  trim(string(totalCount,">>>>>>>>9")) + "</TOTAL_COUNT>").
             run appendText in replyH ("<TOTAL_DEBIT>" + trim(string(debt,">>>>>>>>>>>9.99")) + "</TOTAL_DEBIT>").
             run appendText in replyH ("<TOTAL_CREDIT>" + trim(string(crdt,">>>>>>>>>>>9.99")) + "</TOTAL_CREDIT>").
             run appendText in replyH ("<INCOME>" + string(sm) + "</INCOME>").
             run appendText in replyH ("<OUTCOME>" + string(sm1) + "</OUTCOME>").
             run appendText in replyH ("<AVAILABLE_BALANCE>" + string(sm1) + "</AVAILABLE_BALANCE>").
             run appendText in replyH ("<BEGIN_DATE>" + string(g-today,"99.99.9999") + "</BEGIN_DATE>").
             run appendText in replyH ("<END_DATE>" + string(g-today,"99.99.9999") + "</END_DATE>").
             run appendText in replyH ("<REPORT_NUMBER>" + string(bankName) + "</REPORT_NUMBER>").
             run appendText in replyH ("<CLIENT_ACCOUNT>" + pAccount + "</CLIENT_ACCOUNT>").
             run appendText in replyH ("<BANK_BIC>" + pBic + "</BANK_BIC>").
             run appendText in replyH ("<BANK_OKPO>" + v-okpo + "</BANK_OKPO>").
             run appendText in replyH ("<BANK_NAME>" + bankName + "</BANK_NAME>").
             run appendText in replyH ("<BANK_IDN>" + bankRNN + "</BANK_IDN>").
             run appendText in replyH ("<CLIENT_CODE>" + clientCode + "</CLIENT_CODE>").
             run appendText in replyH ("<CREATE_DATE>" + string(today,"99.99.9999") + " " + string(time,"hh:mm:ss") + "</CREATE_DATE>").
             run appendText in replyH ("<CLIENT_NAME>" + clientName + "</CLIENT_NAME>").
             run appendText in replyH ("<CLIENT_IDN>"  + clientRNN  + "</CLIENT_IDN>").
             */
             TstMsg = "<?xml version=""1.0"" encoding=""UTF-8""?>".
             TstMsg = TstMsg + "<CATALOG>".
             TstMsg = TstMsg + "<TOTAL_COUNT>" +  trim(string(totalCount,">>>>>>>>9")) + "</TOTAL_COUNT>".
             TstMsg = TstMsg + "<TOTAL_DEBIT>" + trim(string(debt,">>>>>>>>>>>9.99")) + "</TOTAL_DEBIT>".
             TstMsg = TstMsg + "<TOTAL_CREDIT>" + trim(string(crdt,">>>>>>>>>>>9.99")) + "</TOTAL_CREDIT>".
             TstMsg = TstMsg + "<INCOME>" + string(sm,">>>>>>>>>>>9.99") + "</INCOME>".
             TstMsg = TstMsg + "<OUTCOME>" + string(sm1,">>>>>>>>>>>9.99") + "</OUTCOME>".
             TstMsg = TstMsg + "<AVAILABLE_BALANCE>" + string(sm1,">>>>>>>>>>>9.99") + "</AVAILABLE_BALANCE>".
             TstMsg = TstMsg + "<BEGIN_DATE>" + string(g-today,"99.99.9999") + "</BEGIN_DATE>".
             TstMsg = TstMsg + "<END_DATE>" + string(g-today,"99.99.9999") + "</END_DATE>".
             TstMsg = TstMsg + "<REPORT_NUMBER>" + string(bankName) + "</REPORT_NUMBER>".
             TstMsg = TstMsg + "<CLIENT_ACCOUNT>" + pAccount + "</CLIENT_ACCOUNT>".
             TstMsg = TstMsg + "<BANK_BIC>" + pBic + "</BANK_BIC>".
             TstMsg = TstMsg + "<BANK_OKPO>" + v-okpo + "</BANK_OKPO>".
             TstMsg = TstMsg + "<BANK_NAME>" + bankName + "</BANK_NAME>".
             TstMsg = TstMsg + "<BANK_IDN>" + bankRNN + "</BANK_IDN>".
             TstMsg = TstMsg + "<CLIENT_CODE>" + clientCode + "</CLIENT_CODE>".
             TstMsg = TstMsg + "<CREATE_DATE>" + string(today,"99.99.9999") + " " + string(time,"hh:mm:ss") + "</CREATE_DATE>".
             TstMsg = TstMsg + "<CLIENT_NAME>" + clientName + "</CLIENT_NAME>".
             TstMsg = TstMsg + "<CLIENT_IDN>"  + clientRNN  + "</CLIENT_IDN>".
             
             for each cred  no-lock break by cred.num :
                 /*
                run appendText in replyH ("<DOC>").
                run appendText in replyH ("<OPER_CODE>" + trim(string(cred.dt,"99.99.9999")) + "</OPER_CODE>").
                run appendText in replyH ("<OPER_DATE>" + trim(string(g-today,"99.99.9999")) + "</OPER_DATE>").
                run appendText in replyH ("<NUM_DOC>" + trim(string(decimal(cred.sumcred),">>>>>>>>>>>9.99")) + "</NUM_DOC>").
                run appendText in replyH ("<DEAL_CODE>" + trim(string(decimal(cred.sumproc),">>>>>>>>>>>9.99")) + "</DEAL_CODE>").
                run appendText in replyH ("<DEAL_TYPE></DEAL_TYPE>").
                run appendText in replyH ("<DATE_DOC>" + string(cred.num) + "</DATE_DOC>").
                run appendText in replyH ("<NAME>" + trim(string(decimal(cred.ostat),">>>>>>>>>>>9.99")) + "</NAME>").
                run appendText in replyH ("<ACCOUNT>" + trim(string(decimal(cred.plateg),">>>>>>>>>>>9.99")) + "</ACCOUNT>").
                run appendText in replyH ("<DEBIT>" + trim(string(5252.00,">>>>>>>>>>>9.99")) + "</DEBIT>").
                run appendText in replyH ("<CREDIT>" + trim(string(8858.00,">>>>>>>>>>>9.99")) + "</CREDIT>").
                run appendText in replyH ("<BANK_BIC>" + v-clecod + "</BANK_BIC>").
                run appendText in replyH ("<BANK_NAME>" + "Bankname" + "</BANK_NAME>").
                run appendText in replyH ("<PAYMENT_DETAILS></PAYMENT_DETAILS>").
                run appendText in replyH ("<CREATE_TIME>" + substr(string(time, "hh:mm:ss"), 1,2) + substr(string(time, "hh:mm:ss"), 4,2) + "</CREATE_TIME>").
                run appendText in replyH ("<CURRENCY_CODE>" + "1" + "</CURRENCY_CODE>").
                run appendText in replyH ("</DOC>").
                */
                TstMsg = TstMsg + "<DOC>".
                TstMsg = TstMsg + "<OPER_CODE>" + trim(string(cred.dt,"99.99.9999")) + "</OPER_CODE>".
                TstMsg = TstMsg + "<OPER_DATE>" + trim(string(g-today,"99.99.9999")) + "</OPER_DATE>".
                TstMsg = TstMsg + "<NUM_DOC>" + trim(string(decimal(cred.sumcred),">>>>>>>>>>>9.99")) + "</NUM_DOC>".
                TstMsg = TstMsg + "<DEAL_CODE>" + trim(string(decimal(cred.sumproc),">>>>>>>>>>>9.99")) + "</DEAL_CODE>".
                TstMsg = TstMsg + "<DEAL_TYPE></DEAL_TYPE>".
                TstMsg = TstMsg + "<DATE_DOC>" + string(cred.num) + "</DATE_DOC>".
                TstMsg = TstMsg + "<NAME>" + trim(string(decimal(cred.ostat),">>>>>>>>>>>9.99")) + "</NAME>".
                TstMsg = TstMsg + "<ACCOUNT>" + trim(string(decimal(cred.plateg),">>>>>>>>>>>9.99")) + "</ACCOUNT>".
                TstMsg = TstMsg + "<DEBIT>" + trim(string(5252.00,">>>>>>>>>>>9.99")) + "</DEBIT>".
                TstMsg = TstMsg + "<CREDIT>" + trim(string(8858.00,">>>>>>>>>>>9.99")) + "</CREDIT>".
                TstMsg = TstMsg + "<BANK_BIC>" + v-clecod + "</BANK_BIC>".
                TstMsg = TstMsg + "<BANK_NAME>" + "Bankname" + "</BANK_NAME>".
                TstMsg = TstMsg + "<PAYMENT_DETAILS></PAYMENT_DETAILS>".
                TstMsg = TstMsg + "<CREATE_TIME>" + substr(string(time, "hh:mm:ss"), 1,2) + substr(string(time, "hh:mm:ss"), 4,2) + "</CREATE_TIME>".
                TstMsg = TstMsg + "<CURRENCY_CODE>" + "1" + "</CURRENCY_CODE>".
                TstMsg = TstMsg + "</DOC>".
                message TstMsg.
                BufferData = BufferData + TstMsg.
                TstMsg = "".
             end.
             
             TstMsg = TstMsg + "</CATALOG>".
             message TstMsg.
             BufferData = BufferData + TstMsg.
             
             run setLongText in replyH( BufferData).
            /* run appendText in replyH (BufferData).*/
             /*
             run appendText in replyH ("</CATALOG>").
             */
             /*message TstMsg.*/
             return.
          end.
          /*=============================*/
          /*ГРАФИК ПОГАШЕНИЯ*/
          smd = 0.      totalCount1 = 0.
          run iovyp22(pInbound,g_date,pAccount,pFromDate,pToDate,output rdes,output totalCount,output v-okpo,output bankName,output bankRNN,output clientCode,output clientName, output clientRNN, output sm, output sm1).
          if pFromDate < 06.07.2010 then smd = sm.
          if pToDate   < 06.07.2010 then smd1 = sm1.
          totalCount1 = totalCount.
          run iovyp2(pInbound, g_date,pAccount,pFromDate,pToDate,output rdes,output totalCount,output v-okpo,output bankName,output bankRNN,output clientCode,output clientName, output clientRNN, output sm, output sm1).
          if pFromDate < 06.07.2010 then sm = smd.
          if pToDate   < 06.07.2010 then sm1 = smd1.
          totalCount = totalCount + totalCount1.
          if connected ("txb")  then disconnect "txb".
          if rdes <> '' then do:
             replyH = replyMessage.
             run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + conv(rdes) + "</error>").
             return.
          end.
          /* ДПВБЧЙМ */
          debt = 0.
          crdt = 0.
          for each t-doc no-lock:
             debt = t-doc.dam + debt.
             crdt = t-doc.cam + crdt.
          end.
          if pInbound = "true" then do:
             totalCount = 0.
             for each t-doc no-lock:
                if pInbound = "true" and t-doc.dam <> 0 then next.
                totalCount = totalCount + 1.
             end.
          end.
          clientName =  replace(clientName,"&", "&amp;").
          replyH = replyMessage.
          run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
          run appendText in replyH ("<CATALOG>").
          run appendText in replyH ("<TOTAL_COUNT>" +  trim(string(totalCount,">>>>>>>>9")) + "</TOTAL_COUNT>").
          run appendText in replyH ("<TOTAL_DEBIT>" + trim(string(debt,">>>>>>>>>>>9.99")) + "</TOTAL_DEBIT>").
          run appendText in replyH ("<TOTAL_CREDIT>" + trim(string(crdt,">>>>>>>>>>>9.99")) + "</TOTAL_CREDIT>").
          run appendText in replyH ("<INCOME>" + string(sm,">>>>>>>>>>>9.99") + "</INCOME>").
          run appendText in replyH ("<OUTCOME>" + string(sm1,">>>>>>>>>>>9.99") + "</OUTCOME>").
          run appendText in replyH ("<AVAILABLE_BALANCE>" + string(sm1,">>>>>>>>>>>9.99") + "</AVAILABLE_BALANCE>").
          run appendText in replyH ("<BEGIN_DATE>" + string(pFromDate,"99.99.9999") + "</BEGIN_DATE>").
          run appendText in replyH ("<END_DATE>" + string(pToDate,"99.99.9999") + "</END_DATE>").
          run appendText in replyH ("<REPORT_NUMBER>" + pAccount + "</REPORT_NUMBER>").
          run appendText in replyH ("<CLIENT_ACCOUNT>" + pAccount + "</CLIENT_ACCOUNT>").
          run appendText in replyH ("<BANK_BIC>" + pBic + "</BANK_BIC>").
          run appendText in replyH ("<BANK_OKPO>" + v-okpo + "</BANK_OKPO>").
          run appendText in replyH ("<BANK_NAME>" + bankName + "</BANK_NAME>").
          run appendText in replyH ("<BANK_IDN>" + bankRNN + "</BANK_IDN>").
          run appendText in replyH ("<CLIENT_CODE>" + clientCode + "</CLIENT_CODE>").
          run appendText in replyH ("<CREATE_DATE>" + string(today,"99.99.9999") + " " + string(time,"hh:mm:ss") + "</CREATE_DATE>").
          run appendText in replyH ("<CLIENT_NAME>" + clientName + "</CLIENT_NAME>").
          run appendText in replyH ("<CLIENT_IDN>"  + clientRNN  + "</CLIENT_IDN>").
          i = 0.
          for each t-docout:
              delete t-docout.
          end.
          for each t-doc no-lock:
              if pInbound = "true" and t-doc.dam <> 0 then next.  /*только входящие платежи*/
              i = i + 1.
              if i > pStart + pLimit then leave.
              if (pStart > 0) and (pLimit > 0) then do:
                  if (i < pStart) or (i >= pStart + pLimit) then next.
              end.
              create t-docout.
                 t-docout.oper_code = t-doc.oper_code.
                 t-docout.num_doc = t-doc.num_doc     .
                 t-docout.deal_type = t-doc.deal_type.
                 t-docout.deal_code = t-doc.deal_code.
                 t-docout.date_doc = t-doc.date_doc .
                 t-docout.name = t-doc.name.
                 t-docout.account = t-doc.account.
                 t-docout.dam = t-doc.dam.
                 t-docout.cam  = t-doc.cam.
                 t-docout.bank_bic = t-doc.bank_bic.
                 t-docout.bank_name = t-doc.bank_name.
                 t-docout.des = t-doc.des.
           	     t-docout.kod = t-doc.kod.
           	     t-docout.kbe = t-doc.kbe.
                 t-docout.knp = t-doc.knp.
           	     t-docout.rnn = t-doc.rnn.
                 t-docout.tim = t-doc.tim.
                 t-docout.crc = t-doc.crc.
                 t-docout.nominale = t-doc.nominale.
          end.
          if pgroupDbCr = "true" and (pSortDir = "DESC" or pSortDir = "ASC") then do:
             for each t-docout break by t-docout.cam by t-docout.dam:
                 {iovyp.i}
             end.
          end. else if pSortDir = "DESC" then do:
             if pSortField = "DATE_DOC" then
                for each t-docout break by  t-docout.date_doc DESCENDING:
                    {iovyp.i}
                end.
             if pSortField = "OPER_CODE" then
                for each t-docout break by  t-docout.oper_code DESCENDING:
                   {iovyp.i}
                end.
             if pSortField = "DEAL_CODE" then
                for each t-docout break by t-docout.deal_code DESCENDING:
                   {iovyp.i}
                end.
             if pSortField = "NUM_DOC" then
                for each t-docout break by t-docout.num_doc DESCENDING:
                    {iovyp.i}
                end.
             if pSortField = "DEBIT" then
                for each t-docout break by t-docout.dam DESCENDING:
                   {iovyp.i}
                end.
             if pSortField = "CREDIT" then
                for each t-docout break by t-docout.cam DESCENDING:
                   {iovyp.i}
                end.
             if pSortField = "ACCOUNT" then
                for each t-docout break by t-docout.account DESCENDING:
                   {iovyp.i}
                end.
             if pSortField = "PAYMENT_DETAILS" then
                for each t-docout break by t-docout.des DESCENDING:
                   {iovyp.i}
                end.
             if pSortField = "BANK_NAME" then
                for each t-docout break by t-docout.bank_name DESCENDING:
                    {iovyp.i}
                end.
             if pSortField = "NAME" then
                for each t-docout break by t-docout.name DESCENDING:
                   {iovyp.i}
                end.
          end. else if pSortDir = "ASC" then do:
             if pSortField = "DATE_DOC" then
                 for each t-docout break by  t-docout.date_doc :
                     {iovyp.i}
                 end.
             if pSortField = "OPER_CODE" then
                 for each t-docout break by  t-docout.oper_code :
                     {iovyp.i}
                 end.
             if pSortField = "DEAL_CODE" then
                 for each t-docout break by t-docout.deal_code :
                     {iovyp.i}
                 end.
             if pSortField = "NUM_DOC" then
                 for each t-docout break by t-docout.num_doc :
                     {iovyp.i}
                 end.
             if pSortField = "DEBIT" then
                 for each t-docout break by t-docout.dam :
                     {iovyp.i}
                 end.
             if pSortField = "CREDIT" then
                 for each t-docout break by t-docout.cam :
                     {iovyp.i}
                 end.
             if pSortField = "ACCOUNT" then
                 for each t-docout break by t-docout.account :
                     {iovyp.i}
                 end.
             if pSortField = "PAYMENT_DETAILS" then
                 for each t-docout break by t-docout.des :
                     {iovyp.i}
                 end.
             if pSortField = "BANK_NAME" then
                 for each t-docout break by t-docout.bank_name :
                     {iovyp.i}
                 end.
             if pSortField = "NAME" then
                 for each t-docout break by t-docout.name :
                     {iovyp.i}
                 end.
          end. else do:
             for each t-docout:
                 delete t-docout.
             end.
             i = 0.
             for each t-doc no-lock:
                if pInbound = "true" and t-doc.dam <> 0 then next.  /*только входящие платежи*/
                if pInbound = "true" and t-doc.cam <> 0 and not t-doc.deal_code begins "RMZ"  then next.  /*только входящие RMZ*/
                i = i + 1.
                create t-docout.
                   t-docout.oper_code = t-doc.oper_code.
                   t-docout.num_doc = t-doc.num_doc     .
                   t-docout.deal_type = t-doc.deal_type.
                   t-docout.deal_code = t-doc.deal_code.
                   t-docout.date_doc = t-doc.date_doc.
                   t-docout.name = t-doc.name.
                   t-docout.account = t-doc.account.
                   t-docout.dam = t-doc.dam.
                   t-docout.cam  = t-doc.cam.
                   t-docout.bank_bic = t-doc.bank_bic.
                   t-docout.bank_name = t-doc.bank_name.
                   t-docout.des = t-doc.des.
                   t-docout.tim = t-doc.tim.
	               t-docout.kod = t-doc.kod.
	               t-docout.kbe = t-doc.kbe.
                   t-docout.knp = t-doc.knp.
           	       t-docout.rnn = t-doc.rnn.
                   t-docout.crc = t-doc.crc.
                   t-docout.nominale = t-doc.nominale.
             end.
             if pgroupDbCr = "true"  then do:
                for each t-docout break by t-docout.cam by t-docout.dam:
                   {iovyp.i}
                end.
             end. else do:
                for each t-docout:
                   {iovyp.i}
                end.
             end.
          end.
          run appendText in replyH ("</CATALOG>").
          message "822.".
       end. /*balance*/
    end.
end.

function inWait returns logical.
    return not(v-terminate).
end.

procedure lonbal3.
   define input  parameter p-sub like trxbal.subled.
   define input  parameter p-acc as char.
   define input  parameter p-dt like jl.jdt.
   define input  parameter p-lvls as char.
   define input  parameter p-includetoday as logi.
   define output parameter res as decimal.
   def var i as integer.
   res = 0.
   if p-dt > g-today then p-dt = g-today. /*return.*/
   if p-includetoday then do: /* за дату */
      if p-dt = g-today then do:
         for each trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc no-lock:
             if lookup(string(trxbal.level), p-lvls) > 0 then do:
                find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
                if not avail b-aaa then return.
      	        find trxlevgl where trxlevgl.gl eq b-aaa.gl and trxlevgl.subled eq p-sub and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
                if not avail trxlevgl then return.
   	            find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	            if not avail gl then return.
         	    if gl.type eq "A" or gl.type eq "E" then res = res + trxbal.dam - trxbal.cam. else res = res + trxbal.cam - trxbal.dam.
   	            find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic" and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	            if available sub-cod and sub-cod.ccode eq "01" then res = - res.
  	            /* ------------------------------------------------------------ */
	            for each jl where jl.acc = p-acc and jl.jdt >= p-dt and jl.lev = 1 no-lock:
                    if gl.type eq "A" or gl.type eq "E" then res = res - jl.dam + jl.cam. else res = res + jl.dam - jl.cam.
                end.
             end.
         end.
      end. else do:
         do i = 1 to num-entries(p-lvls):
            find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls)) and histrxbal.dt <= p-dt no-lock no-error.
            if avail histrxbal then do:
               find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
               if not avail b-aaa then return.
               find trxlevgl where trxlevgl.gl eq b-aaa.gl and trxlevgl.subled eq p-sub and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
               if not avail trxlevgl then return.
 	           find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	           if not avail gl then return.
 	           if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam. else res = res + histrxbal.cam - histrxbal.dam.
 	           find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic" and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	           if available sub-cod and sub-cod.ccode eq "01" then res = - res.
            end.
         end.
      end.
   end. else do: /* на дату */
      do i = 1 to num-entries(p-lvls):
         find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls)) and histrxbal.dt < p-dt no-lock no-error.
         if avail histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.
      	    find trxlevgl where trxlevgl.gl eq b-aaa.gl and trxlevgl.subled eq p-sub and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.
     	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	        if not avail gl then return.
     	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam. else res = res + histrxbal.cam - histrxbal.dam.
     	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic" and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	        if available sub-cod and sub-cod.ccode eq "01" then res = - res.
         end.
      end.
   end.
end.



