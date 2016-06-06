/* vcrepk8out.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        28.05.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        16.07.2012 damir - подкинул, вывод ч/з wrkTemp.
        26.03.2013 damir - Внедрено Т.З. № 1713.
*/
{vcrepk8var.i}

def var i as int.
def var v-bnkbin as char.
def var vv-month as char.

if month(v-dt1) = 1  then vv-month = "Январь".
if month(v-dt1) = 2 then vv-month = "Февраль".
if month(v-dt1) = 3 then vv-month = "Март".
if month(v-dt1) = 4 then vv-month = "Апрель".
if month(v-dt1) = 5 then vv-month = "Май".
if month(v-dt1) = 6 then vv-month = "Июнь".
if month(v-dt1) = 7 then vv-month = "Июль".
if month(v-dt1) = 8 then vv-month = "Август".
if month(v-dt1) = 9 then vv-month = "Сентябрь".
if month(v-dt1) = 10 then vv-month = "Октябрь".
if month(v-dt1) = 11 then vv-month = "Ноябрь".
if month(v-dt1) = 12 then vv-month = "Декабрь".

find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
if avail sysc then v-bnkbin = sysc.chval.
else v-bnkbin = "".

def stream vcrpt.

output stream vcrpt to vcrepk8.doc.
{html-title.i
 &title = "Приложение 8" &stream = "stream vcrpt" &size-add = "x-"}
 find first cmp no-lock no-error.

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman""></P>" skip
   "<P align = ""right""><FONT size=""2"" face=""Times New Roman"">"
   "Приложение 8<br>
    к Правилам осуществления<br>
    экспортно-импортного<br>
    валютного контроля в<br>
    Республике Казахстан, утвержденным постановлением <br>
    Правления Национального Банка Республики Казахстан <br>
    от 24 февраля 2012 года №42</B><br></p>"
    "<P align = ""center""> Информация об экспортере или импортере, осуществившем платежи и (или) переводы денег <br>
    свыше ста тысяч долларов США в эквиваленте<br>
    за " vv-month " месяц " year(v-dt1) " год<br></p>"

    "<P align = ""left"">БИН/Код ОКПО уполномоченного банка " v-bnkbin "<br></FONT>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Исходящие платежи, которых нет в Прагме. */
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD rowspan = 2><FONT size=""2""><B>№</B></FONT></TD>" skip
     "<TD colspan = 6><FONT size=""2""><B>Информация по экспортеру или импортеру</B></FONT></TD>" skip
     "<TD colspan = 4><FONT size=""2"" ><B>Информация о платежах и (или) переводах</B></FONT></TD>" skip
   "</TR>" skip.
put stream vcrpt unformatted "<tr style=""font:bold"">"
   "<td align=""center"">Наименование или фамилия, имя, отчество</td>"
   "<td align=""center"">БИН</td>"
   "<td align=""center"">ИИН</td>"
   "<td align=""center"">Признак –юридическое лицо или индивидуальный предприниматель</td>"
   "<td align=""center"">Адрес</td>"
   "<td align=""center"">Код области</td>"
   "<td align=""center"">Признак – экспорт или импорт </td>"
   "<td align=""center"">Признак – исходящий, входящий</td>"
   "<td align=""center"">Сумма</td>"
   "<td align=""center"">Примечание </td></tr>" skip.

i = 0.
for each wrkTemp where wrkTemp.amti > 100000 or wrkTemp.amte > 100000 no-lock:
    i = i + 1.
    put stream vcrpt unformatted
    "<TD><FONT size=""2"">" + string(i) + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrkTemp.cname   + "</FONT></TD>" skip.
    if wrkTemp.prefix = "ТОО" then put stream vcrpt unformatted
    "<TD><FONT size=""2"">" + wrkTemp.bin + "</FONT></TD>" skip
    "<TD><FONT size=""2"">"  "</FONT></TD>" skip.
    if wrkTemp.prefix = "ИП" then put stream vcrpt unformatted
    "<TD><FONT size=""2"">"  "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrkTemp.rnn + "</FONT></TD>" skip.
     put stream vcrpt unformatted
    "<TD><FONT size=""2"">" + wrkTemp.ctype + "</FONT></TD>" skip.
    put stream vcrpt unformatted
    "<TD><FONT size=""2"">" + wrkTemp.adr + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrkTemp.obl + "</FONT></TD>" skip.
    if wrkTemp.expimp = "i" then put stream vcrpt unformatted
    "<TD><FONT size=""2"">" + "2" + "</FONT></TD>" skip.
    else put stream vcrpt unformatted
    "<TD><FONT size=""2"">" + "1" + "</FONT></TD>" skip.
    put stream vcrpt unformatted
    "<TD><FONT size=""2"">" + wrkTemp.inout + "</FONT></TD>" skip.
    if wrkTemp.expimp = "I" then
    put stream vcrpt unformatted "<TD><FONT size=""2"">" + replace(trim(string(wrkTemp.amti, "->>>>>>>>>>>>>>>>>>>9.99")),".",",") + "</FONT></TD>" skip.
    if wrkTemp.expimp = "E" then
    put stream vcrpt unformatted "<TD><FONT size=""2"">" + replace(trim(string(wrkTemp.amte, "->>>>>>>>>>>>>>>>>>>9.99")),".",",") + "</FONT></TD>" skip.
    put stream vcrpt unformatted "<TD><FONT size=""2"">" + wrkTemp.note + "</FONT></TD>" skip.
    put stream vcrpt unformatted "</TR>" skip.
end.

put stream vcrpt unformatted "</TABLE>" skip.
{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcrepk8.doc winword").

pause 0.

