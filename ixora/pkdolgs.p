/* pkdolgs.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Задолжники по кредитам физ.лиц
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
        15/03/2005 madiar
 * CHANGES
*/

{mainhead.i}

def var v-sel as char.

run sel2 (" Выбор: ", " 1. Задолжники по ""БД"" | 2. Задолжники по прочим кредитам физлиц | 3. Выход ", output v-sel).
case v-sel:
  when '1' then run pkcash.
  when '2' then run pkdolg.
  when '3' then return.
  otherwise return.
end case.

