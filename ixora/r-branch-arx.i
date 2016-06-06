/* r-branch-arx.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        устанавливается коннект на архивные базы
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
        08.10.2003 nataly  - устанавливается коннект на архивные базы 
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/

for each comm.txb where comm.txb.city = 997   no-lock:
/*08.10.2003 nataly   for each comm.txb where comm.txb.consolid = true  no-lock:*/

    if connected ("txb") then disconnect "txb".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    if not connected ("txb") then displ comm.txb.path.
  /* if txb.path = '/data/alm/bank.db' then  */ run {&proc}.
end.
    
if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".

