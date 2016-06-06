/* calxlsm.p
 * MODULE
        Кредитный модуль     
 * DESCRIPTION
        Просмотр календарей погашения кредитов
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
        02/08/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
*/

{global.i}

def shared var s-lon like lon.lon.
def stream rep.
def var coun as int no-undo.
def var v-comved as deci no-undo.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
  message " Ссудный счет не найден " view-as alert-box error.
  return.
end.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define temp-table wrk no-undo
  field num as integer
  field dt1 as date
  field sum1 as decimal
  field dt2 as date
  field sum2 as decimal
  field days as integer
  field dolg as decimal
  index idx is primary dt1.

if (s-ourbank = "txb00" and lon.rdt >= 05/16/2005) or (s-ourbank <> "txb00" and lon.rdt >= 10/03/2005) then do:
  find pksysc where pksysc.credtype = '6' and pksysc.sysc = "bdacc" no-lock no-error.
  if avail pksysc then v-comved = pksysc.deval. else v-comved = 400.
end.

coun = 1.
for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock:
  create wrk.
  wrk.num = coun.
  wrk.dt1 = lnsch.stdat.
  wrk.dt2 = ?.
  find first lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 and lnsci.idat = lnsch.stdat no-lock no-error.
  wrk.sum1 = lnsch.stval + lnsci.iv-sc + v-comved.
  coun = coun + 1.
end.

find first wrk no-lock no-error.
if not avail wrk then do:
  message " Проверьте наличие графиков платежей " view-as alert-box error.
  return.
end.

for each jl where jl.sub = "cif" and jl.acc = lon.aaa and jl.jdt > lon.rdt and jl.lev = 1 and jl.dc = 'C' no-lock:
  find first wrk where wrk.dt2 = ? no-error.
  if not avail wrk then do:
    create wrk.
    wrk.num = coun.
    coun = coun + 1.
  end.
  wrk.dt2 = jl.jdt.
  wrk.sum2 = jl.cam.
  if wrk.dt1 <> ? and wrk.dt1 <= wrk.dt2 then wrk.days = wrk.dt2 - wrk.dt1.
  run lonbalcrc('lon',lon.lon,jl.jdt,"7,9,16",no,lon.crc,output wrk.dolg).
end.

output stream rep to rpt.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find lon where lon.lon = s-lon no-lock.
find first cif where cif.cif = lon.cif no-lock no-error.
find first crc where crc.crc = lon.crc no-lock no-error.
find first cmp no-lock no-error.

put stream rep unformatted
    "<h2>" cmp.name format "x(40)" "</h2><BR>" skip
    "Наименование/имя заемщика (код): " cif.name " (" cif.cif ")<BR>" skip
    "Ссудный счет: " lon.lon "<BR>" skip
    "Сумма кредита: " lon.opnamt " " crc.code "<BR><BR>" skip.
    
put stream rep unformatted
    "<h2>График платежей</h2>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>nn</td>" skip
    "<td>Дата<br>платежа</td>" skip
    "<td>Сумма<br>платежа</td>" skip
    "<td>Дата факт.<br>платежа</td>" skip
    "<td>Сумма факт.<br>платежа</td>" skip
    "<td>Просрочка<br>дней</td>" skip
    "<td>Сумма<br>долга</td>" skip
    "</tr>" skip.

for each wrk no-lock:
  put stream rep unformatted
             "<tr>" skip
             "<td align=""center"">" wrk.num "</td>" skip
             "<td>" wrk.dt1 format "99/99/9999" "</td>" skip
             "<td>" replace(trim(string(wrk.sum1, ">>>>>>>>9.99")),".",",") "</td>" skip
             "<td>" wrk.dt2 format "99/99/9999" "</td>" skip
             "<td>" replace(trim(string(wrk.sum2, ">>>>>>>>9.99")),".",",") "</td>" skip
             "<td>" wrk.days "</td>" skip
             "<td>" replace(trim(string(wrk.dolg, ">>>>>>>>9.99")),".",",") "</td>" skip
             "</tr>" skip.
end.

put stream rep unformatted "</table><BR>" skip.



put stream rep unformatted "</body></html>" skip.

output stream rep close.
unix silent cptwin rpt.htm excel.

