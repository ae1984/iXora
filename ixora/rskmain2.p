/* rskmain2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Матрица рисков по клиенту
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

def input parameter s-cif as char.

/* отрасль срок_до_пог ср_об/ОД обеспечение кред_история фин_состояние */
def var krit_opt as deci extent 6 init [80,80,40,60,100,80].
def var krit_weight as deci extent 6 init [10,10,10,25,15,30].
def var i as integer.

find sysc where sysc.sysc = "rskkri" no-lock no-error.
if avail sysc then do:
  do i = 1 to 6:
    krit_opt[i] = decimal(entry(i,sysc.chval)).
    krit_weight[i] = decimal(entry(6 + i,sysc.chval)).
  end.
end.

def stream rep.
def var klname as char.
def var bilance as deci.
def var coun as integer.
def var mesa as integer.
def var usrnm as char.
def var v-cif as char.
def new shared var coeff as deci extent 6.
def new shared var coeff_a as deci extent 7.
def var all_od as deci.

def var cname as char extent 7 init ["Коэфф. текущей ликвидности","Коэфф. быстрой (срочной) ликвидности","Коэфф. кредитоспособности","Коэфф. оборачиваемости ТМЗ","Коэфф. оборачиваемости кредиторской задолженности","Коэфф. автономии","Коэфф. ROA"].

def temp-table wrk
  field lon like lon.lon
  field crc like crc.crc
  field opnamt like lon.opnamt
  field ostatok like lon.opnamt
  field ostatok_kzt like lon.opnamt
  field coeff as deci extent 6.

find cif where cif.cif = s-cif no-lock no-error.
if avail cif then klname = trim(cif.prefix) + ' ' + trim(cif.name).
else klname = "--не найдено--".

def stream err.
output stream err to err.txt.
output stream err close.

mesa = 0. v-cif = ''. all_od = 0.
for each lon where lon.cif = s-cif no-lock:
  
  if lookup(string(lon.grp),"10,15,30,35,50,55,70") = 0 then next.
  run lonbal('lon', lon.lon, g-today, "1,7,20,21", yes, output bilance).
  if bilance <= 0 then next.
  
  if lon.cif <> v-cif then do: coeff = 0. run rsk_proc2(lon.cif). end.
  
  create wrk.
  assign wrk.lon = lon.lon
         wrk.crc = lon.crc
         wrk.opnamt = lon.opnamt
         wrk.ostatok = bilance.
  
  find crc where crc.crc = lon.crc no-lock no-error.
  wrk.ostatok_kzt = bilance * crc.rate[1].
  all_od = all_od + wrk.ostatok_kzt.
  
  run rsk_proc1(wrk.lon).
  do i = 1 to 6: wrk.coeff[i] = coeff[i]. end.
  
  v-cif = lon.cif.
  
  mesa = mesa + 1.
  hide message no-pause.
  message ' обработано ' + string(mesa) + ' кредитов '.
  
end. /* for each lon */

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
    "<center><b>Матрица рисков, " g-today format "99/99/9999" "</b></center><BR><BR>" skip
    "<b>Код клиента: </b>" s-cif "<BR><b>Наименование: </b>" klname format "X(50)" "<BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>пп</td>" skip
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

def var v-normrasp as deci.
def var v-relindex as deci.
def var cif_coeff as deci extent 7.

coun = 1.
for each wrk no-lock:

  find first crc where crc.crc = wrk.crc no-lock no-error.
  put stream rep unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>&nbsp;" wrk.lon "</td>" skip
    "<td>" if avail crc then crc.code else "-" "</td>" skip
    "<td>" replace(string(wrk.opnamt, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip.
    
  v-relindex = 0.
  do i = 1 to 6:
    run normrasp(wrk.coeff[i] / krit_opt[i],0.5,0.15,yes, output v-normrasp).
    put stream rep unformatted "<td>" replace(string(v-normrasp * krit_weight[i], ">>9.99"),'.',',') "</td>" skip.
    v-relindex = v-relindex + v-normrasp * krit_weight[i].
    cif_coeff[i] = cif_coeff[i] + v-normrasp * krit_weight[i] * wrk.ostatok_kzt / all_od.
  end.
  
  put stream rep unformatted "<td>" replace(string(v-relindex, ">>9.99"),'.',',') "</td></tr>" skip.
  cif_coeff[7] = cif_coeff[7] + v-relindex * wrk.ostatok_kzt / all_od.
  
  coun = coun + 1.
  
end.

put stream rep unformatted
   "<tr style=""font:bold"">" skip
   "<td></td><td colspan=3>Итог по клиенту</td>" skip.
   do i = 1 to 7:
      put stream rep unformatted "<td>" replace(string(cif_coeff[i], ">>9.99"),'.',',') "</td>" skip.
   end.

put stream rep unformatted  "</table><BR><BR>" skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td colspan=6>Коэффициент</td>" skip
    "<td>Значение</td>" skip
    "</tr>" skip.

do i = 1 to 7:
  put stream rep unformatted
    "<tr>" skip
    "<td colspan=6>" cname[i] "</td>" skip
    "<td>" replace(trim(string(coeff_a[i], ">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.
end.

put stream rep unformatted  "</table></body></html>" skip.
output stream rep close.

unix silent cptwin rpt.htm excel.
run menu-prt ("err.txt").

