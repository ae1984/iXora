/* vcrepcif115.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
      Информация поклиенту
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM
 * AUTHOR
        23.05.2008 galina
 * CHANGES
        26.02.2009 galina - адрес клиента берем из addr[1] + addr[2]
        07.04.2011 damir- запись во временную поризводится через формальные переменные
                          добавлены переменные bnkbin,bin,iin в temp-table t-cif115
                          v-bnkbin,v-iin,v-bin,v-crc,v-bankokpo,v-region.
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        03.05.2011. damir - исправлены ошибки.возникшие при компиляции
        04.05.2011  damir - исправлены ошибки.возникшие при компиляции
        06.12.2011 damir - убрал chbin.i, добавил vcmtform.i
*/


{vc.i}

{vcmtform.i} /*переход на БИН и ИИН*/

def input parameter p-depart as integer.
def input parameter p-cif    as char.

def var v-name      as char no-undo.
def var v-rnn       as char no-undo.
def var v-okpo      as char no-undo.
def var v-clntype   as char no-undo.
def var v-address   as char no-undo.
def var v-region    as char no-undo.
def var v-bankokpo  as char no-undo.
def var v-bnkbin    as char no-undo.
def var v-bincif    as char no-undo.
def var v-iincif    as char no-undo.

def shared temp-table t-cif115
    field clcif     like cif.cif
    field clname    like cif.name
    field okpo      as char format "999999999999"
    field rnn       as char format "999999999999"
    field clntype   as char
    field address   as char
    field region    as char
    field bankokpo  as char
    field bnkbin    as char
    field bin       as char
    field iin       as char.

for each cif where (cif.cif = p-cif)  no-lock:
    assign v-clntype = "" v-rnn = "" v-okpo = "" v-name = "".
    if (p-depart <> 0) and (integer(cif.jame) mod 1000 <> p-depart) then next.

    v-name = trim(trim(cif.name) + " " + trim(cif.prefix)).
    if v-bin = yes then do:
        if (cif.type = 'B' and cif.cgr <> 403) then do:
            assign
            v-clntype = "1"
            v-rnn     = ""
            v-okpo    = cif.ssn
            v-bincif  = cif.bin.
        end.
        if (cif.type = 'B' and cif.cgr = 403) then do:
            assign
            v-clntype = "2"
            v-rnn     = cif.jss
            v-okpo    = ""
            v-iincif  = cif.bin.
        end.
    end.
    else do:
        if (cif.type = 'B' and cif.cgr <> 403) then do:
            assign
            v-clntype = "1"
            v-rnn     = ""
            v-okpo    = cif.ssn.
        end.
        if (cif.type = 'B' and cif.cgr = 403) then do:
            assign
            v-clntype = "2"
            v-rnn     = cif.jss
            v-okpo    = "".
        end.
    end.
    v-address = cif.addr[1] + ' ' + cif.addr[2].

    find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
    if avail sysc then v-bnkbin = sysc.chval.
    else v-bnkbin = "".

    find sub-cod where sub-cod.sub = 'cln' and  sub-cod.acc = cif.cif and sub-cod.d-cod = 'regionkz' no-lock no-error.
    if avail sub-cod then v-region = sub-cod.ccode.
    else v-region = "".

    find first cmp no-lock no-error.
    if avail cmp then v-bankokpo = substr(cmp.addr[3], 1, 8).
    else v-bankokpo = "".

    create t-cif115.
    assign
    t-cif115.clname = v-name
    t-cif115.okpo = v-okpo
    t-cif115.rnn = v-rnn
    t-cif115.clntype = v-clntype
    t-cif115.address = v-address
    t-cif115.region = v-region
    t-cif115.bankokpo = v-bankokpo.
    if v-bin = yes then do:
        assign
        t-cif115.bnkbin = v-bnkbin
        t-cif115.bin    = v-bincif
        t-cif115.iin    = v-iincif.
    end.
end.

