/* lcswtinc.p
 * MODULE
        Автоинкремент исходящих 799
 * DESCRIPTION
        Автоинкремент исходящих 799
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
        31/01/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var s-countO799 as integer.
def shared var s-LC like LC.LC.
find last LCswt where LCswt.LC = s-LC and LCswt.mt = 'I799' no-lock no-error.
if avail LCswt then s-countO799 = LCswt.LCcor + 1.
else s-countO799 = 1.

