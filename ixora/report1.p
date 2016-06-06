/* report1.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Автоматическая оплата суммы в удостоверяющий центр
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM IB
 * AUTHOR
       19/05/2010 id00004
 * CHANGES
       13.06.2011 id00004 оптимизация
       28.06.2011 id00004 Сделал возможность остановки процесса клавишей DEL из Менеджера процессов
*/


{global.i}
{srvcheck.i}

def buffer bwpay for wpay.
define variable v-option as char.
define variable rcod as char.
define variable rdes as char.
define variable totalCount as integer.
define variable bankName as char.
define variable bankRNN as char.
define variable ptpsession as handle.
define variable consumerH as handle.
define variable replyMessage as handle.
def var pValue as char no-undo.
def var v-terminate as logi no-undo.
v-terminate = no.

def new shared temp-table t-report1 no-undo /**/
  field num as char
  field benname as char
  field benrekv as char
  field dtplat as date
  field summa as char
  field details as char.


def new shared temp-table t-report2 no-undo /* Отчет по движению денежных средств */
  field dtplat as date
  field startBalance as char
  field transactionType as char
  field amount as char
  field transactionOrder as char
  field bankComission as char.

def new shared temp-table t-report4 no-undo /* Отчет по платежам */
  field dtplat as date
  field num as char
  field beneficiar as char
  field beneficiar_rekv as char
  field amount as char
  field payment_details as char
  field knp as char.




v-option = "0" .
rcod = "0".
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").

if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").
run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').

run beginSession in ptpsession.
run createXMLMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (
                             THIS-PROCEDURE,
                             "requestHandler",
                              output consumerH).
run receiveFromQueue in ptpsession ("REPORTS",
/*run receiveFromQueue in ptpsession ("test",   */
                                     ?,
                                     consumerH).
run startReceiveMessages in ptpsession.

run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).
message "Процесс корректно завершен".

procedure requestHandler:
    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    def var pNames as char no-undo.
    def var pAccount as char no-undo.
    def var fromDate as char no-undo.
    def var toDate as char no-undo.
    def var Knp as char no-undo.
    def var reportType as char no-undo.
    def var msgText as char no-undo.


    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:

        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:


    pNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).

    hide message no-pause.

    if lookup("account",pNames)    > 0 then pAccount   = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "account").
    if lookup("fromDate",pNames)   > 0 then fromDate   = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "fromDate").
    if lookup("toDate",pNames)     > 0 then toDate     = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "toDate").
    if lookup("Knp",pNames)        > 0 then Knp        = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Knp").
    if lookup("messageType",pNames) > 0 then reportType = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "messageType").


    replyH = replyMessage.

    run deleteMessage in requestH.

    if connected ("txb") then disconnect "txb".

    find first comm.txb where comm.txb.bank = "TXB" + substr(pAccount,19,2) and comm.txb.consolid no-lock no-error.
    if not avail comm.txb then do:
       run setText in replyH ("ERROR: Клиент не найден").
           return.
    end.
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).


    /* Отчет 1 */
    if reportType = "REPORT_KNP" then do:
       for each t-report1:
           delete t-report1.
       end.
       run report1_txb(pAccount, date(fromDate), date(toDate), Knp, output totalCount, output bankName, output bankRNN).
       replyH = replyMessage.
       run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
       run appendText in replyH ("<CATALOG>").
       run appendText in replyH ("<KNP>" + string(Knp) + "</KNP>").
       run appendText in replyH ("<TOTAL_COUNT>" + string(totalCount) + "</TOTAL_COUNT>").
       run appendText in replyH ("<BEGIN_DATE>" + string(fromDate) + "</BEGIN_DATE>").
       run appendText in replyH ("<END_DATE>" + string(toDate) + "</END_DATE>").
       run appendText in replyH ("<CLIENT_ACCOUNT>" + string(pAccount) + "</CLIENT_ACCOUNT>").
       run appendText in replyH ("<BANK_NAME>" + string(bankName) + "</BANK_NAME>").
       run appendText in replyH ("<BANK_RNN>" + string(bankRNN) + "</BANK_RNN>").

       for each t-report1  no-lock break by t-report1.dtplat :
           run appendText in replyH ("<DOC>").
           run appendText in replyH ("<PAYMENT_ORDER>"   + string(t-report1.num) + "</PAYMENT_ORDER>").
           run appendText in replyH ("<DATE>"            + string(t-report1.dtplat) + "</DATE>").
           run appendText in replyH ("<BEN_NAME>"        + string(t-report1.benname) + "</BEN_NAME>").
           run appendText in replyH ("<BEN_DETAILS>"    + string(t-report1.benrekv) + "</BEN_DETAILS>").
           run appendText in replyH ("<AMOUNT>"          + trim(string(decimal(t-report1.summa),">>>>>>>>>>>9.99"))  + "</AMOUNT>").
           run appendText in replyH ("<PAYMENT_DETAILS>" + string(t-report1.details) + "</PAYMENT_DETAILS>").
           run appendText in replyH ("</DOC>").
       end.

       run appendText in replyH ("</CATALOG>").
/*       RUN sendToQueue IN ptpsession ("test", replyH, ?, ?, ?).  */
    end.



    /* Отчет 2   (Отчет по движению денежных средств)  */
    if reportType = "REPORT_FUNDS_FLOW" then do:
       for each t-report2:
           delete t-report2.
       end.
       run report2_txb(pAccount, date(fromDate), date(toDate), g-today, output totalCount, output bankName, output bankRNN).
       replyH = replyMessage.
       run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
       run appendText in replyH ("<CATALOG>").
       run appendText in replyH ("<TOTAL_COUNT>" + string(totalCount) + "</TOTAL_COUNT>").
       run appendText in replyH ("<BEGIN_DATE>" + string(fromDate) + "</BEGIN_DATE>").
       run appendText in replyH ("<END_DATE>"  + string(toDate) + "</END_DATE>").
       run appendText in replyH ("<CLIENT_ACCOUNT>" + string(pAccount) + "</CLIENT_ACCOUNT>").
       run appendText in replyH ("<BANK_NAME>" + string(bankName) + "</BANK_NAME>").
       run appendText in replyH ("<BANK_RNN>"  + string(bankRNN) + "</BANK_RNN>").

       for each t-report2  no-lock break by t-report2.dtplat :
           run appendText in replyH ("<DOC>").
           run appendText in replyH ("<DATE>"              + string(t-report2.dtplat) + "</DATE>").

           run appendText in replyH ("<START_BALANCE>"     + trim(string(decimal(t-report2.startBalance),">>>>>>>>>>>9.99")) + "</START_BALANCE>").
           run appendText in replyH ("<TRANSACTION_TYPE>"  + string(t-report2.transactionType) + "</TRANSACTION_TYPE>").
           run appendText in replyH ("<AMOUNT>"            + trim(string(decimal(t-report2.amount),">>>>>>>>>>>9.99"))  + "</AMOUNT>").
           run appendText in replyH ("<TRANSACTION_ORDER>" + string(t-report2.transactionOrder) + "</TRANSACTION_ORDER>").
           run appendText in replyH ("<BANK_COMMISSION>"   + trim(string(decimal(t-report2.bankComission),">>>>>>>>>>>9.99")) + "</BANK_COMMISSION>").
           run appendText in replyH ("</DOC>").
       end.
       run appendText in replyH ("</CATALOG>").
/*       RUN sendToQueue IN ptpsession ("test", replyH, ?, ?, ?).  */
    end.













    /* Отчет 3   (Отчет по платежам) */
    if reportType = "REPORT_PAYMENTS" then do:
       for each t-report4:
           delete t-report4.
       end.
       run report4_txb(pAccount, date(fromDate), date(toDate), g-today, output totalCount, output bankName, output bankRNN).
       replyH = replyMessage.
       run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
       run appendText in replyH ("<CATALOG>").
       run appendText in replyH ("<TOTAL_COUNT>" + string(totalCount) + "</TOTAL_COUNT>").
       run appendText in replyH ("<BEGIN_DATE>" + string(fromDate) + "</BEGIN_DATE>").
       run appendText in replyH ("<END_DATE>"  + string(toDate) + "</END_DATE>").
       run appendText in replyH ("<CLIENT_ACCOUNT>" + string(pAccount) + "</CLIENT_ACCOUNT>").
       run appendText in replyH ("<BANK_NAME>" + string(bankName) + "</BANK_NAME>").
       run appendText in replyH ("<BANK_RNN>"  + string(bankRNN) + "</BANK_RNN>").

       for each t-report4  no-lock break by t-report4.dtplat :

        t-report4.payment_details = replace(t-report4.payment_details,"", "").
        t-report4.beneficiar_rekv = replace(t-report4.beneficiar_rekv,"", "").

           run appendText in replyH ("<DOC>").
           run appendText in replyH ("<PAYMENT_ORDER>"   + string(t-report4.num)             + "</PAYMENT_ORDER>").
           run appendText in replyH ("<DATE>"            + string(t-report4.dtplat)          + "</DATE>").
           run appendText in replyH ("<BEN_NAME><![CDATA["    + string(t-report4.beneficiar)      + "]]></BEN_NAME>").
           run appendText in replyH ("<BEN_DETAILS><![CDATA["    + string(t-report4.beneficiar_rekv) + "]]></BEN_DETAILS>").
           run appendText in replyH ("<AMOUNT>"          + trim(string(decimal(t-report4.amount),">>>>>>>>>>>9.99"))   + "</AMOUNT>").
           run appendText in replyH ("<PAYMENT_DETAILS><![CDATA[" + string(t-report4.payment_details) + "]]></PAYMENT_DETAILS>").
           run appendText in replyH ("<KNP>"             + string(t-report4.knp)             + "</KNP>").
           run appendText in replyH ("</DOC>").



       end.

       run appendText in replyH ("</CATALOG>").
/*       RUN sendToQueue IN ptpsession ("test", replyH, ?, ?, ?).  */




    end.

    /* Отчет 4   (Отчет по списанным комиссиям) */
    if reportType = "REPORT_COMMISSIONS" then do:
       for each t-report2:
           delete t-report2.
       end.
       run report3_txb(pAccount, date(fromDate), date(toDate), g-today, output totalCount, output bankName, output bankRNN).
       replyH = replyMessage.
       run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
       run appendText in replyH ("<CATALOG>").
       run appendText in replyH ("<TOTAL_COUNT>" + string(totalCount) + "</TOTAL_COUNT>").
       run appendText in replyH ("<BEGIN_DATE>" + string(fromDate) + "</BEGIN_DATE>").
       run appendText in replyH ("<END_DATE>"  + string(toDate) + "</END_DATE>").
       run appendText in replyH ("<CLIENT_ACCOUNT>" + string(pAccount) + "</CLIENT_ACCOUNT>").
       run appendText in replyH ("<BANK_NAME>" + string(bankName) + "</BANK_NAME>").
       run appendText in replyH ("<BANK_RNN>"  + string(bankRNN) + "</BANK_RNN>").

       for each t-report2  no-lock break by t-report2.dtplat :
           run appendText in replyH ("<DOC>").
           run appendText in replyH ("<DATE>"              + string(t-report2.dtplat) + "</DATE>").
           run appendText in replyH ("<AMOUNT>"            + trim(string(decimal(t-report2.amount),">>>>>>>>>>>9.99")) + "</AMOUNT>").
           run appendText in replyH ("<PAYMENT_ORDER>" + string(t-report2.transactionOrder) + "</PAYMENT_ORDER>").
           run appendText in replyH ("<COMMISSION_DETAILS>"   + string(t-report2.transactionType) + "</COMMISSION_DETAILS>").
           run appendText in replyH ("</DOC>").
       end.

       run appendText in replyH ("</CATALOG>").
/*       RUN sendToQueue IN ptpsession ("test", replyH, ?, ?, ?).  */
    end.
  end.
end.


function inWait returns logical.
    return not(v-terminate).
end.
