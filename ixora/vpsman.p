/* vpsman.p
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



{lgps.i}
def var pss as cha .
def var pss0 as cha format "x(8)".
update pss0 blank with centered row 6 no-label overlay frame n1.
pss0 = encode(pss0) .
find first sysc where sysc.sysc = "ourbnk" no-error .
if avail sysc then sysc.stc = fill(" ",100) + pss0 .
pss0 = substr(encode(substr(caps(m_hst),1,3) + trim(sysc.stc)),1,6) + ".r"  .
hide frame n1 .
if search(pss0) ne ? then do:
 run value(pss0).
end .
 else
 do:
  pss0 = " WRONG COPY of PSMAN " .
  display  pss0 format "x(30)" with centered no-label row 12 overlay frame dd .
  hide frame dd .
 end.
