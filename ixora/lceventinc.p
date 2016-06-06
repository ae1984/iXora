/* lceventinc.p
 * MODULE
        Advice of Refusal
 * DESCRIPTION
        Advice of Refusal
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        15/03/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var s-countevent as integer.
def shared var s-LC like LC.LC.
def shared var s-event like lcevent.event.
find last LCevent where LCevent.LC = s-LC and LCevent.event = s-event no-lock no-error.
if avail LCevent then s-countevent = LCevent.number + 1.
else s-countevent = 1.

