/* vcpldoc.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по контрактам с переводами.
 * RUN
        15-10
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        18/01/05 saltanat
 * CHANGES
*/

{vc.i}

{mainhead.i}
{get-dep.i}

def var v-dtb     as date.
def var v-dte     as date.
def var v-numstr  as integer.
def var conttype  as char.
def var documtype as char.
def var departid  as integer.
def var v-gtd     as char init '02,03'.

def temp-table t-docsa
    field id      as   inte
    field dep     as   inte
    field ctype   as   char
    field cif     as   char
    field sts     as   char
    field ctnum   like vccontrs.ctnum
    field partner as   char
    field ps      as   char
    field psdt    like vcps.dndate
    field sum     as   deci 
    field crc     like vcps.ncrc
index id-dep dep
index id-typ ctype.

form
   skip(1)
   v-dtb label 'Начало периода' format '99/99/9999' skip
   v-dte label ' Конец периода' format '99/99/9999' skip(1)
   with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

v-dtb = g-today.
v-dte = g-today.

update v-dtb v-dte with frame f-dt.

/* Заполнение временной таблицы  */ 


for each comm.vcdocs where comm.vcdocs.dndate >= v-dtb and comm.vcdocs.dndate <= v-dte no-lock:

   if lookup(comm.vcdocs.dntype,v-gtd) = 0 then next.

   /*if comm.vcdocs.cdt <> ? then next.
   */
   for each comm.vccontrs of comm.vcdocs no-lock:
  
     if comm.vccontrs.cttype ne "1" then next.

     find cif where cif.cif = vccontrs.cif no-lock no-error.
     if not avail cif then next.

     find vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
     if not avail vcps then next.

     find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
     if not avail vcpartners then next.

     create t-docsa.
     assign
      t-docsa.id    = v-numstr
      t-docsa.dep   = integer(cif.jame) mod 1000
      t-docsa.ctype = comm.vccontrs.expimp
      t-docsa.cif   = cif.name
      t-docsa.sts   = comm.vccontrs.sts
      t-docsa.ctnum = comm.vccontrs.ctnum
      t-docsa.partner = comm.vcpartners.name
      t-docsa.ps    = comm.vcps.dnnum
      t-docsa.psdt  = comm.vcdocs.dndate
      t-docsa.sum   = comm.vcdocs.sum
      t-docsa.crc   = comm.vcdocs.pcrc.

   end. /* vccontrs */

end. /* vcdocs */




v-numstr = 0.

/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Переводы за период"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>ПЕРЕВОДЫ<BR>за период с " + string(v-dtb, "99/99/9999") + 
       " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip

   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.



for each t-docsa break by t-docsa.dep by t-docsa.ctype by t-docsa.ctnum: 
 
   if first-of(t-docsa.dep) then do:
     find first ppoint where ppoint.depart = t-docsa.dep no-lock no-error.
     put stream vcrpt unformatted 
       "<TR align=""center"" bgcolor=""#C0C0C0"">" skip
        "<TD colspan=""8""><FONT size=""3""><B>" ppoint.name "</B></FONT></TD>" skip
       "</TR>" skip.
   end.

   if first-of(t-docsa.ctype) then do:
   v-numstr = 0.
   put stream vcrpt unformatted 
    "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>N</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" if t-docsa.ctype = 'i' then "Импортер" else "Экспортер" "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Статус на<BR>данный момент<BR>A/C</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Контраскт N=DD</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" if t-docsa.ctype = 'i' then "Экспортер" else "Импортер" "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Паспорт сделки</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма перевода</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Код вал.</B></FONT></TD>" skip
    "</TR>" skip.

   end.
/*     "<TD><FONT size=""2""><B>Дата перевода</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-docsa.psdt, "99/99/99") + "</FONT></TD>" skip
*/
   if first-of(t-docsa.ctnum) then do:
   v-numstr = v-numstr + 1.

   put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + string(v-numstr)                 + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-docsa.cif + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-docsa.sts                      + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-docsa.ctnum                    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-docsa.partner                  + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-docsa.ps                       + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-docsa.sum)              + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-docsa.crc)              + "</FONT></TD>" skip
   "</TR>" skip.
   end.
 
end.

put stream vcrpt unformatted  
"</TABLE>" skip.


{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.htm iexplore").

pause 0.
