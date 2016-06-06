/* r-credbd.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Отчет по непринятым досье
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-4-9-3
 * AUTHOR
        05/02/2007 Natalya D.
 * BASES
        bank, comm
 * CHANGES
        20/04/2007 madiyar - добавил из новой библиотеки
        25/07/2007 madiyar - добавил поле t-temp.fil
        30/07/2007 madiyar - изменил название отчета, теперь в название попадают все не сданные досье, не только отвергнутые
*/

{global.i}
def new shared temp-table t-temp no-undo
         field name as char
         field paydt as date
         field ofc-n as char
         field ofc-l as char
         field spf as char
         field fil as char
         field sts as char
         index idx is primary fil spf ofc-l.

def var coun as integer no-undo.
define stream m-out.

{r-brfilial.i &proc = "r-noaccd1(g-today)"}

output stream m-out to r-noaccd.html.

{html-title.i &stream = "stream m-out" &size-add = "x-"}

find first cmp no-lock no-error.
put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format "x(79)" "</h3></td></tr><br><br>" skip(1).
put stream m-out unformatted "<tr align=""center""><td><h3> Задолженность менеджеров по сдаче досье </h3></td></tr><br><br>" skip(1).
put stream m-out unformatted "<tr></tr><tr></tr>" skip(1).
put stream m-out unformatted
                  "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                  "<td>П/п</td>"
                  "<td>ФИО заемщика</td>"
                  "<td>Дата<br>выдачи<br>кредита</td>"
                  "<td>ФИО менеджера,<br>выдавшего кредит</td>"
                  "<td>Логин<br>менеджера,<br>выдавшего<br>кредит</td>"
                  "<td>СПФ</td>"
                  "<td>Филиал</td>"
                  "<td>Статус</td>"
                  "</tr>" skip.

coun = 1.
for each t-temp no-lock break by t-temp.fil by t-temp.spf by t-temp.ofc-l.
  put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " t-temp.name "</td>"
               "<td align=""center""> " t-temp.paydt format "99/99/9999" "</td>"
               "<td>" t-temp.ofc-n "</td>"
               "<td>" t-temp.ofc-l "</td>"
               "<td>" t-temp.spf "</td>"
               "<td>" t-temp.fil "</td>"
               "<td>" t-temp.sts "</td>"
               "</tr>" skip.
  coun = coun + 1.

end. 
put stream m-out unformatted "</table>" skip.

{html-end.i "stream m-out"}
output stream m-out close.
unix silent cptwin r-noaccd.html excel.