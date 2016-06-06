/* eknewacc.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Открытие счетов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        11.11.2013 Lyubov - ТЗ 2177, проставление характеристики актива
*/

{global.i}
{pk.i}

{lonlev.i}
{pkduedt.i}

def shared var v-cifcod  as char no-undo.
def shared var v-bank    as char no-undo.
def shared var s-ln      as inte no-undo.

def var v-typ as char no-undo.
def new shared var s-longrp like longrp.longrp.
def new shared var s-aaa like aaa.aaa.
def new shared var s-lgr like lgr.lgr.

def var v-shifr as char no-undo.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '10' and pkanketa.ln = s-ln no-lock no-error.
if not avail pkanketa then leave.

if pkanketa.sts = '111' then do:
    message ' Действия по анкете запрещены, по причине - отказ клиента от Экспресс-кредита ' view-as alert-box.
    return.
end.

if pkanketa.sts = '22' then do:

    /* открытие счетов */
    find pksysc where pksysc.credtype = '10' and pksysc.sysc = "dtchck" no-lock no-error.
    if avail pksysc and pksysc.loval and pkanketa.docdt < g-today then do:
        message "Дата договора меньше сегодняшней!~nВ выдаче отказано" view-as alert-box title "".
        return.
    end.

    /* определение группы кредита */

    v-typ = "longr" + (if pkanketa.srok <= 12 then "1" else "2"). /* делим только по сроку - по валюте не надо! */

    find first pksysc where pksysc.credtype = '10' and pksysc.sysc = v-typ no-lock no-error.
    s-longrp = pksysc.inval.

    find longrp where longrp.longrp = s-longrp no-lock no-error.
    find gl of longrp no-lock no-error.

    run acng(input gl.gl, false, output s-lon).

    if pkanketa.lon = '' then do transaction:
        find lon where lon.lon eq s-lon exclusive-lock.
        assign lon.grp = s-longrp
               lon.cif = v-cifcod
               lon.gl = longrp.gl
               lon.rdt = g-today
               lon.extdt = today
               lon.base = "F"
               lon.prnmos = 2
               lon.who = g-ofc
               lon.whn = g-today
               lon.prem = pkanketa.rateq
               lon.duedt = pkanketa.duedt
               lon.loncat = 504
               lon.opnamt = pkanketa.summa
               lon.crc = pkanketa.crc
               lon.gua = "LO".

        find first pksysc where pksysc.credtype = '10' and pksysc.sysc = "pkbase" no-lock no-error.
        lon.basedy = pksysc.inval.
        lon.clnsts = 1. /* физ. лицо */
        lon.sts = "A".

        create loncon.
        assign loncon.lon = s-lon
               loncon.cif =  v-cifcod
               loncon.rez-char[9] = pkanketa.rnn
               loncon.who = g-ofc
               loncon.whn = g-today
               loncon.objekts = pkanketa.goal
               loncon.lcnt = pkanketa.rescha[1].

        find first pksysc where pksysc.credtype = '10' and pksysc.sysc = "lnpen%" no-lock no-error.
        loncon.sods1 = pksysc.deval.
        lon.penprem = loncon.sods1.
        lon.penprem7 = loncon.sods1.

        find first lonstat no-lock. /****************************************/

        create lonhar.
        assign lonhar.lon = s-lon
               lonhar.ln = 1
               lonhar.lonstat = lonstat.lonstat
               lonhar.fdt = date(1, 1, 1901)
               lonhar.cif = v-cifcod
               lonhar.akc = no
               lonhar.who = g-ofc
               lonhar.whn = g-today.

        find first lonhar where lonhar.lon = s-lon no-lock no-error.
        if not available lonhar then do:
            create lonhar.
            assign lonhar.lon = s-lon
                   lonhar.ln = 2
                   lonhar.fdt = date(1, 1, 1901)
                   lonhar.cif = v-cifcod
                   lonhar.akc = no
                   lonhar.finrez = 999999999999.99
                   lonhar.who = g-ofc
                   lonhar.whn = g-today.
        end.

        find first ln%his where ln%his.lon = s-lon no-lock no-error.
        if not avail ln%his then do:
            create ln%his.
            assign ln%his.stdat = g-today
                   ln%his.who = g-ofc
                   ln%his.whn = g-today
                   ln%his.lon = s-lon
                   ln%his.f0 = 1
                   ln%his.intrate = lon.prem
                   ln%his.opnamt = lon.opnamt
                   ln%his.rdt = g-today
                   ln%his.duedt = lon.duedt
                   ln%his.cif = v-cifcod
                   ln%his.lcnt = loncon.lcnt
                   ln%his.gua = lon.gua
                   ln%his.grp = lon.grp
                   ln%his.loncat = lon.loncat.
        end.

        create lonsec1.
        assign lonsec1.lon = s-lon
               lonsec1.ln = 1
               lonsec1.fdt = lon.rdt
               lonsec1.tdt = lon.duedt
               lonsec1.secamt = pkanketa.billsum
               lonsec1.crc = lon.crc
               lonsec1.prm = pkanketa.goal
               lonsec1.lonsec = 5.

        for each sub-dic where sub-dic.sub = "lon" no-lock.
            find first sub-cod where sub-cod.acc = s-lon and sub-cod.sub = "lon" and sub-cod.d-cod = sub-dic.d-cod use-index dcod  no-lock no-error .
            if not avail sub-cod then do:
                create sub-cod.
                sub-cod.acc = s-lon.
                sub-cod.sub = "lon".
                sub-cod.d-cod = sub-dic.d-cod .
                sub-cod.ccode = "msc" .
            end.
        end.

        find ofc where ofc.ofc = g-ofc no-lock no-error.

        {pk-sub-cod.i "'lon'" "'docbd'"     s-lon "'01'" }
        {pk-sub-cod.i "'lon'" "'ecdivis'"   s-lon "'0'"  }
        {pk-sub-cod.i "'lon'" "'flagl'"     s-lon "'02'" }
        {pk-sub-cod.i "'lon'" "'lneko'"     s-lon "'92'" }
        {pk-sub-cod.i "'lon'" "'lnhld'"     s-lon "'15'" }
        {pk-sub-cod.i "'lon'" "'lnobes'"    s-lon "'0'"  }

        if pkanketa.srok <= 12 then {pk-sub-cod.i "'lon'" "'lnovdcd'" s-lon "'29'" }
        else {pk-sub-cod.i "'lon'" "'lnovdcd'" s-lon "'30'" }

        {pk-sub-cod.i "'lon'" "'lnpen'"     s-lon "'02'" }
        {pk-sub-cod.i "'lon'" "'lnpmtper'"  s-lon "'2'"  }
        {pk-sub-cod.i "'lon'" "'lnpmtper%'" s-lon "'2'"  }

        find first pcstaff0 where pcstaff0.cif = v-cifcod no-lock no-error.
        if      pcstaff0.pcprod = 'staff'  then {pk-sub-cod.i "'lon'" "'lnprod'" s-lon "'16'" }
        else if pcstaff0.pcprod = 'salary' then {pk-sub-cod.i "'lon'" "'lnprod'" s-lon "'17'" }

        /*{r-branch.i &proc = "obyaz_txb"}
        if summa > 1500000 then {pk-sub-cod.i "'lon'" "'lnodnor'" s-lon "'01'" }*/

        {pk-sub-cod.i "'lon'" "'lnsegm'" s-lon "'05'" }

        /* определение шифра в зависимости от валюты - тенге = 1, СКВ = 3, ДВВ = 5 */
        if pkanketa.srok <= 12 then v-shifr = "05".
                               else v-shifr = "06".
        {pk-sub-cod.i "'lon'" "'lnshifr'"  s-lon v-shifr }

        /* определение связанности с банком особыми отношениями */
        find first prisv where prisv.rnn = pkanketa.rnn and prisv.rnn <> '' no-lock no-error.
        if avail prisv then {pk-sub-cod.i "'lon'" "'lnsrel'" s-lon "'1'"}

        if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 90   then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'02'"} end.
        else if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 180  then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'03'"} end.
        else if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 360  then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'04'"} end.
        else if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 1080 then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'05'"} end.
        else do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'06'"} end.

        {pk-sub-cod.i "'lon'" "'lntgt'"    s-lon "'15'"  }
        {pk-sub-cod.i "'lon'" "'lntgt'"    s-lon "'15.2'"}
        {pk-sub-cod.i "'lon'" "'lonkb'"    s-lon "'01'"  }
        {pk-sub-cod.i "'lon'" "'sproftcn'" s-lon "'100'" }
        {pk-sub-cod.i "'lon'" "'lndrhar'"  s-lon "'02'"  }

        message 'Ссудный счет открыт: ' s-lon view-as alert-box.

    end. /* transaction */

    s-lgr = '250'.
    find first lgr where lgr.lgr eq s-lgr no-lock no-error.
    find first led where led.led eq lgr.led no-lock no-error.
    find first crc where crc.crc = lgr.crc no-lock no-error.

    if pkanketa.aaa = '' then do:
        run acc_gen(input lgr.gl, 1, v-cifcod, '', false, output s-aaa). /*20-тизначный счет*/

        do transaction:
            find first aaa where aaa.aaa eq s-aaa exclusive-lock.
            aaa.cif  = v-cifcod.
            aaa.name = trim(pkanketa.name).
            aaa.gl   = lgr.gl.
            aaa.lgr  = s-lgr.

            find sysc where sysc.sysc = "branch" no-error.
            if available sysc then aaa.bra = sysc.inval.

            aaa.regdt = g-today.
            aaa.stadt = g-today.
            aaa.stmdt = aaa.regdt - 1.
            aaa.tim   = time .
            aaa.who   = g-ofc.
            aaa.pass  = lgr.type.
            aaa.pri   = lgr.pri.
            aaa.rate  = lgr.rate.
            aaa.complex = lgr.complex.
            aaa.base  = lgr.base.
            aaa.sta   = "N".
            aaa.minbal[1] = 9999999999999.99.
            aaa.crc   = lgr.crc.
            aaa.grp   = integer(lgr.alt).
            aaa.sec   = false.
            find current aaa no-lock.

            message 'Текущий счет открыт: ' s-aaa view-as alert-box.
        end.
        run stnacc(aaa.cif, s-aaa, 0).
        /* счет в ТЕНГЕ открыт */
    end.
    else s-aaa = pkanketa.aaa.
    /* период выписок */

    do transaction:
        find current pkanketa exclusive-lock.
        if pkanketa.aaa = '' then pkanketa.aaa = s-aaa.
        if pkanketa.lon = '' then do:
            pkanketa.lon = s-lon.
            /* Схема ЭК: 1 - дифференцированные платежи, 2 - аннуитет */
            find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = "emetam" no-lock no-error.
            if avail pkanketh then do:
                if pkanketh.value1 = 'дифференцированные платежи' then lon.plan = 1.
                if pkanketh.value1 = 'аннуитет' then lon.plan = 2.
            end.
        end.
        find current pkanketa no-lock.
    end. /* transaction */

    do transaction:
        find current pkanketa exclusive-lock.
        pkanketa.sts = "30".
        find current pkanketa no-lock.
    end. /* transaction */
    release lon.
end.  /* статус < 30 */
else message 'Статус анкеты не соответствует открытию счетов!' view-as alert-box.