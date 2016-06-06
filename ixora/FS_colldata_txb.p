/* FS_colldata_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы - Сбор данных для различных видов отчетностей.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - FS_GA.p,FS_KA.p,7SB_rep.p,FS_PPN.p,SoursOfFing.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        28.01.2013 damir - Внедрено Т.З. № 1217,1218,1227.
*/
{FS_general.i}

def var s-ourbank as char.
def var s-namebnk as char.
def var v-bankn as char.
def var v-gl as inte.
def var v-hs as char.
def var v-cgr as char.
def var v-r as char.
def var v-code as char.
def var v-geoi as inte.
def var v-cgri as inte.
def var v-bal as deci.
def var v-bank as char.
def var v-mfo as char.
def var v-day as char.
def var v-mon as char.
def var v-god as char.
def var j as inte.
def var sum1 as deci.
def var sum2 as deci.
def var v-basedy as inte.
def var v-dn1 as inte.
def var v-dn2 as inte.
def var v-overdueDay_lev_7 as inte.
def var v-overdueDay_lev_9 as inte.
def var v-bal_lev_1 as deci.
def var v-bal_lev_1_beg as deci.
def var v-bal_lev_1_end as deci.
def var v-bal_lev_2 as deci.
def var v-bal_lev_7 as deci.
def var v-bal_lev_7_beg as deci.
def var v-bal_lev_7_end as deci.
def var v-bal_lev_9 as deci.
def var v-bal_lev_49 as deci.
def var v-bal_lev_41 as deci.
def var v-bal_lev_42 as deci.
def var v-bal_lev_6 as deci.
def var v-bal_lev_36 as deci.
def var v-bal_lev_37 as deci.
def var v-bal_lev_16 as deci.
def var v-bal_lev_19 as deci.
def var v-bal_lev_19_all as deci.
def var v-GLch as char.
def var v-KOd as char.
def var v-KBe as char.
def var v-KNP as char.
def var v-DPScode as char.
def var v-Attribute as char.
def var v-Subledger as char.
def var v-Account as char.
def var v-GeneralLedger as inte.
def var v-GeneralLedgerCrc as inte.
def var v-DateGeneralLedger as date.
def var v-Storn as logi.
def var v-naznplat as char.
def var v-b-jlDPS as inte.
def var v-jlDPS as inte.

{FreqUsedFunc_txb.i}
{FS_functions_txb.i}

s-ourbank = GetSysc("ourbnk").
find first txb.cmp no-lock no-error.
if avail txb.cmp then s-namebnk = trim(txb.cmp.name).

v-bankn = GetFilName(s-ourbank).
display v-bankn no-labels format "x(20)" with row 8 frame ww centered title "СБОР ИНФОРМАЦИИ".

def buffer b-trxbal for txb.trxbal.
def buffer b-jl for txb.jl.

if lookup(s-RepName,"FS_GA,FS_KA,7SB_rep") gt 0 then do:

    for each b-trxbal no-lock:
        if b-trxbal.sub eq "arp" then do:
            find txb.arp where txb.arp.arp eq b-trxbal.acc no-lock no-error.
            if not avail txb.arp then next.
            v-Subledger = b-trxbal.sub. v-Account = b-trxbal.acc.
            run ProcDPSCode.
            Igl(txb.arp.gl,b-trxbal.lev,b-trxbal.acc,txb.arp.des,b-trxbal.sub,b-trxbal.crc,v-r,v-cgr,v-hs).
            if b-trxbal.lev eq 1 then run AddCollData.
        end.
        if b-trxbal.sub eq "ast" then do:
            find txb.ast where txb.ast.ast eq b-trxbal.acc no-lock no-error.
            if not avail txb.ast then next.
            v-Subledger = b-trxbal.sub. v-Account = b-trxbal.acc.
            run ProcDPSCode.
            Igl(txb.ast.gl,b-trxbal.lev,b-trxbal.acc,txb.ast.name,b-trxbal.sub,b-trxbal.crc,v-r,v-cgr,v-hs).
            if b-trxbal.lev eq 1 then run AddCollData.
        end.
        if b-trxbal.sub eq "cif" then do:
            find txb.aaa where txb.aaa.aaa eq b-trxbal.acc no-lock no-error.
            if not avail txb.aaa then next.
            find txb.cif where txb.cif.cif eq txb.aaa.cif no-lock no-error.
            if not avail txb.cif then next.
            v-Subledger = b-trxbal.sub. v-Account = b-trxbal.acc.
            run ProcDPSCode.
            Igl(txb.aaa.gl,b-trxbal.lev,b-trxbal.acc,txb.cif.name,b-trxbal.sub,b-trxbal.crc,v-r,v-cgr,v-hs).
            if b-trxbal.lev eq 1 then run AddCollData.
        end.
        if b-trxbal.sub eq "dfb" then do:
            find txb.dfb where txb.dfb.dfb eq b-trxbal.acc no-lock no-error.
            if not avail txb.dfb then next.
            v-Subledger = b-trxbal.sub. v-Account = b-trxbal.acc.
            run ProcDPSCode.
            Igl(txb.dfb.gl,b-trxbal.lev,b-trxbal.acc,txb.dfb.name,b-trxbal.sub,b-trxbal.crc,v-r,v-cgr,v-hs).
            if b-trxbal.lev eq 1 then run AddCollData.
        end.
        if b-trxbal.sub eq "fun" then do:
            find txb.fun where txb.fun.fun eq b-trxbal.acc no-lock no-error.
            if not avail txb.fun then next.
            v-Subledger = b-trxbal.sub. v-Account = b-trxbal.acc.
            run ProcDPSCode.
            Igl(txb.fun.gl,b-trxbal.lev,b-trxbal.acc,txb.fun.accrcv,b-trxbal.sub,b-trxbal.crc,v-r,v-cgr,v-hs).
            if b-trxbal.lev eq 1 then run AddCollData.
        end.
        if b-trxbal.sub eq "scu" then do:
            find txb.scu where txb.scu.scu eq b-trxbal.acc no-lock no-error.
            if not avail txb.scu then next.
            find txb.gl where txb.gl.gl eq txb.scu.gl no-lock no-error.
            v-Subledger = b-trxbal.sub. v-Account = b-trxbal.acc.
            run ProcDPSCode.
            Igl(txb.scu.gl,b-trxbal.lev,b-trxbal.acc,txb.gl.des,b-trxbal.sub,b-trxbal.crc,v-r,v-cgr,v-hs).
            if b-trxbal.lev eq 1 then run AddCollData.
        end.
        if b-trxbal.sub eq "lon" then do:
            find txb.lon where txb.lon.lon eq b-trxbal.acc no-lock no-error.
            if not avail txb.lon then next.
            find txb.cif where txb.cif.cif eq txb.lon.cif no-lock no-error.
            if not avail txb.cif then next.
            v-Subledger = b-trxbal.sub. v-Account = b-trxbal.acc.
            run ProcDPSCode.
            Igl(txb.lon.gl,b-trxbal.lev,b-trxbal.acc,txb.cif.name,b-trxbal.sub,b-trxbal.crc,v-r,v-cgr,v-hs).
        end.
        hide message no-pause.
        message "The main data collection. " b-trxbal.sub " - " b-trxbal.acc " - " s-ourbank.
    end.

    for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl ne 0 no-lock:
        if txb.gl.subled ne "" then next.
        for each txb.crchs no-lock:
            if GetGlday(s-includetoday,txb.gl.gl,txb.crchs.crc,v-gldate) ne 0 then do:
                if txb.crchs.hs eq "L" then v-hs = "1".
                else if txb.crchs.hs eq "H" then v-hs = "2".
                else if txb.crchs.hs eq "S" then v-hs = "3".
                if v-hs eq "1" then v-r = "1".
                else v-r = "2".
                if txb.gl.gl lt 105000 then v-cgr = "3".
                else if string(txb.gl.gl) begins "2551" then v-cgr = "4".
                else v-cgr = "6".
                v-code = string(truncate(txb.gl.gl / 100,0)) + v-r + v-cgr + v-hs.
                create tgl.
                tgl.txb = s-ourbank.
                tgl.gl = txb.gl.gl.
                tgl.gl7 = inte(v-code).
                tgl.gl4 = inte(substr(v-code,1,4)).
                tgl.gl-des = txb.gl.des.
                tgl.level = txb.gl.lev.
                tgl.type = txb.gl.type.
                tgl.sub-type = txb.gl.subled.
                tgl.code = txb.gl.code.
                tgl.grp = txb.gl.grp.
                tgl.crc = txb.gl.crc.
                tgl.sum = GetGlday(s-includetoday,txb.gl.gl,txb.crchs.crc,v-gldate).
                tgl.geo = "02" + v-r.
            end.
        end.
        hide message no-pause.
        message "Processing ledger accounts. GL = " txb.gl.gl " - " s-ourbank.
    end.

end.

if lookup(s-RepName,"FS_GA,FS_KA,7SB_rep") gt 0 then do:

    for each txb.lon no-lock:
        find txb.cif where txb.cif.cif eq txb.lon.cif no-lock no-error.
        if not avail txb.cif then next.

        v-bal_lev_1 = 0. v-bal_lev_1_beg = 0. v-bal_lev_1_end = 0. v-bal_lev_2 = 0. v-bal_lev_7 = 0. v-bal_lev_7_beg = 0. v-bal_lev_7_end = 0.
        v-bal_lev_9 = 0. v-bal_lev_49 = 0. v-bal_lev_9 = 0. v-bal_lev_41 = 0. v-bal_lev_42 = 0. v-bal_lev_6 = 0. v-bal_lev_36 = 0. v-bal_lev_37 = 0.
        v-bal_lev_16 = 0. v-Attribute = "".

        if v-dtb ne ? and v-dte ne ? then do:
            run lonbalcrc_txb("lon",txb.lon.lon,v-dtb,"1",no,txb.lon.crc,output v-bal_lev_1_beg).
            run lonbalcrc_txb("lon",txb.lon.lon,v-dte,"1",yes,txb.lon.crc,output v-bal_lev_1_end).
            run lonbalcrc_txb("lon",txb.lon.lon,v-dtb,"7",no,txb.lon.crc,output v-bal_lev_7_beg).
            run lonbalcrc_txb("lon",txb.lon.lon,v-dte,"7",yes,txb.lon.crc,output v-bal_lev_7_end).

            v-bal_lev_1_beg = CRC2KZT(no,v-bal_lev_1_beg,txb.lon.crc,v-dtb).
            v-bal_lev_1_end = CRC2KZT(yes,v-bal_lev_1_end,txb.lon.crc,v-dte).
            v-bal_lev_7_beg = CRC2KZT(no,v-bal_lev_7_beg,txb.lon.crc,v-dtb).
            v-bal_lev_7_end = CRC2KZT(yes,v-bal_lev_7_end,txb.lon.crc,v-dte).
        end.

        if v-gldate ne ? then do:
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"1",yes,txb.lon.crc,output v-bal_lev_1).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"2",yes,txb.lon.crc,output v-bal_lev_2).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"6",yes,txb.lon.crc,output v-bal_lev_6).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"7",yes,txb.lon.crc,output v-bal_lev_7).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"9",yes,txb.lon.crc,output v-bal_lev_9).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"16",yes,1,output v-bal_lev_16).

            v-bal_lev_19_all = 0.
            for each txb.crc no-lock:
                v-bal_lev_19 = 0.
                run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"19",yes,txb.crc.crc,output v-bal_lev_19).
                v-bal_lev_19_all = v-bal_lev_19_all + CRC2KZT(yes,v-bal_lev_19,txb.crc.crc,v-gldate).
            end.

            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"36",yes,txb.lon.crc,output v-bal_lev_36).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"37",yes,1,output v-bal_lev_37).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"41",yes,txb.lon.crc,output v-bal_lev_41).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"42",yes,txb.lon.crc,output v-bal_lev_42).
            run lonbalcrc_txb("lon",txb.lon.lon,v-gldate,"49",yes,txb.lon.crc,output v-bal_lev_49).

            v-bal_lev_1 = CRC2KZT(yes,v-bal_lev_1,txb.lon.crc,v-gldate).
            v-bal_lev_2 = CRC2KZT(yes,v-bal_lev_2,txb.lon.crc,v-gldate).
            v-bal_lev_6 = - CRC2KZT(yes,v-bal_lev_6,txb.lon.crc,v-gldate).
            v-bal_lev_7 = CRC2KZT(yes,v-bal_lev_7,txb.lon.crc,v-gldate).
            v-bal_lev_9 = CRC2KZT(yes,v-bal_lev_9,txb.lon.crc,v-gldate).
            v-bal_lev_16 = CRC2KZT(yes,v-bal_lev_16,1,v-gldate).
            v-bal_lev_36 = - CRC2KZT(yes,v-bal_lev_36,txb.lon.crc,v-gldate).
            v-bal_lev_37 = - CRC2KZT(yes,v-bal_lev_37,1,v-gldate).
            v-bal_lev_41 = - CRC2KZT(yes,v-bal_lev_41,txb.lon.crc,v-gldate).
            v-bal_lev_42 = - CRC2KZT(yes,v-bal_lev_42,txb.lon.crc,v-gldate).
            v-bal_lev_49 = CRC2KZT(yes,v-bal_lev_49,txb.lon.crc,v-gldate).
        end.

        v-basedy = 365. v-dn1 = 0. v-dn2 = 0.
        run day-360(txb.lon.rdt,txb.lon.duedt - 1,v-basedy,output v-dn1,output v-dn2).

        create t-wrk.
        t-wrk.txb = s-ourbank.
        t-wrk.namebnk = s-namebnk.
        t-wrk.sub = "lon".
        if avail txb.cif then do:
            t-wrk.cif = txb.cif.cif.
            t-wrk.type = txb.cif.type.
            t-wrk.cgr = txb.cif.cgr.
            t-wrk.geo = substr(trim(txb.cif.geo),3,1).
            t-wrk.acc-des = trim(txb.cif.name) + " " + trim(txb.cif.prefix).
            t-wrk.codfr_lnopf = GetSubCodCode("cln",txb.cif.cif,"lnopf").
            t-wrk.otrasl = GetSubCodCodfr("cln",txb.cif.cif,"ecdivis").
        end.
        find first txb.cgr where txb.cgr.cgr eq txb.cif.cgr no-lock no-error.
        if avail txb.cgr then t-wrk.cgrname = string(txb.cgr.cgr) + " " + trim(txb.cgr.name).
        find txb.loncon where txb.loncon.lon eq txb.lon.lon no-lock no-error.
        if avail txb.loncon then t-wrk.lcnt = txb.loncon.lcnt.
        find last txb.lonhar where txb.lonhar.lon eq txb.lon.lon no-lock no-error.
        if avail txb.lonhar then do:
            find last txb.lonstat where txb.lonstat.lonstat eq txb.lonhar.lonstat no-lock no-error.
            if avail txb.lonstat then do:
                t-wrk.apz = txb.lonstat.apz.
                t-wrk.lonstat = txb.lonstat.lonstat.
            end.
        end.
        t-wrk.aaa = txb.lon.aaa.
        t-wrk.grp = txb.lon.grp.
        t-wrk.poolId = RetPoolId(t-wrk.grp).
        t-wrk.cifloncode = GetCifLonCode(t-wrk.grp).
        t-wrk.gl_4 = inte(substr(string(txb.lon.gl),1,4)).
        t-wrk.objekts = GetSubCodCodfr("lon",txb.lon.lon,"lntgt").
        t-wrk.codeuse = GetCodeUse(t-wrk.objekts).
        t-wrk.orienofloan = GetSubCodCodfr("lon",txb.lon.lon,"lntgt_1").
        t-wrk.prcKfn = v-bal_lev_41 / (v-bal_lev_1 + v-bal_lev_7) * 100.
        t-wrk.procmsfo = (v-bal_lev_6 + v-bal_lev_36 + v-bal_lev_37) / (v-bal_lev_1 + v-bal_lev_7 + (v-bal_lev_2 + v-bal_lev_49) + v-bal_lev_9 + v-bal_lev_16).
        if t-wrk.prcKfn eq ? then t-wrk.prcKfn = 0.
        if t-wrk.procmsfo eq ? or t-wrk.procmsfo lt 0 then t-wrk.procmsfo = 0.
        t-wrk.procmsfo = t-wrk.procmsfo * 100.
        t-wrk.codeclass = GetClassKFN(t-wrk.prcKfn).
        t-wrk.rdt = txb.lon.rdt.
        t-wrk.duedt = txb.lon.duedt.
        if v-bal_lev_7 gt 0 or v-bal_lev_9 gt 0 then run lndayspr_txb(txb.lon.lon,v-gldate,no,output t-wrk.overdueDay_lev_7,output t-wrk.overdueDay_lev_9).
        if v-dn1 ne 0 then t-wrk.dnpogash = v-dn1.
        if txb.lon.ddt[5] ne ? then t-wrk.dprolong = txb.lon.ddt[5].
        else if txb.lon.cdt[5] ne ? then t-wrk.dprolong = txb.lon.cdt[5].
        else t-wrk.dprolong = ?.
        if txb.lon.prem gt 0 then t-wrk.prem_his = txb.lon.prem.
        else if txb.lon.prem1 gt 0 then t-wrk.prem_his = txb.lon.prem1.
        else do:
            find last txb.ln%his where txb.ln%his.lon eq txb.lon.lon and txb.ln%his.intrate gt 0 no-lock no-error.
            if avail txb.ln%his then t-wrk.prem_his = txb.ln%his.intrate.
            else do:
                find first comm.pkanketa where comm.pkanketa.bank eq s-ourbank and comm.pkanketa.lon eq txb.lon.lon no-lock no-error.
                if avail comm.pkanketa then t-wrk.prem_his = comm.pkanketa.rateq.
            end.
        end.
        t-wrk.lnpmt = GetSubCodCodfr("lon",txb.lon.lon,"lnpmtper").
        t-wrk.lnpmt% = GetSubCodCodfr("lon",txb.lon.lon,"lnpmtper%").
        if v-bal_lev_1 gt 0 or v-bal_lev_2 gt 0 then do:
            run GetPeriodClass("lon",txb.lon.lon,0,0,output t-wrk.per1-30,output t-wrk.per31-90,output t-wrk.per91-180,output t-wrk.per181-365,
            output t-wrk.per366-730,output t-wrk.per731-1095,output t-wrk.per1096-1825,output t-wrk.per1826).
        end.
        for each txb.lonsec1 where txb.lonsec1.lon eq txb.lon.lon no-lock:
            case txb.lonsec1.lonsec:
                when 3 then t-wrk.sumdepcrd = t-wrk.sumdepcrd + CRC2KZT(yes,txb.lonsec1.secamt,txb.lonsec1.crc,v-gldate).
                when 6 then t-wrk.sumgarant = t-wrk.sumgarant + CRC2KZT(yes,txb.lonsec1.secamt,txb.lonsec1.crc,v-gldate).
                otherwise t-wrk.obessum_kzt = t-wrk.obessum_kzt + CRC2KZT(yes,txb.lonsec1.secamt,txb.lonsec1.crc,v-gldate).
            end case.
            find first txb.lonsec where txb.lonsec.lonsec eq txb.lonsec1.lonsec no-lock no-error.
            if avail txb.lonsec then do:
                if lookup(txb.lonsec.des1,t-wrk.obesdes) eq 0 then do:
                    if t-wrk.obesdes ne "" then t-wrk.obesdes = t-wrk.obesdes + ",".
                    t-wrk.obesdes = t-wrk.obesdes + txb.lonsec.des1.
                end.
            end.
        end.
        if t-wrk.otrasl eq "" then t-wrk.otrasl = "НЕ ПРОСТАВЛЕНА".
        t-wrk.obesall = t-wrk.obessum_kzt + t-wrk.sumgarant + t-wrk.sumdepcrd.
        t-wrk.neobesp = (v-bal_lev_1 + v-bal_lev_7) - t-wrk.obesall.
        if t-wrk.neobesp lt 0 then t-wrk.neobesp = 0.

        v-Subledger = "lon". v-Account = txb.lon.lon.
        run ProcDPSCode.

        t-wrk.gl_7 = inte(substr(string(txb.lon.gl),1,4) + v-r + v-cgr + v-hs).
        t-wrk.gua = txb.lon.gua.
        t-wrk.lon = txb.lon.lon.
        t-wrk.clmain = txb.lon.clmain.
        t-wrk.bal_1 = v-bal_lev_1.
        t-wrk.bal_1_beg = v-bal_lev_1_beg.
        t-wrk.bal_1_end = v-bal_lev_1_end.
        t-wrk.bal_2 = v-bal_lev_2.
        t-wrk.bal_7 = v-bal_lev_7.
        t-wrk.bal_7_beg = v-bal_lev_7_beg.
        t-wrk.bal_7_end = v-bal_lev_7_end.
        t-wrk.bal_9 = v-bal_lev_9.
        t-wrk.bal_16 = v-bal_lev_16.
        t-wrk.obesall_lev19 = v-bal_lev_19_all.
        t-wrk.bal_49 = v-bal_lev_49.
        t-wrk.bal_41 = v-bal_lev_41.
        t-wrk.bal_42 = v-bal_lev_42.
        t-wrk.bal_6 = v-bal_lev_6.
        t-wrk.bal_36 = v-bal_lev_36.
        t-wrk.bal_37 = v-bal_lev_37.
        t-wrk.crc = txb.lon.crc.
        t-wrk.attribute = v-Attribute.

        hide message no-pause.
        message "Additional information gathering. Loans = " txb.lon.lon " - " s-ourbank.
    end.

end.

pause 0.

if lookup(s-RepName,"FS_GA,FS_KA,7SB_rep") gt 0 then do:

    v-GLch = "1424,1401,1403,1411,1417,1740,1741,9100,1428,1434".
    do j = 1 to num-entries(v-GLch):
        nextGL:
        for each txb.gl where txb.gl.totlev eq 1 and txb.gl.totgl ne 0 no-lock:
            if not (string(txb.gl.gl) begins entry(j,v-GLch)) then next nextGL.
            for each txb.crc no-lock:
                create t-gldy.
                t-gldy.txb = s-ourbank.
                t-gldy.gl_4 = inte(entry(j,v-GLch)) no-error.
                t-gldy.gl = txb.gl.gl.
                if v-gldate ne ? then t-gldy.balkzt = GetGlday(s-includetoday,txb.gl.gl,txb.crc.crc,v-gldate).
                if v-dtb ne ? and v-dte ne ? then do:
                    t-gldy.balkzt_beg = GetGlday(no,txb.gl.gl,txb.crc.crc,v-dtb).
                    t-gldy.balkzt_end = GetGlday(yes,txb.gl.gl,txb.crc.crc,v-dte).
                end.
            end.

            hide message no-pause.
            message "Determination of residues of ledger accounts. GL = " txb.gl.gl " - " s-ourbank.
        end.
    end.

end.

pause 0.

if lookup(s-RepName,"7SB_rep") gt 0 then do:

    v-GLch = "1401,1403,1411,1417,1424".
    nextJL:
    for each b-jl where b-jl.jdt ge v-dtb and b-jl.jdt le v-dte and b-jl.who ne "" no-lock:
        if lookup(substr(string(b-jl.gl),1,4),v-GLch) eq 0 then next nextJL.

        v-KOd = "". V-KBe = "". v-KNP = "". v-Storn = false. v-naznplat = "".

        find first txb.jl where txb.jl.jh eq b-jl.jh and txb.jl.crc eq b-jl.crc and txb.jl.dc ne b-jl.dc and
        (if b-jl.dc eq "D" then txb.jl.cam else txb.jl.dam) eq (if b-jl.dc eq "D" then b-jl.dam else b-jl.cam) and txb.jl.ln ne b-jl.ln no-lock no-error.
        if avail txb.jl then do:
            find first t-TmpRep where t-TmpRep.txb eq s-ourbank and t-TmpRep.jh eq txb.jl.jh and t-TmpRep.D_gl eq (if b-jl.dc eq "D" then b-jl.gl
            else txb.jl.gl) and t-TmpRep.C_gl eq (if b-jl.dc eq "D" then txb.jl.gl else b-jl.gl) and
            t-TmpRep.amt eq (if b-jl.dc eq "D" then b-jl.dam else b-jl.cam) no-lock no-error.
            if not avail t-TmpRep then do:
                find first txb.jh where txb.jh.jh eq txb.jl.jh no-lock no-error.

                create t-TmpRep.
                t-TmpRep.txb = s-ourbank.
                t-TmpRep.namebnk = s-namebnk.
                t-TmpRep.jh = b-jl.jh.
                t-TmpRep.whn = b-jl.jdt.
                t-TmpRep.trx = b-jl.trx.

                v-Storn = txb.jl.rem[1] matches "*storn*" or txb.jl.rem[2] matches "*storn*" or txb.jl.rem[3] matches "*storn*" or
                txb.jl.rem[4] matches "*storn*" or txb.jl.rem[5] matches "*storn*".

                v-naznplat = txb.jl.rem[1] + " " + txb.jl.rem[2] + " " + txb.jl.rem[3] + " " + txb.jl.rem[4] + " " + txb.jl.rem[5].

                v-Subledger = b-jl.subled. v-Account = b-jl.acc. v-GeneralLedger = b-jl.gl. v-GeneralLedgerCrc = b-jl.crc. v-DateGeneralLedger = b-jl.whn.
                run ProcDPSCode.
                v-b-jlDPS = inte(substr(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs).

                v-Subledger = txb.jl.subled. v-Account = txb.jl.acc. v-GeneralLedger = txb.jl.gl. v-GeneralLedgerCrc = txb.jl.crc. v-DateGeneralLedger = txb.jl.whn.
                run ProcDPSCode.
                v-jlDPS = inte(substr(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs).

                if avail txb.jh and (substr(trim(txb.jh.party),1,3) eq "rmz" or substr(trim(txb.jh.party),1,3) eq "jou") then do:
                    run Get_EKNP(substr(trim(txb.jh.party),1,3),substr(trim(txb.jh.party),1,10),"eknp",output v-KOd,output v-KBe,output v-KNP).
                end.
                if b-jl.dc eq "D" then do:
                    run GetCods_txb(v-Storn,b-jl.jh,b-jl.dc,b-jl.dam,b-jl.acc,output v-KOd,output v-KBe,output v-KNP).

                    t-TmpRep.D_gl4 = inte(substr(string(b-jl.gl),1,4)) no-error.
                    t-TmpRep.D_gl = b-jl.gl.
                    t-TmpRep.D_gl7 = v-b-jlDPS.
                    t-TmpRep.D_gldes = GetNameAcc(b-jl.subled,b-jl.acc,b-jl.gl).
                    t-TmpRep.D_geo = substr(string(v-b-jlDPS),5,1).
                    t-TmpRep.D_acc = b-jl.acc.
                    t-TmpRep.D_crc = b-jl.crc.
                    t-TmpRep.D_cgrname = GetNameCgr(b-jl.subled,b-jl.acc).
                    t-TmpRep.C_gl4 = inte(substr(string(txb.jl.gl),1,4)) no-error.
                    t-TmpRep.C_gl = txb.jl.gl.
                    t-TmpRep.C_gl7 = v-jlDPS.
                    t-TmpRep.C_gldes = GetNameAcc(txb.jl.subled,txb.jl.acc,txb.jl.gl).
                    t-TmpRep.C_geo = substr(string(v-jlDPS),5,1).
                    t-TmpRep.C_acc = txb.jl.acc.
                    t-TmpRep.C_crc = txb.jl.crc.
                    t-TmpRep.C_cgrname = GetNameCgr(txb.jl.subled,txb.jl.acc).
                    t-TmpRep.amt = b-jl.dam.
                    t-TmpRep.amtkzt = CRC2KZT_Prog(yes,b-jl.dam,b-jl.crc,b-jl.jdt).
                end.
                else do:
                    run GetCods_txb(v-Storn,b-jl.jh,b-jl.dc,b-jl.cam,b-jl.acc,output v-KOd,output v-KBe,output v-KNP).

                    t-TmpRep.D_gl4 = inte(substr(string(txb.jl.gl),1,4)) no-error.
                    t-TmpRep.D_gl = txb.jl.gl.
                    t-TmpRep.D_gl7 = v-jlDPS.
                    t-TmpRep.D_gldes = GetNameAcc(txb.jl.subled,txb.jl.acc,txb.jl.gl).
                    t-TmpRep.D_geo = substr(string(v-jlDPS),5,1).
                    t-TmpRep.D_acc = txb.jl.acc.
                    t-TmpRep.D_crc = txb.jl.crc.
                    t-TmpRep.D_cgrname = GetNameCgr(txb.jl.subled,txb.jl.acc).
                    t-TmpRep.C_gl4 = inte(substr(string(b-jl.gl),1,4)) no-error.
                    t-TmpRep.C_gl = b-jl.gl.
                    t-TmpRep.C_gl7 = v-b-jlDPS.
                    t-TmpRep.C_gldes = GetNameAcc(b-jl.subled,b-jl.acc,b-jl.gl).
                    t-TmpRep.C_geo = substr(string(v-b-jlDPS),5,1).
                    t-TmpRep.C_acc = b-jl.acc.
                    t-TmpRep.C_crc = b-jl.crc.
                    t-TmpRep.C_cgrname = GetNameCgr(b-jl.subled,b-jl.acc).
                    t-TmpRep.amt = b-jl.cam.
                    t-TmpRep.amtkzt = CRC2KZT_Prog(yes,b-jl.cam,b-jl.crc,b-jl.jdt).
                end.
                t-TmpRep.KOd = v-KOd.
                t-TmpRep.KBe = V-KBe.
                t-TmpRep.KNP = v-KNP.
                t-TmpRep.rem = v-naznplat.
                t-TmpRep.crcrate = CRC2KZTRate_Prog(yes,b-jl.crc,b-jl.jdt).
                pause 0.
            end.
        end.
        hide message no-pause.
        message "Collect loans result. Journal Header = " b-jl.jh " - " s-ourbank.
    end.

end.

hide frame ww.

pause 0.

return.

procedure ProcDPSCode:
    run GetDPSCode(v-Subledger,v-Account,v-GeneralLedger,v-GeneralLedgerCrc,v-DateGeneralLedger,output v-DPScode,output v-Attribute).

    v-r = substr(v-DPScode,1,1).
    v-cgr = substr(v-DPScode,2,1).
    v-hs = substr(v-DPScode,3,1).
end procedure.

procedure AddCollData:
    create t-wrk.
    t-wrk.txb = s-ourbank.
    t-wrk.namebnk = s-namebnk.
    t-wrk.sub = b-trxbal.sub.
    t-wrk.acc = b-trxbal.acc.

    if b-trxbal.sub eq "arp" then do:
        t-wrk.rdt = txb.arp.rdt.
        t-wrk.duedt = txb.arp.duedt.
        t-wrk.attribute = v-Attribute.
    end.
    if b-trxbal.sub eq "ast" then do:
        t-wrk.rdt = txb.ast.rdt.
    end.
    if b-trxbal.sub eq "cif" then do:
        find first txb.acvolt where txb.acvolt.aaa eq txb.aaa.aaa no-lock no-error.
        t-wrk.rdt = txb.aaa.regdt.
        t-wrk.duedt = txb.aaa.expdt.
        if avail txb.acvolt and date(txb.acvolt.x1) <> txb.aaa.regdt then do:
            t-wrk.rdt_1 = date(txb.acvolt.x1).
            t-wrk.duedt_1 = date(txb.acvolt.x3).
        end.
        if t-wrk.duedt_1 ne ? then do:
            if t-wrk.duedt gt v-gldate then t-wrk.dnpogash = t-wrk.duedt - v-gldate.
            else t-wrk.dnpogash = t-wrk.duedt_1 - v-gldate.
        end.
        else if t-wrk.duedt ne ? then t-wrk.dnpogash = t-wrk.duedt - v-gldate.
        else t-wrk.dnpogash = 0.
        if t-wrk.dnpogash ne 0 then t-wrk.mtpogash = round(t-wrk.dnpogash / 30,0).
        else t-wrk.mtpogash = 0.
        t-wrk.clientname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
        t-wrk.attribute = v-Attribute.
    end.
    if b-trxbal.sub eq "dfb" then do:
        find last txb.bankl where txb.bankl.bank eq txb.fun.bank no-lock no-error.
        t-wrk.rdt = txb.dfb.rdt.
        t-wrk.duedt = txb.dfb.duedt.
        if t-wrk.duedt ne ? then t-wrk.dnpogash = t-wrk.duedt - v-gldate.
        else t-wrk.dnpogash = 0.
        if t-wrk.dnpogash ne 0 then t-wrk.mtpogash = round(t-wrk.dnpogash / 30,0).
        else t-wrk.mtpogash = 0.
        if avail txb.bankl and txb.bankl.name ne "" then t-wrk.clientname = trim(txb.bankl.name).
        else t-wrk.clientname = "Не найдено в Справочнике Банков".
    end.
    if b-trxbal.sub eq "fun" then do:
        find last txb.bankl where txb.bankl.bank eq txb.fun.bank no-lock no-error.
        t-wrk.rdt = txb.fun.rdt.
        t-wrk.duedt = txb.fun.duedt.
        if t-wrk.duedt ne ? then t-wrk.dnpogash = t-wrk.duedt - v-gldate.
        else t-wrk.dnpogash = 0.
        if t-wrk.dnpogash ne 0 then t-wrk.mtpogash = round(t-wrk.dnpogash / 30,0).
        else t-wrk.mtpogash = 0.
        if avail txb.bankl and txb.bankl.name ne "" then t-wrk.clientname = trim(txb.bankl.name).
        else t-wrk.clientname = "Не найдено в Справочнике Банков".
    end.
    if b-trxbal.sub eq "scu" then do:
        find first txb.deal where txb.deal.deal eq b-trxbal.acc no-lock no-error.
        find first txb.dealref where txb.dealref.nin eq txb.deal.nin no-lock no-error.
        find first txb.cbcoupon where txb.cbcoupon.nin eq txb.deal.nin and txb.cbcoupon.begdate le v-gldate and txb.cbcoupon.enddate gt v-gldate no-lock no-error.
        if avail txb.dealref then do:
            t-wrk.rdt = txb.dealref.issuedt.
            t-wrk.duedt = txb.dealref.maturedt.
            t-wrk.clientname = txb.dealref.atvalueon.
            t-wrk.nin = txb.dealref.nin.
        end.
        if avail txb.cbcoupon then do:
            t-wrk.rdt_2 = txb.cbcoupon.begdate.
            t-wrk.duedt_2 = txb.cbcoupon.enddate.
        end.
        if t-wrk.duedt ne ? then t-wrk.dnpogash = t-wrk.duedt - v-gldate.
        else t-wrk.dnpogash = 0.
        if t-wrk.dnpogash ne 0 then t-wrk.mtpogash = round(t-wrk.dnpogash / 30,0).
        else t-wrk.mtpogash = 0.
    end.
end procedure.

procedure GetPeriodClass:
    def input parameter p-sub as char.
    def input parameter p-acc as char.
    def input parameter p-day as inte.
    def input parameter p-bal as inte.
    def output parameter v_1-30 as deci.
    def output parameter v_31-90 as deci.
    def output parameter v_91-180 as deci.
    def output parameter v_181-365 as deci.
    def output parameter v_366-730 as deci.
    def output parameter v_731-1095 as deci.
    def output parameter v_1096-1825 as deci.
    def output parameter v_1826 as deci.

    def var v-dtday as inte.

    def buffer b-lnsch for txb.lnsch.

    v_1-30 = 0. v_31-90 = 0. v_91-180 = 0. v_181-365 = 0. v_366-730 = 0. v_731-1095 = 0. v_1096-1825 = 0. v_1826 = 0. v-dtday = ?.

    if p-sub eq "lon" then do:
        for each b-lnsch where b-lnsch.lnn eq p-acc and b-lnsch.stdat ge v-gldate and b-lnsch.f0 gt 0 no-lock:
            find first txb.lon where txb.lon.lon eq p-acc no-lock no-error.
            v-dtday = b-lnsch.stdat - v-gldate.
            if v-dtday ge 1 and v-dtday le 30 then v_1-30 = v_1-30 + CRC2KZT(yes,b-lnsch.stval,txb.lon.crc,v-gldate).
            else if v-dtday ge 31 and v-dtday le 90 then v_31-90 = v_31-90 + CRC2KZT(yes,b-lnsch.stval,txb.lon.crc,v-gldate).
            else if v-dtday ge 91 and v-dtday le 180 then v_91-180 = v_91-180 + CRC2KZT(yes,b-lnsch.stval,txb.lon.crc,v-gldate).
            else if v-dtday ge 181 and v-dtday le 365 then v_181-365 = v_181-365 + CRC2KZT(yes,b-lnsch.stval,txb.lon.crc,v-gldate).
            else if v-dtday ge 366 and v-dtday le 730 then v_366-730 = v_366-730 + CRC2KZT(yes,b-lnsch.stval,txb.lon.crc,v-gldate).
            else if v-dtday ge 731 and v-dtday le 1095 then v_731-1095 = v_731-1095 + CRC2KZT(yes,b-lnsch.stval,txb.lon.crc,v-gldate).
            else if v-dtday ge 1096 and v-dtday le 1825 then v_1096-1825 = v_1096-1825 + CRC2KZT(yes,b-lnsch.stval,txb.lon.crc,v-gldate).
            else if v-dtday ge 1826 then v_1826 = v_1826 + CRC2KZT(yes,b-lnsch.stval,txb.lon.crc,v-gldate).
        end.
    end.
end procedure.


