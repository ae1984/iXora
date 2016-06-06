/* aat-num.p
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

/*
   aat-num.p
*/

{global.i}

def shared var s-aat like aat.aat.

find sysc where sysc.sysc eq "NXTAAT".
s-aat = sysc.inval.
sysc.inval = sysc.inval + 1.
create aat.
aat.aat = s-aat.
aat.tim = time.
aat.who = g-ofc.
aat.whn = g-today.
aat.regdt = g-today.
