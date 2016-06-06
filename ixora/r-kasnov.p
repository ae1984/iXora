/* r-kasnov.p
 * MODULE
         ОД отчетность
 * DESCRIPTION
         Счета Касса Нова за период
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
        17/08/10 marina
 * CHANGES
        14.09.10 marinav - добавлены поля валюта и дата закрытия
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


{nbankBik.i}

def new shared var d1 as date.
def new shared var d2 as date.

form d1 label ' Укажите период с' format '99/99/9999' d2 label ' по' format '99/99/9999' skip(1)
with side-label row 5 width 48 centered frame dat.
update d1 d2 with frame dat.



pause 0.
define new shared stream m-out.
output stream m-out to "rep.html".
put stream m-out "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".

put stream m-out unformatted
  "<P style=""font:bold;font-size:x-small""></P>"
  "<P align=""left"" style=""font:bold;font-size:x-small"">Счета, открытые для кредитов Банка Kassa Nova с " d1 " по " d2 "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>ФИО клиента/ Название компании</TD>" skip
        "<TD>ИИК</TD>" skip
        "<TD>Валюта счета</TD>" skip
        "<TD>Дата открытия</TD>" skip
        "<TD>Дата закрытия</TD>" skip
        "<TD>Полученный доход в тенге</TD>" skip
        "<TD>Филиал</TD>" skip
       "</TR>" skip.


{r-brfilial.i &proc = "r-kasnov1.p"}


put stream m-out "</table>" skip.
put stream m-out "</table>" skip.
put stream m-out "</body></html>".
output stream m-out close.
unix silent cptwin rep.html excel.



