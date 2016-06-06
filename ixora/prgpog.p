/* prgpog.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчет по плановым погашениям за период
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
       01/04/2011
 * BASES
	BANK, COMM
 * CHANGES
   08/11/2011 kapar - по служебной записке
*/

{mainhead.i}

def new shared temp-table lnpr
  field nf       as   int
  field sf       as   char
  field sum_od   as   decimal
  field sum_pr   as   decimal.

def new shared var b-dt as date.
def new shared var e-dt as date.

def var usrnm as char no-undo.
def var v-bank as char no-undo.

do transaction:
     update b-dt label 'ЗАДАЙТЕ ПЕРИОД С'
             help "Введите начальную дату."
            e-dt label 'ПО'
             help "Введите конечную дату."
            with row 5 centered  side-label frame opt.
  if e-dt < b-dt then
   do:
     message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
     undo,retry.
   end.
end.

{r-brfilial.i &proc = "prgpogf" }

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
      "<BR><b>Отчетность по динамике выдач кредитных средств</b><BR><br>" skip.

  put stream repdvk unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td>Филиал</td>" skip
  "<td>Сумма ОД в тенге</td>" skip
  "<td>Сумма процентов в тенге</td>" skip.

  for each lnpr no-lock:
       put stream repdvk unformatted "<tr style=""font:bold"">" skip.
         put stream repdvk unformatted
        "<td>" lnpr.sf "</td>" skip.
        put stream repdvk unformatted
        "<td>" replace(trim(string(lnpr.sum_od, "->>>>>>>>>>>>>>9.99")),".",",") " </td>" skip.
        put stream repdvk unformatted
        "<td>" replace(trim(string(lnpr.sum_pr, "->>>>>>>>>>>>>>9.99")),".",",") " </td>" skip.
  end.

put stream repdvk unformatted "</table></body></html>".
output stream repdvk close.
unix silent cptwin repdvk.htm excel.

hide message no-pause.































































