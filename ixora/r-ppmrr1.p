/* r-ppmrr1.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет "Расчет для ППМРР"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.22
 * AUTHOR
        29/02/2012 dmitriy
 * BASES
        BANK COMM TXB
 * CHANGES
*/


def shared var dat1 as date format '99/99/9999'.

def shared temp-table wrk
    field gl as int
    field grp as int
    field bal as deci
    field plus as char
    index idx gl.

def shared temp-table wrk-gl
    field gl like txb.gl.gl
    field grp as int
    field plus as char
    index gl gl.

def var v-bal as deci.

for each wrk-gl no-lock:
    v-bal = 0.

    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = wrk-gl.gl and txb.glday.gdt <= dat1 and txb.glday.crc = txb.crc.crc no-lock no-error.
        if avail txb.glday and txb.glday.bal <> 0 then do:

            v-bal = txb.glday.bal.

            if txb.crc.crc <> 1 then do:
                find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= dat1 no-lock no-error.
                if avail txb.crchis then v-bal = v-bal * txb.crchis.rate[1].
            end.

            create wrk.
            wrk.gl = wrk-gl.gl.
            wrk.bal = v-bal.
            wrk.grp = wrk-gl.grp.
            wrk.plus = wrk-gl.plus.
        end.
    end.
end.

