/* aaskr.p
 * MODULE
        Отчет по имеющимся спец. инструкциям Кредитных Департаментов.
 * DESCRIPTION
        Отчет по имеющимся спец. инструкциям Кредитных Департаментов.
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        12.11.2004 saltanat
 * CHANGES
        23.11.2004 saltanat - Добавила вывод признака удаления спец.инстр.
        18.01.2005 saltanat - Добавила сумму блокировки
*/

{global.i}

def var dep as char init '102,107,108,109'.

def temp-table tk
    field name like cif.name
    field aaa  like aaa.aaa
    field cif  like cif.cif
    field paye like aas.paye
    field who  like ofc.name
    field whn  like aas.whn
    field priz like aas.delaas
    field sum  like aas.chkamt.

for each aas no-lock.
    find ofc where ofc.ofc = aas.who no-lock no-error.
    if avail ofc and lookup(ofc.titcd,dep) > 0 then do:
       find aaa where aaa.aaa = aas.aaa no-lock no-error. 
       if avail aaa then do:
          find cif where cif.cif = aaa.cif no-lock no-error.
          if avail cif then do:
             create tk.
             assign tk.name = cif.name
                    tk.aaa  = aaa.aaa
                    tk.cif  = cif.cif
                    tk.paye = aas.paye
                    tk.who  = ofc.name
                    tk.whn  = aas.whn
                    tk.sum  = aas.chkamt.
             if aas.delaas = 'k' then tk.priz = '*'.
             else tk.priz = ''.
          end.
       end.
    end.
end.

/* вывод отчета в HTML */

def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Отчет о заблокированных счетах"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""left""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет о заблокированных счетах</B></FONT></P>" skip

   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" bordercolor=#d8e4f8>" skip.
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>Наименование<BR>клиента</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>N текущего счета</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Код клиента</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Причина блокировки</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Кто заблокировал<BR>счет</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда заблокировали</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма блокировки<BR>тг.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Признак удаления<BR>спец.инстр.</B></FONT></TD>" skip
   "</TR>" skip.

for each tk break by tk.name.
   put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + tk.name + "</FONT></TD>" skip
     "<TD><FONT size=""2"">&nbsp;" + tk.aaa  + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + tk.cif  + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + tk.paye + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + tk.who + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if tk.whn  = ? then '' else string(tk.whn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(tk.sum) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + tk.priz + "</FONT></TD>" skip
   "</TR>" skip.
end.

put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcreestr.htm excel.

