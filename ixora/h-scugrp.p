/* h-scugrp.p
 * MODULE
        Модуль ЦБ
 * DESCRIPTION
        ВЫзов справочника групп ЦБ 
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
        20/12/03 nataly
 * CHANGES
*/

/* h-scugrp.p */
{global.i}
{itemlist.i
       &defvar  = " "
       &updvar  = " "
       &where = "true"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &form = "scugrp.scugrp format 'zz9' scugrp.gl scugrp.des[1]"
       &index = "scugrp"
       &chkey = "scugrp"
       &chtype = "integer"
       &file = "scugrp"
       &flddisp = "scugrp.scugrp scugrp.gl scugrp.des[1]"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
