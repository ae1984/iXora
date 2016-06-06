/* repstruc.p
 * MODULE

 * DESCRIPTION
        Сведения об изменениях в структуре активов, обязательств и капитала
 * RUN

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24/12/2012 Luiza
 * BASES
        BANK COMM
 * CHANGES
*/
{mainhead.i}

def new shared var dt1 as date no-undo.
def new shared var dt2 as date no-undo.
def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.
def new shared var v-ful as logic format "да/нет" no-undo.

def stream v-out.
def stream v-ob.
def var prname as char.
def new shared var v-select1 as int no-undo.
def var v-ful1 as int no-undo.


displ dt1 label   " С " format "99/99/9999" validate(dt1 < g-today, "Некорректная дата!") skip
      dt2 label   " По" format "99/99/9999" validate(dt2 < g-today and dt2 > dt1, "Некорректная дата!") skip
      v-ful label " С расшифровкой" skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update dt2 v-ful with frame dat.

v-select1 = 0.
def var v-raz as char  no-undo.

run sel2 (" Выберите ", "1. В млн.тенге |2. В тенге |3. ВЫХОД ", output v-select1).
if keyfunction (lastkey) = "end-error" or v-select1 = 3 then return.
if v-select1 = 1 then v-raz = "  в млн.тенге". else v-raz = "  в тенге".

def temp-table dif  /* для расчета расхождений  */
      field gl like gl.gl
      field crc like crc.crc
      field sum_gl as deci
      field sum_gl_kzt as deci
      field sum_lon as deci
      index gl_idx is primary gl
      index glcrc_idx is unique gl crc.


define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .

define new shared temp-table tgl1
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .

define new shared temp-table t-salde no-undo
    field jh as int
    field jdt as date
    field tmp as char
    field dgl as int
    field dacc as char
    field dcrc as int
    field cgl as int
    field cacc as char
    field ccrc as int
    field cod as char
    field kbe as char
    field knp as char
    field dtsum as decim
    field dtsumtng as decim
    field ctsum as decim
    field ctsumtng as decim
    field rem as char
    field nameo as char
    field nameb as char
    field secek as char
    field dtop as date
    field dtcl as date
    field txb as char
    field txbname as char
    field sub as char
    field poz as int
    field ao as char
    index ind is primary txb jh.


define new shared variable v-gldate as date.
def new shared var v-gl1 as int no-undo.
def new shared var v-gl2 as int no-undo.
def new shared var v-gl-cl as int no-undo.
def var RepName as char.
def var RepPath as char init "/data/reports/array/".

define new shared temp-table wrk1 no-undo
    field num as char extent 40
    field sum as decim extent 40 format ">>>,>>>,>>>,>>>,>>9.99"
    field ps as char extent 40 .

create wrk1. /* остаток на начало */
wrk1.num[5] = "100". /* денежная наличность */
wrk1.num[9] = "1051,110,1705131,1710". /* Вклады в НБРК */
wrk1.num[13] = "120,145,148". /*,1744,1745,1746".*/ /* Ценные бумаги */
wrk1.num[17] = "1052,1054,125,1264". /*,1264141,1267141,1705141,1725,1726,1728141". */ /* Вклады в банках */
wrk1.num[21] = "130,1320". /*,1730,1731,1733,1734".*/ /* Займы банкам */
wrk1.num[25] = "1401,1407,1411,1417,1434". /*,1421,1423,1424,1427,1428,1740,1741".*/ /* Займы юр. и физ. лицам */
wrk1.num[29] = "1424,1741". /*1409,1421,1423,1424,1427,1741". *//* Просроченная задолженность по займам юр. и физ. лицам */
wrk1.num[33] = "1428". /* Провизии по займам юр. и физ. лиц */
wrk1.num[37] = "". /* Прочие активы */

create wrk1.  /*остаток на конец */
wrk1.num[5] = "100". /* денежная наличность */
wrk1.num[9] = "1051,110,1705131,1710". /* Вклады в НБРК */
wrk1.num[13] = "120,145,148". /*,1744,1745,1746".*/ /* Ценные бумаги */
wrk1.num[17] = "1052,1054,125,1264". /*,1264141,1267141,1705141,1725,1726,1728141". */ /* Вклады в банках */
wrk1.num[21] = "130,1320". /*,1730,1731,1733,1734".*/ /* Займы банкам */
wrk1.num[25] = "1401,1407,1411,1417,1434". /*,1421,1423,1424,1427,1428,1740,1741".*/ /* Займы юр. и физ. лицам */
wrk1.num[29] = "1424,1741". /*1409,1421,1423,1424,1427,1741". *//* Просроченная задолженность по займам юр. и физ. лицам */
wrk1.num[33] = "1428". /* Провизии по займам юр. и физ. лиц */
wrk1.num[37] = "". /* Прочие активы */

define new shared temp-table wrk2 no-undo
    field num as char extent 40
    field sum as decim extent 40 format ">>>,>>>,>>>,>>>,>>9.99"
    field ps as char extent 40 .

create wrk2. /* остаток на начало */
wrk2.num[5] = "2051,2059". /*,2111".*/ /* Займы НБРК */
wrk2.num[9] = "2054,2055,2056,2057,2058,2064,2065,2066,2067,2068,2069,2070,2113,2705,2706,2711,2741141". /* Займы банков */
wrk2.num[13] = "2013,2123,2023,2024,2124,2125,2127,2128,2129,2130,2131,2133,2135,2136,2137,2138,2702,2718,2713,2714". /* Вклады банков */
wrk2.num[17] = "2203,2211,2213,2215,2217,2219,2222,2223,2224151,2224161,224171,2224181,2225151,2225161,2225171,2225181,
                2226151,2226161,2226171,2226181,2231,2232151,2232161,2232171,2232181,2233151,2233161,2233171,2233181,
                2234151,2234161,2234171,2234181,2235151,2235161,2235171,2235181,2236151,2236161,2236171,2236181,
                2238151,2238161,2238171,2238181,2239151,2239161,2239171,2239181". /*,2240151,2240161,2240171,2240181,
                2707151,2707161,2707171,2707181,2718151,2718161,2718171,2718181,2719151,2719161,2719171,2719181,
                2720151,2720161,2720171,2720181,2721151,2721161,2721171,2721181,2722151,2722161,2722171,2722181,
                2723151,2723161,2723171,272318". */ /* Вклады юрлиц */
wrk2.num[21] = "2204,2205,2206,2207,2208". /*2213,2224191,2225191,2226191,2232191,2233191,2234191,2235191,2236171,
                2238191,2239191,2240191,2707191,2718191,2719191,2720191,2721191,2723191".*/ /* Вклады физлиц  */
wrk2.num[25] = "240". /* Субординированный долг */
wrk2.num[29] = "". /*2725,2855".*/ /* Операции "РЕПО" с ценными бумагами */
wrk2.num[33] = "". /* Прочие обязательства*/
wrk2.num[37] = "3". /* Капитал */

create wrk2.  /*остаток на конец */
wrk2.num[5] = "2051,2059". /*,2111".*/ /* Займы НБРК */
wrk2.num[9] = "2054,2055,2056,2057,2058,2064,2065,2066,2067,2068,2069,2070,2113,2705,2706,2711,2741141". /* Займы банков */
wrk2.num[13] = "2013,2123,2023,2024,2124,2125,2127,2128,2129,2130,2131,2133,2135,2136,2137,2138,2702,2718,2713,2714". /* Вклады банков */
wrk2.num[17] = "2203,2211,2213,2215,2217,2219,2222,2223,2224151,2224161,224171,2224181,2225151,2225161,2225171,2225181,
                2226151,2226161,2226171,2226181,2231,2232151,2232161,2232171,2232181,2233151,2233161,2233171,2233181,
                2234151,2234161,2234171,2234181,2235151,2235161,2235171,2235181,2236151,2236161,2236171,2236181,
                2238151,2238161,2238171,2238181,2239151,2239161,2239171,2239181". /*,2240151,2240161,2240171,2240181,
                2707151,2707161,2707171,2707181,2718151,2718161,2718171,2718181,2719151,2719161,2719171,2719181,
                2720151,2720161,2720171,2720181,2721151,2721161,2721171,2721181,2722151,2722161,2722171,2722181,
                2723151,2723161,2723171,272318". */ /* Вклады юрлиц */
wrk2.num[21] = "2204,2205,2206,2207,2208". /*2213,2224191,2225191,2226191,2232191,2233191,2234191,2235191,2236171,
                2238191,2239191,2240191,2707191,2718191,2719191,2720191,2721191,2723191".*/ /* Вклады физлиц  */
wrk2.num[25] = "240". /* Субординированный долг */
wrk2.num[29] = "". /*2725,2855".*/ /* Операции "РЕПО" с ценными бумагами */
wrk2.num[33] = "". /* Прочие обязательства*/
wrk2.num[37] = "3". /* Капитал */


function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.


v-gldate = dt1.
RepName = "array" + string(v-gl1) + string(v-gl2) + string(v-gl-cl) + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".
if not FileExist(RepPath + RepName) then do:
 run array-create.
end.
else run ImportData.

def var lst as char.
def var v-grp as char.
def var j as int.
def var i as int.
displ  "Ждите, формир-ся данные по остаткам на начало периода" format "x(70)" with row 10 overlay frame ww .
pause 0.
for each tgl.
tgl.level = 0.
end.
/* активы остаток на начало*/
    find first wrk1.
    i = 5.
    do while i <= 37:
        lst = wrk1.num[i]. /* по долгу */
        do j = 1 to num-entries(lst):
            v-grp = entry(j,lst).
            if length(v-grp) <= 4 then do:
                for each tgl where string(tgl.gl7) begins v-grp.
                    wrk1.sum[i]  = wrk1.sum[i] + tgl.sum.
                    tgl.level = i.
                end.
            end.
            else do:
                for each tgl where string(tgl.gl7) begins substring(v-grp,1,4) and substring(string(tgl.gl7),5,1) = substring(v-grp,5,1).
                    wrk1.sum[i]  = wrk1.sum[i] + tgl.sum.
                    tgl.level = i.
                end.
            end.
        end.   /*  do i = 1 to num-entries(lst) */
        i = i + 1.
    end.
/*обязательства остаток на начало */
    find first wrk2.
    i = 5.
    do while i <= 37:
        lst = wrk2.num[i]. /* по долгу */
        do j = 1 to num-entries(lst):
            v-grp = entry(j,lst).
            if length(v-grp) <= 4 then do:
                for each tgl where string(tgl.gl7) begins v-grp.
                    wrk2.sum[i]  = wrk2.sum[i] + tgl.sum.
                    tgl.level = i.
                end.
            end.
            else do:
                for each tgl where string(tgl.gl7) begins substring(v-grp,1,4) and substring(string(tgl.gl7),5,1) = substring(v-grp,5,1).
                    wrk2.sum[i]  = wrk2.sum[i] + tgl.sum.
                    tgl.level = i.
                end.
            end.
        end.   /*  do i = 1 to num-entries(lst) */
        i = i + 1.
    end.
/* вручную добавляем запись в расхождение по 1424 и по 1428*/
    def var ss as decim.
    run differ(142420,dt1,output ss).
    find first wrk1.
    wrk1.sum[29] = wrk1.sum[29] + ss.
    find first wrk1.
    run differ(142820,dt1,output ss).
    wrk1.sum[33] = wrk1.sum[33] + ss.
/* прочие активы*/
    find first wrk1.
    for each tgl where substring(string(tgl.gl7),1,1) = "1" and tgl.level = 0 and substring(string(tgl.gl7),1,4) <> "1351"
         and substring(string(tgl.gl7),1,4) <> "1352" and substring(string(tgl.gl7),1,4) <> "1858" and substring(string(tgl.gl7),1,4) <> "1859".
        wrk1.sum[37]  = wrk1.sum[37] + tgl.sum.
        tgl.level = 37.
    end.
/* прочие обязательства*/
    find first wrk2.
    for each tgl where substring(string(tgl.gl7),1,1) = "2" and tgl.level = 0 and substring(string(tgl.gl7),1,4) <> "2151"
         and substring(string(tgl.gl7),1,4) <> "2152" and substring(string(tgl.gl7),1,4) <> "2858" and substring(string(tgl.gl7),1,4) <> "2859".
        wrk2.sum[33]  = wrk2.sum[33] + tgl.sum.
        tgl.level = 33.
    end.


displ  "Ждите, формир-ся данные по остаткам на конец периода" format "x(70)" with row 10 overlay frame ww .
pause 0.
/*for each tgl no-lock:
    create tgl1.
    tgl1.txb = tgl.txb.
    tgl1.gl = tgl.gl.
    tgl1.gl4 = tgl.gl4.
    tgl1.gl7 = tgl.gl7.
    tgl1.gl-des = tgl.gl-des.
    tgl1.crc = tgl.crc.
    tgl1.sum = tgl.sum.
    tgl1.sum-val = tgl.sum-val.
    tgl1.type = tgl.type.
    tgl1.sub-type = tgl.sub-type.
    tgl1.totlev = tgl.totlev.
    tgl1.totgl = tgl.totgl.
    tgl1.level = tgl.level.
    tgl1.code = tgl.code.
    tgl1.grp = tgl.grp.
    tgl1.acc = tgl.acc.
    tgl1.acc-des = tgl.acc-des.
    tgl1.geo = tgl.geo.
    tgl1.odt = tgl.odt.
    tgl1.cdt = tgl.cdt.
    tgl1.perc = tgl.perc.
    tgl1.prod = tgl.prod.
    tgl1.level = tgl.level.
end.*/
v-gldate = dt2 .
empty temp-table tgl.
RepName = "array" + string(v-gl1) + string(v-gl2) + string(v-gl-cl) + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".
if not FileExist(RepPath + RepName) then do:
 run array-create.
end.
else run ImportData.
for each tgl.
tgl.level = 0.
end.
/* активы остаток на конец*/
    find last wrk1.
    i = 5.
    do while i <= 37:
        lst = wrk1.num[i]. /* по долгу */
        do j = 1 to num-entries(lst):
            v-grp = entry(j,lst).
            if length(v-grp) <= 4 then do:
                for each tgl where string(tgl.gl7) begins v-grp.
                    wrk1.sum[i]  = wrk1.sum[i] + tgl.sum.
                    tgl.level = i.
                end.
            end.
            else do:
                for each tgl where string(tgl.gl7) begins substring(v-grp,1,4) and substring(string(tgl.gl7),5,1) = substring(v-grp,5,1).
                    wrk1.sum[i]  = wrk1.sum[i] + tgl.sum.
                    tgl.level = i.
                end.
            end.
        end.   /*  do i = 1 to num-entries(lst) */
        i = i + 4.
    end.
/*обязательства остаток на конец */
    find last wrk2.
    i = 5.
    do while i <= 37:
        lst = wrk2.num[i]. /* по долгу */
        do j = 1 to num-entries(lst):
            v-grp = entry(j,lst).
            if length(v-grp) <= 4 then do:
                for each tgl where string(tgl.gl7) begins v-grp.
                    wrk2.sum[i]  = wrk2.sum[i] + tgl.sum.
                    tgl.level = i.
                end.
            end.
            else do:
                for each tgl where string(tgl.gl7) begins substring(v-grp,1,4) and substring(string(tgl.gl7),5,1) = substring(v-grp,5,1).
                    wrk2.sum[i]  = wrk2.sum[i] + tgl.sum.
                    tgl.level = i.
                end.
            end.
        end.   /*  do i = 1 to num-entries(lst) */
        i = i + 4.
    end.
/* вручную добавляем запись в расхождение по 1424 и по 1428*/
    run differ(142420,dt2 + 1,output ss).
    find last wrk1.
    wrk1.sum[29] = wrk1.sum[29] + ss.
    find last wrk1.
    run differ(142820,dt2 + 1,output ss).
    wrk1.sum[33] = wrk1.sum[33] + ss.
/* прочие активы*/
    find last wrk1.
    for each tgl where substring(string(tgl.gl7),1,1) = "1" and tgl.level = 0 and substring(string(tgl.gl7),1,4) <> "1351"
         and substring(string(tgl.gl7),1,4) <> "1352" and substring(string(tgl.gl7),1,4) <> "1858" and substring(string(tgl.gl7),1,4) <> "1859".
        wrk1.sum[37]  = wrk1.sum[37] + tgl.sum.
        tgl.level = 37.
    end.
/* прочие обязательства*/
    find last wrk2.
    for each tgl where substring(string(tgl.gl7),1,1) = "2" and tgl.level = 0 and substring(string(tgl.gl7),1,4) <> "2151"
         and substring(string(tgl.gl7),1,4) <> "2152" and substring(string(tgl.gl7),1,4) <> "2858" and substring(string(tgl.gl7),1,4) <> "2859".
        wrk2.sum[33]  = wrk2.sum[33] + tgl.sum.
        tgl.level = 33.
    end.

/* всего */
    for each wrk1.
        j = 5.
        do while j <= 37:
            wrk1.sum[1] = wrk1.sum[1] + wrk1.sum[j].
            j = j + 4.
        end.
    end.
    for each wrk2.
        j = 5.
        do while j <= 33:
            wrk2.sum[1] = wrk2.sum[1] + wrk2.sum[j].
            j = j + 4.
        end.
    end.

/* в млн. тенге */
if v-select1 = 1 then do:
    i = 1.
    do while i <= 40:
        for each wrk1.
            if wrk1.sum[i] <> 0 then wrk1.sum[i]  = round((wrk1.sum[i] / 1000000),0).
        end.
        for each wrk2.
            if wrk2.sum[i] <> 0 then wrk2.sum[i]  = round((wrk2.sum[i] / 1000000),0).
        end.
        i = i + 1.
    end.
end.
/* расчет  % */
for each wrk1.
    wrk1.sum[2] = 100.
    j = 5.
    do while j <= 40:
        wrk1.sum[j + 1] = round((wrk1.sum[j] / wrk1.sum[1] * 100),2).
        j = j + 4.
    end.
end.
for each wrk2.
    wrk2.sum[2] = 100.
    j = 5.
    do while j <= 40:
        wrk2.sum[j + 1] = round((wrk2.sum[j] / wrk2.sum[1] * 100),2).
        j = j + 4.
    end.
end.
/* расчет отклон и % */
def buffer bwrk1 for wrk1.
find first bwrk1.
find last wrk1.
    j = 1.
    do while j <= 40:
        wrk1.sum[j + 2] = round((wrk1.sum[j] - bwrk1.sum[j]),0).
        if bwrk1.sum[j] <> 0 then wrk1.sum[j + 3] = round((wrk1.sum[j + 2] / bwrk1.sum[j] * 100),0).
        j = j + 4.
    end.
def buffer bwrk2 for wrk2.
find first bwrk2.
find last wrk2.
    j = 1.
    do while j <= 40:
        wrk2.sum[j + 2] = round((wrk2.sum[j] - bwrk2.sum[j]),0).
        if bwrk2.sum[j] <> 0 then wrk2.sum[j + 3] = round((wrk2.sum[j + 2] / bwrk2.sum[j] * 100),0).
        j = j + 4.
    end.
/*----расшифровка-----------------------------------------------------------------------------------------------*/
    define new shared temp-table wgl no-undo
        field gl     as integer /*like gl.gl*/
        field des as character
        field lev as integer
        field subled as character /*like gl.subled*/
        field type   as character /*like gl.type*/
        field code as char
        field grp as int
        field g5 as char  /* 5 позиция балансового счета */
        field poz as int
        field ao as char
        index wgl-idx1 is unique primary gl
        index wgl-idx2  subled.


    /* формируется рабочая таблица */
    /* по активам */
    find last wrk1.
    j = 8.
    do while j <= 40:
        if absolute(wrk1.sum[j]) >= 5 then do: /* если отклонение больше 5% формируем расшифровку и пояснение */
            lst = wrk1.num[j - 3].
            do i = 1 to num-entries(lst):
                v-grp = entry(i,lst).
                for each gl where string(gl.gl) begins substring(v-grp,1,4) no-lock.
                    find first wgl where wgl.gl = gl.gl no-error.
                    if not available wgl then do:
                        create wgl.
                        wgl.gl = gl.gl.
                        wgl.subled = gl.subled.
                        wgl.des = gl.des.
                        wgl.lev = gl.level.
                        wgl.type = gl.type.
                        wgl.code = gl.code.
                        wgl.grp = gl.grp.
                        wgl.g5 = substring(v-grp,5,1).
                        wgl.poz = j - 3.
                        wgl.ao = "A".
                    end.
                    else if wgl.g5 = "" then wgl.g5 = substring(v-grp,5,1). else wgl.g5 = "," + substring(v-grp,5,1).

                end.
            end.
        end.
        j = j + 4.
    end.

    /* по обязательствам */
    find last wrk2.
    j = 8.
    do while j <= 40:
        if absolute(wrk2.sum[j]) >= 5 then do: /* если отклонение больше 5% формируем расшифровку и пояснение */
            lst = wrk2.num[j - 3].
            do i = 1 to num-entries(lst):
                v-grp = entry(i,lst).
                for each gl where string(gl.gl) begins substring(v-grp,1,4) no-lock.
                    find first wgl where wgl.gl = gl.gl no-error.
                    if not available wgl then do:
                        create wgl.
                        wgl.gl = gl.gl.
                        wgl.subled = gl.subled.
                        wgl.des = gl.des.
                        wgl.lev = gl.level.
                        wgl.type = gl.type.
                        wgl.code = gl.code.
                        wgl.grp = gl.grp.
                        wgl.g5 = substring(v-grp,5,1).
                        wgl.poz = j - 3.
                        wgl.ao = "O".
                    end.
                    else if wgl.g5 = "" then wgl.g5 = substring(v-grp,5,1). else wgl.g5 = "," + substring(v-grp,5,1).

                end.
            end.
        end.
        j = j + 4.
    end.

    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        displ  "Ждите, идет сбор данных для расшифровки № 2 " + comm.txb.info format "x(70)".
        pause 0.
        run repstruc1.
    end.
    if connected ("txb")  then disconnect "txb".

/* заполнение пояснений */

/*------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------*/
def stream v-out.
output stream v-out to struc.html.
    put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<h3> Сведения об изменениях в структуре активов, обязательств и капитала <br>"
                                    v-fil-cnt " с " dt1 " по " dt2 v-raz "</h3>" skip.

/*1.  активы*/
    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=2 colspan=4 align=center > Активы, всего </TD>" skip
         "<TD colspan=36 align=center > в том числе </TD></tr>" skip

         "<tr><TD colspan=4 align=center > Денежная наличность </TD>" skip
         "<TD colspan=4 align=center > Вклады в НБРК </TD>" skip
         "<TD colspan=4 align=center > Ценные бумаги </TD>" skip
         "<TD colspan=4 align=center > Вклады в банках </TD>" skip
         "<TD colspan=4 align=center > Займы банкам </TD>" skip
         "<TD colspan=4 align=center > Займы юр. и физ. лицам </TD>" skip
         "<TD colspan=4 align=center > Просроченная задолженность по займам юр. и физ. лицам </TD>" skip
         "<TD colspan=4 align=center > Провизии по займам юр. и физ. лиц </TD>" skip
         "<TD colspan=4 align=center > Прочие активы </TD></tr>" skip
         "<tr><TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip
         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip
         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD></tr>" skip.
         i = 1.
         put stream v-out unformatted
             "<tr>" skip.
         do while i <= 40:
             put stream v-out unformatted  "<TD bgcolor=""#d8d9db"">" i "</TD>" skip.
            i = i + 1.
        end.
        put stream v-out unformatted "</tr>" skip.

        for each wrk1 .
            put stream v-out unformatted
                 "<tr>" skip.
             i = 1.
             do while i <= 40:
                if wrk1.sum[i] <> 0 then do:
                    if wrk1.sum[i] - int(entry(1,string(wrk1.sum[i]),".")) <> 0 then put stream v-out unformatted "<TD>" replace(trim(string(wrk1.sum[i],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    else put stream v-out unformatted "<TD>" replace(trim(string(wrk1.sum[i],'->>>>>>>>>>>9')),'.',',') "</TD>" skip.
                end.
                else put stream v-out unformatted "<TD>" "</TD>" skip.
                i = i + 1.
            end.
            put stream v-out unformatted "</tr>" skip.
        end.
        put stream v-out unformatted "</table>" skip.
        /* пустые строки  */
        put stream v-out unformatted  "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
        put stream v-out unformatted "<tr> </tr>" skip.
         j = 1.
         do while j <= 4.
             i = 1.
             put stream v-out unformatted
                 "<tr>" skip.
             do while i <= 40:
                if j = 1 then do:
                    if i = 1 or i = 5 or i = 9 or i = 13 or i = 17 or i = 21 or i = 25 or i = 29 or i = 33 or i = 37 then put stream v-out unformatted  "<TD bgcolor=""#d8d9db"">  пояснения:  </TD>" skip.
                    else put stream v-out unformatted  "<TD bgcolor=""#d8d9db"">   </TD>" skip.
                end.
                else put stream v-out unformatted  "<TD bgcolor=""#d8d9db"">   </TD>" skip.
                i = i + 1.
            end.
            put stream v-out unformatted "</tr>" skip.
            j = j + 1.
        end.
        put stream v-out unformatted "<tr> </tr>" skip.
        put stream v-out unformatted "<tr> </tr>" skip.
        put stream v-out unformatted "</table>" skip.
        /*---------------------------------------------------------------------*/
        put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

    put stream v-out unformatted
         "<tr><TD  rowspan=2 colspan=4 align=center > Обязательства, всего </TD>" skip
         "<TD colspan=36 align=center > в том числе </TD></tr>" skip

         "<tr><TD colspan=4 align=center> Займы НБРК </TD>" skip
         "<TD colspan=4 align=center > Займы банков </TD>" skip
         "<TD colspan=4 align=center > Вклады банков </TD>" skip
         "<TD colspan=4 align=center > Вклады юрлиц </TD>" skip
         "<TD colspan=4 align=center > Вклады физлиц </TD>" skip
         "<TD colspan=4 align=center > Субординированный долг </TD>" skip
         "<TD colspan=4 align=center > Операции 'РЕПО' с ценными бумагами </TD>" skip
         "<TD colspan=4 align=center > Прочие обязательства </TD>" skip
         "<TD colspan=4 align=center > Капитал </TD></tr>" skip
         "<tr><TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip
         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip
         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD>" skip

         "<TD align=center > сумма </TD>" skip
         "<TD align=center > % </TD>" skip
         "<TD align=center > откл(+/-) </TD>" skip
         "<TD align=center > откл(%)  </TD></tr>" skip.
         i = 1.
         put stream v-out unformatted
             "<tr>" skip.
         do while i <= 40:
             put stream v-out unformatted  "<TD bgcolor=""#d8d9db"">" i "</TD>" skip.
            i = i + 1.
        end.
        put stream v-out unformatted "</tr>" skip.

        for each wrk2 .
            put stream v-out unformatted
                 "<tr>" skip.
             i = 1.
             do while i <= 40:
                if wrk2.sum[i] <> 0 then do:
                    if wrk2.sum[i] - int(entry(1,string(wrk2.sum[i]),".")) <> 0 then put stream v-out unformatted "<TD>" replace(trim(string(wrk2.sum[i],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    else put stream v-out unformatted "<TD>" replace(trim(string(wrk2.sum[i],'->>>>>>>>>>>9')),'.',',') "</TD>" skip.
                end.
                else put stream v-out unformatted "<TD>" "</TD>" skip.
                i = i + 1.
            end.
            put stream v-out unformatted "</tr>" skip.
        end.
        put stream v-out unformatted "</table>" skip.
        /* пустые строки  */
        put stream v-out unformatted  "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
        put stream v-out unformatted "<tr> </tr>" skip.
         j = 1.
         do while j <= 4.
             i = 1.
             put stream v-out unformatted
                 "<tr>" skip.
             do while i <= 40:
                if j = 1 then do:
                    if i = 1 or i = 5 or i = 9 or i = 13 or i = 17 or i = 21 or i = 25 or i = 29 or i = 33 or i = 37 then put stream v-out unformatted  "<TD bgcolor=""#d8d9db"">  пояснения:  </TD>" skip.
                    else put stream v-out unformatted  "<TD bgcolor=""#d8d9db"">   </TD>" skip.
                end.
                else put stream v-out unformatted  "<TD bgcolor=""#d8d9db"">   </TD>" skip.
                i = i + 1.
            end.
            put stream v-out unformatted "</tr>" skip.
            j = j + 1.
        end.
        put stream v-out unformatted "<tr> </tr>" skip.
        put stream v-out unformatted "<tr> </tr>" skip.
        put stream v-out unformatted "</table>" skip.

output stream v-out close.
unix silent cptwin struc.html excel.exe.
pause 0.

if v-ful then do:
    output stream v-ob to ob.html.
    put stream v-ob unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-ob unformatted  "<h3> Расшифровка к отчету Сведения об изменениях в структуре активов, обязательств и капитала с " dt1 " по " dt2 "</h3>" skip.

    put stream v-ob unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-ob unformatted
         "<tr><TD align=center > Филиал <br> </TD>" skip
         "<TD align=center > № транз </TD>" skip
         "<TD align=center > Дата транз</TD>" skip
         "<TD align=center > Шаблон <br> транз </TD>" skip
         "<TD align=center > Дебет <br> счета </TD>" skip
         "<TD align=center > Дебет лицевого <br> счета </TD>" skip
         "<TD align=center > Валюта <br> дебета </TD>" skip
         "<TD  align=center > ДТ Сумма  </TD>" skip
         "<TD  align=center > ДТ Сумма в тенге  </TD>" skip

         "<TD align=center > Кредит <br> счета </TD>" skip
         "<TD align=center > Кредит лицевого <br> счета </TD>" skip
         "<TD align=center > Валюта <br> кредита </TD>" skip
         "<TD  align=center > КТ Сумма  </TD>" skip
         "<TD  align=center > КТ Сумма в тенге  </TD>" skip

         "<TD align=center > Код </TD>" skip
         "<TD  align=center > Кбе  <br> (цен) </TD>" skip
         "<TD  align=center > КНП </TD>" skip
         "<TD  align=center > Назначение транзакции </TD>" skip
         "<TD  align=center > Отправитель </TD>" skip
         "<TD  align=center > Получатель </TD>" skip
         "<TD align=center > Отрасль  <br> экономики  </TD>" skip
         "<TD align=center > Дата открытия  </TD>" skip
         "<TD align=center > Дата закрытия </TD>" skip
         "<TD align=center > sub </TD>" skip
         "<TD align=center > № поз </TD>" skip
         "<TD align=center > AO </TD>" skip.

    for each t-salde .
        put stream v-ob unformatted
        "<tr> <td> " t-salde.txbname "</td>" skip
        "<td> " t-salde.jh "</td>" skip
        "<td> " t-salde.jdt "</td>" skip
        "<td> " t-salde.tmp "</td>" skip
        "<td> " t-salde.dgl "</td>" skip
        "<td> " t-salde.dacc "</td>" skip
        "<td> " t-salde.dcrc "</td>" skip
        "<td> " replace(trim(string(t-salde.dtsum,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.dtsumtng,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " t-salde.cgl "</td>" skip
        "<td> " t-salde.cacc "</td>" skip
        "<td> " t-salde.ccrc "</td>" skip
        "<td> " replace(trim(string(t-salde.ctsum,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.ctsumtng,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " t-salde.cod "</td>" skip
        "<td> " t-salde.kbe "</td>" skip
        "<td> " t-salde.knp "</td>" skip
        "<td> " t-salde.rem "</td>" skip
        "<td> " t-salde.nameo "</td>" skip
        "<td> " t-salde.nameb "</td>" skip
        "<td> " t-salde.secek "</td>" skip
        "<td> " t-salde.dtop "</td>" skip
        "<td> " t-salde.dtcl "</td>" skip
        "<td> " t-salde.sub "</td>" skip
        "<td> " t-salde.poz "</td>" skip
        "<td> " t-salde.ao "</td>" skip
        "</tr>" skip.
    end.
    put stream v-ob unformatted "</table>" skip.
    output stream v-ob close.
    unix silent value("cptwin ob.html excel").
    hide message no-pause.
end.

procedure ImportData:
  INPUT FROM value(RepPath + RepName) NO-ECHO.
  LOOP:
  REPEAT TRANSACTION:
   REPEAT ON ENDKEY UNDO, LEAVE LOOP:
   CREATE tgl.
   IMPORT
     tgl.txb
     tgl.gl
     tgl.gl4
     tgl.gl7
     tgl.gl-des
     tgl.crc
     tgl.sum
     tgl.sum-val
     tgl.type
     tgl.sub-type
     tgl.totlev
     tgl.totgl
     tgl.level
     tgl.code
     tgl.grp
     tgl.acc
     tgl.acc-des
     tgl.geo
     tgl.odt
     tgl.cdt
     tgl.perc
     tgl.prod.
   END. /*REPEAT*/
  END. /*TRANSACTION*/
  input close.
end procedure.

procedure differ:
def input parameter gll as int.
def input parameter dat as date.
def output parameter sum as decim.
sum = 0.
empty temp-table dif.

    def var v-bal as deci.
    def var mesa as integer.
    /*dat = dat - 1.*/

    def var rates as deci extent 20.

    for each crc no-lock:
      find last crchis where crchis.crc = crc.crc and crchis.rdt < dat no-lock no-error.
      rates[crc.crc] = crchis.rate[1].
    end.

    for each gl where gl.subled = 'lon' no-lock:
      for each crc no-lock:
        create dif.
        dif.gl = gl.gl.
        dif.crc = crc.crc.
        find last glday where glday.gl = gl.gl and glday.crc = crc.crc and glday.gdt < dat no-lock no-error.
        if avail glday then do:
          dif.sum_gl = glday.dam - glday.cam.
          dif.sum_gl_kzt = dif.sum_gl * rates[dif.crc].
        end.
      end.
    end.

    mesa = 0.
    for each lon no-lock:

      for each trxbal where trxbal.subled = "lon" and trxbal.acc = lon.lon no-lock:

        find last histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = trxbal.level and histrxbal.crc = trxbal.crc and histrxbal.dt < dat no-lock no-error.
        if avail histrxbal then do:
          if histrxbal.dam - histrxbal.cam = 0 then next.
          find first trxlevgl where trxlevgl.gl = lon.gl and trxlevgl.subled = 'lon' and trxlevgl.level = histrxbal.level no-lock no-error.
          find first dif where dif.gl = trxlevgl.glr and dif.crc = histrxbal.crc no-error.
          dif.sum_lon = dif.sum_lon + histrxbal.dam - histrxbal.cam.
        end.

      end.

      mesa = mesa + 1.
      hide message no-pause.
      message " " mesa " ".

    end. /* for each lon */


    for each dif where dif.gl = gll and dif.crc = 1:
      sum = dif.sum_gl - dif.sum_lon .
    end.
end procedure.