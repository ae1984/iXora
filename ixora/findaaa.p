/* findaaa.p
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
        06/05/2011 evseev  - поиск счета
 * BASES
        BANK COMM
 * CHANGES
        16/05/2011 evseev  - удалил no-undo из шареных переменных
        15.03.2012 id00810 - название банка из sysc
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        05.10.2012 evseev - ТЗ-797
        13.03.2013 evseev - tz-1633
*/

def input parameter i-aaa like aaa.aaa no-undo.
def input parameter i-banks as char no-undo.
def output parameter o-bank as char no-undo.
def output parameter o-isfindaaa as logical no-undo.
def output parameter o-sta like aaa.sta no-undo.
def output parameter o-bin     as char no-undo.
def output parameter o-cifname as char no-undo.
def output parameter o-lgr as char no-undo.

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

/*find first bank.sysc where bank.sysc.sysc = 'bankname' no-lock no-error.
    if avail bank.sysc and bank.cmp.name matches ("*" + bank.sysc.chval + "*")  then v-path = '/data/b'.
    else v-path = '/data/'.*/
if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
else v-path = '/data/b'.

v-isfindaaa = false.
for each comm.txb where comm.txb.consolid = true no-lock:
  if lookup(comm.txb.bank,i-banks) > 0 then do:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run  findaaa1(i-aaa, output v-isfindaaa, output v-sta, output vbin, output v-cifname, output v-lgr ).
    if v-isfindaaa then do:
       o-bank    = comm.txb.bank.
       o-sta     = v-sta.
       o-bin     = vbin    .
       o-cifname = v-cifname.
       o-lgr = v-lgr.
       leave.
    end.
  end.
end.
o-isfindaaa = v-isfindaaa.
if connected ("txb") then disconnect "txb".





