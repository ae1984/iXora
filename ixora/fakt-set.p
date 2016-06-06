/* fakt-set.p
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
        01.01.2004 nadejda - изменила ставку НДС - брать из sysc
*/

define variable v-dt1 as date.
define variable v-dt2 as date.
define variable v-dt as date.
define variable i as integer.
define variable n as integer.

def var v-nds% as decimal.

find sysc where sysc = "nds" no-lock no-error.
if avail sysc then v-nds% = sysc.deval.

form v-dt1 format "99/99/9999" label "S..." 
     v-dt2 format "99/99/9999" label "Po..." 
           validate(month(v-dt2) = month(v-dt1) and 
                                  year(v-dt2) = year(v-dt1),"!!!")
     with 12 down frame a.


repeat:
   display v-dt1 v-dt2 with frame a.
   update v-dt1 with frame a.
   update v-dt2 with frame a.
   for each fakturis where fakturis.jdt >= v-dt1 and fakturis.jdt <= v-dt2
       exclusive-lock:
       delete fakturis.
   end.
   v-dt = v-dt1.
   do while v-dt <= v-dt2:
      run s-faktset.
      v-dt = v-dt + 1.
   end.
   down with frame a.
end.


procedure s-faktset:

define variable v-cif like cif.cif.
define variable v-jh like jh.jh.
define variable v-order like fakturis.order.
define variable v-faktura like fakturis.faktura.
define variable r    as character.
define variable r1   as character.
define variable i    as integer.
define variable j    as integer.

define buffer b-jl for jl.

    for each trxcods where trxcods.codfr = "stmt" and
        trxcods.code = "chg" no-lock,
        each jh where jh.jdt = v-dt and 
             jh.jh = trxcods.trxh and index(jh.party,"STORNO") = 0 no-lock: 
                                               
                                                 /* Sozdajem vse fakturis */

        find jl where jl.jh = trxcods.trxh and jl.ln = trxcods.trxln and
             jl.dc = "C" no-lock no-error.

        if available jl
        then do:
             find b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln - 1 and
                  b-jl.trx = jl.trx and b-jl.genln = jl.genln and 
                  b-jl.dc = "D" no-lock.
             v-cif = "".
             find gl where gl.gl = b-jl.gl no-lock.
             if gl.subled eq "arp" 
             then do:
                  find arp where arp.arp eq b-jl.acc no-lock no-error.
                  v-cif = arp.cif.
             end.
             else if gl.subled eq "bill"
             then do:
                  find bill where bill.bill eq b-jl.acc no-lock no-error.
                  v-cif = bill.cif.
             end.
             else if gl.subled eq "cif"
             then do:
                  find aaa where aaa.aaa eq b-jl.acc no-lock no-error.
                  v-cif = aaa.cif.
             end.
             else if gl.subled eq "lcr"
             then do:
                  find lcr where lcr.lcr eq b-jl.acc no-lock no-error.
                  v-cif = lcr.cif.
             end.
             if gl.subled = "lon" 
             then do:
                  find lon where lon.lon = b-jl.acc no-lock no-error.
                  v-cif = lon.cif.
             end.
             else if gl.subled eq "ock"
             then do:
                  find ock where ock.ock eq b-jl.acc no-lock no-error.
                  find aaa where aaa.aaa = ock.aaa no-lock no-error.
                  v-cif = aaa.cif.
             end.
             find last crchis where crchis.crc = b-jl.crc and
                  crchis.rdt <= v-dt no-lock. 
             find first fakturis where fakturis.jh eq jl.jh and 
                  fakturis.trx = jl.trx and
                  fakturis.ln eq jl.ln exclusive-lock no-error.             
             if not available fakturis
             then do:
                  create fakturis.
                  fakturis.jdt     = jl.jdt. 
                  fakturis.jh      = jl.jh.
                  fakturis.trx     = jl.trx.
                  fakturis.ln      = jl.ln.
                  fakturis.sts     = "OOO". 
                  fakturis.who     = jl.who. 
                  fakturis.rdt     = v-dt. 
                  fakturis.tim     = time. 
                  fakturis.cif     = v-cif.
                  fakturis.acc     = b-jl.acc. 
                  fakturis.amt     = crchis.rate[5] / crchis.rate[9] *
                                     (jl.dam + jl.cam). 
                  fakturis.pvn     = fakturis.amt / (1 + v-nds%) * v-nds%. 
                  fakturis.neto    = fakturis.amt - fakturis.pvn. 
                  fakturis.order   = next-value(vptrx).
                  fakturis.faktura = 10000000 * (year(v-dt) modulo 100) +
                                    100000 * month(v-dt) + fakturis.order.
             end.
             else do:
                  v-order = fakturis.order.
                  v-faktura = fakturis.faktura.
                  if fakturis.cif <> v-cif or
                     fakturis.acc <> b-jl.acc or
                     fakturis.amt <> crchis.rate[5] / crchis.rate[9] *
                                  (jl.dam + jl.cam)
                  then do:    /* Jesli izmenenija v techenije dnja */ 
                       fakturis.sts = substring(fakturis.sts,1,1)  +
                                      "C" + substring(fakturis.sts,3,1).
                       fakturis.cif = v-cif.
                       fakturis.acc = b-jl.acc.
                       fakturis.amt = crchis.rate[5] / crchis.rate[9] *
                                      (jl.dam + jl.cam).
                  end. 
             end.
        end.
    end.   
    
    
    for each jh where jh.jdt = v-dt and index(jh.party,"STORNO") > 0 
        no-lock:                  /* Jesli storno za ljuboj denj */
    
        r = "A" + jh.party.
        do while true:
           r = substring(r,2).
           if length(r) = 1
           then leave.
           r1 = substring(r,1,1).
           if r1 >= "0" and r1 <= "9"
           then leave.
        end.
        i = 0.
        do while true:
           i = i + 1.
           r1 = substring(r,i,1).
           if r1 < "0" or r1 > "9"
           then leave.
        end.
        r = substring(r,1,i - 1).
        v-jh = integer(r).
        for each fakturis where fakturis.jh = v-jh exclusive-lock:
            fakturis.sts = substring(fakturis.sts,1,2) + "S".
        end.    
    end.
    
    for each fakturis where fakturis.rdt = v-dt and 
        substring(fakturis.sts,3,1) = "O" exclusive-lock:
                  /* Mozhet fakturis sozdano, a tranzakcija udalena */
        find first jl where jl.jh = fakturis.jh and jl.trx = fakturis.trx and
             jl.ln = fakturis.ln and jl.dc = "C" no-lock no-error.
        if available jl
        then do:
             find first trxcods where trxcods.trxh eq jl.jh and 
                  trxcods.trxln eq jl.ln and 
                  trxcods.codfr eq "stmt" and 
                  trxcods.code eq "chg" no-lock no-error.
             if not available trxcods
             then fakturis.sts = substring(fakturis.sts,1,2) + "D".
        end.
        else fakturis.sts = substring(fakturis.sts,1,2) + "D".
    end.     
end procedure.