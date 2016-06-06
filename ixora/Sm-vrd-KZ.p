/* Sm-vrd-KZ.p
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Перевод численного представления суммы в прописную
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
        23.04.2008 - alex
 * BASES
        BANK COMM
 * CHANGES
        01/06/2009 madiyar - второй входной параметр, валюта
        15/07/2009 madiyar - при валюте, равной 0, названий не пишем
        16.07.2009 marinav - замена символов на буквы каз языка
*/

def var edn as char format 'x(18)' extent 10 init
            ['бiр ', 'екi ', 'їш ', 'тґрт ', 'бес ', 'алты ', 'жетi ', 'сегiз ', 'тоєыз ', ' '].
def var des as char format 'x(18)' extent 10 init
            ['он ', 'жиырма ', 'отыз ', 'ќырыќ ', 'елю ', 'алпыс ', 'жетпiс ', 'сексен ', 'то&#1179;сан ', ' '].
def var oth as char format 'x(18)' extent 5 init
            ['миллиард ', 'миллион ', 'мыѕ ', 'жїз ', ' '].
def input parameter in-summa as deci.
def input parameter in-crc as integer.
def output parameter out-summa as char.

def var crcn1 as char extent 3 init ['теѕге','доллар А&#1178;Ш','евро'].
def var crcn2 as char extent 3 init ['тиын','цент','евроцент'].

/*
def var in-summa as deci format '999,999,999,999.99'.
def var out-summa as char.
*/

def var k as int.
def var i as int.
def var s as char format 'x(3)'.
def var sb1 as char format 'x(1)'.
def var sb2 as char format 'x(1)'.
def var sb3 as char format 'x(1)'.
def var str-sum as char format 'x(18)'.

/*
set in-sum no-label.
*/

if in-summa > 999999999999.99 then do:
    out-summa = 'слишком много разрядов!'.

/*
    display out-sum format 'x(2000)' no-label view-as editor size 100 by 3.
*/

    return.
end.

str-sum = string(in-summa, '999,999,999,999.99').
out-summa = "".

k = 1.

do i = 1 to 4:
    s = substring(str-sum, k, 3).
    k = k + 4.

    if int(s) ge 0 then do:
        sb1 = substring(s,1,1).
        sb2 = substring(s,2,1).
        sb3 = substring(s,3,1).
    end.

    if sb1 ne '0' then
        if sb1 eq '1' then out-summa = out-summa + oth[4].
            else out-summa = out-summa + edn[int(sb1)] + oth[4].
    if sb2 ne '0' then out-summa = out-summa + des[int(sb2)].
    if sb3 ne '0' then out-summa = out-summa + edn[int(sb3)].
    if (i ne 4) and (s ne '000') then out-summa = out-summa + oth[i].
end.

s = substring(str-sum,17,2).

if (in-crc < 1) or (in-crc > 3) then do:
    if out-summa = '' then out-summa = 'ноль'.
    if integer(s) > 0 then out-summa = out-summa + ',' + s.
end.
else do:
    if out-summa ne '' then out-summa = out-summa + crcn1[in-crc] + ' ' + s + ' ' + crcn2[in-crc].
    else out-summa = 'ноль ' + crcn1[in-crc] + ' ' + s + ' ' + crcn2[in-crc].
end.

if substring(out-summa,1,1) = '&' then do:
    k = int(substring(out-summa,3,4)).
    k = k + 1.
    s ='&#' + string(k) + ';'.
    out-summa = s + substring(out-summa,8,length(out-summa)).
end.
else overlay(out-summa,1,1) = caps(substring(out-summa,1,1)).
return.

/*if out-sum ne '' then display out-sum format 'x(2000)' no-label view-as editor size 100 by 3.*/