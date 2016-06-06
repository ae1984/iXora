/* sprnb1.p
 * MODULE
        ___Ю ФЁR-ЁАБ
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * CONNECT
        bank, comm, (_____<_-__ __" TXB->bank)
 * AUTHOR
        13.09.2005 dpuchkov
 * CHANGES
        13/12/2011 evseev - ТЗ-625. Переход на ИИН/БИН
*/


def shared var vtmen    as char.
def shared var i-tmpidx as integer .
def        var v-clsd   as integer .
def shared temp-table t2
    field number  as integer
    field number2 as integer
    field jss     like txb.cif.jss
    field bin     like txb.cif.bin
    field name    like txb.cif.name
    field cif     like txb.cif.cif
    field prefix  like txb.cif.prefix
    field closed  as char.

def shared temp-table t-fnd
    field number   as integer
    field name     like txb.cif.name
    field fullname like txb.cif.name
    field jss      like txb.cif.jss
    field bin      like txb.cif.bin
    field fnd      as logical init false.

for each t-fnd:
    if t-fnd.bin <> "" and not t-fnd.fnd then
    do:
        find last txb.cif where txb.cif.bin = t-fnd.bin no-lock no-error.
        if avail txb.cif then
        do:
            i-tmpidx = 0.
            v-clsd = 0.
            for each txb.aaa where txb.aaa.cif = txb.cif.cif /*and txb.aaa.sta <> "C" and txb.aaa.sta <> "E" */  no-lock:
                find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
                if txb.lgr.led = 'ODA' then next.
                i-tmpidx = i-tmpidx + 1.
                if txb.aaa.sta = "C" or txb.aaa.sta = "E" then v-clsd = 1.
            end.
            if i-tmpidx > 0 then
            do:
                create t2.
                t2.number = t-fnd.number.
                t2.name   = txb.cif.name.
                t2.jss    = txb.cif.jss.
                t2.bin    = txb.cif.bin.
                t2.prefix = txb.cif.prefix.
                t2.cif = txb.cif.cif.
                if v-clsd = 1 then  t2.closed = "C".
                t-fnd.fnd = True.
            end.
        end.
    end.


    if t-fnd.jss <> "" and not t-fnd.fnd then
    do:
        find last txb.cif where txb.cif.jss = t-fnd.jss no-lock no-error.
        if avail txb.cif then
        do:
            i-tmpidx = 0.
            v-clsd = 0.
            for each txb.aaa where txb.aaa.cif = txb.cif.cif /*and txb.aaa.sta <> "C" and txb.aaa.sta <> "E" */  no-lock:
                find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
                if txb.lgr.led = 'ODA' then next.
                i-tmpidx = i-tmpidx + 1.
                if txb.aaa.sta = "C" or txb.aaa.sta = "E" then v-clsd = 1.
            end.
            if i-tmpidx > 0 then
            do:
                create t2.
                t2.number = t-fnd.number.
                t2.name   = txb.cif.name.
                t2.jss    = txb.cif.jss.
                t2.bin    = txb.cif.bin.
                t2.prefix = txb.cif.prefix.
                t2.cif = txb.cif.cif.
                if v-clsd = 1 then  t2.closed = "C".
                t-fnd.fnd = True.
            end.
        end.
    end.

    if t-fnd.name <> "" /*and not t-fnd.fnd */ then
    do:
        vtmen = "*" + trim(t-fnd.name) + "*".
        vtmen = replace (vtmen, "**", "*").
        for each txb.cif where txb.cif.name matches vtmen no-lock:
            i-tmpidx = 0.
            v-clsd = 0.
            for each txb.aaa where txb.aaa.cif = txb.cif.cif /*and txb.aaa.sta <> "C"  and txb.aaa.sta <> "E" */  no-lock:
                find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
                if txb.lgr.led = 'ODA' then next.
                i-tmpidx = i-tmpidx + 1.
                if txb.aaa.sta = "C" or txb.aaa.sta = "E" then v-clsd = 1.
            end.
            if i-tmpidx > 0 then
            do:
                create t2.
                t2.number = t-fnd.number.
                t2.name   = txb.cif.name.
                t2.jss    = txb.cif.jss.
                t2.bin    = txb.cif.bin.
                t2.prefix = txb.cif.prefix.
                t2.cif    = txb.cif.cif.
                if v-clsd = 1 then  t2.closed = "C".
                t-fnd.fnd = True.
            end.
        end.
    end.
end.
