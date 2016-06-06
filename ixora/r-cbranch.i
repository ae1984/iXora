/* r-branch.i
 * MODULE
	Отчетность
 * DESCRIPTION
        Последовательное соединение с филиалами с запуском определенной программы.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        24.05.2003 nadejda - убраны параметры -H -S из коннекта
        30.08.2006 u00121  - добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        23.10.2006 u00121  - добавил field в "for each comm.txb"
        24.10.2006 u00121  - вернул все как было
        13/12/2007 madiyar - определение базы (МКО или Банк)
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        15/03/2012 id00810 - название банка из sysc
        19/03/2012 id00810 - добавила указание на базу bank
        25/04/2012 evseev  - rebranding. разбранчевка с учетом банк-мко.
*/

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

def var vx-path as char no-undo.

/*find first bank.sysc where bank.sysc.sysc = 'bankname' no-lock no-error.
if avail bank.sysc and bank.cmp.name matches ("*" + bank.sysc.chval + "*")  then vx-path = '/data/b'.
else vx-path = '/data/'.*/

if bank.cmp.name matches "*МКО*" then vx-path = '/data/'.
else vx-path = '/data/b'.

for each comm.txb where comm.txb.consolid = true no-lock:

    if connected ("txb") then disconnect "txb".
/*    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). */
    connect value(" -db " + replace(comm.txb.path,'/data/',vx-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run {&proc}.
end.

if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".



