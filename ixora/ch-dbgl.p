/* ch-dbgl.p
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

/* s-dbgl.p
*/

def shared var s-jh like jl.jh.
def shared var s-jln like jl.ln.
def shared var s-amt like jl.cam.

def var answer as log.
def var vns as log.
def var kbank like bank.bank.
def var vlne like wf.lne.
def var rem6 as log init true. /* FINAL BENEFICIARY ? */
def var xxx as char format "x(3)".
def var fv  as cha.
def var inc as int.
def var prc as log.
def var oldround as log.
def var vln as int.
def var vcon like wf.ln.
def var vdef as char format "x(70)".
def var recno as int.
def var code as int format '>>>>>9'.
def var ink as int.
def var pnk as char format "x" .
def var rf as char format "x(8)".
{global.i}

find jl where jl.jh eq s-jh and jl.ln = s-jln.
find first wf where wf.jh = jl.jh and wf.jln = jl.ln no-error.
if wf.sts ne 0 then do:
   bell.
   {mesg.i 0254}.
   return.
end.

  wf.amt = s-amt.

  if wf.lne = "900" or wf.lne = "9001" then do:
  if wf.tpy = " " then xxx = substring(wf.cdt,1,3).
  else xxx = substring(wf.tpy,1,3).
  end.
  else xxx = "REF".
  {getkey.i}
  wf.who = userid('bank').
  wf.whn = g-today.
  wf.tim = time.
 jl.rem[5] = "    :" + wf.scom + " TKEY:" + string(wf.tst).
