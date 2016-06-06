/* v-remout.p
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

/* checked */
/* v-remout.p
   print outward remittance voucher
   01/02/92 by john d. seo
*/
{global.i}
define shared var s-rem like rem.rem.

define new shared var s-jh like jh.jh.


find rem where rem.rem eq s-rem no-error.
s-jh = rem.jh.
hide all.
{mesg.i 0809}.
run x-jlvouR.
pause 0 .
run x-jlvou1.

 find jh where jh.jh eq rem.jh.
 for each jl of jh.
  jl.sts = 5.
  jl.teller = userid('bank').
 end.
 jh.sts = 5.
