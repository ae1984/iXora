/* r-branchSEL.i
 * MODULE
        Название модуля
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
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        26.11.2012 damir - changing copy r-branch.i.
*/

def var v-path as char no-undo.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.

for each comm.txb where comm.txb.consolid = true and lookup(trim(comm.txb.bank),trim(v_TXB)) > 0 no-lock:
    if connected ("txb") then disconnect "txb".

    if bank.cmp.name matches ("*МКО*") and
    (comm.txb.txb = 0 or comm.txb.txb = 3 or comm.txb.txb = 5 or comm.txb.txb = 7 or comm.txb.txb = 8 or comm.txb.txb = 9 or
     comm.txb.txb = 10 or comm.txb.txb = 11 or comm.txb.txb = 12 or comm.txb.txb = 13 or comm.txb.txb = 14 or comm.txb.txb = 15)
    then next.

    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run {&proc}.
end.

if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".


