/* findarp.p
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
        28/10/2013 galina  - ТЗ 1891 поиск ARP-счета
 * BASES
        BANK COMM
 * CHANGES

*/

def input parameter i-aaa like aaa.aaa no-undo.
def input parameter i-banks as char no-undo.
def output parameter o-isfindaaa as logical no-undo.
def output parameter o-sta like aaa.sta no-undo.
def output parameter o-bin     as char no-undo.
def output parameter o-cifname as char no-undo.


def var v-isfindaaa as logical .
def var v-sta like aaa.sta .
def var vbin as char .
def var v-cifname as char.
def var v-lgr as char.

def var v-path as char no-undo.



find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
else v-path = '/data/b'.

v-isfindaaa = false.
for each comm.txb where comm.txb.consolid = true no-lock:
  if lookup(comm.txb.bank,i-banks) > 0 then do:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run  findarp1(i-aaa, output v-isfindaaa, output v-sta, output vbin, output v-cifname).
    if v-isfindaaa then do:
       o-sta     = v-sta.
       o-cifname = v-cifname.
       leave.
    end.
  end.
end.
o-isfindaaa = v-isfindaaa.
o-bin = vbin.
if connected ("txb") then disconnect "txb".





