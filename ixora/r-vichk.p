/* r-vichk.p
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
 * BASES
        BANK
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	18/06/97 AGA- пpовеpка на возможность получения выписок по "X" клиентам 
*/

def shared var s-cif like cif.cif.
def shared var stat-us as log . /* true - не пpошел пpовеpки */

find first cif where cif.cif EQ s-cif.
if cif.type EQ "X" then do:
   find first ofc where ofc.ofc EQ userid("bank") no-lock no-error.
   if available( ofc) then do:
      if not (ofc.expr[5] matches "*K*" ) then stat-us = true.       
   end.
end.
