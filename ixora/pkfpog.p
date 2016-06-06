/*  pkfpog.p
 * MODULE
        Быстрые Деньги
 * DESCRIPTION
        Отчет - кредиты - кандидаты на полное досрочное погашение
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
        10/01/2005 madiar
 * CHANGES
        17/01/2005 madiar - добавил три колонки - день погашения, ежемесячный платеж и проценты по графику
        19/01/2005 madiar - добавил еще пару колонок
*/

{mainhead.i}

{comm-txb.i}
define var s-ourbank as char.
s-ourbank = comm-txb().

def var v-od as deci.
def var v-ost as deci.
def stream rep.
def var mesa as int.
def var usrnm as char.
def var coun as integer.

def temp-table wrk
  field cif like cif.cif
  field cl_name as char
  field lon like lon.lon
  field aaa like aaa.aaa
  field od as deci
  field ost as deci
  field rdt as date
  field duedt as date
  field dayp as integer
  field mpayment as deci
  field prc as deci
  field fprc as deci
  index idx is primary cif.

for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '6' no-lock:
  
  if pkanketa.lon = '' then next.
  
  find lon where lon.lon = pkanketa.lon no-lock no-error.
  run lonbalcrc('cif',pkanketa.aaa,g-today,"1",yes,1,output v-ost).
  v-ost = - v-ost.
  if v-ost <= 0 then next.
  
  run lonbalcrc('lon',pkanketa.lon,g-today,"1,7",yes,1,output v-od).
  if v-od <= 0 then next.
  
  if v-ost - v-od > - 10000 then do:
    find cif where cif.cif = pkanketa.cif no-lock no-error.
    create wrk.
    wrk.cif = pkanketa.cif.
    wrk.cl_name = trim(cif.name).
    wrk.lon = pkanketa.lon.
    wrk.aaa = pkanketa.aaa.
    wrk.od = v-od.
    wrk.ost = v-ost.
    wrk.rdt = lon.rdt.
    wrk.duedt = lon.duedt.
    wrk.dayp = lon.day.
    
    run lonbalcrc('lon',pkanketa.lon,g-today,"2,9",yes,1,output wrk.fprc).
    
    find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.fpn = 0 and lnsci.flp = 0 and lnsci.idat >= g-today no-lock no-error.
    if avail lnsci then wrk.prc = lnsci.iv-sc.
    else do:
      find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.fpn = 0 and lnsci.flp = 0 no-lock no-error.
      if avail lnsci then wrk.prc = lnsci.iv-sc.
    end.
    
    find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.fpn = 0 and lnsch.flp = 0 and lnsch.stdat >= g-today no-lock no-error.
    if avail lnsch then wrk.mpayment = lnsch.stval + wrk.prc.
    else do:
      find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.fpn = 0 and lnsch.flp = 0 no-lock no-error.
      if avail lnsch then wrk.mpayment = lnsch.stval + wrk.prc.
    end.
    
  end.
  
  mesa = mesa + 1.
  hide message no-pause.
  message " Обработано " mesa " анкет ".
  
end.

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
    "<center><b>Кредиты с возможным досрочным погашением</b></center><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>п/п</td>" skip
    "<td>Код<BR>заемщика</td>" skip
    "<td>ФИО заемщика</td>" skip
    "<td>Остаток ОД</td>" skip
    "<td>Остаток на<BR>тек счете</td>" skip
    "<td>Дата<BR>выдачи</td>" skip
    "<td>Дата<BR>погашения</td>" skip
    "<td>День<BR>погашения</td>" skip
    "<td>Ежемес<BR>платеж</td>" skip
    "<td>% по<BR>графику</td>" skip
    "<td>Факт.<BR>начисл. %</td>" skip
    "<td>Сумма<BR>на досроч. погаш.</td>" skip
    "<td>Сумма остатка<BR>на досроч. погаш.</td>" skip
    "</tr>" skip.

coun = 1.
for each wrk no-lock:
  
  put stream rep unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>" wrk.cif "</td>" skip
    "<td>" wrk.cl_name "</td>" skip
    "<td>" replace(trim(string(wrk.od, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.ost, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" wrk.rdt "</td>" skip
    "<td>" wrk.duedt "</td>" skip
    "<td>" wrk.dayp "</td>" skip
    "<td>" replace(trim(string(wrk.mpayment, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prc, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.fprc, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prc + wrk.od, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prc + wrk.od - wrk.ost, "->>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.
  coun = coun + 1.
  
end.

put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin rep.htm excel.


