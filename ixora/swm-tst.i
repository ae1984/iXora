/* swm-tst.i
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

/*** 
KOVAL Проверка длины Swift - кода, возвращает true - если длина нормальная
***/

function swm-tst returns logical ( bic as char ).
 if length(trim(bic)) = 8 or length(trim(bic)) = 11 then return true. return false.
return true
.

end.