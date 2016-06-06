/* card_application.p
 * MODULE
        Зарплатные карточки
 * DESCRIPTION
        Описание
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
        --/--/2013 zhassulan
 * BASES
        BANK COMM
 * CHANGES
        21.05.2013 zhassulan - ТЗ № 1788.
*/

{srvcheck.i}

define variable ptpsession as handle.
define variable consumerH as handle.
define variable replyMessage as handle.
define variable v-terminate as log no-undo.
v-terminate = no.

run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").

run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').
run beginSession in ptpsession.
run createXMLMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (THIS-PROCEDURE,"requestHandler",output consumerH).
run receiveFromQueue in ptpsession ("CARDS", ?, consumerH).
run startReceiveMessages in ptpsession.
run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).
message "Завершение работы".
run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deletesession in ptpsession no-error.

/****************************************************************************************************************/
procedure requestHandler:
    message "Start processing the request...".

    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    def var pknumber as inte no-undo.  /*номер кредитной анкеты*/
    def var msgText  as char no-undo.
    def var params   as char no-undo.
    def var pType    as char no-undo.
    def var pIdn     as char no-undo.  /*ИИН сотрудника*/

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:
        message "Bad request".
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:

        params = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).
        if lookup("TYPE",params) > 0 then pType = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "TYPE").
        if lookup("IDN",params) > 0 then pIdn = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "IDN").

        message "*****************************************************".
        message string(today,"99/99/9999").
        message string(time,"HH:MM:SS").
        message string(params).
        message "*****************************************************".
        message "           TYPE = " string(pType).
        message "           IDN = " string(pIdn).
        message "*****************************************************".

        run deleteMessage in requestH.

        if pType = "CFNUMBER" then do:
           message "Valid type request".

           find last comm.pkanketa where comm.pkanketa.rnn = pIdn and comm.pkanketa.credtype = '4' no-lock no-error.
           if avail comm.pkanketa then do:
              message "Row for this idn in the table pkanketa was found.".

              pknumber = comm.pkanketa.ln.
              if pknumber > 0 then do:
                 message "Correct cfnumber. Starting create response...".

                 replyH = replyMessage.
                 run setText in replyH (pknumber).

                 message "Response was created.".
              end.

           end.

        end.

    end.

    message "End processing the request.".
end.
/****************************************************************************************************************/
function inWait returns logical.
    return not(v-terminate).
end.
/****************************************************************************************************************/