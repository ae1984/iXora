/* vm-second.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
        03.09.2004 Если платеж прошел по выписке вчера или еще позднее то в список он не попадает.
*/

{vm-lib.i}
def temp-table tmp-in
     field remtrz like remtrz.remtrz    
     field ccrc   like crc.code
     field crc    like crc.crc
     field sbank  like remtrz.sbank  
     field ord    like remtrz.ord    
     field rcbank like remtrz.rcbank 
     field rbank  like remtrz.rbank  
     field valdt1 as date
     field amt    like remtrz.amt 
     field rtim   like remtrz.rtim
     field sts    as char
     field stsl   as logical.

 def buffer b-swdt for swdt.
 def var v-is-complite as logical.
 def var v-is-delete   as logical.


for each remtrz where remtrz.valdt1 > v-clsday  use-index valdt1 no-lock break by remtrz.tcrc by remtrz.sbank by remtrz.amt.
       
         if lookup(remtrz.ptype,  "5,7") = 0 then  next. 
         if remtrz.tcrc = 1 then next.  

              find crc where crc.crc = remtrz.tcrc no-lock no-error.
              if avail crc then v-crc = crc.code.

            create tmp-in.
            assign tmp-in.remtrz = remtrz.remtrz 
                   tmp-in.ccrc   = trim(v-crc)      
                   tmp-in.crc    = remtrz.tcrc      
                   tmp-in.sbank  = remtrz.sbank  
                   tmp-in.ord    = remtrz.ord    
                   tmp-in.rcbank = remtrz.rcbank 
                   tmp-in.rbank  = remtrz.bn[1]  
                   tmp-in.valdt1 = remtrz.valdt1  
                   tmp-in.amt    = remtrz.amt    
                   tmp-in.rtim   = remtrz.rtim.  


            v-is-complite = no.
            v-is-delete   = no.

            find que where que.remtrz = remtrz.remtrz no-lock no-error.

            /* if avail que and lookup(que.pid,  "F,ARC,2L") > 0  then 
                       v-is-complite = true. */

            for each swdt where swdt.rdt >= v-clsday - 3 exclusive-lock.

                if  index(AllSpaceDelete(remtrz.sqn), AllSpaceDelete (swdt.ref)) = 0 then next.
                 
                find first swhd where swhd.swid = swdt.swid no-lock no-error.

                if lookup (swhd.type, "940,950") = 0 then next.
                if swhd.f62dt < g-today  then v-is-delete = true.

                find first dfb where dfb.nostroacc = swhd.acc no-lock no-error.
                if avail dfb then do:
                   find first bankt where bankt.acc = dfb.dfb 
                           and bankt.aut = true no-lock no-error.

                   if avail bankt then do:                 
                      if remtrz.sbank = bankt.cbank then do:
                         v-is-complite = true.
                         swdt.info[1] = remtrz.remtrz. 
                         leave.
                      end.
                   end.

                end.
                release swdt.
            end.

            if not v-is-complite then do: 
                   for each b-swdt where b-swdt.rdt >= v-clsday - 2 exclusive-lock .

                       if index(AllSpaceDelete(remtrz.sqn), AllSpaceDelete(b-swdt.ref2)) = 0 then next.

                       find first swhd where swhd.swid = b-swdt.swid no-lock no-error.
                       if lookup (swhd.type, "940,950") = 0 then next.

                       if swhd.f62dt < g-today  then v-is-delete = true.

                       find first dfb where dfb.nostroacc = swhd.acc no-lock no-error.
                       if avail dfb then do:
                          find first bankt where bankt.acc = dfb.dfb 
                                  and bankt.aut = true no-lock no-error.

                          if avail bankt then do:                 
                             if remtrz.sbank = bankt.cbank then do:
                                v-is-complite = true.
                                b-swdt.info[1] = remtrz.remtrz. 
                                leave.
                             end.
                          end.

                       end.
                       release b-swdt.
                   end.
              end.

            
            if v-is-complite then do:
                   tmp-in.sts     = "окончательный".  
                   tmp-in.stsl    = true.  
            end.
            else do:
                   tmp-in.sts   = "предварительный".             
                   tmp-in.stsl  = false.             
            end.
            /*прошел по выписке вчера - удаляем */
            if (tmp-in.valdt1 < g-today and  v-is-complite) or v-is-delete then delete tmp-in.

end.

for each tmp-in break by tmp-in.crc by tmp-in.sbank by tmp-in.stsl.
     
         accumulate tmp-in.amt  (TOTAL by tmp-in.crc by tmp-in.sbank by tmp-in.stsl).

         if last-of (tmp-in.stsl) then do:
           if not tmp-in.stsl then do:
                find first tmp-bal where tmp-bal.crc = tmp-in.crc 
                                         and tmp-bal.bank = tmp-in.sbank no-error.
                if avail tmp-bal then tmp-bal.cam-amt = accum total by (tmp-in.stsl) tmp-in.amt. 
           end.
         end.
end.


