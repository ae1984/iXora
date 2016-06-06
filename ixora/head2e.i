/* head2e.i
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

/* head2e.i */

{&var}

def var vans as log.
def var vsele as cha form "x(12)" extent 12
 initial ["E D I T", "Q U I T",
          "{&other1}", "{&other2}", "{&other3}", "{&other4}",
          "{&other5}", "{&other6}", "{&other7}", "{&other8}",
          "{&other9}", "{&other10}"].

form vsele with frame vsele {&vseleform}.
form {&form} with frame {&file} {&frame}.
{&start}
          view frame {&file}.
          {&predisp}
          display {&flddisp} with frame {&file}.
          pause .

{&end}
