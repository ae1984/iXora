/* r-garf.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расшифровка условных обязательств по аккредитивам и гарантиям (отчет)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-gar.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-4-12-5
 * AUTHOR
        30/06/2011 id00810
 * BASES
        BANK COMM TXB
 * CHANGES
        27/07/2011 id00810 - новые графы Бенефициар, Сумма комиссии
*/

 def shared var v-rate   as deci no-undo extent 3.
 def shared var v-dat    as date no-undo.

 def var v-bank   as char no-undo.
 def var v-bankn  as char no-undo.
 def var v-lcsum1 as deci no-undo.
 def var v-lcsum2 as deci no-undo.
 def var v-lcsum3 as deci no-undo.
 def var v-cov    as char no-undo.
 def var v-gar    as logi no-undo.
 def var v-cod    as char no-undo.
 def var v-dt1    as date no-undo.
 def var v-dt2    as date no-undo.
 def var v-name   as char no-undo.
 def var v-per    as int  no-undo.

def shared  temp-table temp
     field filial    as   char
     field cif       like txb.cif.cif
     field name      like txb.cif.sname
     field opf       as   char
     field vidusl    as   char
     field ecdivis   as   char
     field rez       as   char
     field ins       as   char
     field ref       as   char
     field regdt     like txb.aaa.regdt
     field expdt     like txb.aaa.expdt
     field code      like txb.crc.code
     field nps       as   char
     field sumtreb   like txb.garan.sumtreb
     field sumzalog  like txb.garan.sumzalog
     field zalog     as   char
     field classif   as   char
     field bal1      as   deci
     field bal2      as   deci
     field bal3      as   deci
     field bal4      as   deci
     field naim      like txb.garan.naim
     field sumkom    like txb.garan.sumkom
 .

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
v-bank = trim(txb.sysc.chval).
find first txb where txb.bank = v-bank no-lock no-error.
if avail txb then v-bankn = comm.txb.info.

for each txb.cif,
    each txb.aaa where txb.aaa.cif = txb.cif.cif
                   and txb.aaa.regdt < v-dat
                   and (string(txb.aaa.gl) begins '2223' or string(txb.aaa.gl) begins '2208' or string(txb.aaa.gl) begins '2240'
                   or txb.aaa.gl =  213110 or txb.aaa.gl =  213120 )
                   no-lock.
    v-lcsum1 = 0.
    find first txb.trxlevgl where txb.trxlevgl.gl     eq  txb.aaa.gl
                              and txb.trxlevgl.subled eq  'cif'
                              and txb.trxlevgl.level  eq  7
                              no-lock no-error.
    if not avail txb.trxlevgl then next.

    for each txb.jl where txb.jl.acc    = txb.aaa.aaa
                      and txb.jl.jdt    < v-dat
                      and txb.jl.lev    = 7
                      and txb.jl.subled = 'cif' no-lock:
        if txb.jl.dc = 'd' then v-lcsum1 = v-lcsum1 + txb.jl.dam.
                           else v-lcsum1 = v-lcsum1 - txb.jl.cam.
    end.
    if v-lcsum1 = 0 then next.

    create temp.
    assign temp.cif     = txb.cif.cif
           temp.name    = trim(txb.cif.sname)
           temp.opf     = trim(txb.cif.prefix)
           temp.vidusl  = 'Гарантия'
           temp.rez     = if txb.cif.irs = 1 then 'резидент' else 'нерезидент'
           temp.filial  = v-bankn
           temp.regdt   = txb.aaa.regdt
           temp.expdt   = txb.aaa.expdt
           temp.nps     = '6555'.

    find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = txb.aaa.cif  and  txb.sub-cod.d-cod = 'ecdivis'  no-lock no-error.
    if avail txb.sub-cod then do:
       find first txb.codfr where txb.codfr.codfr = 'ecdivis'
                              and txb.codfr.code  = txb.sub-cod.ccode
                              no-lock no-error.
        if avail txb.codfr then temp.ecdivis = txb.codfr.name[1].
    end.
    find txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
    if avail txb.crc then temp.code = txb.crc.code.

    find first prisv where prisv.rnn = txb.cif.jss no-lock no-error.
    if avail prisv then do:
        find first txb.codfr where txb.codfr.codfr = 'affil'
                               and txb.codfr.code = prisv.specrel no-lock no-error.
        if avail txb.codfr then temp.ins = codfr.name[1].
    end.
    else temp.ins = 'не связан'.

    find first txb.garan where txb.garan.garan = txb.aaa.aaa and txb.garan.cif = txb.cif.cif no-lock no-error.
	if avail txb.garan then do:
        assign temp.ref      = txb.garan.info[1]
               temp.sumtreb  = txb.garan.sumtreb
               temp.sumzalog = txb.garan.sum
               temp.naim     = txb.garan.naim
               temp.sumkom   = txb.garan.sumkom.

        for each txb.lonsec1 where txb.lonsec1.lon = txb.garan.garan no-lock:
            find first txb.lonsec where txb.lonsec.lonsec = int(txb.lonsec1.lonsec) no-lock no-error.
            if avail txb.lonsec then temp.zalog = if temp.zalog = '' then txb.lonsec.des else ';' + txb.lonsec.des.
            temp.zalog = temp.zalog  + ',' + txb.lonsec1.pielikums[1].
            if txb.lonsec1.secamt <> 0 then do:
                temp.zalog = temp.zalog  + ',' + string(txb.lonsec1.secamt,'>>>>>>>>>>>9.99').
                find txb.crc where txb.crc.crc = txb.lonsec1.crc no-lock no-error.
                if avail txb.crc then temp.zalog = temp.zalog  + ' ' + txb.crc.code.
            end.
            temp.zalog = temp.zalog  + ',' + txb.lonsec1.prm + ',' + txb.lonsec1.vieta.
        end.
        if temp.zalog = '' then do:
            find first txb.lonsec where txb.lonsec.lonsec = int(txb.garan.obes) no-lock no-error.
            if avail txb.lonsec then temp.zalog = txb.lonsec.des.
        end.

        find last txb.lonhar where txb.lonhar.lon = txb.garan.garan and txb.lonhar.fdt < v-dat no-lock no-error.
        if avail txb.lonhar then do:
            find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
            if avail txb.lonstat then temp.classif = txb.lonstat.apz.
        end.

        find last kdlonkl where kdlonkl.bank = v-bank and kdlonkl.kdcif = txb.cif.cif and kdlonkl.kdlon = txb.garan.garan and kdlonkl.kod = 'finsost1' and kdlonkl.rdt < v-dat no-lock no-error.
        if avail kdlonkl then temp.bal1 = kdlonkl.rating.

        find last kdlonkl where kdlonkl.bank = v-bank and kdlonkl.kdcif = txb.cif.cif and kdlonkl.kdlon = txb.garan.garan and kdlonkl.kod = 'prosr' and kdlonkl.rdt < v-dat no-lock no-error.
        if avail kdlonkl then temp.bal2 = kdlonkl.rating.

        find last kdlonkl where kdlonkl.bank = v-bank and kdlonkl.kdcif = txb.cif.cif and kdlonkl.kdlon = txb.garan.garan and kdlonkl.kod = 'rait' and kdlonkl.rdt < v-dat no-lock no-error.
        if avail kdlonkl then temp.bal3 = kdlonkl.rating.

        temp.bal4 = temp.bal1 + temp.bal2 + temp.bal3.
    end.
    else assign temp.sumtreb  = v-lcsum1
                temp.sumzalog = v-lcsum1.
    if  txb.crc.crc <> 1 then
    assign temp.sumtreb  = round(temp.sumtreb  * v-rate[txb.crc.crc - 1],2)
           temp.sumzalog = temp.sumtreb
           temp.sumkom   = round(temp.sumkom   * v-rate[txb.crc.crc - 1],2).

end.

/* Trade Finance */
for each lc where lc.bank = v-bank and lc.lctype = 'i' and lookup(lc.lcsts,'fin,cls,cln') > 0 no-lock:
    if lc.lcsts <> 'fin' then do:
        find last lcsts
        where     lcsts.lcnum = lc.lc
        and       lcsts.sts   = lc.lcsts
        no-lock no-error.
        if avail lcsts and lcsts.whn < v-dat then next.
    end.

    if lc.lc begins 'pg' then v-gar = yes. else v-gar = no.

    find first lch where lch.lc = lc.lc and lch.kritcode = 'cover' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        message "Не найден реквизит Covered/Uncovered для " lc.lc "!" view-as alert-box.
        next.
    end.
    v-cov = lch.value1.

    v-cod = if v-gar then 'Date' else 'DtIs'.
    find first lch where lch.lc = lc.lc and lch.kritcode = v-cod no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        find first lckrit where lckrit.datacode = v-cod and lckrit.lctype = 'i' no-lock no-error.
        v-name = if avail lckrit then lckrit.dataname else ''.
        message "Не найден реквизит " v-name " для " lc.lc "!" view-as alert-box.
        next.
    end.
    if date(lch.value1) >= v-dat then next.
    v-dt1 = date(lch.value1).

    find first lch where lch.lc = lc.lc and lch.kritcode = 'DtExp' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        message "Не найден реквизит Date of Expiry для " lc.lc "!" view-as alert-box.
        next.
    end.

    find last lcamendh where lcamendh.bank = v-bank and lcamendh.lc = lc.lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
    if avail lcamendh then v-dt2 = date(lcamendh.value1).
    else v-dt2 = date(lch.value1).

    /* подсчет остатка */
    assign v-lcsum1 = 0
           v-lcsum2 = 0
           v-lcsum3 = 0.
    find first lch where lch.lc = lc.lc and lch.kritcode = 'amount' no-lock no-error.
    if not avail lch then message "Не найден реквизит Amount для " lc.lc "!" view-as alert-box.
    else v-lcsum1 = decimal(lch.value1).

    find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
    if avail lch and lch.value1 ne '' then do:
        v-per = int(entry(1,lch.value1, '/')).
        if v-per > 0 then v-lcsum1 = v-lcsum1 + (v-lcsum1 * (v-per / 100)).
    end.

    /* amendment */
    if v-gar then
    for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.dacc = '605561' or  lcamendres.dacc = '655561' or lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0  no-lock:
        find first txb.jh where txb.jh.jh = lcamendres.jh no-lock no-error.
        if not avail txb.jh then message "Не найдена проводка " lcamendres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
        else do:
            if txb.jh.jdt >= v-dat then next.
            if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsum1 = v-lcsum1 + lcamendres.amt.
            else v-lcsum1 = v-lcsum1 - lcamendres.amt.
        end.
    end.
    else
    for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.levD = 23 or  lcamendres.levD = 24 or lcamendres.levC = 23 or  lcamendres.levC = 24) and lcamendres.jh > 0  no-lock:
        find first txb.jh where txb.jh.jh = lcamendres.jh no-lock no-error.
        if not avail txb.jh then message "Не найдена проводка " lcamendres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
        else do:
            if txb.jh.jdt >= v-dat then next.
            if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsum1 = v-lcsum1 + lcamendres.amt.
            else v-lcsum1 = v-lcsum1 - lcamendres.amt.
        end.
    end.
    v-lcsum2 = v-lcsum1.
    /* expire, cancel */
    if v-gar then find first lceventres where lceventres.lc = lc.lc and (lceventres.event = 'exp' or lceventres.event = 'cnl') and lceventres.number = 1 and (lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock no-error.
    else find first lceventres where lceventres.lc = lc.lc and (lceventres.event = 'exp' or lceventres.event = 'cnl') and lceventres.number = 1 and (lceventres.levC = 23 or  lceventres.levC = 24) and lceventres.jh > 0 no-lock no-error.
    if avail lceventres then do:
        find first txb.jh where txb.jh.jh = lceventres.jh no-lock no-error.
        if not avail jh then message "Не найдена проводка " lceventres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
        else if txb.jh.jdt < v-dat then v-lcsum2 = 0.
    end.
    if v-lcsum2 <> 0 then do:
        /* payment */
        if v-gar then do:
            for each lcpayres where lcpayres.lc = lc.lc and (lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
                find first txb.jh where txb.jh.jh = lcpayres.jh no-lock no-error.
                if not avail jh then message "Не найдена проводка " lcpayres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
                else do:
                    if txb.jh.jdt >= v-dat then next.
                    v-lcsum2 = v-lcsum2 - lcpayres.amt.
                end.
            end.
        end.
        else
        for each lcpayres where lcpayres.lc = lc.lc and (lcpayres.levC = 23 or  lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
            find first txb.jh where txb.jh.jh = lcpayres.jh no-lock no-error.
            if not avail jh then message "Не найдена проводка " lcpayres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
            else do:
                if txb.jh.jdt >= v-dat then next.
                v-lcsum2 = v-lcsum2 - lcpayres.amt.
            end.
        end.
        /* event */
        for each lceventres where lceventres.lc = lc.lc and lceventres.event <> 'exp' and lceventres.event <> 'cnl' and (lceventres.dacc = '655561' or lceventres.dacc = '655562' or lceventres.levC = 23 or  lceventres.levC = 24) and lceventres.jh > 0 no-lock.
            find first txb.jh where txb.jh.jh = lceventres.jh no-lock no-error.
            if not avail jh then message "Не найдена проводка " lceventres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
            else do:
                if txb.jh.jdt >= v-dat then next.
                assign v-lcsum2 = v-lcsum2 - lceventres.amt.
            end.
        end.
    end.
    if v-lcsum2 = 0 then next.

    create temp.
    assign temp.filial = v-bankn
           temp.vidusl = if v-gar  then 'Гарантия' else 'Аккредитив'
           temp.ref    = lc.lc
           temp.nps    = if v-gar then '6555' else if v-cov = '0' then '6520' else '6505'
           temp.regdt  = v-dt1
           temp.expdt  = v-dt2.


    find first lch where lch.lc = lc.lc and lch.kritcode = 'lcCrc' no-lock no-error.
    if avail lch and lch.value1 <> ? then do:
        find txb.crc where txb.crc.crc = int(lch.value1) no-lock no-error.
        if avail txb.crc then temp.code = txb.crc.code.
    end.

    if  txb.crc.crc <> 1 then do:
        temp.sumtreb = round(v-lcsum2 * v-rate[txb.crc.crc - 1],2).
        if v-cov = '0' then temp.sumzalog = round(v-lcsum1 * v-rate[txb.crc.crc - 1],2).
    end.
    else do:
        temp.sumtreb = v-lcsum2.
        if v-cov = '0' then temp.sumzalog = v-lcsum1.
    end.

    find first lch where lch.lc = lc.lc and lch.kritcode = 'Benef' no-lock no-error.
    if avail lch then temp.naim = trim(substr(lch.value1,1,35)).

    for each lcres where lcres.lc = lc.lc and lcres.com and lcres.jh > 0 no-lock.
        find first txb.jh where txb.jh.jh = lcres.jh no-lock no-error.
        if not avail jh then message "Не найдена проводка " lcres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
        else do:
            if txb.jh.jdt >= v-dat then next.
            v-lcsum3 = v-lcsum3 + lcres.amt.
        end.
    end.
    temp.sumkom = if  txb.crc.crc <> 1 then round(v-lcsum3 * v-rate[txb.crc.crc - 1],2) else v-lcsum3.

    find first txb.cif where txb.cif.cif = lc.cif no-lock no-error.
    if avail txb.cif then do:
        assign temp.cif    = txb.cif.cif
               temp.name   = trim(txb.cif.sname)
               temp.opf    = trim(txb.cif.prefix)
               temp.rez    = if txb.cif.irs = 1 then 'резидент' else 'нерезидент'.

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = txb.cif.cif  and  txb.sub-cod.d-cod = 'ecdivis'  no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivis'
                                   and txb.codfr.code  = txb.sub-cod.ccode
                                   no-lock no-error.
            if avail txb.codfr then temp.ecdivis = txb.codfr.name[1].
        end.

        find first prisv where prisv.rnn = txb.cif.jss no-lock no-error.
        if avail prisv then do:
            find first txb.codfr where txb.codfr.codfr = 'affil'
                                   and txb.codfr.code = prisv.specrel no-lock no-error.
            if avail txb.codfr then temp.ins = codfr.name[1].
        end.
        else temp.ins = 'не связан'.
    end.
    temp.zalog = if v-cov = '0' then 'Деньги(депозиты)' else 'Бланковые(беззалоговые)'.
end.