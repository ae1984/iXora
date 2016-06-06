/* pksysc.p
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
        01.02.2003 marinav
        27.02.2003 nadejda - добавлены обязательные для всех видов кредитов параметры, их проверка и добавление
        11/10/2011 madiyar - перекомпиляция
*/

{mainhead.i}
{pk.i new}

for each pksysc where pksysc.sysc = "" .
 delete pksysc .
end.

form pksysc.chval format "x(312)"
 with frame y  overlay  row 14  centered top-only no-label.

define variable s_rowid as rowid.
def var v-ans as logical.

def temp-table t-pksysc like pksysc.
def buffer b-pksysc for pksysc.

for each pksysc where pksysc.credtype = '6' and pksysc.general no-lock:
  find b-pksysc where b-pksysc.credtype = s-credtype and b-pksysc.sysc = pksysc.sysc no-lock no-error.
  if not avail b-pksysc then do:
    create t-pksysc.
    buffer-copy pksysc to t-pksysc.
    t-pksysc.credtype = s-credtype.
  end.
end.

if can-find (first t-pksysc) then do:
  v-ans = yes.
  message skip(1) " Найдены обязательные параметры кредитов, отсутствующие в списке настроек данного вида кредитов !"
          skip(1) " Добавить недостающие параметры ?" skip(1)
          view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.
  if v-ans then
    for each t-pksysc:
      create pksysc.
      buffer-copy t-pksysc to pksysc.
    end.
end.

{jabrw.i
&start     = " "
&head      = "pksysc"
&headkey   = "sysc"
&index     = "sysc"

&formname  = "pksysc"
&framename = "pksysc"
&where     = " pksysc.credtype = s-credtype "

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = "  pksysc.credtype = s-credtype.
                update pksysc.sysc pksysc.des pksysc.daval pksysc.deval
                pksysc.inval pksysc.loval pksysc.general with frame pksysc .
                update pksysc.chval with frame y. "


&prechoose = "message 'F4-Выход,INS-Вставка,P-Печать.'."

&postdisplay = " "

&display   = "pksysc.sysc pksysc.des pksysc.daval pksysc.deval
              pksysc.inval pksysc.loval pksysc.general"

&highlight = " pksysc.sysc pksysc.des  "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                              update pksysc.sysc pksysc.des pksysc.daval pksysc.deval
                              pksysc.inval pksysc.loval pksysc.general with frame pksysc .
                              update pksysc.chval with frame y scrollable.
                              hide frame y no-pause.
                      end.
              else if keyfunction(lastkey) = 'P' then
                      do:
                         s_rowid = rowid(sysc).
                         output to pksysc.img .
                         for each pksysc:
                             display pksysc.sysc pksysc.des pksysc.daval pksysc.deval
                             pksysc.inval pksysc.loval pksysc.chval.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pksysc.img').
                         find pksysc where rowid(pksysc) = s_rowid no-lock.
                      end. "

&end = "hide frame pksysc.
hide frame y."
}
hide message.


