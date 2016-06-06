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

def  shared temp-table wrk2 no-undo
   field lon as char
   field days as int
   field counts as int
   index idx is primary days.


def var v-bal7 as deci no-undo init 0.
def var p-coun as integer no-undo.
def var fdt as date no-undo.
def var dayc1 as integer no-undo.

if trim (v-iin) <> "" then do:
   for each txb.cif where txb.cif.bin = v-iin no-lock:
       for each txb.lon where txb.lon.cif = txb.cif.cif no-lock:
         fdt = ?.
         dayc1 = 0.
         p-coun = 0.
         for each txb.lonres where txb.lonres.lon = txb.lon.lon no-lock use-index jdt:
             if txb.lonres.lev <> 7 then next.
             if txb.lonres.dc = 'd' then do:
               if v-bal7 = 0 and txb.lonres.amt > 0 then do:
                 p-coun = p-coun + 1.
                 fdt = txb.lonres.jdt.
               end.
               v-bal7 = v-bal7 + txb.lonres.amt.
             end.
             else do:
               v-bal7 = v-bal7 - txb.lonres.amt.
               if v-bal7 <= 0 then do:
                 v-bal7 = 0.
                 dayc1 = txb.lonres.jdt - fdt.
               end.
             end.
         end. /* for each lonres */
         create wrk2.
         assign
         wrk2.lon = txb.lon.lon
         wrk2.counts = p-coun
         wrk2.days = dayc1.
       end.
   end.
end.



