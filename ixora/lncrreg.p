/* lncrreg.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Экспорт данных в Кредитный Регистр
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
        15/02/2005 madiyar
 * CHANGES
        16/02/2005 madiyar - небольшие исправления
        18/02/2005 madiyar - разбранчевка
        18/02/2008 madiyar - подкорректировал описания шаренных переменных
        11/03/2009 madiyar - исправил определение курсов валют
        19/03/2011 kapar - ТЗ 1320
        18/09/2012 id00810 - переход на bookcod при определении кода валюты
*/

{mainhead.i}
{credreg.i "new" }
def var dat as date.
def var dt1 as date.
def var dt2 as date.
def new shared var mesa as char.
def new shared var v-spcrc1 as char no-undo.
def new shared var v-spcrc2 as char no-undo.

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
       with side-label row 5 centered frame dates.

def new shared var rates as deci extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt <= dt2 no-lock no-error.
  rates[crc.crc] = crchis.rate[1].
end.

find first bookcod where bookcod.bookcod = 'lncrreg'
                     and bookcod.code    = 'crc'
                     no-lock no-error.
if avail bookcod then v-spcrc1 = bookcod.name.
else do:
    message "В справочнике <lncrreg> отсутствует код <crc> для определения кодов валют!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
find first bookcod where bookcod.bookcod = 'lncrreg'
                     and bookcod.code    = 'crcreg'
                     no-lock no-error.
if avail bookcod then v-spcrc2 = bookcod.name.
else do:
    message "В справочнике <lncrreg> отсутствует код <crcreg> для определения кодов валют КР!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
if num-entries(v-spcrc1) <> num-entries(v-spcrc2) then do:
    message "В справочнике <lncrreg> в кодах <crc> и <crcreg> не совпадает количество элементов!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
empty temp-table cr_wrk no-error.

{r-brfilial.i &proc = "lncrreg2 (dat,dt1,dt2)"}



hide message no-pause.
message mesa  view-as alert-box buttons ok.


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


run cr_send.