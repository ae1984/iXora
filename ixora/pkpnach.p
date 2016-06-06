/* pkpnach.p
 * MODULE
        Быстрые Деньги
 * DESCRIPTION
        Определение суммы для доначисления по кредитам БД, по которым были приостановлены проценты
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
        07/10/2005 madiar
 * BASES
        bank
 * CHANGES
        11/10/2005 madiar - подправил расчет доначисляемых штрафов
*/

{mainhead.i}

def var v-cif like cif.cif.
def var v-fio as char.
def var v-od as deci.
def var v-lon as char.
def var v-prem as deci.
def var v-pnlt as deci init 0.5.

def var dat as date.
dat = g-today.

def var dt1 as date.
def var dt2 as date.
def var dn1 as integer.
def var dn2 as decimal.
def var v-sumpen as deci.
def var sumst as deci.
def var sumadd as deci.
def var prosr_od as deci.
def var prosr_prc as deci.
/* def var n_prc as deci. */
def var itog as deci extent 2.

def temp-table wrk
  field stdat as date
  field endat as date
  field prc as deci
  field pen as deci
  index idx is primary stdat.

form
v-cif label "КОД КЛИЕНТА" validate(can-find(cif where cif.cif = v-cif)," Неверный код клиента! ") v-fio format "x(45)" no-label skip
dat label "ДАТА       " format "99/99/9999" skip
with no-box centered side-label row 5 width 70 frame cif.


update v-cif with frame cif.

find first cif where cif.cif = v-cif no-lock no-error.
if avail cif then do:
  v-fio = trim(cif.name).
  display v-fio with frame cif.
end.

v-lon = ''.
for each lon where lon.cif = v-cif no-lock:
  if lon.opnamt <= 0 then next.
  if not(lon.grp = 90 or lon.grp = 92) then next.
  run lonbalcrc('lon',lon.lon,g-today,"1,7,13",yes,lon.crc,output v-od).
  if v-od <= 0 then next.
  v-lon = lon.lon. /* v-iik = lon.aaa. */ leave.
end.

if v-lon = '' then do:
  message "У данного клиента нет непогашенных кредитов." view-as alert-box buttons ok title " Внимание! ".
  return.
end.

update dat with frame cif.

find first lon where lon.lon = v-lon no-lock no-error.

find first ln%his where ln%his.lon = v-lon and ln%his.intrate <> 0 no-lock no-error.
if avail ln%his then v-prem = ln%his.intrate.
else do:
  message " Не найдена запись ln%his с ненулевой ставкой! " view-as alert-box buttons ok.
  return.
end.

dt1 = ?.
for each ln%his where ln%his.lon = v-lon and ln%his.stdat <= dat no-lock:
  
  if ln%his.intrate = 0 then do: if dt1 = ? then dt1 = ln%his.stdat. end.
  if ln%his.intrate > 0 then do:
    if dt1 <> ? then do:
      create wrk.
      wrk.stdat = dt1.
      wrk.endat = ln%his.stdat.
      dt1 = ?.
    end.
  end.
  
end.

if dt1 <> ? then do:
    create wrk.
    wrk.stdat = dt1.
    if lon.duedt > dat then wrk.endat = dat. else wrk.endat = lon.duedt.
    dt1 = ?.
end.


for each wrk:
  
  /* if wrk.endat = lon.duedt then */ run day-360(wrk.stdat,wrk.endat - 1,lon.basedy,output dn1,output dn2).
  /* else run day-360(wrk.stdat,wrk.endat,lon.basedy,output dn1,output dn2). -- типа, ставку восстанавливают обычно на следующий день после проплаты */
  
  if lon.plan = 5 then wrk.prc = round(dn1 * v-prem * lon.opnamt / 100 / 360,2).
  if lon.plan = 3 then do:
    for each lnsci where lnsci.lni = lon.lon and lnsci.idat >= wrk.stdat and lnsci.idat <= wrk.endat and lnsci.f0 > 0 no-lock:
      wrk.prc = wrk.prc + lnsci.iv-sc.
    end.
  end.
  run lonbalcrc('lon',lon.lon,wrk.stdat,"7",yes,lon.crc,output prosr_od).
  /* run lonbalcrc('lon',lon.lon,wrk.stdat,"2",yes,lon.crc,output n_prc). */
  run lonbalcrc('lon',lon.lon,wrk.stdat,"9",yes,lon.crc,output prosr_prc).
  
  v-sumpen = 0.
   
  dt1 = wrk.stdat.
  sumst = prosr_od + prosr_prc.
  sumadd = 0.
  for each lnsch where lnsch.lnn = lon.lon and lnsch.stdat >= wrk.stdat and lnsch.stdat < wrk.endat and lnsch.f0 > 0 no-lock:
    run day-360(dt1,lnsch.stdat - 1,lon.basedy,output dn1,output dn2).
    v-sumpen = v-sumpen + round(dn1 * (sumst + sumadd) * v-pnlt / 100,2).
    sumadd = sumadd + lnsch.stval.
    dt1 = lnsch.stdat.
  end.
  run day-360(dt1,wrk.endat - 1,lon.basedy,output dn1,output dn2).
  v-sumpen = v-sumpen + round(dn1 * (sumst + sumadd) * v-pnlt / 100,2).
  
  dt1 = wrk.stdat.
  sumadd = 0.
  for each lnsci where lnsci.lni = lon.lon and lnsci.idat >= wrk.stdat and lnsci.idat < wrk.endat and lnsci.f0 > 0 no-lock:
    run day-360(dt1,lnsci.idat - 1,lon.basedy,output dn1,output dn2).
    v-sumpen = v-sumpen + round(dn1 * sumadd * v-pnlt / 100,2).
    sumadd = sumadd + lnsci.iv-sc.
    /* if sumadd - n_prc > 0 then do: sumadd = sumadd - n_prc. n_prc = 0. end. */
    dt1 = lnsci.idat.
  end.
  run day-360(dt1,wrk.endat - 1,lon.basedy,output dn1,output dn2).
  v-sumpen = v-sumpen + round(dn1 * sumadd * v-pnlt / 100,2).
  
  wrk.pen = v-sumpen.
  
end.

def stream rep.
output stream rep to pkpnach.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "</head><body><pre>" skip.

put stream rep unformatted
    "                   Доначисление % и штрафов" skip(1)
    "Клиент: " v-cif " " v-fio skip
    "Кредит: " v-lon skip(1)
    fill("-", 51) skip
    "С          По               Проценты         Штрафы" skip
    fill("-", 51) skip.

itog = 0.
for each wrk no-lock:
  put stream rep unformatted
      wrk.stdat format "99/99/9999" " "
      wrk.endat format "99/99/9999" " "
      wrk.prc format ">>>,>>>,>>9.99" " "
      wrk.pen format ">>>,>>>,>>9.99" skip.
  itog[1] = itog[1] + wrk.prc.
  itog[2] = itog[2] + wrk.pen.
end.

put stream rep unformatted
    fill("-", 51) skip
    fill(" ", 22)
    itog[1] format ">>>,>>>,>>9.99" " "
    itog[2] format ">>>,>>>,>>9.99" skip(2).

put stream rep unformatted "</pre></body></html>" skip.

output stream rep close.
unix silent cptwin pkpnach.htm winword.
pause 0.
