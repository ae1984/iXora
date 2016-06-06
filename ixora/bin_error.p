/* bin_error.p
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
        04.07.2013 evseev tz-1544
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def var v-file  as char init "binerror.html"  no-undo.
def stream rep.


output to value(v-file).
{html-title.i &size-add = "x-"}
 put unformatted
   "<P align=""center"" style=""font:bold"">Ошибки возникшие при загрузке справочника ИИН/БИН</P>" skip
   "<P align=""center"" style=""font:bold"">за " string(g-today, "99/99/9999") " года</P>" skip
   "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
       "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
         "<TD>Имя файла</TD>" skip
         "<TD>Строка</TD>" skip
         "<TD>Ошибка</TD>" skip
         "<TD>Обрабатываемая строка</TD>" skip
       "</TR>" skip.


for each bin_err where bin_err.rdt = today no-lock:
    put unformatted
      "<TR>" skip
        "<TD>" bin_err.fname "</TD>" skip
        "<TD>" bin_err.line "</TD>" skip
        "<TD>" bin_err.des "</TD>" skip
        "<TD>" bin_err.line_val "</TD>" skip
      "</TR>" skip.
end.


put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.

unix silent cptwin value(v-file) excel.