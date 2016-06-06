/* ap_trxsts.p
 * MODULE
        Платежи - Авангард-Плат
 * DESCRIPTION
        Программа для проверки статуса проведенного ранее платежа
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
        10.04.2013 damir - Внедрено Т.З. № 1577,1571.
*/

{classes.i}
{apterm.i}

def input parameter Doc as class COMPAYDOCClass.
def output parameter p-errcode as integer no-undo init 0.
def output parameter p-errdes as char no-undo init ''.

def var trxsts as integer no-undo.
def var v-str as char no-undo.
def var dt as date no-undo.
def var tm as integer no-undo.
def var v-reply_parse_error as logi no-undo.

def var v-userId as integer no-undo.
v-userId = getUserId("aptcp").

function getErrorDes returns char (input err_code as integer).
    def var res as char no-undo.
    find first aperrlist where aperrlist.errcode = err_code no-lock no-error.
    if avail aperrlist then res = aperrlist.errdes. else res = string(err_code) + ": неизвестная ошибка".
    return res.
end function.

function getDateTime returns char.
    def var res as char no-undo.
    res = string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + replace(string(time,"hh:mm:ss"),':','').
    return res.
end function.

/*
function getStringNum returns char (input p-docnum as integer).
    def var res as char no-undo.
    res = string(p-docnum).
    if length(res) < 8 then res = fill('0',8 - length(res)) + res.
    return res.
end function.
*/

def var v-request as char no-undo.
def var v-reply as char no-undo.

/* build request string */
if Doc:prev_docno <> ? then v-request = '[rPays]' + string(Doc:prev_docno) + ',' + string(v-userId) + ';'.
else v-request = '[rPays]' + string(Doc:docno) + ',' + string(v-userId) + ';'.


v-reply = ''.
trxsts = Doc:state.

run savelog('ap','ap_trxsts->' + v-request).
run ap_send("tcp",no,v-request,output v-reply).
run savelog('ap','ap_trxsts<-' + v-reply).

hide frame f1.

if v-reply matches "mcberr*" then do:
    p-errcode = integer(entry(2,v-reply,'=')).
    p-errdes = getErrorDes(p-errcode).
    return.
end.

if v-reply = v-request then do:
    p-errcode = 9010. /* Сервис недоступен */
    p-errdes = getErrorDes(p-errcode).
    return.
end.

if v-reply matches '?*' then do:
    p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    p-errdes = '(?) ' + getErrorDes(p-errcode).
    return.
end.

if trim(v-reply) = '' then do:
    p-errcode = 9005. /* Сервис вернул пустую строку */
    p-errdes = getErrorDes(p-errcode).
    return.
end.

v-reply_parse_error = no.
if v-reply matches "[rPays]*" then do:
    if v-reply <> "[rPays]" then do: /* v-reply = "[rPays]" - платеж еще проводится, ничего не делаем */
        if num-entries(v-reply,'`') = 3 then do:
            v-str = entry(1,entry(3,v-reply,'`'),';').
            if length(v-str) = 14 then do:
                dt = ?.
                dt = date(substring(v-str,7,2) + substring(v-str,5,2) + substring(v-str,1,4)) no-error.
                tm = 0.
                tm = 3600 * integer(substring(v-str,9,2)) + 60 * integer(substring(v-str,11,2)) + integer(substring(v-str,13,2)) no-error.
                if (dt <> ?) then do:
                    if year(dt) >= 2009 then trxsts = 2. /* платеж проведен */
                    else trxsts = -1. /* платеж не проведен - ошибка */
                    if Doc:state <> trxsts then do:
                        if not(Doc:SetState(trxsts,dt,tm)) then do:
                            p-errcode = 9031. /* Ошибка проставления статуса документа */
                            p-errdes = '(?) ' + getErrorDes(p-errcode).
                        end.
                    end.
                end.
                else v-reply_parse_error = yes.
            end.
            else v-reply_parse_error = yes.
        end.
        else v-reply_parse_error = yes.
    end.
end.

if v-reply_parse_error then do:
    p-errcode = 9011. /* Ошибка обработки ответа на запрос */
    p-errdes = getErrorDes(p-errcode).
end.

