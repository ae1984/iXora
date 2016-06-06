/* r-trar1.p
 * MODULE
        Отчет по ARP
 * DESCRIPTION
        Консолидированный отчет по счетам ARP в инвалюте по счетам ГК: 179300
        179900 185600 186700 (профит центр ДВО)     
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
        21.09.2006 u00777
 * CHANGES        
*/

def shared var v-dt1 as date format "99/99/9999". 
def shared var v-dt2 as date format "99/99/9999".
def shared var v-gl1 as character. 


def input parameter v-name as char.
def var v-crc1 as char format "x(3)" no-undo.
def var v-crc2 as integer no-undo.
def var v-sub1 as char format "x(3)" no-undo.
def var v-r as char no-undo.
def buffer jla for txb.jl.
def buffer b-arp for txb.arp.
pause 0.
displ v-name format "x(25)" label "Филиал " with centered side-label.

def shared temp-table t-arp no-undo
  field jdt like txb.jl.jdt
  field jh like txb.jl.jh 
  field dam like txb.jl.dam
  field cam like txb.jl.cam
  field who like txb.jl.who
  field acc like txb.jl.acc 
  field acc2 like txb.jl.acc 
  field rem as character
  field fil as character 
  field pr as integer
  field code like txb.crc.code
  field ost like txb.jl.cam
  field gl like txb.arp.gl
  field crc like txb.jl.crc
  field subled like txb.jl.subled.                      
for each txb.arp no-lock: 
   if lookup(substring(trim(string(txb.arp.gl)),1,4), v-gl1) ne 0 and 
      txb.arp.crc ne 1 then do:     
      for each txb.jl  where txb.jl.acc eq txb.arp.arp and txb.jl.gl eq txb.arp.gl and
               txb.jl.jdt ge v-dt1 and txb.jl.jdt le v-dt2 no-lock break by txb.jl.acc: 
  
            if first-of(txb.jl.acc)
            then do:
               create t-arp.               
               assign 
                      v-crc1 = ""
                      t-arp.fil = v-name
                      t-arp.pr = 0
                      t-arp.rem = trim(txb.arp.des)                       
                      t-arp.acc = txb.jl.acc
                      t-arp.gl = txb.arp.gl
                      t-arp.jdt = txb.jl.jdt                                                    
                      t-arp.jh = txb.jl.jh.
               find txb.crc where txb.crc.crc = txb.arp.crc no-lock no-error.
               if avail txb.crc then do:
                  assign v-crc1 = txb.crc.code    
                         v-crc2 = txb.crc.crc
                         t-arp.code = v-crc1
                         t-arp.crc = v-crc2.
               end.                         
              find last txb.histrxbal  where txb.histrxbal.subled = 'arp' and txb.histrxbal.acc = txb.arp.arp and 
                                       txb.histrxbal.level = txb.jl.lev and txb.histrxbal.crc = txb.jl.crc and txb.histrxbal.dt < v-dt1  
                                       no-lock no-error.
              
              if avail txb.histrxbal  then
                 t-arp.ost = round(absolute(txb.histrxbal.dam - txb.histrxbal.cam),2).
           end.                                                       
          if last-of(txb.jl.acc)
          then do:         
              create t-arp.
              assign t-arp.pr = 2
                     t-arp.fil = v-name
                     t-arp.code = v-crc1
                     t-arp.acc = txb.jl.acc
                     t-arp.crc = v-crc2
                     t-arp.jdt = txb.jl.jdt                                       
                     t-arp.gl = txb.arp.gl
                     t-arp.jh = txb.jl.jh.
              find last txb.histrxbal  where txb.histrxbal.subled = 'arp' and txb.histrxbal.acc = txb.arp.arp and 
                                       txb.histrxbal.level = txb.jl.lev and txb.histrxbal.crc = txb.jl.crc and txb.histrxbal.dt <= v-dt2  
                                       no-lock no-error.
              if avail txb.histrxbal   then                     
                  t-arp.ost = round(absolute(txb.histrxbal.dam - txb.histrxbal.cam),2).             
          end.            

           create t-arp.
           assign t-arp.jdt = txb.jl.jdt
                  t-arp.jh = txb.jl.jh
                  t-arp.dam = txb.jl.dam
                  t-arp.cam = txb.jl.cam
                  t-arp.who = txb.jl.who
                  t-arp.fil = v-name 
                  t-arp.pr = 1
                  t-arp.code  = v-crc1
                  t-arp.acc = txb.jl.acc
                  t-arp.crc = v-crc2
                  t-arp.gl = txb.arp.gl
                  t-arp.rem = ""
                  v-sub1 = ""
                  v-r = "".

          /*Определение корр. счета*/            
          find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
          v-r = entry(1,txb.jh.ref).
          case txb.jh.sub: 
             when "RMZ" then do:
                  find txb.remtrz where txb.remtrz.remtrz = v-r no-lock no-error.
                  if avail remtrz then do:
                    if txb.jl.dc = "D" then 
                       assign t-arp.acc2 = txb.remtrz.rbank
                              t-arp.subled = txb.remtrz.ba
                              t-arp.rem = trim(txb.remtrz.bn[1]).             
                    else 
                       assign t-arp.acc2 = txb.remtrz.dracc
                              t-arp.rem  = trim(txb.remtrz.ordins[1]).
                  end.        
              end.
              when "JOU" then do:               
                   find txb.joudoc where txb.joudoc.docnum = v-r no-lock no-error.
                   if avail txb.joudoc then do:
                      if txb.jl.dc = "D"
                         then t-arp.acc2 = txb.joudoc.cracc.
                      else t-arp.acc2 = txb.joudoc.dracc.
                   end.
              end.            
              when "UJO" then do:
                  find last txb.ujo where txb.ujo.docnum = v-r no-lock no-error.
                  if avail txb.ujo then
                  do:
                     if txb.jl.dc = "D"
                     then t-arp.acc2 = txb.ujo.cracc.
                     else t-arp.acc2 = txb.ujo.dracc.
                  end.
              end.
           end case.
      
           if  t-arp.acc2 = "" or t-arp.rem = "" then do:
          /*Определение корр. счета*/             
             if txb.jl.dc = 'D' then do:          
               for each jla where jla.jh = txb.jl.jh  and jla.dc = 'C' no-lock:
                 if avail jla and txb.jl.dam = jla.cam and jla.crc = txb.jl.crc and jl.jdt = jla.jdt then do:
                    if jla.acc = "" then do:            
                       if t-arp.acc2 = "" then t-arp.acc2 = string(jla.gl,"999999").
                       v-sub1 = "".
                    end.
                     else do:
                       if t-arp.acc2 = "" then t-arp.acc2 = jla.acc.
                        v-sub1 = jla.subled.                                          
                     end.   
                   leave.
                 end. 
               end. 
             end.   
             else do:
               for each jla where jla.jh = txb.jl.jh  and jla.dc = 'D' no-lock:
                  if avail jla and txb.jl.cam = jla.dam and jla.crc = txb.jl.crc and
                      txb.jl.jdt = jla.jdt then do:
                     if jla.acc = "" then do:                               
                        if t-arp.acc2 = "" then
                           t-arp.acc2 = string(jla.gl,"999999").
                        v-sub1 = "".
                     end.
                     else do:
                        if t-arp.acc2 = "" then t-arp.acc2 = jla.acc.                   
                        v-sub1 = jla.subled.
                     end.
                   leave.     
                  end. 
               end. 
             end.                                            
          /*Определение наименования корр.счета*/
             case v-sub1:
              when "ARP" then do:
                   find b-arp where b-arp.arp = t-arp.acc2 no-lock no-error.
                   if avail b-arp then do:
                      assign t-arp.rem = trim(b-arp.des).
                             t-arp.subled = v-sub1.  
                    end.
              end. 
              when "CIF" then do:
                  find txb.aaa where txb.aaa.aaa = t-arp.acc2 no-lock no-error.
                  if avail txb.aaa then do:
                     find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                     if avail txb.cif then
                        t-arp.rem = trim(txb.cif.name).
                    end.

                 end.
                          
               when "DFB" then do:
                     find txb.dfb where txb.dfb.dfb = t-arp.acc2 no-lock no-error.
                     if avail txb.dfb then do:
                        assign t-arp.rem = trim(txb.dfb.name)
                               t-arp.subled = v-sub1.   
                     end.  
               end.
               when "EPS" then do:   
                     find txb.eps where txb.eps.eps = t-arp.acc2 no-lock no-error.
                     if avail txb.eps then
                     t-arp.rem = trim(txb.eps.des).

               end.
               when "AST" then do:
                     find txb.ast where txb.ast.ast = t-arp.acc2 no-lock no-error.
                     if avail txb.ast then           
                        t-arp.rem = trim(txb.ast.name).

               end.                                               
               otherwise do:
                 find txb.gl where txb.gl.gl = jla.gl no-lock no-error.
                     if avail txb.gl then
                        t-arp.rem = trim(txb.gl.des).
                 end.               
           end case.     
        end.              
        t-arp.rem = trim(t-arp.rem) + "<br>" + trim(txb.jl.rem[1]) + " " + trim(txb.jl.rem[2]) + " " +
                            trim(txb.jl.rem[3]) + " " + trim(txb.jl.rem[4]).                     
      end. 
   end.
end.

 
 
