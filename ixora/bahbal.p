/* bahbal.p
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
def new shared var bah like bah.bah.
def buffer b-bah for bah.
def buffer b-bal for bal.
def var newh as log init false.
def var newl as log init false.
def var ans as log format "YES/NO".
def var cnt as int.
def var dn as int.
def var ln as int.
def var fv as char.
def var inc as int.

repeat:

form "  BATCH-#:" bah.bah " CURRENCY:" bah.crc "-"
     crc.code "BATCH-TOTAL:" bah.amt
     with frame bah no-label centered row 1 overlay title
     "    B A T C H    T R A N S A C T I O N    C H E C K    E N T R Y    ".

form bal.ln bal.aaa bal.amt bal.chkno bal.sta bal.rc
     space(2) bal.post space(2) bal.regdt bal.regwho
     with frame bal row 4 centered 16 down overlay no-label title
"NO. ACCOUNT     CHECK-AMOUNT- CHECK# ST RC POST REG-DATE REG-WHO ".

view frame bah.
clear frame bal all.

prompt bah.bah
       help "ENTER BATCH-# OR HIT <RETURN> FOR NEW BATCH-# ... "
       with frame bah editing: {gethelp.i} end.
find bah using bah.bah no-error.
if not available bah then do:
  find last b-bah use-index bah no-lock no-error.
  if available b-bah then bah = b-bah.bah + 1.
		     else bah = 1.
  create bah.
  bah.bah = bah.
  bah.regwho = userid('bank').
  bah.regdt = today.
  bah.who = userid('bank').
  bah.whn = today.
  bah.tim = time.
  display bah.bah with frame bah. pause 0.
  update bah.crc with frame bah editing: {gethelp.i} end.
end.

bah = bah.bah.
find crc where crc.crc = bah.crc no-lock.
display bah.crc crc.code bah.amt with frame bah. pause 0.

status default
"SELECT BLANK LINE TO ADD... <F1> TO DELETE... <RETURN> TO EDIT... ".

find first bal where bal.bah = bah.bah use-index bahln no-error.

if not available bal then do:

  if {&addcon} true then newh = true.
		    else return.
end.

view frame bal. pause 0.

ln = 1.

outer:
repeat:

  if ln = 1 then do:
    clear frame bal all.
    dn = 0.
  end.

  if available bal then do:
    repeat cnt = ln to frame-down(bal):
      display bal.ln bal.aaa bal.amt bal.chkno bal.sta
	      bal.rc bal.post bal.regdt bal.regwho with frame bal.
      if cnt >= frame-down(bal) then leave.
      find next bal where bal.bah = bah.bah use-index bahln no-error.
      if not available bal then do:
	find last bal where bal.bah = bah.bah use-index bahln no-error.
	leave.
      end.
      down with frame bal.
      dn = dn + 1.
    end.
  end. /* if available bal */

  ln = 1.

  inner:
  repeat on endkey undo, leave outer:

    if not newh then
      choose row bal.ln no-error with frame bal.

    if keyfunction(lastkey) = "CURSOR-UP" and frame-line(bal) = 1 then do:
      repeat cnt = 1 to frame-down(bal) + dn:
	find prev bal where bal.bah = bah.bah use-index bahln no-error.
	if not available bal then do:
	  find first bal where bal.bah = bah.bah use-index bahln no-error.
	  leave.
	end.
      end.
      next outer.
    end.

    else
    if keyfunction(lastkey) = "CURSOR-DOWN" and
      frame-line(bal) = frame-down(bal) then do:
      find next bal where bal.bah = bah.bah use-index bahln no-error.
      next outer.
    end.

    else
    if keyfunction(lastkey) = "CURSOR-RIGHT" then do:
      find last bal where bal.bah = bah.bah use-index bahln no-error.
      next outer.
    end.

    else
    if keyfunction(lastkey) = "CURSOR-LEFT" then do:
      find first bal where bal.bah = bah.bah use-index bahln no-error.
      next outer.
    end.

    else
    if keyfunction(lastkey) = "GO" then do:
      find bal where bal.bah = bah.bah and bal.ln = integer(frame-value)
	no-error.
      if frame-value = "" then do:
	bell.
	{mesg.i 0960}.
	next inner.
      end.
      else if bal.post = no then do:
	find bal where bal.bah = bah.bah and bal.ln = integer(frame-value).
	ans = false.
	status input "ENTER Y>ES OR N>O PLEASE ... ".
	{mesg.i 0843} update ans.
	status input.
	if not ans then undo, retry.
	bah.amt = bah.amt - bal.amt.
	display bah.amt with frame bah. pause 0.
	delete bal.
	ln = frame-line(bal).
	repeat cnt = ln to frame-down(bal):
	  clear frame bal.
	  down with frame bal.
	end.
	repeat cnt = ln to frame-down(bal):
	  up 1 with frame bal.
	end.
	find next bal where bal.bah = bah.bah use-index bahln no-error.
	ln = frame-line(bal).
	{&enddel}
	next outer.
      end.
      else
      do:
	bell.
	{mesg.i 0250}.
	pause 3 no-message.
	hide message.
      end.
    end. /* GO */

    else
    do:

      if not newh then
	find bal where bal.bah = bah.bah and bal.ln = integer(frame-value)
	  no-error.
	if not available bal then do:
	  if true then do:
	    {mesg.i 0403}.
	    find last b-bal where b-bal.bah = bah.bah use-index bahln no-error.
	    create bal.
	    bal.bah = bah.bah.
	    bal.crc = bah.crc.
	    if available b-bal then bal.ln = b-bal.ln + 1.
			       else bal.ln = 1.
	    display bal.ln with frame bal.
	  end.
	  else do:
	    bell.
	    {mesg.i 0233}.
	    pause 10.
	  end.
	  newl = true.
	end.

	else
	do:
	  if bal.post = false then do:
	    {mesg.i 0807}.
	    {&predisp}
	    bah.amt = bah.amt - bal.amt.
	  end.
	  else
	  do:
	    bell.
	    {mesg.i 0250}.
	    pause 3 no-message.
	    hide message.
	  end.
	  newl = false.
	end.

	if bal.post = false then do on error undo, retry:
	  {&preupdt}
	  if new bal then do:
	    update bal.aaa validate(can-find(aaa where aaa.aaa = bal.aaa),
		   "INVALID ACCOUNT NUMBER ... ")
		   help "ENTER ACCOUNT OR HIT <F2> FOR HELP ... "
		   with frame bal.
	    find aaa where aaa.aaa = bal.aaa no-lock no-error.
	    if aaa.crc <> bal.crc then do:
	      bell.
	      {mesg.i 9812}.
	      undo, retry.
	    end.
	    if aaa.sta = "C" then do:
	      bell.
	      {mesg.i 6206}.
	      undo, retry.
	    end.
	  end.
	  if true then do:
	    update bal.amt validate(bal.amt <> 0 and bal.amt <> ?,
		   "MUST ENTER AMOUNT! ... ")
		   help "ENTER CHECK AMOUNT PLEASE ... "
		   with frame bal.
	  find aaa where aaa.aaa = bal.aaa no-lock.
	  /*   if bal.amt > aaa.cr[1] - aaa.dr[1] then do:
	      bell.
	      {mesg.i 8810}.
	      undo, retry.
	  end.  */

	  update bal.chkno validate(bal.chkno <> 0 and bal.chkno <> ?,
		 "MUST ENTER CHECK-# ... ")
		 help "ENTER CHECK-# PLEASE ... "
		 with frame bal.

	    find first b-bal where b-bal.aaa = bal.aaa
			       and ((b-bal.ln <> bal.ln and b-bal.bah = bal.bah)
				or  (b-bal.bah <> bal.bah))
			       and b-bal.chkno = bal.chkno
			       no-lock no-error.
	    if available b-bal then do:
	      bell.
	      {mesg.i 6205}.
	      pause 3 no-message.
	      clear frame bal.
	      display bal.ln with frame bal. pause 0.
	      undo, retry.
	    end.
	  end.
	  bal.who = userid('bank').
	  bal.whn = today.
	  bal.tim = time.
	  if new bal then do:
	    bal.regdt = today.
	    bal.regwho = userid('bank').
	  end.
	  {&postupdt}
	  {&predisp}
	  bah.amt = bah.amt + bal.amt.
	end. /* do on error undo, retry */

	if available bal then
	display bal.ln bal.aaa bal.amt bal.chkno bal.sta
		bal.rc bal.post bal.regdt bal.regwho with frame bal.
	display bah.amt with frame bah. pause 0.
	if new bal then do:
	  {&endadd}
	end.
	else
	do:
	  {&endedit}
	end.
	if newl then down 1 with frame bal.
	newh = false.
      end. /* add or edit */

  end. /* inner */
end. /* outer */

end.

status default.
