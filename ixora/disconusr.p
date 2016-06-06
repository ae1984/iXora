/* disconusr.p
 * MODULE
        Для использования в скриптах администраторов БД
 * DESCRIPTION
        Отключение пользоватлей от БД через proshut
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        suki <PID>
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        20.09.2012 id00700
 * BASES
        BANK COMM
 * CHANGES
*/

def var v-path as char.
def new shared var db-path as char.
def new shared var pts as integer.

input through echo $PTSUSER no-echo.
set pts.
input close.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.

for each comm.txb where comm.txb.consolid = true no-lock:
	if connected ("txb") then disconnect "txb".
	db-path = replace(comm.txb.path,'/data/',v-path).
	if bank.cmp.name matches ("*МКО*") and (comm.txb.txb=0 or comm.txb.txb=3 or comm.txb.txb=5 or comm.txb.txb=7 or comm.txb.txb=8 or comm.txb.txb=9 or comm.txb.txb=10 or comm.txb.txb=11 or comm.txb.txb=12 or comm.txb.txb=13 or comm.txb.txb=14 or comm.txb.txb=15) then next.
	connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
	run r-disconusr.
end.

if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".
quit.