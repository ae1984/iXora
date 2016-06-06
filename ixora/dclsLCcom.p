/* dclsLCcom.p
 * MODULE
        Название модуля
 * DESCRIPTION
        амортизация комиссии для аккредитива
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
        09/09/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        08/10/2010 galina - перекомпиляция
        08/12/2010 galina - поправила расчет суммы амотризации
        27/01/2011 id00810 - добавила комиссию с кодом 966
        17/03/2011 id00810 - убрала проверку по таблице LCres
        10/01/2012 id00810 - остаток комиссии считаем по проводкам
        12/01/2012 id00810 - запоминаем остаток
        03/02/2012 id00810 - учет реквизита NewDtExp, всех проводок по комиссии (в событих amendment, internal charges)
        27/03/2012 id00810 - корректировка алгоритма расчета v-amt в событиях internal charges
        11.12.2012 Lyubov  - по ошибке при рассчете учитывались сторнированные проводки, исключила их из выборки
        14.03.2013 Lyubov  - ТЗ 1726, изменился счет для амортизиции 966 комиссии для новых гарантий
        18.11.2013 Lyubov  - ТЗ 2125, амортизация комиссии расчитывается до даты Oblagation Validity если она заполнена
*/

{global.i}
define shared var s-target as date.
def var v-comsum   as deci.
def var v-amt      as deci.
def var v-allready as deci.
def var v-yet      as deci.
def var v-dtexp    as date.
def var v-dtis     as date.
def var v-jh       like jh.jh.
def var v-gl       as char.
def var v-comacc   as char.
def var v-crc      like crc.crc.
def var v-rem      as char.
def var v-param    as char no-undo.
def var vdel       as char no-undo initial "^".
def var rcode      as int  no-undo.
def var rdes       as char no-undo.
def var v-ourbnk   as char.
def var v-trx      as char.
def var v-comcode  as char.
def buffer b-lc for lc.

def var v-amacc    as inte.

v-ourbnk = ''.
find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if avail sysc and trim(sysc.chval) <> '' then v-ourbnk = sysc.chval.
else return.

for each LC where LC.bank = v-ourbnk and LC.LCsts = 'FIN' no-lock:
    if LC.comsum = 0 then next.

    if lc.lc begins 'imlc' then v-comcode = '970'.
    else if lc.lc begins 'pg' then v-comcode = '966'.
    else next.

    find first lcres where lcres.lc = lc.lc and lcres.com and lcres.comcode = v-comcode no-lock no-error.
    if  avail lcres then do:
        v-amt = lcres.amt.
        if v-comcode = '966' then v-amacc = int(lcres.cacc).
        else v-amacc = 285531.
    end.

    for each lcamendres where lcamendres.lc = lc.lc and lcamendres.com and lcamendres.comcode = v-comcode no-lock.
        if lcamendres.levC = 25 or can-do('285532,286931',lcamendres.cacc) then v-amt = v-amt + lcamendres.amt.
        else v-amt = v-amt - lcamendres.amt.
    end.

    for each lceventres where lceventres.lc = lc.lc and lceventres.event = 'intch' and lceventres.com and lceventres.comcode = v-comcode no-lock.
        if lceventres.levC = 25 or can-do('285532,286931',lceventres.cacc) then v-amt = v-amt + lceventres.amt.
        else if lceventres.levD = 25 or can-do('285532,286931',lceventres.dacc) then v-amt = v-amt - lceventres.amt.
    end.

    find first lch where lch.lc = LC.LC and lch.kritcode = 'DtExp' no-lock no-error.
    if avail lch  and trim(lch.value1) <> '' then  v-dtexp = date(lch.value1).
    else next.

    find last lcamendh where lcamendh.lc = lc.lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
    if avail lcamendh then v-dtexp = date(lcamendh.value1).

    find first lch where lch.lc = LC.LC and lch.kritcode = 'OblValid' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then  v-dtexp = date(lch.value1).

    if lc.lc begins 'imlc' then find first lch where lch.lc = LC.LC and lch.kritcode = 'DtIs' no-lock no-error.
    else find first lch where lch.lc = LC.LC and lch.kritcode = 'Date' no-lock no-error.
    if avail lch  and trim(lch.value1) <> '' then  v-dtis = date(lch.value1).
    else next.

    find first lch where lch.lc = LC.LC and lch.kritcode = 'Comacc' no-lock no-error.
    if avail lch  and trim(lch.value1) <> '' then do:
        find first aaa where aaa.aaa = lch.value1 no-lock no-error.
        if avail aaa then do:
            v-comacc = lch.value1.
            v-crc = aaa.crc.
        end.
        else next.
    end.
    else next.

    v-allready = 0.
    for each jl where jl.jdt >= v-dtis and jl.dc = 'D' and jl.gl = v-amacc no-lock.
        if index(jl.rem[1],lc.lc) = 0 and index(jl.rem[2],lc.lc) = 0 then next.
        if index(jl.rem[1],'сторно') <> 0 or index(jl.rem[2],'сторно') <> 0 or index(jl.rem[1],'Storno') <> 0 or jl.crc <> 1 then next.
        v-allready = v-allready + jl.dam.
    end.

    v-yet = v-amt - v-allready.

    if s-target >= v-dtexp then  v-comsum  = v-yet.
    else v-comsum  = round((v-yet / (v-dtexp - g-today)) * (s-target - g-today), 2).

    find first tarif2 where tarif2.str5 = v-comcode and tarif2.stat = 'r' no-lock no-error.
    if avail tarif2 then v-gl = string(tarif2.kont).
    else next.
    if v-gl = '' then next.

    v-rem = LC.LC.
    if v-comcode = '970'
    then assign v-param = string(v-comsum) + vdel + string(v-crc) + vdel + v-comacc + vdel + v-gl + vdel + v-rem
                v-trx = 'cif0012'.
    else assign v-param = string(v-comsum) + vdel + string(v-crc) + vdel + string(v-amacc) + vdel + v-gl + vdel + 'Амортизация комиссионного вознаграждения на доходы ' + v-rem
                v-trx = 'uni0144'.
     v-jh = 0.
    run trxgen (v-trx, vdel, v-param, "cif" , v-comacc , output rcode, output rdes, input-output v-jh).

    if rcode ne 0 then do:
        run savelog("lccom", "ERROR " + lc.lc + " " + rdes + " " + v-trx).
    end.
    else do:
        if v-jh > 0 then do:
            find first b-lc where b-lc.lc = lc.lc exclusive-lock no-error.
            if avail b-lc then b-lc.comsum = v-yet - v-comsum.
            find current b-lc no-lock no-error.
            run savelog("lccom", "OK " + lc.lc + " " + string(v-jh) ).
        end.
    end.
end.