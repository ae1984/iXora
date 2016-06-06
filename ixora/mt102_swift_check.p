/*
 * MODULE
        Проверка формата МТ102
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
        12.12.2012 e.berdibekov
 * BASES
        BANK COMM
 * CHANGES
        24/01/2013 madiyar - учетка SonicClient
        23.04.2013 evseev tz-1720
        14.05.2013 yerganat tz-1740, ошибка с типом ERROR_ACC, отправка id офицера для логирования
        27.08.2012 yerganat - tz2054, добавил передачу md5 digest для логирования
*/

{srvcheck.i}

define input parameter mt102 as longchar.
define input parameter doc_type as char.
define input parameter mt5_digest_of_mt102 as longchar.
define output parameter r-code as integer init 3.
define output parameter r-des as char init 'Ошибка проверки через интеграционный сервис'.

define variable q_name         as character init "swift_check_queue".

define variable ptpsession     as handle.
define variable requestMessage as handle.
define variable replyMessage   as handle.
define variable p-out          as character.

define shared variable g-ofc    like ofc.ofc.

/*def stream str41.
def var v-strs as char no-undo.
*/


run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginsession in ptpsession.


run createxmlmessage in ptpsession (output requestMessage).
run createmessageconsumer in ptpsession (this-procedure, "replyhandler", output replyMessage).
run startReceiveMessages in ptpsession.

run setStringProperty in requestMessage("DOC_TYPE", doc_type).
run setStringProperty in requestMessage("ID_OFC", g-ofc).
run setStringProperty in requestMessage("MD5_DIGEST", mt5_digest_of_mt102).

/*run setStringProperty in requestMessage("SWIFT_MT102", mt102).
*/
/*run appendText in requestMessage (mt102 ).*/
/*
input stream str41 from "swift.txt".
repeat:
	import stream str41 unformatted v-strs.
	run appendText in requestMessage (v-strs + '\n' ).
end.
input stream str41 close.
*/
run setLongText in requestMessage( mt102).


run requestreply in ptpsession ( q_name,
    requestMessage,
    ?, /* no reply selector */
    replyMessage,
    ?, /* priority */
    35000, /* Time to Live, milliseconds */
    "NON_PERSISTENT" /* Persistency = off, i.e. messages are not available after broker restart */
    ).

run deletemessage in requestMessage.
wait-for u1 of this-procedure.
run stopReceiveMessages in ptpsession.
run deleteConsumer in ptpsession no-error.
run deleteSession in ptpsession.



/***********************************************************************************/
procedure replyhandler:
    define input parameter replyh as handle.
    define input parameter msgconsumerh as handle.
    define output parameter responseh as handle.

    def var sonicResult as char init ''.
    def var sonicText as char init ''.

    sonicText = dynamic-function('gettext':u in replyh).
    sonicResult = DYNAMIC-FUNCTION('getCharProperty':U IN replyh, "REZULT").

    if sonicResult = 'OK' then r-code = 0.
    else r-code = 1.
    if sonicResult = 'ERROR_ACC' then r-code = 2.

    r-des = sonicText.

    run deletemessage in replyh.
    apply "u1" to this-procedure.
end.
/***********************************************************************************/