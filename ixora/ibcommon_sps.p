/* ibfirm_sps.p
 * MODULE
        Процесс общей очереди для Интернет Банкинга-Фирма
 * DESCRIPTION
        Описание программы
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
        16.07.2013 yerganat
 * BASES
        COMM
 * CHANGES
        30.09.2013 - yerganat tz2040 добавил FIOBYIIN.i
*/

{srvcheck.i}

define variable v-type         as char.
define variable msgText        as char.

define variable q_name         as character init "COMMON".

define variable ptpsession     as handle.
define variable consumerH      as handle.
define variable replyMessage   as handle.

define variable v-terminate    as logical.

define variable r-des          as char.
define variable r-code         as char.


v-terminate = no.

run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").

if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").


run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginSession in ptpsession.
run createTextMessage IN ptpsession (OUTPUT replyMessage).
run createMessageConsumer in ptpsession (this-procedure, "replyhandler", output consumerH).
run receiveFromQueue in ptpsession (q_name, ?, consumerH).
run startReceiveMessages in ptpsession.
run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).

message "Процесс корректно завершен".

run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deleteSession in ptpsession no-error.


/*******************************/
function inWait returns logical.
    return not(v-terminate).
end.
/*******************************/


/***********************************************************************************/
procedure replyhandler:
    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.
    replyH = replyMessage.
    r-des=''.
    r-code='0'.


    v-type = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "TYPE").


    if v-type = 'vincheck' then do:
     {vincheck_sps.i}
    end.
    if v-type = 'FIOBYIIN' then do:
     {fiobyiin.i}
    end.


end procedure.
/***********************************************************************************/
