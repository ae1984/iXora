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
  field nsum1    as   decimal
  field nsum2    as   decimal
  field nsum3    as   decimal
  field nsum4    as   decimal
  field nsum5    as   decimal
  field nsum6    as   decimal.

  def var vnsum1    as   decimal.
  def var vnsum2    as   decimal.
  def var vnsum3    as   decimal.
  def var vnsum4    as   decimal.
  def var vnsum5    as   decimal.
  def var vnsum6    as   decimal.

def var usrnm as char no-undo.
def var v-bank as char no-undo.

def var r1 as char no-undo.
r1 = "Отчет по просрочке по продуктам".

def new shared var vcode as int.
def new shared var dt as date.
update dt label '                 За дату' format '99/99/9999' validate (dt <= g-today, " Дата должна быть не позже текущей!") skip
       skip with side-label row 5 centered frame dat title r1 .

create lnpr.
  lnpr.id = 1.
  lnpr.kname = "Корпоративные кредиты(группы 10, 50), в т.ч.: ".
create lnpr.
  lnpr.id = 2.
  lnpr.kname = "Просрочка до 30 дней".
create lnpr.
  lnpr.id = 3.
  lnpr.kname = "Просрочка до 60 дней".
create lnpr.
  lnpr.id = 4.
  lnpr.kname = "Просрочка до 90 дней".
create lnpr.
  lnpr.id = 5.
  lnpr.kname = "Просрочка свыше 90 дней".
create lnpr.
  lnpr.id = 6.
  lnpr.kname = "МСБ(группы 11, 21, 14, 15, 16, 24, 25, 26, 54, 55, 56, 64, 65, 66, 70, 80), в т.ч.: ".
create lnpr.
  lnpr.id = 7.
  lnpr.kname = "Просрочка до 30 дней".
create lnpr.
  lnpr.id = 8.
  lnpr.kname = "Просрочка до 60 дней".
create lnpr.
  lnpr.id = 9.
  lnpr.kname = "Просрочка до 90 дней".
create lnpr.
  lnpr.id = 10.
  lnpr.kname = "Просрочка свыше 90 дней".
create lnpr.
  lnpr.id = 11.
  lnpr.kname = "Розница (81, 82, 90, 92, 20, 60, 27, 28, 67, 68), в т.ч.: ".
create lnpr.
  lnpr.id = 12.
  lnpr.kname = "Просрочка до 30 дней".
create lnpr.
  lnpr.id = 13.
  lnpr.kname = "Просрочка до 60 дней".
create lnpr.
  lnpr.id = 14.
  lnpr.kname = "Просрочка до 90 дней".
create lnpr.
  lnpr.id = 15.
  lnpr.kname = "Просрочка свыше 90 дней".

{r-brfilial.i &proc = "afn_rpt15f"}


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
  "<table border=1 cellpadding=0 cellspacing=0>"
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
  "<td valign=""center""> Филиал </td>"
  "<td valign=""center"" colspan=2> Кредитный портфель (ОД+просроченный ОД) (1401, 1407, 1411, 1417, 1424) </td>"
  "<td valign=""center"" colspan=2> Просроченная задолженность (ОД) (1424) </td>"
  "<td valign=""center"" colspan=2> Начисленное вознаграждение (1740) </td>"
  "<td valign=""center"" colspan=2> Просроченное вознаграждение (1741) </td>"
  "<td valign=""center"" colspan=2> Штрафы, пени (1879) </td>"
  "<td valign=""center"" colspan=2> Провизии(1428) </td>"
  "<td valign=""center""> Отношение просрочки к кредитному портфелю </td>"
  "<td valign=""center""> Отношение провизий к кредитному портфелю </td> </tr>"

  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
  "<td valign=""center""> </td>"
  "<td valign=""center""> сумма </td>"
  "<td valign=""center""> Доля </td>"
  "<td valign=""center""> сумма </td>"
  "<td valign=""center""> Доля </td>"
  "<td valign=""center""> сумма </td>"
  "<td valign=""center""> Доля </td>"
  "<td valign=""center""> сумма </td>"
  "<td valign=""center""> Доля </td>"
  "<td valign=""center""> сумма </td>"
  "<td valign=""center""> Доля </td>"
  "<td valign=""center""> сумма </td>"
  "<td valign=""center""> Доля </td>"
  "<td valign=""center""> </td>"
  "<td valign=""center""> </td> </tr>".

  vnsum1 = 0. vnsum2 = 0. vnsum3 = 0.
  vnsum4 = 0. vnsum5 = 0. vnsum6 = 0.
  for each lnpr  where id = 1 no-lock:
    vnsum1 = vnsum1 + lnpr.nsum1.
    vnsum2 = vnsum2 + lnpr.nsum2.
    vnsum3 = vnsum3 + lnpr.nsum3.
    vnsum4 = vnsum4 + lnpr.nsum4.
    vnsum5 = vnsum5 + lnpr.nsum5.
    vnsum6 = vnsum6 + lnpr.nsum6.
  end.
  if vnsum1 = 0 Then vnsum1 = 1.
  if vnsum2 = 0 Then vnsum2 = 1.
  if vnsum3 = 0 Then vnsum3 = 1.
  if vnsum4 = 0 Then vnsum4 = 1.
  if vnsum5 = 0 Then vnsum5 = 1.
  if vnsum6 = 0 Then vnsum6 = 1.

  for each lnpr where id >= 1 and id <= 5 no-lock:
    put stream repdvk unformatted "<tr>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.kname "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum1,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum1 / vnsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum2,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum2 / vnsum2) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum3,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum3 / vnsum3) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum4,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum4 / vnsum4) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum5,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum5 / vnsum5) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum6,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum6 / vnsum6) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum2 / lnpr.nsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum6 / lnpr.nsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
  end.

  vnsum1 = 0. vnsum2 = 0. vnsum3 = 0.
  vnsum4 = 0. vnsum5 = 0. vnsum6 = 0.
  for each lnpr  where id = 6 no-lock:
    vnsum1 = vnsum1 + lnpr.nsum1.
    vnsum2 = vnsum2 + lnpr.nsum2.
    vnsum3 = vnsum3 + lnpr.nsum3.
    vnsum4 = vnsum4 + lnpr.nsum4.
    vnsum5 = vnsum5 + lnpr.nsum5.
    vnsum6 = vnsum6 + lnpr.nsum6.
  end.
  if vnsum1 = 0 Then vnsum1 = 1.
  if vnsum2 = 0 Then vnsum2 = 1.
  if vnsum3 = 0 Then vnsum3 = 1.
  if vnsum4 = 0 Then vnsum4 = 1.
  if vnsum5 = 0 Then vnsum5 = 1.
  if vnsum6 = 0 Then vnsum6 = 1.

  for each lnpr where id >= 6 and id <= 10 no-lock:
    put stream repdvk unformatted "<tr>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.kname "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum1,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum1 / vnsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum2,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum2 / vnsum2) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum3,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum3 / vnsum3) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum4,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum4 / vnsum4) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum5,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum5 / vnsum5) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum6,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum6 / vnsum6) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum2 / lnpr.nsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum6 / lnpr.nsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
  end.

  vnsum1 = 0. vnsum2 = 0. vnsum3 = 0.
  vnsum4 = 0. vnsum5 = 0. vnsum6 = 0.
  for each lnpr  where id = 11 no-lock:
    vnsum1 = vnsum1 + lnpr.nsum1.
    vnsum2 = vnsum2 + lnpr.nsum2.
    vnsum3 = vnsum3 + lnpr.nsum3.
    vnsum4 = vnsum4 + lnpr.nsum4.
    vnsum5 = vnsum5 + lnpr.nsum5.
    vnsum6 = vnsum6 + lnpr.nsum6.
  end.
  if vnsum1 = 0 Then vnsum1 = 1.
  if vnsum2 = 0 Then vnsum2 = 1.
  if vnsum3 = 0 Then vnsum3 = 1.
  if vnsum4 = 0 Then vnsum4 = 1.
  if vnsum5 = 0 Then vnsum5 = 1.
  if vnsum6 = 0 Then vnsum6 = 1.

  for each lnpr where id >= 11 and id <= 15 no-lock:
    put stream repdvk unformatted "<tr>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.kname "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum1,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum1 / vnsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum2,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum2 / vnsum2) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum3,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum3 / vnsum3) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum4,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum4 / vnsum4) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum5,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum5 / vnsum5) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.nsum6,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum6 / vnsum6) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum2 / lnpr.nsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string((lnpr.nsum6 / lnpr.nsum1) * 100,'>>>>>>>>>>>>>9.99')),'.',',') + "%" "</td>" skip.
  end.

  put stream repdvk unformatted "</table></body></html>".
  output stream repdvk close.
  unix silent cptwin repdvk.htm excel.

hide message no-pause.































































