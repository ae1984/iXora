/* connibkm.p
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

if not connected("ib") then do:
find sysc where sysc.sysc = "IBHOST" no-lock no-error.
if not avail sysc or sysc.chval = "" then do :
   message "Невозможно подключиться к БД Internet-Office.  Нет IBHOST записи в SYSC файле".
   return.
end.

connect value(sysc.chval) no-error.
end.
if not connected("ib") then do: message "Connection lost...". pause. return. end.

run sf_kmob.

disconnect 'ib' no-error.
