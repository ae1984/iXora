/* FreqUsedFunc_txb.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Часто используемые функции и процедуры. Base - TXB.
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
function GetSysc returns char(input p-sysc as char).
    def var v-res as char.

    v-res = "".
    find first txb.sysc where txb.sysc.sysc eq p-sysc no-lock no-error.
    if avail txb.sysc then v-res = trim(txb.sysc.chval).

    return v-res.
end function.

function GetFilName returns char(input p-txb as char):
    def var v-res as char.

    def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
    def var ListBank as char format "x(25)" extent 17 init ["ЦО","Актобе","Костанай","Тараз","Уральск","Караганда","Семипалатинск","Кокшетау",
    "Астана","Павлодар","Петропавловск","Атырау","Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал"].

    v-res = "".
    if lookup(p-txb,ListCod) gt 0 then v-res = ListBank[lookup(p-txb,ListCod)].

    return v-res.
end function.

procedure Get_EKNP:
    def input parameter p-sub as char.
    def input parameter p-acc as char.
    def input parameter p-d-cod as char.
    def output parameter p-KOd as char.
    def output parameter p-KBe as char.
    def output parameter p-KNP as char.

    p-KOd = "". p-KBe = "". p-KNP = "".
    find first txb.sub-cod where txb.sub-cod.sub eq p-sub and txb.sub-cod.acc eq p-acc and txb.sub-cod.d-cod eq p-d-cod and txb.sub-cod.ccode ne "msc" no-lock no-error.
    if avail txb.sub-cod then do:
        p-KOd = substr(trim(txb.sub-cod.rcode),1,2).
        p-KBe = substr(trim(txb.sub-cod.rcode),4,2).
        p-KNP = substr(trim(txb.sub-cod.rcode),7,3).
    end.
end procedure.

function GetBicBnk returns char(input p-txb as char).
    def var v-res as char.

    v-res = "".
    find first comm.txb where comm.txb.visible and comm.txb.bank eq p-txb no-lock no-error.
    if avail comm.txb then v-res = comm.txb.mfo.
    else v-res = p-txb.

    return v-res.
end function.

function GetSubCodCode returns char(input p-sub as char,input p-acc as char,input p-d-cod as char).
    def var v-res as char.

    v-res = "".
    find first txb.sub-cod where txb.sub-cod.sub eq p-sub and txb.sub-cod.acc eq p-acc and txb.sub-cod.d-cod eq p-d-cod and txb.sub-cod.ccode ne "msc" no-lock no-error.
    if avail txb.sub-cod then v-res = trim(txb.sub-cod.ccode).

    return v-res.
end function.

function GetCrcHs returns char(input p-crc as inte).
    def var v-res as char.

    v-res = "".
    find last txb.crchs where txb.crchs.crc eq p-crc no-lock no-error.
    if txb.crchs.hs eq "L" then v-res = "1".
    else if txb.crchs.hs eq "H" then v-res = "2".
    else if txb.crchs.hs eq "S" then v-res = "3".

    return v-res.
end function.

function GetSubCodCodfr returns char(input p-sub as char,input p-acc as char,input p-d-cod as char).
    def var v-res as char.

    v-res = "".
    find first txb.sub-cod where txb.sub-cod.sub eq p-sub and txb.sub-cod.acc eq p-acc and txb.sub-cod.d-cod eq p-d-cod and txb.sub-cod.ccode ne "msc" no-lock no-error.
    if avail txb.sub-cod then do:
        find first txb.codfr where txb.codfr.codfr eq txb.sub-cod.d-cod and txb.codfr.code eq txb.sub-cod.ccode no-lock no-error.
        if avail txb.codfr then v-res = trim(txb.codfr.name[1]).
    end.

    return v-res.
end function.

function CRC2KZTRate returns deci(input p-includetoday as logi,input p-crc as inte,input p-dt as date).
    def var v-res as deci.

    v-res = 0.
    if p-includetoday then do:
        find last txb.crchis where txb.crchis.crc eq p-crc and txb.crchis.whn le p-dt no-lock no-error.
        if avail txb.crchis then v-res = txb.crchis.rate[1].
    end.
    else do:
        find last txb.crchis where txb.crchis.crc eq p-crc and txb.crchis.whn lt p-dt no-lock no-error.
        if avail txb.crchis then v-res = txb.crchis.rate[1].
    end.
    return v-res.
end.

function CRC2KZT returns deci(input p-includetoday as logi,input p-sum as deci,input p-crc as inte, p-dt as date).
    def var v-res as deci.

    v-res = 0.
    if p-includetoday then do:
        find last txb.crchis where txb.crchis.crc eq p-crc and txb.crchis.whn le p-dt no-lock no-error.
        if avail txb.crchis then v-res = p-sum * txb.crchis.rate[1].
    end.
    else do:
        find last txb.crchis where txb.crchis.crc eq p-crc and txb.crchis.whn lt p-dt no-lock no-error.
        if avail txb.crchis then v-res = p-sum * txb.crchis.rate[1].
    end.
    return v-res.
end.

function CRC2KZTRate_Prog returns deci(input p-includetoday as logi,input p-crc as inte,input p-dt as date).
    def var v-res as deci.

    v-res = 0.
    if p-includetoday then do:
        find last txb.crcpro where txb.crcpro.crc eq p-crc and txb.crcpro.regdt le p-dt no-lock no-error.
        if avail txb.crcpro then v-res = txb.crcpro.rate[1].
    end.
    else do:
        find last txb.crcpro where txb.crcpro.crc eq p-crc and txb.crcpro.regdt lt p-dt no-lock no-error.
        if avail txb.crcpro then v-res = txb.crcpro.rate[1].
    end.
    return v-res.
end.

function CRC2KZT_Prog returns deci(input p-includetoday as logi,input p-sum as deci,input p-crc as inte, p-dt as date).
    def var v-res as deci.

    v-res = 0.
    if p-includetoday then do:
        find last txb.crcpro where txb.crcpro.crc eq p-crc and txb.crcpro.regdt le p-dt no-lock no-error.
        if avail txb.crcpro then v-res = p-sum * txb.crcpro.rate[1].
    end.
    else do:
        find last txb.crcpro where txb.crcpro.crc eq p-crc and txb.crcpro.regdt lt p-dt no-lock no-error.
        if avail txb.crcpro then v-res = p-sum * txb.crcpro.rate[1].
    end.
    return v-res.
end.

function GetGlday returns deci(input p-includetoday as logi,input p-gl as inte,input p-crc as inte,input p-dt as date).
    def var v-res as deci.
    def var v-bal as deci.

    v-res = 0. v-bal = 0.
    if p-includetoday then find last txb.glday where txb.glday.gl eq p-gl and txb.glday.crc eq p-crc and txb.glday.gdt le p-dt no-lock no-error.
    else find last txb.glday where txb.glday.gl eq p-gl and txb.glday.crc eq p-crc and txb.glday.gdt lt p-dt no-lock no-error.
    if avail txb.glday then do:
        find txb.gl where txb.gl.gl eq txb.glday.gl no-lock no-error.
        v-bal = txb.glday.cam - txb.glday.dam.

        /*Assets-A,Liabilities-L,Revenue-R,Expenses-E,Capital-O*/
        if txb.gl.type eq "A" or txb.gl.type eq "E" then v-bal = - v-bal.

        v-res = CRC2KZT(yes,v-bal,p-crc,p-dt).
    end.
    return v-res.
end function.

procedure GetDPSCode:
    def input parameter p-sub as char.
    def input parameter p-acc as char.
    def input parameter p-gl as inte.
    def input parameter p-glcrc as inte.
    def input parameter p-dt as date.
    def output parameter p-DPScode as char.
    def output parameter p-Attribute as char.

    def var v-r as char.
    def var v-cgr as char.
    def var v-hs as char.
    def var v-geo as char.

    p-DPScode = "". p-Attribute = "". v-r = "". v-cgr = "". v-hs = "".

    if p-sub eq "ARP" then do:
        find txb.arp where txb.arp.arp eq p-acc no-lock no-error.
        if avail txb.arp then do:
            find txb.cif where txb.cif.cif eq txb.arp.cif no-lock no-error.
            if avail txb.cif then do:
                v-geo = substr(trim(txb.cif.geo),3,1).
                v-cgr = GetSubCodCode("cln",txb.cif.cif,"secek").
            end.
            else do:
                v-geo = substr(trim(txb.arp.geo),3,1).
                v-cgr = GetSubCodCode("arp",txb.arp.arp,"secek").
            end.
            if v-geo eq "1" then v-r = "1".
            else v-r = "2".
            v-hs = GetCrcHs(txb.arp.crc).

            run GetAttribute(output p-Attribute).
        end.
    end.

    if p-sub eq "AST" then do:
        find txb.ast where txb.ast.ast eq p-acc no-lock no-error.
        if avail txb.ast then do: v-r = "1". v-cgr = "4". v-hs = "1". end.
    end.

    if p-sub eq "CIF" then do:
        find txb.aaa where txb.aaa.aaa eq p-acc no-lock no-error.
        if avail txb.aaa then do:
            find txb.cif where txb.cif.cif eq txb.aaa.cif no-lock no-error.
            if avail txb.cif then do:
                v-geo = substr(trim(txb.cif.geo),3,1).
                v-cgr = GetSubCodCode("cln",txb.cif.cif,"secek").
            end.
            if v-geo eq "1" then v-r = "1".
            else v-r = "2".
            v-hs = GetCrcHs(txb.aaa.crc).

            run GetAttribute(output p-Attribute).
        end.
    end.

    if p-sub eq "DFB" then do:
        find txb.dfb where txb.dfb.dfb eq p-acc no-lock no-error.
        if avail txb.dfb then do:
            find last txb.bankl where txb.bankl.bank eq txb.dfb.bank no-lock no-error.
            if avail txb.bankl then v-geo = substr(trim(string(txb.bankl.stn,"999")),3,1).
            if v-geo eq "1" then v-r = "1".
            else v-r = "2".
            if txb.dfb.gl ge 105100 and txb.dfb.gl lt 105200 then v-cgr = "3".
            else v-cgr = "4".
            v-hs = GetCrcHs(txb.dfb.crc).
        end.
    end.

    if p-sub eq "FUN" then do:
        find txb.fun where txb.fun.fun eq p-acc no-lock no-error.
        if avail txb.fun then do:
            find last txb.bankl where txb.bankl.bank eq txb.fun.bank no-lock no-error.
            if avail txb.bankl then v-geo = substr(trim(string(txb.bankl.stn,"999")),3,1).
            if v-geo eq "1" then v-r = "1".
            else v-r = "2".
            v-cgr = GetSubCodCode("fun",txb.fun.fun,"secek").
            if v-cgr eq "0" then v-cgr = "4".
            v-hs = GetCrcHs(txb.fun.crc).
        end.
    end.

    if p-sub eq "SCU" then do:
        find txb.scu where txb.scu.scu eq p-acc no-lock no-error.
        if avail txb.scu then do:
            v-geo = substr(trim(txb.scu.geo),3,1).
            if v-geo eq "1" then v-r = "1".
            else v-r = "2".
            v-cgr = trim(txb.scu.type).
            v-hs = GetCrcHs(txb.scu.crc).
        end.
    end.

    if p-sub eq "LON" then do:
        find txb.lon where txb.lon.lon eq p-acc no-lock no-error.
        if avail txb.lon then do:
            find txb.cif where txb.cif.cif eq txb.lon.cif no-lock no-error.
            if avail txb.cif then do:
                v-geo = substr(trim(txb.cif.geo),3,1).
                v-cgr = GetSubCodCode("cln",txb.cif.cif,"secek").
            end.
            if v-geo eq "1" then v-r = "1".
            else v-r = "2".
            v-hs = GetCrcHs(txb.lon.crc).

            run GetAttribute(output p-Attribute).
        end.
    end.

    if p-sub eq "" then do:
        find txb.gl where txb.gl.gl eq p-gl no-lock no-error.
        if avail txb.gl then do:
            find first txb.crchs where txb.crchs.crc eq p-glcrc no-lock no-error.
            if avail txb.crchs then do:
                if GetGlday(s-includetoday,txb.gl.gl,txb.crchs.crc,p-dt) ne 0 then do:
                    if txb.crchs.hs eq "L" then v-hs = "1".
                    else if txb.crchs.hs eq "H" then v-hs = "2".
                    else if txb.crchs.hs eq "S" then v-hs = "3".
                    if v-hs eq "1" then v-r = "1".
                    else v-r = "2".
                    if txb.gl.gl lt 105000 then v-cgr = "3".
                    else if string(txb.gl.gl) begins "2551" then v-cgr = "4".
                    else v-cgr = "6".
                end.
            end.
        end.
    end.

    p-DPScode = v-r + v-cgr + v-hs.

end procedure.

procedure GetAttribute:
    def output parameter p-attrib as char.

    def var nm as char.

    p-attrib = "". nm = "".
    if avail txb.cif then do:
        find first comm.prisv where comm.prisv.rnn eq txb.cif.jss and (comm.prisv.rnn ne '' or txb.cif.jss ne "") no-lock no-error.
        if avail comm.prisv then do:
             find first txb.codfr where txb.codfr.codfr eq "affil" and txb.codfr.code eq comm.prisv.specrel no-lock no-error.
             if avail txb.codfr then p-attrib = trim(txb.codfr.name[1]).
             else p-attrib = "Нет такого справочника".
        end.
        else do:
            if num-entries(trim(txb.cif.name),' ') gt 0 then nm = entry(1,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') gt 1 and entry(2,trim(txb.cif.name),' ') ne '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') gt 2 and entry(3,trim(txb.cif.name),' ') ne '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
            find first comm.prisv where trim(comm.prisv.name) eq nm no-lock no-error.
            if avail comm.prisv then do:
                 find first txb.codfr where txb.codfr.codfr eq "affil" and txb.codfr.code eq comm.prisv.specrel no-lock no-error.
                 if avail txb.codfr then p-attrib = trim(txb.codfr.name[1]).
                 else p-attrib = 'Нет такого справочника'.
            end.
            p-attrib = "Не связанное лицо".
        end.
    end.
end procedure.

function GetNameAcc returns char(input p-sub as char,input p-acc as char,input p-gl as inte).
    def var v-res as char.

    v-res = "".

    if p-sub eq "ARP" then do:
        find txb.arp where txb.arp.arp eq p-acc no-lock no-error.
        if avail txb.arp then v-res = trim(txb.arp.des).
    end.

    if p-sub eq "AST" then do:
        find txb.ast where txb.ast.ast eq p-acc no-lock no-error.
        if avail txb.ast then v-res = trim(txb.ast.name).
    end.

    if p-sub eq "CIF" then do:
        find txb.aaa where txb.aaa.aaa eq p-acc no-lock no-error.
        if avail txb.aaa then do:
            find txb.cif where txb.cif.cif eq txb.aaa.cif no-lock no-error.
            if avail txb.cif then v-res = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
        end.
    end.

    if p-sub eq "DFB" then do:
        find txb.dfb where txb.dfb.dfb eq p-acc no-lock no-error.
        if avail txb.dfb then v-res = trim(txb.dfb.name).
    end.

    if p-sub eq "FUN" then do:
        find txb.fun where txb.fun.fun eq p-acc no-lock no-error.
        if avail txb.fun then v-res = trim(txb.fun.accrcv).
    end.

    if p-sub eq "SCU" then do:
        find txb.scu where txb.scu.scu eq p-acc no-lock no-error.
        if avail txb.scu then v-res = "SCU".
    end.

    if p-sub eq "LON" then do:
        find txb.lon where txb.lon.lon eq p-acc no-lock no-error.
        if avail txb.lon then do:
            find txb.cif where txb.cif.cif eq txb.lon.cif no-lock no-error.
            if avail txb.cif then v-res = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
        end.
    end.

    if p-sub eq "" then do:
        find txb.gl where txb.gl.gl eq p-gl no-lock no-error.
        if avail txb.gl then v-res = trim(txb.gl.des).
    end.

    return v-res.
end function.

function GetNameCgr returns char(input p-sub as char,input p-acc as char).
    def var v-res as char.

    v-res = "".
    if p-sub eq "CIF" then do:
        find txb.aaa where txb.aaa.aaa eq p-acc no-lock no-error.
        if avail txb.aaa then do:
            find txb.cif where txb.cif.cif eq txb.aaa.cif no-lock no-error.
            if avail txb.cif then do:
                find first txb.cgr where txb.cgr.cgr eq txb.cif.cgr no-lock no-error.
                if avail txb.cgr then v-res = string(txb.cgr.cgr) + " " + trim(txb.cgr.name).
            end.
        end.
    end.
    if p-sub eq "LON" then do:
        find txb.lon where txb.lon.lon eq p-acc no-lock no-error.
        if avail txb.lon then do:
            find txb.cif where txb.cif.cif eq txb.lon.cif no-lock no-error.
            if avail txb.cif then do:
                find first txb.cgr where txb.cgr.cgr eq txb.cif.cgr no-lock no-error.
                if avail txb.cgr then v-res = string(txb.cgr.cgr) + " " + trim(txb.cgr.name).
            end.
        end.
    end.

    return v-res.
end function.

function GetGlLev returns inte(input p-gl as inte,input p-lev as inte).
    def var v-res as inte.

    v-res = 0.
    find txb.gl where txb.gl.gl eq p-gl no-lock no-error.
    if avail txb.gl then do:
        find txb.trxlevgl where txb.trxlevgl.gl eq p-gl and txb.trxlevgl.level eq p-lev and txb.trxlevgl.subled eq txb.gl.subled no-lock no-error.
        if avail txb.trxlevgl then v-res = txb.trxlevgl.glr.
    end.

    return v-res.
end function.

function RetPoolId returns char(input p-grp as inte).
    def var v-pool as char no-undo extent 10.
    def var v-poolName as char no-undo extent 10.
    def var v-poolId as char no-undo extent 10.
    def var i as inte.
    def var v-res as char.

    v-pool[1] = "27,67". v-poolName[1] = "Ипотечные займы". v-poolId[1] = "ipoteka".
    v-pool[2] = "28,68". v-poolName[2] = "Автокредиты". v-poolId[2] = "auto".
    v-pool[3] = "20,60". v-poolName[3] = "Потребительские кредиты Обеспеченные". v-poolId[3] = "flobesp".
    v-pool[4] = "90,92". v-poolName[4] = "Потребительские кредиты Бланковые 'Метрокредит'". v-poolId[4] = "metro".
    v-pool[5] = "81,82". v-poolName[5] = "Потребительские кредиты Бланковые 'Сотрудники'". v-poolId[5] = "sotr".
    v-pool[6] = "16,26,56,66". v-poolName[6] = "Метро-экспресс МСБ". v-poolId[6] = "express-msb".
    v-pool[7] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63". v-poolName[7] = "Кредиты МСБ". v-poolId[7] = "msb".
    v-pool[8] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63". v-poolName[8] = "Инидивид. МСБ". v-poolId[8] = "individ-msb".
    v-pool[9] = "11,21,70,80". v-poolName[9] = "факторинг, овердрафты". v-poolId[9] = "factover".
    v-pool[10] = "95,96". v-poolName[10] = "Ипотека «Астана бонус»". v-poolId[10] = "astana-bonus".

    v-res = "".
    do i = 1 to 10:
        if lookup(string(p-grp),v-pool[i]) gt 0 then v-res = v-poolId[i].
    end.
    return v-res.
end function.

function GetCifLonCode returns char(input p-grp as inte).
    def var v-res as char.

    v-res = "".
    if lookup(string(p-grp),"13,14,16,53,54,55,56,70") gt 0 then v-res = "23".
    else if lookup(string(p-grp),"24,25,26,63,64,65,66,80") gt 0 then v-res = "24".
    else if lookup(string(p-grp),"10,15,50") gt 0 then v-res = "6".
    else if lookup(string(p-grp),"20,60,81,82,90,92,95,96") gt 0 then v-res = "9".

    return v-res.
end function.

function GetGrpLon returns inte(input p-lon as char,input p-clmain as char,input p-grp as inte).
    def var v-res as inte.

    def buffer b2-lon for txb.lon.

    v-res = 0.
    if p-clmain eq "" then v-res = p-grp.
    else do:
        find b2-lon where b2-lon.lon eq p-clmain no-lock no-error.
        if avail b2-lon then v-res = b2-lon.grp.
    end.

    return v-res.
end function.

function GetClassKFN returns char(input p-proc as deci).
    def var v-res as char.

    v-res = "".
    if p-proc eq 0 then v-res = "Стандартные".
    else if p-proc gt 0 and p-proc le 5.01 then v-res = "Сомнительные 1 категории".
    else if p-proc gt 5.01 and p-proc le 10.01 then v-res = "Сомнительные 2 категории".
    else if p-proc gt 10.01 and p-proc le 20.01 then v-res = "Сомнительные 3 категории".
    else if p-proc gt 20.01 and p-proc le 25.01 then v-res = "Сомнительные 4 категории".
    else if p-proc gt 25.01 and p-proc le 50.01 then v-res = "Сомнительные 5 категории".
    else if p-proc gt 50.01 then v-res = "Безнадежные".

    return v-res.
end function.

function GetCodeUse returns char(input p-objekts as char).
    def var v-res as char.

    v-res = "".
    if p-objekts matches "*гражданам на потребительские цели*" then v-res = "11".
    else if p-objekts matches "*гражданам на строительство и приобретение жилья*" or
    p-objekts matches "*на новое строительство и реконструкцию объектов*" then v-res = "13".
    else if p-objekts matches "*Затраты на оборотные средства*" or p-objekts matches "*на инвестиции*" or
    p-objekts matches "*На приобретение основных фондов (кроме лизинга)*" or p-objekts matches "*На приобретение ценных бумаг*" or
    p-objekts matches "*На рефинансирование (из других БВУ)*" or p-objekts matches "*Остальные*" or
    p-objekts matches "*Прочие займы, не учитываемые в кодах с 10 по 19*" then v-res = "15".

    return v-res.
end function.




