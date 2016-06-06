/* lnstfpay.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет "График платежей по сотрудникам"
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
        08/11/2013 galina ТЗ1457
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def new shared temp-table wrk
field lon like lon.lon
field bank as char
field clname as char
field dtpay as date
field sumod as deci
field sumproc as deci
field aaa as char
field pros as logi
index idx is primary bank dtpay lon.

def var usrnm as char.
/*def new shared var dt as date.

find last cls where cls.del no-lock no-error.
dt = cls.whn.
update dt label '      За дату' format '99/99/9999' validate (dt <= g-today, " Дата должна быть не позже текущей!") skip
       skip with side-label row 5 centered frame dat title "Отчет по амортизации комиссии".*/

{r-brfilial.i &proc = "lnstfpayf(g-today)"}

def stream rep.
output stream rep to rep.htm.

  put stream rep unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream rep unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.

  put stream rep unformatted
      "<BR><b> График погашения по сотрудникам</b><BR>" skip
      "<b>Отчет за " string(g-today) "</b><br>" skip.

  put stream rep unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td valign=""center"">Филиал</td>" skip
  "<td valign=""center"">ФИО сотрудника</td>" skip
  "<td valign=""center"">Ссудный счет</td>" skip
  "<td valign=""center"">Дата погашения</td>" skip
  "<td valign=""center"">Сумма ОД</td>" skip
  "<td valign=""center"">Сумма %%</td>" skip
  "<td valign=""center"">Итого сумма <br> к погашению</td>" skip
  "<td valign=""center"">№ счета</td>" skip
  "<td valign=""center"">Факт<br>просрочки</td></tr>" skip.

  for each wrk no-lock:
    put stream rep unformatted "<tr>" skip
    "<td>" wrk.bank "</td>" skip
    "<td>" wrk.clname "</td>" skip
    "<td>`" wrk.lon "</td>" skip
    "<td>" string(wrk.dtpay,'99/99/9999') "</td>" skip
    "<td>" replace(trim(string(wrk.sumod,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sumproc,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sumod + wrk.sumproc,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    "<td>`" wrk.aaa "</td>" skip
    "<td>" wrk.pros "</td>" skip.
  end.

put stream rep unformatted "</table></body></html>".
output stream rep close.
unix silent cptwin rep.htm excel.

hide message no-pause.
