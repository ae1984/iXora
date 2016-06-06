/* con-crd.i
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

/* Соединение с базой пластиковых карточек */

if not connected("cards") then do:
    find sysc where sysc.sysc = "CRHOST" no-lock no-error.
    if not avail sysc or sysc.chval = "" then do :
        message "Нет CRHOST записи в sysc файле !".
        return.
    end.
    connect value(sysc.chval) no-error.
end.
   
if not connected( 'cards' ) then do:
   message "Нет соединения с БД Cards!".
   return.
end.

