/* h-uno.p
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

{global.i}
define shared variable grp as integer.
readkey pause 0.
{itemlist.i &file = "uno"
       &where = "uno.grupa = grp"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &flddisp = "uno.uno label 'Код ' uno.apr    label 'Наименование'"
       &chkey = "uno"
       &chtype = "integer"
       &index  = "uno"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
