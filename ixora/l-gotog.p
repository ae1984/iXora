/* l-gotog.p
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

{global.i}
{lgps.i }
def shared var s-remtrz like remtrz.remtrz .
def var yn as log initial false format "да/нет".
define var v-psingl like gl.gl.

def var ok as log .

find sysc where sysc.sysc eq "PSINGL"  no-lock  no-error. 
if avail sysc then v-psingl = sysc.inval.
                              
Message " Вы уверены ? " update yn .
do transaction:

find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock
 no-error.

find jh where jh.jh = remtrz.jh2 no-error.
if available jh then do:
  Message " 2 проводка уже существует !!! " . pause.
  return.
end.

find que of remtrz NO-LOCK no-error.
if not available que or que.pid ne '2l' then do:
  Message " Платеж не в очереди 2l  !!! " . pause.
      return.
end.


/*

find  jh where jh.jh = remtrz.jh1 no-error .
for each  jl where jl.jh = jh.jh no-lock.
if jl.gl = v-psingl then do:
  Message " 1TRX->G/L = 451000,impossible to send !!! " . pause.
  return.
end.
end.

*/
                               /*

if jh.sts < 5 then do :
  Message " Распечатайте ваучер !!! " . pause.
  return.
end.                             */

if yn then do  :
find first que where que.remtrz = s-remtrz exclusive-lock no-error .
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

if avail que then do :
  remtrz.rbank = "". 
  remtrz.rcbank = "" . 
  remtrz.cracc = "" . 
  remtrz.crgl = 0.
  remtrz.racc = "". 
  remtrz.rsub = "" . 
  remtrz.ptype = "N" . 
  que.ptype = "N" . 
  que.pid = m_pid.
  que.rcod = "10" .
  v-text = " По маршруту отправлен платеж " + remtrz.remtrz + "ТИП = " + 
           remtrz.ptype + " , rcod = " + que.rcod  .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.

 release que .
 release remtrz.
end.
end .         
   end .  /* transaction */               
