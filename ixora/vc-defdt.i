/* vc-defdt.i
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

/* vc-defdt.i
   Определение первой и последней даты месяца

   18.12.2002 nadejda
*/

def var vi as integer.

v-month = month(g-today).
v-god = year(g-today).

if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.
v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
  when 4 or when 6 or when 9 or when 11 then vi = 30.
  when 2 then do:
    if v-god mod 4 = 0 then vi = 29.
    else vi = 28.
  end.
end case.
v-dte = date(v-month, vi, v-god).
