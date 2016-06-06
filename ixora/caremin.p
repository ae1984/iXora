/* caremin.p
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
        13/05/2004 madiar - добавил входной пар-р (true/false) в вызов jlcopy - показывать запрос причины удаления транзакции или нет.
*/

/* caremin.p */

{global.i}

define shared var s-rem like rem.rem.

define new shared var s-jh like jh.jh.
define new shared var s-consol like jh.consol init false.
define new shared var s-aah as int.
define new shared var s-line as int.
define new shared var s-force as log init true.
define shared var jh5 like rem.jh.
define shared var vjh5 like rem.vjh.
def var cans as log.
def buffer b-jh for jh.
def buffer b-jl for jl.
def var djh like jh.jh.
def var dvjh like jh.jh.
def var v-jhdel as log.
djh = ?.
dvjh = ?.

do transaction :
find rem where rem.rem = s-rem.


 if rem.jh ne ? then do:
   jh5 = rem.jh.
   find jh where jh.jh eq rem.jh no-error.
   if not available jh then rem.jh = ?.
  end.

 if rem.vjh ne ? then do:
   vjh5 = rem.vjh.
   find jh where jh.jh eq rem.vjh no-error.
   if not available jh then rem.vjh = ?.
  end.

	      if rem.jh eq ?
		then do:
		     bell.
		     {mesg.i 0214}.
		     pause 3.
		     undo, retry.
	      end.
	      {mesg.i 0823} update cans.
	      if not cans then undo.

	      find jh where jh.jh eq rem.jh no-error.
	      s-jh = rem.jh.
	      if jh.post eq true
		then do:

		     run x-jhnew.
		     find jh where jh.jh eq s-jh exclusive-lock no-error.
		     find b-jh where b-jh.jh eq rem.jh exclusive-lock
		       no-error.
		     for each b-jl of b-jh:
			if b-jl.aah ge 0 then do:
			create jl.
			jl.jh = jh.jh.
			jl.ln = b-jl.ln.
			jl.who = jh.who.
			jl.jdt = jh.jdt.
			jl.whn = jh.whn.
			jl.sts = b-jl.sts.
			jl.rem[1] = b-jl.rem[1].
			jl.rem[2] = b-jl.rem[2].
			jl.rem[3] = b-jl.rem[3].
			jl.rem[4] = b-jl.rem[4].
			jl.rem[5] = b-jl.rem[5].
			jl.gl = b-jl.gl.
			jl.acc = b-jl.acc.
			jl.dam = b-jl.cam.
			jl.cam = b-jl.dam.
			if b-jl.dc eq "D" then jl.dc = "C".
			else jl.dc = "D".
			jl.consol = b-jl.consol.
			jl.crc = b-jl.crc.
			find gl where gl.gl eq jl.gl no-error.
			s-force = true.
			{jlupd-r.i}
			end.
		     end.
		    find b-jh where b-jh.jh eq rem.jh exclusive-lock no-error.
		    jh.party = " for cancel " + string(b-jh.jh).
		    djh = jh.jh.
		    b-jh.party = trim(b-jh.party) + " cancel by "
		    + string(jh.jh).
		    jh.crc = b-jh.crc.
		    if rem.jh eq rem.vjh then rem.vjh = ?.
		    rem.jh = ?.
	      end.
	      else do:
		   run jlcopy(true).
		   v-jhdel = yes.
		   for each jl of jh:
		      if jl.aah ge 0 then do:
			  find gl of jl.
			  {jlupd-f.i -}
			  delete jl.
		      end.
		      else v-jhdel = no.
		   end.
		   /*
		   if v-jhdel then delete jh.
		   */
		   rem.jh = ?.
		   if rem.grp = 1 then rem.vjh = ?.
		   rem.cwho = userid('bank').
		   rem.cwhn = today.
		   rem.ctim = time.
	      end.

       if rem.vjh ne ? then do:
	      find jh where jh.jh eq rem.vjh no-error.
	      s-jh = rem.vjh.
	      if jh.post eq true
		then do:
		     run x-jhnew.
		     find jh where jh.jh eq s-jh exclusive-lock no-error.
		     find b-jh where b-jh.jh eq rem.vjh exclusive-lock no-error.
		     for each b-jl of b-jh:
			if b-jl.aah ge 0 then do:
			create jl.
			jl.jh = jh.jh.
			jl.ln = b-jl.ln.
			jl.who = jh.who.
			jl.jdt = jh.jdt.
			jl.whn = jh.whn.
			jl.sts = b-jl.sts.
			jl.rem[1] = b-jl.rem[1].
			jl.rem[2] = b-jl.rem[2].
			jl.rem[3] = b-jl.rem[3].
			jl.rem[4] = b-jl.rem[4].
			jl.rem[5] = b-jl.rem[5].
			jl.gl = b-jl.gl.
			jl.acc = b-jl.acc.
			jl.dam = b-jl.cam.
			jl.cam = b-jl.dam.
			if b-jl.dc eq "D" then jl.dc = "C".
			else jl.dc = "D".
			jl.consol = b-jl.consol.
			jl.crc = b-jl.crc.
			find gl where gl.gl eq jl.gl no-error.
			s-force = true.
			{jlupd-r.i}
			end.
		     end.
		    find b-jh where b-jh.jh eq rem.vjh exclusive-lock no-error.
		    jh.party = " for cancel " + string(b-jh.jh).
		    dvjh= jh.jh.
		    b-jh.party = trim(b-jh.party) + "cancel by "
		    + string(jh.jh).
		    jh.crc = b-jh.crc.
		    rem.vjh = ?.
	      end.
	      else do:
		   run jlcopy(true).
		   v-jhdel = yes.
		   for each jl of jh:
		      if jl.aah ge 0 then do:
		      find gl of jl.
		      {jlupd-f.i -}
		      delete jl.
		      end.
		      else v-jhdel = no.
		   end.
		   /*
		   if v-jhdel then delete jh.
		   */
		   rem.vjh = ?.
		   rem.cwho = userid('bank').
		   rem.cwhn = today.
		   rem.ctim = time.
	      end.
	   end.
 end.
 pause 0 .
 if djh ne ? then do:
  s-jh = djh.
  run x-jlvou.
 end.
 if dvjh ne ? then do:
  s-jh = dvjh.
  run x-jlvou.
 end.
