/* aat-bat.p
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

/* aat-bat.p
*/

{proghead.i "BATCH CHECK ENTRY MENU"}

define new shared var s-aaa like aaa.aaa.
define new shared var s-toavail as dec.
define new shared var s-aat like aat.aat.
define new shared var s-ln as int.
define new shared var s-force as log initial false.
define new shared var s-bat like bat.bat.
define buffer xbat for  bat.
define buffer b-bat for bat.
define buffer c-bat for bat.
define buffer b-aaa for aaa.

def var disagain as log.
def var vcnt as int.
def var fv  as cha.
def var inc as int.

define var vout as char.
define var vans as log.
define var vaaa like aaa.aaa.
define var vbal like aaa.cbal.
define var vava label "TOT-AVAIL" like aaa.cbal.
define var vamt like aaa.cbal.
define var vdiff like aaa.cbal.
define var vcrc like crc.crc.
define var vchk like bat.chkno.
define var vtrue as logical init false.
define var toavail as dec decimals 2 label "Avail-Bal" init 0.
define var cravail like aaa.cbal label "Cr-Avail" init 0.

update s-bat help "ENTER 0 FOR AUTOMATIC NEXT BATCH NUMBER.."
      label "ENTER BATCH# " with frame batno
       row 8 centered side-label.

if s-bat eq 0 then run nxtbat.

find first bat where bat.bat eq s-bat no-error.
if available bat then vcrc = bat.crc.
if not available bat then do:
  update vcrc validate(can-find(crc where crc.crc eq vcrc),"Invalid Entry...")
	 label "ENTER CURRENCY "
	 with row 8 centered side-label.
end. /* if not abailable bat */


if available bat and bat.who ne g-ofc and g-ofc ne "root"
  then do:
    bell.
    {mesg.i 0602}.
    return.
  end.

form bat.ln bat.aaa vava bat.amt vchk bat.sta
     with row 3 centered 15 down overlay frame bat
     title "BATCH CHECK ENTRY ( BATCH NO : " + string(s-bat) + " )".


view frame bat.
pause 0.

r0:
repeat:
  find first bat where bat.bat eq s-bat use-index batln no-error.
  if available bat then leave.
  create bat.
  bat.bat = s-bat.
  bat.ln = 1.
  s-ln = 1.
  display bat.ln with frame bat.
  if new bat then do:
    bat.bat = s-bat.
    bat.crc = vcrc.
    update bat.aaa  validate
	   (can-find(aaa where aaa.aaa eq bat.aaa), "NON-EXISTING ACCOUNT...")
	   with frame bat.
    s-aaa = bat.aaa.
  end.
  bat.who = userid('bank').
  bat.regdt = g-today.
  bat.tim = time.
  find aaa where aaa.aaa eq s-aaa no-error.
  if available aaa then do:
    if aaa.crc ne vcrc then do:
      {mesg.i 9813}.
      undo,retry.
    end.
    if aaa.sta eq "C" then do:
      {mesg.i 6207}.
      undo, retry.
    end.
    run bat-bal.
    vava = s-toavail.
    disp vava with frame bat.
    update bat.amt
	    validate(bat.amt le aaa.cr[1] - aaa.dr[1],
		      "Non sufficient fund...") with frame bat.

    if bat.amt eq ? or bat.amt = 0 then do:
	{mesg.i 0263}.
	undo, retry.
    end. /* if bat.amt eq ? or 0 */

    if bat.amt gt s-toavail then do:
	  {mesg.i 6200}.
	  {mesg.i 0834} update vans.
	  if vans then do:
	     bat.sta = "RJ".
	     disp bat.sta with frame bat.
	  end.
	  if vans eq false then undo, retry.
    end. /* if bat.amt gt s-toavail */

  end.  /* if available aaa */
  else undo, retry.  /* if not available aaa */
  vchk = 0.
  update vchk  validate (vchk ne 0 , "ENTER CHK#..") with frame bat.
  for each b-bat where b-bat.aaa eq aaa.aaa:
       if b-bat.chkno eq vchk then do:
	 {mesg.i 6204}. pause 3.
	 undo ,retry .
       end. /* if bat.chkno eq vchk */
  end. /* for each bat */

  bat.abal = s-toavail.
  vava = bat.abal.
  bat.chkno = vchk.
  display bat.ln bat.aaa vava bat.amt vchk bat.sta with frame bat.
  pause 0.
end. /* r0 */

disagain = true.

r1:
repeat:
  if not available bat then leave.
  pause 0.
  if disagain
  then do:
      pause 0.
      view frame bat.
      pause 0.
      clear frame bat all.
      repeat vcnt = 1 to frame-down(bat):
	vchk = bat.chkno.
	vava = bat.abal.
	display bat.ln bat.aaa vava bat.amt vchk bat.sta with frame bat.
	down with frame bat.
	find next bat where bat.bat eq s-bat use-index batln no-error.
	if not available bat then leave.
      end. /* repeat vcnt */
      if lastkey eq keycode("cursor-up")
      then up frame-line(bat) - 1 with frame bat.
      else up with frame bat.
  end. /* if disagain */
  disagain = true.

   r2:
   repeat on endkey undo r1, leave r1:
     {mesg.i 0963}.
     {mesg.i 0956}.
     input clear.
     choose row bat.ln no-error with frame bat.
     find bat where bat.bat = s-bat and bat.ln = integer(frame-value)
		  use-index batln no-error.
     if lastkey eq keycode("cursor-up") and frame-line(bat) = 1
     then do:
	   repeat vcnt = 1 to frame-down(bat):
	     find prev bat where bat.bat eq s-bat use-index batln no-error.
	     if not available bat
	     then do:
		find first bat where bat.bat eq s-bat use-index batln.
		leave.
	     end. /* if not available */
	   end.  /* repeat vcnt */
	   next r1.
     end. /* if lastkey */

    else if lastkey eq keycode("cursor-down")  and
	    frame-line(bat) = frame-down(bat)
    then do:
	   find next bat where bat.bat eq s-bat
		     use-index batln no-error.
	   if not available bat
	   then find last bat
		     where bat.bat eq s-bat
		     use-index batln .
	   next r1.
	 end.

    else if lastkey eq keycode("cursor-right")
    then do:
	   find last bat
		where bat.bat eq s-bat
		use-index batln.
	   next r1.
	 end.

    else if lastkey eq keycode("cursor-left")
    then do:
	   find first bat
		where bat.bat eq s-bat
		use-index batln.
	   next r1.
	 end.
    else leave.
  end. /* r2 */

  if keyfunction(lastkey) = "GO"
  then do:
	if bat.regdt ne g-today or
		    (bat.who ne g-ofc and g-ofc ne "root")
		    then undo r1, retry r1.
	 vans = no.
	 {mesg.i 0824} update vans.
	 if vans
	 then do:
		if not new bat
		then do:
		  bat.sta = "".
		  delete bat.
		  scroll from-current up with frame bat.
		  find first bat where bat.bat = s-bat no-error.
		end.
	      end. /* if vans */
	 else {mesg.i 0212}.
       end.  /* if keyfunction(lastkey) eq "GO" */
  else if frame-value = " "
  then do:
      {mesg.i 0839}.
      find last xbat where xbat.bat eq s-bat use-index batln no-error.
      create bat.
      bat.bat = s-bat.
      bat.crc = vcrc.
      if available xbat
      then bat.ln = xbat.ln + 1.
      else bat.ln = 1.
      display bat.ln with frame bat.
      if new bat then do:
	bat.bat = s-bat.
	bat.crc = vcrc.
	update bat.aaa validate(can-find(aaa where aaa.aaa eq bat.aaa)
				     ,"NON_EXISTING ACCOUNT...")
	       with frame bat.
	s-aaa = bat.aaa.
      end. /* if new bat */
      s-ln = bat.ln.
      s-aaa = bat.aaa.
      bat.who = userid('bank').
      bat.regdt = g-today.
      bat.tim = time.
      find aaa where aaa.aaa eq bat.aaa.
      if aaa.crc ne vcrc then do:
	{mesg.i 9813}.
	undo r1,retry r1.
      end.
      if aaa.sta eq "C" then do:
	{mesg.i 6207}.
	undo r1, retry r1.
      end.
      run bat-bal.
      vava = s-toavail.
      disp vava with frame bat.
      update bat.amt validate(bat.amt le aaa.cr[1] - aaa.dr[1],
			"Non sufficient fund.") with frame bat.
      vchk = 0.
      update vchk validate(vchk ne 0, " ENTER CHECK #..." ) with frame bat.

      for each b-bat where b-bat.aaa eq aaa.aaa :
	if b-bat.chkno eq vchk then do:
	  {mesg.i 6204}. pause 3.
	  undo r1,retry r1.
	end. /* if bat.chkno eq vchk */
      end. /* for each b-bat */

      bat.chkno = vchk.
     /*  run aaa-pls. */
      bat.abal = s-toavail.
      bat.chkno = vchk.
      display bat.ln bat.aaa vava bat.amt vchk bat.sta with frame bat.
      disagain = false.
  end.  /* else if frame-value eq "" */

  else if frame-value ne " "
  then do on endkey undo, next r1:
	if bat.regdt ne g-today or (bat.who ne g-ofc and g-ofc ne "root")
		    then undo, retry.
	{mesg.i 0807}.
	s-aaa = bat.aaa.
	s-ln = bat.ln.

	if new bat then do:
	  bat.bat = s-bat.
	  bat.crc = vcrc.
	  update bat.aaa with frame bat.
	  s-aaa = bat.aaa.
	  s-ln = bat.ln.
	end.  /* if new bat */

	bat.who = userid('bank').
	bat.tim = time.

	find aaa where aaa.aaa eq s-aaa.
	if aaa.crc ne vcrc then do:
	  {mesg.i 9813}.
	  undo r1,retry r1.
	end.
	if aaa.sta eq "C" then do:
	  {mesg.i 6207}.
	  undo r1, retry r1.
	end.
	run bat-bal.
	update bat.amt validate(bat.amt le aaa.cr[1] - aaa.dr[1],
		       "Non sufficient fund.") with frame bat.

	if bat.amt eq ? or bat.amt = 0 then do:
	   {mesg.i 0263}.
	   undo r1, retry r1.
	end. /* if bat.amt eq ? or 0 */

	if bat.amt gt s-toavail then do:
	   {mesg.i 6200}.
	   {mesg.i 0834} update vans.
	  if vans then do:
	     bat.sta = "RJ".
	     disp bat.sta with frame bat.
	  end.
	  if vans eq false then undo, retry.
	end. /* if bat.amt gt s-toavail */
	vchk = bat.chkno.
	update vchk validate(vchk ne 0, "ENTER CHECK #...") with frame bat.

	for each b-bat where b-bat.aaa eq aaa.aaa:
	   if b-bat.chkno eq vchk and b-bat.chkno ne bat.chkno then do:
	      {mesg.i 6204}. pause 3.
	      vchk = bat.chkno.
	      disp vchk with frame bat.
	      undo r1,retry r1.

	   end. /* if bat.chkno eq vchk */
	end. /* for each b-bat */

	bat.chkno = vchk.
	bat.abal = s-toavail.
	display bat.ln bat.aaa vava bat.amt vchk bat.sta with frame bat.
	disagain = false.
    end.  /* else if frame-value ne "" */
end.
