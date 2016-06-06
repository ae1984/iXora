/* qsendcom.p
 * MODULE
        Процессы для работы с Sonic
 * DESCRIPTION
        Отправка команды процессу
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
        17/07/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

def input parameter p-queue as char no-undo.
def input parameter p-command as char no-undo.
def input parameter p-login as char no-undo.
def input parameter p-pass as char no-undo.
def input parameter p-host as char no-undo.
def input parameter p-port as integer no-undo.

def var ptpsession as handle.
def var messageh as handle.

p-queue = trim(p-queue).
p-command = trim(p-command).
p-login = trim(p-login).
p-pass = trim(p-pass).

if (p-queue = '') or (p-command = '') or (p-login = '') or (p-pass = '') or (p-host = '') or (p-port < 0) then return.

run jms/ptpsession.p persistent set ptpsession ("-h " + p-host + " -s 5162 ").
run setbrokerurl in ptpsession (p-host + ":" + trim(string(p-port),">>>>>>>>>>>9")).

run setUser in ptpsession (p-login).
run setPassword in ptpsession (p-pass).

run beginsession in ptpsession no-error.
if error-status:error then return.

run createtextmessage in ptpsession (output messageh) no-error.
if error-status:error then do:
    run deletesession in ptpsession no-error.
    return.
end.

run settext in messageh ("qcommand=" + p-command) no-error.
if error-status:error then do:
    run deletemessage in messageh no-error.
    run deletesession in ptpsession no-error.
    return.
end.

run sendtoqueue in ptpsession (p-queue, messageh, ?, ?, ?) no-error.

run deletemessage in messageh no-error.
run deletesession in ptpsession no-error.

