/* cashw.p                                                                      			
 * MODULE
        Кассовые операции
 * DESCRIPTION
	Перевод профит-центров (РКО) на постоянную работу через кассу в пути 100200
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
	
 * AUTHOR
        30/05/2006 u00121
 * CHANGES
*/
{global.i}

def temp-table t-hist no-undo
	field dep like ppoint.dep /*код РКО*/
	field sts as log format "Добавлен/Удален" /*статус - добавлен в список постоянно работающих через кассу в пути = true, удален из списка = false*/
	field who as char /*кто изменил стату РКО*/
	field dt  as date /*дата изменения*/
	field tm as int
	index hidx dep dt tm.  /*время изменения*/

def temp-table t-ppoint no-undo /*таблица для существующих профит-центров (не переведенных на принудительный переход)*/
	field dep like ppoint.dep
	field name like ppoint.name
	field sts as log init true format "/?"
	index idx dep .


def temp-table t-CASHW no-undo /*таблица для профит-центров переведенных на принудительный переход*/
	field dep like ppoint.dep
	field name like ppoint.name
	field dt as date init ?
	field tm as int
	field sts as log init false format "/?"
	index idx dep .


def temp-table t-cascheck no-undo /*таблица для анализа внесенных изменений в список профит-центров переведенных на 100200*/
	field dep like t-CASHW.dep.

def query q-ppoint for t-ppoint. 
def query q-CASHW  for t-CASHW.


def browse b-CASHW 
    query q-CASHW no-lock 
        display 
                t-CASHW.name format "x(25)"  t-cashw.dt string(t-cashw.tm, "HH:MM:SS") t-cashw.sts
                    with 7 down width 70 title "Работают через кассу в пути" no-labels.
                          				

def browse b-ppoint             	
    query q-ppoint no-lock 
        display 
                t-ppoint.name  format "x(34)" t-ppoint.sts
                    with 5 down width 40 title "Работают через кассу" no-labels.

def frame f-CASHW
    b-CASHW help ""
  with column 1 no-label  row 11.

def frame f-ppoint
    b-ppoint help ""
  with column 1 no-label  row 2.

def frame f-info "ПЕРЕВОД РКО НА ПОСТОЯННУЮ РАБОТУ ЧЕРЕЗ КАССУ В ПУТИ" with centered row 1 no-box.

def frame fhelp "<Tab>   - Переход между окнами "  skip 
		"<F1>    - Сохранение"  skip
		"<Enter> - Перенос РКО" skip
		"<F4>    - Выход" skip(1)
		"Примечание: знаком <?> помечаются" skip
		"РКО, статус которых не вступил в " skip
		"действие" skip
  with row 3 column 45 no-box .                  


on tab next-frame.

def var i as int init 0 no-undo.
def var v-dep as int init 0 no-undo.



function savecas return int. /*функция сохранения внесенных изменений*/

	for each  t-cascheck: delete  t-cascheck. end.

	find last sysc where sysc.sysc = 'CASHW' no-error.
	if avail sysc then
	do:
		repeat i = 1 to num-entries(sysc.chval):
			if int(entry(i,sysc.chval)) > 0 then
			do:
				create t-cascheck.
				assign t-cascheck.dep = int(entry(i,sysc.chval)).
			end.
		end.
		for each t-CASHW no-lock.
			find last t-cascheck where t-cascheck.dep = t-CASHW.dep no-lock no-error.
			if not avail t-cascheck then 
			do:	/*департамент добавлен в список постоянной работы через кассу в пути*/
				create t-hist.
				assign	
					t-hist.dep = t-CASHW.dep
					t-hist.sts = true
					t-hist.who = g-ofc
					t-hist.dt  = today
					t-hist.tm  = time.

			end.
		end.
		for each t-cascheck no-lock.
			find last t-CASHW where t-CASHW.dep = t-cascheck.dep no-lock no-error.
			if not avail t-CASHW then 
			do:	/*департамент удален из списка постоянной работы через кассу в пути*/
				create t-hist.
				assign	
					t-hist.dep = t-cascheck.dep
					t-hist.sts = false
					t-hist.who = g-ofc
					t-hist.dt  = today
					t-hist.tm  = time.
			end.
		end.

		sysc.chval = "".
		for each t-CASHW break by t-CASHW.dep.
			message "Сохранение...". pause 0.
			sysc.chval = sysc.chval + string(t-CASHW.dep) + ",".
		end.
	end.
	message "Сохранено" view-as alert-box.
end function.
/*ФОРМИРОВАНИЕ ВРЕМЕННЫХ ТАБЛИЦ*****************************************************************************************************************************************************/
find last sysc where sysc.sysc = 'CASHW' no-lock no-error.
if avail sysc then
do:
	repeat i = 1 to num-entries(sysc.chval):
		v-dep = int(entry(i,sysc.chval)).
		find last ppoint where ppoint.dep = v-dep no-lock no-error.
		if avail ppoint then
		do:
			create t-CASHW.
			assign
				t-CASHW.dep = ppoint.dep
				t-CASHW.name = ppoint.name.
			find last hcashw where hcashw.dep = t-cashw.dep no-lock no-error.
			if avail hcashw then
			do:
				assign
					t-cashw.dt = hcashw.dt
					t-cashw.tm = hcashw.tm
					t-cashw.sts = hcashw.sts.
			end.
		end.
	end.
end.

for each ppoint no-lock.
	find last t-CASHW where t-CASHW.dep = ppoint.dep no-lock no-error.
	if not avail t-CASHW then
	do:
		create t-ppoint.
		assign 
			t-ppoint.dep = ppoint.dep
			t-ppoint.name = ppoint.name.
	end.
end.
/***********************************************************************************************************************************************************************************/

/*ПЕРЕНОС РКО МЕЖДУ ОКНАМИ (ФРАЙМАМИ) ПО НАЖАТИЮ КЛАВИШИ ENTER**********************************************************************************************************************/
on return of b-ppoint in frame f-ppoint
do:
	if avail t-ppoint then
	do:
		create t-CASHW.
		assign 
			t-CASHW.dep = t-ppoint.dep
			t-CASHW.name = t-ppoint.name.

			find last hcashw where hcashw.dep = t-cashw.dep no-lock no-error.
			if avail hcashw and hcashw.sts then
			do:
				assign
					t-cashw.dt = hcashw.dt
					t-cashw.tm = hcashw.tm
					t-cashw.sts = hcashw.sts.
			end.

		delete t-ppoint.

		open query q-ppoint for each t-ppoint.
		
		disable b-CASHW with frame f-CASHW.
		open query q-CASHW for each t-CASHW.
		enable b-CASHW with frame f-CASHW.
	end.
end.

on return of b-CASHW in frame f-CASHW
do:
	if avail t-CASHW then
	do:
		create t-ppoint.
		assign 
			t-ppoint.dep = t-CASHW.dep
			t-ppoint.name = t-CASHW.name.

		find last sysc where sysc.sysc = 'CASHW' no-error.
		if avail sysc and lookup(string(t-ppoint.dep), sysc.chval) > 0 then
			t-ppoint.sts  = false.
			
		delete t-CASHW.

		open query q-CASHW for each t-CASHW.

		disable b-ppoint with frame f-ppoint.
		open query q-ppoint for each t-ppoint.
		enable b-ppoint with frame f-ppoint.
	end.
end.
/***********************************************************************************************************************************************************************************/

/*СОХРАНЕНИЕ ВНЕСЕННЫХ ИЗМЕНЕНИЙ ПО НАЖАТИЮ КЛАВИШИ F1******************************************************************************************************************************/
on "go" of browse b-ppoint 
do:
	savecas().
end.

on "go" of browse b-CASHW 
do:
	savecas().	
end.
/***********************************************************************************************************************************************************************************/


/*ПРОВЕРКА ВНЕСЕННЫХ ИЗМЕНЕНИЙ НА СОХРАНЕНИЕ****************************************************************************************************************************************/
def var v-add as log init false no-undo.
def var v-del as log init false no-undo.
def var v-save as log init false no-undo.


on 'end-error' of browse b-ppoint or 'end-error' of browse b-CASHW
do:
	find last sysc where sysc.sysc = 'CASHW' no-lock no-error.
	if avail sysc then
	do:
		repeat i = 1 to num-entries(sysc.chval):
			if int(entry(i,sysc.chval)) > 0 then
			do:
				create t-cascheck.
				assign t-cascheck.dep = int(entry(i,sysc.chval)).
			end.
		end.
		for each t-CASHW no-lock.
			find last t-cascheck where t-cascheck.dep = t-CASHW.dep no-lock no-error.
			if not avail t-cascheck then v-add = true.
		end.
		for each t-cascheck no-lock.
			find last t-CASHW where t-CASHW.dep = t-cascheck.dep no-lock no-error.
			if not avail t-CASHW then v-del = true.
		end.
		
		if v-add or v-del then
			MESSAGE "Внесенные изменения не были сохранены!" skip "Сохранить?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE v-save.
		if v-save then
			savecas().
	end.

	for each t-hist no-lock break by t-hist.dep by t-hist.dt by t-hist.tm.
		create hcashw.
			buffer-copy t-hist to hcashw.
	end.
end.
/***********************************************************************************************************************************************************************************/



open query q-ppoint for each t-ppoint.
open query q-CASHW for each t-CASHW.

view frame f-info.
view frame f-ppoint.
view frame f-CASHW.
view frame fhelp.

enable b-ppoint with frame f-ppoint.
enable b-CASHW with frame f-CASHW.

apply "VALUE-CHANGED" to BROWSE b-CASHW.
apply "VALUE-CHANGED" to BROWSE b-ppoint.
 
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

disable b-ppoint with frame f-ppoint.
disable b-CASHW with frame f-CASHW.


