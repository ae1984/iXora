/* 9st-prf1.p
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
        21.11.2005 nataly внесены изменения
        24.05.2003 nadejda - убраны параметры -H -S из коннекта 
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


for each comm.txb where comm.txb.name matches '*STAT*' :

 if connected ("stat") then disconnect "stat".
  connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld stat -U " + comm.txb.login + " -P " +  comm.txb.password).
  run 9st-prf11. 
end.
    
if connected ("stat") then disconnect "stat".
if connected ("comm") then disconnect "comm".







