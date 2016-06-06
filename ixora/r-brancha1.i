/* r-brancha1.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
   Коннект ко всем филиалам и сбор информации по ним
   Отличие от r-brancha.i - после выполнения не делается disconnect от COMM!

   Параметры
     &proc - имя вызываемой процедуры

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
	13.06.2003 nadejda
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        09/11/2010 madiyar - убрал -H,-S
*/

if not connected ("comm") then run conncom.

for each comm.txb where comm.txb.consolid = true no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
    run {&proc}.
end.
    
if connected ("ast")  then disconnect "ast".


