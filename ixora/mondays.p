/* mondays.p
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

def input parameter mm as inte.
def input parameter yy as inte.
def output parameter mdays as inte.

if mm = 1 then mdays = 31.
else if mm = 2 then do:
   if round((yy - 1900) / 4 , 0) = (yy - 1900) / 4 then mdays = 29.
   else mdays = 28.
end.
else if mm = 3 then mdays = 31.
else if mm = 4 then mdays = 30.
else if mm = 5 then mdays = 31.
else if mm = 6 then mdays = 30.
else if mm = 7 then mdays = 31.
else if mm = 8 then mdays = 31.
else if mm = 9 then mdays = 30.
else if mm = 10 then mdays = 31.
else if mm = 11 then mdays = 30.
else if mm = 12 then mdays = 31.  

