/* r-riskline2.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет о средних остатках за месяц по счетам ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.21
 * AUTHOR
        02.04.2013 dmitriy. ТЗ 1690
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def shared var dt as date.

def shared temp-table wrk-gl no-undo
    field br  as char
    field dt  as date
    field gl  as int
    field gl4 as char
    field bal as deci
    field crc as int
    field skv as int
    field tot as logi
    field totlev as int
    field totgl as int
    field des as char
    field include as logi init no
    index gl4 gl4.

def shared temp-table wrk2 no-undo
    field id as int
    field nom as int
    field name as char
    field income as deci
    field inc-gl as char
    field expense as deci
    field exp-gl as char
    field bal as deci
    field risksum as deci.

def var i  as int.
def var j  as int.
def var day-sum as deci.
def var br-code as int.
def var v-gl4 as char.
def var v-inc as logi.
def buffer b-gl for txb.gl.
def var v-skv as int.
def var sum1 as deci.
def var sum2 as deci.
def var sum3 as deci.
def var sum4 as deci.

find first txb.cmp no-lock no-error.
if avail txb.cmp then br-code = txb.cmp.code.

message "Сбор данных : " + txb.cmp.name.


for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and txb.gl.gl >= 400000 and txb.gl.gl < 600000 no-lock break by txb.gl.gl:
    if txb.gl.gl <> 599980 then do:
    v-gl4 = substr(string(txb.gl.gl), 1, 4).
    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.gdt <= dt and txb.glday.crc = txb.crc.crc no-lock no-error.
        if avail txb.glday then do:
            find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.rdt <= dt no-lock no-error.
            if avail txb.crchis then day-sum = txb.glday.bal * txb.crchis.rate[1].

            if txb.crc.crc = 1 then v-skv = 1.
            else if txb.crc.crc <> 1 and txb.crc.crc <> 4 and txb.crc.crc <> 5 then v-skv = 3.
            else v-skv = 2.

            find first comm.txb where comm.txb.city = br-code no-lock no-error.

            create wrk-gl.
            wrk-gl.br = comm.txb.info.
            wrk-gl.dt = dt.
            wrk-gl.gl = txb.gl.gl.
            wrk-gl.des = txb.gl.des.
            wrk-gl.gl4 = v-gl4.
            wrk-gl.crc = txb.glday.crc.
            wrk-gl.skv = v-skv.
            wrk-gl.bal = day-sum.
            wrk-gl.tot = txb.gl.totact.
            wrk-gl.totlev = txb.gl.totlev.
            wrk-gl.totgl = txb.gl.totgl.

            day-sum = 0.
        end.
    end.
    end.
end.

for each wrk2 where wrk2.nom = 2 no-lock:
    sum1 = 0. sum2 = 0. sum3 = 0. sum4 = 0.

    for each txb.jh no-lock :
        if index(txb.jh.party,"STORNED") > 0 or index(txb.jh.party,"STORNO") > 0 then next.

            for each txb.jl where txb.jl.jh = txb.jh.jh and lookup(substr(string(txb.jl.gl),1,4), wrk2.inc-gl) > 0 no-lock:

                find first txb.gl where txb.gl.gl = txb.jl.gl and txb.gl.totlev = 1 and gl.totgl <> 0 no-lock no-error.
                if not avail txb.gl then next.

                if txb.jl.sub = "lon" then do:
                    find first txb.lon where txb.lon.lon = txb.jl.acc no-lock no-error.
                    if avail txb.lon then do:
                        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                        if avail txb.sub-cod and txb.sub-cod.ccode <> "9" then do:
                            sum1 = sum1 + txb.jl.cam - txb.jl.dam.
                        end.
                    end.
                end.
                sum2 = sum2 + txb.jl.cam - txb.jl.dam.
            end.

            for each txb.jl where txb.jl.jh = txb.jh.jh and lookup(substr(string(txb.jl.gl),1,4), wrk2.exp-gl) > 0 no-lock:
                find first txb.gl where txb.gl.gl = txb.jl.gl and txb.gl.totlev = 1 and gl.totgl <> 0 no-lock no-error.
                if not avail txb.gl then next.

                if txb.jl.sub = "lon" then do:
                    find first txb.lon where txb.lon.lon = txb.jl.acc no-lock no-error.
                    if avail txb.lon then do:
                        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                        if avail txb.sub-cod and txb.sub-cod.ccode <> "9" then do:
                            sum3 = sum3 + txb.jl.dam - txb.jl.cam.
                        end.
                    end.
                end.
                sum4 = sum4 + txb.jl.dam - txb.jl.cam.
            end.

    end.

    do transaction:
        wrk2.income = sum2 - sum1.
        wrk2.expense = sum4 - sum3.
        wrk2.bal = (sum2 - sum1) - (sum4 - sum3).
        wrk2.risksum = ((sum2 - sum1) - (sum4 - sum3)) * 0.12 .
    end.
end.


message "". pause 0.
