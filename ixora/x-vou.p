/* x-vou.p
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
   rundoll - добавил переменную v-s.
*/

def input parameter pnum like remtrz.remtrz.
def input parameter psub like substs.sub.
def var v-point like point.point.
def var v-cmp like cmp.name.
def var v-s as char.
{global.i}
find first remtrz where remtrz.remtrz = pnum no-lock no-error.
     if avail remtrz and remtrz.cover = 2 then do:
find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz  and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
if avail sub-cod  then
                       v-s = "Срочный платеж".
                       else v-s = "".
end.
find ofc where ofc.ofc = g-ofc no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

find first trxsub where trxsub.sub = psub no-lock no-error.

find first cmp no-lock.
output to vou.img  page-size 0.
put skip(3)
"=============================================================================="
skip cmp.name format "x(30)" skip.
put point.addr[1] skip.
if point.addr[2] <> " " then put point.addr[2] skip.
if point.addr[3] <> " " then put point.addr[3] skip.
put point.regno skip point.licno skip(2).
put g-today " " string(time,"HH:MM") " " pnum " " v-s " " psub " " trxsub.des
 " * " g-ofc skip.
put
"------------------------------------------------------------------------------"
skip(1).
output close.
unix silent prit -t vou.img.
/*
hide all.
*/
pause 0.
