/* secofc.p
 * MODULE
        Название Программного Модуля
	Администрирование АБПК
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Разрешение / Запрещение использования пунктов меню указанным пользователем
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	nmenu.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
	9-1-5-3 ПОДДЕРЖКА ДОСТУПА ПОЛЬЗОВАТЕЛЕЙ
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        24.03.2005 - u00121  по клавише 'Enter' на пункте меню  показываем время разр./запр.
	    21/08/2007 madiyar - опциональная синхронизация пакета с филиалами
	    20/05/2008 madiyar - не выдавались права на пункты нижже 16-го, исправил
        12.12.2011 id00477 - добавил синхронизацию для id
*/


{mainhead.i SECUSR} /* Security Maintenance by Officer */

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def buffer b-nmenu for nmenu.
def buffer f-nmenu for nmenu.
def buffer f-sec   for sec.

def var v-father  like nmenu.father initial "MENU".
def var v-fname   like nmenu.fname.
def var v-max     as   int.
def var v-proc    like nmenu.proc.
def var v-ans     as log.
def var v-stack   as cha.
def var v-ln      like nmenu.ln.
def var v-lnstack as cha.
def var v-deep    as int.
def var v-sts     as cha format "x" label "S".
def var v-per     as cha format "x" label "P".
def var dest      as log.
def var v-all     as log.
def var v-ofc as char no-undo.

def new shared var v-sync as log.

main: repeat:
	prompt-for sec.ofc with frame ofc side-label row 4 centered no-box.
	find ofc where ofc.ofc = input sec.ofc.
	display ofc.name with frame ofc.

    v-ofc = ofc.ofc.

	status default "'F1'- разр./запр.использ.  'Enter' - Время разр./запр.".
	/**********************************************************************************************************************************************************************************************************************************************/
	repeat:
		/**********************************************************************************************************************************************************************************************************************************************/
		repeat:
			v-max = 0.
			form nmenu.ln nmdes.des nmenu.fname nmenu.link v-sts v-per with centered row 5 no-box no-label 32 down frame nmenu.
			clear frame nmenu all no-pause.

			for each nmenu where nmenu.father eq v-father:
				find nmdes where nmdes.lang eq "RR" and  nmdes.fname eq nmenu.fname no-error.
				if nmenu.proc eq "" and nmenu.link eq "" then
					v-sts = ">".
				else
					if nmenu.link ne "" then
						v-sts = "^".
					else
						v-sts = "".
				find sec where sec.ofc eq ofc.ofc and  sec.fname eq nmenu.fname no-error.
				if available sec then
					v-per = "*".
				else
					v-per = "".
				disp nmenu.ln nmdes.des when available nmdes nmenu.fname nmenu.link v-sts v-per with frame nmenu.
				v-max = nmenu.ln.
				if v-max ge 32 then leave.
				down with frame nmenu.

			end.
			choose row nmenu.ln with frame nmenu.
			if frame-value eq "" then do:
				bell.
				undo, retry.
			end.
			else
			do:
				find nmenu where nmenu.father eq v-father and  nmenu.ln eq integer(frame-value).
				find nmdes where nmdes.lang eq "RR" and  nmdes.fname eq nmenu.fname no-error.

			end.

			display nmdes.des when available nmdes nmenu.fname nmenu.link nmenu.ln with frame nmenu.





			/*u00121 24.03.2005 по клавише 'Enter' на пункте меню  показываем время разр./запр.************************************************************************************************************************************************************/
			if keyfunction(lastkey) = "RETURN" then
			do:
				find last hissta where hissta.ref = nmenu.fname and hissta.rem = ofc.ofc no-error.
				if avail hissta then
				do:
					pause 0.
					displ  hissta.swho hissta.swhn string(hissta.stim, "HH:MM:SS")  skip hissta.fwho label "Кто лишил" hissta.fwhn string(hissta.ftim,"HH:MM:SS") with side-labels title nmdes.des overlay centered 1 down frame sec1.
					hide frame sec1.
				end.
			end.
			/**********************************************************************************************************************************************************************************************************************************************/
			else
			/**********************************************************************************************************************************************************************************************************************************************/
			if keyfunction(lastkey) eq "GO" then
			do:
				if nmenu.proc ne "" then
				do:
					find sec where sec.ofc eq ofc.ofc and sec.fname eq nmenu.fname no-error.
					if available sec then
					do:
						delete sec.
						/* 14/08/96 AGA удаление "*" пунктов, котоpые имеют подменю, а в подменю удаляется последний пункты  */
						RELEASE sec.
						dest = FALSE.
						for each f-nmenu where f-nmenu.father eq nmenu.father NO-LOCK:
							find first f-sec where f-sec.ofc eq ofc.ofc and f-sec.fname eq f-nmenu.fname no-lock no-error.
							if available f-sec  then
							do:
								dest = TRUE.
							end.
						end.
						if not dest then
						do:
							find first sec where sec.ofc eq ofc.ofc and sec.fname eq nmenu.father no-error.
							if available sec then
							do:
								DELETE sec.
							end.
						end.
					end.
					else
					do:
						create sec.
							sec.ofc = ofc.ofc.
							sec.fname = nmenu.fname.
					end.
				end. /* Actual Program */
				else
					if nmenu.link ne "" then
					do:
						bell.
						{mesg.i 9862}.
						next.
					end. /* Link */
					else
					do:
						{mesg.i 0612} update v-ans.
						if v-ans eq true then
						do:
							v-stack = nmenu.fname.
							v-ln = 1.
							v-deep = 1.
							repeat:
								find b-nmenu where b-nmenu.father eq entry(1,v-stack) and  b-nmenu.ln eq v-ln no-error.
								if not available b-nmenu then
								do:
									if v-deep eq 1 then leave.
									v-ln = integer(entry(1,v-lnstack)).
									v-stack = substring(v-stack,index(v-stack,",") + 1).
									v-lnstack = substring(v-lnstack,index(v-lnstack,",") + 1).
									v-deep = v-deep - 1.
									next.
								end.
								if b-nmenu.proc ne "" then
								do:
									find sec where sec.ofc eq ofc.ofc and  sec.fname eq b-nmenu.fname no-error.
									if not available sec then
									do:
										create sec.
											sec.ofc = ofc.ofc.
											sec.fname = b-nmenu.fname.
									end.
								end.
								v-ln = v-ln + 1.
								if b-nmenu.proc eq "" and b-nmenu.link eq "" then
								do:
									v-stack = b-nmenu.fname + "," + v-stack.
									v-lnstack = string(v-ln) + "," +  v-lnstack.
									v-ln = 1.
									v-deep = v-deep + 1.
								end.
							end.

						end. /* Answer is yes */
					end. /* Directory */
			end. /* GO */
			/**********************************************************************************************************************************************************************************************************************************************/

			if nmenu.link eq "" and nmenu.proc eq "" then
				v-father = nmenu.fname.
		end.
		/**********************************************************************************************************************************************************************************************************************************************/

		if v-father ne "MENU" then
		do:
			find nmenu where nmenu.fname eq v-father.
			v-father = nmenu.father.
		end.
		else
			leave.
	end.
	/**********************************************************************************************************************************************************************************************************************************************/
	status default.

	if s-ourbank = "txb00" then run ofc_check(v-ofc).
        if v-sync then do:
	        v-all = no.
            message "Производить изменения по всем филиалам?" view-as alert-box question buttons yes-no title "" update v-all.
            if v-all then do:
                displ " Синхронизация пакета с филиалами... " with no-label row 7 centered frame vmess.
	            run pack_sync(v-ofc).
	            hide frame vmess.
            end.
        end.

end. /* main */
