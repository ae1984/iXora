/* lngrfanu.p
 * MODULE
        3-1-2
 * DESCRIPTION
        вывод аннуитетного графика
 * RUN
        lngrf-2.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        06.01.2012 aigul
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def input parameter p-sum as decimal.
def input parameter p-sel as char.
def shared var s-lon like lnsch.lnn.

def new shared var v-dt1 as date.
def new shared var v-dt2 as date.
def var v-holiday as logical.
def var v-zapis as logical initial no.

def new shared temp-table wrk
    field nn as int
    field nni as int
    field stdt as date
    field days as int
    field sumb as decimal
    field od as decimal
    field percent as decimal
    field sump as decimal
    field sume as decimal
    field ch as char.

def var i as int.
def var tot-od as decimal.
def var tot-percent as decimal.
def var tot-p as decimal.

update v-dt1 label ' Укажите дату следующего ануитетного платежа по графику' format '99/99/9999'
                  validate (v-dt1 >= g-today, "Дата должна быть больше текущей") skip with side-label row 5 centered frame dat.

find first lon where lon.lon = s-lon no-lock.
v-dt2 = lon.duedt.

message "Произвести сдвиг платежей с выходных дней?" view-as alert-box question buttons yes-no update v-holiday.
  if v-holiday then run lngrfanu-h(p-sum,p-sel).
  else run lngrfanu-nh(p-sum,p-sel).
find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.
put stream m-out "<html><head><title>METROCOMBANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"
                 "<STYLE TYPE=""text/css"">" skip

                 "body, H4, H3 ~{margin-top:0pt; margin-bottom:0pt~}" skip
                 "</STYLE></head><body>" skip.

put stream m-out "<table WIDTH=600 border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse""
style=""font-size:15px; font-family:Times New Roman;"">".
put stream m-out "<tr align=""center""><td><h4>" cmp.name format 'x(79)' "</h4></td></tr>".
put stream m-out "<tr align=""center""><td><h4>Приложение N 1</h4></td></tr>".

find first cif where cif.cif = lon.cif no-lock no-error.

put stream m-out "<tr align=""center""><td><br><br><h4> ГРАФИК ПЛАТЕЖЕЙ</h4><br><br></td></tr>".
put stream m-out "<tr align=""left""><td><h4> ФИО заемщика     : " cif.name format 'x(60)' "</h4></td></tr>".
put stream m-out "<tr align=""left""><td><h4> Сумма кредита    : " lon.opnamt format '>>>,>>>,>>9.99' " </h4></td></tr>".
put stream m-out "<tr align=""left""><td><h4> Процентная ставка: " lon.prem format ">9.99%" "</h4></td></tr>".
put stream m-out "<tr align=""left""><td><h4> Дата выдачи кредита : " lon.rdt "</h4></td></tr>".
put stream m-out "<tr align=""left""><td><h4> Дата погашения кредита : " lon.duedt "</h4></td></tr>".

       put stream m-out "<tr><td><table width=""100%""border=""1"" cellpadding=""0"" cellspacing=""0""
           style=""font-size:16px; font-family:Times New Roman;"">"
           "<tr align=""center""  bgcolor=""#C0C0C0"" style=""font:bold"">"
           "<td>N<br>платежа</td>"
           "<td>Дата<br>погашения</td>"
           "<td>Кол-во<br>дней<br>поль-<br>зования<br>кредитом</td>"
           "<td>Сумма<br>кредита<br>на начало<br>периода</td>"
           "<td>Основной<br>долг</td>"
           "<td>Проценты</td>"
           "<td>Платеж<br>за период</td>"
           "<td>Сумма<br>кредита<br>на конец<br>периода</td></tr>" skip.
i = 0.
for each wrk .
       i = i + 1.
       put stream m-out unformatted "<tr align=""right"" style=""font-size:16px; font-family:Times New Roman;"">"
               "<td>~&nbsp~;" i format '>>>9' "~&nbsp~;</td>"
               "<td align=""center"">" wrk.stdt "</td>"
               "<td>" wrk.days format '>>>9' "</td>"
               "<td>" replace(replace(trim(string(wrk.sumb, "->>>,>>>,>>>,>>9.99")),","," "),".",",") "</td>"
               "<td>" replace(replace(trim(string(wrk.od, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
               "<td>" replace(replace(trim(string(wrk.percent, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
               "<td>" replace(replace(trim(string(wrk.sump, "->>>,>>>,>>>,>>9.99")),","," "),".",",") "</td>"
               "<td>" replace(replace(trim(string(wrk.sume, "->>>,>>>,>>>,>>9.99")),","," "),".",",") "</td>"
               /*"<td>" wrk.ch "</td>"*/
               "</tr>" skip.
       tot-od = tot-od + wrk.od.
       tot-percent = tot-percent + wrk.percent.
       tot-p = tot-p + wrk.sump.
end.

put stream m-out unformatted
       "<tr align=""right"" style=""font:bold"" style=""font-size:16px; font-family:Times New Roman;"">"
       "<td colspan=""4"" align=""left"">ИТОГО</td>"
       "<td>" replace(replace(trim(string(tot-od, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
       "<td>" replace(replace(trim(string(tot-percent, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
       "<td>" replace(replace(trim(string(tot-p, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
       "<td></td></tr>" skip.

put stream m-out "</font></table></tr>".

put stream m-out "</table></body></html>".


output stream m-out close.

unix silent cptwin rpt.html excel.

message "Внести данные графика в бд? ( При нажатии YES старый график будет заменен новым! )"
view-as alert-box question buttons yes-no update v-zapis.
  if v-zapis then run lngrfanu-zapis.
