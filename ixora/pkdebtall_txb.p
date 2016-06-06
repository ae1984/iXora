/* pkdebtall_txb.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Задолженность по быстрым кредитам в разрезе
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
        08/09/2009 galina
 * BASES
        BANK TXB
 * CHANGES
        09/09/2009 galina - перекомпиляция
*/

def input parameter p-bank as char.

def shared var dates as date no-undo extent 3.

def shared temp-table  wrk no-undo
    field lon    like txb.lon.lon
    field cif    like txb.lon.cif
    field name   like txb.cif.name
    field rdt    like txb.lon.rdt
    field opnamt like txb.lon.opnamt /*сумма кредита*/
    field balans like txb.lon.opnamt /*остаток долга*/
    field crc    like txb.lon.crc
    field bal1   like txb.lon.opnamt /*просрочка ОД*/
    field dt_pros    as   inte /*дней просрочки ОД*/
    field bal2   like txb.lon.opnamt /*просрочка %*/
    field balpen   like txb.lon.opnamt /*пеня вся*/
    field bal13 as decimal
    field bal14 as decimal
    field bal30 as decimal
    /*field bal4 as decimal
    field bal5 as decimal*/
    field com_acc as decimal
    field year as integer /*год выдачи кредита*/
    field bank as char
    field guarant as char /*поручитель*/    
    field is-cl as logical
    field crccode as char 
    field dtrep as date  
    index main is primary bank year crc name
    index guar guarant.

define shared var g-today  as date.
    
def var bilance as decimal no-undo format "->,>>>,>>>,>>9.99".
def var dlong as date no-undo.
def var v-ankln as integer no-undo.
def var v-credtype as char no-undo.
def var datums as date no-undo.
def var counter as integer no-undo.

define var v-days_od as integer no-undo.
define var v-days_prc as integer no-undo.

do counter = 1 to 3:
  
  datums = dates[counter].
  for each txb.lon no-lock: 
        
    
     v-ankln = 0.
     for each pkanketa where pkanketa.bank = p-bank and pkanketa.cif = txb.lon.cif no-lock:
       if pkanketa.lon = txb.lon.lon then do:
         v-ankln = pkanketa.ln.
         v-credtype = pkanketa.credtype.
         leave.
       end.
     end.
     if v-ankln = 0 then next.

     find first pkanketa where pkanketa.bank = p-bank and pkanketa.credtype = v-credtype and pkanketa.ln = v-ankln no-lock no-error.
     
     find txb.cif where txb.cif.cif = txb.lon.cif no-lock.
        dlong = txb.lon.duedt.
        if txb.lon.ddt[5] <> ? then do:
          dlong = txb.lon.ddt[5].
          if txb.lon.ddt[5] > g-today then next.
        end.
        if txb.lon.cdt[5] <> ? then do:
          dlong = txb.lon.cdt[5].
          if txb.lon.cdt[5] > g-today then next.
        end.
                       
        find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
        create wrk.

        for each txb.bxcif where txb.bxcif.cif = txb.cif.cif and txb.bxcif.crc = txb.lon.crc no-lock:
          wrk.com_acc = wrk.com_acc + txb.bxcif.amount.
        end.
        
        run lonbalcrc_txb('lon',txb.lon.lon,datums,"1,7",no,txb.lon.crc,output bilance). /* остаток  ОД*/
        run lonbalcrc_txb('lon',txb.lon.lon,datums,"13",no,txb.lon.crc,output wrk.bal13).
        run lonbalcrc_txb('lon',txb.lon.lon,datums,"14",no,txb.lon.crc,output wrk.bal14).
        run lonbalcrc_txb('lon',txb.lon.lon,datums,"30",no,txb.lon.crc,output wrk.bal30).
        
        run lonbalcrc_txb('lon',txb.lon.lon,datums,"7",no,txb.lon.crc,output wrk.bal1).
        run lonbalcrc_txb('lon',txb.lon.lon,datums,"9,4",no,txb.lon.crc,output wrk.bal2).
        run lonbalcrc_txb('lon',txb.lon.lon,datums,"16,5",no,1,output wrk.balpen).

       
        run lndaysprf_txb(txb.lon.lon,datums, no, output v-days_od, output v-days_prc).
        assign wrk.cif = cif.cif
               wrk.lon = txb.lon.lon
               wrk.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name))
               wrk.rdt =  txb.lon.rdt
               wrk.opnamt = txb.lon.opnamt
               wrk.balans = bilance
               wrk.crc = txb.lon.crc
               wrk.guaran = trim(txb.loncon.rez-char[8]) 
               wrk.year = year(txb.lon.rdt)
               wrk.dtrep = datums
               wrk.bank = p-bank.
               if wrk.guaran = '' then wrk.guaran = 'нет'.
               if v-days_od > v-days_prc then wrk.dt_pros = v-days_od.
               else wrk.dt_pros = v-days_prc. 
  end.
end.
for each wrk where wrk.bal1 + wrk.bal2 + wrk.balpen + wrk.bal13 + wrk.bal14 + wrk.bal30 = 0:
  delete wrk.
end.
