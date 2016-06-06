/* wpcom1.p
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

/*
{comm-com.i}

def var selgrp as integer init 0.

do while true:
   run comm-grp(output selgrp).
   if selgrp = 7 then leave.
   else 
   if selgrp = -1 then return.
   else message "Не возможно зачислить проценты за платежи" 
        selname(selgrp)
        view-as alert-box.
end.

run comm-com(selgrp, 1).
*/

run comm-com(1).
