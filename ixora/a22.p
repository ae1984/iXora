/* a22.p
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
        03.11.2004 suchkov - убрал все лишнее
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
	03.10.2006 suchkov - т.к. записей city = 997 в txb больше нет, переделал for each .
*/
def shared var v-pass as char.

define variable path as character .
/*
define shared variable m as integer .
define shared variable g as integer .
*/
for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    run act-22.
    run 700n-gl2.
end.
    
if connected ("txb") then disconnect "txb".




