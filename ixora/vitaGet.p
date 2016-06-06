/* kfmAMLOnline.p
 * MODULE
        Внутрибанковские операции
 * DESCRIPTION
        Запрос к сервису Vitamin
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
        02/08/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        29/08/2012 madiyar - при большом количестве операций не хватало емкости типа char, отправляем в несколько порций по 100 операций
        31/08/2012 madiyar - тестовый/боевой сервер
*/

{srvcheck.i}

/*
def input parameter p-year as integer no-undo.
def input parameter p-month as integer no-undo.
def input parameter p-type as integer no-undo. /* вид запроса: 1 - МЖР, 2 - ОКН */
*/
def input parameter p-type as character . /* вид запроса: READ, CLEAR */
def output parameter p-errorDes as char no-undo. /* описание ошибки, если пусто - ошибок нет */

def shared temp-table t-xml no-undo
  field num as integer
  field xml as char
  index idx is primary num.

def var v-xml as char no-undo.
def var i as integer no-undo.

def var errorCode as integer no-undo.
def var q_name as char no-undo.
q_name = "vitaQ".
/*
if p-year < 2010 then do:
    p-errorDes = "Некорректные входные данные - год (" + string(p-year) + ")".
    return.
end.

if (p-month < 1) or (p-month > 12) then do:
    p-errorDes = "Некорректные входные данные - месяц (" + string(p-month) + ")".
    return.
end.


*/


if p-type <> "READ" and p-type <> "CLEAR" then do:
    p-errorDes = "Некорректные входные данные - вид запроса (" + p-type + ")".
    return.
end.

def var ptpsession as handle.
def var consumerh as handle.
def var requesth as handle.

def var v-txt as char.

def var v-out as integer no-undo.
v-out = 0.

/* creates a session object. */
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginsession in ptpsession no-error.
if error-status:error then do:
    p-errorDes = "Ошибка соединения с сервисом!".
    return.
end.

/* create a message */
run createtextmessage in ptpsession (output requesth) no-error.
if error-status:error then do:
    run deletesession in ptpsession no-error.
    p-errorDes = "Ошибка инициализации сообщения!".
    return.
end.

/* creates a consumer for the reply  */
run createmessageconsumer in ptpsession (
    this-procedure, /* this proc will handle it */
    "replyhandler", /* name of internal procedure */
    output consumerh) no-error.
if error-status:error then do:
    run deletemessage in requesth no-error.
    run deletesession in ptpsession no-error.
    p-errorDes = "Ошибка инициализации получателя!".
    return.
end.

/* start receiving replies */
run startreceivemessages in ptpsession no-error.
if error-status:error then do:
    run deleteConsumer in ptpsession no-error.
    run deletemessage in requesth no-error.
    run deletesession in ptpsession no-error.
    p-errorDes = "Ошибка инициализации получателя!".
    return.
end.

/* fill the outgoing message */
errorCode = 0.
/*run settext in requesth (string(p-year) + "_" + string(p-month) + "_" + string(p-type)) no-error.*/
/*if error-status:error then errorCode = 1.
*/
if errorCode = 0 then do:
    run setStringProperty in requesth("host", "db01.metrobank.kz") no-error.
    if error-status:error then errorCode = 1.
end.
if errorCode = 0 then do:
    run setStringProperty in requesth("db", "VitaDB") no-error.
    if error-status:error then errorCode = 1.
end.
if errorCode = 0 then do:
    run setStringProperty in requesth("user", "vita_user") no-error.
    if error-status:error then errorCode = 1.
end.
if errorCode = 0 then do:
    run setStringProperty in requesth("pword", "1CtoIxora") no-error.
    if error-status:error then errorCode = 1.
end.
if errorCode = 0 then do:
    run setStringProperty in requesth("RepType", p-type) no-error.
    if error-status:error then errorCode = 1.
end.
/*
if errorCode = 0 then do:
    run setIntProperty in requesth("year", p-year) no-error.
    if error-status:error then errorCode = 1.
end.
*/
/*
if errorCode = 0 then do:
    run setIntProperty in requesth("month", p-month) no-error.
    if error-status:error then errorCode = 1.
end.
*/
/*
if errorCode = 0 then do:
    run setIntProperty in requesth("type", p-type) no-error.
    if error-status:error then errorCode = 1.
end.
*/

if errorCode > 0 then do:
    run deleteConsumer in ptpsession no-error.
    run deletemessage in requesth no-error.
    run deletesession in ptpsession no-error.
    p-errorDes = "Ошибка заполнения сообщения!".
    return.
end.

/* send a request to the requestqueue and handle the reply in the replyhandler internal procedure. */
run requestreply in ptpsession ( q_name,
                                 requesth,
                                 ?, /* no reply selector */
                                 consumerh,
                                 ?, /* priority */
                                 120000, /* Time to Live, milliseconds */
                                 "NON_PERSISTENT" /* Persistency = off, i.e. messages are not available after broker restart */
                                 ) no-error.
if error-status:error then do:
    run deleteConsumer in ptpsession no-error.
    run deletemessage in requesth no-error.
    run deletesession in ptpsession no-error.
    p-errorDes = "Ошибка отправки запроса!".
    return.
end.

run deletemessage in requesth no-error.

/* wait for the reply. */
wait-for u1 of this-procedure.

run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deleteSession in ptpsession no-error.


procedure replyhandler:
    define input parameter replyh as handle.
    define input parameter msgconsumerh as handle.
    define output parameter responseh as handle.

    def var v-reply as char no-undo.
    def var pNames as char no-undo.

    /* get the reply from the service */
    v-reply = dynamic-function('gettext':u in replyh).

    errorCode = 0.

    if num-entries(v-reply,"=") = 2 then do:
        errorCode = integer(entry(2,v-reply,'=')) no-error.
        if error-status:error then do:
            errorCode = 101.
            p-errorDes = "(" + string(errorCode) + ") Некорректный формат ответа".
        end.
        else do:
            pNames = dynamic-function('getPropertyNames':u in replyh).
            if errorCode = 0 and p-type = "READ" then do:
                if lookup("xml",pNames) > 0 then do:
                    v-xml = dynamic-function('getCharProperty':u in replyh, "xml").
                    v-xml = trim(v-xml).
                    if v-xml = '' then do:
                        errorCode = 103.
                        p-errorDes = "(" + string(errorCode) + ") Пустой ответ".
                    end.
                    else do:
                        create t-xml.
                        t-xml.num = 0.
                        t-xml.xml = v-xml.
                        i = 1.
                        repeat:
                            if lookup("xml" + string(i),pNames) > 0 then do:
                                v-xml = dynamic-function('getCharProperty':u in replyh, "xml" + string(i)).
                                v-xml = trim(v-xml).
                                if v-xml <> '' then do:
                                    create t-xml.
                                    t-xml.num = i.
                                    t-xml.xml = v-xml.
                                end.
                                i = i + 1.
                            end.
                            else leave.
                        end.
                    end.
                end.
                else do:
                    errorCode = 104.
                    p-errorDes = "(" + string(errorCode) + ") Не найден xml-документ в ответе".
                end.
            end.
            else do:
                if lookup("errordes",pNames) > 0 then p-errorDes = dynamic-function('getCharProperty':u in replyh, "errordes").
                else p-errorDes = "(" + string(errorCode) + ") Некорректный формат ответа - нет описания ошибки".
            end.
        end.
    end.
    else do:
        errorCode = 102.
        p-errorDes = "(" + string(errorCode) + ") Некорректный формат ответа".
    end.

    run deletemessage in replyh no-error.


    apply "u1" to this-procedure.
end.


