/* pcarpostrep_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Сверка остатков по консолидированным счетам ДПК в системе AВС iXora и OpenWay
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
        12/08/2013 galina ТЗ 1628
 * BASES
        BANK COMM TXB
 * CHANGES
*/

define shared var g-today  as date.

def input parameter p-dtabc as date no-undo.
def input parameter p-dtow as date no-undo.
def input parameter p-bank as char no-undo.
def shared temp-table t-rep no-undo
   field bank as char
   field dateow as date
   field dateabc as date
   field dateload as date
   field arp as char
   field crccode as char
   field sumow as deci
   field sumabc as deci
   field sumdef as deci
   field arpval as int
   index bank is primary arpval bank.


function get_amt returns deci (p-acc as char, p-gl as integer, p-lev as integer, p-dt as date, p-sub as char, p-crc as integer).
  def var v-amt as deci.
  v-amt = 0.
  if p-dt < g-today then do:
      find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = p-lev and txb.histrxbal.crc = p-crc and txb.histrxbal.dt <= p-dt  no-lock no-error.
      if avail txb.histrxbal then do:
          find txb.gl where txb.gl.gl  = p-gl no-lock no-error.

          if avail txb.gl then do:
              if txb.gl.type eq "A" or txb.gl.type eq "E" then  v-amt = txb.histrxbal.dam - txb.histrxbal.cam.
              else v-amt = txb.histrxbal.cam - txb.histrxbal.dam.
          end.
      end.
  end.
  if p-dt = g-today then do:
      find first txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc and txb.trxbal.level = p-lev and txb.trxbal.crc = p-crc no-lock no-error.
      if avail txb.trxbal then do:
          find txb.gl where txb.gl.gl  = p-gl no-lock no-error.
          if avail txb.gl then do:
              if txb.gl.type eq "A" or txb.gl.type eq "E" then v-amt = txb.trxbal.dam - txb.trxbal.cam.
              else v-amt = txb.trxbal.cam - txb.trxbal.dam.
          end.
      end.

  end.
  return v-amt.
end.

for each pcarpsum where pcarpsum.bank = p-bank and pcarpsum.dtost = p-dtow no-lock:
    find first txb.crc where txb.crc.crc = pcarpsum.crc no-lock no-error.
    find first txb.arp where txb.arp.arp = pcarpsum.arp no-lock no-error.
    if not avail txb.arp then do:
        create t-rep.
        assign t-rep.bank = p-bank
               t-rep.dateow = pcarpsum.dtost
               t-rep.dateload = pcarpsum.rwhn
               t-rep.arp = pcarpsum.arp
               t-rep.sumow =  abs(pcarpsum.outbal)
               t-rep.arpval = 2.

        if avail txb.crc then t-rep.crccode = txb.crc.code.

    end.
    else do:
        create t-rep.
        assign t-rep.bank = p-bank
               t-rep.dateow = pcarpsum.dtost
               t-rep.dateabc = p-dtabc
               t-rep.dateload = pcarpsum.rwhn
               t-rep.arp = pcarpsum.arp
               t-rep.sumow =  abs(pcarpsum.outbal)
               t-rep.sumabc = get_amt(txb.arp.arp,txb.arp.gl,1,p-dtabc, "arp", txb.arp.crc)
               t-rep.sumdef = t-rep.sumabc - t-rep.sumow
               t-rep.arpval = 1.
        if avail txb.crc then t-rep.crccode = txb.crc.code.

    end.
end.
if p-bank = 'TXB00' then do:
   for each pcarpsum where pcarpsum.bank = '' and pcarpsum.dtost = p-dtow no-lock:
       find first txb.crc where txb.crc.crc = pcarpsum.crc no-lock no-error.
       find first txb.arp where txb.arp.arp = pcarpsum.arp no-lock no-error.

       create t-rep.
       assign t-rep.dateow = pcarpsum.dtost
              t-rep.dateload = pcarpsum.rwhn
              t-rep.arp = replace(replace(pcarpsum.arp,'<','&lt;'),'>','&gt;')
              t-rep.sumow =  abs(pcarpsum.outbal)
              t-rep.arpval = 2.

       if avail txb.crc then t-rep.crccode = txb.crc.code.

  end.

end.