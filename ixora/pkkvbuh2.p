/* pkkvbuh2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Ежеквартальный отчет ДПК в бухгалтерию
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
        26/10/2004 madiar
 * BASES
        bank, comm, txb
 * CHANGES
        06/01/2005 madiar - изменил расчет выданных сумм
*/

def input parameter dat1 as date.
def input parameter dat2 as date.

def shared temp-table wrk
  field segm        as   char
  field bank        as   char
  field cif         like txb.lon.cif
  field klname      as   char
  field lon         like txb.lon.lon
  field grp         as   int
  field crc         like txb.lon.crc
  field prem        as   deci
  field rdt         as   date
  field opnamt      as   deci
  field vyd_kzt     as   deci
  field pog_kzt     as   deci
  field nachprc_kzt as   deci
  field polprc_kzt  as   deci
  field prol_kzt    as   deci
  index ind is primary bank segm cif.

def shared var g-today as date.
def var mesa as integer.
def var i as integer.
def var bilance as deci.
def var bb as deci.
def buffer b-lonres for txb.lonres.
def var dtpro as date.
def var vals as deci extent 5.

find first txb.cmp no-lock no-error.

mesa = 0.
for each txb.lon no-lock:
  
  if txb.lon.dam[1] = 0 then next.
  
  find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock.
  if txb.sub-cod.ccode <> '9' then next.
  
  vals = 0.
  
  if txb.lon.rdt >= dat1 and txb.lon.rdt <= dat2 then do:
    /*
    for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= dat1 and txb.lonres.jdt <= dat2 no-lock:
      if txb.lonres.lev = 1 and txb.lonres.dc = 'D' then do:
        find txb.jh where txb.jh.jh = txb.lonres.jh no-lock no-error.
        if avail txb.jh then do:
          if not(txb.jh.party begins "Storn") then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lonres.jdt no-lock no-error.
            vals[1] = vals[1] + txb.lonres.amt * txb.crchis.rate[1].
          end.
        end.
      end.
    end.
    */
    for each txb.lnscg where txb.lnscg.lng = txb.lon.lon no-lock:
      if txb.lnscg.jh > 0 then do:
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnscg.stdat no-lock no-error.
        vals[1] = vals[1] + txb.lnscg.paid * txb.crchis.rate[1].
      end.
    end.
  end. /* if txb.lon.rdt >= dat1 and txb.lon.rdt <= dat2 */
  
  for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.fpn = 0 and txb.lnsch.flp > 0 and txb.lnsch.stdat >= dat1 and txb.lnsch.stdat <= dat2 no-lock:
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsch.stdat no-lock no-error.
    vals[2] = vals[2] + txb.lnsch.paid * txb.crchis.rate[1].
  end.
  
  find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.lev = 11 and txb.histrxbal.dt <= dat2 no-lock no-error.
  if avail txb.histrxbal then vals[3] = txb.histrxbal.cam.
  find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.lev = 11 and txb.histrxbal.dt <= dat1 no-lock no-error.
  if avail txb.histrxbal then vals[3] = vals[3] - txb.histrxbal.cam.
  
  for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.fpn = 0 and txb.lnsci.flp > 0 and txb.lnsci.idat >= dat1 and txb.lnsci.idat <= dat2 no-lock:
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsci.idat no-lock no-error.
    vals[4] = vals[4] + txb.lnsci.paid-iv * txb.crchis.rate[1].
  end.
  
  /*
  правильно, если еще учесть уровень предоплаты, но он в валюте кредита
  run lonbal_txb('lon',txb.lon.lon,dat1,"12",no,output bb).
  run lonbal_txb('lon',txb.lon.lon,dat2,"12",yes,output vals[4]).
  vals[4] = bb - vals[4]. -- так как 12 уровень - пассивный --
  */
  
  dtpro = ?.
  if txb.lon.ddt[5] <> ? then dtpro = txb.lon.ddt[5].
  if txb.lon.cdt[5] <> ? then dtpro = txb.lon.cdt[5].
  if dtpro <> ? then do:
    run lonbal_txb('lon',txb.lon.lon,dtpro,"1,7,20,21",no,output vals[5]).
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt < dtpro no-lock no-error.
    vals[5] = vals[5] * txb.crchis.rate[1].
  end.
  
  bb = 0.
  do i = 1 to 5: bb = bb + vals[i]. end.
  
  if bb > 0 then do:
    
    create wrk.
    
    find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnsegm' no-lock no-error.
    if avail txb.sub-cod then wrk.segm = txb.sub-cod.ccode.
    else message " Не указан сегмент кредита, клиент " + txb.lon.cif + ", сс.счет " + txb.lon.lon view-as alert-box buttons ok title " Ошибка! ".
    
    wrk.bank = txb.cmp.name.
    wrk.cif = txb.lon.cif.
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then wrk.klname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
    else wrk.klname = "--не найден--".
    wrk.lon = txb.lon.lon.
    wrk.grp = txb.lon.grp.
    wrk.crc = txb.lon.crc.
    wrk.prem = txb.lon.prem.
    wrk.rdt = txb.lon.rdt.
    wrk.opnamt = txb.lon.opnamt.
    wrk.vyd_kzt = vals[1].
    wrk.pog_kzt = vals[2].
    wrk.nachprc_kzt = vals[3].
    wrk.polprc_kzt = vals[4].
    wrk.prol_kzt = vals[5].
    
    mesa = mesa + 1.
    if (mesa / 5) - integer (mesa / 5) = 0 then do:
       hide message no-pause.
       message ' ' + txb.cmp.name + ': обработано ' + string(mesa) + ' кредитов '.
    end.
    
  end. /* if bb > 0 */
  
end. /* for each txb.lon */