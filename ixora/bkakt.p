/* bkakt.p
 * MODULE
        БД
 * DESCRIPTION
        Формирование акта приема-передачи карт и пин-конвертов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        17.01.06 marinav 
 * CHANGES
*/

{global.i}
{bk.i}

def var i as inte.
def var s_bank as char.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause. 
  return.
end.
else s_bank = sysc.chval.


 for each bkorder where bkorder.bank = s_bank and bkorder.execute = yes and bkorder.point > 0 .
     if bkorder.info1 ne '' then next.
     repeat i = 1 to bkorder.counts:
        find first bkcard where bkcard.bank = s_bank and bkcard.nom = bkorder.nom and bkcard.point = 0 and bkcard.exec = yes and 
                                bkcard.nominal = bkorder.nominal exclusive-lock no-error.
           if avail bkcard then do:
              bkcard.point = bkorder.point.
              find current bkcard no-lock no-error.
              bkorder.info1 =  bkorder.info1 + bkcard.rbs + ','.
           end.
     end. 
 end.



output to ord1.html.

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

i = 0.
for each bkcard where bkcard.bank = s_bank  and bkcard.exec = yes and  bkcard.point > 0  no-lock break by bkcard.point.
if who1 ne '' or who2 ne '' then next.

if first-of(bkcard.point) then do:
    put unformatted   "<TABLE cellspacing=""0"" cellpadding=""3"" border=""0"">" skip
                         "<tr><td align=""center"" style=""font:bold;font-size:12.0pt;"">АКТ</td></tr>" skip
                         "<tr><td align=""center"" style=""font:bold;font-size:12.0pt;"">приема-передачи карт Visa Instant Issue/</td></tr>" skip
                         "<tr><td align=""center"" style=""font:bold;font-size:12.0pt;"">приема-передачи ПИН-конвертов к картам Visa Instant Issue</td></tr>" skip.
    put unformatted "</table>" skip.
    
    put unformatted  "<br><br>".
    
    find first cmp.
    put unformatted  "<P align=""left""> Настоящий Акт приема-передачи составлен " g-today " в " entry(1, cmp.addr[1]) " и свидетельствует о том, что: </P>" skip.
    
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    find first ppoint where ppoint.depart = bkcard.point no-lock no-error.
    if avail ofc and avail ppoint then 
    put unformatted  "<P align=""left""> Я, менеджер Департамента потребительского кредитования АО TEXAKABANK, " 
                        ofc.name format 'x(30)' " передал(-а), а менеджер " ppoint.name  " ___________________________________ принял карты/ПИН-конверты: </P>" skip.
    
    put unformatted  "<br><br>".
    
    put unformatted   "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                  "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                  "<td rowspan=2 align=center>N</td>"
                  "<td rowspan=2 align=center>Номер карты/ ПИН-конверта</td>"
                  "<td rowspan=2 align=center>Срок действия карты</td>"
                  "<td rowspan=2 align=center>Номинал карты</td>"
                  "</tr><tr></tr>" skip.
end.
    i = i + 1.
    put unformatted 
       "<TR>"
       "<TD>" i "</TD>" skip
       "<TD >&nbsp;" string(bkcard.contract_number) format "x(16)" "</TD>" skip
       "<TD>" month(bkcard.whn) "/" year(bkcard.whn) + 1 "</TD>" skip
       "<TD>" bkcard.nominal "</TD>" skip
       "</TR>" skip.

if last-of(bkcard.point) then do:
     put unformatted "</table>" skip.
     put unformatted "<br><b> Итого: " i " карт/ ПИН-конвертов</b>" skip.
     put unformatted  "<br><br>".
     put unformatted "<br> Настоящий акт составлен в двух экземплярах " skip.
     put unformatted  "<br><br>".
     put unformatted "<br> Передал(-а)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Принял(-а)" skip.
     put unformatted  "<br>".
     put unformatted  "<br>___________/______________________/
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
     ___________/______________________/" skip.
     put unformatted  "<br>подпись&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ФИО
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
     подпись&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ФИО" skip.
 
     put unformatted "<br clear=all style='page-break-before:always'>" skip.
     i = 0.
end.
end.

put unformatted "</table></body></html>" skip.
output close.
unix silent cptwin ord1.html winword.
