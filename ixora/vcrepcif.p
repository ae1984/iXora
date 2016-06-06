/* vcrepcif.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
     Информация поклиенту и конракту
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM
 * AUTHOR
        20.05.2008 galina
 * CHANGES
        07.04.2011 damir- запись во временную поризводится через формальные переменные
                          добавлены переменные bnkbin,bin,iin в temp-table t-cif
                          v-bnkbin,v-iin,v-bin,v-crc,v-bankokpo,v-address,v-region.
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        03.05.2011. damir - исправлены ошибки.возникшие при компиляции
        06.12.2011 damir - убрал chbin.i, поставил vcmtform.i.
*/


{vc.i}

{vcmtform.i} /*переход на БИН и ИИН*/

def input parameter p-depart   as integer.
def input parameter p-contract like vccontrs.contract.

def var vp-days         as inte.
def var v-name          as char no-undo.
def var v-rnn           as char no-undo.
def var v-okpo          as char no-undo.
def var v-country       as char no-undo.
def var v-partnername   as char no-undo.
def var v-countryben    as char no-undo.
def var v-clntype       as char no-undo.
def var v-expimp        as char no-undo.
def var v-psnum         as char no-undo.
def var v-psdate        as date no-undo.
def var v-bnkbin        as char no-undo.
def var v-bincif        as char no-undo.
def var v-iincif        as char no-undo.
def var v-prefix        as char no-undo.
def var v-crc           as char no-undo.
def var v-bankokpo      as char no-undo.
def var v-address       as char no-undo.
def var v-region        as char no-undo.

def shared temp-table t-cif
    field clcif      like cif.cif
    field clname     like cif.name
    field okpo       as char format "999999999999"
    field rnn        as char format "999999999999"
    field clntype    as char
    field address    as char
    field region     as char
    field psnum      as char
    field psdate     as date
    field bankokpo   as char
    field ctexpimp   as char
    field ctnum      as char
    field ctdate     as date
    field ctsum      as char
    field ctncrc     as char
    field partner    like vcpartners.name
    field countryben as char
    field ctterm     as char
    field cardsend   like vccontrs.cardsend
    field prefix     as char
    field bnkbin     as char
    field bin        as char
    field iin        as char
    index main is primary clcif ctdate ctsum.

for each vccontrs where (vccontrs.contract = p-contract)  no-lock:
    if vccontrs.sts = 'C' then next.
    v-clntype = "".
    v-rnn = "".
    v-okpo = "".
    v-name = "".
    v-expimp = "".
    if vccontrs.expimp = 'e' then v-expimp = "1".
    if vccontrs.expimp = 'i' then v-expimp = "2".
    find cif where cif.cif = vccontrs.cif no-lock no-error.
    if avail cif then do:
        if (p-depart <> 0) and (integer(cif.jame) mod 1000 <> p-depart) then next.

        if v-bin = yes then do:
            if (cif.type = 'B' and cif.cgr <> 403) then do: v-clntype = "1".
                v-rnn = "".
                v-okpo = cif.ssn.
                v-bincif = cif.bin.
            end.
        end.
        else do:
            if (cif.type = 'B' and cif.cgr <> 403) then do: v-clntype = "1".
                v-rnn = "".
                v-okpo = cif.ssn.
            end.
        end.
        if v-bin = yes then do:
            if (cif.type = 'B' and cif.cgr = 403) then do: v-clntype = "2".
                v-rnn = cif.jss.
                v-okpo = "".
                v-iincif = cif.bin.
            end.
        end.
        else do:
            if (cif.type = 'B' and cif.cgr = 403) then do: v-clntype = "2".
                v-rnn = cif.jss.
                v-okpo = "".
            end.
        end.
        v-name = trim(trim(cif.name) + " " + trim(cif.prefix)).
        v-prefix = trim(cif.prefix).
        v-address = cif.addr[2].
    end.

    find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
    if avail sysc then v-bnkbin = sysc.chval.
    else v-bnkbin = "".

    find sub-cod where sub-cod.sub = 'cln' and  sub-cod.acc = vccontrs.cif and sub-cod.d-cod = 'regionkz' no-lock no-error.
    if avail sub-cod then v-region = sub-cod.ccode.
    else v-region = "".
    v-psnum = "".
    v-psdate = ?.
    if vccontrs.cttype = '1' then do:
        find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
        if avail vcps then do:
            v-psnum = vcps.dnnum + string(vcps.num).
            v-psdate = vcps.dndate.
        end.
        else do:
            v-psnum = "".
            v-psdate = ?.
        end.
    end.

    find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
    if avail ncrc then v-crc = ncrc.code.
    else v-crc = "".
    find vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
    v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
    find first cmp no-lock no-error.
    if avail cmp then v-bankokpo = substr(cmp.addr[3], 1, 8).
    else v-bankokpo = "".

    create t-cif.
    assign
    t-cif.clcif = vccontrs.cif
    t-cif.clname = v-name
    t-cif.okpo = v-okpo
    t-cif.rnn = v-rnn
    t-cif.clntype = v-clntype
    t-cif.address = v-address
    t-cif.region = v-region
    t-cif.psnum = v-psnum
    t-cif.psdate = v-psdate
    t-cif.bankokpo = v-bankokpo
    t-cif.ctexpimp = v-expimp
    t-cif.ctnum = vccontrs.ctnum
    t-cif.ctdate = vccontrs.ctdate
    t-cif.ctsum = trim(string((vccontrs.ctsum / 1000), ">>>>>>>>>>>>>>9.99"))
    t-cif.ctncrc = v-crc
    t-cif.partner = v-partnername
    t-cif.countryben = vcpartner.country
    t-cif.ctterm = vccontrs.ctterm
    t-cif.cardsend = vccontrs.cardsend
    t-cif.prefix = v-prefix.
    if v-bin = yes then do:
        t-cif.bnkbin = v-bnkbin.
        t-cif.bin    = v-bincif.
        t-cif.iin    = v-iincif.
    end.
end.

