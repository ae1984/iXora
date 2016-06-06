/* lnsootvcods.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Преведение в признаков lnshifr и lnovdcd в зависимости от признака lndrhar, ФЛ/ЮЛ, долгосрочности и валюты
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
        05/11/2013 Sayat(id01143) - ТЗ 2174 от 30/10/2013 "Приведение в соответствие кода займа"
 * BASES
        BANK
 * CHANGES
        07/11/2013 Sayat(id01143) - ТЗ 2174 от 30/10/2013 "Приведение в соответствие кода займа" перекомпиляция
*/
def var v-cod as char.
def var v-cod1 as int.
def var v-urfiz as int. /* ur - 1, fiz - 2 */
def var v-crc as char. /* 1 - тенге, 2 - СКВ, 3 - ДВВ */
def var v-valut as int.
def var v-srok as int. /* 1 - краткосрочный, 2 - долгосрочный */
def var v-lndrhar as char.
def var v-gl as char.
def var k as int.
def var n as int.
def var v-small as int. /* 2 - малое предпринимательство, 1 - не малое */
def shared var g-today as date.
/*def stream v-out .
output stream v-out to lnsootvcods.csv.
put stream v-out unformatted "cif;lon;name;v-valut;v-urfiz;v-small;v-srok;k;v-crc;v-lndrhar;v-gl;" skip.*/

for each lon /*where lon = '005147222'*/ no-lock:

    v-gl = substr(string(lon.gl),1,4).
    if v-gl = '1417' then v-srok = 2.
    else if v-gl = '1401' or v-gl = '1411' then v-srok = 1.
    else next.

    find first crc where crc.crc = lon.crc no-lock no-error.
    if avail crc then v-crc = trim(crc.code).
    else next.
    if lon.crc = 1 then v-valut = 1.
    else if lookup(v-crc,'AUD,KRW,HKD,DKK,USD,EUR,JPY,CAD,MXN,NZD,ILS,NOK,SGD,GBP,SEK,CHF,ZAR') <> 0 then v-valut = 2.
    else v-valut = 3.

    find first sub-cod where sub-cod.sub = 'lon' and sub-cod.d-cod = 'lndrhar' and sub-cod.acc = lon.lon no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-lndrhar = sub-cod.ccode.
    else next.
    if v-lndrhar = '04.1' then v-small = 2.
    else v-small = 1.

    find first cif where cif.cif = lon.cif no-lock no-error.
    if avail cif then do:
        if cif.type = 'B' and lookup(string(cif.cgr),'403,405,605') = 0 then v-urfiz = 1.
        else v-urfiz = 2.
    end.
    else next.

    k = (v-valut - 1) * 8.
    k = k + (v-urfiz - 1) * 4.
    k = k + (v-small - 1) * 2.
    k = k + v-srok.

    /*displ v-valut v-urfiz v-small v-srok k.*/
    /*put stream v-out unformatted  lon.cif ";" lon.lon ";" cif.prefix + " " cif.name ";" v-valut ";" v-urfiz ";" v-small ";" v-srok ";" k ";" v-crc ";" v-lndrhar ";" v-gl ";" skip.*/

    if k <= 0 then next.

    find first sub-cod where sub-cod.sub = 'lon' and sub-cod.d-cod = 'lnshifr' and sub-cod.acc = lon.lon exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        assign sub-cod.sub = 'lon' sub-cod.acc = lon.lon sub-cod.d-cod = 'lnshifr' sub-cod.rdt = g-today.
    end.
    sub-cod.ccode = string(k,'99').
    find current sub-cod no-lock no-error.

    find first sub-cod where sub-cod.sub = 'lon' and sub-cod.d-cod = 'lnovdcd' and sub-cod.acc = lon.lon exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        assign sub-cod.sub = 'lon' sub-cod.acc = lon.lon sub-cod.d-cod = 'lnovdcd' sub-cod.rdt = g-today.
    end.
    sub-cod.ccode = string(k + 24,'99').
    find current sub-cod no-lock no-error.

end.

/*output stream v-out close.
unix silent cptwin lnsootvcods.csv excel.*/