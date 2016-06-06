/* l-govcon.p
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
def var ok as log .
def var vcash as log.

do transaction:

find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

find jh where jh.jh = remtrz.jh2 no-error.
if not available jh then do:
  Message remtrz.remtrz " 2TRX doesn't exist !!! " . pause.
  return.
end.

find que of remtrz NO-LOCK no-error.
if not available que or que.pid ne '2l' then do:
    Message " Платеж " remtrz.remtrz " находится не в очереди 2L  !!! " . pause.
    return.
end.

 find sysc where sysc.sysc = 'CASHGL' no-lock no-error.
 find first jh where jh.jh = remtrz.jh2 no-error.
 vcash = false .
 for each jl of jh :
  if jl.gl = sysc.inval then  vcash = true.
 end.

 if vcash then do :
    for each jl of jh exclusive-lock .
        jl.sts = 5 .
    end .
    jh.sts = 5.
 end.

 else do:
      for each jl of jh exclusive-lock .
          jl.sts = 6 .
      end .
      jh.sts = 6.
 end.


find first que where que.remtrz = s-remtrz exclusive-lock no-error .
if avail que then do :

  que.pid = m_pid.
  if jh.sts = 6 then
  que.rcod = "0" .
  else
  que.rcod = "1" .
  v-text = " Отправлен платеж " + remtrz.remtrz + 
           " по маршруту , rcod = " + que.rcod  .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.

 release que .
 release remtrz.
end.

end. /* ...do transaction... */

