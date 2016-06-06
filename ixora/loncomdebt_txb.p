/*loncomdebt_txb.p
 * MODULE
       Кредиты 
 * DESCRIPTION
        Задолженность по комиссии за ведение счета по рефинансированным и конвертированным кредитам (в разрезе филиалов)
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
        13/03/2009 galina
 * BASES
        BANK TXB COMM
 * CHANGES
        16/03/2009 galina - убрала global.i
*/


def input parameter p-dt as date.
def input parameter p-bank as char.
def input parameter p-city as char.

def shared temp-table t-com
  field cif like txb.lon.cif
  field name as char
  field crc like txb.crc.code
  field com as deci
  field com_kzt as deci
  field lon like txb.lon.lon
  field lontype as char
  field city as char.

FOR EACH txb.lon where txb.lon.crc <> 1 no-lock : 
  if lookup(string(txb.lon.grp),'90,92') = 0 then next.

  if txb.lon.sts =  "C" then do:
     find last txb.lonres where txb.lonres.lon = txb.lon.lon use-index jdt no-lock no-error.
     if not avail txb.lonres then next.
     if txb.lonres.jdt < p-dt then next.
  end.   

  find first pkanketa where pkanketa.bank = p-bank and pkanketa.lon = txb.lon.lon no-lock no-error.
  if not avail pkanketa then next.
  
  find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.stdat <= p-dt and txb.lnscg.flp > 0  no-lock no-error.
  if not avail txb.lnscg then next.
  
  find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
  
  create t-com.
  t-com.cif = txb.lon.cif.
  t-com.lon = txb.lon.lon.
  t-com.crc = txb.crc.code. 
  t-com.city = p-city.
  t-com.name = pkanketa.name.
  
  if txb.lon.opnamt > txb.lnscg.stval and (txb.lnscg.who = 'id00049' or txb.lnscg.who = 'id00027') then t-com.lontype = 'Конвертированный'.
  
  
  for each txb.bxcif where txb.bxcif.cif = txb.lon.cif and txb.bxcif.crc = txb.lon.crc no-lock:
      t-com.com = t-com.com + bxcif.amount.
  end.

  for each txb.bxcif where txb.bxcif.cif = txb.lon.cif and txb.bxcif.crc = 1 no-lock:
     t-com.com_kzt = t-com.com_kzt + txb.bxcif.amount.
  end.

END.   