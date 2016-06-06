/* start.p
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
        07.06.2012 evseev - отструктурировал код
*/

{lgps.i}
def shared var s-remtrz like remtrz.remtrz .

if m_pid ne "PS_" then do transaction :
   find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
   find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .
   find sysc where sysc.sysc = "ourbnk" no-lock no-error .
   if avail que and  avail sysc and  sysc.chval ne  "" and  que.pvar = "" then do:
      if remtrz.dracc ne "" and remtrz.valdt1 ne ? and remtrz.amt ne 0 and remtrz.sbank ne sysc.chval then do :
         que.pvar = string(remtrz.valdt1 - 01/01/01) + "," + string(remtrz.amt,"zzzzzzzzzzzzz.99" ) + "," + remtrz.dracc + "," .
      end. else  que.pvar = " , , ," .
      if remtrz.cracc ne "" and remtrz.valdt2 ne ? and remtrz.payment ne 0 and remtrz.rbank ne sysc.chval then do:
         que.pvar  = que.pvar + string(remtrz.valdt2 - 01/01/01) + "," + string(remtrz.payment,"zzzzzzzzzzzzz.99" ) + "," + remtrz.cracc .
      end. else  que.pvar = que.pvar + " , ," .
   end .
   if remtrz.jh1 ne ? then do:
      find first jl where jl.jh = remtrz.jh1 no-lock no-error .
      if not avail jl then do:
         v-text = remtrz.remtrz + " 1TRX " + string(remtrz.jh1) + " haven't been found , so remtrz.jh1 have been cleaned . " .
         run lgps. remtrz.jh1 = ? .
      end.
   end.
   if remtrz.jh2 ne ? then do:
      find first jl where jl.jh = remtrz.jh2 no-lock no-error .
      if not avail jl then do:
         v-text = remtrz.remtrz + " 2TRX " + string(remtrz.jh2) + " haven't been found , so remtrz.jh1 have been cleaned . " .
         run lgps.
         remtrz.jh2 = ? .
      end.
   end.
   release remtrz .
   release que .
end .
