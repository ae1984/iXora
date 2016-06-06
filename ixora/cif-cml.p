/* cif-cml.p
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
 * BASES
        BANK COMM
 * CHANGES
        10.09.2004 saltanat - Полностью изменила по новому требованию о внесении нескольких упол.лиц.
	    19.09.2005 u00121 - Добавлены кнопки Архив, Сверка отпечатков, на котр. 2-4-1-6, Отпечатки пальцев
	    11/04/2006 madiar - в вызов bisaveres добавил входной параметр - показывать или нет фрейм с запросом количества разрешенных проводок
	    25/09/2008 galina - счет 20-тизначный
	    26/09/2008 galina - явно указала ширину фреймa fr2
	    30/09/2008 galina - явно указала ширину фреймa fr1
        05/05/2010 - добавила дополнительную информацию по доверенному лицу созласно ТЗ 639 от 17/03/2010
        06/05/2010 galina - явно указала ширину фрейма fr
        16/01/2012 evseev - ТЗ-1245. Добавил РНН
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{global.i}
{yes-no.i}
{chk12_innbin.i}
def var yn as log initial false format "да/нет".
def shared var s-cif like cif.cif.
def var v-aaa like aaa.aaa.
def var v-badd1 as char.
def var v-badd2 as char.
def var v-badd3 as char.
def var id as inte.
def buffer buff_upl for uplcif.

def temp-table waaa
    field aaa as char
    field lgr as char
    field midd as char
index main is primary unique lgr midd aaa.

def temp-table wupl
    field id    as   inte
    field upl   as   inte
    field badd1 as   char
    field badd2 as   char
    field badd3 as   char
index main is primary unique upl.

DEFINE QUERY q1 FOR uplcif.
def browse b1
query q1
displ
    uplcif.dop     label 'Счет' format 'x(20)'
    uplcif.coregdt label 'Дата рег.' format '99/99/99'
    uplcif.finday  label 'Дата окон.' format '99/99/99'
    uplcif.badd[1] label 'ФИО' format 'x(20)'
    uplcif.badd[2] label 'Пасп/удов N' format 'x(15)'
with 12 down title ' Доверенное лицо '.

DEFINE BUTTON bloo LABEL "LOOK".
DEFINE BUTTON bext LABEL "Выход".
DEFINE BUTTON barch LABEL "Архив".
DEFINE BUTTON bcompare LABEL "Сверка отпечатков".
DEFINE BUTTON biocon LABEL "на котр. 2-4-1-6".
DEFINE BUTTON bfinger LABEL "Отпечатки пальцев".
DEFINE BUTTON bext2 LABEL "Выход из архива".

/**********************************************************************************/
DEFINE QUERY q2 FOR uplcif. /*запрос архива*/

def browse b2
	query q2
	displ
    		uplcif.dop     label 'Счет' format 'x(20)'
    		uplcif.coregdt label 'Дата рег.' format '99/99/99'
    		uplcif.finday  label 'Дата окон.' format '99/99/99'
    		uplcif.badd[1] label 'ФИО' format 'x(20)'
    		uplcif.badd[2] label 'Пасп/удов N' format 'x(15)'
	with 12 down title 'Архив доверенностей ' .
/**********************************************************************************/


def frame fr2
     b2 skip
     bext2
     with width 90 centered overlay row 1 top-only.



def frame fr1
     b1 skip
     bloo
     barch
     bcompare
     biocon
     bfinger
     bext with centered width 90 overlay row 1 top-only.

def var v-bdt as date.
def var v-bplace as char.
def var v-adres as char.
def frame fr
    uplcif.dop     label 'Счет' colon 26 format 'x(20)'      skip
    uplcif.coregdt label 'Дата регистр.доверенности' colon 26 format '99/99/9999' skip
    uplcif.finday  label 'Дата оконч.доверенности' colon 26 format '99/99/9999' skip
    '-----------------------------------------------------------------------------------------' at 5 skip
    uplcif.badd[1] label 'ФИО' colon 26 format 'x(40)' skip
    v-bdt label 'Дата рождения' format "99/99/9999" validate (v-bdt <> ?, 'Введите дату рождения') colon 26 skip
    v-bplace label 'Место рождения' format "x(40)" validate(trim(v-bplace) <> '','Введите место рождения') colon 26 skip
    v-adres label 'Юридический адрес' colon 26 format 'x(60)' skip
    '------------------------------------Документ удостоверяющий личность---------------------' at 5  skip
    uplcif.badd[2] label 'Пасп/удов N' colon 26 format 'x(40)' skip
    uplcif.badd[3] label ' Кем/когда выдан' colon 26 format 'x(40)' skip
    uplcif.rnn label ' ИИН' colon 26 format 'x(12)' validate((chk12_innbin(uplcif.rnn)),'Неправильно введён БИН/ИИН') skip

with frame fr row 3 overlay top-only width 100 side-label col 5 title ' Доверенное лицо '.



on "end-error" of frame fr2 do:
    open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
	ENABLE all with frame fr1 centered overlay top-only.
end.

/*Сверка отпечатков пальцев *********************************************************************************************************/
def var res-compare as int. /*результат сверки*/
DEFINE VARIABLE ok AS LOGICAL NO-UNDO.
ON CHOOSE OF bcompare IN FRAME fr1
do:
	find last cif where cif.cif = s-cif no-lock no-error.
	if avail cif and cif.biom then
	do:
		find current uplcif no-lock.
		find last upl where upl.uplid = uplcif.uplid no-lock no-error.
		if upl.finger then
		do:
		    	run fngrcompare(string(cif.cif), string(uplcif.uplid), output res-compare).
			case res-compare:
				when 0 then
				do:
					message "Сверка не прошла!" skip "Отправить доверенное лицо на контроль в п.п. 2-4-1-6?" view-as alert-box WARNING BUTTONS YES-NO UPDATE OK.
					if OK then
						res-compare = 4. /*отправим как исключение по сверке*/
				end.
				when 1 then
					message "Сверка прошла успешно!" view-as alert-box.
				when 3 then
					message "Произошла не определенная ошибка сверки отпечатков пальцев," skip "либо сканирование было принудительно прекращено!" view-as alert-box.
			end case.
			run biosaveres(input cif.cif, input string(uplcif.uplid), input res-compare, yes).
		end.
		else
			message "Отпечатки доверенного лица " uplcif.badd[1] " отсутствуют!" view-as alert-box.
	end.
	else
		message "Клиент не контролируется биометрией!" view-as alert-box.

	open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
	ENABLE all with frame fr1 centered overlay top-only.
end.
/************************************************************************************************************************************/

/*отправка доверенного лица на контроль в 2-4-1-6**************************************************************************************/

on choose of biocon in frame fr1
do:
	def var v-upl as char format "x(50)".
	def frame f-upl /*красивый фраме для ввода количества проводок*/
		v-upl
	     with centered overlay row 1 top-only title "Введите Ф.И.О.".

	find last cif where cif.cif = s-cif no-lock no-error.
	if avail cif and cif.biom then
	do:
		update v-upl with frame f-upl.
		if v-upl entered then
		do:
			run biosaveres(input s-cif, input v-upl, input 2, yes).
		end.
	end.
	else
		message "Клиент не контролируется биометрией!" view-as alert-box.

	open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
	ENABLE all with frame fr1 centered overlay top-only.

end.
/************************************************************************************************************************************/

/*Архив действоваших доверенностей***************************************************************************************************/
ON CHOOSE OF barch IN FRAME fr1
do:

	find cif where cif.cif = s-cif no-lock no-error.
	if not avail cif then
	do:
   		message 'Клиент не найден!' view-as alert-box buttons ok.
   		return.
	end.

	open query q2 for each uplcif where uplcif.cif = s-cif and uplcif.finday < g-today.
	enable all with frame fr2.
	WAIT-FOR choose of bext2.
	/*hide frame fr2.*/

	open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
	ENABLE all with frame fr1 centered overlay top-only.
end.
/************************************************************************************************************************************/

/*Запуск процедуры сканирования отпечатков пальцев***********************************************************************************/
ON CHOOSE OF bfinger IN FRAME fr1
do:
	find last cif where cif.cif = s-cif no-lock no-error.
	if avail cif and cif.biom then
	do:
		find current uplcif.
		find last upl where upl.uplid = uplcif.uplid no-lock no-error. /*если найдена хоть одна запись с доверенностью на выбранное доверенное лицо, и у которой стоит признак снятия отпечатков */
		if not upl.finger then
		do: /*если не найдена, значит отпечатки еще не снимались*/

			run fingers(string(cif.cif), string(uplcif.uplid) /*string(uplcif.upl)*/ ).
		end.
		else /*не позваляем снятие отпечатков второй раз*/
			message "Отпечатки доверенного лица " uplcif.badd[1] " уже сняты!" view-as alert-box.
	end.
	else
		message "Клиент не контролируется биометрией!" view-as alert-box.

	open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
	ENABLE all with frame fr1 centered overlay top-only.
end.
/************************************************************************************************************************************/

ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bloo IN FRAME fr1 do:
    find current  uplcif no-lock.
    find first  upl where upl.uplid =  uplcif.uplid no-lock no-error.
    if avail upl then do:
        v-bdt = upl.bdt.
        v-bplace = upl.bplace.
        v-adres = upl.uradr.
    end.

    displ uplcif.dop uplcif.coregdt  uplcif.finday  uplcif.badd[1] uplcif.badd[2] uplcif.badd[3] uplcif.rnn v-bdt v-bplace v-adres with frame fr.
end.
/*

ON CHOOSE OF bloo IN FRAME fr1
do:
displ
    uplcif.dop     label '                     Счет' format 'x(20)'      skip
    uplcif.coregdt label 'Дата регистр.доверенности' format '99/99/9999' skip
    uplcif.finday  label '  Дата оконч.доверенности' format '99/99/9999' skip
    uplcif.badd[1] label '             ФИО' format 'x(40)' skip
    uplcif.badd[2] label 'Пасп/удов N/дата' format 'x(40)'
    uplcif.badd[3] label ' Кем/когда выдан' format 'x(40)'
with frame fr row 3 overlay top-only side-label col 5 title ' Доверенное лицо '.
end.*/
open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.




b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

