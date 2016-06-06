/* vcrepdolg.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по долгам
 * RUN
        Отчет по долгам
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        23/06/04 saltanat
 * CHANGES
*/

{vc.i}

{mainhead.i}
{get-dep.i}

def var v-dt as date.
def var v-num as integer.
def var departid as integer.

def new shared temp-table t-dolgs 
  field depart as int
  field codcl as char
  field clname as char
  field ctnum as char
  field dnnum as char
  field dnvn as date init '?'
  field dnpg as date init '?'
  field dopsv as char.

form
   skip(1)
   v-dt label 'На дату' format '99/99/9999' skip
   with centered side-label row 5 title "УКАЖИТЕ ДАТУ ДЛЯ ОТЧЕТА" frame f-dt.

v-dt = g-today.

update v-dt with frame f-dt.

/* Определение пользователя */
departid = get-dep(g-ofc,g-today).
 
v-num = 0.

/* Заполнение временной таблицы  */ 
for each comm.vcdolgs where comm.vcdolgs.dnpg < v-dt and vcdolgs.cdt = ? no-lock:
   for each comm.vccontrs of comm.vcdolgs no-lock:
      for each cif of comm.vccontrs no-lock:
          create t-dolgs.
          t-dolgs.depart = integer(cif.jame) mod 1000.
          t-dolgs.codcl = cif.cif.
          t-dolgs.clname = cif.name.
          t-dolgs.ctnum = comm.vccontrs.ctnum.
          t-dolgs.dnnum = comm.vcdolgs.dnnum.
          t-dolgs.dnvn = comm.vcdolgs.dnvn.
          t-dolgs.dnpg = comm.vcdolgs.dnpg.
          t-dolgs.dopsv = comm.vcdolgs.dopsv + " " + comm.vcdolgs.info[1] + " " + comm.vcdolgs.info[2] + " " + comm.vcdolgs.info[3]. 
      end.
   end.
end.

/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Список задолжников"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>СПИСОК ЗАДОЛЖНИКОВ<BR>за дату: " + string(v-dt, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Вывод в отчет неакцептованных контрактов */

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Н</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Код клиента</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Наименование клиента</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер контракта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер документа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата внесения</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата погашения долга</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Примечание</B></FONT></TD>" skip
   "</TR>" skip.


for each t-dolgs break by t-dolgs.depart: 
 
 if departid = 1 then do:

   if first-of(t-dolgs.depart) then do:
     find first ppoint where ppoint.depart = t-dolgs.depart no-lock no-error.
     put stream vcrpt unformatted 
       "<TR align=""center"">" skip
        "<TD colspan=""8""><FONT size=""2""><B>" ppoint.name "</B></FONT></TD>" skip
       "</TR>" skip.
   end.

   v-num = v-num + 1.

   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + string(v-num) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.codcl + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.clname + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.ctnum + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.dnnum + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-dolgs.dnvn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-dolgs.dnpg, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.dopsv + "</FONT></TD>" skip
   "</TR>" skip.
 
 end.
 else do:

  if t-dolgs.depart = departid then do:

   v-num = v-num + 1.

   put stream vcrpt unformatted 

   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + string(v-num) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.codcl + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.clname + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.ctnum + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.dnnum + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-dolgs.dnvn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-dolgs.dnpg, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-dolgs.dopsv + "</FONT></TD>" skip
   "</TR>" skip.

  end.
 end.
end.

put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.htm iexplore").

pause 0.
