/* p_pkprov.p
 * MODULE
        Администратор
 * DESCRIPTION
        Динамика прироста портфеля потреб.кредитов и провизий для управленческой (Push-отчет)
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
        29/07/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        03/08/2009 galina - перекомпеляция
*/
{global.i}
{push.i}
def var dat as date no-undo.
def var bdat as date no-undo.
def var i as integer no-undo.
def var v-sumport as decimal no-undo extent 3.
def var v-amtport as integer no-undo extent 3.
def var v-sumprov as decimal no-undo extent 3.
def var v-amtprov as integer no-undo extent 3.
def new shared var dates as date no-undo extent 3.

/*кредитный потфель*/
def new shared temp-table pkport
  field dt as date
  field sum as decimal
  field amt as integer
  field bank as char.
  
/*провизии*/
def new shared temp-table pkprov
  field dt as date
  field sum as decimal
  field amt as integer
  field bank as char.
  
def stream rep.
def buffer b-pkport for pkport.

dat = vd1.

bdat = dat.
dates[1] = dat.
do i = 2 to 3:
  if day(bdat) <> 1 then bdat = date(month(bdat),1,year(bdat)).
  else do:
    if month(bdat) = 1 then bdat = date(12,1,year(bdat) - 1).
    else bdat = date(month(bdat) - 1,1,year(bdat)).
  end.
  dates[i] = bdat.
end.       
/*message "Формируется отчет...".*/
for each comm.txb where comm.txb.consolid no-lock.
  if connected ("txb") then disconnect "txb".
  connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
  run pkprov1(txb.bank).
  disconnect "txb".
end.   

do i = 1 to 3: 
  v-sumport[i] = 0.
  v-amtport [i] = 0.
end.
do i = 1 to 3:
  for each pkport where pkport.dt = dates[i] no-lock:
    v-sumport[i] = v-sumport[i] + pkport.sum.
    v-amtport[i] = v-amtport[i] + pkport.amt.
  end.
end.


do i = 1 to 3: 
  v-sumprov[i] = 0.
  v-amtprov [i] = 0.
end.
do i = 1 to 3:
  for each pkprov where pkprov.dt = dates[i] no-lock:
    v-sumprov[i] = v-sumprov[i] + pkprov.sum.
    v-amtprov[i] = v-amtprov[i] + pkprov.amt.
  end.
end.

output stream rep to value(vfname).
{html-title.i
 &title = "METROCOMBANK" 
 &stream = "stream rep" 
 &size-add = "x-"}
 put stream rep unformatted
 "<center><b>Динамика прироста портфеля потребительских кредитов, провизий и просроченной задолженности на " dat format "99/99/9999" "<br>(физические лица)</b></center><BR>" skip
 "<table border=1 cellpadding=0 cellspacing=0>" skip
 "<tr>" skip
 "<td rowspan = ""3"" style=""font:bold"">Провизии (резервы)</td>" skip.
 do i = 1 to 2:
   put stream rep unformatted "<td colspan = ""2"">"dates[i]"</td>" skip.
 end.
 put stream rep unformatted "</tr><tr>" skip.
 do i = 1 to 2:
   put stream rep unformatted "<td>Сумма</td><td>Прирост</td>" skip.
 end.
 put stream rep unformatted "</tr><tr style=""font:bold"">" skip.
 do i = 1 to 2:
   put stream rep unformatted "<td>" replace(trim(string(v-sumprov[i], "->>>>>>>>>>>9.99")),".",",") "</td><td>" replace(trim(string(v-sumprov[i] - v-sumprov[i + 1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
 end.
 put stream rep unformatted "</tr><tr>" skip
 "<td>Кредитный портфель</td>" skip.
 do i = 1 to 2:
   put stream rep unformatted "<td colspan = ""2""></td>" skip.
 end.
 put stream rep unformatted "</tr><tr style=""font:bold"">" skip
 "<td>Консолидированный</td>" skip.
 do i = 1 to 2:
   put stream rep unformatted "<td>" replace(trim(string(v-sumport[i], "->>>>>>>>>>>9.99")),".",",") "</td><td>" replace(trim(string(v-sumport[i] - v-sumport[i + 1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
 end.
 put stream rep unformatted "</tr>" skip.

for each txb where txb.consolid no-lock break by txb.info:
  put stream rep unformatted "<tr>" skip
  "<td>" txb.info "</td>" skip.
  do i = 1 to 2:
    find pkport where pkport.bank = txb.bank and pkport.dt = dates[i] no-lock no-error.
    put stream rep unformatted
    "<td>" replace(trim(string(pkport.sum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
    find b-pkport where b-pkport.bank = txb.bank and b-pkport.dt = dates[i + 1] no-lock no-error.
    put stream rep unformatted
    "<td>" replace(trim(string(pkport.sum - b-pkport.sum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
  end.
  put stream rep unformatted "</tr>" skip.
end.
put stream rep unformatted "</table>" skip.
 
{html-end.i "stream rep"}
output stream rep close.
vres = yes. /* успешное формирование файла */