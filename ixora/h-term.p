/* h-term.p
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
        19/05/06 ten
 * CHANGES
*/

{global.i}
{itemlist.i 
       &where = " eterminal.terminal-id <> ''  "     	
       &file = "eterminal"
       &frame = "width 2 row 5 centered scroll 1 13 down overlay "
       &flddisp = "' ' eterminal.terminal-id format 'x(12)' column-label ' Номер ' ' '
                   eterminal.acc format 'x(12)' column-label 'Счет' ' '
                   " 
       &chkey = "terminal-id"
       &chtype = "string"
       &index  = "id" }
return frame-value.

