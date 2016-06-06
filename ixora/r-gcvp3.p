/* r-gcvp3.p
 * MODULE
        отчеты по ГЦВП - выплата пенсий и пособий
 * DESCRIPTION
        Отчет по отсутствию операций по счету   
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        BANK COMM 
 * AUTHOR
        25.08.08  marinav
 * CHANGES
*/

{mainhead.i}


def new shared var v-dtb as date.

def new shared temp-table wrk
             field bank as char
             field name like bank.cif.name
             field dt as date 
             field aaa like bank.aaa.aaa
             field jdt as date. 

def var coun as inte .

v-dtb  = g-today.

update 
  v-dtb label " Дата отчета" format "99/99/9999" skip
  with centered row 5 side-label frame f-dt.


{r-brfilial.i &proc = "r-gcvp3p (txb.bank)" } 


define stream m-out.
output stream m-out to rpt.html.
put stream m-out "<html><head><title></title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
put stream m-out unformatted "<tr align=""center""><td><h3>Сведения по получателям, не получавшим пенсии и пособия 3 и более месяцев</h3></td></tr><br><br>"  skip(1).
put stream m-out unformatted "<tr></tr><tr></tr>" skip(1).

put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">ФИО</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Дата рождения</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Номер счета</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Дата последней <br>расходной <br>операции</td>"
                 "</tr>" skip.

coun = 1.

for each wrk .
  
        put stream m-out unformatted
               "<tr align=""right"">"
               "<td align=""center"">" coun "</td>"
               "<td align=""left"">"   wrk.name "</td>"
               "<td align=""center"">" wrk.dt "</td>"
               "<td align=""center"">&nbsp;" wrk.aaa "</td>"
               "<td align=""center"">" wrk.jdt "</td>"
               "</tr>" skip.
         coun = coun + 1.
end.                       

put stream m-out unformatted "</table>" skip.

output stream m-out close.
unix silent cptwin rpt.html excel.
pause 0.
