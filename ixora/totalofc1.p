/* totalofc1.p
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
        26.01.2011 Luiza скопировала с модуля txbs.p, только возвращает номер выбранного филиала в перем v-select1
 * BASES
        BANK COMM
 * CHANGES
        05.12.2011 id00004 убрал консолидирование если отчет запускается с филиала
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

def output parameter v-select1 as int no-undo.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

def var v-path as char no-undo.
if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
else v-path = '/data/b'.


def buffer bsysc for sysc.
find last bsysc where bsysc.sysc = 'ourbnk' no-lock no-error.

/*   {sel-filial.i}
     v-select1 = v-select. */


if bsysc.chval = 'TXB00' then do:
   {sel-filial.i}
   v-select1 = v-select.
end.
else  do:
  v-select1 = integer(substr(bsysc.chval,4,2)) + 2.
  v-select = integer(substr(bsysc.chval,4,2)) + 2.
end.

for each comm.txb where comm.txb.consolid and
         (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run value("totalofc").
end.

if connected ("txb")  then disconnect "txb".




