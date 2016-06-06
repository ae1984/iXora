/* ap_send.p
 * MODULE
        Коммунальные платежи - Авангард-Плат
 * DESCRIPTION
        Отправка запросов в Авангард-Плат
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
        13/10/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        22/12/2010 madiyar - убираем непонятный символ "?" в начале строки ответа, если он там есть
        13/09/2012 madiyar - ptpsession -> jmssession
*/

{global.i}
{apterm.i}
{srvcheck.i}

def input parameter p-prot as char no-undo.
def input parameter p-encrypt as logi no-undo.
def input parameter p-message_in as char no-undo.
def output parameter p-message_out as char no-undo.

if lookup(p-prot,"http,tcp") = 0 then return.

def var q_name as char no-undo.
if p-prot = "http" then q_name = "ap_request_q".
if p-prot = "tcp" then q_name = "ap_entry_q".

def var v-termId as integer no-undo.
def var v-userId as integer no-undo.
def var v-pass as char no-undo.

def var ptpsession as handle.
def var consumerh as handle.
def var requesth as handle.

run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginsession in ptpsession.

/* create a message */
run createxmlmessage in ptpsession (output requesth).

/* creates a consumer for the reply  */
run createmessageconsumer in ptpsession (
                              this-procedure, /* this proc will handle it */
                             "replyhandler", /* name of internal procedure */
                              output consumerh).

/* start receiving replies */
run startreceivemessages in ptpsession.

/* build request string */
run settext in requesth (p-message_in).

/* add parameters */
if p-prot = "tcp" then do:
    if p-encrypt then run setBooleanProperty in requesth ("encrypt",p-encrypt).
    /*
    run setStringProperty in requesth ("termId","54").
    run setStringProperty in requesth ("userId","97").
    run setStringProperty in requesth ("password","eae27d77ca").

    run setStringProperty in requesth ("termId","68").
    run setStringProperty in requesth ("userId","126").
    run setStringProperty in requesth ("password","36660e5985").
    */

    run setStringProperty in requesth ("termId",string(getTermId("aptcp"))).
    run setStringProperty in requesth ("userId",string(getUserId("aptcp"))).
    run setStringProperty in requesth ("password",getPass("aptcp")).
end.

/* sends a request to the requestqueue and handles the reply in the replyhandler internal procedure. */
run requestreply in ptpsession ( q_name,
                                 requesth,
                                 ?, /* no reply selector */
                                 consumerh,
                                 ?, /* priority */
                                 35000, /* Time to Live, milliseconds */
                                 "NON_PERSISTENT" /* Persistency = off, i.e. messages are not available after broker restart */
                                 ).

run deletemessage in requesth.

/* wait for the reply. */
wait-for u1 of this-procedure.

run stopReceiveMessages in ptpsession.
run deleteSession in ptpsession.


procedure replyhandler:
    define input parameter replyh as handle.
    define input parameter msgconsumerh as handle.
    define output parameter responseh as handle.

    def var v-reply as char no-undo.

    /* get the reply from the service */
    p-message_out = dynamic-function('gettext':u in replyh).
    if p-message_out begins "?" then p-message_out = substring(p-message_out,2).

    run deletemessage in replyh.

    apply "u1" to this-procedure.
end.


