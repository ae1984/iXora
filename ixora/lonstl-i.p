/* lonstl-i.p
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
def shared var marked like lnsci.paid-iv.

start: repeat:
  if flag = 1 then do:
   run lonstl-i1(output flag).
   next start.
  end.
  else if flag = 2 then do:
   run lonstl-i2(output flag).
   next start.
  end.
  else if flag = 3 then do:
   run lonstl-i3(output flag).
   next start.
  end.
 if lastkey = 404 or flag = 0 then do:
/*
    for each lnsci where lnsci.lni = s-lon and lnsci.mark <> "":
     lnsci.mark = "".
    end.
    */
    if lastkey = 404 then marked = 0.
    leave.
 end.
end.
