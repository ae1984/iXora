/* findjh3.p
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
        03/10/2011  - поиск arp значения jh3
 * BASES

 * CHANGES
    15/03/2012 id00810 - название банка из sysc
*/

def input parameter i-banks as char no-undo.
def input parameter i-rmz as char no-undo.
def output parameter i-jh3 as int no-undo.

def var v-path as char no-undo.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

find first bank.sysc where bank.sysc.sysc = 'bankname' no-lock no-error.
if avail bank.sysc and bank.cmp.name matches ("*" + bank.sysc.chval + "*")  then v-path = '/data/b'.
else v-path = '/data/'.

/*if bank.cmp.name matches "*Метрокомбанк*" then v-path = '/data/b'.
else v-path = '/data/'.*/

for each comm.txb where comm.txb.consolid = true no-lock:
  if lookup(comm.txb.bank,i-banks) > 0 then do:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) .
    i-jh3 = 0.
    run  findjh31(i-rmz, output i-jh3).
  end.
end.
if connected ("txb") then disconnect "txb".



