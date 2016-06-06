/* lonstl-p.p
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

def var flag as inte initial 2.
def shared var s-lon like lon.lon.

start: repeat:
  if flag = 1 then do:
   run lonstl-p1(output flag).
   next start.
  end.
  else if flag = 2 then do:
   run lonstl-p2(output flag).
   next start.
  end.
  else if flag = 3 then do:
   run lonstl-p3(output flag).
   next start.
  end. 
 if lastkey = 404 then leave.
end.
