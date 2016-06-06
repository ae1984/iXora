/* stchk3.i
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

if periods <> 0 then do: 
        f_date = t_date.
     end.
     else do:
	if available a_hi then 
           f_date = t_date + 1. 
        else 
           f_date = t_date.
           /* 
           repeat:
             if weekday(f_date) = wkend + 1 or
                weekday(f_date) = wkstrt - 1 or
                can-find ( hol where hol.hol = f_date ) then do:
                  f_date = f_date + 1.
                  next.
                end. 
             leave.
           end.
           */
           if f_date >= g-today then leave. 
     end.
