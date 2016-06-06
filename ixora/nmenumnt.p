/* nmenumnt.p
 * MODULE
        Администрирование
 * DESCRIPTION
        Редактирование главного меню
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	nmenudel.p
	callsynnm.p
 * MENU
        12-1-3-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        05.08.2003 sasco   - удаление прав доступа на пункт меню при его удалении
                           - перенос прав доступа на пункт меню при переименовании fname`а
        19.07.2004 nadejda - удаление дерева пунктов меню через nmenudel.p
        19.04.2006 u00121  - Добавил процедуру синхронизации пунктов меню с филиалами + изменение пунктов меню разрешено только с базы данных Алматы
        21/02/2008 madiyar - подправил под новый размер терминала
        25/02/2008 madiyar - расширил фреймы
        29/12/2012 madiyar - убрал ограничение на показ только 25 пунктов
*/

{mainhead.i MMENT}

/*18.04.2006 u00121**********************************************************************************************************************************/
find last sysc where sysc.sysc = 'OURBNK' no-lock no-error.
if avail sysc and sysc.chval <> 'TXB00' then
do:
	find last cmp no-lock no-error.
	if avail cmp then
		message "Изменение пунктов меню возможно только из базы данных Алматы!" skip
			"Текущий филиал : " cmp.name view-as alert-box.
	return.
end.

define var l-change as log init false 				no-undo.
/*18.04.2006 u00121**********************************************************************************************************************************/

define buffer b-nmenu for nmenu.
define var v-father 	like nmenu.father initial "MENU"	no-undo.
define var v-fname  	like nmenu.fname			no-undo.
define var v-max    	as   int				no-undo.
define var v-proc   	like nmenu.proc				no-undo.
define var v-ln 	like nmenu.ln				no-undo.
define var v-ans 	as log					no-undo.
define var wantDel 	as logical				no-undo.
define var oldFname 	as character				no-undo.

repeat:
	repeat:
		v-max = 0.
		form nmenu.ln nmdes.des format "x(59)" nmenu.fname format "x(16)" nmenu.link nmenu.proc format "x(16)" with centered row 4 width 110 no-box no-label 32 down frame nmenu.
		/*form space(4) nmenu.ln help " " nmdes.des format "x(59)" nmenu.fname format "x(16)" with centered row 3 32 down no-label width 110 overlay frame nmenu.*/
		clear frame nmenu all no-pause.
		for each nmenu where nmenu.father eq v-father:
			find nmdes where nmdes.lang eq "RR" and  nmdes.fname eq nmenu.fname no-error.
			disp nmenu.ln nmdes.des when available nmdes nmenu.fname nmenu.link nmenu.proc with frame nmenu.
			v-max = nmenu.ln.
			if v-max ge 32 then leave.
			down with frame nmenu.
		end.
		choose row nmenu.ln go-on("CTRL-D" "DEL-LINE") with frame nmenu.
		if keyfunction(lastkey) eq "DELETE-LINE" then
		do: /* nadejda */
			v-ln = integer(frame-value).
			find nmenu where nmenu.father = v-father and  nmenu.ln = v-ln no-lock.
			{mesg.i 9860} update v-ans.
			if v-ans eq false then next.

			do transaction on error undo, retry: /* sasco - удаление прав доступа на пункт меню по имени функции */
				message "Удалить права пользователей на этот пункт меню?" update wantDel.
				hide message no-pause.

				/* 19.07.2004 MX nadezhda - удаление пункта меню со всеми его подменю */
				run nmenudel (nmenu.fname, wantDel). /* wantDel - by sasco */
                                l-change = true. /*18.04.2006 u00121*/
				for each b-nmenu where b-nmenu.father eq v-father and  b-nmenu.ln ge v-ln by b-nmenu.ln:
					b-nmenu.ln = b-nmenu.ln - 1.
				end.
			end.
			next.
		end.
		else
			if frame-value eq "" then
			do:
				create nmenu.
					nmenu.father = v-father.
					nmenu.ln = v-max + 1.
				display nmenu.ln nmenu.fname with frame nmenu.

				create nmdes.
					nmdes.lang = "RR".
			end.
			else
			do:
				find nmenu where nmenu.father eq v-father and  nmenu.ln eq integer(frame-value).
				find nmdes where nmdes.lang eq "RR" and  nmdes.fname eq nmenu.fname no-error.
				if not available nmdes then
				do:
					create nmdes.
					nmdes.lang = "RR".
				end.
			end.
		display nmdes.des nmenu.fname nmenu.link nmenu.proc nmenu.ln
		with frame nmenu.
		oldFname = nmenu.fname.
		prompt-for nmdes.des nmenu.fname nmenu.link nmenu.proc nmenu.ln with frame nmenu.

		if nmenu.ln entered or nmdes.des entered or nmenu.fname entered or nmenu.link entered or nmenu.proc entered then l-change = true. /*18.04.2006 u00121*/


		if nmenu.ln entered then
		do:
			if input nmenu.ln eq 0 then
			do:
				v-ln = nmenu.ln.
				for each nmdes where nmdes.fname eq nmenu.fname:
					delete nmdes.
				end.
				message "Удалить права пользователей на этот пункт меню?" update wantDel.
				hide message no-pause.
				if wantDel then
				do:
					displ "Удаление прав доступа..." with row 5 centered overlay no-label frame delfr. pause 0.
					for each ofc no-lock:
						for each sec where sec.ofc = ofc.ofc and sec.fname = nmenu.fname:
							delete sec.
						end.
					end.
					hide frame delfr. pause 0.
				end.
				delete nmenu.
				for each b-nmenu where b-nmenu.father eq v-father and  b-nmenu.ln ge v-ln by b-nmenu.ln:
					b-nmenu.ln = b-nmenu.ln - 1.
				end.
				next.
			end.
			else
				for each b-nmenu where b-nmenu.father eq v-father and  b-nmenu.ln ge input nmenu.ln by b-nmenu.ln descending:
					b-nmenu.ln = b-nmenu.ln + 1.
				end.
		end.
		if nmenu.fname entered then
			for each b-nmenu where b-nmenu.father eq nmenu.fname:
				b-nmenu.father = input nmenu.fname.
			end.
		assign nmdes.des nmenu.fname nmenu.link nmenu.proc nmenu.ln.
		/* sasco - переделать права доступа если переименовали FNAME пункта меню */
		if oldFname <> "" and oldFname <> nmenu.fname then
		do:
			for each ofc no-lock:
				for each sec where sec.ofc = ofc.ofc and sec.fname = oldFname:
					sec.fname = nmenu.fname.
				end.
			end.
		end.
		nmdes.fname = nmenu.fname.


		if nmenu.link eq "" and nmenu.proc eq "" then
		do:
			v-father = nmenu.fname.
			next.
		end.
	end.
	if v-father ne "MENU" then
	do:
		find nmenu where nmenu.fname eq v-father.
		v-father = nmenu.father.
	end.
	else
	do:
		/*18.04.2006 u00121**********************************************************************************************************************************/
		if l-change then
		do:
			message "Возможно меню было изменено." skip
				"Произвести синхронизацию с филиалами?" view-as alert-box question buttons yes-no title "Синхронизация меню" update sync-it as log.
			if sync-it then
				run callsynnm.
		end.
		/*18.04.2006 u00121**********************************************************************************************************************************/

		leave.
	end.
end.


