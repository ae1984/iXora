/* vcrep5dat.p
* MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 5 - Информация по паспортам сделок и дополнительным листам к паспортам сделок (МТ111 для НБ)
        Сборка данных во временную таблицу по всем филиалам
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM TXB
 * AUTHOR
        20.08.2008 galina
 * CHANGES
        05.09.2008 galina - добавила поле bankokpo во временную таблицу
        02/10/2008 galina - если контракт закрыт, то проверяем попадает ли дата закрытия в отчетный период
        03/10/2008 galina - для МТ сообщения выбирать только те паспорта, которые попали в отчетный период, а не все подряд
        18/11/2008 galina - добавила поле repdate
                            выводим ОКПО банка для закрытых и для открытых ПС

        05/12/2008 galina - поле repdate = дата оформления УНК
        26/02/2009 galina - не выводим лишние поля для доплистов
                            всегда выводить ОКПО банка
        11/06/2009 galina - поле repdate = дата оформления/закрытия УНК или дата оформления доплиста
        08/10/2010 galina - добавила приммечание
        18/11/2010 aigul - добавила no-lock no-error
        14.01.2011 aigul - для МТ сообщения выбирать все данные записанные в vcps.info[3]
        16.03.2011 aigul - изменила вывод данных по ПС 01
        30.03.2011 aigul - убрала доп листы с закрытыми контрактами
        04.04.2011 aigul - вывод vcps.dnnote[5] в МТ 111 при заполнении
        07.04.2011 aigul - исправила report date
        07.04.2011 aigul - исправила вывод закрытых МТ в приложение 5
        15.04.2011 aigul - для доп листов вывела сумма доплистов
        19.04.2011 damir - добавлены bin,iin,bnkbin в t-ps.
                           v-bin,v-iin,v-bnkbin
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        08.09.2011 damir - Добавил:
                           1) входной параметр v-oper(тип операции).
                           2) алгоритм вывод измененных данных в МТ-111, тип операции - 2, подписан ниже.
                           3) алгоритм сохраняет ПС в первоначальном виде, добавил, затем закоментил,но если вдруг передумают.
                           4) Добавлены поля field - corrinfo, newval1, newval2, valplnew.
        30.09.2011 damir - добавил okpoprev в  temp-table t-ps.
        07.10.2011 damir - добавил prilozh5.i для p-option = "rep".
        04.11.2011 damir - перекомпиляция...
        06.12.2011 damir - убрал chbin.i, добавил vcmtform_txb.i
        28.12.2011 damir - небольшие корректировки.
        24.02.2012 damir - перекомпиляция изменения prilozh5.i.
        16.04.2012 damir - перекомпиляция изменения prilozh5.i.
        28.04.2012 damir - убрал проверку на статус при выводе доп.листов.
        07.05.2012 damir - тип документа 19 поставил проверку на дату.
        13.06.2012 damir - перекомпиляция.
        29.06.2012 damir - oper_type, выгружаем в МТ только отредактированные ДОП.СОГЛ.
        17.07.2012 damir - перекомпиляция.
        14.09.2012 damir - в МТ 111 поле /NAME/ не корректно отражалось наименование клиента,исправил.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        09.10.2013 damir - Т.З. № 1670.
*/
{vc.i}
{vcmtform_txb.i}
{comm-txb_txb.i}
{vcshared5.i}

def var v-cifname as char no-undo.
def var v-cifprefix as char no-undo.
def var v-cifokpo like txb.cif.ssn.
def var v-cifrnn as char no-undo.
def var v-ciftype as integer no-undo.
def var v-cifregion as char no-undo.
def var v-partname as char no-undo.
def var v-partcountry like vcpartner.country no-undo.
def var v-crc as char no-undo.
def var v-bincif as char no-undo.
def var v-iincif as char no-undo.
def var v-bnkbin as char no-undo.
def var v-corrinfo as char init "".
def var v-ourbnk as char.
def var i as inte.
def var v-lg1 as logi.
def var v-lg2 as logi.
def var v-lg3 as logi.
def var v-opertyp as inte.
def var v-operdt as date.

def var EISIGN as char.
def var CONTRACT as char.
def var CDATE as char.
def var CSUMM as char.
def var NRNAME as char.
def var NRCOUNTRY as char.
def var TERM_ as char.
def var CCURR as char.
def var CLASTDATE as char.
def var CLOSEDATE as char.
def var CLOSEFOUND as char.

def temp-table mt
    field i as int
    field contract as int
    field ps as int
    field dnnum as char format "x(25)"
    field dndate as date
    field dntype as char
    field ctformrs as char.

def temp-table t-abbr no-undo
    field nm as char
    field vl as char
index idx1 nm ascending.

def buffer b-mt for mt.
def buffer b-vcps for vcps.
def buffer b2-vccorrecthis for vccorrecthis.

v-ourbnk = comm-txb().

find first txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
if avail txb.sysc then v-bnkbin = txb.sysc.chval.
else v-bnkbin = "".

find first txb.cmp no-lock no-error.

function ExpImp returns inte(input expimp as char).
    if expimp <> "" then do:
        if expimp = 'I' then return 2.
        else return 1.
    end.
    else return 0.
end function.

function RetAbbr returns char(input nm as char).
    find t-abbr where t-abbr.nm = nm no-lock no-error.
    if avail t-abbr then return t-abbr.vl.
    else return "".
end function.

function BegData returns char(input opt as char,input id as inte,input nm as char,input vv as char):
    def buffer b-vccorrecthis for comm.vccorrecthis.

    def var val as char.
    val = "".
    if opt = "VCCONTRS" then do:
        find first b-vccorrecthis where b-vccorrecthis.contract = id and b-vccorrecthis.correctdt <> ? and b-vccorrecthis.sub = nm no-lock no-error.
        if avail b-vccorrecthis then if index(b-vccorrecthis.corrfield,"|") > 0 then val = entry(1,b-vccorrecthis.corrfield,"|").
    end.
    if opt = "VCDOCS" then do:
        find first b-vccorrecthis where b-vccorrecthis.docs = id and b-vccorrecthis.correctdt <> ? and b-vccorrecthis.sub = nm no-lock no-error.
        if avail b-vccorrecthis then if index(b-vccorrecthis.corrfield,"|") > 0 then val = entry(1,b-vccorrecthis.corrfield,"|").
    end.
    if val <> "" then return val.
    else return vv.
end function.

create t-abbr.
t-abbr.nm = "EISIGN". t-abbr.vl = "признака контракта".
create t-abbr.
t-abbr.nm = "CONTRACT". t-abbr.vl = "номера контракта".
create t-abbr.
t-abbr.nm = "CDATE". t-abbr.vl = "даты контракта".
create t-abbr.
t-abbr.nm = "CSUMM". t-abbr.vl = "суммы контракта".
create t-abbr.
t-abbr.nm = "NRNAME". t-abbr.vl = "наименования нерезидента".
create t-abbr.
t-abbr.nm = "NRCOUNTRY". t-abbr.vl = "страны нерезидента".
create t-abbr.
t-abbr.nm = "TERM". t-abbr.vl = "сроков репатриации".
create t-abbr.
t-abbr.nm = "CCURR". t-abbr.vl = "валюты контракта".
create t-abbr.
t-abbr.nm = "CLASTDATE". t-abbr.vl = "последней даты".
create t-abbr.
t-abbr.nm = "CLOSEDATE". t-abbr.vl = "Даты закрытия УНК".
create t-abbr.
t-abbr.nm = "CLOSEFOUND". t-abbr.vl = "основания закрытия УНК".

for each vccontrs where vccontrs.bank = v-ourbnk no-lock:
    if not (vccontrs.cttype = '1') then next.
    v-cifname = "". v-cifokpo = "". v-cifrnn =  "". v-ciftype = 0. v-cifprefix = "". v-bincif = "". v-iincif = "".

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if not avail txb.cif then next.

    v-cifname = trim(substr(txb.cif.name, 1, 95)) + " " + trim(txb.cif.prefix).
    if v-bin then do:
        if txb.cif.type = 'B' then do:
            if txb.cif.cgr <> 403 then do:
                v-ciftype = 1.
                v-cifokpo = trim(txb.cif.ssn).
                v-bincif  = trim(txb.cif.bin).
            end.
            else do:
                v-ciftype = 2.
                v-cifrnn  = trim(string(txb.cif.jss, "999999999999")).
                v-iincif  = trim(txb.cif.bin).
            end.
        end.
    end.
    v-cifprefix = trim(txb.cif.prefix).
    v-cifregion = "".
    find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error.
    if avail txb.sub-cod then v-cifregion = txb.sub-cod.ccode.
    v-partname = "". v-partcountry = "".

    def var c as char.
    def var d as char.
    def var e as char.

    c-vcps:
    for each vcps where vcps.contract = vccontrs.contract no-lock:
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

        v-lg1 = false. v-lg2 = false. v-lg3 = false. v-opertyp = 1. v-operdt = ?.
        if vcps.dntype = '01' then do:
            find last vccorrecthis where vccorrecthis.contract = vccontrs.contract and vccorrecthis.sub = "CSTS" and vccorrecthis.correctdt >= v-dt and vccorrecthis.correctdt <= v-dte no-lock no-error.
            if avail vccorrecthis then do:
                find last b2-vccorrecthis where b2-vccorrecthis.contract = vccontrs.contract and b2-vccorrecthis.sub = "COPERTYP" and b2-vccorrecthis.correctdt >= v-dt and b2-vccorrecthis.correctdt <= v-dte no-lock no-error.
                if avail b2-vccorrecthis then do:
                    v-opertyp = inte(b2-vccorrecthis.corrfield).
                    v-operdt = b2-vccorrecthis.correctdt.
                end.

                if v-opertyp = 3 then v-lg3 = true.
                else do:
                    if vccorrecthis.corrfield <> "C" then v-lg1 = true.
                    else v-lg2 = true.
                end.
            end.
            if v-lg1 then do:
                create t-ps.
                t-ps.oper = "1".
                t-ps.psnum = vcps.dnnum + string(vcps.num).
                t-ps.psdate = vcps.dndate.
                t-ps.bank = vccontrs.bank.
                t-ps.cifname = v-cifname.
                t-ps.cifprefix = v-cifprefix.
                t-ps.cif_rfkod1 = v-cifokpo.
                t-ps.cif_jss = v-cifrnn.
                t-ps.cif_type = v-ciftype.
                t-ps.cif_region = v-cifregion.
                find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
                if avail vcpartners then do:
                    t-ps.partner_name = BegData("VCCONTRS",vccontrs.contract,"NRNAME",trim(vcpartners.name)) + " " + trim(vcpartner.formasob).
                    t-ps.partner_country = BegData("VCCONTRS",vccontrs.contract,"NRCOUNTRY",trim(vcpartner.country)).
                end.
                t-ps.ctexpimp = ExpImp(BegData("VCCONTRS",vccontrs.contract,"EISIGN",vccontrs.expimp)).
                t-ps.ctnum = BegData("VCCONTRS",vccontrs.contract,"CONTRACT",vccontrs.ctnum).
                t-ps.ctregdt = vcps.dndate.
                t-ps.ctdate = date(BegData("VCCONTRS",vccontrs.contract,"CDATE",string(vccontrs.ctdate,"99/99/9999"))) no-error.
                t-ps.ctvalpl = vcps.ctvalpl. /*ВАЛЮТА ПЛАТЕЖА*/
                t-ps.ctsum = vcps.sum / 1000. /*СУММА*/
                t-ps.ctncrc_int = vcps.ncrc. /*ВАЛЮТА*/
                find txb.ncrc where txb.ncrc.crc = t-ps.ctncrc_int no-lock no-error.
                if avail txb.ncrc then t-ps.ctncrc = txb.ncrc.code.
                t-ps.ctogval = vccontrs.info[1].
                t-ps.ctlastdate = vcps.lastdate. /*ПОСЛЕДНЯЯ ДАТА*/
                t-ps.ctformrs = vcps.ctformrs.
                t-ps.okpoprev = vcps.okpoprev.
                t-ps.ctterm = vcps.ctterm. /*СРОКИ РЕПАТРИАЦИИ*/
                t-ps.repdate = vcps.dndate.
                t-ps.note = vcps.dnnote[5].
                t-ps.bankokpo = txb.cmp.addr[3].
                find vcrslc where vcrslc.contract = vcps.contract and vcrslc.dntype = '21' no-lock no-error.
                if avail vcrslc then do:
                    t-ps.rslcdnnum_21 = vcrslc.dnnum.
                    t-ps.rslcdndate_21 = vcrslc.dndate.
                end.
                if v-bin then do:
                    t-ps.bnkbin = v-bnkbin.
                    t-ps.bin = v-bincif.
                    t-ps.iin = v-iincif.
                end.
            end.
            if v-lg2 then do:
                create t-ps.
                t-ps.oper = "1".
                t-ps.psnum = vcps.dnnum + string(vcps.num).
                t-ps.psdate = vcps.dndate.
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
                t-ps.note = trim(vcps.dnnote[5]).
                t-ps.repdate = vccontrs.stsdt.
                if avail txb.cmp then t-ps.bankokpo = trim(txb.cmp.addr[3]).
                if v-bin then t-ps.bnkbin = v-bnkbin.
            end.
            if v-lg3 then do:
                create t-ps.
                t-ps.oper = "3".
                t-ps.psnum = vcps.dnnum + string(vcps.num).
                t-ps.psdate = vcps.dndate.
                t-ps.repdate = v-operdt.
                t-ps.corrinfo = "возобновление контракта".
                t-ps.note = "возобновление контракта".
            end.
        end.
        if ((vcps.dntype = '04' and vcps.info2[1] = "F2") or vcps.dntype = '19') and vcps.dndate >= v-dt and vcps.dndate <= v-dte then do:
            create t-ps.
            t-ps.psnum = vcps.dnnum + string(vcps.num).
            t-ps.psdate = vcps.dndate.
            find first b-vcps where b-vcps.contract = vccontrs.contract and b-vcps.dntype = "01" and b-vcps.ps <> vcps.ps no-lock no-error.
            if avail b-vcps then do:
                t-ps.psnum = b-vcps.dnnum + string(b-vcps.num).
                t-ps.psdate = b-vcps.dndate.
            end.
            if index(vcps.dnnum,"N") > 0 then t-ps.psnum_19 = trim(replace(entry(2,vcps.dnnum),'N',' ')).
            else t-ps.psnum_19 = trim(entry(2,vcps.dnnum)).
            t-ps.psdate_19 = vcps.rdt.
            t-ps.psreason_19 = vcps.info[4] .
            t-ps.repdate = vcps.rdt.
            if avail txb.cmp then t-ps.bankokpo = txb.cmp.addr[3].
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
            if lookup('21',vcps.info[3]) > 0 then t-ps.ctterm = vcps.ctterm.
            if lookup('22',vcps.info[3]) > 0 then t-ps.note = vcps.dnnote[5].
            if lookup('23',vcps.info[3]) > 0 then do:
                find txb.ncrc where txb.ncrc.crc = vccontrs.ncrc no-lock no-error.
                if avail txb.ncrc then t-ps.ctncrc = txb.ncrc.code.
            end.
            if lookup('24',vcps.info[3]) > 0 then t-ps.ctlastdate = vcps.lastdate.
            if lookup('25',vcps.info[3]) > 0 then t-ps.ctvalpl = vcps.ctvalpl.
            if lookup('26',vcps.info[3]) > 0 then t-ps.ctformrs = vcps.ctformrs.
            if lookup('27',vcps.info[3]) > 0 then t-ps.ctogval = vcps.ctvalogr.
            if lookup('28',vcps.info[3]) > 0 then t-ps.ctogval = vcps.ctvalogr.
            t-ps.note = vcps.dnnote[5].
            if v-bin then t-ps.bnkbin = v-bnkbin.
        end.
    end.
    if v-option = "rep" then do:
        if vccontrs.dtcorrect >= v-dt and vccontrs.dtcorrect <= v-dte then do:
            run Fdata(vccontrs.dtcorrect).

            if v-corrinfo <> "" then do:
                find vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
                create t-ps.
                if avail vcps then do:
                    t-ps.psnum = vcps.dnnum + string(vcps.num).
                    t-ps.psdate = vcps.dndate.
                end.
                t-ps.ctexpimp = ExpImp(EISIGN).
                t-ps.ctnum = CONTRACT.
                t-ps.ctdate = date(CDATE) no-error.
                t-ps.ctsum = deci(CSUMM) / 1000 no-error.
                t-ps.partner_name = NRNAME.
                if t-ps.partner_name <> "" then do:
                    find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
                    if avail vcpartners then t-ps.partner_name = trim(trim(t-ps.partner_name) + " " + trim(vcpartner.formasob)).
                end.
                t-ps.partner_country = NRCOUNTRY.
                t-ps.ctterm = TERM_.
                t-ps.ctncrc = CCURR.
                t-ps.ctlastdate = date(CLASTDATE) no-error.
                t-ps.ctclosedt = date(CLOSEDATE) no-error.
                t-ps.ctclosereas = CLOSEFOUND.
                t-ps.corrinfo = v-corrinfo.
                t-ps.note = vcps.dnnote[5].
            end.
        end.
    end.
end.

if v-oper = "2" then run Cdata("1","01",v-dtps,v-dtps,v-dtcorr).

procedure RetVal:
    def input parameter opt as char.
    def input parameter id as inte.
    def input parameter dt as date.
    def input parameter nm as char.
    def output parameter val as char.

    def buffer b-vccorrecthis for comm.vccorrecthis.

    if opt = "VCCONTRS" then do:
        find last b-vccorrecthis where b-vccorrecthis.contract = id and b-vccorrecthis.correctdt = dt and b-vccorrecthis.sub = nm no-lock no-error.
        if avail b-vccorrecthis then if index(b-vccorrecthis.corrfield,"|") > 0 then val = entry(2,b-vccorrecthis.corrfield,"|").
    end.
    if opt = "VCDOCS" then do:
        find last b-vccorrecthis where b-vccorrecthis.docs = id and b-vccorrecthis.correctdt = dt and b-vccorrecthis.sub = nm no-lock no-error.
        if avail b-vccorrecthis then if index(b-vccorrecthis.corrfield,"|") > 0 then val = entry(2,b-vccorrecthis.corrfield,"|").
    end.
end procedure.

procedure Fdata:
    def input parameter dtcor as date.

    v-corrinfo = "". EISIGN = "". CONTRACT = "". CDATE = "". CSUMM = "". NRNAME = "". NRCOUNTRY = "". TERM_ = "". CCURR = "". CLASTDATE = "". CLOSEDATE = "". CLOSEFOUND = "".
    if lookup('12', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"EISIGN",output EISIGN).
        if EISIGN <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("EISIGN").
            else v-corrinfo = RetAbbr("EISIGN").
        end.
    end.
    if lookup('13', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"CONTRACT",output CONTRACT).
        if CONTRACT <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CONTRACT").
            else v-corrinfo = RetAbbr("CONTRACT").
        end.
    end.
    if lookup('14', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"CDATE",output CDATE).
        if CDATE <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CDATE").
            else v-corrinfo = RetAbbr("CDATE").
        end.
    end.
    if lookup('15', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"CSUMM",output CSUMM).
        if CSUMM <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CSUMM").
            else v-corrinfo = RetAbbr("CSUMM").
        end.
    end.
    if lookup('16', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"NRNAME",output NRNAME).
        if NRNAME <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("NRNAME").
            else v-corrinfo = RetAbbr("NRNAME").
        end.
    end.
    if lookup('17', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"NRCOUNTRY",output NRCOUNTRY).
        if NRCOUNTRY <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("NRCOUNTRY").
            else v-corrinfo = RetAbbr("NRCOUNTRY").
        end.
    end.
    if lookup('18', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"TERM",output TERM_).
        if TERM_ <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("TERM").
            else v-corrinfo = RetAbbr("TERM").
        end.
    end.
    if lookup('20', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"CCURR",output CCURR).
        if CCURR <> "" then do:
            find txb.crc where txb.crc.crc = inte(CCURR) no-lock no-error.
            if avail txb.crc then CCURR = txb.crc.code.
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CCURR").
            else v-corrinfo = RetAbbr("CCURR").
        end.
    end.
    if lookup('21', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"CLASTDATE",output CLASTDATE).
        if CLASTDATE <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CLASTDATE").
            else v-corrinfo = RetAbbr("CLASTDATE").
        end.
    end.
    if lookup('22', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"CLOSEDATE",output CLOSEDATE).
        if CLOSEDATE <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CLOSEDATE").
            else v-corrinfo = RetAbbr("CLOSEDATE").
        end.
    end.
    if lookup('23', vccontrs.info[4]) > 0 then do:
        run RetVal("VCCONTRS",vccontrs.contract,dtcor,"CLOSEFOUND",output CLOSEFOUND).
        if CLOSEFOUND <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CLOSEFOUND").
            else v-corrinfo = RetAbbr("CLOSEFOUND").
        end.
    end.
end procedure.

procedure Cdata:
    def input parameter cttype as char.
    def input parameter dntype as char.
    def input parameter dtb as date.
    def input parameter dte as date.
    def input parameter dtcorr as date.

    m1:
    for each vccontrs where vccontrs.bank = v-ourbnk no-lock:
        if not (vccontrs.cttype = cttype) then next m1.
        find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
        if not avail txb.cif then next m1.

        m2:
        for each vcps where vcps.contract = vccontrs.contract no-lock:
            if lookup(vcps.dntype,dntype) = 0 then next m2.

            if not (vcps.dndate >= dtb and vcps.dndate <= dte) then next m2.

            run Fdata(dtcorr).

            if v-corrinfo <> "" then do:
                create t-dc.
                t-dc.cont = vccontrs.contract.
                t-dc.psnum = vcps.dnnum + string(vcps.num).
                t-dc.psdate = vcps.dndate.
                t-dc.dtcorrect = vccontrs.dtcorrect.
                t-dc.ctregdt = vccontrs.ctregdt.

                t-dc.EISIGN = EISIGN.
                t-dc.CONTRACT = CONTRACT.
                t-dc.CDATE = CDATE.
                t-dc.CSUMM = string(round(deci(CSUMM) / 1000,2),"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99") no-error.
                t-dc.NRNAME = NRNAME.
                if t-dc.NRNAME <> "" then do:
                    find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
                    if avail vcpartners then t-dc.NRNAME = trim(trim(t-dc.NRNAME) + " " + trim(vcpartner.formasob)).
                end.
                t-dc.NRCOUNTRY = NRCOUNTRY.
                t-dc.TERM_ = TERM_.
                t-dc.CCURR = CCURR.
                t-dc.CLASTDATE = CLASTDATE.
                t-dc.CLOSEDATE = CLOSEDATE.
                t-dc.CLOSEFOUND = CLOSEFOUND.
                t-dc.note = "Корректировка " + v-corrinfo.
            end.
        end.
    end.
end.

