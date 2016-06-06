/* vm-four.i
 * MODULE

 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-1
 * AUTHOR
        07.06.05 tsoy
 * CHANGES
        07.06.05 исключил платежи с будущей датой валютирования
*/

def temp-table tmp-out2
    field remtrz  like  remtrz.remtrz  
    field pid     like  que.pid       
    field crc     like  crc.crc         
    field ccrc    like  crc.code         
    field ord     like  remtrz.ord    
    field dracc   like  remtrz.dracc  
    field amt     like  remtrz.amt
    field valdt   like  remtrz.valdt1.



for each remtrz where remtrz.valdt1 >= g-today use-index valdt1 no-lock.
 if lookup(remtrz.ptype,  "2,6,N") = 0 then  next. 
 if remtrz.tcrc = 1 then next.  
 if remtrz.valdt1 <> g-today then next.  
        find first que where que.remtrz = remtrz.remtrz 
                              and lookup(que.pid,"O,G,3G,3A") >0
                     no-lock no-error .
         if avail que then do:
              find crc where crc.crc = remtrz.tcrc no-lock no-error.

              if avail crc then v-crc = crc.code.
               create tmp-out2.
                   assign tmp-out2.remtrz = remtrz.remtrz  
                          tmp-out2.pid    = que.pid       
                          tmp-out2.crc    = remtrz.tcrc         
                          tmp-out2.ccrc   = trim(v-crc)         
                          tmp-out2.ord    = remtrz.ord    
                          tmp-out2.dracc  = remtrz.dracc  
                          tmp-out2.amt    = remtrz.amt
                          tmp-out2.valdt  = remtrz.valdt1.
         end.
end.

