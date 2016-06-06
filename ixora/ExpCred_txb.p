/* ExpCred_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        11/11/2013 Luiza ТЗ 1932
 * BASES
        COMM TXB
 * CHANGES
*/

def shared var vv-iin as char no-undo.
def shared temp-table wrk3 no-undo
   field dt as date
   field od as deci
   field prc as deci
   field koms as deci
   field crc as int
   field codcontr as char /* код контракта*/
   field bank as char /* код банка*/
   index idx is primary codcontr.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
def var v-bal1 as decim.

if trim (vv-iin) <> "" then do:
   for each txb.cif where txb.cif.bin = vv-iin no-lock:
       for each txb.lon where txb.lon.cif = txb.cif.cif no-lock:
            v-bal1 = 0.
            run lonbalcrc_txb('lon',txb.lon.lon,today,"1,2,7,9,49,50",no,txb.lon.crc,output v-bal1).
            if  v-bal1 <= 0 then next.
            find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0 and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= today no-lock no-error.
           if available txb.lnsch then do:
               find first wrk3 where wrk3.codcontr = substring(trim(txb.sysc.chval),3,2) + trim(txb.lon.lon) exclusive-lock no-error.
               if not avail wrk3 then do:
                   create wrk3.
                   wrk3.bank = txb.sysc.chval.
                   wrk3.codcontr = /*substring(trim(txb.sysc.chval),3,2) +*/ trim(txb.lon.lon).
                   wrk3.crc = txb.lon.crc.
                   wrk3.dt = txb.lnsch.stdat.
               end.
               wrk3.od = wrk3.od + txb.lnsch.stval.
           end.

           find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0 and txb.lnsci.f0 > 0 and txb.lnsci.idat >= today no-lock no-error.
           if available txb.lnsci then do:
               find first wrk3 where wrk3.codcontr = substring(trim(txb.sysc.chval),3,2) + trim(txb.lon.lon) exclusive-lock no-error.
               if not avail wrk3 then do:
                   create wrk3.
                   wrk3.bank = txb.sysc.chval.
                   wrk3.codcontr = /*substring(trim(txb.sysc.chval),3,2) +*/ trim(txb.lon.lon).
                   wrk3.crc = txb.lon.crc.
                   wrk3.dt = txb.lnsci.idat.
               end.
               wrk3.prc = wrk3.prc + txb.lnsci.iv-sc.
           end.

           find first txb.lnscs where txb.lnscs.lon = txb.lon.lon and txb.lnscs.sch and txb.lnscs.stdat >= today no-lock no-error.
           if available txb.lnscs then do:
               find first wrk3 where wrk3.codcontr = substring(trim(txb.sysc.chval),3,2) + trim(txb.lon.lon) exclusive-lock no-error.
               if not avail wrk3 then do:
                   create wrk3.
                   wrk3.bank = txb.sysc.chval.
                   wrk3.codcontr = /*substring(trim(txb.sysc.chval),3,2) +*/ trim(txb.lon.lon).
                   wrk3.crc = txb.lon.crc.
                   wrk3.dt = txb.lnscs.stdat.
               end.
               wrk3.koms = wrk3.koms + txb.lnscs.stval.
           end.
       end.
   end.
end.