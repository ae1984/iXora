/* tdatda.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* tdatda.p
   081591
   S.CHOI
*/

define var vwht as int format "9" init 1.
define var vmat as char format "x(10)".
define var vext like vmat.
{mainhead.i TDMAT}  /* CDA MATURE/EXTEND */

{mesg.i 2401} update vwht.

if vwht eq 1 then run tdamat.
else if vwht eq 2 then run tdaext.
else do:
  {mesg.i 0260}.
  undo, retry.
end.
