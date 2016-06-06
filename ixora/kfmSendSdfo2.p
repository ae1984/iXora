/* kfmSendSdfo2.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Отправка сформированного сообщения в sonic
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
 * AUTHOR
        30/03/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        03/04/2010 madiyar - изменил параметры коннекта к брокеру в связи с переносом esb-сервиса на develop
        03/04/2010 madiyar - изменения в связи с переносом базы на db01
        09/07/2010 madiyar - используем боевой sonic
        06/08/2010 madiyar - перешли на transferVersionId=2
        24/09/2013 yerganat - перешли на transferVersionId=3
*/

{global.i}
{srvcheck.i}

def input parameter p-msg as char no-undo.
def output parameter p-opErr as logi no-undo.
def output parameter p-opErrDes as char no-undo.

function strToDigits returns char (input str as char).
    def var res as char no-undo.
    def var i as integer no-undo.
    res = ''.
    do i = 1 to length(str):
        if index("0123456789",substring(str,i,1)) > 0 then res = res + substring(str,i,1).
    end.
    if res = '' then res = '0'.
    return res.
end function.

def var q_name as char no-undo.
q_name = "kfm_q".

def var ptpsession as handle.
def var messageh as handle.
def var v-i as integer no-undo.
def var v-d as date no-undo.
def var v-r as deci no-undo.
def var v-l as logi no-undo.
def var v-stop as logi no-undo.

p-opErr = yes.
p-opErrDes = "Неизвестная ошибка".

def shared temp-table t-msgParam no-undo
  field paramType as char
  field paramName as char
  field paramValue as char.

def var database_name as char no-undo.

if p-msg = '' then do:
    p-opErrDes = "Отсутствует информация по участникам операции".
    return.
end.

/* creates a session object. */
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then do:
    run setbrokerurl in ptpsession ("172.16.1.22:2507").
    database_name = "sdfo".
end.
else do:
    run setbrokerurl in ptpsession ("172.16.1.12:2507").
    database_name = "sdfotest".
end.

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginsession in ptpsession.

/* create a message */
run createtextmessage in ptpsession (output messageh).

/* build request string */
run settext in messageh (p-msg).

/* add connection parameters */

run setStringProperty in messageh("oracleHost", "db01.metrobank.kz").
run setStringProperty in messageh("oracleDb", database_name).
run setStringProperty in messageh("oracleUser", "kfm").
run setStringProperty in messageh("oraclePassword", "qwe").
run setIntProperty in messageh("transferVersionId", 3).

/*
run setStringProperty in messageh("oracleHost", "10.0.2.1").
run setStringProperty in messageh("oracleDb", "sdfo").
run setStringProperty in messageh("oracleUser", "kfm").
run setStringProperty in messageh("oraclePassword", "qwe").
run setIntProperty in messageh("transferVersionId", 1).
*/

/* add parameters */
p-opErrDes = ''.
v-stop = no.
for each t-msgParam no-lock:
    case t-msgParam.paramType:
        when 'c' then run setStringProperty  in messageh(t-msgParam.paramName, t-msgParam.paramValue).
        when 'd' then do:
            v-d = date(t-msgParam.paramValue) no-error.
            v-stop = error-status:error.
            if not v-stop then do:
                if t-msgParam.paramName = "poper_trans_date" then run setStringProperty in messageh(t-msgParam.paramName, t-msgParam.paramValue).
                else run setStringProperty in messageh(t-msgParam.paramName, string(v-d,"99/99/9999")).
            end.
        end.
        when 'i' then do:
            v-i = integer(t-msgParam.paramValue) no-error.
            v-stop = error-status:error.
            if not v-stop then run setIntProperty in messageh(t-msgParam.paramName, v-i).
        end.
        when 'l' then do:
/* ! */     v-l = logical(t-msgParam.paramValue) no-error.
            v-stop = error-status:error.
            if not v-stop then run setBooleanProperty in messageh(t-msgParam.paramName, v-l).
        end.
        when 'r' then do:
/* ! */     v-r = decimal(t-msgParam.paramValue) no-error.
            v-stop = error-status:error.
            if not v-stop then run setStringProperty in messageh(t-msgParam.paramName, t-msgParam.paramValue).
            else do:
                run setStringProperty in messageh(t-msgParam.paramName, strToDigits(t-msgParam.paramValue)).
                v-stop = no.
            end.
        end.
    end case.
    if v-stop then do:
        p-opErrDes = "Ошибка конвертации, name=" + t-msgParam.paramName + " type=" + t-msgParam.paramType + " value=" + t-msgParam.paramValue.
        leave.
    end.
end.

if p-opErrDes <> '' then do:
    run deletemessage in messageh.
    run deletesession in ptpsession.
    return.
end.

/* send a message to a queue */
run sendtoqueue in ptpsession (q_name, messageh, ?, ?, ?).

run deletemessage in messageh.
run deletesession in ptpsession.

p-opErr = no.
p-opErrDes = ''.

