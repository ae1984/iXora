/* r-branch3.i
 * MODULE
        Консолидированная отчетность
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Поиск всех филиалов для формиорвания консолидированной отчетности
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
	25.04.2006 u00121  - переделал коннект с banks`ов на bank`и comm.txb.city = 997 -> comm.txb.consolid
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


for each comm.txb where comm.txb.consolid no-lock:

    if connected ("ast") then disconnect "ast".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
    run {&proc}.
end.
    
if connected ("txb") then disconnect "txb".
if connected ("ast") then disconnect "ast".
if connected ("comm") then disconnect "comm".

