/* vcfaaa.p
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

/* vcfaaa.p
*/
def var vcif like cif.cif.


{proghead.i "ACCOUNT List"}

update vcif .

for each aaa where aaa.cif eq vcif:
  display aaa.aaa aaa.cif
	  with centered title " aaa List "
	  row 4 down frame aaa.
end.
