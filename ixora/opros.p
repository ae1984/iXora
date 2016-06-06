/* opros.p 
 * MODULE
        CALL Center
 * DESCRIPTION
        Отчет по данным опроса клиентов.
 * RUN
        call.p
 * CALLER
        call.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        п.16
 * AUTHOR
        13.06.2005 saltanat 
 * CHANGES
        21.06.2005 saltanat - Добавила источник "Наружная реклама".
        10.04.2006 suchkov  - Добавил источник "Ручки в транспорте".
        05.05.2006 suchkov  - Добавил источник "Реклама в супермаркетах".
*/
{global.i}

def var v-dt1 as date.
def var v-dt2 as date.
def var v-sid as inte.
def var i as inte.

def frame fr 
          v-dt1 format '99/99/99' label 'с'
          v-dt2 format '99/99/99' label 'по'
with title ' За период ' centered row 8 side-label.   
    
def temp-table tmp
    field a1 as inte extent 19
    field a2 as inte extent 19
    field a3 as inte extent 19
    field a4 as inte extent 19
    field a5 as inte extent 19
    field a6 as inte extent 19
    field a7 as inte extent 19
    field a8 as inte extent 19
    . 

v-dt1 = g-today. v-dt2 = g-today. 
update v-dt1 v-dt2 with frame fr. 
    
for each answ where answ.dat >= v-dt1
                and answ.dat <= v-dt2 no-lock:
    find opros where opros.sid = answ.sid no-lock no-error. 
         if opros.nu = 1 then do: 
            if opros.sts eq 'r' then v-sid = opros.sid.
            else v-sid = 0.
         end.
         else if opros.nu = 2 and v-sid ne 0 then do:
              
              find first tmp no-error.
              if not avail tmp then create tmp. 
              
              case opros.sid :
                   when 32 then i = 1.  
                   when 55 then i = 2.
                   when 33 then i = 3.
                   when 38 then i = 4.
                   when 41 then i = 5.
                   when 40 then i = 6.
                   when 39 then i = 7.
                   when 42 then i = 8.
                   when 56 then i = 9.
                   when 57 then i = 10.
                   when 58 then i = 11.
                   when 59 then i = 12.
                   when 60 then i = 13.
                   when 61 then i = 14.
                   when 44 then i = 15.
                   when 62 then i = 16.
                   when 65 then i = 17.
                   when 63 then i = 18.
                   otherwise next.
              end.

              case v-sid :
                   when 13 then do: tmp.a1[i] = tmp.a1[i] + 1. tmp.a1[19] = tmp.a1[19] + 1. end.
                   when 16 then do: tmp.a2[i] = tmp.a2[i] + 1. tmp.a2[19] = tmp.a2[19] + 1. end.
                   when 11 then do: tmp.a3[i] = tmp.a3[i] + 1. tmp.a3[19] = tmp.a3[19] + 1. end.
                   when 6  then do: tmp.a4[i] = tmp.a4[i] + 1. tmp.a4[19] = tmp.a4[19] + 1. end.
                   when 7  then do: tmp.a5[i] = tmp.a5[i] + 1. tmp.a5[19] = tmp.a5[19] + 1. end.
                   when 8  then do: tmp.a6[i] = tmp.a6[i] + 1. tmp.a6[19] = tmp.a6[19] + 1. end.
                   when 54 then do: tmp.a7[i] = tmp.a7[i] + 1. tmp.a7[19] = tmp.a7[19] + 1. end.
                   otherwise next.
              end.
               tmp.a8[i] = tmp.a8[i] + 1. tmp.a8[19] = tmp.a8[19] + 1. 
         end.

end.



/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Данные по опросу за период"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Данные по опросу <BR>за период с " + string(v-dt1, "99/99/9999") + 
       " по " + string(v-dt2, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
   
put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD rowspan = ""2""><FONT size=""2"">&nbsp;</FONT></TD>" skip
     "<TD colspan = ""3""><FONT size=""2""><b>Печатные СМИ</b></FONT></TD>" skip
     "<TD colspan = ""4""><FONT size=""2""><b>Радио</b></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Флаер в банке</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Промоакция</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>ALMA TV</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Интернет</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Родственники, коллеги</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Рассылка</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>e-mail рассылка</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Другое</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Наружная реклама</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Ручки в транспорте</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>Реклама в супермаркетах</B></FONT></TD>" skip
     "<TD rowspan = ""2""><FONT size=""2""><B>ИТОГО</B></FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Караван</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>АиФ</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>НП</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Европа+</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Русское радио</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ретро</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Хит FM</B></FONT></TD>" skip
   "</TR>" skip.

for each tmp : 

/* 11111111111111111111111111111111111 */
   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Быстрые деньги</B></FONT></TD>" skip.
   
   do i = 1 to 19:
   put stream vcrpt unformatted  
     "<TD><FONT size=""2"">" + string(a1[i]) + "</FONT></TD>" skip.
   end.
     
   put stream vcrpt unformatted  
   "</TR>" skip.

/* 22222222222222222222222222222222222222 */
   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Ипотека</B></FONT></TD>" skip.
   
   do i = 1 to 19:
   put stream vcrpt unformatted  
     "<TD><FONT size=""2"">" + string(a2[i]) + "</FONT></TD>" skip.
   end.
     
   put stream vcrpt unformatted  
   "</TR>" skip.

/* 333333333333333333333333333333333333333 */
   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Автокредит</B></FONT></TD>" skip.
   
   do i = 1 to 19:
   put stream vcrpt unformatted  
     "<TD><FONT size=""2"">" + string(a3[i]) + "</FONT></TD>" skip.
   end.
     
   put stream vcrpt unformatted  
   "</TR>" skip.

/* 44444444444444444444444444444444444444 */
   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Депозиты</B></FONT></TD>" skip.
   
   do i = 1 to 19:
   put stream vcrpt unformatted  
     "<TD><FONT size=""2"">" + string(a4[i]) + "</FONT></TD>" skip.
   end.
     
   put stream vcrpt unformatted  
   "</TR>" skip.

/* 55555555555555555555555555555555555555 */
   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Платежные карточки</B></FONT></TD>" skip.
   
   do i = 1 to 19:
   put stream vcrpt unformatted  
     "<TD><FONT size=""2"">" + string(a5[i]) + "</FONT></TD>" skip.
   end.
     
   put stream vcrpt unformatted  
   "</TR>" skip.

/* 66666666666666666666666666666666666666 */
   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Кредитные карточки</B></FONT></TD>" skip.
   
   do i = 1 to 19:
   put stream vcrpt unformatted  
     "<TD><FONT size=""2"">" + string(a6[i]) + "</FONT></TD>" skip.
   end.
     
   put stream vcrpt unformatted  
   "</TR>" skip.

/* 777777777777777777777777777777777777777 */
   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Операционное обслуживание</B></FONT></TD>" skip.
   
   do i = 1 to 19:
   put stream vcrpt unformatted  
     "<TD><FONT size=""2"">" + string(a7[i]) + "</FONT></TD>" skip.
   end.
     
   put stream vcrpt unformatted  
   "</TR>" skip.

/* 88888888888888888888888888888888888888 */
   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>ИТОГО</B></FONT></TD>" skip.
   
   do i = 1 to 19:
   put stream vcrpt unformatted  
     "<TD><FONT size=""2"">" + string(a8[i]) + "</FONT></TD>" skip.
   end.
     
   put stream vcrpt unformatted  
   "</TR>" skip.
 
end.

put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.htm excel").

pause 0.
   