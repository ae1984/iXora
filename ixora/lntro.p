/* lntro.p
 * MODULE
        Кредитование
 * DESCRIPTION
        Отчет по проблемным и условно-проблемным кредитам
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
        20/09/2005 madiar
 * BASES
        bank
 * CHANGES
        26/09/2005 madiar - разбивка на проблемные - условно-проблемные, исправил перекос в колонках
        27/09/2005 madiar - исправил формат вывода описания обеспечения
        04/10/2005 madiar - изменил расчет начисл. процентов
        14/10/2005 madiar - учет списанных сумм
        31/10/2005 madiar - консолидированный, вынес заполнение временной таблицы в lntro2.p
*/

{mainhead.i}

define new shared temp-table wrk
  field cif like cif.cif
  field clname as char
  field lon like lon.lon
  field tro as char
  field crc as integer
  field rdt as date
  field duedt as date
  field prem as deci
  field opnamt as deci
  field opnamt_kzt as deci
  field od as deci
  field od_kzt as deci
  field prc_kzt as deci
  field com_kzt as deci
  field prosr_kzt as deci
  field nprolong as integer
  field penalty as deci
  field dolg_kzt as deci
  field sts as deci
  field prov as deci
  field zalog_kzt as deci
  field zalog_des as char
  index idx is primary tro cif lon.

def var dat as date.
dat = g-today.
update dat label ' На дату ' format '99/99/9999'
       validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
       with side-label row 5 centered frame dat.

def var bilance as deci.
def var v-bal as deci.
def var itog as deci extent 9.
def var usrnm as char.
def var coun as integer.

def new shared var rates as deci extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.regdt < dat no-lock no-error.
  rates[crc.crc] = crchis.rate[1].
end.

message " Ждите... ".

{r-brfilial.i &proc = "lntro2 (dat)"}

output to lntro.htm.

put unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Отчет по проблемным кредитам на " dat format "99/99/9999" "</b></center><BR>" skip.

coun = 0.
for each wrk no-lock break by wrk.tro by wrk.cif:
  
  if first-of(wrk.tro) then do:
    itog = 0.
    put unformatted
    "<b>" if wrk.tro = '01' then "Проблемные кредиты" else "Условно-проблемные кредиты" "</b><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip
    "<td>пп</td>" skip
    "<td>Код<BR>заемщика</td>" skip
    "<td>Наименование заемщика</td>" skip
    "<td>Валюта<BR>займа</td>" skip
    "<td>Дата<BR>выдачи</td>" skip
    "<td>Дата<BR>погашения</td>" skip
    "<td>% ставка</td>" skip
    "<td>Одобренная<BR>сумма</td>" skip
    "<td>Одобренная<BR>сумма (KZT)</td>" skip
    "<td>Остаток<BR>ОД</td>" skip
    "<td>Остаток<BR>ОД (KZT)</td>" skip
    "<td>Сумма<BR>начисл % (KZT)</td>" skip
    "<td>Сумма неоплач<BR>комиссии (KZT)</td>" skip
    "<td>Общая сумма<BR>просроч задолженности (KZT)</td>" skip
    "<td>Количество<BR>пролонгаций</td>" skip
    "<td>Сумма начисл<BR>пени (KZT)</td>" skip
    "<td>Общая сумма<BR>долга (KZT)</td>" skip
    "<td>Статус %</td>" skip
    "<td>Факт. сформированные<BR>провизии</td>" skip
    "<td>Причина низкой квалификации</td>" skip
    "<td>Сумма<BR>залога (KZT)</td>" skip
    "<td>Описание залогового<BR>имущества</td>" skip
    "</tr>" skip.
  end.
  
  if first-of(wrk.cif) then do:
    coun = coun + 1.
    put unformatted "<tr><td>" coun "</td><td>" wrk.cif "</td><td>" wrk.clname "</td>" skip.
  end.
  else put unformatted "<tr><td></td><td></td><td></td>" skip.
  
  find crc where crc.crc = wrk.crc no-lock no-error.
  put unformatted
    "<td>" crc.code "</td>" skip
    "<td>" wrk.rdt format "99/99/9999" "</td>" skip
    "<td>" wrk.duedt format "99/99/9999" "</td>" skip
    "<td>" replace(trim(string(wrk.prem, ">>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.opnamt, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.opnamt_kzt, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.od, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.od_kzt, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prc_kzt, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.com_kzt, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prosr_kzt, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" nprolong "</td>" skip
    "<td>" replace(trim(string(wrk.penalty, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.dolg_kzt, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sts, ">>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prov, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td></td>" skip
    "<td>" replace(trim(string(wrk.zalog_kzt, ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" wrk.zalog_des "</td>" skip
    "</tr>" skip.
    
  itog[1] = itog[1] + wrk.opnamt_kzt.
  itog[2] = itog[2] + wrk.od_kzt.
  itog[3] = itog[3] + wrk.prc_kzt.
  itog[4] = itog[4] + wrk.com_kzt.
  itog[5] = itog[5] + wrk.prosr_kzt.
  itog[6] = itog[6] + wrk.penalty.
  itog[7] = itog[7] + wrk.dolg_kzt.
  itog[8] = itog[8] + wrk.prov.
  itog[9] = itog[9] + wrk.zalog_kzt.
  
  if last-of(wrk.tro) then do:
    put unformatted
      "<tr style=""font:bold"">" skip
      "<td colspan=""3"" align=""right"">Итого в KZT:</td>" skip
      "<td></td> <td></td> <td></td> <td></td> <td></td>" skip
      "<td>" replace(trim(string(itog[1], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(trim(string(itog[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(itog[3], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(itog[4], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(itog[5], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(trim(string(itog[6], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(itog[7], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(trim(string(itog[8], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(trim(string(itog[9], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "</tr>" skip.
    put unformatted
      "<tr style=""font:bold"">" skip
      "<td colspan=""3"" align=""right"">Итого в KZT:</td>" skip
      "<td></td> <td></td> <td></td> <td></td> <td></td>" skip
      "<td>" replace(trim(string(itog[1] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(trim(string(itog[2] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(itog[3] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(itog[4] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(itog[5] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(trim(string(itog[6] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(itog[7] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(trim(string(itog[8] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "<td>" replace(trim(string(itog[9] / rates[2], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td></td>" skip
      "</tr>" skip.
    put unformatted "</table><br>" skip.
  end.
  
end. /* for each wrk */


put unformatted "</body></html>" skip.
hide message no-pause.
output close.
unix silent cptwin lntro.htm excel.
