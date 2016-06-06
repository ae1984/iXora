/* pkanhis.p
 * MODULE
        Потребкредит - Быстрые деньги
 * DESCRIPTION
        Отчет по изменению анкет клиентов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-12-4-6
 * AUTHOR
        06.04.05 saltanat
 * CHANGES
*/
{mainhead.i}

def var ourbank as char.
def var dt1 as date.
def var dt2 as date.
def var usrnm as char.

dt1 = g-today.
dt2 = g-today.

update dt1 label 'с   ' skip
       dt2 label 'по  '
with centered side-label row 5 title 'Введите отчетную дату'.

message ' Формируется отчет... '.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
display "Отсутствует запись OURBANK в таблице SYSC!".
pause . undo . return . end.
ourbank = sysc.chval.


/* вывод отчета в HTML */

def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Отчет по изменению статусов в процессе выдачи кредита и графика платежей"
 &size-add = "xx-"
}

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream vcrpt unformatted 
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по изменению статусов в процессе выдачи кредита и графика платежей с " + string(dt1, "99/99/9999") + 
       " по " + string(dt2,"99/99/9999") + " </B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" bordercolor=#000000>" skip.
   
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#000000 bgcolor=#C0C0C0>" skip
     "<TD rowspan = ""2""><FONT size=""1""><B>N<br>анкеты</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""1""><B>ФИО<br>клиента</B></FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""1""><B>Изменение статуса</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""1""><B>Дата<br>изменения<br>статуса</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""1""><B>ФИО менеджера<br>осуществившего<br>изменения<br>статуса</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""1""><B>Дата<br>изменения<br>графика</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""1""><B>ФИО менеджера<br>осуществившего<br>изменения<br>графика</B></FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#000000 bgcolor=#C0C0C0>" skip
     "<TD><FONT size=""1""><B>предыдущий</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>новый</B></FONT></TD>" skip
   "</TR>" skip.
   
for each pkankhis where pkankhis.bank = ourbank and pkankhis.credtype = '6' and pkankhis.whn >= dt1 and pkankhis.whn <= dt2 by pkankhis.ln by pkankhis.type by no-lock :
 find pkanketa where  pkanketa.ln = pkankhis.ln and pkanketa.credtype = pkankhis.credtype and pkanketa.bank = pkankhis.bank no-lock no-error.
 if not avail pkanketa then next.
 find cif where cif.cif = pkanketa.cif no-lock no-error.
 if not avail cif then next.

 put stream vcrpt unformatted 
       "<TR align=""right"" valign=""bottom"" bordercolor=#000000>" skip
           "<TD><FONT size=""1"">" + string(pkankhis.ln) + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + cif.name + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + pkankhis.chval + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + if pkankhis.type = 'sts'   then '99' else '' + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + if pkankhis.type = 'sts'   then string(pkankhis.whn,"99/99/9999") else '' + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + if pkankhis.type = 'sts'   then pkankhis.who else '' + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + if pkankhis.type = 'graph' then string(pkankhis.whn,"99/99/9999") else '' + " </FONT></TD>" skip
           "<TD><FONT size=""1"">" + if pkankhis.type = 'graph' then pkankhis.who else '' + " </FONT></TD>" skip
       "</TR>" skip.    
end.

put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcreestr.htm excel.
