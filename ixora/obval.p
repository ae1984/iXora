/* obval.p
 * MODULE
        Название Программного Модуля
        Отчетность
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	ОБЪЕМ КУПЛЕННОЙ И ПРОДАННОЙ ИНОСТРАННОЙ ВАЛЮТЫ ЗА ПЕРИОД
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	r-obval2.p
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM 
 * AUTHOR
        30.11.2000 pragma
 * CHANGES
        21/10/03 nataly Были добавлны счета 100200, 100300 + консолидирован отчет 
        26/10/04 kanat добавил ofc и ofc_name для отчета 
	05/05/06 u00121 - добавил опцию no-undo в описание переменных и временной таблицы
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


def shared var g-today as date.
def shared var g-batch as logical.

   
def new  shared  temp-table temp no-undo
     field    dc    as    char format "x(1)"
     field    debv  as decimal format "zzzz,zzz,zz9.99"
     field    credv as decimal format "zzzz,zzz,zz9.99"
     field    crc   as integer 
     field    rate  as decimal format "zzz9.99"
     field    rko   as char
     field    ofc   as char 
     field    ofc_name as char
     index main is primary crc dc rate credv debv.

def  stream   m-out.

def  new shared var v-name as char no-undo.
def  new shared var fdate as date no-undo.
def  new shared var tdate as date no-undo.

def var v-crc as char no-undo.

{functions-def.i}
 fdate = g-today.
 tdate = g-today.

display
   fdate label " С "
   tdate label " по "
         with row 8 centered  side-labels frame opt title " Введите период: " .
         
   update fdate validate(fdate <= g-today,"Должно быть: начало <= сегодня") with frame opt.
   update tdate validate(tdate >= fdate and tdate <= g-today, "Должно быть: начало <= конец <= сегодня") with frame opt.
                     
hide frame opt no-pause.
                     
display "   Ждите...   "  with row 5 frame ww centered .

/****************************************************************************************************************************************************/
{r-branch.i &proc = "r-obval2"}
/*
for each comm.txb where comm.txb.consolid = true  no-lock:
    v-name = comm.txb.name. 
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    run r-obval2.
end.
if connected ("txb") then disconnect "txb".
*/
/****************************************************************************************************************************************************/

output stream m-out to rpt.txt.

put stream m-out
    FirstLine( 1, 1 ) format "x(80)" skip(1)
    "            "
    "ОБЪЕМ КУПЛЕННОЙ И ПРОДАННОЙ ИНОСТРАННОЙ ВАЛЮТЫ  "  skip
    "                  "
    "за период с " string(fdate)  " по "  string(tdate) skip(1)
    FirstLine( 2, 1 ) format "x(80)" skip.
    put stream m-out  fill( "-", 80 ) format "x(80)"  skip.
    put stream m-out
    " Валюта  "
    "       Покупка "
    "        Продажа "
    "        Курс "
    " Кассир/Менеджер "
     skip.    

put stream m-out  fill( "-", 80 ) format "x(80)"  skip(1).



for each temp break by temp.crc  by temp.rko  by temp.dc    by temp.rate.

	accum temp.debv (total by temp.crc).
	accum temp.debv (total by temp.rko).
	accum temp.debv (total by temp.dc) .
	accum temp.debv (total by temp.rate).
	accum temp.credv  (total by temp.crc).
	accum temp.credv (total by temp.rko).
	accum temp.credv  (total by temp.dc) .
	accum temp.credv  (total by temp.rate).

	if first-of(temp.crc) then 
	do.
		find crc where crc.crc = temp.crc no-lock no-error.
		if avail crc then 
			v-crc = crc.code.  
		else 
			v-crc = 'N/A'.
	end.

	if first-of(temp.rko) then 
	do.
		put stream m-out skip v-crc " "  temp.rko format 'x(30)' " " skip.
	end.

	put stream m-out 
			temp.debv format "z,zzz,zzz,zz9.99"  at 7 
			temp.credv format "z,zzz,zzz,zz9.99"  at 27 
			temp.rate  at 47 
			temp.ofc   at 57 
			temp.ofc_name at 67 format "x(25)" skip.

	if last-of(temp.rate) then 
	do:
		put stream m-out  space (11) fill ('-',42) format 'x(42)' skip.

		if temp.dc = "d" then   
			put stream m-out "ИТОГО" accum total by temp.rate temp.debv format "z,zzz,zzz,zz9.99" at 7 temp.rate at 47 skip(2) .
		else  
			put stream m-out "ИТОГО" accum total by temp.rate temp.credv format "z,zzz,zzz,zz9.99"  at 27 temp.rate at 47 skip(2).
	end.

	if last-of(temp.rko) then 
	do:
		put stream m-out  skip(1).
		put stream m-out "ИТОГО " . 
		put stream m-out  v-crc format 'x(3)' " " temp.rko format 'x(30)' skip .
		put stream m-out 
			accum total by temp.rko temp.debv format "z,zzz,zzz,zz9.99" at 7 
			accum total by temp.rko temp.credv format "z,zzz,zzz,zz9.99"  at 27 skip(1).
		put stream m-out  space (11) fill ('=',42) format 'x(42)' skip(3).
	end.
end.

put stream m-out  fill( "-", 80 ) format "x(80)"  skip(1).

output stream m-out close.

{functions-end.i}

if not g-batch then 
do:
	pause 0.
	run menu-prt ("rpt.txt").
end.

hide frame ww no-pause.
