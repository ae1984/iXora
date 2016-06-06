/* r-prod.p
 * MODULE
        Доходы-расходы в разрезе продуктов (депозиты)
 * DESCRIPTION
        Доходы-расходы в разрезе продуктов (депозиты)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-15
 * AUTHOR
        14/06/2006 nataly
 * CHANGES
        17/07/2006 nataly добавлен расчет по кредитам
        19/07/2006 nataly добавлен счет 2240
        31/07/2006 madiyar - кредиты юр.лиц - все в подразделение '205' (кредитный департамент ЦО)
        03/08/2006 madiyar - кредиты физ.лиц в ЦО (которые попадают на операционку) - все в подразделение '207' (ДПК)
        06/09/2006 madiyar - проценты по кредитам = (нач + получ на конец) - (нач + получ на начало)
        08/09/2006 madiyar - подправил мелкие ошибки
        23/10/2006 nataly  - доработали алгоритм по расчету средних остатков за месяц
*/

def var v-dep-lon as integer no-undo.
def new shared var v-mon as integer no-undo.
def new shared var v-god as integer no-undo.
def new shared var v-report-type as integer.
def new shared var v-des like cods.des label "Наименование".
def new shared var v-dep-code as char no-undo.
def frame opt
           v-dep-code label 'ЗАДАЙТЕ КОД ДЕПАРТАМЕНТА (F2-выбор)'  
            validate(can-find(codfr where codfr.codfr = "sdep" and codfr.code = v-dep-code ) ,  "Неверно задан департамент ") skip
            v-des view-as text skip
              with row 8 centered  side-label.
on help of v-dep-code in frame opt do: 
                                   run help-dep('000').
                                   v-dep-code:screen-value = return-value.
                                   v-dep-code = v-dep-code:screen-value.
                                end.



display 
	'Выберите тип отчёта (по умолчанию 1):' skip
	'1. Отчёт по депозитам.' skip
	'2. Отчёт по кредитам.' skip
	'3. Test.' skip
	with frame type-request centered no-labels.

update	v-dep-lon
	with frame type-request centered no-labels.

if v-dep-lon < 1 or v-dep-lon > 3 then
	v-dep-lon = 1.



update v-mon label 'Задайте месяц' 
       v-god label 'Задайте год' format 'zzz9' with frame ss centered .

/*ВНИМАНИЕ! При добавлении новых пунктов нужно добавить условия для вывода в отчёте*/
display 
	'Задайте группировку отчёта (по умолчанию 1):' skip
	'1. По срокам.' skip
	'2. Сводная по департаментам.' skip
	'3. По одному департаменту.' skip
	with frame rep-request centered no-labels.

update	v-report-type 
	with frame rep-request centered no-labels.


if v-report-type < 1 or v-report-type > 3 then
	v-report-type = 1.

if v-report-type = 3 then
do:
	update v-dep-code 
		with row 8 centered  side-label frame opt. 
	find codfr where codfr.codfr = 'sdep' and codfr.code = v-dep-code:screen-value no-lock no-error.
	if avail codfr then v-des = codfr.name[1]. else v-des = "".
	displ  v-des with frame opt.
end.


if v-dep-lon = 1 then
	run prod-dep.
else if v-dep-lon = 2 then
	run prod-lon.
else if v-dep-lon = 3 then
	run glgl2.







