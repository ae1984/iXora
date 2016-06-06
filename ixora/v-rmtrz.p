/* v-rmtrz.p
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
define shared var s-remtrz like remtrz.remtrz.

define new shared var s-jh like jh.jh.

find remtrz where remtrz.remtrz eq s-remtrz no-error. 
find first jh where jh.jh = remtrz.jh1 no-lock no-error . 
if not avail jh then do : 
  run x-vou(input remtrz.remtrz, "rmz").
  return . 
end.  
s-jh = remtrz.jh1.
hide all.
{mesg.i 0809}.
/* run x-jlvouR. */
pause 0 .
run x-jlvouP.
pause 0.

 find jh where jh.jh eq remtrz.jh1.
 for each jl of jh.
  if jl.sts < 5 then  do:
   jl.sts = 5.
   jl.teller = userid('bank').
  end .
 end.
 if jh.sts < 5 then jh.sts = 5.
