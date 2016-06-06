/* lncrreg1.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Экспорт данных в Модернизированный Кредитный Регистр
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
        22/07/2013 Sayat(id01143) - ТЗ 1254 от 09/01/2012 "Касательно модернизации АИП «Кредитный Регистр»" (на основе lncrreg)
 * BASES
        BANK COMM
 * CHANGES

*/

{mainhead.i}
{credreg1.i "new" }
def var dat as date.
def var dt1 as date.
def var dt2 as date.
def new shared var mesa as char.
mesa = ''.
def new shared var k as int.
k = 0.

def new shared temp-table lnpr no-undo
  field cif    as   char
  field lon    as   char
  field n1     as   decimal
  field n2     as   decimal
  field n3     as   decimal
  field n4     as   decimal
  field n5     as   decimal.

def new shared var v-bik as char.
find first txb where txb.bank = "txb00" and txb.consolid no-lock no-error.
if avail txb then v-bik = txb.mfo.

dat = date(month(g-today),1,year(g-today)).
dt2 = dat - 1.
dt1 = date(month(dt2),1,year(dt2)).

update skip(1)
       dat label ' Дата отчета ' format '99/99/9999' validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip(1)
       dt1 label ' Период с    ' format '99/99/9999' validate (dt1 < g-today, " Дата должна быть раньше текущей! ")
       dt2 label ' по ' format '99/99/9999' validate (dt2 < g-today, " Дата должна быть раньше текущей! ") " " skip(1)
       with side-label row 5 centered frame dates title 'Модернизированный кредитный регистр'.

def new shared var rates as deci extent 20.
def new shared var crates as char extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt <= dt2 no-lock no-error.
  if avail crchis then assign rates[crc.crc] = crchis.rate[1] crates[crc.crc] = crchis.code.
end.

empty temp-table cr_wrk no-error.

{r-brfilial.i &proc = "lncrreg21.p (dat,dt1,dt2)"}



hide message no-pause.
message mesa  view-as alert-box buttons ok.

/*
def stream repdvk.
output stream repdvk to repdvk.htm.

  put stream repdvk unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.


  put stream repdvk unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td valign=""center"">CIF код</td>" skip
  "<td valign=""center"">Ссудный счет</td>" skip
  "<td valign=""center"">Провизии МСФО</td>" skip
  "<td valign=""center"">Провизии АФН</td>" skip.

  for each lnpr no-lock:
    put stream repdvk unformatted "<tr>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.cif "</td>" skip.
    put stream repdvk unformatted
    "<td>'" lnpr.lon "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n1,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n2,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
  end.

put stream repdvk unformatted "</table></body></html>".
output stream repdvk close.
unix silent cptwin repdvk.htm excel.
*/

/*run cr_send.*/
run cr_send_xml.p (dat,dt1,dt2,'GB').