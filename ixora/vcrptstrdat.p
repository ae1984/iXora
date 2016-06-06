/* vcrptstrdat.p
 * MODULE
        Название модуля - сбор информации  о контрактах и ПС.
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
        Пункт меню - 9-3-18
 * AUTHOR
        02/03/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        08.09.2011 damir - cvs add.
*/

{vc.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.
def input parameter p-dtb as date.
def input parameter p-dte as date.
def input parameter p-sts as char .
def input parameter p-type as char.

def shared temp-table t-cif
    field cif like txb.cif.cif
    field bank      as char
    field name      as char
    field contract  as char
    field data      as date
    field cttype    as char
    field v-amt     as decimal init 2
    field crc like txb.ncrc.crc
    field name-ino  as char
    field rekv-ino  as char
    field strana    as char
    field tovar     as char
    field expimp    as char
    field sts       as char
    field psnum     as char
    field psnumnum  as integer
    field vcrslc    as char
    index main is primary name cif data contract.

def var v-depart as integer.
def var v-sts1 as char.
def var v-type1 as char.
def var v-val as char.

v-sts1 = p-sts.
v-type1 = p-type.

for each vccontrs where (vccontrs.bank = p-vcbank) and (vccontrs.rdt >= p-dtb and vccontrs.rdt <= p-dte) and lookup(vccontrs.sts,v-sts1) > 0
and lookup(vccontrs.cttype, v-type1) > 0 use-index main no-lock break by vccontrs.cif:
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do:
        v-depart = integer(txb.cif.jame) mod 1000.
        if p-depart <> 0 and v-depart <> p-depart then next.
        create t-cif.
        assign
        t-cif.cif = txb.cif.cif
        t-cif.name = trim(trim(txb.cif.sname) + " " + trim(txb.cif.prefix))
        t-cif.contract = vccontrs.ctnum
        t-cif.data = vccontrs.ctdate
        t-cif.cttype = vccontrs.cttype
        t-cif.v-amt = vccontrs.ctsum
        t-cif.crc = vccontrs.ncrc.
        find first txb.codfr where txb.codfr.codfr = 'iso3166' no-lock no-error.
        if avail txb.codfr then do:
            t-cif.strana = txb.codfr.name[1].
        end.
        else t-cif.strana = "".
        find first txb.codfr where txb.codfr.codfr = 'vccontr' no-lock no-error.
        if avail txb.codfr then do:
            t-cif.tovar = txb.codfr.name[1].
        end.
        else t-cif.tovar = "".
        assign
        t-cif.expimp = vccontrs.expimp
        t-cif.sts = vccontrs.sts .
        find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
        if avail vcps then do:
             t-cif.psnum = vcps.dnnum + string(vcps.num).
        end.
        find first vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.dntype = "21" or vcrslc.dntype = "64") no-lock no-error.
        if avail vcrslc then do:
            t-cif.vcrslc = vcrslc.dnnum.
        end.
        else do:
            t-cif.vcrslc = "".
        end.
    end.
end.