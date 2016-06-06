/* s-lonnd1s.p
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
        18/07/2013 Sayat(id01143) - ТЗ 1637 от 28/12/2012 "Доработка модуля по залогам"
* BASES
        BANK
 * CHANGES
        18/07/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониториг залогов - переоценка"

*/

/*-------------------------------
  #3.NodroЅin–juma ievade
-------------------------------*/
{global.i}
{kd.i new}
define shared variable s-lon    as character.
def var ii as inte init 1 no-undo.


find lon where lon.lon = s-lon no-lock.
find last crchis where crchis.crc = lon.crc and crchis.rdt <= lon.rdt no-lock no-error.
if not available crchis then find first crchis where crchis.crc = lon.crc and crchis.rdt > lon.rdt no-lock no-error.

find first lonsec1 where lonsec1.lon = s-lon no-error.

def var s_rowid as rowid.
def var v-txt as char no-undo.
def var v-log as logi no-undo.
def buffer b-lonsec1 for lonsec1.
def var v-select as integer.

{jabrw.i
&start     = "  "
&head      = "lonsec1"
&headkey   = "ln"
&index     = "lonln"

&formname  = "s-lonnd1"
&framename = "sec2"
&where     = " lonsec1.lon = s-lon "

&addcon    = " false "
&deletecon = " false "
&precreate = " "
&postadd   = " "

&prevdelete = " "

&prechoose = " message 'F6 - Мониторинг, F4 - Выход '. "

&postdisplay = " "

&display   = " lonsec1.ln lonsec1.lonsec lonsec1.pielikums[1] lonsec1.numdog lonsec1.dtdog lonsec1.sectp lonsec1.crc lonsec1.secamt lonsec1.fdt lonsec1.tdt "

&highlight = " lonsec1.ln lonsec1.lonsec lonsec1.pielikums[1] lonsec1.numdog lonsec1.dtdog lonsec1.sectp lonsec1.crc lonsec1.secamt lonsec1.fdt lonsec1.tdt "


&postkey   = "else
              if lastkey = keycode('F6') then do:
                  m-ln = lonsec1.ln.
                  run zlgmonclnd('zalog',' Проверка залогового обеспечения ').
                  next upper.
              end. "

&postupdate = "m-ln = lonsec1.ln.

               update lonsec1.lonsec with frame sec2.
               v-log = no.
               run s-seczal(lonsec1.lon,m-ln,output v-log, output v-txt).
               if v-log then do:
                 lonsec1.pielikums[1] = v-txt.
                 displ lonsec1.pielikums[1] with frame sec2.
               end.
               update lonsec1.numdog lonsec1.dtdog with frame sec2.
               update lonsec1.sectp with frame sec2.
               update lonsec1.crc lonsec1.secamt with frame sec2.
               update lonsec1.fdt with frame sec2.
               update lonsec1.tdt with frame sec2.
               run s-secamt.
               find current lonsec1 exclusive-lock.
               lonsec1.fdt = lonsec1.dtdog.
               next upper.
              "

&end = "hide frame sec2."
}
hide message.

