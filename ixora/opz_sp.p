/* opz_sp.p
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
  field lon       as   char
  field cname     as   char
  field fcode     as   char
  field fname     as   char
  field ndog      as   char
  field crc       as   int
  field dtdate    as   date
  field ost       as   decimal
  field sts       as   char.

def new shared var b-dt as date.
def new shared var e-dt as date.
/*def new shared var v-dt as date.*/

def var usrnm as char no-undo.
def var v-bank as char no-undo.

do transaction:
     update b-dt label 'ЗАДАЙТЕ ПЕРИОД С'
             validate(b-dt <= today,   "Дата не может быть больше текущей даты..... ")
             help "Введите начальную дату."
            e-dt label 'ПО'
             validate(e-dt <= today,   "Дата не может быть больше текущей даты..... ")
             help "Введите конечную дату." skip skip
/*            v-dt label 'НА ДАТУ'
             validate (v-dt <= g-today, "Дата не может быть больше текущей даты..... ")
             help "Введите дату."  skip*/
            with row 5 centered  side-label frame opt.
  if e-dt < b-dt then
   do:
     message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
     undo,retry.
   end.
end.


{r-brfilial.i &proc = "opz_spf" }


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
  "<BR><b>Погашенные займы </b><BR><br>" skip.

  put stream repmzo unformatted
  "<table border=1 cellpadding=0 cellspacing=0>"
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"

  "<td rowspan=""2"" valign=""center"">N бал. счета </td>"
  "<td rowspan=""2"" valign=""center"">Наименование заемщика</td>"
  "<td rowspan=""2"" valign=""center"">Код</td>"
  "<td rowspan=""2"" valign=""center"">Филиал</td>"
  "<td rowspan=""2"" valign=""center"">N договора</td>"
  "<td rowspan=""2"" valign=""center"">Валюта</td>"
  "<td rowspan=""2"" valign=""center"">Дата погашения</td>"
  "<td rowspan=""2"" valign=""center"">Остаток ОД на дату погашения</td>"
  "<td rowspan=""2"" valign=""center"">Статус Погашен по Договору / погашен досрочно </td>" skip.
  put stream repmzo unformatted "<tr>" skip.


for each lnpr no-lock:
    put stream repmzo unformatted "<tr>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.lon "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.cname "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.fcode "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.fname "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.ndog "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.crc "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.dtdate "</td>" skip.
    put stream repmzo unformatted
    "<td>" replace(trim(string(lnpr.ost,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repmzo unformatted
    "<td>" lnpr.sts "</td>" skip.
end.

  put stream repmzo unformatted "</table></body></html>".
  output stream repmzo close.
  unix silent cptwin repmzo.htm excel.


hide message no-pause.





























































