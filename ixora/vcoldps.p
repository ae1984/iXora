/* vcoldps.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по паспортам сделок, оформленных в 1997-1998г.
 * RUN
        vcoldps.p
 * CALLER
        vcoldps.p
 * SCRIPT
        vcoldps.p
 * INHERIT
        vcoldps.p
 * MENU
        15-4-5 
 * AUTHOR
        21.10.2004 saltanat Присоединение баз - Bank, Comm
 * CHANGES
        22.10.2004 saltanat - вывод в Ехсел.
        16.11.2004 saltanat - сортировка по Наименованию импортера/экспортера
*/

{mainhead.i}
{rkorepfun.i}

def var id as inte init 0.
def var ip as char.
def var ib as char.
def var it as char.

def temp-table vc
    field id  as inte
    field it  as char
    field ib  as char
    field ip  as char
    field rnn like cif.jss
    field dnn like vcps.dnnum
    field ddt like vcps.dndate
    field sum like vcps.sum
    index ip-idx ip ASCENDING. 

display "Ждите идет формирование отчета..."  with row 12 frame ww centered.
pause 0.

id = 0.

for each comm.vcps where year(dndate) < 1999 no-lock:
for each comm.vccontrs of comm.vcps no-lock:
if (comm.vccontrs.sts begins "C") /*or (year(comm.vccontrs.rdt) > 1998)*/ then next.
for each cif of comm.vccontrs no-lock:
   find first txb where txb.bank = vccontrs.bank and txb.city = 998 no-lock no-error.
   if avail txb then ib = txb.info.
   else ib = vccontrs.bank.
   find first codfr where codfr.codfr = 'customs' and codfr.code = vccontrs.custom  no-lock no-error.
   if avail codfr then it = codfr.name[1].
   else it = string(vccontrs.custom).
   id = id + 1.
   create vc.
   assign vc.id  = id 
          vc.it  = it
          vc.ib  = ib
          vc.ip  = cif.name
          vc.rnn = cif.jss
          vc.dnn = vcps.dnnum
          vc.ddt = vcps.dndate
          vc.sum = vcps.sum. 
end.
end. /* vccontrs */
end. /* vcps */

/* вывод отчета в HTML */

def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Отчет по сумме начисленных %% по кредитам"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""left""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по паспортам сделок, оформленных в 1997-1998гг.</B></FONT></P>" skip

   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" >" skip.
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>N=<br>строки<br>отчета</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Наименование<br>таможенного<br>органа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Наименование<br>банка</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Наименование<br>экспортера/<br>импортера</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>РНН</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер<br>паспорта<br>сделки</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата<br>паспорта<br>сделки</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма<br>паспорта<br>сделки</B></FONT></TD>" skip
   "</TR>" skip.

for each vc break by vc.ip.
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"">" skip
     "<TD><FONT size=""2"">" + string(vc.id)  + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + vc.it  + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + vc.ib  + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + vc.ip  + "</FONT></TD>" skip
     "<TD><FONT size=""2"">&nbsp;" + string(vc.rnn) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + vc.dnn  + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(vc.ddt,'99/99/9999') + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(vc.sum,"->>>>>>>>>>>9.99"),'.',',') + "</FONT></TD>" skip
   "</TR>" skip.
end.
put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcreestr.htm excel.

hide all.
/*
unix silent value("cptwin vcreestr.htm iexplore").

pause 0.
*/