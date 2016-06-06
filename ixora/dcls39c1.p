/* dcls39c1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * BASES
        BANK
 * CHANGES
        06/01/2012 evseev - recompile
        06/01/2012 evseev - если не банк то не отрабатывать
        24/04/2012 evseev - если МКО то не отрабатывать
*/


{mainhead.i}
define variable s-jh like jh.jh.
define variable conv_gl like gl.gl.
define variable day_amt like jl.dam.
define variable crc_amt like jl.dam.

define shared var s-target as date.

/*
def var v-templ as char.
def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
   */                                        /*19.04.2005 nataly*/

FUNCTION XLS-NUMBER returns char (num as decimal).
    if num ge 0 then return replace (string (num, "zzzzzzzzzzz9.99"), ".", ",").
                else return "-" + trim (replace (string (absolute(num), "zzzzzzzzzzz9.99"), ".", ",")).
END function.

find first cmp no-lock no-error.
if avail cmp then do:
   /*if cmp.name matches "*МЕТРОКОМБАНК*" then . else return.*/

   if cmp.name matches "*МКО*" then return.
end.


def stream s-file.
output stream s-file to value("dcls39c1_" + string(year(g-today),"9999") + "_" + string(month(g-today),"99") + "_" + string(day(g-today),"99") + ".csv").


find sysc where sysc.sysc eq "SELGL" no-lock no-error.
    if available sysc then conv_gl = sysc.inval.
    else return.

for each glbal where glbal.gl eq conv_gl no-lock:
    find crc where crc.crc eq glbal.crc no-lock.
        if crc.sts eq 9 then next.

    find last crcpro where crcpro.crc = glbal.crc and crcpro.regdt <= s-target no-lock no-error.

    day_amt = day_amt + glbal.bal * crcpro.rate[1].

    for each jl where jl.jdt eq g-today and jl.gl eq glbal.gl and
        jl.crc eq glbal.crc no-lock break by jl.crc:

        crc_amt = crc_amt + jl.dam - jl.cam.
        if last-of (jl.crc) then do:
            day_amt = day_amt + crc_amt * crcpro.rate[1].
            crc_amt = 0.
        end.
    end.
end.

put stream s-file unformatted  "185800;" + XLS-NUMBER(day_amt).

/*
if day_amt eq 0 then return.
v-templ = "dcl0004".
v-param = string(maximum(day_amt,0)) + vdel + string(maximum(- day_amt,0)).

s-jh = 0.
run trxgen (v-templ, vdel, v-param, "dcl" , "" , output rcode,
output rdes, input-output s-jh).

if rcode ne 0 then do:
    message rdes.
    pause .
    undo, return.
end.
*/

output stream s-file close.