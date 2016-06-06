/* cli-inc.p
 * MODULE
        Название Программного Модуля
        Отчетность
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Отчет по доходности клиентов 
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
 * CHANGES
        24.05.2004 nadejda - разбивка по департаментам
        02.09.2004 sasco   - возможность выбора клиента
        09.09.2004 sasco   - добавил Г/К 45**** (из-за 450310)
        01.12.2004 sasco   - добавил итоги по операционным доходам
        06.12.2004 sasco   - убрал 4606*
        06.01.2005 sasco   - поменял цикл по bjl
        29.04.2005 suchkov - исправил косяк при расчете даты
        31.08.2005 suchkov - исправил еще один косяк при расчете даты
	    04.09.2006 u00121  - добавил avail на проверку логина менеджера счета
        01/04/2011 madiyar - не понял хитрый алгоритм вычисления даты, но при датах 1 апреля и 1 августа ломается, исправил 
*/

def stream  nur.

def var v-tim as int no-undo.


def var flg as log init false no-undo.

def var fdt as date no-undo.
def var tdt as date no-undo.
def var v-dat as date no-undo.

def var limit as decimal FORMAT "->>>,>>9.99" init 1 no-undo.
def var v-subtot as deci init 0 no-undo.
def var v-tot as deci init 0 no-undo.
def var temp-acc as char  format "x(9)" init "" no-undo.
def var temp-rnn as char  format "x(15)" init "" no-undo.
def var i as int.  

def buffer bjl for jl.

def var sumgl as decimal no-undo.
def var sumcif as decimal no-undo.
def var v-dep as integer no-undo.
def var v-deptmp as integer no-undo.
def var v-cif like cif.cif init "" no-undo.
def  var v-supusr as char no-undo.

define variable operdoh as decimal no-undo.


def temp-table temp  no-undo
	field dep as integer
	field cif  like cif.cif
	field gl   like jl.gl
	field amt like jl.dam
	field v-subtot like v-subtot
	field v-tot  like v-tot
	INDEX ind-cif IS primary cif gl
	index main v-tot desc v-subtot desc.

def buffer btemp for temp.

{mainhead.i}

tdt = g-today.

if month(tdt) > 2 then 
do:
	if month(tdt) = 4 or month(tdt) = 8 then do:
        if day(tdt) = 1 then fdt = date(month(tdt) - 2, day(tdt), year(tdt)).
		else fdt = date(month(tdt) - 2, day(tdt) - 1, year(tdt)).
    end.
	else 
		fdt = date(month(tdt) - 2, day(tdt), year(tdt)).
end.
else 
	fdt = date(month(tdt) , day(tdt), year(tdt)).


update 	fdt   label "        ПЕРИОД ОТЧЕТА С" skip 
	tdt   label "                     ПО" skip
	limit label " МИНИМАЛЬНАЯ СУММА ДЛЯ ВЫВОДА" validate (limit > 0 , "Ограничение должно быть > 0") 
	v-cif label "КОД КЛИЕНТА (ПУСТО = ВСЕ КЛИЕНТЫ)" validate (v-cif = "" or (v-cif <> "" and can-find (cif where cif.cif = v-cif no-lock)), "Нет клиента с таким кодом!") skip   
	with side-label row 5 centered title " ПАРАМЕТРЫ ОТЧЕТА " frame dat.

display "   Ждите...   "  with row 5 frame ww centered .
v-tim = time.
{get-dep.i}

v-dep = get-dep(g-ofc, g-today).

v-cif = trim(v-cif).

find last sysc where sysc.sysc = "supusr" no-lock no-error.
if avail sysc then 
	v-supusr = sysc.chval.

find last cmp no-lock no-error.

output stream  nur to rpt.img.

put stream nur skip 
	g-today format "99/99/9999" ", " string(time, "HH:MM:SS") skip
	trim( cmp.name ) format "x(79)" skip(1).


put stream nur skip 
	" СПИСОК КЛИЕНТОВ, ПРИНЕСШИХ ДОХОД БАНКУ ЗА ПЕРИОД  С "  at 5  fdt " ПО " tdt    skip " НА СУММУ ОТ "  at 18 limit  " ТЕНГЕ И ВЫШЕ" skip(1).

find last ppoint where ppoint.depart = v-dep no-lock no-error.
if avail ppoint then
	put stream nur if v-dep = 1 then "Все департаменты" else "ДЕПАРТАМЕНТ : " + ppoint.name format "x(50)" skip(1).
else
do:
	message "Ваш логин привязан к неправильному департаменту!" skip
		"Департамента с кодом " v-dep " отсутсвует в системе (ppoint)!" skip
		"Формирование отчета прекращено!" view-as alert-box.
        return.
end.

put stream nur skip(2) 
	"Кл-т/ГК " 	format "x(9)" at 1 space(7)  
	"Наименование " format "x(15)" space(25) 
	"ИТОГО (KZT)" 	format "x(35)" skip.

do v-dat = fdt to tdt:
	hide message no-pause.

	/* ВСЕ КЛИЕНТЫ */
	if v-cif = "" then 
		for each jl fields (jl.gl jl.sub jl.acc jl.jh jl.dam jl.crc jl.jdt) no-lock where jl.jdt = v-dat and jl.dc = "d" /*use-index jdtdcgl*/ :
			if not string(jl.gl) begins "2" or jl.sub <> "cif" then next.
			displ jl.jdt jl.jh with overlay no-labels centered row 15 1 down title "Обработка". pause 0.
			find aaa where jl.acc = aaa.aaa no-lock no-error.
			if not available aaa then next.

			find last cif where cif.cif = aaa.cif no-lock no-error.
			/* определяем РКО по менеджеру счета, если нет - по привязке клиента на сегодняшний день (ну нет у нас истории) */
			if trim(substr(cif.fname, 1, 8)) = "" then 
				v-deptmp = integer(cif.jame) mod 1000.
			else 
			do:
				find last ofc where ofc.ofc = trim(substr(cif.fname, 1, 8)) no-lock no-error.
				if avail ofc then
					v-deptmp = get-dep(trim(substr(cif.fname, 1, 8)), g-today).
				else
				do:
					v-deptmp = integer(cif.jame) mod 1000.
					message "Клиент с кодом " cif.cif " привязан к не существующему менеджеру счета!" view-as alert-box title "Для информации".
				end.
			end.
			/* для ЦО выдаем все проводки, для РКО - только свои */
			if v-dep <> 1 and v-dep <> v-deptmp then next.


			/* доход по кредитам не учитывается */
			for each bjl fields (bjl.gl bjl.cam) where bjl.jh = jl.jh and bjl.sub <> "lon" and bjl.cam = jl.dam and bjl.dc = "c" no-lock:
				if lookup(substr(string(bjl.gl),1,2), "44,45,46") > 0  then
				do:
					find last crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt no-lock no-error.
					create temp. 
					assign 
						temp.cif = aaa.cif
						temp.gl = bjl.gl
						temp.amt = bjl.cam * crchis.rate[1]
						temp.dep = v-deptmp.
				end.
			end. /* for each bjl*/
		end.  /*jl*/
	else 
	do:
		for each aaa fields (aaa.aaa aaa.cif) where aaa.cif = v-cif no-lock:
			for each jl fields (jl.gl jl.jh jl.dam jl.crc jl.jdt) no-lock where jl.jdt = v-dat and jl.acc = aaa.aaa and jl.dc = "d" /*use-index jdtaccgl*/ :

				if not string(jl.gl) begins "2" then next.
	
				for each bjl fields (bjl.gl bjl.cam) where lookup(substr(string(bjl.gl),1,2), "44,45,46") > 0 and 
							bjl.jh = jl.jh and 
							bjl.sub <> "lon" and 
							bjl.cam = jl.dam and 
							bjl.dc = "c" no-lock:

					find last crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt no-lock no-error.
					create temp. 
					assign 
						temp.cif = aaa.cif
						temp.gl = bjl.gl
						temp.amt = bjl.cam * crchis.rate[1]
						temp.dep = v-deptmp.
				end. /* for each bjl*/
			end.  /*jl*/
		end. /*aaa*/
	end. /*else*/
end. /*v-dat*/

hide message no-pause.

for each temp no-lock break by temp.cif by temp.gl.
	ACCUMULATE temp.amt (total by temp.cif by temp.gl).

	if last-of(temp.gl) then  
	do: 
		sumgl = ACCUMulate total  by temp.gl temp.amt.   
		for each btemp where btemp.gl = temp.gl and btemp.cif = temp.cif.
			btemp.v-subtot = sumgl.
		end.
	end. /*last-of gl*/

	if last-of(temp.cif) then  
	do: 
		sumcif = ACCUMulate total  by (temp.cif) temp.amt.   
		for each btemp where btemp.cif = temp.cif.
			btemp.v-tot = sumcif.
		end.
	end. /*last-of cif*/
end.

for each temp where temp.v-tot > limit break by temp.v-tot desc by temp.v-subtot desc:
	if first-of(temp.v-tot) then 
	do:
		operdoh = 0.
		find last cif where cif.cif = temp.cif no-lock no-error.
		put stream nur 	temp.cif format "x(6)" at 1 space(4) 
				cif.name format "x(40)"  
				temp.v-tot format "zz,zzz,zzz,zz9.99" skip.
	end.

	if last-of(temp.v-subtot) then 
	do:
		find last gl where gl.gl = temp.gl no-lock no-error. 
		put stream nur skip  
				temp.gl format "zzzzzz" at 1 space(4) 
				trim(gl.des) format "x(40)"  
				temp.v-subtot format "zz,zzz,zzz,zz9.99" skip.
	end.

	if lookup (substring (string (temp.gl, "999999"), 1, 4), "4429,4606") = 0 then 
		operdoh = operdoh + temp.amt.

	if last-of(temp.v-tot) then 
	do:
		put stream nur "          Операционный доход" format "x(50)" 
				operdoh format "zz,zzz,zzz,zz9.99" skip.
		put stream nur skip(2).
	end.
end.

output stream nur close.

message "Время формирования отчета:" skip
	string(time - v-tim, "HH:MM:SS") view-as alert-box.

if not g-batch then 
do:
	pause 0 before-hide.                  
	run menu-prt( "rpt.img" ).
	pause 0 no-message.
	pause before-hide.
end.

