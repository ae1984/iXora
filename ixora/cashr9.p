/* cashr9.p
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


def shared var g-ofc like ofc.ofc.
def var panum like point.point.
find ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then do :
   panum =  ofc.regno / 1000 - 0.5 .
end.
if panum <> 99 then run casher69. else run casher96.
