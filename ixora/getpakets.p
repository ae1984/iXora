/* getpakets.p
 * MODULE
        PRAGMA
 * DESCRIPTION
        Получить список пакетов пользователей (вместе с самим пользователем).
        - возвращает список логинов через запятую
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
        23.08.2004 sasco
 * CHANGES

*/

define input parameter g-ofc as character.

define variable pakets as character.

/* ------------------------------------------- */

procedure get_pakets.
   define variable ggi as integer.
   define input parameter wofc as char.
   define variable wpar as character.

   find ofc where ofc.ofc = wofc no-lock no-error.
   if not avail ofc then return.
   wpar = trim(ofc.expr[1]).

   if lookup (wofc, pakets) > 0 then return.

   pakets = pakets + "," + wofc.
   do ggi = 1 to num-entries (wpar):
      find ofc where ofc.ofc = entry(ggi, wpar) no-lock no-error.
      run get_pakets (entry(ggi, wpar)).
   end.      

end procedure.


/* ------------------------------------------- */

pakets = ''.
find ofc where ofc.ofc = g-ofc no-lock no-error.
run get_pakets (g-ofc).

pakets = substr (pakets, 2).
return pakets.

