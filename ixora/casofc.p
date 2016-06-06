/* casofc.p
 * MODULE
        Кассовые операции
 * DESCRIPTION
	Перевод профит-центров (СПФ) на принудительный переход на кассу в пути 100200
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
        07/02/2006 u00121
 * CHANGES
*/


def temp-table t-ppoint no-undo /*таблица для существующих профит-центров (не переведенных на принудительный переход)*/
	field dep like ppoint.dep
	field name like ppoint.name
	index idx dep .


def temp-table t-casofc no-undo /*таблица для профит-центров переведенных на принудительный переход*/
	field dep like ppoint.dep
	field name like ppoint.name
	index idx dep .


def temp-table t-cascheck no-undo /*таблица для анализа внесенных изменений в список профит-центров переведенных на 100200*/
	field dep like t-casofc.dep.

def query q-ppoint for t-ppoint. 
def query q-casofc  for t-casofc.


def browse b-casofc 
    query q-casofc no-lock 
        display 
                t-casofc.name format "x(35)"         
                    with 10 down width 38 title "Касса в пути" no-labels.

def browse b-ppoint
    query q-ppoint no-lock 
        display 
                t-ppoint.name  format "x(35)"         
                    with 10 down width 34 title "Профит-центр" no-labels.

def frame f-casofc
    b-casofc help ""
  with column 40  no-label  row 2.

def frame f-ppoint
    b-ppoint help ""
  with column 4 no-label  row 2.


def frame fhelp "<Tab>   - Переход между окнами " colon 1 "<F1>    - Сохранение"  colon 40 skip
		"<Enter> - Перенос СПФ"           colon 1 "<F4>    - Выход"       colon 40
  with row 18 column 4 no-box .                  


on tab next-frame.

def var i as int init 0 no-undo.
def var v-dep as int init 0 no-undo.



function savecas return int. /*функция сохранения внесенных изменений*/
	find last sysc where sysc.sysc = 'CASOFC' no-error.
	if avail sysc then
	do:
		sysc.chval = "".
		for each t-casofc break by t-casofc.dep.
			message "Сохранение...". pause 0.
			sysc.chval = sysc.chval + string(t-casofc.dep) + ",".
		end.
	end.
	message "Сохранено" view-as alert-box.
end function.
/*ФОРМИРОВАНИЕ ВРЕМЕННЫХ ТАБЛИЦ*****************************************************************************************************************************************************/
find last sysc where sysc.sysc = 'CASOFC' no-lock no-error.
if avail sysc then
do:
	repeat i = 1 to num-entries(sysc.chval):
		v-dep = int(entry(i,sysc.chval)).
		find last ppoint where ppoint.dep = v-dep no-lock no-error.
		if avail ppoint then
		do:
			create t-casofc.
			assign
				t-casofc.dep = ppoint.dep
				t-casofc.name = ppoint.name.
		end.
	end.
end.

for each ppoint no-lock.
	find last t-casofc where t-casofc.dep = ppoint.dep no-lock no-error.
	if not avail t-casofc then
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
		create t-casofc.
		assign 
			t-casofc.dep = t-ppoint.dep
			t-casofc.name = t-ppoint.name.
		delete t-ppoint.

		open query q-ppoint for each t-ppoint.
		
		disable b-casofc with frame f-casofc.
		open query q-casofc for each t-casofc.
		enable b-casofc with frame f-casofc.
	end.
end.

on return of b-casofc in frame f-casofc
do:
	if avail t-casofc then
	do:
		create t-ppoint.
		assign 
			t-ppoint.dep = t-casofc.dep
			t-ppoint.name = t-casofc.name.
		delete t-casofc.

		open query q-casofc for each t-casofc.

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

on "go" of browse b-casofc 
do:
	savecas().	
end.
/***********************************************************************************************************************************************************************************/


/*ПРОВЕРКА ВНЕСЕННЫХ ИЗМЕНЕНИЙ НА СОХРАНЕНИЕ****************************************************************************************************************************************/
def var v-add as log init false no-undo.
def var v-del as log init false no-undo.
def var v-save as log init false no-undo.

on 'end-error' of browse b-ppoint or 'end-error' of browse b-casofc
do:
	find last sysc where sysc.sysc = 'CASOFC' no-lock no-error.
	if avail sysc then
	do:
		repeat i = 1 to num-entries(sysc.chval):
			if int(entry(i,sysc.chval)) > 0 then
			do:
				create t-cascheck.
				assign t-cascheck.dep = int(entry(i,sysc.chval)).
			end.
		end.
		for each t-casofc no-lock.
			find last t-cascheck where t-cascheck.dep = t-casofc.dep no-lock no-error.
			if not avail t-cascheck then v-add = true.
		end.
		for each t-cascheck no-lock.
			find last t-casofc where t-casofc.dep = t-cascheck.dep no-lock no-error.
			if not avail t-casofc then v-del = true.
		end.
		
		if v-add or v-del then
			MESSAGE "Внесенные изменения не были сохранены!" skip "Сохранить?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE v-save.
		if v-save then
			savecas().
	end.
end.
/***********************************************************************************************************************************************************************************/



open query q-ppoint for each t-ppoint.
open query q-casofc for each t-casofc.

view frame f-ppoint.
view frame f-casofc.
view frame fhelp.

enable b-ppoint with frame f-ppoint.
enable b-casofc with frame f-casofc.

apply "VALUE-CHANGED" to BROWSE b-casofc.
apply "VALUE-CHANGED" to BROWSE b-ppoint.
 
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

disable b-ppoint with frame f-ppoint.
disable b-casofc with frame f-casofc.


