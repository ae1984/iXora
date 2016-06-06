/* r-klasif-nb2.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Классификация кредитного портфеля для НБРК
 * RUN
        r-klasif-nb2
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT

 * INHERIT

 * MENU
        4-2-5-11
 * BASES
        BANK TXB COMM
 * AUTHOR
        23.06.2011 aigul
 * CHANGES
        04.07.2011 aigul - добавила комменты - описание переменных и алгоритма
        21.07.2011 kapar - вывод данных из excel
*/

def input parameter datums as date no-undo.
def shared var g-today as date.
def var i as int no-undo.
def shared temp-table wrk no-undo
    field num as inte /*нумерация*/
    field fcode as int /*код филиала*/
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
    field sup-sum-kzt as decimal.
def buffer b-lnmoncln for txb.lnmoncln.
def buffer b-lon for txb.lon.
def var v-dtk as date.
def var nm as char.
def var v-prov as decimal.
def var v-bal as decimal.
def var s-ourbank as char no-undo.
def var v-sup-sum as decimal.
def var v-sup-sum1 as decimal.
def var v-sup-sum-kzt as decimal.
def var v-sup-sum-kzt1 as decimal.
def var v-sup-sum-kzt2 as decimal.
def var v-sup-sum-kzt3 as decimal.
def var v-sup-sum-kzt-all as decimal.
def var v-sup-sum-kzt-all1 as decimal.
def var rates as deci extent 3.
def var v-od as decimal.
def var v-total as decimal.
def var v-total1 as decimal.
def var v-perc as decimal.
def var v-chk as deci.
def var v-chk1 as deci.
def var v-chk2 as deci.
def var v-chk3 as deci.
def var prov as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var v-prov_od as decimal.
def var v-prov_prc as decimal.
def var v-prov_pen as decimal.
def var v-porog as decimal.
def var v-perc-rate as decimal.
def temp-table wrk1
    field lon as char.
def shared temp-table list
    field dt as date
    field fcode as int
    field fil as char
    field lon as char
    field fin as decimal
    field exp-pay as decimal
    field sup-qual as decimal
    field shr as decimal
    field rate as decimal
    field total as char
index ind is primary fcode lon.

v-porog = 0.
v-chk = 0.
rates[1] = 1.
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < datums no-lock no-error.
if avail txb.crchis then rates[2] = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < datums no-lock no-error.
if avail txb.crchis then rates[3] = txb.crchis.rate[1].
v-sup-sum = 0.
v-prov = 0.
v-bal = 0.
v-dtk = ?.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).
v-prov_od = 0.
v-prov_prc = 0.
v-prov_pen = 0.
prov = 0.
/*пороговая сумма для однородных кредитов*/
find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnodnor" no-lock no-error.
if avail pksysc then v-porog = pksysc.deval.
for each txb.lon no-lock:
    /* Убрал Капар
    find first txb.lnscg where txb.lnscg.lng = txb.lon.lon no-lock no-error.
    if avail txb.lnscg  then do:
    if txb.lnscg.stdat >= datums then next.
    end.
    */
    if txb.lon.opnamt <= 0 then next.

    run lonbalcrc_txb('lon',txb.lon.lon,datums,"1,7",no,txb.lon.crc,output v-chk).

    /*Начало добавил Капар*/
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"2,9",no,txb.lon.crc,output v-perc).

    run lonbalcrc_txb ('lon',txb.lon.lon,datums,"6",no,txb.lon.crc,output v-prov_od).
    v-prov_od = - v-prov_od.
    if txb.lon.crc <> 1 then do:
       find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= datums no-lock no-error.
       if avail txb.crchis then v-prov_od = v-prov_od * txb.crchis.rate[1].
       else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
    end.

    run lonbalcrc_txb ('lon',txb.lon.lon,datums,"36",no,txb.lon.crc,output v-prov_prc).
    v-prov_prc = - v-prov_prc.
    if txb.lon.crc <> 1 then do:
       find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= datums no-lock no-error.
       if avail txb.crchis then v-prov_prc = v-prov_prc * txb.crchis.rate[1].
       else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
    end.

    run lonbalcrc_txb ('lon',txb.lon.lon,datums,"37",no,1,output v-prov_pen).
    v-prov_pen = - v-prov_pen.

    prov = v-prov_od + v-prov_prc + v-prov_pen.

    if v-chk <= 0 and v-perc <= 0 and prov <= 0 then next. /*0 остаток не нужны*/
    /*Конец*/

    create wrk.
    find first txb.cmp where txb.cmp.code = int(substr(s-ourbank,4,3)) no-lock no-error.
    if avail txb.cmp then do:
     wrk.fcode = int(substr(s-ourbank,4,3)).
     wrk.fil = txb.cmp.name.
    end.
    wrk.cif = txb.lon.cif.
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then do:
        wrk.cname = txb.cif.name.
        /*организациионно-правовая форма*/
        wrk.org = txb.cif.prefix.
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
    /*наименование группы кредита*/
    wrk.grp = txb.lon.grp.
    find first txb.longrp where txb.longrp.longrp = txb.lon.grp no-lock no-error.
    if avail txb.longrp then wrk.lontype = txb.longrp.des.
    /*признак однородности*/
    /*find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnodnor' no-lock no-error.
    if avail txb.sub-cod then do:
        wrk.sign = txb.sub-cod.ccode.
    end.
    else*/ wrk.sign = "нет".
    /*номер контракта*/
    find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if avail txb.loncon then wrk.contr = txb.loncon.lcnt.
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
    else wrk.seco = "НЕ ПРОСТАВЛЕНА".
    /*дата выдачи*/
    find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
    if avail txb.lnscg then wrk.issuedt = txb.lnscg.stdat.
    /*wrk.issuedt = txb.lon.opndt.*/
    /*дата погашения*/
    wrk.rpaydt = txb.lon.duedt.
    /*процентная ставка*/
    v-perc-rate = 0.
    find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < datums and txb.ln%his.intrate <> 0 no-lock no-error.
    if avail txb.ln%his then v-perc-rate = txb.ln%his.intrate.
    else v-perc-rate = txb.lon.prem.
    wrk.perc-rate = v-perc-rate.
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
    /*wrk.od = txb.lon.opnamt.*/
    /*ОД*/
    v-od = 0.
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"1,7",no,txb.lon.crc,output v-od).
    wrk.od = v-od.
    if txb.lon.crc <> 1 then do:
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < datums no-lock no-error.
        if avail txb.crchis then v-od = v-od * txb.crchis.rate[1].
    end.
    /*просроченный ОД*/
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"7",no,txb.lon.crc,output wrk.exp-od).
    /*проценты*/
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"2,9",no,txb.lon.crc,output wrk.perc).
    /*просроченные проценты*/
    run lonbalcrc_txb('lon',txb.lon.lon,datums,"9",no,txb.lon.crc,output wrk.exp-perc).
    /*описание обеспечения и сумма*/
    v-sup-sum = 0.
    v-sup-sum-kzt = 0.
    v-sup-sum-kzt2 = 0.
    v-sup-sum-kzt-all = 0.
    for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
       v-sup-sum = v-sup-sum + txb.lonsec1.secamt.
       if txb.lonsec1.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lonsec1.crc and txb.crchis.rdt < datums no-lock no-error.
            if avail txb.crchis then v-sup-sum-kzt = txb.lonsec1.secamt * txb.crchis.rate[1].
       end.
       if txb.lonsec1.crc = 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lonsec1.crc and txb.crchis.rdt < datums no-lock no-error.
            if avail txb.crchis then v-sup-sum-kzt2 = txb.lonsec1.secamt * txb.crchis.rate[1].
       end.
       v-sup-sum-kzt-all =  v-sup-sum-kzt-all + v-sup-sum-kzt + v-sup-sum-kzt2.
       if wrk.sup-char = "" then wrk.sup-char = txb.lonsec1.prm + "(" + txb.lonsec1.vieta + ")".
       else wrk.sup-char = wrk.sup-char + ", " + txb.lonsec1.prm + "(" + txb.lonsec1.vieta + ")".
    end.
    v-sup-sum1 = 0.
    v-sup-sum-kzt1 = 0.
    v-sup-sum-kzt3 = 0.
    v-sup-sum-kzt-all1 =  0.
    if txb.lon.clmain <> '' then do:
        find first wrk1 where wrk1.lon = txb.lon.clmain no-lock no-error.
        if not avail wrk1 then do:
            find last b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
            if avail b-lon then do:
                for each txb.lonsec1 where txb.lonsec1.lon = b-lon.lon no-lock:
                   v-sup-sum1 = v-sup-sum1 + txb.lonsec1.secamt.
                   if txb.lonsec1.crc <> 1 then do:
                        find last txb.crchis where txb.crchis.crc = txb.lonsec1.crc and txb.crchis.rdt < datums no-lock no-error.
                        if avail txb.crchis then v-sup-sum-kzt1 = txb.lonsec1.secamt * txb.crchis.rate[1].
                   end.
                   if txb.lonsec1.crc = 1 then do:
                        find last txb.crchis where txb.crchis.crc = txb.lonsec1.crc and txb.crchis.rdt < datums no-lock no-error.
                        if avail txb.crchis then v-sup-sum-kzt3 = txb.lonsec1.secamt * txb.crchis.rate[1].
                   end.
                   v-sup-sum-kzt-all1 =  v-sup-sum-kzt-all1 + v-sup-sum-kzt1 + v-sup-sum-kzt3.
                end.
                create wrk1.
                wrk1.lon = b-lon.lon.
            end.
        end.
    end.
    wrk.sup-sum = v-sup-sum + v-sup-sum1.
    wrk.sup-sum-kzt = v-sup-sum-kzt-all + v-sup-sum-kzt-all1.
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
    /*find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
    if avail txb.lonhar then do:
        find first txb.lonstat where txb.lonstat.ln = txb.lonhar.lonstat no-lock no-error.
        if avail txb.lonstat then wrk.categ = txb.lonstat.apz.
    end.*/
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < datums use-index lonhar-idx1 no-lock no-error.
    if avail txb.lonhar then find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    if avail txb.lonstat then wrk.categ = txb.lonstat.apz.
    else wrk.categ = "стандартный".
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
    /*баллы - фин сост*/
    v-total = 0.
    find last kdlonkl where kdlonkl.kod = "finsost1" and
    kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.rdt < datums
    use-index bclrdt no-lock no-error.
    if avail kdlonkl then wrk.fin = kdlonkl.rating.
    /*баллы - просрорчка платежей*/
    find last kdlonkl where kdlonkl.kod = "prosr" and
    kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.rdt < datums
    use-index bclrdt no-lock no-error.
    if avail kdlonkl then wrk.exp-pay = kdlonkl.rating.
    /*баллы - качество обеспеч*/
    find last kdlonkl where kdlonkl.kod = "obesp1" and
    kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.rdt < datums
    use-index bclrdt no-lock no-error.
    if avail kdlonkl then wrk.sup-qual = kdlonkl.rating.

    /*баллы - доля нецелевого исп*/
    find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = "purpose"
    no-lock no-error.
    if avail txb.lnmoncln  and txb.lnmoncln.edt <> ? then do:
        find last b-lnmoncln where b-lnmoncln.lon = txb.lnmoncln.lon and b-lnmoncln.code = "purpose" and b-lnmoncln.edt < datums no-lock no-error.
        if avail b-lnmoncln then do:
        if b-lnmoncln.res-deci[1] >= 75 then wrk.shr = 0.
        if b-lnmoncln.res-deci[1] < 75 then wrk.shr = 1.
        if b-lnmoncln.res-deci[1] < 50 then wrk.shr = 2.
        if b-lnmoncln.res-deci[1] < 25 then wrk.shr = 3.
        if b-lnmoncln.res-deci[1] = 0 then wrk.shr = 4.
        end.
    end.
    if  avail txb.lnmoncln  and txb.lnmoncln.edt = ? then do:
        find last b-lnmoncln where b-lnmoncln.lon = txb.lnmoncln.lon and b-lnmoncln.code = "purpose" and b-lnmoncln.pdt < datums no-lock no-error.
        if avail b-lnmoncln then wrk.shr = 4.
    end.
    /*если дата отчета с 1 марта 2011 то 90,92,81,82,26,16,56,66 с суммой меньше пороговой в справочнике v-porog */


    if datums >= 03/01/2011 then do:
        wrk.rate = 0.
        if (txb.lon.grp = 90 or txb.lon.grp = 92) and v-od <= v-porog then do:
            wrk.sign = "да".
            wrk.categ = "безнадежный".
            wrk.fin = 0.
            wrk.exp-pay = 0.
            wrk.sup-qual = 0.
            wrk.rate = 0.
        end.
        if (txb.lon.grp = 90 or txb.lon.grp = 92) and v-od > v-porog then do:
            v-total1 = wrk.fin + wrk.exp-pay + wrk.sup-qual + wrk.shr + wrk.rate.
            wrk.sign = "нет".
            find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < datums use-index lonhar-idx1 no-lock no-error.
            if avail txb.lonhar then find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
            if avail txb.lonstat then wrk.categ = txb.lonstat.apz.
            else wrk.categ = "стандартный".
        end.
        if (txb.lon.grp = 81 or txb.lon.grp = 82) and v-od <= v-porog then do:
            wrk.sign = "да".
            wrk.totball = "Однор.Сотрудн ".
            wrk.fin = 0.
            wrk.exp-pay = 0.
            wrk.sup-qual = 0.
            wrk.rate = 0.
        end.
        if (txb.lon.grp = 81 or txb.lon.grp = 82) and v-od > v-porog then do:
            wrk.sign = "нет".
        end.

    end.
    if (txb.lon.grp = 16 or txb.lon.grp = 26 or txb.lon.grp = 56 or txb.lon.grp = 66) and v-od <= v-porog then do:
            wrk.sign = "да".
            wrk.categ = "стандартный".
            wrk.fin = 0.
            wrk.exp-pay = 0.
            wrk.sup-qual = 0.
            wrk.rate = 0.
            wrk.totball = "Однор.Сотрудн ".
    end.
     /*итоговый бал*/
    v-total =  wrk.fin + wrk.exp-pay + wrk.sup-qual + wrk.shr + wrk.rate.
    if wrk.totball = "" then wrk.totball = replace(trim(string(v-total,"->>>>>>>>>>>>>>>>>9.99")),'.',',').
    /*если данные по балам нужно тянуть с файлов - запятые используются для отделения полей, для указания десятичных цифр нужно в файле использовать точки*/

    v-total = 0.
    for each list where list.fcode = wrk.fcode and list.lon = wrk.lon no-lock:
        /*message wrk.lon view-as alert-box.*/
        wrk.fin = list.fin.
        wrk.exp-pay = list.exp-pay.
        wrk.sup-qual = list.sup-qual.
        wrk.rate = list.rate.
        wrk.shr = list.shr.
        wrk.totball = replace(trim(list.total),'.',',').
    end.

end.
