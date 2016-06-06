/* balaat.p
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
def new shared var s-aat like aat.aat.
def buffer b-aaa for aaa.
def var vcbal    like bal.amt.
def var toavail  like bal.amt.
def var cravail  like bal.amt.
def var xl as int init 0.
def var yl as int init 0.

find first bal where bal.regdt = g-today and bal.post = true no-lock no-error.
if available bal then do:
  bell.
  display " P O S T I N G    D O N E    F O R    T H E    D A Y    ! ! ! "
	  with frame x-1 no-label centered row 10.
  pause 5. {mesg.i 0917}.
  return.
end.
else display " W O R K I N G " with frame x-2 no-label centered row 10.


for each bal where bal.regdt = g-today
	    and not(bal.post) and bal.sta <> "RJ" use-index bahln
     , each aaa where aaa.aaa = bal.aaa
	       break by bal.regdt by bal.bah by aaa.lgr:

    find bah where bah.bah = bal.bah no-lock.

    vcbal = aaa.cbal.
    if aaa.loa ne ""
       then do:
	      find b-aaa where b-aaa.aaa = aaa.loa no-lock.
	      cravail = (b-aaa.dr[5] - b-aaa.cr[5])
		      - (b-aaa.dr[1] - b-aaa.cr[1]).
       end.

    if aaa.cr[1] - aaa.dr[1] ge 0 then
	toavail = vcbal + cravail - aaa.hbal.
    else toavail = cravail - aaa.hbal.

    if vcbal - aaa.hbal lt bal.amt /* and s-force eq false   */
       then do:
	  if toavail lt bal.amt then bal.sta = "RJ".
	  else bal.sta = "CR".
    end.
    else bal.sta = "".


    if bal.sta ne "RJ" then do:
      find sysc where sysc.sysc = "NXTAAT".
      sysc.inval = sysc.inval + 1.
      s-aat = sysc.inval.
      do transaction:
	create aat.
	aat.aat = s-aat.
	aat.regdt = today.
	aat.whn = g-today.
	aat.bah = bah.bah.
	aat.aaa = bal.aaa.
	aat.aax = 2.
	aat.lgr = aaa.lgr.
	aat.amt = bal.amt.
	aat.chk = bal.chkno.
	aat.stn = 0.
	aat.who = bal.who.

	bal.post = true.
	bal.stn = 9.
      end.
      run aat-pls2.
   end. /*  do   */

  end. /* for each bal */
