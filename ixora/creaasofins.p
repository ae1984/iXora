/* creaasofins.p
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
        12/05/2011 evseev  - добавление в aas с занесением в aas-hist
 * BASES
        BANK COMM
 * CHANGES
        15/03/2012 id00810 - название банка из sysc
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


def input parameter i-ref like insin.ref no-undo.
def input parameter i-aaa like aaa.aaa no-undo.
def input parameter i-bank as char no-undo.
def input parameter i-regno like ofc.regno no-undo.

def var v-path as char no-undo.

find first insin where insin.ref eq i-ref no-lock no-error.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

/*find first bank.sysc where bank.sysc.sysc = 'bankname' no-lock no-error.
if avail bank.sysc and bank.cmp.name matches ("*" + bank.sysc.chval + "*")  then v-path = '/data/b'.
else v-path = '/data/'.*/
if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
else v-path = '/data/b'.

find first comm.txb where comm.txb.consolid = true and comm.txb.bank = i-bank no-lock no-error.
if avail comm.txb then do:
      if connected ("txb") then disconnect "txb".
      connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
      run  creaasofins1 (i-ref, i-aaa, i-regno).
end.
if connected ("txb") then disconnect "txb".


