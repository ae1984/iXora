/* vcconv.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур - vccomcreddat.p
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        25.12.2012 damir - Внедрено Т.З. № 1306.
*/
function konv2usd returns deci(input p-sum as deci,input p-crc as inte,input p-date as date).
    def var vp-sum as deci.
    def var v-kurs as deci.
    def var v-cursusd as deci.

    if p-crc = 2 then vp-sum = p-sum.
    else do:
        find last txb.ncrchis where txb.ncrchis.crc = p-crc and txb.ncrchis.rdt <= p-date no-lock no-error.
        if avail txb.ncrchis and txb.ncrchis.rate[1] <> 0 then v-kurs = txb.ncrchis.rate[1].
        else do:
            find last txb.ncrchis where txb.ncrchis.crc = p-crc and txb.ncrchis.rdt <= p-date and txb.ncrchis.rate[1] <> 0 no-lock no-error.
            if avail txb.ncrchis then v-kurs = txb.ncrchis.rate[1].
            else v-kurs = 1.
        end.
        find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= p-date no-lock no-error.
        if avail txb.ncrchis then v-cursusd = txb.ncrchis.rate[1].

        vp-sum = (p-sum * v-kurs) / v-cursusd.
    end.

    return vp-sum.
end.

function konv2usd_docs returns deci(input p-sum as deci,input p-crc as inte,input p-contract as inte,input p-dntype as char,
input p-dt as date,input p-reciw as recid).
    def var v-res as deci.

    v-res = 0.
    if p-crc = 2 then v-res = p-sum.
    else do:
        find comm.vccontrs where comm.vccontrs.contract = p-contract no-lock no-error.
        if avail comm.vccontrs then do:
            find comm.vcdocs where comm.vcdocs.contract = comm.vccontrs.contract and trim(comm.vcdocs.dntype) = trim(p-dntype) and
            comm.vcdocs.dndate = p-dt and comm.vcdocs.pcrc = p-crc and round(comm.vcdocs.sum,2) = round(p-sum,2) and
            recid(comm.vcdocs) = p-reciw no-lock no-error.
            if avail comm.vcdocs then v-res = konv2usd(comm.vcdocs.sum / comm.vcdocs.cursdoc-con,comm.vccontrs.ncrc,p-dt - 1).
        end.
    end.

    return v-res.
end function.

function konv2concrc returns deci(input p-sum as deci,input p-crc1 as inte,input p-crc2 as inte,input p-date as date).
    def var vp-sum as deci.
    def var v-kurs_1 as deci.
    def var v-kurs_2 as deci.

    vp-sum = 0. v-kurs_1 = 0. v-kurs_2 = 0.

    find last txb.ncrchis where txb.ncrchis.crc = p-crc1 and txb.ncrchis.rdt <= p-date no-lock no-error.
    if avail txb.ncrchis and txb.ncrchis.rate[1] <> 0 then v-kurs_1 = txb.ncrchis.rate[1].

    find last txb.ncrchis where txb.ncrchis.crc = p-crc2 and txb.ncrchis.rdt <= p-date no-lock no-error.
    if avail txb.ncrchis and txb.ncrchis.rate[1] <> 0 then v-kurs_2 = txb.ncrchis.rate[1].

    vp-sum = p-sum * v-kurs_1 / v-kurs_2.

    return vp-sum.
end.

function check_term returns deci(input p-term as char).
    def var v-repdays as inte.
    def var v-repyears as inte.
    def var v-srokrep as deci.

    v-repdays = inte(substr(string(p-term,'999.99' ),1,3)).
    v-repyears = inte(substr(string(p-term, '999.99'),5,2)).

    if (v-repdays <= 360 and v-repyears = 0) then v-srokrep = v-repdays.
    if (v-repdays <= 360 and v-repyears > 0) then v-srokrep = v-repdays + v-repyears * 360.

    return v-srokrep.
end.


