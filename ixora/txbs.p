/* .p
 * MODULE
        Программа общего назначения
 * DESCRIPTION
        Запуск определенной программы (p-proc) на всех филиалах
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
        04/06/2008 madiyar
 * BASES
        BANK COMM
 * CHANGES
        15/03/2012 id00810 - название банка из sysc
        25/04/2012 evseev  - rebranding. разбранчевка с учетом банк-мко.
        27/04/2012 evseev  - повтор
*/

def input parameter p-proc as char no-undo.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

def var v-path as char no-undo.

if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.


{sel-filial.i}


for each comm.txb where comm.txb.consolid and
         (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run value(p-proc).
end.

if connected ("txb")  then disconnect "txb".




