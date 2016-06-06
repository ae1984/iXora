/* actstch.p
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
*/

 /* actstch.p
    by S. Choi */


 {proghead.i "ACCT STATUS CHANGE"}

 for each aaa where aaa.sta eq "N":

     if (year(g-today) eq year(aaa.regdt))
	and ((month(g-today) - month(aaa.regdt)) eq 1)
	and (day(g-today) eq day(g-today)) then
	  aaa.sta = "A".

     else if ((year(g-today) - year(aaa.regdt)) eq 1)
       and ((month(g-today) + 12 - month(aaa.regdt)) eq 1)
       and (day(g-today) eq day(aaa.regdt)) then
	  aaa.sta = "A".

 end.
