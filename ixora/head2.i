/* head2.i
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

/* head2.i
  as second or third screen
*/

{&var}
def var vans as log.
def var vsele as cha form "x(12)" extent 12
 initial ["E D I T", "Q U I T",
	  "{&other1}", "{&other2}", "{&other3}", "{&other4}",
	  "{&other5}", "{&other6}", "{&other7}", "{&other8}",
	  "{&other9}", "{&other10}"].


/* these 2 vars required by gethelp */

form vsele with frame vsele {&vseleform}.
form {&form} with frame {&file} {&frame}.
{&start}
  repeat:
	  view frame {&file}.
	  {&predisp}
	  display {&flddisp} with frame {&file}.
	  pause 0.
    display vsele with frame vsele.

    choose field vsele auto-return with frame vsele.
    hide frame vsele.
    if frame-value = "E D I T"
    then do:
	   {&no-edit}
		   {&preupdt}
		   {&prepost}
		   update {&fldupdt} with frame {&file}.

		   {&file}.who = userid('bank').
		   {&file}.whn = g-today.
		   {&file}.tim = time.
		   {&posupdt}
		   {&pospost}

	 end.
    else if frame-value = "Q U I T"
    then leave.
    else if frame-value = " " then do:
				   {mesg.i 9205}.
				   pause 2.
			      end.

    else if frame-value = "{&other1}"
	 then do:        {&no-1}
			 if search("{&prg1}" + ".r") ne ?
			 then do:
				{&start1}
				run {&prg1}.
				{&end1}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.

    else if frame-value = "{&other2}"
	 then do:        {&no-2}
			 if search("{&prg2}" + ".r") ne ?
			 then do:
				{&start2}
				run {&prg2}.
				{&end2}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
    else if frame-value = "{&other3}"
	 then do:
		 {&no-3}
			 if search("{&prg3}" + ".r") ne ?
			 then do:
				{&start3}
				run {&prg3}.
				{&end3}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
    else if frame-value = "{&other4}"
	 then do:
		 {&no-4}
			 if search("{&prg4}" + ".r") ne ?
			 then do:
				{&start4}
				run {&prg4}.
				{&end4}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
    else if frame-value = "{&other5}"
	 then do:
		 {&no-5}
			 if search("{&prg5}" + ".r") ne ?
			 then do:
				{&start5}
				run {&prg5}.
				{&end5}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
    else if frame-value = "{&other6}"
	 then do:
		 {&no-6}
			 if search("{&prg6}" + ".r") ne ?
			 then do:
				{&start6}
				run {&prg6}.
				{&end6}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
    else if frame-value = "{&other7}"
	 then do:
		 {&no-7}
			 if search("{&prg7}" + ".r") ne ?
			 then do:
				{&start7}
				run {&prg7}.
				{&end7}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
    else if frame-value = "{&other8}"
	 then do:
		 {&no-8}
			 if search("{&prg8}" + ".r") ne ?
			 then do:
				{&start8}
				run {&prg8}.
				{&end8}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
    else if frame-value = "{&other9}"
	 then do:
		 {&no-9}
			 if search("{&prg9}" + ".r") ne ?
			 then do:
				{&start9}
				run {&prg9}.
				{&end9}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
    else if frame-value = "{&other10}"
	 then do:
		 {&no-10}
			 if search("{&prg10}" + ".r") ne ?
			 then do:
				{&start10}
				run {&prg10}.
				{&end10}
			      end.
			 else do:
				{mesg.i 0210}.
				pause 2.
			 end.
	 end.
  end.
{&end}
