/* nppast.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Отчет - "Начисленное и не полученное вознаграждение"
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
        15/07/2004 madiyar
 * CHANGES
        16/07/2004 madiyar - добавил возможность формирования отчета НА заданную дату
                             при формировании на сегодня - не учитываются сегодняшние проводки
        02/08/2004 madiyar - добавил две колонки - "всего в валюте кредита" и "всего в тыс.тенге"
        04/08/2004 madiyar - исправил ошибку
        06/08/2004 madiyar - изменения - для того чтобы отчет сошелся с балансом
        07/09/2004 madiyar - Отчет - за дату. Исправил заголовок отчета и обработку ввода даты
        05/11/2004 madiyar - Разбивка физ/юр делается не по статусу, а по группе кредита
        07/01/2005 madiyar - Добавил второй отчет
        01/02/2005 madiyar - Добавил колонку во втором отчете - суммарная одобренная сумма по клиенту, последняя колонка теперь в тенге, а не в тыс. тенге
        01/02/2005 madiyar - исправил формат
        28/02/2005 madiyar - вынес расчетную часть в nppast2.p
        16/03/2005 madiyar - добавил курсы валют, консолидировал физ.лиц, итоговые данные
        03/06/2005 madiyar - в итоговых данных были неточности, исправил
        27/07/2005 madiyar - % текущего года выводятся в поквартальной разбивке
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        07/03/2007 madiyar - запрос базового года
*/

{mainhead.i}

def new shared var base_year as integer init 2005.
def new shared var rates as deci extent 2.
def new shared var num_col as integer.
def new shared var dates as date extent 10.

def var nach_by_year as decimal extent 10.

def var pogasheno as decimal.
def var prc as decimal.
def var i as integer.
def var dn1 as integer.
def var dn2 as decimal.
def var cur_prc as decimal.
def var sum_prc_all as deci.
def stream rep.

def var dat as date.
def var todate as date.

/* группы кредитов юридических лиц */
def var lst_ur as char init ''.
for each longrp no-lock:
  if substr(string(longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(longrp.longrp).
  end.
end.

def var v-head as char.

def new shared temp-table wrk
  field bank as char
  field urfiz as char
  field cif like cif.cif
  field name as char
  field lon like lon.lon
  field opnamt as deci
  field crc as char
  field prc as deci extent 10
  field sum_prc as deci
  field sum_prc_kzt as deci
  field cur_prc as deci
  field cur_prc_kzt as deci
  index mind bank urfiz crc cif.

dat = g-today - 1.
update dat label " За дату " format "99/99/9999" validate (dat < g-today, " Дата должна быть раньше текущей!") " " skip
       " С " base_year no-label format ">>>9" validate(base_year > 0,"Некорректное значение") " года " skip
       with side-label row 5 centered frame dat.
base_year = base_year - 1.

find last crchis where crchis.crc = 2 and crchis.regdt <= dat no-lock no-error.
if avail crchis then rates[1] = crchis.rate[1].
find last crchis where crchis.crc = 11 and crchis.regdt <= dat no-lock no-error.
if avail crchis then rates[2] = crchis.rate[1].

num_col = year(dat) - base_year.

if month(dat) >= 10 then num_col = num_col + 3.
else
if month(dat) >= 7 then num_col = num_col + 2.
else
if month(dat) >= 4 then num_col = num_col + 1.

do i = 1 to num_col:
  if base_year + i < year(dat) then dates[i] = date(1,1,base_year + i + 1).
  else do:
    if base_year + i = year(dat) then dates[i] = date(4,1,year(dat)).
    if base_year + i = year(dat) + 1 then dates[i] = date(7,1,year(dat)).
    if base_year + i = year(dat) + 2 then dates[i] = date(10,1,year(dat)).
    if base_year + i = year(dat) + 3 then dates[i] = date(1,1,year(dat) + 1).
  end.
end.

{r-brfilial.i &proc = "nppast2 (dat)"}


output stream rep to rpt.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

put stream rep unformatted "<center><b>СВЕДЕНИЯ О НАЧИСЛЕННОМ К ПОЛУЧЕНИЮ ВОЗНАГРАЖДЕНИИ НА " dat + 1 "</b></center><BR>" skip.

put stream rep unformatted
    "<table border=0 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold"">" skip
    "<td colspan=8></td>" skip
    "<td align=""right"">USD/KZT</td>" skip
    "<td align=""left"">" replace(trim(string(rates[1],">>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip
    "<tr style=""font:bold"">" skip
    "<td colspan=8></td>" skip
    "<td align=""right"">EUR/KZT</td>" skip
    "<td align=""left"">" replace(trim(string(rates[2],">>>>>9.99")),'.',',') "</td>" skip
    "</tr></table>" skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td rowspan=2>Код клиента</td>" skip
    "<td rowspan=2>Наименование клиента</td>" skip
    "<td rowspan=2>Ссудный счет</td>" skip
    "<td rowspan=2>Одобренная сумма</td>" skip
    "<td rowspan=2>Валюта</td>" skip
    "<td colspan=" num_col ">Начисленные и не погашенные проценты</td>" skip
    "<td rowspan=2>Всего в<BR>валюте кредита</td>" skip
    "<td rowspan=2>Всего<BR>в тенге</td>" skip
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip.

do i = 1 to num_col:
  if month(dates[i]) = 1 and dates[i] < dat then v-head = string(base_year + i,"9999").
  else
  if month(dates[i]) <> 1 then v-head = string(integer(month(dates[i]) / 3),"9") + " кв. " + string(year(dat),"9999").
  else
  v-head = "4 кв. " + string(year(dat),"9999").
  put stream rep unformatted "<td>" v-head "</td>" skip.
end.

put stream rep unformatted "</tr>" skip.

sum_prc_all = 0.
for each wrk no-lock break by wrk.bank by wrk.urfiz by wrk.crc by wrk.cif:

  if first-of(wrk.urfiz) then do:
    put stream rep unformatted
        "<tr><td bgcolor=""#9BCDFF"" colspan=" 7 + num_col "><b>" if wrk.urfiz = "0" then "Юридические лица" else "Физические лица" "</b></td></tr>" skip.
  end.
  
  put stream rep unformatted
          "<tr>" skip
          "<td>" wrk.cif "</td>" skip
          "<td>" wrk.name "</td>" skip
          "<td>&nbsp;" wrk.lon "</td>" skip
          "<td align=""right"">" replace(string(wrk.opnamt, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
          "<td>" wrk.crc "</td>" skip.
  
  do i = 1 to num_col:
    if i < num_col then put stream rep unformatted "<td align=""right"">" replace(trim(string(wrk.prc[i], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
    else put stream rep unformatted "<td align=""right"">" replace(trim(string(wrk.cur_prc - (wrk.sum_prc - wrk.prc[i]), ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
  end.
  
  put stream rep unformatted "<td align=""right"">" replace(trim(string(wrk.cur_prc, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                             "<td align=""right"">" replace(trim(string(wrk.cur_prc_kzt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
  
  put stream rep unformatted "</tr>" skip.
  sum_prc_all = sum_prc_all + wrk.cur_prc_kzt.
  
end. /* for each wrk */

put stream rep unformatted "<tr><td>ИТОГО</td><td></td><td></td><td></td><td></td>" skip.
do i = 1 to num_col:
  put stream rep unformatted "<td></td>".
end.
put stream rep unformatted "<td></td>" skip
                           "<td align=""right"">" replace(string(sum_prc_all, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
                           "</tr>" skip.

put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin rpt.htm excel.

/* отчет 2 */

def var itog_cif as decimal extent 10.
def var itog_crc as decimal extent 10.
def var cif_opnamt as decimal.
def var itogall_cif as decimal extent 2.
def var itogall_crc as decimal extent 2.
def var itog_opnamt as decimal.
def var coun as integer.
def var counter as integer.

output stream rep to rpt2.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

put stream rep unformatted "<center><b>СВЕДЕНИЯ О НАЧИСЛЕННОМ К ПОЛУЧЕНИЮ ВОЗНАГРАЖДЕНИИ НА " dat + 1 "</b></center><BR>" skip.

put stream rep unformatted
    "<table border=0 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold"">" skip
    "<td colspan=8></td>" skip
    "<td align=""right"">USD/KZT</td>" skip
    "<td align=""left"">" replace(trim(string(rates[1],">>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip
    "<tr style=""font:bold"">" skip
    "<td colspan=8></td>" skip
    "<td align=""right"">EUR/KZT</td>" skip
    "<td align=""left"">" replace(trim(string(rates[2],">>>>>9.99")),'.',',') "</td>" skip
    "</tr></table>" skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td rowspan=2>пп</td>" skip
    "<td rowspan=2>Код клиента</td>" skip
    "<td rowspan=2>Наименование клиента</td>" skip
    "<td rowspan=2>Валюта</td>" skip
    "<td rowspan=2>Одобренная<BR>сумма</td>" skip
    "<td colspan=" num_col ">Начисленные и не погашенные проценты</td>" skip
    "<td rowspan=2>Всего в<BR>валюте кредита</td>" skip
    "<td rowspan=2>Всего<BR>в тенге</td>" skip
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip.

do i = 1 to num_col:
  if month(dates[i]) = 1 and dates[i] < dat then v-head = string(base_year + i,"9999").
  else
  if month(dates[i]) <> 1 then v-head = string(integer(month(dates[i]) / 3),"9") + " кв. " + string(year(dat),"9999").
  else
  v-head = "4 кв. " + string(year(dat),"9999").
  put stream rep unformatted "<td>" v-head "</td>" skip.
end.

put stream rep unformatted "</tr>" skip.

def var sumurfiz as deci.

sum_prc_all = 0.
for each wrk no-lock break by wrk.urfiz by wrk.crc by wrk.cif:

  if first-of(wrk.urfiz) then do:
    put stream rep unformatted
        "<tr><td bgcolor=""#9BCDFF"" colspan=" 7 + num_col "><b>" if wrk.urfiz = "0" then "Юридические лица" else "Физические лица" "</b></td></tr>" skip.
    counter = 0.
    sumurfiz = 0.
  end.
  
  if first-of(wrk.crc) then do: itog_crc = 0. itogall_crc = 0. coun = 0. itog_opnamt = 0. end.
  
  if first-of(wrk.cif) then do: itog_cif = 0. itogall_cif = 0. cif_opnamt = 0. counter = counter + 1. end.
  
  do i = 1 to num_col:
    if i < num_col then itog_cif[i] = itog_cif[i] + wrk.prc[i].
    else itog_cif[i] = itog_cif[i] + (wrk.cur_prc - (wrk.sum_prc - wrk.prc[i])).
  end.
  itogall_cif[1] = itogall_cif[1] + wrk.cur_prc.
  itogall_cif[2] = itogall_cif[2] + wrk.cur_prc_kzt.
  cif_opnamt = cif_opnamt + wrk.opnamt.
  coun = coun + 1.
  
  if last-of(wrk.cif) then do:
    if wrk.urfiz = '0' then do:
      put stream rep unformatted
          "<tr>" skip
          "<td>" counter "</td>" skip
          "<td>" wrk.cif "</td>" skip
          "<td>" wrk.name "</td>" skip
          "<td>" wrk.crc "</td>" skip
          "<td align=""right"">" replace(trim(string(cif_opnamt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
      do i = 1 to num_col:
        put stream rep unformatted "<td align=""right"">" replace(trim(string(itog_cif[i], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
      end.
      put stream rep unformatted "<td align=""right"">" replace(trim(string(itogall_cif[1], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                                 "<td align=""right"">" replace(trim(string(itogall_cif[2], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                                 "</tr>" skip.
    end.
    
    do i = 1 to num_col:
      itog_crc[i] = itog_crc[i] + itog_cif[i].
    end.
    itogall_crc[1] = itogall_crc[1] + itogall_cif[1].
    itogall_crc[2] = itogall_crc[2] + itogall_cif[2].
    itog_opnamt = itog_opnamt + cif_opnamt.
  end.
  
  if last-of(wrk.crc) then do:
    if wrk.urfiz = '0' then do:
      put stream rep unformatted
          "<tr style=""font:bold"">" skip
          "<td colspan=5>Итого</td>" skip.
      do i = 1 to num_col:
        put stream rep unformatted "<td align=""right"">" replace(trim(string(itog_crc[i], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
      end.
      put stream rep unformatted "<td align=""right"">" replace(trim(string(itogall_crc[1], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                                 "<td align=""right"">" replace(trim(string(itogall_crc[2], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                                 "</tr>" skip.
    end.
    if wrk.urfiz = '1' then do:
      put stream rep unformatted
          "<tr>" skip
          "<td>" counter "</td><td></td>" skip
          "<td>ФИЗИЧЕСКИЕ ЛИЦА - " coun " КРЕДИТОВ</td>" skip
          "<td>" wrk.crc "</td>" skip
          "<td>" replace(trim(string(itog_opnamt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
      do i = 1 to num_col:
        put stream rep unformatted "<td align=""right"">" replace(trim(string(itog_crc[i], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
      end.
      put stream rep unformatted "<td align=""right"">" replace(trim(string(itogall_crc[1], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                                 "<td align=""right"">" replace(trim(string(itogall_crc[2], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                                 "</tr>" skip.
    end.
    
    sum_prc_all = sum_prc_all + itogall_crc[2].
    sumurfiz = sumurfiz + itogall_crc[2].
  end.
  
  if last-of(wrk.urfiz) then do:
    put stream rep unformatted
        "<tr>" skip
        "<td bgcolor=""#9BCDFF"" colspan=" 6 + num_col " align=""right""><b>ИТОГО ПО " if wrk.urfiz = '0' then "ЮРИДИЧЕСКИМ" else "ФИЗИЧЕСКИМ" " ЛИЦАМ НА " dat format "99/99/9999" " в KZT:</b></td>" skip
        "<td bgcolor=""#9BCDFF""><b>" replace(trim(string(sumurfiz, ">>>>>>>>>>>>>>9.99")),'.',',') "</b></td>" skip
        "</tr>" skip
        "<tr>" skip
        "<td bgcolor=""#9BCDFF"" colspan=" 6 + num_col " align=""right""><b>ИТОГО ПО " if wrk.urfiz = '0' then "ЮРИДИЧЕСКИМ" else "ФИЗИЧЕСКИМ" " ЛИЦАМ НА " dat format "99/99/9999" " в USD:</b></td>" skip
        "<td bgcolor=""#9BCDFF""><b>" replace(trim(string(sumurfiz / rates[1], ">>>>>>>>>>>>>>9.99")),'.',',') "</b></td>" skip
        "</tr>" skip.
    counter = 0.
  end.
  
  
end. /* for each wrk */

put stream rep unformatted "<tr style=""font:bold""><td colspan=" 6 + num_col " align=""right"">ВСЕГО НАЧИСЛЕНО К ПОЛУЧЕНИЮ НА " dat format "99/99/9999" " В KZT:</td>" skip
                           "<td align=""right"">" replace(trim(string(sum_prc_all, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                           "</tr>" skip
                           "<tr style=""font:bold""><td colspan=" 6 + num_col " align=""right"">ВСЕГО НАЧИСЛЕНО К ПОЛУЧЕНИЮ НА " dat format "99/99/9999" " В USD:</td>" skip
                           "<td align=""right"">" replace(trim(string(sum_prc_all / rates[1], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                           "</tr>" skip.

put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin rpt2.htm excel.


