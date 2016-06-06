/* linfo.p
 * MODULE
        Информация о логине пользователя
 * DESCRIPTION
        Показывает имя пользователя и профит-центр.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
        linfobr.p
 * MENU
        8.5.9
 * AUTHOR
        20.08.04 - suchkov
 * CHANGES
        06.07.06 - u00121 теперь поиск логина происходит по всем филиалам, и выдается весь список филиалов в котором он нашелся
 	    04/10/2007 madiyar - изменил формат вывода
*/
{mainhead.i} 

define variable v-ofc no-undo like ofc.ofc .
define new shared variable v-res as log no-undo.

def new shared temp-table t-temp no-undo
	field profitname as char format "x(30)"
	field branch as char format "x(70)"
	field name like ofc.name.

def query q-ofc for t-temp.
def browse b-ofc query q-ofc 
        display t-temp.branch  t-temp.profitname  with no-labels 26 down separators .

def frame f-ofc  b-ofc with size 109 by 30.


update v-ofc label "Введите логин" with centered .

{r-branch.i &proc ="linfobr (input v-ofc)"}


if v-res then
do:
	find last t-temp no-lock no-error.
	displ v-ofc t-temp.name with frame f-nm  centered row  2 no-labels .
	OPEN QUERY  q-ofc FOR EACH t-temp no-lock.
	ENABLE  b-ofc WITH FRAME f-ofc.
end.
else
do:
	message "Пользователь не найден!" view-as alert-box.
	return.
end.	

WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
