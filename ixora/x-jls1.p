/* x-jls1.p
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

/* x-jls.p
*/

def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.

{proghead.i "GENERAL ENTRY - SINGLE"}
def var i as int.
def var vbal as dec format "zzz,zzz,zz9.99-".
def var vdam like vbal.
def var vcam like vbal.
def var vop  as int format "z".
/*
def var fv as char.
def var inc as int.
*/
def var oldround as log.

{jhjl.f new}

main:
repeat: /* 1 */

  {x-jlcf.i} /* clearing frame */
  {x-jlvf.i} /* view frame */

  vop = 0.
  {mesg.i 1400} update vop.
  /* "3.ListTrx 4.ListG/L 5.ListAm 6.SubLedger" */

  if vop = 1 or vop = 2
    then do:
      if vop = 1
	then do:
	  run x-jhnew.
	  find jh where jh.jh = s-jh.
	  display jh.jh jh.jdt jh.who
	    with frame jh.
	  if g-tty ne 0 then run g-ttys.
	end.
      else if vop = 2
	then do:
	  {x-jlol.i}
	  s-jh = jh.jh.
	end.
      {x-jllis.i}
      run x-jlgens1.p.
    end. /* 12 */
  /*
  else if vop = 3
    then do:
      {x-jlhf.i}
      {mesg.i 0810}.
      run x-jllt.
    end.
  else if vop = 4
    then do:
      {x-jlhf.i}
      {mesg.i 0810}.
      run x-jllg.
    end.

  else if vop = 5
    then do:
      {x-jlhf.i}
      {mesg.i 0810}.
      run x-jlam.
    end.

  else if vop = 6
    then do:
      {x-jlhf.i}
      {mesg.i 0810}.
      run x-jlsl.
    end.

  else if vop = 0
    then leave.
  */
end.
