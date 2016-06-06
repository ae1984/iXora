/* lnloss.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Отчет - расшифровка счетов 713014 и 713040 (13 и 14 уровни lon - од и %%, списанные в убыток)
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
        28/02/2005 madiar - вынес расчетную часть из lnloss.p
 * CHANGES
        01/03/2005 madiar - дата списания - последняя проводка только по дебету
        22/04/2005 madiar - вместо lon.gua - программа кредитования (сегмент)
*/

define input parameter dat as date.

define var s-ourbank as char.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def shared temp-table wrk
  field bank        as   char
  field cif         like txb.lon.cif
  field klname      as   char
  field lon         like txb.lon.lon
  field crc         like txb.lon.crc
  field sdtod       as   date init ?
  field sumod       as   deci
  field sumodkzt    as   deci
  field sdtprc      as   date init ?
  field sumprc      as   deci
  field sumprckzt   as   deci
  field sdtpen      as   date init ?
  field sumpen      as   deci
  field curacc      as   deci
  field segm        as   char
  index ind is primary bank cif.

def var od as deci.
def var prc as deci.
def var pen as deci.

for each txb.lon no-lock:
  
  run lonbalcrc_txb('lon', txb.lon.lon, dat, "13", no, txb.lon.crc, output od).
  run lonbalcrc_txb('lon', txb.lon.lon, dat, "14", no, txb.lon.crc, output prc).
  run lonbalcrc_txb('lon', txb.lon.lon, dat, "30", no, 1, output pen).
  if od = 0 and prc = 0 and pen = 0 then next.
  
  create wrk.
  wrk.bank = s-ourbank.
  find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
  wrk.cif = txb.lon.cif.
  if avail txb.cif then wrk.klname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
  else wrk.klname = "--не найден--".
  wrk.lon = txb.lon.lon.
  wrk.crc = txb.lon.crc.
  wrk.sumod = od.
  wrk.sumprc = prc.
  wrk.sumpen = pen.
  find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt < dat no-lock no-error.
  wrk.sumodkzt = wrk.sumod * txb.crchis.rate[1].
  wrk.sumprckzt = wrk.sumprc * txb.crchis.rate[1].
  if od <> 0 then do:
    find last txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 13 and txb.lonres.dc = 'D' and txb.lonres.jdt < dat no-lock no-error.
    if avail txb.lonres then wrk.sdtod = txb.lonres.jdt.
  end.
  if prc <> 0 then do:
    find last txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 14 and txb.lonres.dc = 'D' and txb.lonres.jdt < dat no-lock no-error.
    if avail txb.lonres then wrk.sdtprc = txb.lonres.jdt.
  end.
  if pen <> 0 then do:
    find last txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 30 and txb.lonres.dc = 'D' and txb.lonres.jdt < dat no-lock no-error.
    if avail txb.lonres then wrk.sdtpen = txb.lonres.jdt.
  end.
  
  run lonbalcrc_txb('cif', txb.lon.aaa, dat, "1", no, txb.lon.crc, output wrk.curacc).
  wrk.curacc = - wrk.curacc.
  
  find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnsegm' no-lock no-error.
  if avail txb.sub-cod then do:
    find first txb.codfr where txb.codfr.codfr = "lnsegm" and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
    if avail txb.codfr then wrk.segm = txb.codfr.name[1].
  end.
  else wrk.segm = "--n/a--".
  
end.
