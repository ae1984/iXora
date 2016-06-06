/* stampdatr.p
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

def shared var g-today as date.
def var nm as inte.
def output parameter vdatu as char format "x(13)".
def shared var s-remtrz like remtrz.remtrz.
def var dt1 as date.

find first remtrz where remtrz.remtrz  = s-remtrz no-lock .
if remtrz.source = "H" then do:
   find first jl where jl.jh = remtrz.jh1 no-lock no-error.
   dt1 = jl.jdt.
end.
else dt1 = remtrz.valdt1.
vdatu = string(year(dt1),"9999 ").
vdatu = vdatu + string(day(dt1),"99. ").
nm = month(dt1).
if nm = 1 then vdatu = vdatu + "JAN.".
else if nm = 2 then vdatu = vdatu + "FEB.".
else if nm = 3 then vdatu = vdatu + "MAR.".
else if nm = 4 then vdatu = vdatu + "APR.".
else if nm = 5 then vdatu = vdatu + "MAI.".
else if nm = 6 then vdatu = vdatu + "JUN.".
else if nm = 7 then vdatu = vdatu + "JUL.".
else if nm = 8 then vdatu = vdatu + "AUG.".
else if nm = 9 then vdatu = vdatu + "SEP.".
else if nm = 10 then vdatu = vdatu + "OKT.".
else if nm = 11 then vdatu = vdatu + "NOV.".
else if nm = 12 then vdatu = vdatu + "DEC.".
