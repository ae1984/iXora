/* prilozh5.i
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
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        14.10.2011 damir - small changes
        18.10.2011 damir - отражение сроков по формату.
        24.02.2012 damir - небольшая корректировка.
        16.04.2012 damir - убрал проверку на статус, в доп.листах и в пс.
        04.07.2012 damir - отображение бин и иин.
        17.07.2012 damir - вывод в приложение УНК редактируемые через F2.
*/

for each vccontrs where vccontrs.bank = p-bank and vccontrs.cttype = '1' no-lock:
    assign v-cifname = "" v-cifokpo = "" v-cifrnn =  ""  v-ciftype = 0  v-cifprefix = ""  v-corrinfo = "" v-partname = "" v-partcountry = "".
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    /*выбираем клиента данного департамента*/
    /*if p-depart <> 0 and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.*/
    if avail txb.cif then do:
        v-cifname = trim(trim(substring(txb.cif.name, 1, 40)) + " " + trim(txb.cif.prefix)).
        v-cifprefix = trim(txb.cif.prefix).
    end.
    v-cifregion = "".
    find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error. /*aigul */
    if avail txb.sub-cod then v-cifregion = txb.sub-cod.ccode.
    if vccontrs.dtcorrect = v-dt then do:
        for each vcpshismt where vcpshismt.contract = vccontrs.contract and vcpshismt.stsnew = "new" and vcpshismt.createdt = v-dt no-lock:
            create t-ps.
            assign
            t-ps.psnum = vcpshismt.dnnum + string(vcpshismt.num)
            t-ps.psdate = vcpshismt.dndate
            t-ps.bank = vccontrs.bank.
            find vcrslc where vcrslc.contract = vcpshismt.contract and vcrslc.dntype = '21' no-lock no-error.
            if avail vcrslc then do:
                assign
                t-ps.rslcdnnum_21 = vcrslc.dnnum
                t-ps.rslcdndate_21 = vcrslc.dndate.
            end.

            if vcpshismt.ctexpimp <> "" then do:
                v-expimp = 0.
                if vcpshismt.ctexpimp = 'I' then v-expimp = 2.
                else v-expimp = 1.
                t-ps.ctexpimp = v-expimp.
            end.

            if vcpshismt.ctpartner <> "" then do:
                find vcpartners where vcpartners.partner = vcpshismt.ctpartner no-lock no-error.
                if avail vcpartners then do:
                    v-partname = trim(trim(vcpartners.name) + " " + trim(vcpartner.formasob)).
                    v-partcountry = vcpartner.country.
                end.
                t-ps.partner_name = v-partname.
            end.

            if vcpshismt.ncrc <> 0 then do:
                v-crc = "".
                find txb.ncrc where txb.ncrc.crc = vcpshismt.ncrc no-lock no-error.
                if avail txb.ncrc then v-crc = txb.ncrc.code.
                t-ps.ctncrc_int = vcpshismt.ncrc.
                t-ps.ctncrc = v-crc.
            end.
            if vcpshismt.ctnum <> ""     then t-ps.ctnum = vcpshismt.ctnum.
            if vcpshismt.dndate <> ?     then t-ps.ctregdt = vcpshismt.dndate.
            if vcpshismt.ctdate <> ?     then t-ps.ctdate = vcpshismt.ctdate.
            if vcpshismt.ctvalpl <> ""   then t-ps.ctvalpl = vcpshismt.ctvalpl.
            if vcpshismt.sum <> 0        then t-ps.ctsum = vcpshismt.sum / 1000.
            if vcpshismt.ncrc <> 0       then t-ps.ctncrc_int = vcpshismt.ncrc.
            if v-crc <> ""               then t-ps.ctncrc = v-crc.
            if vcpshismt.ctvalogr <> ""  then t-ps.ctogval = vcpshismt.ctvalogr.
            if vcpshismt.lastdate <> ?   then t-ps.ctlastdate = vcpshismt.lastdate.
            if vcpshismt.ctformrs <> ""  then t-ps.ctformrs = vcpshismt.ctformrs.
            if vcpshismt.ctterm <> ""    then t-ps.ctterm = string(vcpshismt.ctterm,"999.99").
            if vcpshismt.dndate <> ?     then t-ps.repdate = vcpshismt.dndate.
            if vcpshismt.dnnote[5] <> "" then t-ps.note = vcpshismt.dnnote[5].
            if vcpshismt.country <> ""   then t-ps.partner_country = vcpshismt.country.

            if lookup('16', vccontrs.info[4]) > 0 then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "наим. нерезид.".
                else v-corrinfo = v-corrinfo + "наим. нерезид.".
            end.
            if lookup('17', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "страны нерезид.".
                else v-corrinfo = v-corrinfo + "страны нерезид.".
            end.
            if lookup('12', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "признака Э/И".
                else v-corrinfo = v-corrinfo + "признака Э/И".
            end.
            if lookup('13', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "номера контракта".
                else v-corrinfo = v-corrinfo + "номера контракта".
            end.
            if lookup('14', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "даты контракта".
                else v-corrinfo = v-corrinfo + "даты контракта".
            end.
            if lookup('24', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "валюты платежа".
                else v-corrinfo = v-corrinfo + "валюты платежа".
            end.
            if lookup('15', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "суммы контракта".
                else v-corrinfo = v-corrinfo + "суммы контракта".
            end.
            if lookup('20', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "валюты контракта".
                else v-corrinfo = v-corrinfo + "валюты контракта".
            end.
            if lookup('26', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "валютной оговорки".
                else v-corrinfo = v-corrinfo + "валютной оговорки".
            end.
            if lookup('27', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "деталей вал.огов.".
                else v-corrinfo = v-corrinfo + "деталей вал.огов.".
            end.
            if lookup('21', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "последней даты".
                else v-corrinfo = v-corrinfo + "последней даты".
            end.
            if lookup('25', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "кода способа расчетов".
                else v-corrinfo = v-corrinfo + "кода способа расчетов".
            end.
            if lookup('18', vccontrs.info[4]) > 0  then do:
                if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "сроков репатриации".
                else v-corrinfo = v-corrinfo + "сроков репатриации".
            end.
            t-ps.corrinfo = v-corrinfo.
        end.
    end.
    else do:
        for each vcpshismt where vcpshismt.contract = vccontrs.contract and vcpshismt.stsnew = "old" no-lock:
            if vcpshismt.dntype = '01' and ((vcpshismt.dndate = v-dt /*and vccontrs.sts <> "C"*/ ) or
            (vccontrs.sts = 'C' and vccontrs.stsdt = v-dt)) then do:
                v-expimp = 0.
                if vcpshismt.ctexpimp = 'I' then v-expimp = 2.
                else v-expimp = 1.

                assign v-cifname = "" v-cifokpo = "" v-cifrnn =  "" v-ciftype = 0 v-cifprefix = "" v-bincif = "" v-iincif = "".
                find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
                if avail txb.cif then do:
                    v-cifname = trim(trim(substring(txb.cif.name, 1, 40)) + " " + trim(txb.cif.prefix)).
                    if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then do:
                        v-ciftype = 1.
                        v-cifokpo = trim(txb.cif.ssn).
                        if v-bin = yes then v-bincif = trim(txb.cif.bin).
                    end.
                    if (txb.cif.type = 'B' and txb.cif.cgr = 403) then do:
                        v-ciftype = 2.
                        v-cifrnn =  string(txb.cif.jss, "999999999999").
                        if v-bin = yes then v-iincif = trim(txb.cif.bin).
                    end.
                    v-cifprefix = trim(txb.cif.prefix).
                end.

                find vcpartners where vcpartners.partner = vcpshismt.ctpartner no-lock no-error.
                if avail vcpartners then do:
                    v-partname = trim(trim(vcpartners.name) + " " + trim(vcpartner.formasob)).
                    v-partcountry = vcpartner.country.
                end.

                v-crc = "".
                find txb.ncrc where txb.ncrc.crc = vcpshismt.ncrc no-lock no-error.
                if avail txb.ncrc then v-crc = txb.ncrc.code.

                if vcpshismt.dndate = v-dt then do:
                    create t-ps.
                    assign
                    t-ps.psnum = vcpshismt.dnnum + string(vcpshismt.num)
                    t-ps.psdate = vcpshismt.dndate
                    t-ps.bank = vccontrs.bank
                    t-ps.cifname = v-cifname
                    t-ps.cifprefix = v-cifprefix
                    t-ps.cif_rfkod1 = v-cifokpo
                    t-ps.cif_jss = v-cifrnn
                    t-ps.cif_type = v-ciftype
                    t-ps.cif_region = v-cifregion
                    t-ps.partner_name = v-partname
                    t-ps.partner_country = v-partcountry
                    t-ps.ctexpimp = v-expimp
                    t-ps.ctnum = vcpshismt.ctnum
                    t-ps.ctregdt = vcpshismt.dndate
                    t-ps.ctdate = vcpshismt.ctdate
                    t-ps.ctvalpl = vcpshismt.ctvalpl
                    t-ps.ctsum = vcpshismt.sum / 1000
                    t-ps.ctncrc_int = vcpshismt.ncrc
                    t-ps.ctncrc = v-crc
                    t-ps.ctogval = vcpshismt.ctvalogr
                    t-ps.ctlastdate = vcpshismt.lastdate
                    t-ps.ctformrs = vcpshismt.ctformrs
                    t-ps.ctterm = string(vcpshismt.ctterm,"999.99")
                    t-ps.repdate = vcpshismt.dndate
                    t-ps.note = vcpshismt.dnnote[5].
                    find first txb.cmp no-lock no-error.
                    if avail txb.cmp then t-ps.bankokpo = txb.cmp.addr[3].
                    find vcrslc where vcrslc.contract = vcpshismt.contract and vcrslc.dntype = '21' no-lock no-error.
                    if avail vcrslc then do:
                        assign
                        t-ps.rslcdnnum_21 = vcrslc.dnnum
                        t-ps.rslcdndate_21 = vcrslc.dndate.
                    end.
                    if v-bin = yes then do:
                        assign
                        t-ps.bnkbin = v-bnkbin
                        t-ps.bin    = v-bincif
                        t-ps.iin    = v-iincif.
                    end.
                end.
                if vccontrs.sts = 'C' and vccontrs.stsdt = v-dt then do:
                    create t-ps.
                    t-ps.psnum = vcpshismt.dnnum + string(vcpshismt.num).
                    t-ps.psdate = vcpshismt.dndate.
                    t-ps.ctclosereas = trim(vccontrs.info[8]).
                    t-ps.ctclosedt = vccontrs.stsdt.
                    t-ps.cifname = "".
                    t-ps.cif_rfkod1 = "".
                    t-ps.cif_jss = "".
                    string(t-ps.cif_type) = "".
                    t-ps.cif_region = "".
                    t-ps.cifprefix = "".
                    string(t-ps.ctexpimp) = "".
                    t-ps.ctnum = "".
                    string(t-ps.ctdate) = "".
                    t-ps.ctvalpl = "".
                    string(t-ps.ctsum) = "".
                    t-ps.ctncrc = "".
                    string(t-ps.ctlastdate) = "".
                    t-ps.partner_name = "".
                    t-ps.partner_country = "".
                    t-ps.ctterm = "".
                    t-ps.ctformrs = "".
                    t-ps.psnum_19 = "".
                    string(t-ps.psdate_19) = "".
                    t-ps.psreason_19 = "".
                    t-ps.psreason_19 = "".
                    if v-bin = yes then do:
                        assign
                        t-ps.bnkbin = v-bnkbin.
                    end.
                end.
            end.
        end.
    end.
end.

/*Алготритм по Доп.листам не трогал*/
for each vccontrs where vccontrs.bank = p-bank and vccontrs.cttype = '1' /*and vccontrs.sts <> 'C'*/ no-lock:
    v-expimp = 0.
    if vccontrs.expimp = 'i' then v-expimp = 2.
    else v-expimp = 1.

    assign
    v-cifname = ""
    v-cifokpo = ""
    v-cifrnn =  ""
    v-ciftype = 0
    v-cifprefix = "".
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    /*выбираем клиента данного департамента*/
    /*if p-depart <> 0 and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.*/
    if avail txb.cif then do:
        v-cifname = trim(trim(substring(txb.cif.name, 1, 40)) + " " + trim(txb.cif.prefix)).
        v-cifprefix = trim(txb.cif.prefix).
    end.

    v-cifregion = "".
    find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error. /*aigul */
    if avail txb.sub-cod then v-cifregion = txb.sub-cod.ccode.
    v-partname = "".
    v-partcountry = "".
    find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
    if avail vcpartners then do:
        v-partname = trim(trim(vcpartners.name) + " " + trim(vcpartner.formasob)).
        v-partcountry = vcpartner.country.
    end.

    for each vcps where vcps.contract = vccontrs.contract no-lock:
        if vcps.dntype = '04' and vcps.info2[1] = "F2" and vcps.dndate = v-dt then do:
            i = 0.
            for each b-vcps where b-vcps.contract = vcps.contract no-lock break by b-vcps.ps.
                i = i + 1.
                create mt.
                mt.i = i.
                mt.contract = b-vcps.contract.
                mt.ps = b-vcps.ps.
                mt.dnnum = b-vcps.dnnum.
                mt.dntype = b-vcps.dntype.
                mt.ctformrs = b-vcps.ctformrs.
            end.
            v-crc = "".
            find txb.ncrc where txb.ncrc.crc = vcps.ncrc no-lock no-error.
            if avail txb.ncrc then v-crc = txb.ncrc.code.

            create t-ps.
            t-ps.psnum = vcps.dnnum + string(vcps.num).
            t-ps.psdate = vcps.dndate.
            find first b-vcps where b-vcps.contract = vccontrs.contract and b-vcps.dntype = "01" and b-vcps.ps <> vcps.ps no-lock no-error.
            if avail b-vcps  then do:
            t-ps.psnum = b-vcps.dnnum + string(b-vcps.num).
            t-ps.psdate = b-vcps.dndate.
            end.

            if index(vcps.dnnum,",") > 0 then t-ps.psnum_19 = trim(replace(entry(2,vcps.dnnum),'N',' ')).
            else t-ps.psnum_19 = trim(replace(vcps.dnnum,'N',' ')).

            t-ps.psdate_19 = vcps.rdt.
            t-ps.psreason_19 = vcps.info[4] .
            t-ps.repdate = vcps.rdt.
            find first txb.cmp no-lock no-error.
            if avail txb.cmp then t-ps.bankokpo = txb.cmp.addr[3].

            if lookup('3',vcps.info[3]) > 0  then t-ps.ctsum = vcps.sum / 1000.
            if lookup('5',vcps.info[3]) > 0  then t-ps.ctterm = string(vcps.ctterm,"999.99").
            if lookup('2',vcps.info[3]) > 0  then t-ps.ctlastdate = vcps.lastdate.
            if lookup('4',vcps.info[3]) > 0  then t-ps.ctvalpl = vcps.ctvalpl.
            find txb.ncrc where txb.ncrc.crc = vcps.ncrc no-lock no-error.
            if lookup('1',vcps.info[3]) > 0  then t-ps.ctncrc = txb.ncrc.code.
            if lookup('7',vcps.info[3]) > 0  then assign t-ps.ctogval = vccontrs.info[1].
            if lookup('6',vcps.info[3]) > 0  then t-ps.ctformrs = vcps.ctformrs.
            if lookup('11',vcps.info[3]) > 0 then do:
                find first txb where txb.bank = vccontrs.bank no-lock no-error.
                if avail txb then t-ps.bank = txb.params.
            end.
            if lookup('12',vcps.info[3]) > 0 then do:
                find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
                if avail txb.cif then t-ps.cifname = txb.cif.name.
            end.
            if lookup('13',vcps.info[3]) > 0 then do:
                find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
                if avail txb.cif then t-ps.cif_rfkod1 = txb.cif.ssn.
            end.
            if lookup('14',vcps.info[3]) > 0 then do:
                find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
                if avail txb.cif then t-ps.cif_jss = txb.cif.jss.
            end.
            if lookup('15',vcps.info[3]) > 0 then do:
                find first txb.sub-cod where txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
                if avail txb.sub-cod then do:
                    find first txb.codfr where txb.codf.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccod no-lock no-error.
                    if avail txb.codfr then t-ps.cifprefix = txb.codfr.name[1].
                end.
            end.
            if lookup('16',vcps.info[3]) > 0 then t-ps.ctnum = vccontrs.ctnum.
            if lookup('17',vcps.info[3]) > 0 then t-ps.ctdate = vccontrs.ctdate.
            if lookup('18',vcps.info[3]) > 0 then t-ps.ctsum = vcps.sum / 1000.
            if lookup('19',vcps.info[3]) > 0 then do:
                find first vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
                if avail vcpartners then t-ps.partner_name = vcpartners.name + " " + vcpartner.formasob.
            end.
            if lookup('20',vcps.info[3]) > 0 then do:
                find first vcpartners where vcpartners.partner = vccontrs.partner.
                if avail vcpartners then t-ps.partner_country = vcpartners.country.
            end.
            if lookup('21',vcps.info[3]) > 0 then t-ps.ctterm = string(vcps.ctterm,"999.99").
            if lookup('22',vcps.info[3]) > 0 then t-ps.note = vcps.dnnote[5].
            if lookup('23',vcps.info[3]) > 0 then do:
                find txb.ncrc where txb.ncrc.crc = vccontrs.ncrc no-lock no-error.
                if avail txb.ncrc then t-ps.ctncrc = txb.ncrc.code.
            end.
            if lookup('24',vcps.info[3]) > 0 then t-ps.ctlastdate = vcps.lastdate.
            if lookup('25',vcps.info[3]) > 0 then t-ps.ctvalpl = vcps.ctvalpl.
            if lookup('26',vcps.info[3]) > 0 then t-ps.ctformrs = vcps.ctformrs.
            if lookup('27',vcps.info[3]) > 0 then assign t-ps.ctogval = vccontrs.info[1].
            if lookup('28',vcps.info[3]) > 0 then assign t-ps.ctogval = vccontrs.info[1].
            t-ps.note = vcps.dnnote[5].
        end.
    end.
end.