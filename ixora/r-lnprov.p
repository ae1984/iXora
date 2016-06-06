/* r-lnprov.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет по динамике изменения провизий
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
        28/03/2005 madiyar
 * CHANGES
        04/04/2005 madiyar - добавил ссудный счет
        10/03/2006 madiyar - для нормального формирования отчета на старые даты - изменил расчет дат
        02/05/2006 madiyar - стандартизовал вывод отчета (на случай появления новых филиалов)
*/

{mainhead.i}

def new shared temp-table wrk_ur
    field bank    as   char
    field city    as   char
    field klname  as   char
    field cif     like lon.cif
    field lon     like lon.lon
    field crc     like lon.crc
    field ost     as   deci extent 2
    field ost_kzt as   deci extent 2
    field pr      as   deci extent 2
    field prov    as   deci extent 2
    index idx is primary bank crc cif.

def new shared temp-table wrk_fiz
    field bank     as   char
    field city     as   char
    field ost_kzt  as   deci extent 2
    field prov     as   deci extent 2
    field prov_inc as   deci
    field prov_dec as   deci
    index idx is primary bank.

def var dt1 as date.
def var dt2 as date.
def var dat as date.
define stream rep.
def var usrnm as char.
def var itog-prov as deci extent 4.
def var v-prov as deci.
def new shared var rates1 as deci extent 20.
def new shared var rates2 as deci extent 20.

dt2 = date(month(g-today),1,year(g-today)).
update dt2 label ' Отчет на дату ' format '99/99/9999' skip with side-label row 5 centered frame dat.
dat = date(month(dt2),1,year(dt2)).
dt1 = date(month(dat - 1),1,year(dat - 1)).

hide frame dat.

for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.regdt < dt1 no-lock no-error.
  rates1[crc.crc] = crchis.rate[1].
  find last crchis where crchis.crc = crc.crc and crchis.regdt < dt2 no-lock no-error.
  rates2[crc.crc] = crchis.rate[1].
end.

{r-brfilial.i &proc = "r-lnprov2 (input dt1, input dt2)"}.

output stream rep to r-lnprov.htm.

put stream rep unformatted "<html><head><title>TEXAKABANK</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
  "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
  "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
  "<h3>ДИНАМИКА ИЗМЕНЕНИЙ ПО ФОРМИРОВАНИЮ СПЕЦИАЛЬНЫХ ПРОВИЗИЙ НА " dt2 format "99/99/9999" "</h3><BR><BR>" skip
  "<h4>ЮРИДИЧЕСКИЕ ЛИЦА</h4><BR>" skip.

put stream rep unformatted
       "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
       "<tr style=""font:bold"" valign=""top"">" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Код кл</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Наименование заемщика</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Сс счет</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Валюта</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" colspan=3>Данные на " dt1 format "99/99/9999" "</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" colspan=3>Данные на " dt2 format "99/99/9999" "</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" colspan=3>Динамика изменений показателей</td>" skip
       "</tr>" skip
       "<tr style=""font:bold"" valign=""top"">" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток долга<br>в тенге</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">% ставка<br>по провизиям</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<br>провизий</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток долга<br>в тенге</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">% ставка<br>по провизиям</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<br>провизий</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток долга<br>в тенге</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">% ставка<br>по провизиям</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<br>провизий</td>" skip
       "</tr>" skip.

itog-prov = 0.
for each wrk_ur no-lock break by wrk_ur.bank by wrk_ur.crc by wrk_ur.cif:
  
  find first crc where crc.crc = wrk_ur.crc no-lock no-error.
  put stream rep unformatted
           "<tr>" skip
           "<td>" wrk_ur.cif "</td>" skip
           "<td>" wrk_ur.klname "</td>" skip
           "<td>&nbsp;" wrk_ur.lon "</td>" skip
           "<td>" crc.code "</td>" skip
           "<td>" replace(trim(string(wrk_ur.ost_kzt[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_ur.pr[1],'>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_ur.prov[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_ur.ost_kzt[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_ur.pr[2],'>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_ur.prov[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_ur.ost_kzt[2] - wrk_ur.ost_kzt[1],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_ur.pr[2] - wrk_ur.pr[1],'->>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_ur.prov[2] - wrk_ur.prov[1],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "</tr>" skip.
  
  itog-prov[1] = itog-prov[1] + wrk_ur.prov[1].
  itog-prov[2] = itog-prov[2] + wrk_ur.prov[2].
  if wrk_ur.prov[2] - wrk_ur.prov[1] < 0 then itog-prov[3] = itog-prov[3] + wrk_ur.prov[2] - wrk_ur.prov[1].
  else itog-prov[4] = itog-prov[4] + wrk_ur.prov[2] - wrk_ur.prov[1].
  
end. /* for each crover_vyd */

put stream rep unformatted "</table>" skip.
put stream rep unformatted
       "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
       "<tr style=""font:bold"">" skip
       "<td></td>" skip
       "<td align=""right"">Итого по ЮЛ в KZT:</td>" skip
       "<td></td><td></td><td></td>" skip
       "<td>" replace(trim(string(itog-prov[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "<td></td><td></td>" skip
       "<td>" replace(trim(string(itog-prov[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "<td></td><td></td>" skip
       "<td>" replace(trim(string(itog-prov[2] - itog-prov[1],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "</tr>" skip
       "<tr style=""font:bold"">" skip
       "<td colspan=11 align=""right"">Сумма восстановленной провизии</td>" skip
       "<td>" replace(trim(string(itog-prov[3],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "</tr>" skip
       "<tr style=""font:bold"">" skip
       "<td colspan=11 align=""right"">Сумма увеличения провизии</td>" skip
       "<td>" replace(trim(string(itog-prov[4],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "</tr>" skip
       "</table><BR><BR>" skip.

v-prov = itog-prov[2].

put stream rep unformatted
       "<h4>ФИЗИЧЕСКИЕ ЛИЦА</h4><BR>" skip
       "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
       "<tr style=""font:bold"" valign=""top"">" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2 colspan=2>Наименование филиала</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Данные на " dt1 format "99/99/9999" "</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Данные на " dt2 format "99/99/9999" "</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Динамика изменений показателей</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Сумма<BR>увеличения<BR>провизии</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Сумма<BR>восстановленной<BR>провизии</td>" skip
       "</tr>" skip
       "<tr style=""font:bold"" valign=""top"">" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток долга<br>в тенге</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<br>провизий</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток долга<br>в тенге</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<br>провизий</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток долга<br>в тенге</td>" skip
       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<br>провизий</td>" skip
       "</tr>" skip.

itog-prov = 0.
for each wrk_fiz no-lock:
  
  put stream rep unformatted
           "<tr>" skip
           "<td colspan=2>" if caps(wrk_fiz.bank) begins "TXB" then caps(wrk_fiz.city) else "БЫСТРЫЕ ДЕНЬГИ" "</td>" skip
           "<td>" replace(trim(string(wrk_fiz.ost_kzt[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_fiz.prov[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_fiz.ost_kzt[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_fiz.prov[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_fiz.ost_kzt[2] - wrk_fiz.ost_kzt[1],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_fiz.prov[2] - wrk_fiz.prov[1],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_fiz.prov_inc,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk_fiz.prov_dec,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
           "</tr>" skip.
  
  itog-prov[1] = itog-prov[1] + wrk_fiz.prov[1].
  itog-prov[2] = itog-prov[2] + wrk_fiz.prov[2].
  itog-prov[3] = itog-prov[3] + wrk_fiz.prov_inc.
  itog-prov[4] = itog-prov[4] + wrk_fiz.prov_dec.
  
end. /* for each crover_vyd */

v-prov = v-prov + itog-prov[2].

put stream rep unformatted "</table>" skip.
put stream rep unformatted
       "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
       "<tr style=""font:bold"">" skip
       "<td colspan=2 align=""right"">Итого по ФЛ в KZT:</td>" skip
       "<td></td>" skip
       "<td>" replace(trim(string(itog-prov[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "<td></td>" skip
       "<td>" replace(trim(string(itog-prov[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "<td></td>" skip
       "<td>" replace(trim(string(itog-prov[2] - itog-prov[1],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "<td>" replace(trim(string(itog-prov[3],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "<td>" replace(trim(string(itog-prov[4],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "</tr>" skip
       "<tr style=""font:bold""><td>&nbsp;</td></tr>" skip
       "<tr style=""font:bold""><td>&nbsp;</td></tr>" skip
       "<tr style=""font:bold"">" skip
       "<td colspan=5>ВСЕГО ПО БАНКУ НА " dt2 format "99/99/9999" " СОЗДАНО СПЕЦИАЛЬНЫХ ПРОВИЗИЙ В KZT:</td>" skip
       "<td>" replace(trim(string(v-prov,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "</tr>" skip
       "</table><BR><BR>" skip.

output stream rep close.

unix silent cptwin r-lnprov.htm excel.

hide message no-pause.

