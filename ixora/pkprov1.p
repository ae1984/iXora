/* pkprov1.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Динамика прироста портфеля потреб.кредитов и провизий для управленческой
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
def var v-output as deci  no-undo.
def shared var dates as date no-undo extent 3.
/*кредитный потфель*/
def shared temp-table pkport
  field dt as date
  field sum as decimal
  field amt as integer
  field bank as char.
  
/*провизии*/
def shared temp-table pkprov
  field dt as date
  field sum as decimal
  field amt as integer
  field bank as char.
    

do counter = 1 to 3:
  bdat = dates[counter].
  create pkprov.
  pkprov.bank = p-bank.   
  pkprov.dt = bdat.
  
  create pkport.
  pkport.bank = p-bank.
  pkport.dt = bdat.

  for each txb.lon no-lock:
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.
    if txb.cif.type <> 'p' then next. 
    run lonbalcrc_txb('lon', txb.lon.lon, bdat, "1,7", no, txb.lon.crc, output bilance).
    if bilance <= 0 then do:
      find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 and txb.lnscg.stdat < bdat no-lock no-error.
      if not avail txb.lnscg then next.
    end.
    
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < dates[1] no-lock no-error.      
    
    pkport.sum = pkport.sum + bilance * txb.crchis.rate[1].
    if bilance > 0 then pkport.amt = pkport.amt + 1.

    /*if txb.cif.type = 'p' then do: */
        run lonbalcrc_txb('lon',txb.lon.lon,bdat,"3,6",no,txb.lon.crc,output v-output).
        pkprov.sum = pkprov.sum + v-output * txb.crchis.rate[1] * (-1).
    /*end.*/
    
  end. /*for each txb.lon*/  
end. /*counter*/    