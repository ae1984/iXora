/* rmzoutg.p
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
        17.11.09 marinav счет as cha format "x(20)" 
*/

/* s-remout.p*/

{global.i}
def var ys as log .
def shared var s-remtrz like remtrz.remtrz .
def  shared var v-option as char.
def var t-pay like remtrz.amt.
def var prilist as cha.
define new shared frame remtrz.
def buffer  tgl  for  gl.
def var acode like crc.code.
def var bcode like crc.code.
{lgps.i}
{rmz.f}
 find first que where que.remtrz = s-remtrz no-lock .
 if     que.pid ne m_pid then do:
  Message "Платеж находится в очереди = " + que.pid + 
          ", невозможно обработать " . 
  pause .
  return .
 end.

 find first remtrz where remtrz.remtrz = s-remtrz no-lock .
 find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error.
 v-psbank = remtrz.sbank .
 if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then do :
  v-kind = "TAX" .
 end .
 else 
  v-kind = "PAY" .
 display
     remtrz.remtrz remtrz.sqn v-psbank remtrz.ptype ptyp.des
      remtrz.rdt
     remtrz.valdt1  remtrz.valdt2 remtrz.jh1      remtrz.jh2
     v-psbank remtrz.rbank remtrz.scbank remtrz.rcbank
     remtrz.sacc remtrz.racc rsub
     remtrz.drgl remtrz.crgl remtrz.dracc  remtrz.cracc
     remtrz.fcrc acode remtrz.tcrc bcode remtrz.amt remtrz.payment
     remtrz.ptype remtrz.cover remtrz.svccgr  pakal
     remtrz.svca remtrz.svcrc remtrz.svcaaa remtrz.svccgl
     remtrz.bb remtrz.ba remtrz.bn remtrz.ord remtrz.bi  v-priory v-kind
     with frame remtrz .
      
     run 3-outg.
     /*
     find remtrz where  remtrz.remtrz = s-remtrz exclusive-lock no-error.
     if avail  remtrz then
     remtrz.cover  = 1. */
     pause 0.


