/* r-klasifo-nb2.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Классификация кредитного портфеля для НБРК
 * RUN
        r-klasifo-nb
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT

 * INHERIT
        r-klasifo-nb2(input datums)
 * MENU
        3-4-16-3
 * BASES
        BANK TXB COMM
 * AUTHOR
        27.06.2011 aigul
 * CHANGES
        04.07.2011 aigul - добавила комменты - описание переменных и алгоритма
*/
def input parameter datums as date no-undo.
def shared var g-today as date.
def var i as int no-undo.
def shared temp-table wrk no-undo
    field num as inte /*нумерация*/
    field fil as char /*филиал*/
    field cif as char /*номер клиента*/
    field cname as char /*наименование клиента*/
    field org as char /*ТОО,ИП,ФЛ*/
    field lontype as char /*группа кредита - наименование*/
    field seco as char /*шифр экономики*/
    field rez as char  /*резид*/
    field inside as char /*нумерация*/
    field sign as char /*признак однородности*/
    field contr as char /*номер контракта*/
    field grp as  int /*группа кредита*/
    field issuedt as date /*дата регистр кредита*/
    field rpaydt as date /*дата погашения*/
    field perc-rate as decimal /*процентная ставка*/
    field crc as int /*валюта кредита*/
    field crccode as char /*валюта кредита - наименование*/
    field acc as char /*счет по НПС*/
    field lon as char /*номер кредита*/
    field od as decimal /*ОД*/
    field exp-od as decimal /*просрочен ОД*/
    field perc as decimal /*проценты*/
    field exp-perc as decimal /*просрочен проценты*/
    field sup-sum as decimal /*сумма обеспечения*/
    field sup-char as char /*описание обеспечения*/
    field rpayod as char /*условия погашения ОД*/
    field rpayperc as char /*условия погашения процентов*/
    field categ as char /*классификация - категория*/
    field provi-sum as decimal /*сумма провизий*/
    field fin as decimal /*фин сост*/
    field exp-pay as decimal /*просрочка платежей*/
    field sup-qual as decimal /*качесчтво обеспечен*/
    field shr as decimal /*доля нецелев использ*/
    field rate as decimal /*наличие рейтинга*/
    field totball as char /*итого баллов*/
    field rezid as char /*гео код*/
    field scode as char /*сектор экономики*/
    field val as char /*опред валюты*/
    field rel as char /*связ/не связ лицо*/
    field gl_perc as int /*счет ГК процент*/
    field gl_exp-perc as int /*счет ГК просроч процент*/
    field sup-r as deci /*обеспеч - рыночная стоимость*/
    field sup-z as deci /*обеспечен - залоговая стоимость*/
    field sup-h as char /*обеспечен - характеристика*/
    field sup-vh as char /*высоколиквидн обеспечен - характеристика*/
    field sup-vz as deci /*высоколиквидн обеспечен - залоговая стоимость*/
    field kol-od as int /*количество дней просрочки ОД*/
    field kol-perc as int /*количество дней просрочки процент*/.
    def var nm as char.
def var v-prov as decimal.
def var v-bal as decimal.
def var s-ourbank as char no-undo.
def var v-sup-sum as decimal.
def var rates as deci extent 3.
def var v-od as decimal.
def var v-total as decimal.
def var v-total1 as decimal.
def var v-perc as decimal.
def var v-chk as deci.
def var v-amt as deci.
def var prov as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var v-prov_od as decimal.
def var v-prov_prc as decimal.
def var v-prov_pen as decimal.
def var v-porog as decimal.
v-porog = 0.
v-amt = 0.
v-chk = 0.
rates[1] = 1.
/*пороговая сумма для однородных кредитов*/
find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnodnor" no-lock no-error.
if avail pksysc then v-porog = pksysc.deval.
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt <= datums no-lock no-error.
if avail txb.crchis then rates[2] = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt <= datums no-lock no-error.
if avail txb.crchis then rates[3] = txb.crchis.rate[1].
v-sup-sum = 0.
v-prov = 0.
v-bal = 0.
v-prov_od = 0.
v-prov_prc = 0.
v-prov_pen = 0.
prov = 0.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).
for each txb.lon where (txb.lon.grp = 90 or txb.lon.grp = 92 or txb.lon.grp = 81 or txb.lon.grp = 82 or txb.lon.grp = 16 or
txb.lon.grp = 26 or txb.lon.grp = 56 or txb.lon.grp = 66) no-lock:
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"1,7",no,txb.lon.crc,output v-chk).
    if txb.lon.crc = 1 then v-amt = v-chk.
    else do:
        find last txb.ncrchis where txb.ncrchis.crc = txb.lon.crc and txb.ncrchis.rdt < datums no-lock no-error.
        if avail txb.ncrchis then v-amt = v-chk * txb.ncrchis.rate[1].
        find last txb.ncrchis where txb.ncrchis.crc = 1 and txb.ncrchis.rdt < datums no-lock no-error.
        if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
    end.
    if (v-amt > v-porog) or (v-chk = 0) then next. /*ОД с 0 остатком и с суммой больше пороговойне нужны*/
    create wrk.
    find first txb.cmp where txb.cmp.code = int(substr(s-ourbank,4,3)) no-lock no-error.
    if avail txb.cmp then wrk.fil = txb.cmp.name.
    wrk.cif = txb.lon.cif.
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then do:
        wrk.cname = txb.cif.name.
        wrk.org = txb.cif.prefix.
        /*организациионно-правовая форма*/
        if wrk.org = "" then do:
            find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" and txb.sub-cod.acc = txb.lon.cif no-lock no-error.
            if avail txb.sub-cod then do:
                find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                if avail txb.codfr then wrk.org = txb.codfr.name[1].
            end.
        end.
        /*резиденство*/
        wrk.rezid = string (txb.cif.geo).
        if txb.cif.geo = "021" then wrk.rez = "Резидент".
        else wrk.rez = "Нерезидент".
        /*инсайдер*/
        if txb.cif.jss <> '' then do:
            find first prisv where prisv.rnn = txb.cif.jss and prisv.rnn <> '' no-lock no-error.
            if avail prisv then do:
                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                 if avail txb.codfr then wrk.inside = txb.codfr.name[1].
                 if not avail txb.codfr then wrk.inside = 'Нет такого справочника'.
            end.
            else do:
            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
            find first prisv where trim(prisv.name) = nm no-lock no-error.
            if avail prisv then do:
                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                 if avail txb.codfr then wrk.rel = txb.codfr.name[1].
                 if not avail txb.codfr then wrk.inside = 'Нет такого справочника'.
            end.
            else wrk.inside = "Не связанное лицо".
            end.
        end.
        if txb.cif.jss = '' then do:
            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
            find first prisv where trim(prisv.name) = nm no-lock no-error.
            if avail prisv then do:
                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                 if avail txb.codfr then wrk.inside = txb.codfr.name[1].
                 if not avail txb.codfr then wrk.inside = 'Нет такого справочника'.
            end.
            else wrk.inside = "Не связанное лицо".
        end.
    end.
    /*группа кредитов*/
    wrk.grp = txb.lon.grp.
    find first txb.longrp where txb.longrp.longrp = txb.lon.grp no-lock no-error.
    if avail txb.longrp then wrk.lontype = txb.longrp.des.
    if  (txb.longrp.longrp = 90 or  txb.longrp.longrp = 92) then wrk.sign = "Метрокредит".
    if  (txb.longrp.longrp = 81 or  txb.longrp.longrp = 82) then wrk.sign = "Сотрудники".
    if  (txb.longrp.longrp = 16 or  txb.longrp.longrp = 26  or
    txb.longrp.longrp = 56 or  txb.longrp.longrp = 66) then wrk.sign = "Метро-экспресс МСБ".
    find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if avail txb.loncon then wrk.contr = replace(txb.loncon.lcnt,'.','/').
    /*сектор экономики*/
    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'secek' and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
        if avail txb.sub-cod then wrk.scode = string (txb.sub-cod.ccode).
    /*find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lneko' no-lock no-error.
    if avail txb.sub-cod then do:
        find first txb.codfr where txb.codfr.codfr = "lneko" and txb.codfr.code = txb.sub-cod.ccode no-lock.
        if avail txb.codfr then wrk.seco = txb.codfr.name[1].
    end.
    else wrk.seco = "НЕ ПРОСТАВЛЕНА".*/
    /*шифр экономики*/
    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif
    and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
    if avail txb.sub-cod then do:
        find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
        wrk.seco = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
    end.
    /*номер контракта*/
    find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if avail txb.loncon then wrk.contr = txb.loncon.lcnt.
    /*дата выдачи*/
    find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
    if avail txb.lnscg then wrk.issuedt = txb.lnscg.stdat.
    /*wrk.issuedt = txb.lon.opndt.*/
    /*дата погашения*/
    wrk.rpaydt = txb.lon.duedt.
    /*процентная ставка*/
    /*find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < datums no-lock no-error.
    if avail txb.ln%his then wrk.perc-rate = txb.ln%his.intrate.
    else wrk.perc-rate = txb.lon.prem.*/
    if txb.lon.prem > 0 then wrk.perc-rate = txb.lon.prem.
    else
    if txb.lon.prem1 > 0 then wrk.perc-rate = txb.lon.prem1.
    else do:
        find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.intrate > 0 no-lock no-error.
        if avail txb.ln%his then wrk.perc-rate = txb.ln%his.intrate.
        else do:
            find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
            if avail pkanketa then wrk.perc-rate = pkanketa.rateq.
        end.
    end.
    /*wrk.perc-rate = txb.lon.base + string(txb.lon.prem).*/
    /*валюта кредита*/
    find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
    if avail txb.crc then wrk.crccode = txb.crc.code.
    wrk.crc = txb.lon.crc.
    /*счет по НПС*/
    if txb.lon.crc = 1 then wrk.val = "1".
    else if txb.lon.crc = 2 or txb.lon.crc = 3 or txb.lon.crc = 6 then wrk.val = "2".
    else if txb.lon.crc = 4 then wrk.val = "3".
    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'secek' and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
    if avail txb.sub-cod then wrk.scode = string (txb.sub-cod.ccode).
    wrk.acc = substring(string(txb.lon.gl),1,4) + substring (wrk.rezid, 3, 1) + string (wrk.scode) + string (wrk.val).
    wrk.lon = "'" + txb.lon.lon.
    /*ОД*/
    /*wrk.od = txb.lon.opnamt.*/
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"1,7",no,txb.lon.crc,output wrk.od).
    /*просроченный ОД*/
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"7",no,txb.lon.crc,output wrk.exp-od).
    /*проценты*/
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"2,9",no,txb.lon.crc,output wrk.perc).
    /*просроченные проценты*/
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"9",no,txb.lon.crc,output wrk.exp-perc).
    /*описание обеспечения и сумма*/
    for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
       v-sup-sum = v-sup-sum + lonsec1.secamt.
       if wrk.sup-char = "" then wrk.sup-char = lonsec1.prm + lonsec1.vieta.
       else wrk.sup-char = wrk.sup-char + ", " + lonsec1.prm + lonsec1.vieta.
    end.
    wrk.sup-sum = v-sup-sum.
    /*условия погашения ОД*/
    find txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnpmtper' no-lock no-error.
    if avail txb.sub-cod then do:
        find first txb.codfr where txb.codfr.codfr = "lnpmtper" and txb.codfr.code = txb.sub-cod.ccode no-lock.
        if avail txb.codfr then wrk.rpayod = txb.codfr.name[1].
    end.
    /*условия погашения процентов*/
    find txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnpmtper%' no-lock no-error.
    if avail txb.sub-cod then do:
        find first txb.codfr where txb.codfr.codfr = "lnpmtper" and txb.codfr.code = txb.sub-cod.ccode no-lock.
        if avail txb.codfr then wrk.rpayperc = txb.codfr.name[1].
    end.
    /*калссификация - категория*/
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
    if avail txb.lonhar then do:
        find first txb.lonstat where txb.lonstat.ln = txb.lonhar.lonstat no-lock no-error.
        if avail txb.lonstat then wrk.categ = txb.lonstat.apz.
    end.
    /*сумма провизий*/
    run lonbalcrc_txb ('lon',txb.lon.lon,datums,"6",no,txb.lon.crc,output v-prov_od).
    v-prov_od = - v-prov_od.
    if txb.lon.crc <> 1 then do:
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < datums no-lock no-error.
        if avail txb.crchis then v-prov_od = v-prov_od * txb.crchis.rate[1].
        else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
     end.
    run lonbalcrc_txb ('lon',txb.lon.lon,datums,"36",no,txb.lon.crc,output v-prov_prc).
    v-prov_prc = - v-prov_prc.
     if txb.lon.crc <> 1 then do:
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < datums no-lock no-error.
        if avail txb.crchis then v-prov_prc = v-prov_prc * txb.crchis.rate[1].
        else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
     end.
    run lonbalcrc_txb ('lon',txb.lon.lon,datums,"37",no,1,output v-prov_pen).
    v-prov_pen = - v-prov_pen.
    prov = v-prov_od + v-prov_prc + v-prov_pen.
    wrk.provi-sum = prov.
    /*количество проср дней ОД и процентов*/
    run lndayspr_txb(txb.lon.lon,datums,no,output wrk.kol-od,output wrk.kol-perc).
    /*Для след груп обеспеч заполняется отдельно*/
    if (txb.lon.grp = 90 or txb.lon.grp = 92) then do:
        wrk.categ = "безнадежный".
        if wrk.sup-char = "" then wrk.sup-sum = 0.
    end.
    if (txb.lon.grp = 81 or txb.lon.grp = 82) then do:
        if wrk.sup-char = "" then wrk.sup-sum = 0.
    end.
end.