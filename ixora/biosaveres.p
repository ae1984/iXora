/* biosaveres.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	формирование истории сверок отпечатков пальцев
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
        11/04/2006 madiyar - входной параметр - показывать или нет фрейм с запросом количества разрешенных проводок
        27/03/2008 madiyar - 0 - успешная сверка
*/

{global.i}

def input param i-cif like cif.cif. /*Код клиента*/
def input param i-upl as char. /*Код доверенного лица либо код директора/гл.бухгалтера*/
def input param i-res like biocmprres.idres. /*результат сверки*/
def input param i-ask as logical. /*кол-во проводок - спрашивать или нет*/

def var v-aaa like aaa.aaa. /*переменная для поиска счетов клиента*/
 
def temp-table waaa /*таблица. которая будет содержать все найденные счета клиента*/
    field aaa as char
    field lgr as char
    field midd as char
index main is primary unique lgr midd aaa.



create biocmprhst. /*создаем запись в истории сверки отпечатков пальцев*/
	biocmprhst.cif = i-cif. /*код клиента*/
	biocmprhst.upl = i-upl. /*код конролируемого лица*/
	biocmprhst.who = user('bank'). /*кто активизировал сверку*/
	biocmprhst.dt = g-today. /*когда*/
	biocmprhst.tm = time. /*восколько*/
	biocmprhst.idres = i-res. /*результат сверки*/


if not i-ask then return.


def var v-cnt as int label "Количество проводок". /*собственно само количество проводок*/

def frame f-cnt /*красивый фраме для ввода количества проводок*/
	v-cnt
	     with centered overlay row 1 top-only title "Введите количество разрешенных проводок". 


if i-res = 0 then  /*только если результат сверки положительный*/
do: /*даем возможность сразу вводить количество разрешенных проводок*/
		update v-cnt with frame f-cnt. /*вводим количество прводок*/
		if v-cnt entered then /*если ввели*/
		do:	/*ищем уже существующую запись за текущий ОПЕРАЦИОННЫЙ день*/
			find last biojhcnt where biojhcnt.cif = i-cif and biojhcnt.dt = g-today no-error.
			if not avail biojhcnt then
			do: /*если такая запись не найдена*/
				create biojhcnt. /*создаем ее*/
					biojhcnt.cif = i-cif. /*код клиента*/
					biojhcnt.dt = g-today. /*дата*/
			end. 
			biojhcnt.cnt = biojhcnt.cnt + v-cnt. /*если даже запись и была неайдена, просто увеличиваем колисчество разрешенных проводок*/
			biocmprhst.cnt = v-cnt. /*так же сохраняем количество разрешенных проводок в истории сверки, чтобы можно было определить кто, когда и на какое количество получал разрешение на проводки*/
			run biom_print_ord(input  biocmprhst.cif, input  "", input  biocmprhst.cnt).
		end.
end.


