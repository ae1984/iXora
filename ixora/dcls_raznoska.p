/* dcls_raznoska.p
 * MODULE
        Закрытие дня
 * DESCRIPTION
        Разноска остатков 1858 на 1859, 2858, 2859
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
        27/11/2012 madiyar
 * BASES
        BANK
 * CHANGES
        11/02/2013 madiyar - исключаем входящие обороты
*/

{global.i}
def var s-jh like jh.jh.
def var v-templ as char.
def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
def var v-sumd as deci no-undo.
def var v-sumc as deci no-undo.

find first cmp no-lock no-error.
if avail cmp and cmp.name matches "*МКО*" then return.

def stream s-file.
output stream s-file to value("dcls_raznoska_" + string(year(g-today),"9999") + "_" + string(month(g-today),"99") + "_" + string(day(g-today),"99") + ".txt").

for each crc no-lock:
    v-sumd = 0.
    v-sumc = 0.

    /*
    find last glbal where glbal.gl = 185800 and glbal.crc = crc.crc no-lock no-error.
    if avail glbal then do:
        v-sumd = glbal.dam.
        v-sumc = glbal.cam.
    end.
    */

    for each jl where jl.jdt = g-today and jl.gl = 185800 and jl.crc = crc.crc no-lock:
        v-sumd = v-sumd + jl.dam.
        v-sumc = v-sumc + jl.cam.
    end.

    if crc.crc = 1 then do:
        if v-sumd <> 0 then do:
            if v-sumd > 0 then do:
                 v-param = string(v-sumd) + vdel + string(crc.crc) + vdel + "185900"  + vdel + "185800" + vdel + "Перенос дебетового остатка в KZT 185800->185900".
                 s-jh = 0.
                 run trxgen ("dcl0018", vdel, v-param, "dcl", "", output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then do:
                     put stream s-file unformatted "Error! side=D crc=" + string(crc.crc) + "; amt=" + string(v-sumd) + " (Dt 185900 Ct 185800); rdes=" + rdes skip.
                     message rdes.
                     pause.
                 end.
                 else put stream s-file unformatted "side=D crc=" + string(crc.crc) + "; amt=" + string(v-sumd) + " (Dt 185900 Ct 185800); jh=" + string(s-jh) skip.
            end.
            else do:
                v-param = string(abs(v-sumd)) + vdel + string(crc.crc) + vdel + "185800"  + vdel + "285900" + vdel + "Перенос отриц. дебетового остатка в KZT 185800->285900".
                 s-jh = 0.
                 run trxgen ("dcl0018", vdel, v-param, "dcl", "", output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then do:
                     put stream s-file unformatted "Error! side=D crc=" + string(crc.crc) + "; amt=" + string(v-sumd) + " (Dt 185800 Ct 285900); rdes=" + rdes skip.
                     message rdes.
                     pause.
                 end.
                 else put stream s-file unformatted "side=D crc=" + string(crc.crc) + "; amt=" + string(v-sumd) + " (Dt 185800 Ct 285900); jh=" + string(s-jh) skip.
            end.
        end.
        if v-sumc <> 0 then do:
            if v-sumc > 0 then do:
                 v-param = string(v-sumc) + vdel + string(crc.crc) + vdel + "185800"  + vdel + "285900" + vdel + "Перенос кредитового остатка в KZT 185800->285900".
                 s-jh = 0.
                 run trxgen ("dcl0018", vdel, v-param, "dcl", "", output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then do:
                     put stream s-file unformatted "Error! side=C crc=" + string(crc.crc) + "; amt=" + string(v-sumc) + " (Dt 185800 Ct 285900); rdes=" + rdes skip.
                     message rdes.
                     pause.
                 end.
                 else put stream s-file unformatted "side=C crc=" + string(crc.crc) + "; amt=" + string(v-sumc) + " (Dt 185800 Ct 285900); jh=" + string(s-jh) skip.
            end.
            else do:
                 v-param = string(abs(v-sumc)) + vdel + string(crc.crc) + vdel + "185900"  + vdel + "185800" + vdel + "Перенос отриц. кредитового остатка в KZT 185800->185900".
                 s-jh = 0.
                 run trxgen ("dcl0018", vdel, v-param, "dcl", "", output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then do:
                     put stream s-file unformatted "Error! side=C crc=" + string(crc.crc) + "; amt=" + string(v-sumc) + " (Dt 185900 Ct 185800); rdes=" + rdes skip.
                     message rdes.
                     pause.
                 end.
                 else put stream s-file unformatted "side=C crc=" + string(crc.crc) + "; amt=" + string(v-sumc) + " (Dt 185900 Ct 185800); jh=" + string(s-jh) skip.
            end.
        end.
    end.
    else do:
        if v-sumd <> 0 then do:
            if v-sumd > 0 then do:
                 /* do nothing */
            end.
            else do:
                 v-param = string(abs(v-sumd)) + vdel + string(crc.crc) + vdel + "185800"  + vdel + "285800" + vdel + "Перенос отриц. дебетового остатка в валюте 185800->285800".
                 s-jh = 0.
                 run trxgen ("dcl0018", vdel, v-param, "dcl", "", output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then do:
                     put stream s-file unformatted "Error! side=D crc=" + string(crc.crc) + "; amt=" + string(v-sumd) + " (Dt 185800 Ct 285800); rdes=" + rdes skip.
                     message rdes.
                     pause.
                 end.
                 else put stream s-file unformatted "side=D crc=" + string(crc.crc) + "; amt=" + string(v-sumd) + " (Dt 185800 Ct 285800); jh=" + string(s-jh) skip.
            end.
        end.
        if v-sumc <> 0 then do:
            if v-sumc > 0 then do:
                 v-param = string(v-sumc) + vdel + string(crc.crc) + vdel + "185800"  + vdel + "285800" + vdel + "Перенос кредитового остатка в валюте 185800->285800".
                 s-jh = 0.
                 run trxgen ("dcl0018", vdel, v-param, "dcl", "", output rcode, output rdes, input-output s-jh).
                 if rcode ne 0 then do:
                     put stream s-file unformatted "Error! side=C crc=" + string(crc.crc) + "; amt=" + string(v-sumc) + " (Dt 185800 Ct 285800); rdes=" + rdes skip.
                     message rdes.
                     pause.
                 end.
                 else put stream s-file unformatted "side=C crc=" + string(crc.crc) + "; amt=" + string(v-sumc) + " (Dt 185800 Ct 285800); jh=" + string(s-jh) skip.
            end.
            else do:
                 /* do nothing */
            end.
        end.
    end.

end.

output stream s-file close.

