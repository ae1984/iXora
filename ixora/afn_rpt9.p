/* afn.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчеты по проверкам фин-хоз деятельности заемщиков и залогового обеспечения
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

*/

{mainhead.i}

def new shared temp-table lnpr no-undo
  field id       as   int
  field kname    as   char
  field gid      as   int
  field gname    as   char
  field nsum     as   decimal
  field psum     as   decimal.

def var vnf      as   int.
def var vnsum    as   decimal.

def var usrnm as char no-undo.
def var v-bank as char no-undo.

def var r1 as char no-undo.
r1 = "Кредиты резидентам/нерезидентам".

def new shared var vcode as int.
def new shared var dt as date.
update dt label '                 За дату' format '99/99/9999' validate (dt <= g-today, " Дата должна быть не позже текущей!") skip
       skip with side-label row 5 centered frame dat title r1 .

{r-brfilial.i &proc = "afn_rpt9f"}


def var h1 as char no-undo.
def var h2 as char no-undo.
def var h3 as char no-undo.
h1 = "Резиденты/Нерезиденты (Страна)".
h2 = "Сумма".
h3 = "Удельный вес".

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
      "<BR><b>" r1 "</b><BR>" skip
      "<b>Отчет за " string(dt) "</b><br>" skip.

  put stream repdvk unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td valign=""center"">" "Вид валюты" "</td>" skip
  "<td valign=""center"">" h1 "</td>" skip
  "<td valign=""center"">" h2 "</td>" skip
  "<td valign=""center"">" h3 "</td>" skip.

  vnsum = 0.
  for each lnpr no-lock:
    vnsum = vnsum + lnpr.nsum.
  end.

  for each lnpr no-lock:
    put stream repdvk unformatted "<tr>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.kname "</td>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.gname "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum / vnsum) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
  end.

    put stream repdvk unformatted "<tr style=""font:bold"">" skip.
    put stream repdvk unformatted
    "<td> Всего </td>" skip.
    put stream repdvk unformatted
    "<td> </td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(vnsum,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((vnsum / vnsum) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.

  put stream repdvk unformatted "</table></body></html>".
  output stream repdvk close.
  unix silent cptwin repdvk.htm excel.

hide message no-pause.































































