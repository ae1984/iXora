/* aat-trf.p
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

/*
   aat-trf.p
*/

{global.i}

def shared var s-aat like aat.aat.
def shared var s-sta like aat.sta.
def shared var s-amt like aat.amt.
def shared var s-aax like aax.ln.
def shared var s-trf like aat.trf.
def buffer b-aaa for aaa.
def var vbal as dec form "zzz,zzz,zzz.99-" label "BALANCE".
def var abal as dec form "zzz,zzz,zzz.99-" label "AVAI-BAL".
def var vcnt as int.
def var vdt as char.
def var vaat like aat.aat.
def var vavail as dec decimals 2 label "TotAvail" init 0.
def var cravail like aaa.cbal label "COLLT BAL" init 0.


if s-aax = 21 then vdt = "TRANSFER TO ACCT#".
else if s-aax = 71 then vdt = "TRANSFER FROM ACCT#".

form aaa.aaa
     vbal
     aaa.cbal
     with frame xf row 6 centered scroll 1 5 down overlay title vdt.

find first aaa where aaa.cif eq g-cif and aaa.aaa ne g-aaa
				     use-index lgr no-lock no-error.
if not available aaa then do:
   {mesg.i 0205}.
   frame-value = "".
   pause 2.
   return.
end.
view frame xf.
pause 0.
outer:
repeat:
  clear frame xf all.
  repeat vcnt = 1 to frame-down(xf):
    find lgr where lgr.lgr eq aaa.lgr.
    vbal = aaa.cr[1] - aaa.dr[1].
    abal = vbal - aaa.hbal.
    display aaa.aaa
	    vbal
	    abal
	    with frame xf.
    down with frame xf.

    find next aaa where aaa.cif eq g-cif and aaa.aaa ne g-aaa
		    use-index lgr no-lock no-error.
    if not available aaa then leave.
  end.

  if lastkey eq keycode("cursor-up")
    then up frame-line(xf) - 1 with frame xf.
  else up with frame xf.

  inner:
  repeat on endkey undo, leave outer:
    input clear.

    choose row aaa.aaa no-error with frame xf.
    find first aaa where aaa.cif eq g-cif and
		       aaa.aaa eq string(frame-value)
		 use-index lgr
		 no-lock no-error.
    if lastkey eq keycode("cursor-up") and frame-line(xf) = 1
    then do:
	   repeat vcnt = 1 to frame-down(xf):
	     find prev aaa where aaa.cif eq g-cif and aaa.aaa ne g-aaa
		    use-index lgr no-lock no-error.
	     if not available aaa
	     then do:
		find first aaa where  aaa.cif eq g-cif  and aaa.aaa ne g-aaa
		      use-index lgr no-lock.
		find aaa where aaa.aaa eq g-aaa.
		find lgr where lgr.lgr eq aaa.lgr.
		find aax where aax.ln eq s-aax and aax.lgr eq aaa.lgr.
		leave.
	      end.
       /*     {&findadd}  */
	   end.
	   leave inner.
	 end.
    else if lastkey eq keycode("cursor-down")  and
	    frame-line(xf) = frame-down(xf)
    then do:
	   find next aaa where aaa.cif eq g-cif and aaa.aaa ne g-aaa
		 use-index lgr no-lock no-error.
	   if not available aaa
	   then find last aaa where aaa.cif eq g-cif and aaa.aaa ne g-aaa
		      use-index lgr no-lock.
	/*   {&findadd}   */
	   leave inner.
	 end.

    else if lastkey eq keycode("cursor-right")
    then do:
	   find last aaa where aaa.cif eq g-cif and aaa.aaa ne g-aaa
		   use-index lgr no-lock.
	 /*  {&findadd}  */
	   leave inner.
	 end.

    else if lastkey eq keycode("cursor-left")
    then do:
	   find first aaa where aaa.cif eq g-cif and aaa.aaa ne g-aaa
			 use-index lgr no-lock.
      /*     {&findadd}   */
	   leave inner.
	 end.

    else do:
      if frame-value = " " then
			 do:
			     {mesg.i 9205}.
			     pause 1.
			     next.
			 end.
     g-aaa = frame-value.
     vaat = s-aat.
     if s-aax eq 21 then do transaction:
	s-aat = 0.
	run aat-num.
	find aat where aat.aat eq s-aat.
	find aaa where aaa.aaa eq g-aaa.
	aat.aax = 71.
	aat.regdt = g-today.
	aat.aaa = aaa.aaa.
	aat.lgr = aaa.lgr.
	aat.who = g-ofc.
	aat.whn = g-today.
	aat.tim = time.
	aat.amt = s-amt.
	aat.trf = vaat.
	s-trf = aat.aat.
	run aat-pls.
	aat.bal = (aaa.cr[1] - aaa.dr[1]).
      end.
      if s-aax eq 71 then do transaction:
	s-aat = 0.
	run aat-num.
	find aat where aat.aat eq s-aat.
	find aaa where aaa.aaa eq g-aaa.
	if aaa.loa ne ""
	   then do:
	     find b-aaa where b-aaa.aaa = aaa.loa.
	     cravail = (b-aaa.dr[5] - b-aaa.cr[5])
			   - (b-aaa.dr[1] - b-aaa.cr[1]).
	   end.
	vavail = aaa.cbal + cravail - aaa.hbal.
	if s-amt gt vavail then do:
	   {mesg.i 8819}.
	   s-sta = "RJ".
	   leave outer.
	end.
	aat.aax = 21.
	aat.regdt = g-today.
	aat.aaa = aaa.aaa.
	aat.lgr = aaa.lgr.
	aat.who = g-ofc.
	aat.whn = g-today.
	aat.tim = time.
	aat.amt = s-amt.
	aat.trf = vaat.
	s-trf = aat.aat.
	run aat-pls.
	aat.bal = (aaa.cr[1] - aaa.dr[1]).
      end.
      g-aaa = "".
      g-cif = "".
      return.
   end.

  end. /* inner */
end. /* outer */
