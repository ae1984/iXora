/* VALM_ps.p
 * MODULE
        Валютный монитор        
 * DESCRIPTION
        Валютный монитор
 RUN
        Процесс платежной системы. Запускать ТОЛЬКО под Superman! 
 * CALLER
        стандартные для процессов
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        5.1
 * AUTHOR
        27.04.2004 tsoy
 * CHANGES
        04.10.2004 tsoy  изменил условия поиска swdt вместо ref теперь дата
*/

def temp-table tmp-out
field  remtrz     like remtrz.remtrz    
field  ccrc        like crc.code            
field  crc        like crc.crc            
field  sbank      like remtrz.sbank     
field  ord        like remtrz.ord       
field  rcbank     like remtrz.rcbank    
field  rbank      like remtrz.rbank    
field  valdt1     as date
field  amt        like remtrz.amt  
field  rtim       like remtrz.rtim  
field  stsl       as logical
field  sts        as char.


for each remtrz where remtrz.valdt1 >= v-clsday use-index valdt1 no-lock. 

       if lookup(remtrz.ptype,  "2,6,N") = 0 then  next. 

       find first que where que.remtrz = remtrz.remtrz no-lock no-error .

       if que.pid <> "SWS" then next.

         if avail que then do:
              find crc where crc.crc =  remtrz.tcrc no-lock no-error.
              if avail crc then v-crc = crc.code.
                 create tmp-out.
                 assign tmp-out.remtrz     = remtrz.remtrz   
                        tmp-out.ccrc       = trim(v-crc)        
                        tmp-out.crc        = remtrz.tcrc 
                        tmp-out.sbank      = remtrz.sbank    
                        tmp-out.ord        = remtrz.ord      
                        tmp-out.rcbank     = remtrz.rbank   
                        tmp-out.rbank      = remtrz.bn[1]
                        tmp-out.valdt1     = remtrz.valdt1  
                        tmp-out.amt        = remtrz.amt      
                        tmp-out.rtim       = remtrz.rtim.     

                        tmp-out.sts        = "предварительный".             
                        tmp-out.stsl       = false.             

                        for each swdt where swdt.rdt >= v-clsday - 3 exclusive-lock.

                        if index (swdt.ref, remtrz.remtrz) = 0 then next.

                          swdt.info[1] = remtrz.remtrz. 
                          
                          find first swhd where swhd.rdt >= v-clsday and swhd.swid = swdt.swid no-lock no-error.

                             if trim(swhd.type) = "940" or trim(swhd.type) = "950" then do:                                
                                tmp-out.sts        = "окончательный".             
                                tmp-out.stsl       = true.
                                release swdt.
                                leave.
                             end. 

                             if trim(swhd.type) = "942" then do:
                                tmp-out.sts        = "расчитан по 942".             
                                tmp-out.stsl       = false.
                                release swdt. 
                             end. 
                        end.

        end.

end.

for each tmp-out break by tmp-out.crc by tmp-out.rcbank by tmp-out.stsl.
     
         accumulate tmp-out.amt  (total by tmp-out.crc by tmp-out.rcbank by tmp-out.stsl).

         if last-of (tmp-out.stsl) then do:
             if not tmp-out.stsl then do:
                  find first tmp-bal where tmp-bal.crc = tmp-out.crc 
                                           and tmp-bal.bank = tmp-out.rcbank no-error.
                  if avail tmp-bal then do: 
                         tmp-bal.dam-amt = accum total by (tmp-out.stsl) tmp-out.amt. 
                  end.
             end.
         end.
end.

