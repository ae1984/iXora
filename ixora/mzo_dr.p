/* mzo_dr.p
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
  field cif       as   char
  field cname     as   char
  field ndog      as   char
  field dtv       as   date
  field dto       as   date
  field sz_vlt    as   char
  field sz_sum    as   decimal
  field ob_name   as   char
  field ob_adr    as   char
  field ob_zlg    as   char
  field sp_vlt    as   char
  field sp_sum    as   decimal
  field sp_dtm    as   date
  field ost       as   decimal
  field otm       as   char.

def new shared var b-dt as date.
b-dt = g-today.

def var v-pp         as int.
def var usrnm as char no-undo.
def var v-bank as char no-undo.

{r-brfilial.i &proc = "mzo_drf" }


def stream repmzo.
output stream repmzo to repmzo.htm.

  put stream repmzo unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream repmzo unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.


  put stream repmzo unformatted
      "<BR><b>Мониторинг залогового обеспечения</b><BR><br>" skip.

  put stream repmzo unformatted
  "<table border=1 cellpadding=0 cellspacing=0>"
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"

  "<td rowspan=""2"" valign=""center"">П/п </td>"
  "<td rowspan=""2"" valign=""center"">Номер </td>"
  "<td rowspan=""2"" valign=""center"">Наименование заемщика</td>"
  "<td rowspan=""2"" valign=""center"">№ Договора залога </td>"
  "<td rowspan=""2"" valign=""center"">Дата выдачи</td>"
  "<td rowspan=""2"" valign=""center"">Дата окончания</td>"

  "<td colspan=""2""> Стоимость по договору о залоге </td>"
  "<td colspan=""3""> Обеспечение </td>"
  "<td colspan=""3""> Стоимость в результате переоценки </td>"
  "<td rowspan=""2"" valign=""center"">Остаток ссудной задолженности по кредиту</td>"
  "<td rowspan=""2"" valign=""center"">Ответственный  менеджер</td>"

  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
  "<td>Валюта</td>"
  "<td>Сумма</td>"

  "<td>Наименование</td>"
  "<td>Адрес</td>"
  "<td>Залогодатель</td>"

  "<td>Валюта</td>"
  "<td>Сумма</td>"
  "<td>Дата мониторинга</td>" skip.


  v-pp = 1.
  for each lnpr no-lock:
    put stream repmzo unformatted "<tr>" skip.
    put stream repmzo unformatted
    "<td>" v-pp "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.cif "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.cname "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.ndog "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.dtv "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.dto "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.sz_vlt "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.sz_sum "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.ob_name "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.ob_adr "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.ob_zlg "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.sp_vlt "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.sp_sum "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.sp_dtm "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.ost "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.otm "</td>" skip.
  v-pp = v-pp + 1.
  end.

  put stream repmzo unformatted "</table></body></html>".
  output stream repmzo close.
  unix silent cptwin repmzo.htm excel.


hide message no-pause.































































