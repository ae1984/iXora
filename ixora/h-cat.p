/* h-cat.p
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
define shared variable su-min as integer.
define shared variable su-max as integer.
define variable u-min as integer.
define variable u-max as integer.

u-min = su-min.
u-max = su-max.
if u-min = ?
then u-min = 0.
if u-max = ? or u-max = 0
then u-max = 99999.

{itemlist.i
       &updvar = " "
       &file = "loncat"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "loncat.loncat >= u-min and loncat.loncat <= u-max" 
       &flddisp = "loncat.loncat format '99999'
                   string(loncat.loncat) format '999.99' label 'Код '
                   loncat.des format 'x(50)' label 'Наименование'"
       &chkey = "loncat"
       &chtype = "integer"
       &index  = "loncat"
       &findadd = " "
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }

