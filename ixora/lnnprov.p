/* lnnprov.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Отчет по провизиям для налоговой
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
        24/02/2005 madiyar
 * CHANGES
        28/02/2005 madiyar - добавил промежуточные и финальные итоги
        03/03/2005 madiyar - полностью переделал отчет
        05/03/2005 madiyar - добавил выделение цветом при некорректных данных
        11/03/2005 madiyar - остаток долга - в тенге
        14/03/2005 madiyar - добавил "погашено списанного ОД"
        18/03/2005 madiyar - добавил колонку по потерянным кредитам
        05/05/2005 madiyar - запрос дат
        09/03/2006 madiyar - добавил группу кредита
        21/07/2006 madiyar - dt_old (дата для разделения провизий на возникшие в прошлых годах и в году, предш. отчетному) определялась неверно, исправил
        17/10/2006 madiyar - дорисовал if avail для crchis
*/

{mainhead.i}

def new shared temp-table wrk no-undo
  field bank as char
  field cif like cif.cif
  field klname as char
  field urfiz as char
  field lon like lon.lon
  field grp like lon.grp
  field sum as deci extent 15
  field fact_prov as deci
  field comment as char
  index idx is primary bank cif lon.

def var usrnm as char no-undo.
def var v-red as logi no-undo.
def var i as integer no-undo.

def new shared var dt1 as date no-undo.
def new shared var dt2 as date no-undo.
def new shared var dt_old as date no-undo.

dt1 = date(1,1,year(g-today) - 1).
dt2 = date(12,31,year(g-today) - 1).

update dt1 label ' Укажите период с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat.
hide frame dat.

dt_old = date(1,1,year(dt1) - 1). /* дата для разделения провизий на возникшие в прошлых годах и в году, предш. отчетному */

def new shared var rates1 as deci no-undo extent 20.
def new shared var rates2 as deci no-undo extent 20.

for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.regdt < dt1 no-lock no-error.
  if avail crchis then rates1[crc.crc] = crchis.rate[1].
  find last crchis where crchis.crc = crc.crc and crchis.regdt <= dt2 no-lock no-error.
  if avail crchis then rates2[crc.crc] = crchis.rate[1].
end.

{r-brfilial.i &proc = "lnnprov2"}

def stream rep.
output stream rep to lnnprov.htm.

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
    "<center><b>Отчет о формировании и списании провизий в " year(g-today) - 1 " году</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" valign=""top"" align=""center"">" skip
    "<td rowspan=2>Код<BR>заемщика</td>" skip
    "<td rowspan=2>Наименование заемщика</td>" skip
    "<td rowspan=2>Юр/физ</td>" skip
    "<td rowspan=2>Ссудный<BR>счет</td>" skip
    "<td rowspan=2>Группа<BR>кредита</td>" skip
    "<td rowspan=2>Остаток ОД<BR>на начало<BR>отчетного года</td>" skip
    "<td rowspan=2>Норма провизий<BR>на начало<BR>отчетного года</td>" skip
    "<td colspan=2>Провизии на начало отчетного года</td>" skip
    "<td rowspan=2>Создано<BR>провизий за<BR>отчетный год</td>" skip
    "<td colspan=2>Списано провизий<BR>за отчетный год</td>" skip
    "<td colspan=4>Списано провизий за баланс<BR>за отчетный год</td>" skip
    "<td colspan=2>Провизии на конец отчетного года</td>" skip
    "<td rowspan=2>Остаток ОД<BR>на конец<BR>отчетного года</td>" skip
    "<td rowspan=2>Норма провизий<BR>на конец<BR>отчетного года</td>" skip
    "<td rowspan=2>Примечание</td>" skip
    "</tr>" skip
    
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" valign=""top"" align=""center"">" skip
    "<td>созданные<BR>в прошлые<BR>годы</td>" skip
    "<td>созданные в<BR>предшествующем<BR>отчетному году</td>" skip
    "<td>созданные<BR>в прошлые<BR>годы</td>" skip
    "<td>созданные<BR>в отчетном<BR>году</td>" skip
    "<td>созданные<BR>в прошлые<BR>годы</td>" skip
    "<td>созданные<BR>в отчетном<BR>году</td>" skip
    "<td>из них погашено</td>" skip
    "<td>потерянные</td>" skip
    "<td>созданные<BR>в прошлые<BR>годы</td>" skip
    "<td>созданные в<BR>отчетном году</td>" skip
    "</tr>" skip.

/*
for each wrk:
  if wrk.sum_begin[4] < 0 then do:
    wrk.sum_begin[3] = wrk.sum_begin[3] + wrk.sum_begin[4].
    wrk.sum_begin[4] = 0.
  end.
  if wrk.sum_begin[6] < 0 then do:
    wrk.sum_begin[5] = wrk.sum_begin[5] + wrk.sum_begin[6].
    wrk.sum_begin[6] = 0.
  end.
  if wrk.sum_end[4] < 0 then do:
    wrk.sum_end[3] = wrk.sum_end[3] + wrk.sum_end[4].
    wrk.sum_end[4] = 0.
  end.
  if wrk.sum_end[6] < 0 then do:
    wrk.sum_end[5] = wrk.sum_end[5] + wrk.sum_end[6].
    wrk.sum_end[6] = 0.
  end.
end.
*/

def var sum_itog_1 as deci no-undo extent 15.
def var sum_itog_2 as deci no-undo extent 15.
def var sum_itog_3 as deci no-undo extent 15.
def var sum_itog as deci no-undo extent 15.

sum_itog = 0.
for each wrk no-lock break by wrk.bank by wrk.urfiz desc by wrk.sum[15] by wrk.cif:
  
  if first-of(wrk.bank) then sum_itog_3 = 0.
  
  if first-of(wrk.urfiz) then sum_itog_2 = 0.
  
  if first-of(wrk.sum[15]) then sum_itog_1 = 0.
  
  v-red = (wrk.sum[1] < 0) or (wrk.sum[2] = -1) or (wrk.sum[3] < 0) or (wrk.sum[4] < 0) or (wrk.sum[5] < 0) or (wrk.sum[6] < 0) or (wrk.sum[7] < 0) or (wrk.sum[8] < 0)
          or (wrk.sum[9] < 0) or (wrk.sum[10] < 0) or (wrk.sum[11] < 0) or (wrk.sum[12] < 0) or (wrk.sum[13] < 0) or (wrk.sum[14] < 0) or (wrk.sum[15] = -1).
  
  put stream rep unformatted
     "<tr" if v-red then "bgcolor=""#ff9999""" else ">" skip
     
     "<td>" wrk.cif "</td>" skip
     "<td>" wrk.klname "</td>" skip
     "<td>" wrk.urfiz "</td>" skip
     "<td>&nbsp;" wrk.lon "</td>" skip
     "<td>&nbsp;" wrk.grp "</td>" skip
     
     "<td>" if wrk.sum[2] <> -2 then replace(trim(string(wrk.sum[1],"->>>>>>>>>>>9.99")),'.',',') else "" "</td>" skip
     "<td>" if wrk.sum[2] <> -2 then replace(trim(string(wrk.sum[2],"->>9.99")),'.',',') else "" "</td>" skip
     "<td>" if wrk.sum[2] <> -2 then replace(trim(string(wrk.sum[3],"->>>>>>>>>>>9.99")),'.',',') else "" "</td>" skip
     "<td>" if wrk.sum[2] <> -2 then replace(trim(string(wrk.sum[4],"->>>>>>>>>>>9.99")),'.',',') else "" "</td>" skip
     
     "<td>" replace(trim(string(wrk.sum[5],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[6],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[7],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[8],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[9],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[10],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[11],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     
     "<td>" replace(trim(string(wrk.sum[12],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[13],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[14],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     "<td>" replace(trim(string(wrk.sum[15],"->>9.99")),'.',',') "</td>" skip
     
     
     "<td>" wrk.comment "</td>" skip
     "<td>" replace(trim(string(wrk.fact_prov,"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
     
     "</tr>" skip.
  
  do i = 1 to 15:
    sum_itog_1[i] = sum_itog_1[i] + wrk.sum[i].
  end.
    
  if last-of(wrk.sum[15]) then do:
    do i = 1 to 15:
      sum_itog_2[i] = sum_itog_2[i] + sum_itog_1[i].
    end.
    put stream rep unformatted
       "<tr style=""font:bold"">" skip
       "<td></td>" skip
       "<td>Кредиты """ caps(wrk.urfiz) """ c нормой провизий " wrk.sum[15] format ">>9.99" "</td>" skip
       "<td></td>" skip
       "<td></td>" skip
       "<td></td>" skip
       
       "<td>" replace(trim(string(sum_itog_1[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td></td>" skip
       "<td>" replace(trim(string(sum_itog_1[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td>" replace(trim(string(sum_itog_1[5],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[6],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[7],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[8],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[9],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[10],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[11],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td>" replace(trim(string(sum_itog_1[12],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[13],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_1[14],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td></td>" skip
       
       "<td></td>" skip
       
       "</tr>" skip.
  end.
  
  if last-of(wrk.urfiz) then do:
    do i = 1 to 15:
      sum_itog_3[i] = sum_itog_3[i] + sum_itog_2[i].
    end.
    put stream rep unformatted
       "<tr style=""font:bold"">" skip
       "<td></td>" skip
       "<td>Всего по кредитам """ caps(wrk.urfiz) """" "</td>" skip
       "<td></td>" skip
       "<td></td>" skip
       "<td></td>" skip
       
       "<td>" replace(trim(string(sum_itog_2[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td></td>" skip
       "<td>" replace(trim(string(sum_itog_2[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td>" replace(trim(string(sum_itog_2[5],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[6],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[7],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[8],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[9],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[10],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[11],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td>" replace(trim(string(sum_itog_2[12],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[13],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_2[14],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td></td>" skip
       
       "<td></td>" skip
       
       "</tr>" skip.
  end.
  
  if last-of(wrk.bank) then do:
    do i = 1 to 15:
      sum_itog[i] = sum_itog[i] + sum_itog_3[i].
    end.
    put stream rep unformatted
       "<tr style=""font:bold"">" skip
       "<td></td>" skip
       "<td>Всего по " caps(wrk.bank) "</td>" skip
       "<td></td>" skip
       "<td></td>" skip
       "<td></td>" skip
       
       "<td>" replace(trim(string(sum_itog_3[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td></td>" skip
       "<td>" replace(trim(string(sum_itog_3[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td>" replace(trim(string(sum_itog_3[5],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[6],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[7],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[8],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[9],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[10],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[11],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       
       "<td>" replace(trim(string(sum_itog_3[12],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[13],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td>" replace(trim(string(sum_itog_3[14],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td></td>" skip
       
       "<td></td>" skip
       
       "</tr>" skip.
  end.
  
end. /* for each wrk */

put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td></td>" skip
    "<td>ИТОГО</td>" skip
    "<td></td>" skip
    "<td></td>" skip
    "<td></td>" skip
     
    "<td>" replace(trim(string(sum_itog[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td></td>" skip
    "<td>" replace(trim(string(sum_itog[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    
    "<td>" replace(trim(string(sum_itog[5],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[6],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[7],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[8],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[9],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[10],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[11],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    
    "<td>" replace(trim(string(sum_itog[12],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[13],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sum_itog[14],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td></td>" skip
    
    "<td></td>" skip
    
   "</tr>" skip.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin lnnprov.htm excel.

