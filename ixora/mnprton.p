/* mnprton.p
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
        23/09/04 kanat
 * CHANGES
*/

def var v-gl-whole as decimal.
def var v-whole as decimal.
def new shared var v-date-fin as date.
def new shared var v-operation as char.

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

def new shared frame opt 
       v-date-fin label "Данные на " with row 8 centered side-labels title " Отчет по счетам клиентов ЮЛ, нерезидентов ГК".

update v-date-fin
       with frame opt.

hide frame opt.
{r-branch.i &proc = "mnprtcn"}

output to lyuda.htm.
{html-start.i}
put unformatted
   "<BR><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "Отчет по сверке Приложения N 2</FONT><BR>" skip
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

if first-of (substr(string(ttmps.gl),1,4)) then do:
put unformatted "<TR><TD><B>" string(ttmps.gl) "</B></TD>" skip
                    "<TD></TD>" skip
                    "<TD></TD>" skip
                    "<TD></TD></TR>" skip.
end.

if first-of (ttmps.balgl) then 
v-gl-whole = 0.

v-gl-whole = v-gl-whole + (ttmps.sum / 1000).

if v-operation = "2" then do:
put unformatted "<TR><TD></TD>" skip
                    "<TD>" ttmps.name "</TD>" skip
                    "<TD>" ttmps.balgl "</TD>" skip
                    "<TD>" string(round(ttmps.sum / 1000, 2)) "</TD></TR>" skip.
end.


if last-of (ttmps.balgl) then do:
put unformatted "<TR><TD  bgcolor=""#95B2D1""><B>ИТОГО " ttmps.balgl "</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" string(round(v-gl-whole, 2)) "<B></TD></TR>" skip.
end.
end.

put unformatted "</TABLE>" skip.
{html-end.i}
output close.

unix silent value("cptwin lyuda.htm excel").
pause 0.

