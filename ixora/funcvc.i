/* funcvc.i
 * MODULE
        Название модуля - Функции и процедуры, используемые в ВАЛКОНЕ для БАЗЫ BANK
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        29.06.2012 damir.
        25.12.2012 damir - Внедрено Т.З. № 1306. Добавлены функции.
*/

function konv2usd returns deci(p-sum as deci, p-crc as inte, p-date as date).
    def var vp-sum      as deci.
    def var v-kurs      as deci init 0.
    def var v-cursusd2  as deci.

    if p-crc = 2 then vp-sum = p-sum.
    else do:
        find last ncrchis where ncrchis.crc = p-crc and ncrchis.rdt <= p-date no-lock no-error.
        if avail ncrchis and ncrchis.rate[1] <> 0 then v-kurs = ncrchis.rate[1].
        else do:
            find last ncrchis where ncrchis.crc = p-crc and ncrchis.rdt <= p-date and ncrchis.rate[1] <> 0 no-lock no-error.
            if avail ncrchis then v-kurs = ncrchis.rate[1].
            else v-kurs = 1.
        end.
        find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= p-date no-lock no-error.
        if avail ncrchis then v-cursusd2 = ncrchis.rate[1].

        vp-sum = (p-sum * v-kurs) / v-cursusd2.
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

procedure RECNAME.
    def input  parameter p-bank      as char.
    def output parameter p-out_one   as char.
    def output parameter p-out_two   as char.

    if connected ("txb") then disconnect "txb".
    for each comm.txb where comm.txb.consolid = true and comm.txb.bank = p-bank no-lock:
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
        run vccontxb(output p-out_one,output p-out_two).
        disconnect "txb".
    end.
    if connected ("txb") then disconnect "txb".
end procedure.

function check_term returns deci(p-term as char).
    def var v-repdays as inte.
    def var v-repyears as inte.
    def var v-srokrep as deci.

    v-repdays = inte(substr(string(p-term,'999.99' ),1,3)).
    v-repyears = inte(substr(string(p-term, '999.99'),5,2)).

    if (v-repdays <= 360 and v-repyears = 0) then v-srokrep = v-repdays.
    if (v-repdays <= 360 and v-repyears > 0) then v-srokrep = v-repdays + v-repyears * 360.

    return v-srokrep.
end.
