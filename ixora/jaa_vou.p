/* jaa_vou.p
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
 * CHANGES
        21.04.10 marinav - добавилось третье поле примечания
        23.08.2012 evseev - иин/бин
*/

/** jaa_vou.p
    KASE -- KASE (klienta voucher ) **/


{mainhead.i}
{chbin.i}

define shared variable v_doc   like joudoc.docnum.

define variable vcha1   as character format "x(65)".
define variable v-point as integer.
define variable intot   as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99".
define variable outtot  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99".


find first cmp.
vcha1 = " " + cmp.name.
find joudoc where joudoc.docnum = v_doc no-lock.
find ofc where ofc.ofc = joudoc.who no-lock.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.
find jh where jh.jh eq joudoc.jh no-lock.

def var bascrc like crc.code.
find crc where crc.crc eq 1 no-lock.
bascrc = crc.code.

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then v-bankbin = sysc.chval. else v-bankbin = cmp.addr[2].

output to stmt.img.



put space(25) "ОРДЕР ОБМЕНА ВАЛЮТЫ" skip.
put
"============================================================================="
    skip
    cmp.name space(23)
    joudoc.whn format "99/99/9999" " " string(time,"HH:MM") skip
    "БИН" + v-bankbin + "," + cmp.addr[3] format "x(60)" skip.
put point.name skip.
put point.addr[1] skip.
put string (joudoc.jh) + "/" + joudoc.docnum + "/" + "Док.Nr." + joudoc.num +
    "   /" + ofc.name + "/" + ofc.ofc format "x(78)" skip.


put
"============================================================================="
    skip.


define variable obmenGL2 as integer.
find sysc where sysc.sysc = "904kas" no-lock.
if avail sysc then obmenGL2 = sysc.inval. else obmenGL2 = 100200.

find sysc where sysc.sysc = "CASHGL" no-lock.

intot = 0.
outtot = 0.


for each jl where jl.jh eq joudoc.jh and (jl.gl = sysc.inval or (jl.gl = obmenGL2 and (substring(jl.rem[1],1,5) = 'Обмен')))
    use-index jhln no-lock break by jl.crc:

    /* iemaksa */
    if jl.dam gt 0 then intot = intot + jl.dam.
    /* izmaksa */
    else outtot = outtot + jl.cam.

    if last-of (jl.crc) then do:
        find crc where crc.crc eq jl.crc no-lock.

        /** iemaksa **/
/*
        if intot ne 0 then do:
            put "ВЗНОС   " + crc.des format "x(28)".
            put " (курс  " +
                string (crc.rate[2], "999.9999") + bascrc + "/ " +
                string (crc.rate[9], "zzzzzzz") + " " + crc.code + " " +
                string (intot, "zzz,zzz,zzz,zz9.99")
                format "x(60)" skip(1).
        end.
*/
        if intot ne 0 then do:
            put "ВЗНОС   " + crc.des format "x(28)".
            put " (курс  " +
                string (joudoc.brate, "999.9999") + bascrc + "/ " +
                string (crc.rate[9], "zzzzzzz") + " " + crc.code + " " +
                string (intot, "zzz,zzz,zzz,zz9.99")
                format "x(60)" skip(1).
        end.
        /** izmaksa **/
        if outtot ne 0 then do:
            put "ВЫПЛАТА " + crc.des format "x(28)".
/*
            put " (курс  " +
                string (crc.rate[3], "999.9999") + bascrc + "/ " +
                string (crc.rate[9], "zzzzzzz") + " " + crc.code + " "
                + string (outtot, "zzz,zzz,zzz,zz9.99")
                format "x(60)" skip(2).
*/
            put " (курс  " +
                string (joudoc.srate, "999.9999") + bascrc + "/ " +
                string (crc.rate[9], "zzzzzzz") + " " + crc.code + " "
                + string (outtot, "zzz,zzz,zzz,zz9.99")
                format "x(60)" skip(2).
        end.

        intot = 0.
        outtot = 0.
    end.
end.

put "Примеч. :" + joudoc.remark[1] format "x(77)" skip.
put "         " + joudoc.remark[2] format "x(77)" skip.
put "         " + joudoc.rescha[3] format "x(77)" skip.
put
"------------------------------------------------------------------------------"    skip.
put "Выполнил : " + ofc.name format "x(77)" skip
"============================================================================="
    skip(15).

output close.

unix silent prit stmt.img.
/*unix silent joe stmt.img.*/

