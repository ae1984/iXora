/* pklocpar.p
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
        18.04.2008 alex - Расширил фрейм
*/

/* pklocpar.p ПотребКредиты
   Редактирование справочника локальных настроек модуля sysc

   18.03.2003 nadejda создан
*/

{mainhead.i}
{pk.i new}

define variable s_rowid as rowid.
def var v-title as char init "ЛОКАЛЬНЫЕ ПАРАМЕТРЫ МОДУЛЯ ""ПОТРЕБИТЕЛЬСКОЕ КРЕДИТОВАНИЕ""".
def var v-param as char.

form
     sysc.chval label "СТРОКА" format "x(300)"
   with overlay row 16 centered frame f-char.

for each sysc where sysc.sysc begins "pk" no-lock:
  v-param = if v-param <> "" then v-param + "," + sysc.sysc else sysc.sysc.
end.

for each bookcod where bookcod.bookcod = "credtype" no-lock:
  for each sysc where sysc.sysc begins bookcod.info[1] no-lock:
    v-param = if v-param <> "" then v-param + "," + sysc.sysc else sysc.sysc.
  end.
end.

{jabrw.i 
&start     = "displ v-title format 'x(60)' at 14 with row 4 no-box no-label frame f-header."
&head      = "sysc"
&headkey   = "sysc"
&index     = "sysc"

&formname  = "pklocpar"
&framename = "f-ed"
&where     = " lookup(sysc.sysc, v-param) > 0 "

&addcon    = "true"
&deletecon = "true"
&postcreate = " "
&postupdate   = " if lookup(sysc.sysc, v-param) = 0  then
                    v-param = if v-param <> '' then v-param + ',' + sysc.sysc else sysc.sysc.
                  update sysc.chval with frame f-char scrollable. 
                  hide frame f-char no-pause. "
       
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 37 no-box frame f-footer."

&postdisplay = " "

&display   = " sysc.sysc sysc.des sysc.daval sysc.deval sysc.inval sysc.loval "
&update    = " sysc.sysc sysc.des sysc.daval sysc.deval sysc.inval sysc.loval "
&highlight = " sysc.sysc "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(sysc).
                         output to pkdata.img .
                         for each sysc where lookup(sysc.sysc, v-param) > 0 no-lock:
                             display sysc.sysc sysc.des format 'x(54)' sysc.daval sysc.deval sysc.inval sysc.loval
                               sysc.chval format 'x(150)' with width 250.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pkdata.img').
                         find sysc where rowid(sysc) = s_rowid no-lock.
                      end. "

&end = "hide all no-pause."
}
hide message.