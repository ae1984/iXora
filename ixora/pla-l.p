/* pla-l.p
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

/* pla-i.p
AGA - 07/05/96 - формирование новых записей

*/

DEF SHARED VAR v-nmb LIKE pla.nmb.
DEF SHARED VAR g-ofc LIKE ofc.ofc.
DEF SHARED VAR g-today AS DATE.
FIND FIRST cmp NO-LOCK.
FIND FIRST point NO-LOCK.
FIND FIRST sysc WHERE sysc.sysc EQ "CLECOD" NO-LOCK.
CREATE pla.
pla.lang = "l".
pla.nmb = "0001".
pla.regdt = g-today.
pla.who = g-ofc.
pla.tim = TIME.
pla.ma1 = cmp.name.
pla.ma2 = point.regno.
pla.ba1 = cmp.name.
pla.ba2 = point.regno.
pla.kb2 = sysc.chval.
pla.code = "Ls".
pla.summ = 0.
pla.sa1 = "".
pla.sa2 = "".
pla.ba3 = "".
pla.ba4 = string(pla.regdt).
pla.kb4 = "".
pla.rs1 = "".
pla.rs2 = "".
pla.rs3 = "".
pla.rs4 = "".
pla.ve  = "14".
pla.me  = "14".
pla.ap  = "".
v-nmb = pla.nmb.
