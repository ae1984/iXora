/* amrk_rpt.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчет для проверки амортизации комиссии
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
       kapar
 * BASES
	   BANK COMM
 * CHANGES
       07/03/2012 madiyar - инициализация даты
       01/11/2013 galina - ТЗ1897 поменяла наименование столбцов
*/

{mainhead.i}

def new shared temp-table lnpr no-undo
  field fname    as   char
  field cname    as   char
  field ndog     as   char
  field lon      as   char
  field nsum     as   decimal
  field ksum     as   decimal
  field gsum     as   decimal
  field rsum     as   decimal.

def var usrnm as char no-undo.
def var v-bank as char no-undo.

def new shared var dt as date.
find last cls where cls.del no-lock no-error.
dt = cls.whn.
update dt label '      За дату' format '99/99/9999' validate (dt <= g-today, " Дата должна быть не позже текущей!") skip
       skip with side-label row 5 centered frame dat title "Отчет по амортизации комиссии".

{r-brfilial.i &proc = "amrk_rptf"}

def stream repdvk.
output stream repdvk to repdvk.htm.

  put stream repdvk unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream repdvk unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.

  put stream repdvk unformatted
      "<BR><b> Отчет по амортизации комиссии </b><BR>" skip
      "<b>Отчет за " string(dt) "</b><br>" skip.

  put stream repdvk unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td valign=""center"">Филиал</td>" skip
  "<td valign=""center"">Заемщик</td>" skip
  "<td valign=""center"">№ Договора</td>" skip
  "<td valign=""center"">Ссудный счет</td>" skip
  "<td valign=""center"">Общая сумма<br>комиссии</td>" skip
  "<td valign=""center"">остаток несамортизированной<br>комиссии на балансе 1434</td>" skip
  "<td valign=""center"">Амортизированная сумма<br>комиссии по графику</td>" skip
  "<td valign=""center"">Расхождения</td>" skip.

  for each lnpr no-lock:
    put stream repdvk unformatted "<tr>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.fname "</td>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.cname "</td>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.ndog "</td>" skip.
    put stream repdvk unformatted
    "<td>'" lnpr.lon "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.ksum,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.gsum,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.rsum,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
  end.

put stream repdvk unformatted "</table></body></html>".
output stream repdvk close.
unix silent cptwin repdvk.htm excel.

hide message no-pause.































































