/* findcif.p
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

def var v-name like cif.name.

v-name = "".
repeat:
update v-name label " Что искать ? " with frame aaa.
display  " Ждите ... " with centered row 12 with frame aac.
pause 0.
hide frame aac.

find first cif use-index sname where cif.sname >= v-name .
repeat:
 display cif.cif trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(60)".
 find next cif use-index sname .
 if not available cif then leave.
end.
end.
