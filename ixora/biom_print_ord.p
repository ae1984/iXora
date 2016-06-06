/* biom_print_ord.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Формирование и печать ордера клиенту, подтверждающего количество разрешенных проводок
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
	subcod.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19/09/05 u00121
 * CHANGES
*/

{global.i}
def input param  v-cif as char.
def input param  v-accnt as char.
def input param  v-cnt as int.

	output to bioorder.txt.
		put unformatted skip (1) fill("=",80) skip.
		put unformatted "Отчет о количестве произведенных переводных операций " skip.
		put unformatted "по клиенту " v-accnt skip.
		put unformatted fill("-",80) skip.
		find last cif where cif.cif = v-cif no-lock no-error.
		put unformatted "Наименование компании " cif.name skip.
		put unformatted fill("-",80) skip(1).
		put unformatted "Дата: " g-today skip.
		put unformatted "Количество операций: " v-cnt skip (1).
		put unformatted fill("=",80) skip(1).
	output close.

unix silent value( 'prit bioorder.txt').
