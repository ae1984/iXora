/* biocon.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Контроль клиентов не прошедших биометрический анализ
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
        2-7-5
 * AUTHOR
        19/09/05 u00121
 * BASES
        BANK
 * CHANGES
        05/05/2010 galina - перекомпиляция
*/


{global.i}



define variable v-send as char init '' no-undo.
define variable v-tem  as char init '' no-undo.
define variable v-mess as char init '' no-undo.
define variable v-rec  as char init '' no-undo.
def var v-cif like cif.cif  no-undo.
def var v-cifname like cif.name no-undo.
def var v-cifbiom like cif.biom no-undo.
def var v-cifbiomold like cif.biom no-undo.

DEFINE VARIABLE ok AS LOGICAL NO-UNDO.

define query q1 for biocmprhst, cif, biocmprres.

def buffer b-cif for cif.

def var v-upl as char format "x(50)" no-undo.
def var v-fio like cif.name format "x(50)" no-undo.

def button btn-clsbio label "Настройка биометрии".

def browse b1 query q1 no-lock
  display
      	biocmprhst.cif
        biocmprres.name format "x(35)"
        biocmprhst.who
        biocmprhst.dt
        biocmprhst.cnt label "Кол-во" format "zz9"
   with 10 down separators single title "БИОМЕТРИЧЕСКИЙ КОНТРОЛЬ".



define frame f1
   b1 help "F1-Акцепт, F8-Запретить, Enter-Коррект., F5-Настр., F4-Выход"
   	v-fio format "x(50)"
	skip
	v-upl format "x(50)"
	skip
with row 2.


on "get" of browse b1
do:
	def frame fr-cls
		v-cif label "Код клиента" help "F2 - поиск клиента"
		v-cifname no-label
			skip
		v-cifbiom
		with frame fr-cls row 3 overlay top-only side-label centered title ' Настройка биометрии '.

	if query-off-end("q1") then
	do:
		v-cif = ''.
	end.
	else
	do:
		find current biocmprhst no-lock.
		v-cif = biocmprhst.cif.
	end.
		find last b-cif where b-cif.cif = v-cif no-lock no-error.
		if avail b-cif then
		do:
			v-cifname = b-cif.name.
			v-cifbiom = b-cif.biom.
		end.
		displ v-cifname v-cifbiom with frame fr-cls.

		update v-cif  with frame fr-cls.
		if v-cif entered then
		do:
			find last b-cif where b-cif.cif = v-cif no-lock no-error.
			if avail b-cif then
			do:
				v-cifname = b-cif.name.
				v-cifbiom = b-cif.biom.
			end.
			displ v-cifname v-cifbiom with frame fr-cls.
		end.
		v-cifbiomold = v-cifbiom.
		OK = false.
		update v-cifbiom with frame fr-cls.
		if v-cifbiomold <> v-cifbiom then
		do:
			if v-cifbiom then
				message "Вы уверены, что хотите установить признак?" view-as alert-box WARNING BUTTONS YES-NO UPDATE OK.
			else
				message "Вы уверены, что хотите снять признак?" view-as alert-box WARNING BUTTONS YES-NO UPDATE OK.
		end.
		if OK then
		do:
			find last b-cif where b-cif.cif = v-cif no-error.
			if avail b-cif then
			do:
				b-cif.biom = v-cifbiom.
			end.
		end.


		open query q1 for each  biocmprhst where biocmprhst.idres = 4 or biocmprhst.idres = 2, each cif of biocmprhst, each biocmprres of biocmprhst.
		enable b1 with frame f1 .
		run dop_info.
end.

on "go" of browse b1
do:
	if query-off-end("q1") then message  "Акцептовать 'ничего'?" skip "Вы утомились... отдохните 5 мин.!" view-as alert-box.
	else
	do:
		find current biocmprhst exclusive-lock.
		if avail biocmprhst then
		do:
			if biocmprhst.cnt <= 0  then
			do:
				message "Нельзя акцептовать "  biocmprhst.cnt " проводок!" view-as alert-box.
				OK = false.
			end.
			else
				OK = true.

			if OK then
				message "Вы уверены, что хотите разрешить "  biocmprhst.cnt " проводок," skip "по клиенту " biocmprhst.cif "?" view-as alert-box WARNING BUTTONS YES-NO UPDATE OK.
			if OK then
			do:
				biocmprhst.idres = 1.
				find last biojhcnt where biojhcnt.cif = biocmprhst.cif and biojhcnt.dt = g-today no-error.
				if not avail biojhcnt then
				do: /*если такая запись не найдена*/
					create biojhcnt. /*создаем еее*/
						biojhcnt.cif = biocmprhst.cif. /*счет*/
						biojhcnt.dt = g-today. /*дата*/
				end.
				biojhcnt.cnt = biojhcnt.cnt + biocmprhst.cnt. /*если даже запись и была неайдена, просто увеличиваем колисчество разрешенных проводок*/

				run biom_print_ord(input  biocmprhst.cif, input "", input  biocmprhst.cnt).

				find last ofc where ofc.ofc = g-ofc no-lock no-error.
				if avail ofc then
				do:
					v-rec  = biocmprhst.who + '@texakabank.kz'.
					v-send = g-ofc + '@texakabank.kz'.
					v-tem  = 'Биометрический контроль:  Клиент ' + biocmprhst.cif.
					v-mess = 'Акцептован клиент: ' + biocmprhst.cif + '. Разрешено: '+ string(biocmprhst.cnt) + ' проводок. Акцептовал: ' + ofc.name + ', ' + string(g-today, '99/99/9999') + '  ' + string(time, "HH:MM:SS") + '. Общая сумма разрешенных проводок по клиенту ' + string(biojhcnt.cnt).
					run mail(v-rec, v-send, v-tem, v-mess, "", "", "").
				end.
			end.
			open query q1 for each  biocmprhst where biocmprhst.idres = 4 or biocmprhst.idres = 2, each cif of biocmprhst, each biocmprres of biocmprhst.
			enable b1 with frame f1 .
  			run dop_info.
		end.
	end.
end.


on "clear" of browse b1
do:
	if query-off-end("q1") then message  "Как по Вашему, можно ли отменить 'ничто'???" view-as alert-box.
	else
	do:
		find current biocmprhst exclusive-lock.
		if avail biocmprhst then
		do:
			message "Вы уверены, что хотите отказать в Акцепте" skip "по клиенту " biocmprhst.cif "?" view-as alert-box WARNING BUTTONS YES-NO UPDATE OK.
			if OK then
				biocmprhst.idres = 0.

			find last ofc where ofc.ofc = g-ofc no-lock no-error.
			if avail ofc then
			do:
				v-rec  = biocmprhst.who + '@texakabank.kz'.
				v-send = g-ofc + '@texakabank.kz'.
				v-tem  = 'Биометрический контроль:  Клиент1 ' + biocmprhst.cif.
				v-mess = 'Запрет акцепта для клиента: ' + biocmprhst.cif + '. Запретил акцепт: ' + ofc.name + ', ' + string(g-today, '99/99/9999') + '  ' + string(time, "HH:MM:SS") + '.'.
				run mail(v-rec, v-send, v-tem, v-mess, "", "", "").
			end.
		end.
		open query q1 for each  biocmprhst where biocmprhst.idres = 4 or biocmprhst.idres = 2, each cif of biocmprhst, each biocmprres of biocmprhst.
		enable b1 with frame f1 .
		run dop_info.
	end.
end.


/******************************************************************************************************************************************************/
on "return" of browse b1
do:
	if query-off-end("q1") then message  "Чтобы что-то изменить," skip "надо что-то создать!!!" view-as alert-box.
	else
	do:
		find current biocmprhst  exclusive-lock.
		if avail biocmprhst then
		do:
			def frame fr
			      	biocmprhst.cif
		     		cif.name label "Клиент"
				biocmprhst.cnt label "Кол-во" format "zz9"
				biocmprhst.cif
					with frame fr row 3 overlay top-only side-label col 5 title ' Редактирование '.
			displ
			      	biocmprhst.cif
			     	cif.name
				biocmprhst.cif
					with frame fr.

			update
				biocmprhst.cnt label "Кол-во" format "zz9"
					with frame fr.

			hide frame fr.
			open query q1 for each  biocmprhst where biocmprhst.idres = 4 or biocmprhst.idres = 2, each cif of biocmprhst, each biocmprres of biocmprhst.
			enable b1 with frame f1 .
	  		run dop_info.
		end.
	end.
end.
/******************************************************************************************************************************************************/

/******************************************************************************************************************************************************/
on "CURSOR-UP" of browse b1
do:
	get prev q1.

	if query-off-end("q1") then get first q1.
	run dop_info.
end.

on "CURSOR-DOWN" of browse b1
do:
	get next q1.
	if query-off-end("q1") then get last q1.
	run dop_info.
end.
/******************************************************************************************************************************************************/

on 'end-error' of browse b1
do:
	hide all.
end.


open query q1 for each  biocmprhst where biocmprhst.idres = 4 or biocmprhst.idres = 2 , each cif of biocmprhst, each biocmprres of biocmprhst .
	run dop_info.
enable b1 with frame f1 .
wait-for window-close of frame f1 focus browse b1.

/******************************************************************************************************************************************************/
PROCEDURE dop_info.
	if query-off-end("q1") then
	do:
		v-fio = ''.
		v-upl = ''.
	end.
	else
	do:
		find last b-cif where b-cif.cif = biocmprhst.cif no-lock no-error.
		if avail b-cif then
		do:
			v-fio = b-cif.prefix + " " + b-cif.name.

			v-upl = biocmprhst.upl.
			find last upl where upl.uplid = int(v-upl) no-lock no-error.
			if avail upl then
				v-upl = upl.fio.
			else
			do:
				find last sub-cod where sub-cod.acc = biocmprhst.cif and  sub-cod.sub = 'cln' and sub-cod.d-cod = v-upl no-lock no-error.
				if avail sub-cod then
				do:
					v-upl = sub-cod.rcode.
				end.
			end.
		end.
	end.
	displ v-fio v-upl with frame f1 no-labels.
end procedure.
/******************************************************************************************************************************************************/

