/* kurs.p
 * MODULE
         ГБ отчетность
 * DESCRIPTION
         Курсовая разница за период
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
 * BASES
        BANK COMM
 * AUTHOR
        14/08/10 marina
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


{nbankBik.i}

def new shared temp-table wrk
  field gl       like bank.gl.gl
  field dt       as date
  field sum1     as deci  format "->>>,>>>,>>>,>>9.99"
  field sum2     as deci  format "->>>,>>>,>>>,>>9.99"
  field diff     as deci  format "->>>,>>>,>>>,>>9.99".


def new shared var d1 as date.
def new shared var d2 as date.

form d1 label ' Укажите период с' format '99/99/9999' d2 label ' по' format '99/99/9999' skip(1)
with side-label row 5 width 48 centered frame dat.
update d1 d2 with frame dat.



{r-brfilial.i &proc = "kurs1"}


pause 0.
define new shared stream m-out.
output stream m-out to "rep.html".
put stream m-out "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".


put stream m-out unformatted
  "<P style=""font:bold;font-size:x-small""></P>"
  "<P align=""left"" style=""font:bold;font-size:x-small""></P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>Счет</TD>" skip
/*        "<TD>Дата</TD>" skip*/
        "<TD>Сумма 1 (предыд день)</TD>" skip
        "<TD>Сумма 2</TD>" skip
        "<TD>Разница</TD>" skip
       "</TR>" skip.

for each wrk where wrk.sum1 ne wrk.sum2.
         put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>" wrk.gl "</TD>" skip
                      /* "<TD>" wrk.dt "</TD>" skip*/
                       "<TD>" replace(trim(string(wrk.sum1 , "->>>>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(wrk.sum2 , "->>>>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(wrk.sum2 - wrk.sum1, "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                     "</TR>" skip.

end.

put stream m-out "</table>" skip.
put stream m-out "</table>" skip.
put stream m-out "</body></html>".
output stream m-out close.
unix silent cptwin rep.html excel.



