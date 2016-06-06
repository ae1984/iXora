/* casdp3.p
 * MODULE
        Кассовые операции
 * DESCRIPTION
	Смена статуса профит-центра  (Крупный/Мелкий)
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
        30/10/2006 u00121
 * CHANGES
*/


def temp-table t-ppoint no-undo /*таблица для мелких*/
	field dep like ppoint.dep
	field name like ppoint.name
	index idx dep .


def temp-table t-casdp3 no-undo /*таблица для крупных*/
	field dep like ppoint.dep
	field name like ppoint.name
	index idx dep .


def temp-table t-cascheck no-undo /*таблица для анализа внесенных изменений в список профит-центров*/
	field dep like t-casdp3.dep.

def query q-ppoint for t-ppoint. 
def query q-casdp3  for t-casdp3.


def browse b-casdp3 
    query q-casdp3 no-lock 
        display 
                t-casdp3.name format "x(35)"         
                    with 10 down width 38 title "КРУПНЫЕ" no-labels.

def browse b-ppoint
    query q-ppoint no-lock 
        display 
                t-ppoint.name  format "x(35)"         
                    with 10 down width 34 title "МЕЛКИЕ" no-labels.

def frame f-casdp3
    b-casdp3 help ""
  with column 40  no-label  row 2.

def frame f-ppoint
    b-ppoint help ""
  with column 4 no-label  row 2.


def frame fhelp "<Tab>   - Переход между окнами " colon 1 "<F1>    - Сохранение"  colon 40 skip
		"<Enter> - Сменить статус"    colon 1 "<F4>    - Выход"       colon 40
  with row 18 column 4 no-box .                  


on tab next-frame.

def var i as int init 0 no-undo.
def var v-dep as int init 0 no-undo.



function savecas return int. /*функция сохранения внесенных изменений*/
	find last sysc where sysc.sysc = 'casdp3' no-error.
	if avail sysc then
	do:
		sysc.chval = "".
		for each t-casdp3 break by t-casdp3.dep.
			message "Сохранение...". pause 0.
			sysc.chval = sysc.chval + string(t-casdp3.dep) + ",".
		end.
	end.
	message "Сохранено" view-as alert-box.
end function.
/*ФОРМИРОВАНИЕ ВРЕМЕННЫХ ТАБЛИЦ*****************************************************************************************************************************************************/
find last sysc where sysc.sysc = 'casdp3' no-lock no-error.
if avail sysc then
do:
	repeat i = 1 to num-entries(sysc.chval):
		v-dep = int(entry(i,sysc.chval)).
		find last ppoint where ppoint.dep = v-dep no-lock no-error.
		if avail ppoint then
		do:
			create t-casdp3.
			assign
				t-casdp3.dep = ppoint.dep
				t-casdp3.name = ppoint.name.
		end.
	end.
end.

for each ppoint no-lock.
	find last t-casdp3 where t-casdp3.dep = ppoint.dep no-lock no-error.
	if not avail t-casdp3 then
	do:
		create t-ppoint.
		assign 
			t-ppoint.dep = ppoint.dep
			t-ppoint.name = ppoint.name.
	end.
end.
/***********************************************************************************************************************************************************************************/

/*ПЕРЕНОС СПФ МЕЖДУ ОКНАМИ (ФРАЙМАМИ) ПО НАЖАТИЮ КЛАВИШИ ENTER**********************************************************************************************************************/
on return of b-ppoint in frame f-ppoint
do:
	if avail t-ppoint then
	do:
		create t-casdp3.
		assign 
			t-casdp3.dep = t-ppoint.dep
			t-casdp3.name = t-ppoint.name.
		delete t-ppoint.

		open query q-ppoint for each t-ppoint.
		
		disable b-casdp3 with frame f-casdp3.
		open query q-casdp3 for each t-casdp3.
		enable b-casdp3 with frame f-casdp3.
	end.
end.

on return of b-casdp3 in frame f-casdp3
do:
	if avail t-casdp3 then
	do:
		create t-ppoint.
		assign 
			t-ppoint.dep = t-casdp3.dep
			t-ppoint.name = t-casdp3.name.
		delete t-casdp3.

		open query q-casdp3 for each t-casdp3.

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

on "go" of browse b-casdp3 
do:
	savecas().	
end.
/***********************************************************************************************************************************************************************************/


/*ПРОВЕРКА ВНЕСЕННЫХ ИЗМЕНЕНИЙ НА СОХРАНЕНИЕ****************************************************************************************************************************************/
def var v-add as log init false no-undo.
def var v-del as log init false no-undo.
def var v-save as log init false no-undo.

on 'end-error' of browse b-ppoint or 'end-error' of browse b-casdp3
do:
	find last sysc where sysc.sysc = 'casdp3' no-lock no-error.
	if avail sysc then
	do:
		repeat i = 1 to num-entries(sysc.chval):
			if int(entry(i,sysc.chval)) > 0 then
			do:
				create t-cascheck.
				assign t-cascheck.dep = int(entry(i,sysc.chval)).
			end.
		end.
		for each t-casdp3 no-lock.
			find last t-cascheck where t-cascheck.dep = t-casdp3.dep no-lock no-error.
			if not avail t-cascheck then v-add = true.
		end.
		for each t-cascheck no-lock.
			find last t-casdp3 where t-casdp3.dep = t-cascheck.dep no-lock no-error.
			if not avail t-casdp3 then v-del = true.
		end.
		
		if v-add or v-del then
			MESSAGE "Внесенные изменения не были сохранены!" skip "Сохранить?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE v-save.
		if v-save then
			savecas().
	end.
end.
/***********************************************************************************************************************************************************************************/



open query q-ppoint for each t-ppoint.
open query q-casdp3 for each t-casdp3.

view frame f-ppoint.
view frame f-casdp3.
view frame fhelp.

enable b-ppoint with frame f-ppoint.
enable b-casdp3 with frame f-casdp3.

apply "VALUE-CHANGED" to BROWSE b-casdp3.
apply "VALUE-CHANGED" to BROWSE b-ppoint.
 
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

disable b-ppoint with frame f-ppoint.
disable b-casdp3 with frame f-casdp3.


