/* lcrep2f.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Reports - Remaining Amount
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        lcrep2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        lcrep2.i
 * MENU
        14-7-3-2
 * BASES
        BANK COMM TXB
 * AUTHOR
        29/11/11 id00810
 * CHANGES
*/

{lcrep2.i "shared"}

def input parameter v-name as char.

def var v-lcprod   as char.
def var v-acc      as char.
def var v-lc       as char.
def var v-crc_code as char.
def var v-cif_name as char.
def var v-rate     as deci.
def var v-ost      as deci extent 4.
def var i          as int.

def shared temp-table wrk no-undo
  field bank     as char
  field bankn    as char
  field gl       as int
  field crc      as int
  field crc_code as char
  field ost      as deci
  field ost_KZT  as deci
  field lcprod   as char
  field lc       as char
  field cif      as char
  field cif_name as char
  index idx is primary gl lcprod lc.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

for each lc where lc.bank = s-ourbank and lookup(lc.lcsts,'fin,cls,cln') > 0 no-lock.
    v-lcprod = substr(lc.lc,1,index(lc.lc,'0') - 1).
    if v-splcprod ne '' then
    if lookup(v-lcprod,v-splcprod) = 0 then next.

    if v-cif ne '*' then if lc.cif ne v-cif then next.

    if lc.rwhn >= v-dt then next.

    if lc.lcsts <> 'fin' then do:
        find last lcsts
        where     lcsts.type  = 'cre'
        and       lcsts.lcnum = lc.lc
        and       lcsts.sts   = lc.lcsts
        no-lock no-error.
        if avail lcsts and lcsts.whn < v-dt then next.
    end.

    if v-cover ne '' then do:
       find first lch where lch.lc = lc.lc and lch.kritcode = 'cover' no-lock no-error.
       if not avail lch or lch.value1 ne v-cover then next.
    end.
    if v-code ne '' then do:
       find first lch where lch.lc = lc.lc and lch.kritcode = v-code no-lock no-error.
       if not avail lch or lch.value1 = '' then next.
       v-acc = lch.value1.
    end.
    else v-acc = string(v-glacc).
    find first txb.cif where txb.cif.cif = lc.cif no-lock no-error.
    if avail cif then v-cif_name = txb.cif.name.
    for each lcres where lcres.lc = lc.lc and lcres.com = v-com and lcres.levc = v-lev no-lock:
        if lcres.jh = 0 then next.
        if lcres.cacc ne v-acc then next.
        if lcres.jdt >= v-dt then next.
        if v-ap then v-ost[lcres.crc] = v-ost[lcres.crc] - lcres.amt.
        else v-ost[lcres.crc] = v-ost[lcres.crc] + lcres.amt.
    end.
    for each lcres where lcres.lc = lc.lc and lcres.com = v-com and lcres.levd = v-lev no-lock:
        if lcres.jh = 0 then next.
        if lcres.dacc ne v-acc then next.
        if lcres.jdt >= v-dt then next.
        if v-ap then v-ost[lcres.crc] = v-ost[lcres.crc] + lcres.amt.
        else v-ost[lcres.crc] = v-ost[lcres.crc] - lcres.amt.
    end.
    for each lcamendres where lcamendres.lc = lc.lc and lcamendres.com = v-com and lcamendres.levc = v-lev no-lock:
        if lcamendres.jh = 0 then next.
        if lcamendres.cacc ne v-acc then next.
        if lcamendres.jdt >= v-dt then next.
        if v-ap then v-ost[lcamendres.crc] = v-ost[lcamendres.crc] - lcamendres.amt.
        else v-ost[lcamendres.crc] = v-ost[lcamendres.crc] + lcamendres.amt.
    end.
    for each lcamendres where lcamendres.lc = lc.lc and lcamendres.com = v-com and lcamendres.levd = v-lev no-lock:
        if lcamendres.jh = 0 then next.
        if lcamendres.dacc ne v-acc then next.
        if lcamendres.jdt >= v-dt then next.
        if v-ap then v-ost[lcamendres.crc] = v-ost[lcamendres.crc] + lcamendres.amt.
        else v-ost[lcamendres.crc] = v-ost[lcamendres.crc] - lcamendres.amt.
    end.
    for each lcpayres where lcpayres.lc = lc.lc and lcpayres.com = v-com and lcpayres.levc = v-lev no-lock:
        if lcpayres.jh = 0 then next.
        if lcpayres.cacc ne v-acc then next.
        if lcpayres.jdt >= v-dt then next.
        if v-ap then v-ost[lcpayres.crc] = v-ost[lcpayres.crc] - lcpayres.amt.
        else v-ost[lcpayres.crc] = v-ost[lcpayres.crc] + lcpayres.amt.
    end.
    for each lcpayres where lcpayres.lc = lc.lc and lcpayres.com = v-com and lcpayres.levd = v-lev no-lock:
        if lcpayres.jh = 0 then next.
        if lcpayres.dacc ne v-acc then next.
        if lcpayres.jdt >= v-dt then next.
        if v-ap then v-ost[lcpayres.crc] = v-ost[lcpayres.crc] + lcpayres.amt.
        else v-ost[lcpayres.crc] = v-ost[lcpayres.crc] - lcpayres.amt.
    end.

    for each lceventres where lceventres.lc = lc.lc and lceventres.com = v-com and lceventres.levc = v-lev no-lock:
        if lceventres.jh = 0 then next.
        if lceventres.cacc ne v-acc then next.
        if lceventres.jdt >= v-dt then next.
        if v-ap then v-ost[lceventres.crc] = v-ost[lceventres.crc] - lceventres.amt.
        else v-ost[lceventres.crc] = v-ost[lceventres.crc] + lceventres.amt.
    end.
    for each lceventres where lceventres.lc = lc.lc and lceventres.com = v-com and lceventres.levd = v-lev no-lock:
        if lceventres.jh = 0 then next.
        if lceventres.dacc ne v-acc then next.
        if lceventres.jdt >= v-dt then next.
        if v-ap then v-ost[lceventres.crc] = v-ost[lceventres.crc] + lceventres.amt.
        else v-ost[lceventres.crc] = v-ost[lceventres.crc] - lceventres.amt.
    end.

    i = 1.
    do while i <= 4:
        if v-ost[i] > 0 then do:
            create wrk.
            assign wrk.bank     = s-ourbank
                   wrk.bankn    = v-name
                   wrk.gl       = v-glacc
                   wrk.crc      = i
                   wrk.ost      = v-ost[i]
                   wrk.lc       = lc.lc
                   wrk.cif      = lc.cif
                   wrk.cif_name = v-cif_name
                   wrk.lcprod   = v-lcprod.
            v-ost[i] = 0.
        end.
        i = i + 1.
    end.
end.
for each wrk break by wrk.crc:
    if first-of(wrk.crc) then do:
        v-crc_code = ''.
        find first txb.crc where txb.crc.crc = wrk.crc no-lock no-error.
        if avail txb.crc then v-crc_code = txb.crc.code.
        v-rate = 0.
        if wrk.crc <> 1 then do:
         find last txb.crchis where txb.crchis.crc = wrk.crc and txb.crchis.rdt < v-dt no-lock no-error.
         if avail txb.crchis then v-rate = txb.crchis.rate[1].
        end.
    end.
    wrk.crc_code = v-crc_code.
    if wrk.crc <> 1 then wrk.ost_KZT = wrk.ost * v-rate.
    else wrk.ost_KZT = wrk.ost.
end.
