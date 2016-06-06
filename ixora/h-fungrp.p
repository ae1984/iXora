/* h-fungrp.p
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
        31.08.2004 tsoy - Для международников только 232 группа 
*/

/* h-fungrp.p */
{global.i}


def temp-table t-fungrp like fungrp.

def var v-dep as char.

find ofc where ofc.ofc = g-ofc no-lock no-error.
find codfr where codfr.codfr = "sproftcn" and codfr.code = ofc.titcd  no-lock no-error.

if avail codfr then v-dep = codfr.code .
               else v-dep = "".

for each fungrp no-lock.

  if v-dep = "106" then do:
       if fungrp.fungrp = 232 then do:
          create t-fungrp.
          buffer-copy fungrp to t-fungrp.
       end.
  end. else do:
       create t-fungrp.
       buffer-copy fungrp to t-fungrp.
  end.

end.


{itemlist.i
       &defvar  = " "
       &updvar  = " "
       &where = "true"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &form = "t-fungrp.fungrp format 'zz9' t-fungrp.gl t-fungrp.des[1]"
       &index = "fungrp"
       &chkey = "fungrp"
       &chtype = "integer"
       &file = "t-fungrp"
       &flddisp = "t-fungrp.fungrp t-fungrp.gl t-fungrp.des[1]"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
