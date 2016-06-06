/* setps.p
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
def var pss0 as cha .
find first sysc where sysc.sysc = "ourbnk" no-lock no-error .
pss0 =
 substr(encode(substr(caps(sysc.chval),1,3) + trim(sysc.stc)),1,6) + ".r"  .
if ( avail sysc and search(pss0) ne ? ) then u_pid = "0".
