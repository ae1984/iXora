/* delaasofins.p
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
        12/05/2011 evseev  - удаление из aas с занесением в aas-hist отзывов РПРО
 * BASES
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


def input parameter i-ref like insin.ref no-undo.

def var v-path as char no-undo.

find first insin where insin.ref eq i-ref no-lock no-error.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
else v-path = '/data/b'.

for each comm.txb where comm.txb.consolid = true no-lock:
   if lookup(comm.txb.bank,insin.bank1) > 0 then do:
      if connected ("txb") then disconnect "txb".
      connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
      run  delaasofins1 (i-ref).
   end.
end.
if connected ("txb") then disconnect "txb".


