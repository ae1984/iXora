/* jgg_vou.p
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

/** jgg_vou.p
    KONTS->0 -- KASE (klienta voucher ) **/
/* 01.10.02 nadejda - наименование клиента заменено на форма собств + наименование */

{mainhead.i}
{chbin.i}

define shared variable v_doc   like joudoc.docnum.

define variable vcha1    as character format "x(65)".
define variable v-point  as integer.
define variable tot      as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99".
define variable outtot   as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99".
define variable vardiem  as character.
define variable siknauda as character.
define variable bascode  like crc.code.
define variable bascrc   like crc.crc.
define variable n        as integer.
define variable m        as integer.

find first cmp.
vcha1 = " " + cmp.name.
find joudoc where joudoc.docnum = v_doc no-lock.
find ofc where ofc.ofc = joudoc.who no-lock.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.
find jh where jh.jh eq joudoc.jh no-lock.

bascrc = 1.
find crc where crc.crc eq bascrc no-lock.
bascode = crc.code.

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then v-bankbin = sysc.chval. else v-bankbin = cmp.addr[2].

output to stmt.img.

put space(25) "КАССОВЫЙ ОРДЕР (ВЫПЛАТА)" skip.
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


find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
find cif of aaa no-lock no-error.
find crc where crc.crc eq joudoc.drcur no-lock.
put "ПЛАТЕЛЬЩИК " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(78)" skip.
put "          " + cif.jss format "x(78)" skip.
if joudoc.drcur eq joudoc.crcur then do:
    put "  счет  " + joudoc.dracc format "x(30)".
    put string (joudoc.dramt, "z,zzz,zzz,zzz,zz9.99") + " " + crc.code
        format "x(25)" at 48 skip(1).
end.
else do:
    if bascrc ne crc.crc then put "  счет  " + joudoc.dracc + " (курс  " +
        string (joudoc.brate, "999.9999") + " " + bascode + "/" +
        string (joudoc.bn, "zzzzzzz") + crc.code + ")" +
        string (joudoc.dramt, "z,zzz,zzz,zzz,zz9.99") + " " + crc.code
        format "x(78)" skip(1).
    else do:
        put "  счет  " + joudoc.dracc format "x(30)".
        put string (joudoc.dramt, "z,zzz,zzz,zzz,zz9.99") + " " + crc.code
            format "x(25)" at 48 skip(1).
    end.
end.


find crc where crc.crc eq joudoc.crcur no-lock.
put "ВЫПЛ В КАССЕ".
if joudoc.drcur eq joudoc.crcur then
    put string (joudoc.cramt, "z,zzz,zzz,zzz,zz9.99") + " " + crc.code
        format "x(25)" at 48 skip.
else do:
    if crc.crc ne bascrc then put " (курс  " +
        string (joudoc.srate, "999.9999") + " " + bascode + "/" +
        string (joudoc.sn, "zzzzzzz") + crc.code + ")" +
        string (joudoc.cramt, "z,zzz,zzz,zzz,zz9.99") + " " + crc.code
        format "x(59)" at 19 skip.
    else put string (joudoc.cramt, "z,zzz,zzz,zzz,zz9.99") + " " + crc.code
        format "x(25)" at 48 skip.
end.


run Sm-vrd (input truncate (joudoc.cramt, 0), output vardiem).
siknauda = string (joudoc.cramt, "z,zzz,zzz,zzz,zz9.99").

if substring (siknauda, r-index (siknauda, ".") + 1, 2) eq "00" then do:
    if length (vardiem) lt 63 then put "Сумма прописью:" skip(2) vardiem + " " +               crc.code format "x(78)" skip(1).
    else do:
        n = r-index (vardiem, " ", 63).
        put "Сумма прописью:" skip(2) substring (vardiem, 1, n)
            format "x(78)" skip.

        if length (vardiem) lt (n + 78) then
            put substring (vardiem, n + 1) + " " + crc.code format "x(78)"
                skip(1).
        else do:
            m = r-index (vardiem, " ", (n + 78)).
            put substring (vardiem, n + 1, m - n) format "x(78)" skip.
            put substring (vardiem, m + 1) + " " + crc.code format "x(78)"
                skip(1).
        end.
    end.
end.
else do:
    siknauda = substring (siknauda, r-index (siknauda, ".") + 1).
    if length (vardiem) lt 51 then put "Сумма прописью:" skip(2) vardiem + ", " +              siknauda + "/100 " + crc.code format "x(77)" skip(1).
    else do:
        n = r-index (vardiem, " ", 63).
        put "Сумма прописью:" skip(2) substring (vardiem, 1, n)
            format "x(78)" skip.

        if length (vardiem) lt (n + 66) then
            put substring (vardiem, n + 1) + ", " + siknauda + "/100 " +
                crc.code format "x(78)" skip(1).
        else do:
            m = r-index (vardiem, " ", (n + 78)).
            put substring (vardiem, n + 1, m - n) format "x(78)" skip.
            put substring (vardiem, m + 1) + ", " + siknauda + "/100 " +
                crc.code format "x(78)"
                skip(1).
        end.
    end.
end.



if joudoc.comamt ne 0 then do:
    find first jouset where jouset.proc eq "jcc_jou" no-lock no-error.
    find crc where crc.crc eq joudoc.comcur no-lock.
    put "БАНКОВСКАЯ КОМИССИЯ" skip.
    if jouset.drtype eq joudoc.comacctype then do:
        put "   удержана со счета " + joudoc.comacc format "x(40)".
        put string (joudoc.comamt, "z,zzz,zzz,zzz,zz9.99") + " " + crc.code
            at 48 format "x(25)" skip.
    end.
    if joudoc.cracctype eq joudoc.comacctype then do:
        put "   внесена в кассу   " format "x(25)".
        put string (joudoc.comamt, "z,zzz,zzz,zzz,zz9.99") + " " + crc.code
            at 48 format "x(25)" skip.

        run Sm-vrd (input truncate (joudoc.comamt, 0), output vardiem).
        siknauda = string (joudoc.comamt, "z,zzz,zzz,zzz,zz9.99").

        if substring (siknauda, r-index (siknauda, ".") + 1, 2) eq "00"
            then do:

            if length (vardiem) lt 63 then put "Сумма прописью:" skip(2) vardiem + " "                 + crc.code format "x(78)" skip(1).
            else do:
                n = r-index (vardiem, " ", 63).
                put "Summa v–rdiem: " + substring (vardiem, 1, n)
                    format "x(78)" skip.
                put substring (vardiem, n + 1) + " " +
                    crc.code format "x(78)" skip(1).
            end.
        end.
        else do:
            siknauda = substring (siknauda, r-index (siknauda, ".") + 1).
            if length (vardiem) lt 51 then put "Сумма прописью:" skip(2) vardiem +
                ", " + siknauda + "/100 " + crc.code format "x(77)" skip(1).
            else do:
                n = r-index (vardiem, " ", 63).
                put "Сумма прописью:" skip(2) substring (vardiem, 1, n)
                    format "x(78)" skip.
                put substring (vardiem, n + 1) + ", " + siknauda + "/100 " +                     crc.code format "x(78)" skip(1).
            end.
        end.
    end.

    put skip(1).
end.

put "Примеч. :" + joudoc.remark[1] format "x(77)" skip.
put "         " + joudoc.remark[2] format "x(77)" skip.
put "         " + joudoc.rescha[3] format "x(77)" skip.
/*
if joudoc.chk ne 0 then do:
    put "Izmaks–ts pёc ўeka Nr." + string(joudoc.chk) format "x(45)" skip.
end. */
put
"------------------------------------------------------------------------------"    skip.
put "Получил  :" joudoc.info format "x(35)" "Кассир  :" at 50 skip.
    if joudoc.passp eq ? then put " Pase " skip.
    else put "Пасп. " + joudoc.passp format "x(35)" skip.

 /*
put " Pase " + joudoc.passp format "x(35)" skip.*/
put " Персон. код   " + joudoc.perkod format "x(35)" skip.
put " Подпись :" skip.
put
"============================================================================="
    skip(15).

output close.

unix silent prit stmt.img.
/*unix silent joe stmt.img.*/

