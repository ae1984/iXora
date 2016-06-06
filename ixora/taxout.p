/* taxout.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Реестр платежей за дату
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
        31/10/03 sasco изменил today на g-today
*/

define shared variable g-today as date.
def var dat as date.
def var report-var as int init 1.
{taxoutimg.f}   

dat = g-today.

VIEW FRAME image1.
UPDATE dat WITH FRAME image1.
UPDATE report-var WITH FRAME image1.
 
/*
update dat label "Укажите дату".
update report-var label " 1) детальный реестр   2) сводный отчет  ".
*/

if report-var = 1 then run taxoutdet (dat).
else
  if report-var = 2 then run taxoutsvod (dat).
  else
    return.

run menu-prt ("tax.log").

HIDE FRAME image1.    
