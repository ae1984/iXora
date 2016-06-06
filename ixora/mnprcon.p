/* mnprcon.p
 * MODULE
       Генеральная Бухгалтерия
 * DESCRIPTION
       Отчет по счетам клиентов для Приложения 2 (конс.)
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        21/09/04 kanat
 * CHANGES
        15/06/2005 kanat - добавил формат вывода чисел в отчете и итоге по просьбе Валеры Башкатова.
	24/11/2005 u00121 - изменил формат вывода сумм - вместо точки разделителем теперь будет запятая
	09/12/2005 u00121 - добавил переменную для контроля времени формирования отчета, и вывод времени формирования отчета по заврешению работы программы
	04/08/2006 u00121 - добавил no-undo только для переменных
*/

def new shared var v-time as int no-undo. /*u00121 09.12.2005 время начала формирования отчета*/
v-time = time.

def var v-gl-whole as decimal no-undo.
def var v-whole as decimal no-undo.
def new shared var v-date-fin as date no-undo.
def new shared var v-operation as char no-undo.

def new shared temp-table ttmps 
	field aaa as char
	field crc as integer
	field sum as decimal
	field ofc as char
	field gl  as integer
	field name as char
	field sector as char
	field balgl as char.

run sel ("Выберите тип отчета", "1. Краткий отчет      |" +
	 "2. Детальный отчет     ").
case return-value:
	when "1" then v-operation = "1".
	when "2" then v-operation = "2".
end.

def new shared frame opt v-date-fin label "Данные на " with row 8 centered side-labels title " Отчет по счетам клиентов ЮЛ, нерезидентов ГК".

update v-date-fin with frame opt.

hide frame opt.
{r-branch.i &proc = "mnprccn"}

output to lyuda.htm.
{html-start.i}
	put unformatted
		"<BR><BR><BR><BR>" skip
		"<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
		"Отчет об отдельных счетах по операциям с филиалами и " skip 
		"представительствами иностранных компаний</FONT><BR>" skip
		"<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><BR>"
		" на " + string(v-date-fin, "99/99/9999") + "</FONT></P></B>" skip.

	put unformatted
		"<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
		"<TR align=""center"" valign=""top"">" skip
		"<TD  bgcolor=""#95B2D1""><B>Номер счета</B></FONT></TD>" skip
		"<TD  bgcolor=""#95B2D1""><B>Наименование класса, группы счетов, счета</B></FONT></TD>" skip
		"<TD  bgcolor=""#95B2D1""><B>Счет ГК</B></FONT></TD>" skip
		"<TD  bgcolor=""#95B2D1""><B>Сумма (тыс. тенге)</B></FONT></TD>" skip
		"</TR>".                            

	for each ttmps no-lock break by substr(string(ttmps.gl),1,4) by ttmps.balgl.

		if first-of (substr(string(ttmps.gl),1,4)) then 
		do:
			put unformatted "<TR><TD><B>" string(ttmps.gl) "</B></TD>" skip
					"<TD></TD>" skip
					"<TD></TD>" skip
					"<TD></TD></TR>" skip.
		end.

		if first-of (ttmps.balgl) then 
			v-gl-whole = 0.

		v-gl-whole = v-gl-whole + (ttmps.sum / 1000).

		if v-operation = "2" then 
		do:
			put unformatted "<TR><TD></TD>" skip
					"<TD>" ttmps.name "</TD>" skip
					"<TD>" ttmps.balgl "</TD>" skip
					"<TD>" replace(string(round(ttmps.sum / 1000, 2)), ".", ",") "</TD></TR>" skip.
		end.

		if last-of (ttmps.balgl) then 
		do:
			put unformatted "<TR><TD  bgcolor=""#95B2D1""><B>ИТОГО " ttmps.balgl "</B></TD>" skip
					"<TD  bgcolor=""#95B2D1""></TD>" skip
					"<TD  bgcolor=""#95B2D1""></TD>" skip
					"<TD  bgcolor=""#95B2D1""><B>" replace(string(round(v-gl-whole, 2)), ".", ",") "<B></TD></TR>" skip.
		end.
	end.

	put unformatted "</TABLE>" skip.
{html-end.i}
output close.

unix silent value("cptwin lyuda.htm excel").
pause 0.


message "Формирование отчета завершено." skip "Время формирования " + string(time - v-time , "HH:MM:SS") view-as alert-box. /*u00121 09.12.2005 покажем пользователю, сколько времени ушло на формирование отчета*/