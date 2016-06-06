/* h-dracc.p
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

/* h-quetyp.p */
{global.i}
{lgps.i}


def var v-name like bankl.name .
def var h as int .

def shared var s-remtrz like remtrz.remtrz.
find first remtrz where remtrz.remtrz = s-remtrz no-lock .

  h = 0 .
 for each bankt where bankt.crc =
     remtrz.fcrc and bankt.cbank = remtrz.scbank no-lock .
     h = h + 1 .
  end .
  if h > 10 then h = 10 .


  do:

       {browpnp.i
        &h = "h"
        &where = "
         bankt.crc =
               remtrz.fcrc and bankt.cbank = remtrz.scbank
         "
        &frame-phrase = "row 8 centered
                   scroll 1 h down overlay   "
        &seldisp = "bankt.acc"
        &file = "bankt"
        &disp = "bankt.acc column-label "" Nostro/Loro ""
         bankt.subl column-label "" SUB "" bankt.crc column-label "" CRC "" "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " frame-value = bankt.acc . hide all . "
       }

end.
