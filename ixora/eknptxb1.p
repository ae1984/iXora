/* eknptxb1.p
 * MODULE
        СТАТИСТИКА
 * DESCRIPTION
        Отчет о покупке-продаже иностранной валюты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        eknp_f2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-9-6-5
 * BASES
        BANK COMM TXB
 * AUTHOR
        26/04/2006 dpuchkov
 * CHANGES
        24.05.2006 dpuchkov - добавил if avail программа выдавала ошибки.
        26/05/2006 dpuchkov - изменил порядок вывода данныхв отчете
        09.06.2006 dpuchkov - добавил проверку на наличные деньги
*/


 def shared var vn-dt as date    no-undo.
 def shared var vn-dtbeg as date no-undo.
 def var v-arp as char.
 def buffer b1 for txb.aaa.
 def buffer b2 for txb.aaa.
 def var KOd as char format "x(2)" no-undo.
 def var KBe as char format "x(2)" no-undo.
 def var KNP as char format "x(3)" no-undo.

 def shared temp-table tmp-f2p2
     field nom  as integer
     field name as char
     field kod  as integer
     field summ as decimal decimals 2
     field RRez  as decimal decimals 2
     field RNer  as decimal decimals 2
     field NRez  as decimal decimals 2
     field NNer  as decimal decimals 2. 


     function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
     define buffer bcrc1 for txb.crchis.
     define buffer bcrc2 for txb.crchis.
         if c1 <> c2 then 
            do:
               find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
               find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
               return sum * bcrc1.rate[1] / bcrc2.rate[1].
            end.
         else return sum.    
     end.


       for each tmp-f2p2 break by nom:

           if tmp-f2p2.kod = 11100 then do:
              for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                  if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' then do: /*входящие*/
                     find last txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
                     if avail txb.aaa then 
                        find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                        find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                           if txb.cif.type = "P" then do:
                              if substr(txb.sub-cod.rcode,1,2) = "19" and substr(txb.sub-cod.rcode,4,2) = "19" then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if substr(txb.sub-cod.rcode,1,2) = "19" and substr(txb.sub-cod.rcode,4,2) = "29" then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if substr(txb.sub-cod.rcode,1,2) = "29" and substr(txb.sub-cod.rcode,4,2) = "19" then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if substr(txb.sub-cod.rcode,1,2) = "29" and substr(txb.sub-cod.rcode,4,2) = "29" then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                        end.
                     end.
                  end.
              end.
           end.


           if tmp-f2p2.kod = 11210 then do:
              run in1("710,720,730,780,790").
           end.
           if tmp-f2p2.kod = 11220 then do:
              run in1("740,810,811,813,814,815,816,817,818,819,820,830,831,832,833,834,835,836,837,839,840,850,851,852,853,854,855,812,859,860,861,862,869,870,880,890").
           end.
           if tmp-f2p2.kod = 11230 then do:
              run in1("411,413,840").
           end.

           if tmp-f2p2.kod = 11240 then do:
              run in1("419").
           end.

           if tmp-f2p2.kod = 11241 then do:
              for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                  if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' then do: /*входящие*/
                     find last txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
                     if avail txb.aaa then 
                        find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                        find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                           if txb.cif.type = "B" and substr(txb.remtrz.sqn, 5,2) = "KZ" then do:
                              if lookup(substr(txb.sub-cod.rcode,7,3),"419") <> 0 then do:
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                              end.
                        end.
                     end.
                  end.
              end.
           end.

           if tmp-f2p2.kod = 11242 then do:
              for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                  if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' then do: /*входящие*/
                     find last txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
                     if avail txb.aaa then 
                        find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                        find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                           if txb.cif.type = "B" and substr(txb.remtrz.sqn, 5,2) <> "KZ" then do:
                              if lookup(substr(txb.sub-cod.rcode,7,3),"419") <> 0 then do:
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                              end.
                        end.
                     end.
                  end.
              end.
           end.

           if tmp-f2p2.kod = 11251 then do:
              run in1("610").
           end.
           if tmp-f2p2.kod = 11252 then do:
              run in1("510").
           end.
           if tmp-f2p2.kod = 11253 then do:
              run in1("631,633,639,671,681,690,639").
           end.
           if tmp-f2p2.kod = 11254 then do:
              run in1("641,642,645,647,648,649,651,652,652,655,657,658,672,682,690").
           end.
           if tmp-f2p2.kod = 11255 then do:
              run in1("531,532,539,541,542,543,544,545,548,549,551,552,553,554,555,558,559,569,562,563,570,580,590,590").
           end.
           if tmp-f2p2.kod = 11260 then do:
              run in1("119").
           end.

           if tmp-f2p2.kod = 12000 then do:
              v-arp = "00".
              find sysc where sysc.sysc = "ourbnk" no-lock no-error .
              if avail sysc then do:
                 if sysc.chval = "TXB00" then v-arp = "000076915,003904738,003904602,003076611,002904784,002904645,088076115,077076906,002904386,003076912,002076968,002636654,003904903,002904946,002904085,003904039,003904204,002904247,003076213,002904535,077076207,177076916,200076304,010076367,000076135,188076015,200076906,200076605,001076626,177076217".
                 if sysc.chval = "TXB01" then v-arp = "150076202,150076215,150076121,150076105,151076010,150076503,150076516,150076710,150076435,150076134".
                 if sysc.chval = "TXB02" then v-arp = "250076207,250076210,250076906,250076508,250076401,250076511,250076618,250076414".
                 if sysc.chval = "TXB03" then v-arp = "350076433,350076682,350076954,350076310,350076844,350076705,350076381,350076404,350076802".
                 if sysc.chval = "TXB04" then v-arp = "450076209,450076911,450076610,450076212".
                 if sysc.chval = "TXB05" then v-arp = "0-0".
                 for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                    if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' then do: /*входящие*/
                       if lookup(string(txb.remtrz.racc),v-arp) <> 0 then do:
                           find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                           if avail txb.sub-cod then do:
                              if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18,19") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18,19") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28,29") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28,29") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                           end.
                       end.
                    end.
                 end.
              end.
           end.

           if tmp-f2p2.kod = 13000 then do:
                 for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                     if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' then do:
                        find last txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
                        if avail txb.aaa then 
                           find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                           find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                           if lookup(substr(txb.sub-cod.rcode,7,3),"131,132,321,312,314") <> 0 then do:
                              if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0).
                            end.
                         end.
                     end.
                 end.
           end.

           if tmp-f2p2.kod = 13001 then do:
                 for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                     if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' then do:
                        find last txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
                        if avail txb.aaa then 
                           find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                           find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                         if lookup(substr(txb.sub-cod.rcode,7,3),"131,132,321,312,314") <> 0 then do:
                         if substr(txb.remtrz.sqn, 5,2) = "KZ" then do:
                               if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                               if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                         end.
                            end.

                         end.
                     end.
                 end.
           end.

           if tmp-f2p2.kod = 13002 then do:
                 for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                     if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' then do:
                        find last txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
                        if avail txb.aaa then 
                           find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                           find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                         if lookup(substr(txb.sub-cod.rcode,7,3),"131,132,321,312,314") <> 0 then do:
                         if substr(txb.remtrz.sqn, 5,2) <> "KZ" then do:
                               if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                               if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                         end.
                            end.

                         end.
                     end.
                 end.
           end.


           if tmp-f2p2.kod = 14100 then do:
              for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
                  if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                      find last b1 where b1.aaa = tclientaccno no-lock.
                      find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 then do:
                      find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "P" no-lock no-error.
                         find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                         if avail txb.cif and avail txb.jl then do:
                            if substr(txb.cif.geo,3,1) = "1" then do: /*резидент*/
                               tmp-f2p2.RRez = tmp-f2p2.RRez + round(txb.jl.cam / 1000, 0). 
                            end.
                            if substr(txb.cif.geo,3,1) = "2" then do: /*резидент*/
                               tmp-f2p2.NNer = tmp-f2p2.NNer + round(txb.jl.cam / 1000, 0). 
                            end.
                         end.
end.
                  end.
              end.
           end.

           if tmp-f2p2.kod = 14200 then do:
              for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
                  if (txb.dealing_doc.doctype = 1 or txb.dealing_doc.doctype = 2 ) then do:
                      find last b1 where b1.aaa = tclientaccno no-lock.
                      find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 then do:
                      find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "B" no-lock no-error.
                         find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 1 and txb.jl.dam = 0 no-lock no-error.
                         if avail txb.cif and avail txb.jl then do:
                            if substr(txb.cif.geo,3,1) = "1" then do: /*резидент*/
                               tmp-f2p2.RRez = tmp-f2p2.RRez + round(txb.jl.cam / 1000, 0). 
                            end.
                            if substr(txb.cif.geo,3,1) = "2" then do: /*резидент*/
                               tmp-f2p2.NNer = tmp-f2p2.NNer + round(txb.jl.cam / 1000, 0). 
                            end.
                         end.
end.
                  end.
              end.
           end.



           if tmp-f2p2.kod = 15100 then do:
              for each txb.jl where txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt  and txb.jl.subled = "CIF" and txb.jl.crc > 1 and txb.jl.dc = "C" no-lock:
                  find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                       if index(txb.jh.party,"STORNED") > 0 or index(txb.jh.party,"STORNO") > 0 or txb.jh.sub = "" then next.
                       if txb.jl.lev <> 1 then next.
                       if txb.jl.cam = 0 then next.
                       find last txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
                       if not avail txb.aaa then next.
                       find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                       if not avail txb.cif then next.
                       if txb.cif.type = "P" then do:
                          KOd = "". KBe = "". KNP = "".
                          run GetEKNP(txb.jl.jh, 1, "", input-output KOd, input-output KBe, input-output KNP).
                          if KOd <> "" and KBe <> "" then do:
                             if lookup(KOd,"15,16,17,18,19") <> 0 and lookup(KBe,"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"25,26,27,28,29") <> 0 and lookup(KBe,"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"15,16,17,18,19") <> 0 and lookup(KBe,"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"25,26,27,28,29") <> 0 and lookup(KBe,"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). 
                          end. else
                          do:
                                if substr(txb.cif.geo,3,1) = "1" then  tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                                if substr(txb.cif.geo,3,1) = "2" then  tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0).
                          end.
                       end.
              end.
           end.



           if tmp-f2p2.kod = 15200 then do:
              for each txb.jl where txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt  and txb.jl.subled = "CIF" and txb.jl.crc > 1 and txb.jl.dc = "C" no-lock:
if txb.jl.gl = 100100 or txb.jl.gl = 100200 or txb.jl.gl = 100300 then do:
                  find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                       if index(txb.jh.party,"STORNED") > 0 or index(txb.jh.party,"STORNO") > 0 or txb.jh.sub = "" then next.
                       if txb.jl.lev <> 1 then next.
                       if txb.jl.cam = 0 then next.
                       find last txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
                       if not avail txb.aaa then next.
                       find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                       if not avail txb.cif then next.
                       if txb.cif.type = "B" then do:
                          KOd = "". KBe = "". KNP = "".
                          run GetEKNP(txb.jl.jh, 1, "", input-output KOd, input-output KBe, input-output KNP).
                          if KOd <> "" and KBe <> "" then do:
                             if lookup(KOd,"15,16,17,18,19") <> 0 and lookup(KBe,"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"25,26,27,28,29") <> 0 and lookup(KBe,"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"15,16,17,18,19") <> 0 and lookup(KBe,"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"25,26,27,28,29") <> 0 and lookup(KBe,"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). 
                          end. else
                          do:
                                if substr(txb.cif.geo,3,1) = "1" then  tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                                if substr(txb.cif.geo,3,1) = "2" then  tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0).
                          end.
                       end.
end.
              end.
           end.



/* исходящие */
           if tmp-f2p2.kod = 21100 then do:
              for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                  if txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' then do: /*исходящие*/
                     find last txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
                     if avail txb.aaa then 
                        find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                        find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                           if txb.cif.type = "P" then do:
                              if substr(txb.sub-cod.rcode,1,2) = "19" and lookup(substr(txb.sub-cod.rcode,4,2), "15,16,17,18,19") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if substr(txb.sub-cod.rcode,1,2) = "19" and lookup(substr(txb.sub-cod.rcode,4,2), "25,26,27,28,29") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else       
                              if substr(txb.sub-cod.rcode,1,2) = "29" and lookup(substr(txb.sub-cod.rcode,4,2), "15,16,17,18,19") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if substr(txb.sub-cod.rcode,1,2) = "29" and lookup(substr(txb.sub-cod.rcode,4,2), "25,26,27,28,29") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0).
                           end.
                        end.
                  end.
              end.
           end.


           if tmp-f2p2.kod = 21210 then do:
              run out1("710,720,730,780,790").
           end.
           if tmp-f2p2.kod = 21220 then do:
              run out1("810,811,812,740,813,814,815,816,817,818,819,820,830,831,832,833,834,835,836,837,839,840,850,851,852,853,854,855,859,860,861,862,869,870,880,890").
           end.
           if tmp-f2p2.kod = 21230 then do:
              run out1("411,413,419").
           end.

           if tmp-f2p2.kod = 21240 then do:
              run out1("840").
           end.


           if tmp-f2p2.kod = 21241 then do:
              for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                  if txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' then do: /*исх*/
                     find last txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
                     if avail txb.aaa then 
                        find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                        find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                           if txb.cif.type = "B" and substr(txb.remtrz.sqn, 5,2) = "KZ" then do:
                              if lookup(substr(txb.sub-cod.rcode,7,3),"419") <> 0 then do:
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                              end.
                        end.
                     end.
                  end.
              end.
           end.

           if tmp-f2p2.kod = 21242 then do:
              for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                  if txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' then do: /*исх*/
                     find last txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
                     if avail txb.aaa then 
                        find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                        find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                           if txb.cif.type = "B" and substr(txb.remtrz.sqn, 5,2) <> "KZ" then do:
                              if lookup(substr(txb.sub-cod.rcode,7,3),"419") <> 0 then do:
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                                 if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                              end.
                        end.
                     end.
                  end.
              end.
           end.
           if tmp-f2p2.kod = 21251 then do:
              run out1("610").
           end.
           if tmp-f2p2.kod = 21252 then do:
              run out1("510").
           end.
           if tmp-f2p2.kod = 21253 then do:
              run out1("621,623,629,671,681,690,639").
           end.
           if tmp-f2p2.kod = 21254 then do:
              run out1("641,642,645,647,648,649,651,652,655,657,658,672,682,690").
           end.
           if tmp-f2p2.kod = 21255 then do:
              run out1("521,522,529,539,541,542,543,544,545,548,549,551,552,553,554,555,558,559,563,570,580,590").
           end.
           if tmp-f2p2.kod = 21260 then do:
              run out1("119").
           end.

           if tmp-f2p2.kod = 22000 then do:
              v-arp = "00".
              find sysc where sysc.sysc = "ourbnk" no-lock no-error .
              if avail sysc then do:
                 if sysc.chval = "TXB00" then v-arp = "000076915,003904738,003904602,003076611,002904784,002904645,088076115,077076906,002904386,003076912,002076968,002636654,003904903,002904946,002904085,003904039,003904204,002904247,003076213,002904535,077076207,177076916,200076304,010076367,000076135,188076015,200076906,200076605,001076626,177076217".
                 if sysc.chval = "TXB01" then v-arp = "150076202,150076215,150076121,150076105,151076010,150076503,150076516,150076710,150076435,150076134".
                 if sysc.chval = "TXB02" then v-arp = "250076207,250076210,250076906,250076508,250076401,250076511,250076618,250076414".
                 if sysc.chval = "TXB03" then v-arp = "350076433,350076682,350076954,350076310,350076844,350076705,350076381,350076404,350076802".
                 if sysc.chval = "TXB04" then v-arp = "450076209,450076911,450076610,450076212".
                 if sysc.chval = "TXB05" then v-arp = "0-0".
                 for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                    if txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6'  then do: /*исходящие*/
                       if lookup(string(txb.remtrz.sacc),v-arp) <> 0 then do:
                           find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                           if avail txb.sub-cod then do:
                              if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18,19") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18,19") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28,29") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28,29") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0).
                           end.
                       end.
                    end.
                 end.
              end.
           end.


           if tmp-f2p2.kod = 23000 then do:
                 for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                     if txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' then do:
                        find last txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
                        if avail txb.aaa then 
                           find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                           find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                           if lookup(substr(txb.sub-cod.rcode,7,3),"131,132,321,312,314") <> 0 then do:
      
                              if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                              if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                            end.
                         end.
                     end.
                 end.
           end.

           if tmp-f2p2.kod = 23001 then do:
                 for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                     if txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' then do:
                        find last txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
                        if avail txb.aaa then 
                           find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                           find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                         if lookup(substr(txb.sub-cod.rcode,7,3),"131,132,321,312,314") <> 0 then do:
                         if substr(txb.remtrz.sqn, 5,2) = "KZ" then do:
                               if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                               if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                         end.
                            end.

                         end.
                     end.
                 end.
           end.

           if tmp-f2p2.kod = 23002 then do:
                 for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
                     if txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' then do:
                        find last txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
                        if avail txb.aaa then 
                           find last txb.cif where txb.cif.cif = txb.aaa.aaa no-lock no-error.
                           find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                        if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                         if lookup(substr(txb.sub-cod.rcode,7,3),"131,132,321,312,314") <> 0 then do:
                         if substr(txb.remtrz.sqn, 5,2) <> "KZ" then do:
                               if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                               if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                         end.
                            end.

                         end.
                     end.
                 end.
           end.       


           if tmp-f2p2.kod = 24100 then do:
              for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
                  if (txb.dealing_doc.doctype = 3 or txb.dealing_doc.doctype = 4) then do:
                      find last b1 where b1.aaa = tclientaccno no-lock.
                      find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 then do:
                      find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "P" no-lock no-error.
                         find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 2 and txb.jl.dam = 0 no-lock no-error.
                         if avail txb.cif and avail txb.jl then do:
                            if substr(txb.cif.geo,3,1) = "1" then do: /*резидент*/
                               tmp-f2p2.RRez = tmp-f2p2.RRez + round(txb.jl.cam / 1000, 0). 
                            end.
                            if substr(txb.cif.geo,3,1) = "2" then do: /*резидент*/
                               tmp-f2p2.NNer = tmp-f2p2.NNer + round(txb.jl.cam / 1000, 0). 
                            end.
                         end.
end.
                  end.
              end.
           end.
           if tmp-f2p2.kod = 24200 then do:
              for each txb.dealing_doc where  txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock: 
                  if (txb.dealing_doc.doctype = 3 or txb.dealing_doc.doctype = 4) then do:
                      find last b1 where b1.aaa = tclientaccno no-lock.
                      find last b2 where b2.aaa = vclientaccno no-lock no-error.
if avail b2 then do:
                      find last txb.cif where txb.cif.cif = b1.cif and txb.cif.type = "B" no-lock no-error.
                         find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.genln = 2 and txb.jl.dam = 0 no-lock no-error.
                         if avail txb.cif and avail txb.jl then do:
                            if substr(txb.cif.geo,3,1) = "1" then do: /*резидент*/
                               tmp-f2p2.RRez = tmp-f2p2.RRez + round(txb.jl.cam / 1000, 0). 
                            end.
                            if substr(txb.cif.geo,3,1) = "2" then do: /*резидент*/
                               tmp-f2p2.NNer = tmp-f2p2.NNer + round(txb.jl.cam / 1000, 0). 
                            end.
                         end.
end.
                  end.
              end.
           end.


           if tmp-f2p2.kod = 25100 then do:
              for each txb.jl where txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt  and txb.jl.subled = "CIF" and txb.jl.crc > 1 and txb.jl.dc = "D" no-lock:
                  find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                       if index(txb.jh.party,"STORNED") > 0 or index(txb.jh.party,"STORNO") > 0 or txb.jh.sub = "" then next.
                       if txb.jl.lev <> 1 then next.
                       if txb.jl.dam  = 0 then next.
                       find last txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
                       if not avail txb.aaa then next.
                       find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                       if not avail txb.cif then next.
                       if txb.cif.type = "P" then do:
                          KOd = "". KBe = "". KNP = "".
                          run GetEKNP(txb.jl.jh, 1, "", input-output KOd, input-output KBe, input-output KNP).
                          if KOd <> "" and KBe <> "" then do:
                             if lookup(KOd,"15,16,17,18,19") <> 0 and lookup(KBe,"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"25,26,27,28,29") <> 0 and lookup(KBe,"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"15,16,17,18,19") <> 0 and lookup(KBe,"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"25,26,27,28,29") <> 0 and lookup(KBe,"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). 
                          end. else
                          do:
                                if substr(txb.cif.geo,3,1) = "1" then  tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                                if substr(txb.cif.geo,3,1) = "2" then  tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0).
                          end.
                       end.
              end.
           end.
                
           if tmp-f2p2.kod = 25200 then do:
              for each txb.jl where txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt  and txb.jl.subled = "CIF" and txb.jl.crc > 1 and txb.jl.dc = "D" no-lock:
                  find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                       if index(txb.jh.party,"STORNED") > 0 or index(txb.jh.party,"STORNO") > 0 or txb.jh.sub = "" then next.
                       if txb.jl.lev <> 1 then next.
                       if txb.jl.dam  = 0 then next.
                       find last txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
                       if not avail txb.aaa then next.
                       find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                       if not avail txb.cif then next.
                       if txb.cif.type = "B" then do:
                          KOd = "". KBe = "". KNP = "".
                          run GetEKNP(txb.jl.jh, 1, "", input-output KOd, input-output KBe, input-output KNP).
                          if KOd <> "" and KBe <> "" then do:
                             if lookup(KOd,"15,16,17,18,19") <> 0 and lookup(KBe,"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"25,26,27,28,29") <> 0 and lookup(KBe,"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"15,16,17,18,19") <> 0 and lookup(KBe,"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                             if lookup(KOd,"25,26,27,28,29") <> 0 and lookup(KBe,"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). 
                          end. else
                          do:
                                if substr(txb.cif.geo,3,1) = "1" then  tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0). else
                                if substr(txb.cif.geo,3,1) = "2" then  tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / 1000, 0).
                          end.
                       end.
              end.
           end.
           tmp-f2p2.summ = /*tmp-f2p2.summ +*/ tmp-f2p2.RRez + tmp-f2p2.RNer + tmp-f2p2.NRez + tmp-f2p2.NNer.

/*if tmp-f2p2.kod = 14100 then do:
    message tmp-f2p2.summ tmp-f2p2.RRez tmp-f2p2.RNer tmp-f2p2.NRez tmp-f2p2.NNer.
    pause 555.
  end. */


       end.









  
 


  procedure in1.
     def input parameter v-knp as char.
     for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
         if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' then do: /*входящие*/
            find last txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
            if avail txb.aaa then 
               find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
               find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
               if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                  if txb.cif.type = "B" then do:
                     if lookup(substr(txb.sub-cod.rcode,7,3),v-knp) <> 0 then do:
                        if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                        if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                        if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                        if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). 
                     end.
               end.
            end.
         end.
     end.
  end.

  procedure out1.
     def input parameter v-knp as char.
     for each txb.remtrz where txb.remtrz.rdt >= vn-dtbeg and txb.remtrz.rdt <= vn-dt and txb.remtrz.tcrc <> 1 no-lock:
         if txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' then do: /*входящие*/
            find last txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
            if avail txb.aaa then 
               find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
               find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
               if avail txb.aaa and avail txb.cif and avail txb.sub-cod then do:
                  if txb.cif.type = "B" then do:
                     if lookup(substr(txb.sub-cod.rcode,7,3),v-knp) <> 0 then do:
                        if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RRez = tmp-f2p2.RRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                        if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"15,16,17,18") <> 0 then tmp-f2p2.RNer = tmp-f2p2.RNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                        if lookup(substr(txb.sub-cod.rcode,1,2),"15,16,17,18,19") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NRez = tmp-f2p2.NRez + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0). else
                        if lookup(substr(txb.sub-cod.rcode,1,2),"25,26,27,28,29") <> 0 and lookup(substr(txb.sub-cod.rcode,4,2),"25,26,27,28") <> 0 then tmp-f2p2.NNer = tmp-f2p2.NNer + round(crc-crc-date(txb.remtrz.payment, txb.remtrz.tcrc, 1, txb.remtrz.rdt) / 1000, 0).

                     end.
               end.
            end.
         end.
     end.
  end.






