/* garan_view.p
 * MODULE
        Отчет принятых гарантий
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.4.2.16.18
 * AUTHOR
        14/09/2010 aigul
 * BASES
        BANK COMM
 * CHANGES
        21/09/2010 madiyar - перекомпиляция
        2/10/2010 aigul - замена на g-today
        01/07/2011 madiyar - добавил филиал
        07/06/2013 galina - ТЗ 1835
*/

def shared var g-today as date.
def new shared var vasof  as date.
def new shared var vasof2 like vasof.
def new shared var vglacc as char format "x(6)".

def var i as integer.
i = 0.

def new shared temp-table wrk
    field nn as integer
    field gl as char
    field fil as char
    field gname as char format "x(50)"
    field zname as char format "x(50)"
    field cif as char
    field lon_no like lon.lon
    field lonrdt as date
    field londuedt as date
    field lonamt as decimal format ">>>,>>>,>>>,>>9.99"
    field loncrc as char
    field gamt as decimal format ">>>,>>>,>>>,>>9.99"
    field gcrc as char
    field kurs as decimal
    field kurs_dt as date
    field gamt_kzt as decimal format ">>>,>>>,>>>,>>9.99"
    field sec_econ as char
    field numdog like loncon.lcnt.
/*
find sysc where sysc.sysc eq "GLDATE" no-lock no-error.
if avail sysc then do:
	vasof2 = sysc.daval.
	vasof = vasof2.
end.
else do:
	message  "Внимание! Не найден GLDATE!!!".
	pause 100.
	return.
end.
*/
vasof = g-today.
update vasof label "Введите дату" validate (vasof <> ? and vasof <= g-today, "Неверная дата!")
       with row 9 centered side-labels frame vasfff. /*вводим дату отчета*/
hide frame vasfff.

/*
vglacc = "".
update vglacc label "Введите счет Г/К или нажмите ENTER для всех счетов" with side-labels centered row 9 no-box frame glgl.
hide frame glgl.

if length(vglacc,"CHARACTER") ne 6 and vglacc ne "" then do:
	vglacc = "".
	message "Неверный формат счета Г/К!!! Продолжаю для всех счетов".
	pause 5.
	hide message.
end.
*/
{r-brfilial.i &proc = "garan_view1 (comm.txb.bank)" }
output to value ("garan_view.htm").
{html-title.i}
find first cmp no-lock no-error.
put unformatted "<P style=""font-size:x-small"">" cmp.name "</P>" skip
                "<P align=""center"" style=""font:bold;font-size:small"">Отчет по принятым гарантиям на  " vasof ".<br>Время создания: " + string(time,"HH:MM:SS") + "</P>" skip
                "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""50%"">" skip.
put unformatted
"<TR align=""center"" style=""font:bold;background:gainsboro "">" skip
"<TD><font size=1>№</TD>"
/*"<TD><font size=1>счет ГК</TD>"*/
"<TD><font size=1>Филиал</TD>"
"<TD><font size=1>Наименование гаранта</TD>"
"<TD><font size=1>Код заемщика</TD>"
"<TD><font size=1>Наименование заемщика</TD>"
"<TD><font size=1>Номер ссудного счета</TD>"
"<TD><font size=1>Номер договора</TD>"
"<TD><font size=1>Дата выдачи кредита</TD>"
"<TD><font size=1>Дата погашения кредита</TD>"
"<TD><font size=1>Сумма кредита</TD>"
"<TD><font size=1>Валюта кредита<br> в тенге</TD>"
"<TD><font size=1>Сумма гарантии в валюте</TD>"
"<TD><font size=1>Валюта гарантии</TD>"
"<TD><font size=1>Курс</TD>"
"<TD><font size=1>Сумма гарантии в тенге</TD>"
"<TD><font size=1>Сектор экономики</TD>"
"</TR>" skip.
for each wrk where wrk.gamt <> 0 no-lock break by i by wrk.londuedt.
    i = i + 1.
    accumulate wrk.gamt_kzt (TOTAL by i).
    put unformatted "<tr>"
        "<td><font size=1>" i "</td>"
        /*"<td><font size=1>" wrk.gl "</td>"*/
        "<td><font size=1>" wrk.fil "</td>"
        "<td><font size=1>" wrk.gname "</td>"
        "<td><font size=1>" wrk.cif "</td>"
        "<td><font size=1>" wrk.zname "</td>"
        "<td><font size=1>'" wrk.lon_no "</td>"
        "<td><font size=1>'" wrk.numdog "</td>"
        "<td><font size=1>" wrk.lonrdt "</td>"
        "<td><font size=1>" wrk.londuedt "</td>"
        "<td align=right><font size=1>" replace(trim(string(wrk.lonamt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
        "<td><font size=1>" wrk.loncrc "</td>"
        "<td align=right><font size=1>" replace(trim(string(wrk.gamt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
        "<td><font size=1>" wrk.gcrc "</td>"
        "<td><font size=1>" replace(string(wrk.kurs),'.',',') "</td>"  skip
        "<td><font size=1>" replace(trim(string(wrk.gamt_kzt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"  skip
        "<td><font size=1>" wrk.sec_econ "</td></tr>"  skip.
        if last-of (i) then
            put unformatted "<tr align=""center"" style=""font:bold;background:gainsboro "">"
            "<td><font size=1>ИТОГО в тенге :</td>"
            /*"<td>&nbsp</td>"*/
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td>&nbsp</td>"
            "<td><font size=1>" replace(trim(string(accum total by (i) wrk.gamt_kzt, "->>>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
            "<TD>&nbsp</TD>"
            /*"<TD>&nbsp</TD>"*/
            "</tr>" skip.
end.
put unformatted "</table>" skip.
{html-end.i " "}
output close .
hide all.
unix silent cptwin value("garan_view.htm") excel.
