/* pkfizport1.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Анализ кредитного потрфеля физ.лиц для управленческой
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
        BANK TXB
 * CHANGES
        27/10/2009 galina - отчет только по физ.лицам
*/
def input parameter p-bank as char.
def var counter as integer no-undo.
def var bdat as date no-undo.
def var bilance as decimal no-undo.
def shared var dates as date no-undo extent 4.
/*кредитный потфель*/
def shared temp-table pkport
  field sum as decimal
  field amt as integer
  field bank as char.
  
/*выданные кредиты*/
def shared temp-table pkvyd
  field dt as date
  field sum as decimal
  field amt as integer
  field bank as char.
    
create pkport.
pkport.bank = p-bank.

do counter = 1 to 4:
  bdat = dates[counter].
  create pkvyd.
  pkvyd.bank = p-bank.   
  pkvyd.dt = bdat.
  for each txb.lon no-lock:
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.
    if txb.cif.type = 'b' then next.
    run lonbalcrc_txb('lon', txb.lon.lon, bdat, "1,7", no, txb.lon.crc, output bilance).
    if bilance <= 0 then do:
      find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 and txb.lnscg.stdat < bdat no-lock no-error.
      if not avail txb.lnscg then next.
    end.
    if counter = 1 then do:
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < bdat no-lock no-error.      
      pkport.sum = pkport.sum + bilance * txb.crchis.rate[1].
      if bilance > 0 then pkport.amt = pkport.amt + 1.
    end.
    if txb.cif.type <> 'b' and counter < 4 then do:
        for each txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 and (txb.lnscg.stdat < dates[counter] and txb.lnscg.stdat >= dates[counter + 1]) no-lock:
          find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < dates[1] no-lock no-error.
          pkvyd.sum = pkvyd.sum + txb.lnscg.paid * txb.crchis.rate[1].
          pkvyd.amt = pkvyd.amt + 1.
        end.
    end.
  end. /*for each txb.lon*/  
end. /*counter*/    