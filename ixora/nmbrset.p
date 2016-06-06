/* nmbrset.p
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

/* checked */
/* nmbrset.p
   SUB-LEDGER NUMBERING FILE
*/

{mainhead.i NUM}

def var ans as log.
def var cmd as cha format "x(6)" extent 4
    initial ["NEXT","EDIT","DELETE","QUIT"].

form nmbr.code
     with row 3 centered 1 col frame nmbr.
form cmd
     with centered no-box no-label row 21 frame slct.

view frame nmbr.
view frame slct.

outer:
repeat:
  prompt-for nmbr.code with frame nmbr.
  find nmbr using nmbr.code no-error.
  if not available nmbr
    then do:
      bell.
      {mesg.i 1808} update ans.
      if ans eq false then next.
      create nmbr.
      assign nmbr.code.
    end.
  display nmbr.des nmbr.prefix nmbr.fmt nmbr.sufix nmbr.nmbr
	  with frame nmbr.
  display cmd auto-return with frame slct.

  inner:
  repeat:
    choose field cmd with frame slct.
	 if frame-value eq "EDIT"
      then do:
	update nmbr.des nmbr.prefix nmbr.fmt nmbr.sufix nmbr.nmbr
	    with frame nmbr.
	if length(nmbr.prefix) + length(nmbr.fmt) + length(nmbr.sufix) gt 10
	  then do:
	    bell.
	    {mesg.i 9837}.
	    undo, retry.
	  end.
      end.
    else if frame-value eq "QUIT" then return.
    else if frame-value eq "DELETE "
      then do:
	{mesg.i 0824} update ans.
	if ans eq false then next.
	delete nmbr.
	next outer.
      end.
    else if frame-value eq "NEXT"
      then do:
       clear frame nmbr.
       next outer.
     end.
  end. /* inner */
end. /* outer */
