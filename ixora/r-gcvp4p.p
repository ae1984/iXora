/* r-gcvp4p.p
 * MODULE
        отчеты по ГЦВП - выплата пенсий и пособий
 * DESCRIPTION
        Акты сверок Период указывается с ... по ... включительно!!! 
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        BANK COMM TXB 
 * AUTHOR
        22.08.08  marinav
 * CHANGES
        18/12/08  marinav - в исключения добавлен 011
        10/02/09 marinav - добавлено деление кода 091 txb.jl.rem[1] matches '*из PБ*'
*/

def input parameter v-bank as char.
def input parameter v-sel as char.

def shared var v-dtb as date.
def shared var v-dte as date.

def shared temp-table wrk
             field bank as char
             field type as inte
             field sum1 as deci  
             field sum2 as deci  
             field sum3 as deci  
             field sum4 as deci  
             field sum5 as deci.  


def var v-isk   as char init '011'.     
def var v-gf    as char init '027,046,048,091,096'.       /* выплаты из ГФСС акт 1*/
def var v-vozrb as char init ''.                          /* возвраты акт 1 на РБ - не отражать в акте */
def var v-vozgf as char init '028,047,049,092,097'.       /* возвраты акт 1 в ГФСС */
def var v-sem   as char init '090'.                       /* семипалатинск акт 2*/
def var v-ud    as char init '020'.                       /* удержания акт 3*/
def var v-kod   as char .

/*перечислено sum2 */
/*
if v-bank = 'TXB00' then do:
   for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte and txb.jl.acc = '004904440' and txb.jl.dc = 'C' no-lock.
       find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
       find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
       if avail txb.sub-cod and lookup(entry(3,txb.sub-cod.rcode), v-gf) = 0 then do:
             find first wrk where wrk.type = 1. 
             wrk.sum2 = wrk.sum2 + txb.jl.cam.
       end.
       if avail txb.sub-cod and lookup(entry(3,txb.sub-cod.rcode), v-gf) > 0 then do:
             find first wrk where wrk.type = 2. 
             wrk.sum2 = wrk.sum2 + txb.jl.cam.
       end.
   end.
end.
*/


if v-sel = '1' then do:

     if v-bank = 'TXB00' then do:
         find last txb.histrxbal where txb.histrxbal.sub = 'arp' and txb.histrxbal.acc = '004904440' and txb.histrxbal.lev = 1 and txb.histrxbal.dt <= v-dtb no-lock no-error.
         if avail txb.histrxbal then do:
                find first wrk where wrk.type = 1. 
                wrk.sum1 = wrk.sum1 + txb.histrxbal.cam - txb.histrxbal.dam.
         end.
         find last txb.histrxbal where txb.histrxbal.sub = 'arp' and txb.histrxbal.acc = '004904440' and txb.histrxbal.lev = 1 and txb.histrxbal.dt <= v-dte no-lock no-error.
         if avail txb.histrxbal then do:
                find first wrk where wrk.type = 1. 
                wrk.sum5 = wrk.sum5 + txb.histrxbal.cam - txb.histrxbal.dam.
         end.
     end.

     for each txb.aaa where txb.aaa.lgr = '246' no-lock.
                                        
         for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte and txb.jl.acc = txb.aaa.aaa no-lock .

             v-kod = "".
             if txb.jl.dc = 'C' then do:  /*выплачено sum4*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:               
                    v-kod = entry(3,txb.sub-cod.rcode).
                    if lookup(v-kod, v-gf) = 0 and v-kod ne v-sem and v-kod ne v-ud and v-kod ne v-isk then do:
                      find first wrk where wrk.type = 1. 
                      wrk.sum2 = wrk.sum2 + txb.jl.cam.
                      wrk.sum4 = wrk.sum4 + txb.jl.cam.
                    end.
                    if lookup(v-kod, v-gf) > 0 then do:
                      if v-kod = '091' and txb.jl.rem[1] matches '*из PБ*' then find first wrk where wrk.type = 1. 
                                                                           else find first wrk where wrk.type = 2. 
                         wrk.sum2 = wrk.sum2 + txb.jl.cam.
                         wrk.sum4 = wrk.sum4 + txb.jl.cam.
                    end. 
                end.
                if not avail txb.sub-cod then do:
                   find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.codfr = "spnpl" no-lock no-error.
                   if avail txb.trxcods then do:
                      v-kod = txb.trxcods.code.
                      if lookup(v-kod, v-gf) = 0 and v-kod ne v-sem and v-kod ne v-ud and v-kod ne v-isk then do:
                         find first wrk where wrk.type = 1. 
                         wrk.sum2 = wrk.sum2 + txb.jl.cam.
                         wrk.sum4 = wrk.sum4 + txb.jl.cam.
                      end.
                      if lookup(v-kod, v-gf) > 0  then do:
                      if v-kod = '091' and txb.jl.rem[1] matches '*из PБ*' then find first wrk where wrk.type = 1. 
                                                                           else find first wrk where wrk.type = 2. 
                         wrk.sum2 = wrk.sum2 + txb.jl.cam.
                         wrk.sum4 = wrk.sum4 + txb.jl.cam.
                      end.
                   end.
                end.     
             end.
             else do:                     /*возвращено sum3*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                      v-kod = entry(3,txb.sub-cod.rcode).
                      if  lookup(v-kod, v-vozgf) = 0 and v-kod ne v-sem and v-kod ne v-ud and v-kod ne v-isk then do:
                          find first wrk where wrk.type = 1. 
                          wrk.sum3 = wrk.sum3 + txb.jl.cam.
                      end.
                      if lookup(v-kod, v-vozgf) > 0 then do:
                          find first wrk where wrk.type = 2. 
                          wrk.sum3 = wrk.sum3 + txb.jl.cam.
                      end.
                end.    
             end.
         end.
     end.
end.



if v-sel = '2' then do:
     for each txb.aaa where txb.aaa.lgr = '246' no-lock.
                                        
         for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte and txb.jl.acc = txb.aaa.aaa no-lock .

             v-kod = "".
             if txb.jl.dc = 'C' then do:  /*выплачено sum4*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:               
                    v-kod = entry(3,txb.sub-cod.rcode).
                    if lookup(v-kod, v-sem) > 0 then do:
                       if txb.jl.rem[1] matches "*пенсионер*"  then do:
                          find first wrk where wrk.type = 1. 
                          wrk.sum2 = wrk.sum2 + txb.jl.cam.
                          wrk.sum4 = wrk.sum4 + txb.jl.cam.
                       end.
                       else do:
                          find first wrk where wrk.type = 2. 
                          wrk.sum2 = wrk.sum2 + txb.jl.cam.
                          wrk.sum4 = wrk.sum4 + txb.jl.cam.
                       end. 
                    end.
                end.
                if not avail txb.sub-cod then do:
                   find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.codfr = "spnpl" no-lock no-error.
                   if avail txb.trxcods then do:
                      v-kod = txb.trxcods.code.
                      if lookup(v-kod, v-sem) > 0 then do:
                         if txb.jl.rem[1] matches "*пенсионер*"  then do:
                            find first wrk where wrk.type = 1. 
                            wrk.sum2 = wrk.sum2 + txb.jl.cam.
                            wrk.sum4 = wrk.sum4 + txb.jl.cam.
                         end.
                         else do:
                            find first wrk where wrk.type = 2. 
                            wrk.sum2 = wrk.sum2 + txb.jl.cam.
                            wrk.sum4 = wrk.sum4 + txb.jl.cam.
                         end. 
                      end.
                   end.
                end.     
             end.
             else do:                     /*возвращено sum3*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                      v-kod = entry(3,txb.sub-cod.rcode).
                      if  lookup(v-kod, v-sem) > 0 then do:
                          if txb.jl.rem[1] matches "*пенсионер*"  then do:
                             find first wrk where wrk.type = 1. 
                             wrk.sum3 = wrk.sum3 + txb.jl.cam.
                          end.
                          else do:
                             find first wrk where wrk.type = 2. 
                             wrk.sum3 = wrk.sum3 + txb.jl.cam.
                          end.
                      end.
                end.    
             end.
         end.
     end.

end.



if v-sel = '3' then do:
     for each txb.aaa where txb.aaa.lgr = '246' no-lock.
                                        
         for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte and txb.jl.acc = txb.aaa.aaa no-lock .

             v-kod = "".
             if txb.jl.dc = 'C' then do:  /*выплачено sum4*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:               
                    v-kod = entry(3,txb.sub-cod.rcode).
                    if lookup(v-kod, v-ud) > 0 then do:
                       if txb.jl.rem[1] matches "*368609709*"  then do:
                          find first wrk where wrk.type = 1. 
                          wrk.sum2 = wrk.sum2 + txb.jl.cam.
                          wrk.sum4 = wrk.sum4 + txb.jl.cam.
                       end.
                       else do:
                          find first wrk where wrk.type = 2. 
                          wrk.sum2 = wrk.sum2 + txb.jl.cam.
                          wrk.sum4 = wrk.sum4 + txb.jl.cam.
                       end. 
                    end.
                end.
                if not avail txb.sub-cod then do:
                   find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.codfr = "spnpl" no-lock no-error.
                   if avail txb.trxcods then do:
                      v-kod = txb.trxcods.code.
                      if lookup(v-kod, v-ud) > 0 then do:
                         if txb.jl.rem[1] matches "*368609709*"  then do:
                            find first wrk where wrk.type = 1. 
                            wrk.sum2 = wrk.sum2 + txb.jl.cam.
                            wrk.sum4 = wrk.sum4 + txb.jl.cam.
                         end.
                         else do:
                            find first wrk where wrk.type = 2. 
                            wrk.sum2 = wrk.sum2 + txb.jl.cam.
                            wrk.sum4 = wrk.sum4 + txb.jl.cam.
                         end. 
                      end.
                   end.
                end.     
             end.
             else do:                     /*возвращено sum3*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                      v-kod = entry(3,txb.sub-cod.rcode).
                      if  lookup(v-kod, v-ud) > 0 then do:
                          if txb.jl.rem[1] matches "*368609709*"  then do:
                             find first wrk where wrk.type = 1. 
                             wrk.sum3 = wrk.sum3 + txb.jl.cam.
                          end.
                          else do:
                             find first wrk where wrk.type = 2. 
                             wrk.sum3 = wrk.sum3 + txb.jl.cam.
                          end.
                      end.
                end.    
             end.
         end.
     end.

end.
