/* cdaprt.p
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

/* cdaprt.p
*/

{mainhead.i cfcd}  /* PRINT CERTIFICATE OF DEPOSIT */

define new shared var s-aaa like aaa.aaa.

update "INPUT C/D #" s-aaa
   with centered row 7 no-box no-label frame opt.


run s-cdaprts.
