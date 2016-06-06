/* r-PL2.p
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
        18.04.2013 dmitriy
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def shared var dt1 as date.

define shared temp-table repPL no-undo
    field br as int
    field dt as date
    field gl as int
    field gl4 as char
    field crc as int
    field bal as deci
    field tot as logi
    field totlev as int
    field totgl as int.

/*define shared temp-table tgl no-undo
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field acc-ddt as date
    field geo as character
    field dt as date
    index tgl-id1 is primary gl7.*/

def shared temp-table wrk-scu
    field scu as char
    field ref as char
    field isin as char
    field s4510 as deci
    field s5510 as deci
    field razn1 as deci
    field s4709 as deci
    field s5709 as deci
    field razn2 as deci
    field s4733 as deci
    field s5733 as deci
    field razn3 as deci
    field s4201 as deci
    field razn4 as deci
    index scu is primary scu.

def var v-cb as char.
def var v4510 as deci.
def var v5510 as deci.
def var v4709 as deci.
def var v5709 as deci.
def var v4733 as deci.
def var v5733 as deci.
def var v4201 as deci.

def var day-sum as deci.
def var br-code as int.
def var v-gl4 as char.

find first txb.cmp no-lock no-error.
if avail txb.cmp then br-code = txb.cmp.code.

message "Сбор данных : " + txb.cmp.name.

/*define variable s-ourbank as character no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not available txb.sysc or txb.sysc.chval = "" then
do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(txb.sysc.chval).*/

def var dt as date.

/*run r-PL3(dt1 - 7).
run r-PL3(dt1).*/

run CreatePL(dt1 - 7).
run CreatePL(dt1).

/*run CreateWrkSCU (dt1 - 7).*/
run CreateWrkSCU (dt1).


procedure CreateWrkSCU:
    def input parameter p-dt as date.

    for each txb.scu /*where txb.scu.scu = txb.trxbal.acc*/ no-lock:

        find first txb.dealref where txb.dealref.nin = txb.scu.ref no-lock no-error.
        if avail txb.dealref then v-cb = txb.dealref.cb.

        v4510 = 0. v5510 = 0. v4709 = 0. v5709 = 0. v4733 = 0. v5733 = 0. v4201 = 0.

        find last txb.trxlevgl where txb.trxlevgl.gl = txb.scu.gl and string(txb.trxlevgl.glr) begins "4510"  no-lock no-error.
        if avail txb.trxlevgl then do:
            find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt
                    and txb.histrxbal.sub = 'scu'
                    and txb.histrxbal.acc = txb.scu.scu
                    and txb.histrxbal.crc = 1 /*scu.crc*/
                    and txb.histrxbal.lev = txb.trxlevgl.lev
            no-lock no-error.
            if avail txb.histrxbal then v4510 = txb.histrxbal.cam - txb.histrxbal.dam.
        end.

        find last txb.trxlevgl where txb.trxlevgl.gl = txb.scu.gl and string(txb.trxlevgl.glr) begins "5510"  no-lock no-error.
        if avail txb.trxlevgl then do:
            find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt
                    and txb.histrxbal.sub = 'scu'
                    and txb.histrxbal.acc = txb.scu.scu
                    and txb.histrxbal.crc = 1 /*scu.crc*/
                    and txb.histrxbal.lev = txb.trxlevgl.lev
            no-lock no-error.
            if avail txb.histrxbal then v5510 = txb.histrxbal.cam - txb.histrxbal.dam.
        end.

        find last txb.trxlevgl where txb.trxlevgl.gl = txb.scu.gl and string(txb.trxlevgl.glr) begins "4709"  no-lock no-error.
        if avail txb.trxlevgl then do:
            find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt
                    and txb.histrxbal.sub = 'scu'
                    and txb.histrxbal.acc = txb.scu.scu
                    and txb.histrxbal.crc = 1 /*scu.crc*/
                    and txb.histrxbal.lev = 21 /*txb.trxlevgl.lev*/
            no-lock no-error.
            if avail txb.histrxbal then v4709 = txb.histrxbal.cam - txb.histrxbal.dam.
        end.

        find last txb.trxlevgl where txb.trxlevgl.gl = txb.scu.gl and string(txb.trxlevgl.glr) begins "5709"  no-lock no-error.
        if avail txb.trxlevgl then do:
            find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt
                    and txb.histrxbal.sub = 'scu'
                    and txb.histrxbal.acc = txb.scu.scu
                    and txb.histrxbal.crc = 1 /*scu.crc*/
                    and txb.histrxbal.lev = 22 /*txb.trxlevgl.lev*/
            no-lock no-error.
            if avail txb.histrxbal then v5709 = txb.histrxbal.cam - txb.histrxbal.dam.
        end.

        find last txb.trxlevgl where txb.trxlevgl.gl = txb.scu.gl and string(txb.trxlevgl.glr) begins "4733"  no-lock no-error.
        if avail txb.trxlevgl then do:
            find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt
                    and txb.histrxbal.sub = 'scu'
                    and txb.histrxbal.acc = txb.scu.scu
                    and txb.histrxbal.crc = 1 /*scu.crc*/
                    and txb.histrxbal.lev = txb.trxlevgl.lev
            no-lock no-error.
            if avail txb.histrxbal then v4733 = txb.histrxbal.cam - txb.histrxbal.dam.
        end.

        find last txb.trxlevgl where txb.trxlevgl.gl = txb.scu.gl and string(txb.trxlevgl.glr) begins "5733"  no-lock no-error.
        if avail txb.trxlevgl then do:
            find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt
                    and txb.histrxbal.sub = 'scu'
                    and txb.histrxbal.acc = txb.scu.scu
                    and txb.histrxbal.crc = 1 /*scu.crc*/
                    and txb.histrxbal.lev = txb.trxlevgl.lev
            no-lock no-error.
            if avail txb.histrxbal then v5733 = txb.histrxbal.cam - txb.histrxbal.dam.
        end.

/*        find first txb.trxlevgl where txb.trxlevgl.gl = txb.scu.gl and string(txb.trxlevgl.glr) begins "4201"  no-lock no-error.
        if avail txb.trxlevgl then do:
            find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt
                    and txb.histrxbal.sub = 'scu'
                    and txb.histrxbal.acc = txb.scu.scu
                    and txb.histrxbal.crc = 1
                    and txb.histrxbal.lev = 11
            no-lock no-error.
            if avail txb.histrxbal then v4201 = txb.histrxbal.cam - txb.histrxbal.dam.
        end. */

        /*find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt
                and txb.histrxbal.sub = 'scu'
                and txb.histrxbal.acc = txb.scu.scu
                and txb.histrxbal.crc = 1
                and txb.histrxbal.lev = 11
        no-lock no-error.
        if avail txb.histrxbal then v4201 = txb.histrxbal.cam - txb.histrxbal.dam.

        find last txb.histrxbal where txb.histrxbal.dt      <=  p-dt  and txb.histrxbal.dt > date(1,1,year(p-dt))
                and txb.histrxbal.sub = 'scu'
                and txb.histrxbal.acc = txb.scu.scu
                and txb.histrxbal.crc = 1
                and txb.histrxbal.lev = 12
        no-lock no-error.
        if avail txb.histrxbal then v4201 = v4201 + txb.histrxbal.cam - txb.histrxbal.dam.*/

        for each txb.jl where
            txb.jl.jdt > date(12,31,year(p-dt) - 1)
            and txb.jl.jdt <= p-dt
            and (txb.jl.gl = 420110 or txb.jl.gl = 420120)
            and txb.jl.sub = 'scu'
            and txb.jl.acc = scu.scu
        no-lock:
            v4201 = v4201 + (txb.jl.cam - txb.jl.dam).
        end.


        do transaction:
            create wrk-scu.
            wrk-scu.scu = txb.scu.scu.
            wrk-scu.ref = v-cb.
            wrk-scu.isin = txb.scu.ref.
            wrk-scu.s4510 = v4510.
            wrk-scu.s5510 = v5510.
            wrk-scu.razn1 = wrk-scu.s4510 + wrk-scu.s5510.
            wrk-scu.s4709 = v4709.
            wrk-scu.s5709 = v5709.
            wrk-scu.razn2 = wrk-scu.s4709 + wrk-scu.s5709.
            wrk-scu.s4733 = v4733.
            wrk-scu.s5733 = v5733.
            wrk-scu.razn3 = wrk-scu.s4733 + wrk-scu.s5733.
            wrk-scu.s4201 = v4201.
            wrk-scu.razn4 = wrk-scu.razn1 + wrk-scu.razn2 + wrk-scu.razn3 + wrk-scu.s4201.
        end.
    end.
end procedure.

procedure CreatePL:
    def input parameter p-dt as date.

    for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and txb.gl.gl >= 400000 and txb.gl.gl < 600000 no-lock break by txb.gl.gl:
        if txb.gl.gl <> 599980 then do:
            v-gl4 = substr(string(txb.gl.gl), 1, 4).
            for each txb.crc no-lock:
                find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.gdt <= p-dt and txb.glday.crc = txb.crc.crc no-lock no-error.
                if avail txb.glday then do:
                    day-sum = 0.
                    find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.rdt <= dt no-lock no-error.
                    if avail txb.crchis then day-sum = txb.glday.bal * txb.crchis.rate[1].

                    do transaction:
                        create repPL.

                        repPL.br = br-code.
                        repPL.dt = p-dt.
                        repPL.gl = txb.gl.gl.
                        repPL.gl4 = v-gl4.
                        repPL.crc = txb.glday.crc.
                        repPL.bal = day-sum.
                        repPL.tot = txb.gl.totact.
                        repPL.totlev = txb.gl.totlev.
                        repPL.totgl = txb.gl.totgl.
                    end.
                end.
            end.
        end.
    end.

end procedure.

message "". pause 0.