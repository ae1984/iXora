/* FS_functions_txb.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - FS_colldata_txb.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        28.01.2013 damir - Внедрено Т.З. № 1217,1218,1227.
*/
function Igl return inte(input p-gl as inte,input p-lev as inte,input p-acc as char,input p-des as char,input p-sub as char,input p-crc as inte,
                         input v-r as char,input v-cgr as char,input v-hs as char).
    def var v-gl as inte.
    def var v-code as char.
    def var v-bal as deci.
    def var v-bal_beg as deci.
    def var v-bal_end as deci.

    v-bal = 0. v-bal_beg = 0. v-bal_end = 0.
    v-gl = GetGlLev(p-gl,p-lev).
    find txb.gl where txb.gl.gl eq v-gl and txb.gl.totlev eq 1 and txb.gl.totgl ne 0 no-lock no-error.
    if avail txb.gl then do:
        v-code = string(truncate(v-gl / 100,0)) + v-r + v-cgr + v-hs.
        if v-code eq ? or index(v-code,"msc") gt 0 then return 1.

        if v-dtb ne ? and v-dte ne ? then do:
            run lonbalcrc_txb(p-sub,p-acc,v-dtb,p-lev,no,p-crc,output v-bal_beg).
            run lonbalcrc_txb(p-sub,p-acc,v-dte,p-lev,yes,p-crc,output v-bal_end).
        end.
        if v-gldate ne ? then run lonbalcrc_txb(p-sub,p-acc,v-gldate,p-lev,s-includetoday,p-crc,output v-bal).
        /*Liabilities-L,Revenue-R*/
        if txb.gl.type eq "L" or txb.gl.type eq "R" then do:
            v-bal_beg = - v-bal_beg.
            v-bal_end = - v-bal_end.
            v-bal = - v-bal.
        end.

        create tgl.
        tgl.txb = s-ourbank.
        tgl.gl = txb.gl.gl.
        tgl.gl4 = inte(substr(v-code,1,4)) no-error.
        tgl.gl7 = inte(v-code) no-error.
        tgl.gl-des = txb.gl.des.
        tgl.crc = p-crc.
        tgl.level = p-lev.
        tgl.sum = CRC2KZT(yes,v-bal,p-crc,v-gldate).
        tgl.sum_crcpro = CRC2KZT_Prog(yes,v-bal,p-crc,v-gldate).
        tgl.sum_beg = CRC2KZT_Prog(no,v-bal_beg,p-crc,v-dtb).
        tgl.sum_end = CRC2KZT_Prog(yes,v-bal_end,p-crc,v-dte).
        tgl.type = txb.gl.type.
        tgl.sub-type = p-sub.
        tgl.code = txb.gl.code.
        tgl.grp = txb.gl.grp.
        tgl.acc = p-acc.
        tgl.acc-des = p-des.
        tgl.geo = "02" + v-r.
    end.
end function.





