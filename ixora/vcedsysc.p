/* vcedsysc.p
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

/* vcedpar.p Валютный контроль 
   Редактирование справочника настроек

   18.10.2002 nadejda создан
*/

{mainhead.i VCEDSYSC}


define variable s_rowid as rowid.
def var v-title as char init "ЛОКАЛЬНЫЕ ПАРАМЕТРЫ МОДУЛЯ ""ВАЛЮТНЫЙ КОНТРОЛЬ""".
def var v-addparam as char init "mainbk".

form
     sysc.chval label "СТРОКА" format "x(300)"
   with overlay row 16 centered frame vcchar.

{jabrw.i
&start     = "displ v-title format 'x(50)' at 14 with row 4 no-box no-label frame vcheader."
&head      = "sysc"
&headkey   = "sysc"
&index     = "sysc"

&formname  = "vcedsysc"
&framename = "vced"
&where     = " sysc.sysc begins 'vc-' or lookup(sysc.sysc, v-addparam) > 0 "

&addcon    = "true"
&deletecon = "true"
&postcreate = " "
&postupdate   = " update sysc.chval with frame vcchar scrollable. 
                  hide frame vcchar no-pause. "
       
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 22 no-box frame vcfooter."

&postdisplay = " "

&display   = " sysc.sysc sysc.des sysc.daval sysc.deval sysc.inval sysc.loval "
&update    = " sysc.daval sysc.deval sysc.inval sysc.loval "
&highlight = " sysc.sysc "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(sysc).
                         output to vcdata.img .
                         for each sysc where sysc.sysc begins 'vc-' no-lock:
                             display sysc.sysc sysc.des sysc.daval sysc.deval sysc.inval sysc.loval
                               sysc.chval.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('vcdata.img').
                         find sysc where rowid(sysc) = s_rowid no-lock.
                      end. "

&end = "hide all no-pause."
}
hide message.


