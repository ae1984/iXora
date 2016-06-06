/* dealread.p
 * MODULE
        Модуль ЦБ (используется таблица deal) 
 * DESCRIPTION
        Редактирование Справочника по ЦБ 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        dealref.p
 * MENU
        7-1-4 
 * BASES
        BANK 
 * AUTHOR
        11/07/08 id00209
 * CHANGES
*/

{global.i}

def var v-deal like dealhist.deal.

def frame deal
	v-deal 		label "Номер сделки........."	skip
	dealhist.rdt 	label "Дата редактирования.."	skip 
	dealhist.fname 	label "Редактированное поле." format 'x(20)'	skip
	dealhist.who 	label "Офицер..............."	skip
	dealhist.oldval label "Старое значение......"	skip
	dealhist.newval label "Новое значение......."	skip
	dealhist.com	label "Коментарий..........." format 'x(20)'	skip
with row 5 side-label centered   width 80.


repeat:  /* начало огромного репита */

on help of v-deal in frame deal do:
    {itemlist.i 
        &file = " dealhist "
        &frame = "row 6 width 110 centered 28 down overlay "
        &where = " dealhist.deal ne '' "
        &flddisp = " dealhist.deal label 'Номер' format 'x(9)' dealhist.fname label 'Редактированное поле' format 'x(20)' dealhist.who label 'Офицер' dealhist.oldval label 'Старое значение' dealhist.newval label 'Новое значение' dealhist.com label 'Коментарий' format 'x(20)' "
        &chkey = "deal"
        &chtype = "string"
        &index  = " deal "
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }

v-deal = dealhist.deal.
displ v-deal with frame deal.
/*

	displ
	dealhist.rdt 	label "Дата редактирования" 
	dealhist.fname 	label "Редактированное поле" format 'x(20)'
	dealhist.who 	label "Офицер"
	dealhist.oldval label "Старое значение"
	dealhist.newval label "Новое значение"
	dealhist.com	label "Коментарий" format 'x(20)'
        with frame deal row 5 side-label centered width 80.
*/
	end.


update v-deal with frame deal.
find first dealhist where dealhist.deal = v-deal no-lock no-error.

	if avail dealhist then displ
	dealhist.rdt dealhist.fname dealhist.who dealhist.oldval dealhist.newval dealhist.com 
        with frame deal.


message "Для выхода нажмите пробел и F4". pause.

end.  /* конец огромного репита */