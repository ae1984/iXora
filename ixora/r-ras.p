/* 
 * MODULE
        r-ras.p
 * DESCRIPTION
        Обороты по расходным счетам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r-ras1.p
 * MENU
        8-2-5-3 
 * AUTHOR
        В.Ким. 15.03.01.
 * CHANGES
	20/05/04 valery сделал возможность формировать отчет консолидированным или выбирать по филиалам, а также вывод отчета в Excel
	04/06/04 valery выводится счет Г/Л с названием, а также проводки групируются по этому счету
*/


{global.i}

{functions-def.i}

def var v-file as char init "r-ras.html".

def var dt as dec format "->>>,>>>,>>>,>>9.99".
def var ct as dec format "->>>,>>>,>>>,>>9.99".

def new shared var datBegDay as date.
def new shared var datEndDay as date.
def new shared var sumDtKZT as dec format "->>>,>>>,>>>,>>9.99".
def new shared var sumCtKZT as dec format "->>>,>>>,>>>,>>9.99".

/*def stream  m-out.*/

def new shared temp-table t-ras
	field gl like bank.gl.gl
	field des like bank.gl.des
	field dat as date
	field jh like bank.jl.jh
	field dam like bank.jl.dam
	field cam like bank.jl.cam
	field crc like bank.jl.crc
	field rem like bank.jl.rem[1]
	field who like bank.jl.who
	field txbt as char.

def var wait as char label "ЖДИТЕ" format "x(20)".
def var i as int init 0.

datBegDay = g-today.
datEndDay = g-today.

display datBegDay label " с " datEndDay label " по "
    with row 8 centered  side-labels frame opt title "Введите :".


update datBegDay with frame opt.
update datEndDay with frame opt.

display '   Ждите...   '  with row 5 frame ww centered .
hide frame opt.

/***Бегаем по фелиалам*****************************/
{r-brfilial.i &proc = "r-ras1 (comm.txb.bank)" }
/**************************************************/



/***************************формируем файл отчета********************************************************/
output  to value(v-file).

{html-title.i 
 &stream = " " 
 &title = " "
 &size-add = "x-"
}


put unformatted      
  "<P align=""center"" style=""font:bold"">ОБОРОТЫ ПО РАСХОДАМ</P>" skip
  "<P align=""center"" style=""font:bold"">ЗА ПЕРИОД " datBegDay "-" datEndDay "</P>" skip
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
	  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
	    "<TD>ДАТА</TD>" skip
	    "<TD>ТРАНЗАКЦИЯ</TD>" skip
	    "<TD>ДЕБЕТ</TD>" skip
	    "<TD>КРЕДИТ</TD>" skip
	    "<TD>ВАЛЮТА</TD>" skip
	    "<TD>ПРИМЕЧАНИЕ</TD>" skip
	    "<TD>ИСПОЛНИТЕЛЬ</TD>" skip
	    "<TD>ФИЛИАЛ</TD>" skip
	  "</TR>" skip.




for each t-ras no-lock break by t-ras.gl by t-ras.crc by t-ras.txbt by t-ras.dat.
    accumulate dam (total by gl by crc).
    accumulate cam (total by gl by crc).
/*    if f = 0 then do:*/
    if first-of(t-ras.gl) then do:
        put unformatted    
		"<TR BGCOLOR>" skip
			"<TD>Счет ГК: " gl " " des "</TD>" skip
			"<TD>&nbsp</TD>" skip
			"<TD>&nbsp</TD>" skip
			"<TD>&nbsp</TD>" skip
			"<TD>&nbsp</TD>" skip
			"<TD>&nbsp</TD>" skip
			"<TD>&nbsp</TD>" skip
			"<TD>&nbsp</TD>" skip
		"</TR>" skip.
    end.
	put unformatted   
		"<TR>" skip
			"<TD>" t-ras.dat "</TD>" skip
			"<TD>" t-ras.jh "</TD>" skip
			"<TD>" replace(string(t-ras.dam, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
			"<TD>" replace(string(t-ras.cam, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
			"<TD>" t-ras.crc "</TD>" skip
			"<TD>" t-ras.rem "</TD>" skip
			"<TD>" t-ras.who "</TD>" skip
			"<TD>" t-ras.txbt "</TD>" skip
		"</TR>" skip.

    if t-ras.crc = 1 then do:
        sumDtKZT = sumDtKZT + t-ras.dam.
        sumCtKZT = sumCtKZT + t-ras.cam.
    end.


    if last-of(t-ras.crc) then do:
        dt = accum total by t-ras.crc t-ras.dam.
        ct = accum total by t-ras.crc t-ras.cam.
	        put unformatted    
			"<TR>" skip
				"<TD>ИТОГО:</TD>" skip
				"<TD>&nbsp</TD>" skip
				"<TD>" replace(string(dt, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
				"<TD>" replace(string(ct, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
				"<TD>" t-ras.crc "</TD>" skip
				"<TD>&nbsp</TD>" skip
				"<TD>&nbsp</TD>" skip
				"<TD>&nbsp</TD>" skip
			"</TR>" skip.

    end.

end.

	        put unformatted   
			"<TR>" skip
				"<TD>ИТОГО:</TD>" skip
				"<TD>&nbsp</TD>" skip
				"<TD>" replace(string(sumDtKZT, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
				"<TD>" replace(string(sumCtKZT, "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip
				"<TD>&nbsp</TD>" skip
				"<TD>&nbsp</TD>" skip
				"<TD>&nbsp</TD>" skip
				"<TD>&nbsp</TD>" skip
			"<TR>" skip.



put unformatted "</TABLE>" skip.

{html-end.i " "}

output close.

/****************************************фаил сформирован *********************************************************************************/

{functions-end.i}


hide all. /*скрываем все фреймы*/
unix silent cptwin value(v-file) excel. /*выводим файл в Excel*/

pause 0.

