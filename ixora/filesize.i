/* filesize.i
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
KOVAL 

Получение размера файла 

in: путь к файлу
out: размер в байтах

*/

function filesize returns int ( input fl as char ).
 def var s as char.

 input through value("l -a " + fl + " | awk '~{print ~$5~}' "). 
 repeat:
       import s no-error.
 end.
 input close.

 return integer(s).

end function.

