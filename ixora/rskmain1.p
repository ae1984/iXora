/* rskmain1.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Риски ссудного портфеля
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
        24/09/2004 madiar
 * CHANGES
        18/10/2004 madiar - чтение значений и весов критериев из справочника
*/

{global.i}

/* отрасль срок_до_пог ср_об/ОД обеспечение кред_история фин_состояние */
def var krit_opt as deci extent 6 init [80,80,40,60,100,80].
def var krit_weight as deci extent 6 init [10,10,10,25,15,30].
def var rsk_port as deci extent 7.
def var i as integer.

find sysc where sysc.sysc = "rskkri" no-lock no-error.
if avail sysc then do:
  do i = 1 to 6:
    krit_opt[i] = decimal(entry(i,sysc.chval)).
    krit_weight[i] = decimal(entry(6 + i,sysc.chval)).
  end.
end.

def stream rep.
def var bilance as deci.
def var coun as integer.
def var mesa as integer.
def var usrnm as char.
def var v-cif as char.
def new shared var coeff as deci extent 6.
def new shared var coeff_a as deci extent 7.
def var v-normrasp as deci.
def var v-relindex as deci.

def var all_od as deci.
def var lonnum as integer.

def temp-table wrk
  field cif like cif.cif
  field klname as char
  field lon like lon.lon
  field crc like crc.crc
  field opnamt like lon.opnamt
  field ostatok like lon.opnamt
  field ostatok_kzt like lon.opnamt
  field coeff as deci extent 6
  index cif is primary cif.

def temp-table wrk1
  field cif like cif.cif
  field sumod like lon.opnamt
  index cif is primary cif.

def stream err.
output stream err to err.txt.
output stream err close.

mesa = 0. v-cif = ''.
for each lon where lon.grp = 10 or lon.grp = 15 or lon.grp = 30 or lon.grp = 35 or lon.grp = 50 or lon.grp = 55 or lon.grp = 70 no-lock break by lon.cif:
  run lonbal('lon', lon.lon, g-today, "1,7,20,21", yes, output bilance).
  if bilance <= 0 then next.
  
  if lon.cif <> v-cif then do: coeff = 0. run rsk_proc2(lon.cif). end.
  
  find cif where cif.cif = lon.cif no-lock no-error.
  create wrk.
  assign wrk.cif = lon.cif.
  if avail cif then wrk.klname = trim(cif.prefix) + ' ' + trim(cif.name).
  else wrk.klname = "--не найдено--".
  assign wrk.lon = lon.lon
         wrk.crc = lon.crc
         wrk.opnamt = lon.opnamt
         wrk.ostatok = bilance.
  
  find crc where crc.crc = lon.crc no-lock no-error.
  wrk.ostatok_kzt = bilance * crc.rate[1].
  
  run rsk_proc1(wrk.lon).
  do i = 1 to 6: wrk.coeff[i] = coeff[i]. end.
  
  v-cif = lon.cif.
  
  mesa = mesa + 1.
  hide message no-pause.
  message ' обработано ' + string(mesa) + ' кредитов '.
  
end. /* for each lon */

hide message no-pause.
message ' Идет расчет рисков '.

def var bb as deci init 0.
all_od = 0.
for each wrk no-lock break by wrk.cif:
  bb = bb + wrk.ostatok_kzt.
  all_od = all_od + wrk.ostatok_kzt.
  if last-of(wrk.cif) then do:
    create wrk1.
    wrk1.cif = wrk.cif.
    wrk1.sumod = bb.
    bb = 0. 
  end.
end.

output stream rep to rpt.htm.

put stream rep unformatted
    "<html xmlns:o=""urn:schemas-microsoft-com:office:office""xmlns:x=""urn:schemas-microsoft-com:office:excel""><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru"">" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Риски ссудного портфеля " g-today format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>пп</td>" skip
    "<td>Код<BR>клиента</td>" skip
    "<td>Наименование клиента</td>" skip
    "<td>Ссудный счет</td>" skip
    "<td>Валюта</td>" skip
    "<td>Одобренная<BR>сумма</td>" skip
    "<td>Отрасль</td>" skip
    "<td>Срок до<BR>погашения</td>" skip
    "<td>Ср.об./сумма<BR>займа</td>" skip
    "<td>Обеспечение</td>" skip
    "<td>Кредитная<BR>история</td>" skip
    "<td>Фин.<BR>состояние</td>" skip
    "<td>Индекс<BR>надежности</td>" skip
    "</tr>" skip.

def var cif_coeff as deci extent 7.

coun = 0. rsk_port = 0.
for each wrk no-lock break by wrk.cif:
  
  if first-of(wrk.cif) then do:
     lonnum = 0. cif_coeff = 0.
  end.
  find first crc where crc.crc = wrk.crc no-lock no-error.
  put stream rep unformatted
    "<tr>" skip
    "<td>" coun + 1 "</td>" skip
    "<td>" if first-of(wrk.cif) then wrk.cif else "" "</td>" skip
    "<td>" if first-of(wrk.cif) then wrk.klname else "" "</td>" skip
    "<td>&nbsp;" wrk.lon "</td>" skip
    "<td>" if avail crc then crc.code else "-" "</td>" skip
    "<td>" replace(string(wrk.opnamt, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip.
  
  find wrk1 where wrk1.cif = wrk.cif no-lock no-error.
  v-relindex = 0.
  do i = 1 to 6:
    run normrasp(wrk.coeff[i] / krit_opt[i],0.5,0.15,yes, output v-normrasp).
    put stream rep unformatted "<td>" replace(string(v-normrasp * krit_weight[i], ">>9.99"),'.',',') "</td>" skip.
    v-relindex = v-relindex + v-normrasp * krit_weight[i].
    cif_coeff[i] = cif_coeff[i] + v-normrasp * krit_weight[i] * wrk.ostatok_kzt / wrk1.sumod.
    rsk_port[i] = rsk_port[i] + v-normrasp * krit_weight[i] * wrk.ostatok_kzt / all_od.
  end.
  
  put stream rep unformatted "<td>" replace(string(v-relindex, ">>9.99"),'.',',') "</td></tr>" skip.
  cif_coeff[7] = cif_coeff[7] + v-relindex * wrk.ostatok_kzt / wrk1.sumod.
  rsk_port[7] = rsk_port[7] + v-relindex * wrk.ostatok_kzt / all_od.
  
  coun = coun + 1.
  lonnum = lonnum + 1.
  if last-of(wrk.cif) then do:
    if lonnum > 1 then do:
      
      put stream rep unformatted
          "<tr>" skip
          "<td></td><td colspan=5>Итог по клиенту " wrk.cif "</td>" skip.
      do i = 1 to 7:
        put stream rep unformatted "<td>" replace(string(cif_coeff[i], ">>9.99"),'.',',') "</td>" skip.
      end.
      
    end.
  end. /* if last-of(wrk.cif) */
  
end. /* for each wrk */

/* риски кредитного портфеля */
put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td colspan=""6"">Риски кредитного портфеля (ю/л)</td>" skip.

v-relindex = 0.
do i = 1 to 7:
  put stream rep unformatted "<td>" replace(string(rsk_port[i], ">>9.99"),'.',',') "</td>" skip.
end.

put stream rep unformatted "</tr>" skip.

/* строка оптимальных значений */
put stream rep unformatted
    "<tr>" skip
    "<td colspan=""6"">Пороговое значение</td>" skip.

def var v-porog as deci init 0.

do i = 1 to 6:
  put stream rep unformatted "<td>" replace(string(krit_opt[i] * krit_weight[i] / 100, ">>9.99"),'.',',') "</td>" skip.
  v-porog = v-porog + krit_opt[i] * krit_weight[i] / 100.
end.

put stream rep unformatted "<td>" replace(string(v-porog, ">>9.99"),'.',',') "</td></tr>" skip.

/* отклонение */
put stream rep unformatted
    "<tr>" skip
    "<td colspan=""6"">Отклонение</td>" skip.

do i = 1 to 6:
  put stream rep unformatted "<td>" replace(string(krit_opt[i] * krit_weight[i] / 100 - rsk_port[i], "->>9.99"),'.',',') "</td>" skip.
end.

put stream rep unformatted "<td>" replace(string(v-porog - rsk_port[7], "->>9.99"),'.',',') "</td></tr>" skip.

put stream rep unformatted  "</table></body></html>" skip.
output stream rep close.

hide message no-pause.

unix silent cptwin rpt.htm excel.
run menu-prt ("err.txt").

