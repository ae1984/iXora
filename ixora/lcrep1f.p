/* lcrep1f.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Reports -Turnover
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        lcrep1.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        lcrep1.i
 * MENU
        14-7-3-1
* BASES
        BANK COMM TXB
 * AUTHOR
        21/11/11 id00810
 * CHANGES
        10.07.2012 Lyubov  - добавила поля "Дата окончания" и "Статус"
*/

{lcrep1.i "shared"}

def input parameter v-name as char.

def var v-lcprod   as char.
def var v-acc      as char.
def var v-lc       as char.
def var v-crc_code as char.
def var v-cif_name as char.
def var v-rate     as deci.
def var v-expdt    as char.
def var v-sts      as char.

def shared temp-table wrk no-undo
  field bank     as char
  field bankn    as char
  field gl       as int
  field crc      as int
  field crc_code as char
  field jdt      as date
  field jh       as int
  field dam      as deci
  field cam      as deci
  field dam_KZT  as deci
  field cam_KZT  as deci
  field who      as char
  field lcprod   as char
  field lc       as char
  field cif      as char
  field cif_name as char
  field expdt    as char
  field sts      as char
  index idx is primary gl lcprod jdt jh.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

for each lc where lc.bank = s-ourbank and lookup(lc.lcsts,'fin,cls,cln') > 0 no-lock.
    if lookup(lc.lcsts,'CNL,CLS') > 0 then v-sts = 'Expired'.
    else v-sts = 'Active'.
    v-lcprod = substr(lc.lc,1,index(lc.lc,'0') - 1).
    if v-splcprod ne '' then
    if lookup(v-lcprod,v-splcprod) = 0 then next.

    if v-cif ne '*' then if lc.cif ne v-cif then next.

    if lc.rwhn > v-to then next.

    if lc.lcsts <> 'fin' then do:
        find last lcsts
        where     lcsts.type  = 'cre'
        and       lcsts.lcnum = lc.lc
        and       lcsts.sts   = lc.lcsts
        no-lock no-error.
        if avail lcsts and lcsts.whn < v-from then next.
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
    find first lch where lch.lc = lc.lc and lch.kritcode = 'DtExp' no-lock no-error.
    if not avail lch or lch.value1 = '' then next.
    else v-expdt = lch.value1.
    find first txb.cif where txb.cif.cif = lc.cif no-lock no-error.
    if avail cif then v-cif_name = txb.cif.name.
    for each lcres where lcres.lc = lc.lc and lcres.com = v-com and lcres.levc = v-lev no-lock:
        if lcres.jh = 0 then next.
        if lcres.cacc ne v-acc then next.
        if lcres.jdt < v-from or lcres.jdt > v-to then next.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.bankn  = v-name
               wrk.gl     = v-glacc
               wrk.crc    = lcres.crc
               wrk.jdt    = lcres.jdt
               wrk.jh     = lcres.jh
               wrk.cam    = lcres.amt
               wrk.lc     = lc.lc
               wrk.cif    = lc.cif
               wrk.cif_name = v-cif_name
               wrk.lcprod = v-lcprod
               wrk.expdt  = v-expdt
               wrk.sts    = v-sts.

    end.
    for each lcres where lcres.lc = lc.lc and lcres.com = v-com and lcres.levd = v-lev no-lock:
        if lcres.jh = 0 then next.
        if lcres.dacc ne v-acc then next.
        if lcres.jdt < v-from or lcres.jdt > v-to then next.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.bankn  = v-name
               wrk.gl     = v-glacc
               wrk.crc    = lcres.crc
               wrk.jdt    = lcres.jdt
               wrk.jh     = lcres.jh
               wrk.dam    = lcres.amt
               wrk.lc     = lc.lc
               wrk.cif    = lc.cif
               wrk.cif_name = v-cif_name
               wrk.lcprod = v-lcprod
               wrk.expdt  = v-expdt
               wrk.sts    = v-sts.

    end.
    for each lcamendres where lcamendres.lc = lc.lc and lcamendres.com = v-com and lcamendres.levc = v-lev no-lock:
        if lcamendres.jh = 0 then next.
        if lcamendres.cacc ne v-acc then next.
        if lcamendres.jdt < v-from or lcamendres.jdt > v-to then next.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.bankn  = v-name
               wrk.gl     = v-glacc
               wrk.crc    = lcamendres.crc
               wrk.jdt    = lcamendres.jdt
               wrk.jh     = lcamendres.jh
               wrk.cam    = lcamendres.amt
               wrk.lc     = lc.lc
               wrk.cif    = lc.cif
               wrk.cif_name = v-cif_name
               wrk.lcprod = v-lcprod
               wrk.expdt  = v-expdt
               wrk.sts    = v-sts.

    end.
    for each lcamendres where lcamendres.lc = lc.lc and lcamendres.com = v-com and lcamendres.levd = v-lev no-lock:
        if lcamendres.jh = 0 then next.
        if lcamendres.dacc ne v-acc then next.
        if lcamendres.jdt < v-from or lcamendres.jdt > v-to then next.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.bankn  = v-name
               wrk.gl     = v-glacc
               wrk.crc    = lcamendres.crc
               wrk.jdt    = lcamendres.jdt
               wrk.jh     = lcamendres.jh
               wrk.dam    = lcamendres.amt
               wrk.lc     = lc.lc
               wrk.cif    = lc.cif
               wrk.cif_name = v-cif_name
               wrk.lcprod = v-lcprod
               wrk.expdt  = v-expdt
               wrk.sts    = v-sts.

    end.
    for each lcpayres where lcpayres.lc = lc.lc and lcpayres.com = v-com and lcpayres.levc = v-lev no-lock:
        if lcpayres.jh = 0 then next.
        if lcpayres.cacc ne v-acc then next.
        if lcpayres.jdt < v-from or lcpayres.jdt > v-to then next.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.bankn  = v-name
               wrk.gl     = v-glacc
               wrk.crc    = lcpayres.crc
               wrk.jdt    = lcpayres.jdt
               wrk.jh     = lcpayres.jh
               wrk.cam    = lcpayres.amt
               wrk.lc     = lc.lc
               wrk.cif    = lc.cif
               wrk.cif_name = v-cif_name
               wrk.lcprod = v-lcprod
               wrk.expdt  = v-expdt
               wrk.sts    = v-sts.

    end.
    for each lcpayres where lcpayres.lc = lc.lc and lcpayres.com = v-com and lcpayres.levd = v-lev no-lock:
        if lcpayres.jh = 0 then next.
        if lcpayres.dacc ne v-acc then next.
        if lcpayres.jdt < v-from or lcpayres.jdt > v-to then next.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.bankn  = v-name
               wrk.gl     = v-glacc
               wrk.crc    = lcpayres.crc
               wrk.jdt    = lcpayres.jdt
               wrk.jh     = lcpayres.jh
               wrk.dam    = lcpayres.amt
               wrk.lc     = lc.lc
               wrk.cif    = lc.cif
               wrk.cif_name = v-cif_name
               wrk.lcprod = v-lcprod
               wrk.expdt  = v-expdt
               wrk.sts    = v-sts.

    end.

    for each lceventres where lceventres.lc = lc.lc and lceventres.com = v-com and lceventres.levc = v-lev no-lock:
        if lceventres.jh = 0 then next.
        if lceventres.cacc ne v-acc then next.
        if lceventres.jdt < v-from or lceventres.jdt > v-to then next.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.bankn  = v-name
               wrk.gl     = v-glacc
               wrk.crc    = lceventres.crc
               wrk.jdt    = lceventres.jdt
               wrk.jh     = lceventres.jh
               wrk.cam    = lceventres.amt
               wrk.lc     = lc.lc
               wrk.cif    = lc.cif
               wrk.cif_name = v-cif_name
               wrk.lcprod = v-lcprod
               wrk.expdt  = v-expdt
               wrk.sts    = v-sts.

    end.
    for each lceventres where lceventres.lc = lc.lc and lceventres.com = v-com and lceventres.levd = v-lev no-lock:
        if lceventres.jh = 0 then next.
        if lceventres.dacc ne v-acc then next.
        if lceventres.jdt < v-from or lceventres.jdt > v-to then next.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.bankn  = v-name
               wrk.gl     = v-glacc
               wrk.crc    = lceventres.crc
               wrk.jdt    = lceventres.jdt
               wrk.jh     = lceventres.jh
               wrk.dam    = lceventres.amt
               wrk.lc     = lc.lc
               wrk.cif    = lc.cif
               wrk.cif_name = v-cif_name
               wrk.lcprod = v-lcprod
               wrk.expdt  = v-expdt
               wrk.sts    = v-sts.

    end.
end.
for each wrk break by wrk.crc by wrk.jdt:
    if first-of(wrk.crc) then do:
        v-crc_code = ''.
        find first txb.crc where txb.crc.crc = wrk.crc no-lock no-error.
        if avail txb.crc then v-crc_code = txb.crc.code.
    end.
    wrk.crc_code = v-crc_code.
    if first-of(wrk.jdt) then do:
       v-rate = 0.
       if wrk.crc <> 1 then do:
        find last txb.crchis where txb.crchis.crc = wrk.crc and txb.crchis.rdt <= wrk.jdt no-lock no-error.
        if avail txb.crchis then v-rate = txb.crchis.rate[1].
       end.
    end.
    if wrk.crc <> 1 then assign wrk.dam_KZT = wrk.dam * v-rate
                                wrk.cam_KZT = wrk.cam * v-rate.
    else assign wrk.dam_KZT = wrk.dam
                wrk.cam_KZT = wrk.cam.
    find first txb.jh where txb.jh.jh = wrk.jh no-lock no-error.
    if avail txb.jh then wrk.who = txb.jh.who.

end.
