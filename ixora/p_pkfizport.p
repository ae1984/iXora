/* p_pkfizport.p
 * MODULE
        Администратор
 * DESCRIPTION
        Анализ кредитного потрфеля физ.лиц для управленческой (Push-отчет)
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
def var v-sumport as decimal no-undo.
def var v-amtport as integer no-undo.
def var v-sumvyd as decimal no-undo extent 3.
def var v-amtvyd as integer no-undo extent 3.
def new shared var dates as date no-undo extent 4.

/*кредитный потфель*/
def new shared temp-table pkport
  field sum as decimal
  field amt as integer
  field bank as char.
  
/*кредитный потфель*/
def new shared temp-table pkvyd
  field dt as date
  field sum as decimal
  field amt as integer
  field bank as char.
def stream rep.
def buffer b-pkvyd for pkvyd.

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
  run pkfizport1(txb.bank).
  disconnect "txb".
end.   
output stream rep to value(vfname).
{html-title.i
 &title = "METROCOMBANK" 
 &stream = "stream rep" 
 &size-add = "x-"}
 put stream rep unformatted
 "<center><b>Анализ портфеля потребительских кредитов на " dat format "99/99/9999" "<br>(физические лица)</b></center><BR>" skip
 "<table border=1 cellpadding=0 cellspacing=0>" skip
 "<tr>" skip
 "<td>Кредитный портфель</td>" skip
 "<td colspan = ""2"" align=""center"" >"string(dat,'99.99.9999')"</td>" skip.
 put stream rep unformatted
 "<tr>" skip
 "<td></td>" skip
 "<td align=""center"" >Сумма</td>" skip
 "<td align=""center"" >Количество</td>" skip.
v-sumport = 0.
v-amtport = 0.
for each pkport:
  find txb where txb.bank = pkport.bank and txb.consolid no-lock no-error.
  if avail txb then pkport.bank = txb.info.
  v-sumport = v-sumport + pkport.sum.
  v-amtport = v-amtport +  pkport.amt.
end.


put stream rep unformatted
"<tr  style=""font:bold"">" skip
"<td>Консолидированный</td>" skip
"<td>" replace(trim(string(v-sumport, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" v-amtport "</td></tr>" skip.


for each pkport no-lock break by pkport.bank:
   
   put stream rep unformatted
   "<tr>" skip
   "<td>" pkport.bank "</td>" skip
   "<td>" replace(trim(string(pkport.sum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
   "<td>" pkport.amt "</td></tr>" skip.
end.

put stream rep unformatted "</table><br><br>" skip.

do i = 1 to 3: 
  v-sumvyd[i] = 0.
  v-amtvyd [i] = 0.
end.
do i = 1 to 3:
  for each pkvyd where pkvyd.dt = dates[i] no-lock:
    v-sumvyd[i] = v-sumvyd[i] + pkvyd.sum.
    v-amtvyd [i] = v-amtvyd [i] + pkvyd.amt.
  end.
end.

put stream rep unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip
 "<tr align=""center"">" skip
 "<td rowspan = ""2"">Выдача кредита</td>" skip.
do i = 1 to 2:
  put stream rep unformatted "<td colspan = ""3"">"dates[i]"</td>" skip.
end. 
put stream rep unformatted "</tr><tr align=""center"" >" skip.
do i = 1 to 2:
 put stream rep unformatted
 "<td >Сумма</td>" skip
 "<td >Прирост выдач</td>" skip
 "<td >Количество</td>" skip.
end. 
put stream rep unformatted "</tr>" skip
"<tr  style=""font:bold""><td>Консолидированный</td>" skip.
do i = 1 to 2:
    put stream rep unformatted
    "<td>" replace(trim(string(v-sumvyd[i], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
    "<td>" replace(trim(string(v-sumvyd[i] - v-sumvyd[i + 1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
    "<td>" v-amtvyd [i] "</td>" skip.
end.
put stream rep unformatted "</tr>" skip.
for each txb where txb.consolid no-lock break by txb.info:
  put stream rep unformatted "<tr>" skip
  "<td>" txb.info "</td>" skip.
  do i = 1 to 2:
    find pkvyd where pkvyd.bank = txb.bank and pkvyd.dt = dates[i] no-lock no-error.
    put stream rep unformatted
    "<td>" replace(trim(string(pkvyd.sum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
    find b-pkvyd where b-pkvyd.bank = txb.bank and b-pkvyd.dt = dates[i + 1] no-lock no-error.
    put stream rep unformatted
    "<td>" replace(trim(string(pkvyd.sum - b-pkvyd.sum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
    "<td>" pkvyd.amt "</td>" skip.
  end.
  put stream rep unformatted "</tr>" skip.
end.

put stream rep unformatted "</table><br><br>" skip.
 
{html-end.i "stream rep"}
output stream rep close.
vres = yes. /* успешное формирование файла */