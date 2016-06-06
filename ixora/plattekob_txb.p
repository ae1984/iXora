/* .p
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
        30.03.2013 evseev
 * BASES
        COMM TXB
 * CHANGES
*/
def  shared var v-iin as char no-undo.

def  shared temp-table wrk no-undo
   field dt as date
   field od as deci
   field prc as deci
   field koms as deci
   index idx is primary dt.

if trim (v-iin) <> "" then do:
   for each txb.cif where txb.cif.bin = v-iin no-lock:
       for each txb.lon where lon.cif = txb.cif.bin no-lock:
           for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0 and txb.lnsch.f0 > 0 no-lock:
               find first wrk where wrk.dt = txb.lnsch.stdat exclusive-lock no-error.
               if not avail wrk then do:
                   create wrk.
                   wrk.dt = txb.lnsch.stdat.
               end.
               wrk.od = wrk.od + txb.lnsch.stval.
           end.

           for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0 and txb.lnsci.f0 > 0 no-lock:
               find first wrk where wrk.dt = txb.lnsci.idat exclusive-lock no-error.
               if not avail wrk then do:
                   create wrk.
                   wrk.dt = txb.lnsci.idat.
               end.
               wrk.prc = wrk.prc + txb.lnsci.iv-sc.
           end.

           for each txb.lnscs where txb.lnscs.lon = txb.lon.lon and txb.lnscs.sch no-lock:
               find first wrk where wrk.dt = txb.lnscs.stdat exclusive-lock no-error.
               if not avail wrk then do:
                   create wrk.
                   wrk.dt = txb.lnscs.stdat.
               end.
               wrk.koms = wrk.koms + txb.lnscs.stval.
           end.
       end.
   end.
end.