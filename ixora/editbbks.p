/* editbbks.p
 * MODULE
	Администрирование
 * DESCRIPTION
	Заполнение БКС, адреса и РНН для СПФ
 * RUN
	Menu
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        20/09/2006 u00121
 * CHANGES
*/

{mainhead.i}

def temp-table t-spf no-undo
	field dep like ppoint.depart label "ID"
	field name like ppoint.name
	field bks as char label "БКС" format "x(40)"
	field region as char label "Район"  help "Например: Медеуский р-он г.Алматы" format "x(38)"
	field street as char label "Улица, дом" help "Например: ул.Розыбакиева, 37'б'" format "x(33)"
	field rnn as char label "РНН" format "x(40)"
	field change as log init false.

define var combo-spf as char format "x(30) " label "СПФ" view-as combo-box.
define var combo-list as char no-undo.

for each ppoint fields (ppoint.depart ppoint.name) no-lock break by ppoint.depart.
	create t-spf.
	assign
		t-spf.dep = ppoint.depart
		t-spf.name = ppoint.name.

	combo-list = combo-list + t-spf.name + ",".
	for each depaccnt fields (depaccnt.rem) where depaccnt.depart = ppoint.depart no-lock.
		if num-entries(depaccnt.rem, "$") > 1 then
			t-spf.bks = entry(1,depaccnt.rem, "$") .
		if num-entries(depaccnt.rem, "$") > 2 then
			t-spf.region = entry(2,depaccnt.rem, "$") .
		if num-entries(depaccnt.rem, "$") > 3 then
			t-spf.street = entry(3,depaccnt.rem, "$") .
		if num-entries(depaccnt.rem, "$") > 4 then	
			t-spf.rnn = entry(4,depaccnt.rem, "$") .
	end.
end.


form  combo-spf t-spf.dep skip 
	t-spf.bks  skip
	t-spf.region skip
	t-spf.street skip
	t-spf.rnn skip(2)
	"F4 - выйти/сохранить, если были изменения"
with frame f-spf row 5 OVERLAY SIDE-LABELS CENTERED.




ASSIGN combo-spf:LIST-ITEMS IN FRAME f-spf = combo-list.

find last t-spf where t-spf.dep = 1 no-lock no-error.
displ t-spf.dep t-spf.bks t-spf.region t-spf.street t-spf.rnn with frame f-spf.

on value-changed of combo-spf
do:
       find last t-spf where t-spf.name = SELF:SCREEN-VALUE no-lock no-error.
       displ t-spf.dep t-spf.bks t-spf.region t-spf.street t-spf.rnn with frame f-spf.
end.
enable combo-spf WITH FRAME f-spf.

on return of combo-spf
do:
    apply "go".
end.


displ combo-spf with frame f-spf.
repeat:
	update combo-spf with frame f-spf.

	update t-spf.bks with frame f-spf. 
	if  t-spf.bks entered then
		t-spf.change = true.

	update t-spf.region with frame f-spf. 
	if t-spf.region entered then
		t-spf.change = true.

	update t-spf.street with frame f-spf. 
	if t-spf.street entered then
		t-spf.change = true.

	update t-spf.rnn with frame f-spf.
	if t-spf.rnn entered then
		t-spf.change = true.

	on "end-error" of frame f-spf /*если нажали F4, проверим были ли изменения, если были предложим сохранить*/ 
	do:
		find last t-spf where t-spf.change no-lock no-error.
		if avail  t-spf then
		do:
			message "Сохранить изменения?" view-as alert-box question buttons yes-no update save-it as logical.
			if save-it then
				run save_all.
		end.
		leave.
	end.
end.

procedure save_all.
	for each t-spf where t-spf.change no-lock.
        	find last depaccnt where depaccnt.depart = t-spf.dep.
        	do transaction:
			depaccnt.rem = t-spf.bks + "$" + t-spf.region + "$" + t-spf.street + "$" + t-spf.rnn + "$".
		end.
	end.
end.