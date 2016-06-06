/* trbonus.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Расчет бонуса отдела по работе с проблемными кредитами
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
        22/09/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
        22/09/2006 madiyar - за знаменатель процента возврата берем всю сумму кредита, включая непросроченный ОД, причем на dt_pog
        10/10/2006 madiyar - изменил принцип выборки кредитов
*/

{mainhead.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc then s-ourbank = trim(sysc.chval).

def var dt1 as date no-undo.
def var dt2 as date no-undo.

def temp-table wrk no-undo
  field cif like cif.cif
  field clname as char
  field lon like lon.lon
  field wdays as integer
  field sum1 as deci
  field dtpay as date
  field sum2 as deci
  field comm as char
  index idx is primary cif lon.

dt2 = date(month(g-today),1,year(g-today)) - 1.
dt1 = date(month(dt2),1,year(dt2)).

update dt1 label ' Укажите период с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat.
hide frame dat.

def var v-bal as deci no-undo.
def var v-sp as deci no-undo.

def var dt_pog as date no-undo.
def var days_pr as integer no-undo.
def var v-wdays as integer no-undo.
def var v-in as logical no-undo.
def var days_pr1 as integer no-undo.
def var v-spis as logical no-undo.
def var csumv as deci no-undo.
def var sumv as deci no-undo.
def var sumb as deci no-undo.
def var days as integer no-undo extent 2.
def var coun as integer no-undo.
/* def var mesa as integer no-undo extent 3. */

/*
days[1] - по всем ПРОБЛЕМНЫМ задолжникам - кол-во дней работы
days[2] - по всем ПРОБЛЕМНЫМ задолжникам - кол-во дней просрочки
coun - количество ПРОБЛЕМНЫХ задолжников
*/

message "Формируется отчет".

for each lon where lon.grp = 90 or lon.grp = 92 no-lock:
  
  if lon.opnamt <= 0 then next.
  if lon.rdt > dt2 then next.
  
  csumv = 0. dt_pog = 01/01/3000.
  for each jl where jl.acc = lon.aaa and jl.dc = 'C' and jl.jdt >= dt1 and jl.jdt <= dt2 and jl.lev = 1 use-index accdcjdt no-lock:
      csumv = csumv + jl.cam.
      if jl.jdt < dt_pog then dt_pog = jl.jdt.
  end.
  
  if csumv <= 0 then next.
  
  v-spis = no. /* csumv = 0. */
  find first lonres where lonres.lon = lon.lon and lonres.jdt >= dt1 and lonres.jdt <= dt2 and (lonres.lev = 13 or lonres.lev = 14 or lonres.lev = 30) no-lock no-error.
  if avail lonres then v-spis = yes.
  else do:
    run lonbalcrc('lon',lon.lon,dt1,"13,14,30",no,1,output v-sp).
    if v-sp > 0 then v-spis = yes.
  end.
  
  v-in = no.
  if v-spis then assign days_pr = 180 v-wdays = 180 v-in = yes.
  else do:
    run lndayspr(lon.lon,dt_pog,no,output days_pr,output days_pr1).
    find last pkdebtdat where pkdebtdat.bank = s-ourbank
                              and pkdebtdat.lon = lon.lon
                              and pkdebtdat.rdt > (dt_pog - days_pr)
                              and pkdebtdat.rdt <= dt_pog
                              and pkdebtdat.result = "secu" use-index lonrdt no-lock no-error.
    if avail pkdebtdat then do:
      v-wdays = dt_pog - pkdebtdat.rdt.
      v-in = yes.
    end.
  end.
  
  if v-in then do:
    
    sumv = sumv + csumv.
    /*run lonbalcrc('lon',lon.lon,dt1,"1,4,5,7,9,13,14,16,30",no,1,output v-bal).*/
    run lonbalcrc('lon',lon.lon,dt_pog,"1,4,5,7,9,13,14,16,30",no,1,output v-bal).
    sumb = sumb + v-bal.
    
    find first cif where cif.cif = lon.cif no-lock no-error.
    create wrk.
    assign wrk.cif = lon.cif
           wrk.clname = trim(cif.name)
           wrk.lon = lon.lon
           wrk.sum1 = v-bal
           wrk.dtpay = dt_pog
           wrk.sum2 = csumv
           wrk.wdays = v-wdays.
    if v-spis then wrk.comm = "Z".
    days[1] = days[1] + wrk.wdays.
    days[2] = days[2] + days_pr.
    coun = coun + 1.
    /*
    mesa[3] = mesa[3] + 1.
    */
    
  end. /* if v-in */
  
end. /* for each lon */

def var keirv as deci no-undo. /* Эффективность использования рабочего времени */
def var kkdp as deci no-undo. /* Количество дней просрочки */
def var kkz as deci no-undo. /* Количество заемщиков */
def var kvz as deci no-undo. /* Процент возврата от общей задолженности */

def var keirv1 as deci no-undo.
def var kkdp1 as deci no-undo.
def var kkz1 as deci no-undo.
def var sumv1 as deci no-undo.
def var kvz1 as deci no-undo.

def var sumv_r as deci no-undo.
def var kball as deci no-undo.
def var kball_r as deci no-undo.
def var kprc as deci no-undo.

keirv = days[1] / coun.
kkdp = days[2] / coun.
kkz = coun.
/* sumv - Сумма возврата */
kvz = sumv / sumb * 100.


if keirv <= 10 then keirv1 = 4.
else
if keirv <= 30 then keirv1 = 3.
else
if keirv <= 60 then keirv1 = 2.
else
if keirv <= 90 then keirv1 = 1.
else
keirv1 = 0.

if kkdp > 180 then kkdp1 = 4.
else
if kkdp > 120 then kkdp1 = 3.
else
if kkdp > 60 then kkdp1 = 2.
else
if kkdp > 30 then kkdp1 = 1.
else
kkdp1 = 0.

if kkz > 600 then kkz1 = 4.
else
if kkz > 300 then kkz1 = 3.
else
if kkz > 225 then kkz1 = 2.
else
if kkz > 150 then kkz1 = 1.
else
kkz1 = 0.

sumv_r = round(sumv,0).
if sumv_r <= 5000000 then sumv1 = 0.
else
if sumv_r > 19400000 then sumv1 = 4.
else do:
  sumv1 = ((sumv_r - 5000001) - ((sumv_r - 5000001) mod 600000)) / 600000 * 0.125 + 1.
end.

if kvz > 80 then kvz1 = 4.
else
if kvz > 50 then kvz1 = 3.
else
if kvz > 30 then kvz1 = 2.
else
if kvz > 10 then kvz1 = 1.
else
kvz1 = 0.

def var usrnm as char no-undo.
def stream rep.
output stream rep to trbonus.htm.

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
    "<center><b>Расчет бонуса Отдела по работе с проблемными займами, " dt1 format "99/99/9999" " - " dt2 format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr>" skip
    "<td colspan=""2"" style=""font:bold"">Коэффициент</td>" skip
    "<td style=""font:bold"">Вес</td>" skip
    "<td style=""font:bold"">Значение</td>" skip
    "<td style=""font:bold"">Получ. балл</td>" skip
    "</tr>" skip
    "<tr>" skip
    "<td colspan=""2"">1. Эффективность использования рабочего времени</td>" skip
    "<td>10</td>" skip
    "<td>" replace(trim(string(keirv,">>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(keirv1,">>>>>>>>9.999")),'.',',') "</td>" skip
    "</tr>" skip
    "<tr>" skip
    "<td colspan=""2"">2. Количество дней просрочки</td>" skip
    "<td>10</td>" skip
    "<td>" trim(string(kkdp,">>>>>>>>9")) "</td>" skip
    "<td>" replace(trim(string(kkdp1,">>>>>>>>9.999")),'.',',') "</td>" skip
    "</tr>" skip
    "<tr>" skip
    "<td colspan=""2"">3. Количество заемщиков</td>" skip
    "<td>20</td>" skip
    "<td>" trim(string(kkz,">>>>>>>>9")) "</td>" skip
    "<td>" replace(trim(string(kkz1,">>>>>>>>9.999")),'.',',') "</td>" skip
    "</tr>" skip
    "<tr>" skip
    "<td colspan=""2"">4. Сумма возврата</td>" skip
    "<td>35</td>" skip
    "<td>" replace(trim(string(sumv,">>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(sumv1,">>>>>>>>9.999")),'.',',') "</td>" skip
    "</tr>" skip
    "<tr>" skip
    "<td colspan=""2"">5. Процент возврата от общей задолженности</td>" skip
    "<td>25</td>" skip
    "<td>" replace(trim(string(kvz,">>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(kvz1,">>>>>>>>9.999")),'.',',') "</td>" skip
    "</tr>" skip
    "<tr>" skip.

kball = keirv1 * 0.1 + kkdp1 * 0.1 + kkz1 * 0.2 + sumv1 * 0.35 + kvz1 * 0.25.
kball_r = kball * 100.
if kball_r >= 375 then kprc = 100.
else
if kball_r >= 350 then kprc = 70.
else
if kball_r >= 325 then kprc = 50.
else
if kball_r >= 100 then kprc = round(((kball_r - 100) - ((kball_r - 100) mod 25)) / 25 * 5 + 5,0).

put stream rep unformatted
    "<td colspan=""2"" style=""font:bold"">Конечный балл</td>" skip
    "<td></td>" skip
    "<td></td>" skip
    "<td>" replace(trim(string(kball,">>>>>>>>9.999")),'.',',') "</td>" skip
    "</tr>" skip
    "<td colspan=""2"" style=""font:bold"">% оклада, выпл. в виде премии</td>" skip
    "<td></td>" skip
    "<td></td>" skip
    "<td>" replace(trim(string(kprc,">>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip
    "</table><br><br>" skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Код кл</td>" skip
    "<td>ФИО</td>" skip
    "<td>Кол-во дней<br>в работе</td>" skip
    "<td>Сумма<br>задолженности</td>" skip
    "<td>Дата первого<br>погашения</td>" skip
    "<td>Сумма<br>погашения</td>" skip
    "<td>% возврата</td>" skip
    "<td>Примеч</td>" skip
    "</tr>" skip.

for each wrk no-lock:
  put stream rep unformatted
      "<tr>" skip
      "<td>" wrk.cif "</td>" skip
      "<td>" wrk.clname "</td>" skip
      "<td>" wrk.wdays "</td>" skip
      "<td>" replace(trim(string(wrk.sum1,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" wrk.dtpay format "99/99/9999" "</td>" skip
      "<td>" replace(trim(string(wrk.sum2,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" replace(trim(string(wrk.sum2 / wrk.sum1 * 100,">>>>>9.99")),'.',',') "</td>" skip
      "<td>" wrk.comm "</td>" skip
      "</tr>" skip.
end.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
hide message no-pause.
unix silent cptwin trbonus.htm excel.




