/* lnpereo.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Переоценка кредитного портфеля
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
        25/02/2005 madiyar
 * CHANGES
        14/03/2005 madiyar - мелкие добавления
        10/06/2008 madiyar - код валюты 11 -> 3
*/

{mainhead.i}

define new shared temp-table wrk
  field dt as date
  field sum_usd as deci extent 3
  field sum_eur as deci extent 3
  index idx is primary dt.

def buffer b-wrk for wrk.

def var usrnm as char.
def var st_border as char init "style=""border:.5pt; border:solid;""".
def var v-pere as decimal extent 4.
def var v-pere_itog as decimal extent 4.
def var dt1 as date.
def var dt2 as date.

dt2 = date(month(g-today),1,year(g-today)) - 1.
dt1 = date(month(dt2),1,year(dt2)).

update dt1 label ' Укажите период с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .
hide frame dat.

message " Формируется отчет... ".

{r-brfilial.i &proc = "lnpereo2(dt1,dt2)"}

create wrk.
find last cls where cls.whn < dt1 and cls.del no-lock no-error.
wrk.dt = cls.whn.
find last crchis where crchis.crc = 2 and crchis.regdt <= wrk.dt no-lock no-error.
wrk.sum_usd[1] = crchis.rate[1].
find last crchis where crchis.crc = 3 and crchis.regdt <= wrk.dt no-lock no-error.
wrk.sum_eur[1] = crchis.rate[1].

def var v-lastcrc_usd as deci.
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
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Переоценка кредитного портфеля, с " dt1 format "99/99/9999" " по " dt2 format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=0 cellpadding=0 cellspacing=0>" skip.

find last crchis where crchis.crc = 2 and crchis.regdt <= dt2 no-lock no-error.
put stream rep unformatted
    "<tr style=""font:bold"" align=""right"">" skip
    "<td colspan=12></td>" skip
    "<td>USD/KZT</td>" skip
    "<td>" replace(trim(string(crchis.rate[1],">>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.
find last crchis where crchis.crc = 3 and crchis.regdt <= dt2 no-lock no-error.
put stream rep unformatted
    "<tr style=""font:bold"" align=""right"">" skip
    "<td colspan=12></td>" skip
    "<td>EUR/KZT</td>" skip
    "<td>" replace(trim(string(crchis.rate[1],">>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" valign=""top"" align=""center"">" skip
    "<td rowspan=3 " st_border ">Дата</td>" skip
    "<td rowspan=2 colspan=2 " st_border ">Курс валюты</td>" skip
    "<td colspan=5 " st_border ">Кредиты, выданные в USD</td>" skip
    "<td colspan=5 " st_border ">Кредиты, выданные в EUR</td>" skip
    "<td rowspan=3 " st_border ">Cумма<BR>переоценки<BR>всего<BR>портфеля</td>" skip
    "</tr>" skip
    
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" valign=""top"" align=""center"">" skip
    "<td colspan=2 " st_border ">Юридические лица</td>" skip
    "<td colspan=2 " st_border ">Физические лица</td>" skip
    "<td rowspan=2 " st_border ">Итого по<BR>портфелю USD</td>" skip
    "<td colspan=2 " st_border ">Юридические лица</td>" skip
    "<td colspan=2 " st_border ">Физические лица</td>" skip
    "<td rowspan=2 " st_border ">Итого по<BR>портфелю EUR</td>" skip
    "</tr>" skip
    
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" valign=""top"" align=""center"">" skip
    "<td " st_border ">USD</td>" skip
    "<td " st_border ">EUR</td>" skip
    "<td " st_border ">Сумма портфеля</td>" skip
    "<td " st_border ">Сумма переоценки</td>" skip
    "<td " st_border ">Сумма портфеля</td>" skip
    "<td " st_border ">Сумма переоценки</td>" skip
    "<td " st_border ">Сумма портфеля</td>" skip
    "<td " st_border ">Сумма переоценки</td>" skip
    "<td " st_border ">Сумма портфеля</td>" skip
    "<td " st_border ">Сумма переоценки</td>" skip
    "</tr>" skip.


v-pere_itog = 0.
for each wrk no-lock:
  
  if wrk.dt < dt1 then do:
    put stream rep unformatted
       "<tr>" skip
       "<td>" wrk.dt format "99/99/9999" "</td>" skip
       
       "<td>" replace(trim(string(wrk.sum_usd[1],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(wrk.sum_eur[1],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td></td> <td></td> <td></td> <td></td> <td></td>" skip
       "<td></td> <td></td> <td></td> <td></td> <td></td>" skip
       "<td></td>" skip
       
       "</tr>" skip.
  end.
  else do:
    find last b-wrk where b-wrk.dt < wrk.dt no-lock no-error.
    
    v-pere[1] = wrk.sum_usd[2] * (wrk.sum_usd[1] - b-wrk.sum_usd[1]).
    v-pere[2] = wrk.sum_usd[3] * (wrk.sum_usd[1] - b-wrk.sum_usd[1]).
    v-pere[3] = wrk.sum_eur[2] * (wrk.sum_eur[1] - b-wrk.sum_eur[1]).
    v-pere[4] = wrk.sum_eur[3] * (wrk.sum_eur[1] - b-wrk.sum_eur[1]).
    
    put stream rep unformatted
       "<tr>" skip
       "<td " st_border ">" wrk.dt format "99/99/9999" "</td>" skip
       
       "<td " st_border ">" replace(trim(string(wrk.sum_usd[1],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.sum_eur[1],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td " st_border ">" replace(trim(string(wrk.sum_usd[2],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(v-pere[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.sum_usd[3],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(v-pere[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(v-pere[1] + v-pere[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td " st_border ">" replace(trim(string(wrk.sum_eur[2],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(v-pere[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.sum_eur[3],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(v-pere[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(v-pere[3] + v-pere[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td " st_border ">" replace(trim(string(v-pere[1] + v-pere[2] + v-pere[3] + v-pere[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "</tr>" skip.
    v-pere_itog[1] = v-pere_itog[1] + v-pere[1].
    v-pere_itog[2] = v-pere_itog[2] + v-pere[2].
    v-pere_itog[3] = v-pere_itog[3] + v-pere[3].
    v-pere_itog[4] = v-pere_itog[4] + v-pere[4].
    if wrk.dt = dt2 then v-lastcrc_usd = wrk.sum_usd[1].
  end.
  
end. /* for each wrk */

put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td></td> <td></td> <td></td> <td></td>" skip
    "<td>" replace(trim(string(v-pere_itog[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td></td>" skip
    "<td>" replace(trim(string(v-pere_itog[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(v-pere_itog[1] + v-pere_itog[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    
    "<td></td>" skip
    "<td>" replace(trim(string(v-pere_itog[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td></td>" skip
    "<td>" replace(trim(string(v-pere_itog[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(v-pere_itog[3] + v-pere_itog[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    
    "<td>" replace(trim(string(v-pere_itog[1] + v-pere_itog[2] + v-pere_itog[3] + v-pere_itog[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    
    "</tr>" skip
    "<tr style=""font:bold"">" skip
    "<td></td> <td></td> <td></td> <td></td> <td></td>" skip
    "<td></td> <td></td> <td></td> <td></td> <td></td>" skip
    "<td colspan=3 align=""right"">Итого в USD</td>" skip
    "<td>" replace(trim(string((v-pere_itog[1] + v-pere_itog[2] + v-pere_itog[3] + v-pere_itog[4]) / v-lastcrc_usd,"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted "</table></body></html>" skip.

hide message no-pause.

output stream rep close.
unix silent cptwin rep.htm excel.
