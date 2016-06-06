/* SMS_ib.p
 * MODULE
        Соник-процессы
 * DESCRIPTION
        Соник-сервис для отправки СМС-сообщений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30/04/2013 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        14/05/2013 madiyar - поменял очередь на SMS
*/

{global.i}
{srvcheck.i}
{xmlParser.i}

define variable ptpsession   as handle.
define variable consumerH    as handle.
define variable replyMessage as handle.
define variable v-terminate  as log    no-undo.
v-terminate = no.


run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").

if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").

run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').
run beginSession in ptpsession.

run createXMLMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (THIS-PROCEDURE,"requestHandler",output consumerH).

run receiveFromQueue in ptpsession ("SMS", ?, consumerH).
run startReceiveMessages in ptpsession.


run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).
message "Завершение работы".
run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deletesession in ptpsession no-error.

/****************************************************************************************************************/
procedure requestHandler:
    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    define variable msgText as character  no-undo.
    define variable pData as character  no-undo.
    define variable pType  as character  no-undo.
    define variable pClient  as character  no-undo.
    define variable pNumber as character no-undo.
    define variable pMessage as character no-undo.

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).


    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then
    do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else
    do:



        pData = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).
        if lookup("Type",pData)  > 0 then pType      = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Type").
        if lookup("Client",pData)  > 0 then pClient      = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Client").
        if lookup("Number",pData)  > 0 then pNumber      = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Number").
        if lookup("Message",pData)  > 0 then pMessage      = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Message").


      /*
       pData = GetParamValueOne(msgText,"Data").
       pType = GetParamValueOne(pData,"Type").
       pClient = GetParamValueOne(pData,"Client").
       pNumber = GetParamValueOne(pData,"Number").
       pMessage = GetParamValueOne(pData,"Message").
      */

       run savelog( "SMS_ib", " Type = " + pType + ", Client = " + pClient + ", Number = " + pNumber + ", Message = " + pMessage).
       if pType <> "" and pClient <> "" and pNumber <> "" and pMessage <> "" then
       do:
        create ib_sms.
           ib_sms.bank  = pType.
           ib_sms.id  = next-value(smsib).
           ib_sms.tell = pNumber.
           ib_sms.pdate = today.
           ib_sms.ptime = time.
           ib_sms.pwho = g-ofc.
           ib_sms.state = 2.
           ib_sms.cif = pClient.
           ib_sms.mess = pMessage.
        end.
        run smsibsend.

        run deleteMessage in requestH.
    end.
end.
/****************************************************************************************************************/
function inWait returns logical.
    return not(v-terminate).
end.
/****************************************************************************************************************/


