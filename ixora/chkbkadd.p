/* chkbkadd.p
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

/*chkbkadd.p*/
{mainhead.i}
def shared var s-aaa like chkbk.aaa .
def var vl as int.
def shared frame chkbk.

{chkbk.f}
view frame chkbk.
find chkbk where chkbk.aaa = s-aaa.

do on error undo,retry:
find chkbksts where chkbksts.chkbksts = chkbk.chkbksts.
if chkbksts.done eq false  then do:
   bell.
   {mesg.i 0601} chkbksts.des.
   pause.
   undo,return.
end.

chkbk.odate  = ?.
chkbk.chkbkby = 0.
chkbk.bydes  = "".
chkbk.byfee  = 0.
chkbk.chkbktp = 0.
chkbk.tpdes  = "".
chkbk.qty    = 0.
chkbk.chkfee  = 0.
chkbk.deldt   = ?.
chkbk.sdate  = ?.
chkbk.chkfrm  = 0.
chkbk.chkto   = 0.
chkbk.chkbksts  = 0.
chkbk.pbdt     = ?.
chkbk.probm    = "".
chkbk.chkbkord = 0.

chkbk.odate = g-today.
update chkbk.odate chkbk.chkbkby with frame chkbk.
find chkbkby where chkbkby.chkbkby = chkbk.chkbkby.
chkbk.bydes = chkbkby.des. chkbk.byfee = chkbkby.byfee.
update chkbk.bydes chkbk.byfee with frame chkbk.
update chkbk.chkbktp with frame chkbk.
find chkbktp where chkbktp.chkbktp = chkbk.chkbktp.
chkbk.tpdes = chkbktp.des.
update chkbk.tpdes chkbk.qty with frame chkbk.
chkbk.chkfee = chkbktp.chkfee * chkbk.qty / chkbktp.qty .
chkbk.deldt = g-today + chkbkby.days.
update chkbk.chkfee chkbk.deldt chkbk.chkfrm with frame chkbk.
chkbk.chkto = chkbk.chkfrm + chkbk.qty.
chkbk.chkbksts = 1.
update chkbk.chkto chkbk.chkbksts with frame chkbk.
find chkbksts where chkbksts.chkbksts = chkbk.chkbksts.
if chkbksts.prob eq true then update chkbk.pbdt chkbk.probm  with frame chkbk.
if chkbk.chkbkord = 0 then do:
   find last chkbkord no-error.
   if not available chkbkord then vl = 1.
   else vl = chkbkord.chkbkord + 1.
   create chkbkord.
   chkbkord.chkbkord = vl.
   chkbkord.aaa = chkbk.aaa.
   chkbkord.odate = chkbk.odate.
   chkbkord.chkbkby = chkbk.chkbkby.
   chkbkord.byfee = chkbk.byfee.
   chkbkord.chkbktp = chkbk.chkbktp.
   chkbkord.qty = chkbk.qty.
   chkbkord.chkfee = chkbk.chkfee.
   chkbkord.deldt = chkbk.deldt.
   chkbkord.sts = chkbk.chkbksts.
   chkbk.chkbkord = vl.
end.
else do:
   find  chkbkord where chkbkord.chkbkord = chkbk.chkbkord .
   chkbkord.odate = chkbk.odate.
   chkbkord.chkbkby = chkbk.chkbkby.
   chkbkord.byfee = chkbk.byfee.
   chkbkord.chkbktp = chkbk.chkbktp.
   chkbkord.qty = chkbk.qty.
   chkbkord.chkfee = chkbk.chkfee.
   chkbkord.deldt = chkbk.deldt.
end.
end.
