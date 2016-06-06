/* 8st-prfdek2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def  shared var v-pass as char.

if not connected ("txb") then do:
  find first comm.txb where comm.txb.consolid and (not comm.txb.is_branch) no-lock no-error.
  connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
end.

for each comm.txb where comm.txb.consolid = true no-lock:

    if connected ("ast") then disconnect "ast".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
    run 8st-prfdek22.p.
    run str59.p.
    run str76.p.
    run str87.p.
    run str88.p.
    run str91.p.
end.
    
if connected ("txb") then disconnect "txb".
if connected ("ast") then disconnect "ast".
/*if connected ("comm") then disconnect "comm".*/



