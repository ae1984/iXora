/* dcls_after.p
 * MODULE
        Закрытие операционного дня банка
 * DESCRIPTION
        Свертка счетов конвертации
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        27/11/2012 madiyar
 * BASES
        BANK
 * CHANGES
        30/12/2012 madiyar - выключил срабатывание в МКО
		11.02.2013 id00477 добавил разряд в формате вывода
		                   заменил "Корректировка контрстоимости предыдущих периодов" - на "Корректировка контрстоимости текущего периода"
*/

{global.i}
def var v-city as char.
def var v-bal like jl.dam.
def var v-revers as logical.
def var s-jh like jh.jh.
def var v-templ as char.
def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
def var day_amt like jl.dam.
define shared var s-target as date.

def var v-sum1858 as deci no-undo.
def var v-sum1859 as deci no-undo.
def var v-sum2858 as deci no-undo.
def var v-sum2859 as deci no-undo.

find first cmp no-lock no-error.
if (avail cmp) and (cmp.name matches "*МКО*") then return.

for each crc no-lock:
    find last crcpro where crcpro.crc = crc.crc and crcpro.regdt <= s-target no-lock no-error.

    find first gl where gl.gl = 185800 no-lock no-error.
    v-bal = 0.
    find last glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock no-error.
    if avail glbal then v-bal = glbal.bal.
    for each jl where jl.jdt = g-today and jl.gl = glbal.gl and jl.crc = glbal.crc no-lock:
        if substr(trim(string(jl.gl)),1,1) = "1" then do:
            v-bal = v-bal + jl.dam - jl.cam.
        end.
        if substr(trim(string(jl.gl)),1,1) = "2" then do:
            v-bal = v-bal + jl.cam - jl.dam.
        end.
    end.
    if crc.crc = 1 then v-sum1858 = v-sum1858 + v-bal.
    else v-sum1858 = v-sum1858 + v-bal * crcpro.rate[1].

    find first gl where gl.gl = 185900 no-lock no-error.
    v-bal = 0.
    find last glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock no-error.
    if avail glbal then v-bal = glbal.bal.
    for each jl where jl.jdt = g-today and jl.gl = glbal.gl and jl.crc = glbal.crc no-lock:
        if substr(trim(string(jl.gl)),1,1) = "1" then do:
            v-bal = v-bal + jl.dam - jl.cam.
        end.
        if substr(trim(string(jl.gl)),1,1) = "2" then do:
            v-bal = v-bal + jl.cam - jl.dam.
        end.
    end.
    if crc.crc = 1 then v-sum1859 = v-sum1859 + v-bal.
    else v-sum1859 = v-sum1859 + v-bal * crcpro.rate[1].

    find first gl where gl.gl = 285800 no-lock no-error.
    v-bal = 0.
    find last glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock no-error.
    if avail glbal then v-bal = glbal.bal.
    for each jl where jl.jdt = g-today and jl.gl = glbal.gl and jl.crc = glbal.crc no-lock:
        if substr(trim(string(jl.gl)),1,1) = "1" then do:
            v-bal = v-bal + jl.dam - jl.cam.
        end.
        if substr(trim(string(jl.gl)),1,1) = "2" then do:
            v-bal = v-bal + jl.cam - jl.dam.
        end.
    end.
    if crc.crc = 1 then v-sum2858 = v-sum2858 + v-bal.
    else v-sum2858 = v-sum2858 + v-bal * crcpro.rate[1].

    find first gl where gl.gl = 285900 no-lock no-error.
    v-bal = 0.
    find last glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock no-error.
    if avail glbal then v-bal = glbal.bal.
    for each jl where jl.jdt = g-today and jl.gl = glbal.gl and jl.crc = glbal.crc no-lock:
        if substr(trim(string(jl.gl)),1,1) = "1" then do:
            v-bal = v-bal + jl.dam - jl.cam.
        end.
        if substr(trim(string(jl.gl)),1,1) = "2" then do:
            v-bal = v-bal + jl.cam - jl.dam.
        end.
    end.
    if crc.crc = 1 then v-sum2859 = v-sum2859 + v-bal.
    else v-sum2859 = v-sum2859 + v-bal * crcpro.rate[1].

end.

def stream s-file.
output stream s-file to value("dcls_after_" + string(year(g-today),"9999") + "_" + string(month(g-today),"99") + "_" + string(day(g-today),"99") + ".txt").

put stream s-file unformatted
    "v-sum1858=" trim(string(v-sum1858,">>>,>>>,>>>,>>>,>>>,>>9.99-")) skip
    "v-sum1859=" trim(string(v-sum1859,">>>,>>>,>>>,>>>,>>>,>>9.99-")) skip
    "v-sum2858=" trim(string(v-sum2858,">>>,>>>,>>>,>>>,>>>,>>9.99-")) skip
    "v-sum2859=" trim(string(v-sum2859,">>>,>>>,>>>,>>>,>>>,>>9.99-")) skip
    "v-sum1858-v-sum2859=" trim(string(v-sum1858 - v-sum2859,">>>,>>>,>>>,>>>,>>>,>>9.99-")) skip
    "v-sum2858-v-sum1859=" trim(string(v-sum2858 - v-sum1859,">>>,>>>,>>>,>>>,>>>,>>9.99-")) skip.

    if abs(v-sum1858 - v-sum2859) - abs(v-sum2858 - v-sum1859) < 1000 then do:
        if v-sum1858 - v-sum2859 > 0 then v-param = string(v-sum1858 - v-sum2859) + vdel + "1" + vdel + "185900"  + vdel + "285900" + vdel + "Корректировка контрстоимости текущего периода".
        else v-param = string(abs(v-sum1858 - v-sum2859)) + vdel + "1" + vdel + "285900"  + vdel + "185900" + vdel + "Корректировка контрстоимости текущего периода".
        s-jh = 0.
        run trxgen ("dcl0018", vdel, v-param, "dcl", "", output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
        end.
        put stream s-file unformatted "s-jh=" s-jh skip.
    end.


output stream s-file close.