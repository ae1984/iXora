/* braksum.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Отчет по услугам ОАО TEXAKABANK новобрачным клиентам
 * RUN
        
 * CALLER
        nmenu.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        08/06/2005 kanat
 * CHANGES
*/


define variable v-string as char.
v-string = "108104,108108,108111".

def temp-table ttmps 
    field kbk as integer
    field hsum as decimal
    field hsum1 as decimal
    field hcomsum as decimal.


def temp-table ttmps_cis 
    field type as integer
    field npl as char
    field hsum as decimal
    field hsum1 as decimal
    field hcomsum as decimal.

def temp-table ttmpd
    field sums as decimal
    field hcomsum as decimal.

define variable v-count as integer.

define variable v-date-begin as date label "Начало периода".
define variable v-date-fin as date label "Конец периода". 

define variable v-whole-sum1 as decimal.
define variable v-whole-sum2 as decimal.

define variable v-wamt1 as decimal. /* суммы от 1 до 100 тенге */
define variable v-wamt2 as decimal. /* суммы от 101 до 3000 тенге */
define variable v-wamt3 as decimal. /* суммы свыше 3000 тенге */

define variable v-wcnt1 as decimal. /* количество от 1 до 100 тенге */
define variable v-wcnt2 as decimal. /* количество от 101 до 3000 тенге */
define variable v-wcnt3 as decimal. /* количество свыше 3000 тенге */

update v-date-begin v-date-fin with centered frame frame_for_edit. 

if v-date-begin > v-date-fin then do:
message "Задан неверный период" view-as alert-box title "Внимание".
return.
end.


for each tax where tax.txb = 0 and tax.date >= v-date-begin and tax.date <= v-date-fin 
                   and tax.duid = ? and 
                   lookup(string(tax.kb,"999999"), v-string) <> 0 
                   no-lock break by tax.kb.         
create ttmps.
update ttmps.kbk = tax.kb
       ttmps.hsum = tax.sum
       ttmps.hsum1 = tax.sum
       ttmps.hcomsum = tax.comsum.
end.



for each commonpl where commonpl.txb = 0 and commonpl.date >= v-date-begin and commonpl.date <= v-date-fin and commonpl.deluid = ? and 
                        commonpl.grp = 1 and commonpl.arp = "010904103" no-lock break by commonpl.type by commonpl.sum.
create ttmps_cis.
update ttmps_cis.type = commonpl.type
       ttmps_cis.npl = commonpl.npl
       ttmps_cis.hsum = commonpl.sum
       ttmps_cis.hsum1 = commonpl.sum
       ttmps_cis.hcomsum = commonpl.comsum.
end.


output to braksum.xls.
 {html-start.i " "}

put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "Анализ доходов от платежей по документированию населения и ЗАГС</FONT><BR><BR>" skip
   "<FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" 
   "за период с " + string(v-date-begin, "99/99/9999") + " по " + string(v-date-fin, "99/99/9999") + "</FONT></P></B>" skip
   "<TABLE width=""140%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip.

  put unformatted
     "<TD><FONT size=""2""><B>N</B></FONT></TD>"  skip
     "<TD><FONT size=""2""><B>КБК</B></FONT></TD>"  skip
     "<TD><FONT size=""2""><B>Вид платежей</B></FONT></TD>"  skip
     "<TD><FONT size=""2""><B>Сумма платежа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Комиссия</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Количество</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Доходы</B></FONT></TD>" skip
   "</TR>".

for each ttmps no-lock break by ttmps.kbk by ttmps.hsum1.

if first-of (ttmps.kbk) then
put unformatted "<TR bgcolor = ""C0C0C0""><TD><B>" string(ttmps.kbk, "999999") "</B></TD></TR>" skip.

  accumulate ttmps.hsum (sub-count by ttmps.kbk by ttmps.hsum1).             
  accumulate ttmps.hcomsum (sub-total by ttmps.kbk by ttmps.hsum1).
  accumulate ttmps.hcomsum (count).
  accumulate ttmps.hcomsum (total).

if last-of (ttmps.hsum1) then do:

find first budcodes where budcodes.code = ttmps.kbk no-lock no-error.
if avail budcodes then do:

v-count = v-count + 1.

put unformatted "<TR><TD>" string(v-count) "</TD>" skip
                "<TD><B>" string(ttmps.kbk, "999999") "</B></TD>" skip
                "<TD>" budcodes.name "</TD>" skip
                "<TD align = ""center""><B>" ttmps.hsum1 "</B></TD>" skip
                "<TD>" ttmps.hcomsum "</TD>" skip
                "<TD><B>" (accum sub-count by ttmps.hsum1 ttmps.hsum) "</B></TD>" skip
                "<TD><B>" (accum sub-total by ttmps.hsum1 ttmps.hcomsum) "</B></TD></TR>" skip.

create ttmpd.
update ttmpd.sums = ttmps.hsum1
       ttmpd.hcomsum = (accum sub-total by ttmps.hsum1 ttmps.hcomsum). 


end. /* avail budcodes then ...  */
end. /* last-of ttmps.hsum1 */
end. /* for each ttmps ... */

put unformatted "<TR bgcolor = ""C0C0C0""><TD align = ""right""><B>ИТОГО</B></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD><B>" string(accum count ttmps.hcomsum) "</B></TD>" skip
                "<TD><B>" string(accum total ttmps.hcomsum) "</B></TD></TR></TABLE></P>" skip.


put unformatted
   "<BR>" skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "Платежи за услуги КГП ЦИС по г. Алматы</FONT><BR><BR>" skip
   "<FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" 
   "за период с " + string(v-date-begin, "99/99/9999") + " по " + string(v-date-fin, "99/99/9999") + "</FONT></P></B>" skip
   "<TABLE width=""140%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip.

  put unformatted
     "<TD><FONT size=""2""><B>N</B></FONT></TD>"  skip
     "<TD><FONT size=""2""><B>КБК</B></FONT></TD>"  skip
     "<TD><FONT size=""2""><B>Вид платежей</B></FONT></TD>"  skip
     "<TD><FONT size=""2""><B>Сумма платежа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Комиссия</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Количество</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Доходы</B></FONT></TD>" skip
   "</TR>".

v-count = 0.

for each ttmps_cis no-lock break by ttmps_cis.type by ttmps_cis.hsum1.
if first-of (ttmps_cis.type) then 
put unformatted "<TR bgcolor = ""C0C0C0""><TD></TD></TR>" skip.

  accumulate ttmps_cis.hsum (sub-count by ttmps_cis.type by ttmps_cis.hsum1).             
  accumulate ttmps_cis.hcomsum (sub-total by ttmps_cis.type by ttmps_cis.hsum1).
  accumulate ttmps_cis.hcomsum (count).
  accumulate ttmps_cis.hcomsum (total).

if last-of (ttmps_cis.hsum1) then do:

v-count = v-count + 1.

put unformatted "<TR><TD>" string(v-count) "</TD>" skip
                "<TD></TD>" skip
                "<TD>" ttmps_cis.npl "</TD>" skip
                "<TD align = ""center""><B>" ttmps_cis.hsum "</B></TD>" skip
                "<TD>" ttmps_cis.hcomsum "</TD>" skip
                "<TD><B>" (accum sub-count by ttmps_cis.hsum1 ttmps_cis.hsum) "</B></TD>" skip
                "<TD><B>" (accum sub-total by ttmps_cis.hsum1 ttmps_cis.hcomsum) "</B></TD></TR>" skip.

create ttmpd.
update ttmpd.sums = ttmps_cis.hsum1
       ttmpd.hcomsum = (accum sub-total by ttmps_cis.hsum1 ttmps_cis.hcomsum). 

end. /* last of ttmps_cis.hsum1 ... */
end. /* for each commonpl .... */


put unformatted "<TR bgcolor = ""C0C0C0""><TD align = ""right""><B>ИТОГО</B></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD><B>" string(accum count ttmps_cis.hcomsum) "</B></TD>" skip
                "<TD><B>" string(accum total ttmps_cis.hcomsum) "</B></TD></TR>" skip.


for each ttmpd no-lock break by ttmpd.sums.

if ttmpd.sums >= 1 and ttmpd.sums <= 100 then do:
v-wamt1 = v-wamt1 + ttmpd.hcomsum.
v-wcnt1 = v-wcnt1 + 1.
end.


if ttmpd.sums > 100 and ttmpd.sums <= 3000 then do:
v-wamt2 = v-wamt2 + ttmpd.hcomsum.
v-wcnt2 = v-wcnt2 + 1.
end.


if ttmpd.sums > 3000 then do:
v-wamt3 = v-wamt3 + ttmpd.hcomsum.
v-wcnt3 = v-wcnt3 + 1.
end.

end. /* for each ttmpd ... */

put unformatted "<TR><TD></TD>" skip
                "<TD>Суммы от 1 до 100 тенге</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD><B>" v-wcnt1 "</B></TD>" skip
                "<TD><B>" v-wamt1 "</B></TD></TR>" skip.

put unformatted "<TR><TD></TD>" skip
                "<TD>Суммы от 101 до 3000 тенге</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD><B>" v-wcnt2 "</B></TD>" skip
                "<TD><B>" v-wamt2 "</B></TD></TR>" skip.

put unformatted "<TR><TD></TD>" skip
                "<TD>Суммы свыше 3000 тенге</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD><B>" v-wcnt3 "</B></TD>" skip
                "<TD><B>" v-wamt3 "</B></TD></TR>" skip.

put unformatted "<TR bgcolor = ""C0C0C0""><TD align = ""right""><B>ВСЕГО</B></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD><B>" (v-wcnt1 + v-wcnt2 + v-wcnt3) "</B></TD>" skip
                "<TD><B>" (v-wamt1 + v-wamt2 + v-wamt3) "</B></TD></TR>" skip.

put unformatted "</TABLE></P>" skip.

 {html-end.i " "}
output close. 

unix silent value("cptwin braksum.xls excel").
pause 0.
