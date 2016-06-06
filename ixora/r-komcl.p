/* r-komcl.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Список ссудных счетов с начисленными комиссиями
 * RUN
        без параметров
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2 
 * AUTHOR
        02.03.2004 marinav
 * CHANGES
        03/09/2004 madiyar - свободный остаток кредитной линии и комиссия берутся из histrxbal, отчет теперь формируется на задаваемую дату
        07/09/2004 madiyar - Добавил дату в заголовок отчета, изменил название одной колонки
        04/11/2004 madiyar - Теперь это отчет по всем комиссиям, не только за неиспользованную кред линию
        09/11/2004 madiyar - В Астане кредитная линия без выдачи, но с комиссией не попадала в отчет
        17/03/2005 madiyar - Добавил курсы валют, колонку "итого", итоговые данные
        03/05/2005 madiyar - lonbal -> lonbalcrc
        15/08/2008 madiyar - euro 11 -> 3
*/



{global.i}
{lonlev.i}

define var v-bal as deci extent 4.
define var v-sum as deci.
define var sumcl as deci.
define var v-crc as char.
define var coun as integer.

find first cmp no-lock no-error.
def var dat as date.
def var itog as deci extent 5.

def temp-table wrk
field cif     like cif.cif
field kl_name as   char
field lon     like lon.lon
field opnamt  as   deci
field crc     like crc.crc
field predcr  as deci
field vedacc  as deci
field prodcr  as deci
field sumclin as deci
field credlin as deci
index ind1 is primary cif.

dat = g-today.
update dat label ' Отчет на дату ' format '99/99/9999'
       validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
       with side-label row 5 centered frame dat.

message " Ждите... ".

for each lon no-lock:
   /*find first lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock no-error.
   if not avail lonhar or lonhar.rez-dec[2] = 0 then next.*/
   /*if lon.gua <> 'CL' then next.*/
   
   if lon.opnamt = 0 then next.
   
   run lonbalcrc('lon',lon.lon,dat,'27',no,1,output v-bal[1]).
   run lonbalcrc('lon',lon.lon,dat,'28',no,lon.crc,output v-bal[2]).
   run lonbalcrc('lon',lon.lon,dat,'29',no,lon.crc,output v-bal[3]).
   run lonbalcrc('lon',lon.lon,dat,'25',no,lon.crc,output v-bal[4]).

   if v-bal[1] + v-bal[2] + v-bal[3] + v-bal[4] > 0 then do:
      
      sumcl = 0.
      if lon.gua = "CL" then do:
         run lonbalcrc('lon',lon.lon,dat,'15',no,lon.crc,output sumcl).
         sumcl = - sumcl.
      end.
      find first cif where cif.cif = lon.cif no-lock no-error.
      create wrk.
      wrk.cif = lon.cif.
      if avail cif then wrk.kl_name = trim(cif.prefix) + " " + trim(cif.name).
      else wrk.kl_name = "--не найден--".
      wrk.lon = lon.lon.
      wrk.opnamt = lon.opnamt.
      wrk.crc = lon.crc.
      wrk.predcr = v-bal[1].
      wrk.vedacc = v-bal[2].
      wrk.prodcr = v-bal[3].
      wrk.sumclin = sumcl.
      wrk.credlin = v-bal[4].
      
   end.

end. /* for each lon */

def var v-crcusd as deci.
def var v-crceur as deci.

find last crchis where crchis.crc = 2 and crchis.regdt < dat no-lock no-error.
v-crcusd = crchis.rate[1].
find last crchis where crchis.crc = 3 and crchis.regdt < dat no-lock no-error.
v-crceur = crchis.rate[1].

define stream m-out.
output stream m-out to r-komcl.htm.

put stream m-out unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
                  
put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)' skip
                 "</h3></td></tr><br><br>" skip.

put stream m-out unformatted "<tr align=""center""><td><h3> Расшифровка счета 1818 (начисленные комиссии) <br> на " dat format "99/99/9999" "</h3></td></tr><br><br>" skip.
put stream m-out unformatted "<br><br><tr></tr>" skip.

put stream m-out unformatted
      "<tr><td>" skip
      "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
      "<tr style=""font:bold"">" skip
      "<td colspan=13></td>" skip
      "<td>USD/KZT</td><td>" replace(trim(string(v-crcusd,">>>9.99")),'.',',') "</td></tr>" skip
      "<tr style=""font:bold"">" skip
      "<td colspan=13></td>" skip
      "<td>EUR/KZT</td><td>" replace(trim(string(v-crceur,">>>9.99")),'.',',') "</td></tr>" skip
      "</table>" skip
      "</td></tr>" skip.
 
       put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>Код кл</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>Номер счета</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>Одобренная сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=8>Комиссии</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>Итого</td>"
                  "</tr>" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">За предоставление кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>За ведение ссудного счета</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>За продление ссуды</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=3>За неисп кред линию</td>"
                  "</tr>" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта кр</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта кр</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Своб остаток КЛ</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта кр</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">KZT</td>"
                  "</tr>" skip.

coun = 1. itog = 0.
for each wrk no-lock break by wrk.cif:
  
  find last crchis where crchis.crc = wrk.crc and crchis.regdt < dat no-lock no-error.
  put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""center"">" coun "</td>" skip
               "<td align=""center"">" if first-of(wrk.cif) then wrk.cif else "" "</td>" skip
               "<td align=""left"">" if first-of(wrk.cif) then wrk.kl_name else "" "</td>" skip
               "<td align=""left"">&nbsp;" wrk.lon "</td>" skip
               "<td align=""left"">" crchis.code "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.opnamt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.predcr, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.vedacc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.vedacc * crchis.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.prodcr, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.prodcr * crchis.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.sumclin, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.credlin, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.credlin * crchis.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(wrk.predcr + (wrk.vedacc + wrk.prodcr + wrk.credlin) * crchis.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.
   coun = coun + 1.
   
   itog[1] = itog[1] + wrk.predcr.
   itog[2] = itog[2] + wrk.vedacc * crchis.rate[1].
   itog[3] = itog[3] + wrk.prodcr * crchis.rate[1].
   itog[4] = itog[4] + wrk.credlin * crchis.rate[1].
   itog[5] = itog[5] + wrk.predcr + (wrk.vedacc + wrk.prodcr + wrk.credlin) * crchis.rate[1].
   
end.

put stream m-out unformatted "<tr style=""font:bold"" align=""right"">" skip
               "<td align=""center""></td>" skip
               "<td align=""right"" colspan=5>ИТОГО В KZT:</td>" skip
               "<td align=""right"">" replace(trim(string(itog[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right""></td>" skip
               "<td align=""right"">" replace(trim(string(itog[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right""></td>" skip
               "<td align=""right"">" replace(trim(string(itog[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right""></td>" skip
               "<td align=""right""></td>" skip
               "<td align=""right"">" replace(trim(string(itog[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(itog[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip
               "<tr style=""font:bold"" align=""right"">" skip
               "<td align=""center""></td>" skip
               "<td align=""right"" colspan=5>ИТОГО В USD:</td>" skip
               "<td align=""right"">" replace(trim(string(itog[1] / v-crcusd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right""></td>" skip
               "<td align=""right"">" replace(trim(string(itog[2] / v-crcusd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right""></td>" skip
               "<td align=""right"">" replace(trim(string(itog[3] / v-crcusd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right""></td>" skip
               "<td align=""right""></td>" skip
               "<td align=""right"">" replace(trim(string(itog[4] / v-crcusd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""right"">" replace(trim(string(itog[5] / v-crcusd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>" skip.

put stream m-out unformatted "</table></body></html>" .
output stream m-out close.

hide message no-pause.

unix silent cptwin r-komcl.htm excel.

