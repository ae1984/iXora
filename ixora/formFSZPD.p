/* lnaudit.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Кредитный портфель для аудита (цикл по всем филиалам)
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
        27/12/2012 id01143 Sayat
 * CHANGES
        24/05/2013 Sayat(id01143) - перекомпиляция в связи с изменением repFS.i по ТЗ 1303 от 01/03/2012
*/

{global.i}
def var d1 as date no-undo.
def new shared var v-reptype as integer no-undo.
def var v-vid as integer no-undo.
def var v-rep as integer no-undo.
def var v-rash as logi.
v-reptype = 1.

{repFS.i "new"}

def new shared var v-sum_msb as deci no-undo.
def new shared var v-pool as char no-undo extent 10.
def new shared var v-poolName as char no-undo extent 10.
def new shared var v-poolId as char no-undo extent 10.
def var rezsum as deci.
def var prcrezafn as deci.
def var sum_od as deci.

def var m as int.
def var i as integer.
def var k as integer.
def var n1 as int.
def var n2 as int.
def var n3 as int.
def var n4 as int.
def var n5 as int.
def var categ as int.
def var k1 as int.
def var k2 as int.
def var k3 as int.
def var k4 as int.
def var k5 as int.
def var sname as char.
def var daypr as int.
def var nzal as int.
def var kol as int.
def var obty as char.
def var m1 as int.
def var vivod as char.

def new shared temp-table FSZPD no-undo
    field num       as int
    field lev       as int extent 5
    field nnum      as char
    field nname     as char
    field odost     as deci extent 8
    field disc      as deci extent 8
    field prcnach   as deci extent 8
    field korrect   as deci extent 8
    field stpriv    as deci extent 8
    field obesp     as deci extent 8
    field odprov    as deci extent 8
    field prcprov   as deci extent 8
    field allprov   as deci extent 8
    index ind1 is primary num.


def var obesmax as deci.
def var target as int.
def var prosr as int.
def var x1 as int.
def var s1 as int.
def var s2 as int.
def var s3 as int.
def var kat as int.

d1 = g-today.
v-reptype = 5.
update d1 label ' На дату' format '99/99/9999' validate (d1 <= g-today, " Дата должна быть не позже текущей!") skip
       /*v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 6, " Тип отчета - 1, 2, 3, 4 или 5") help "1 - Юр, 2 - Физ, 3 - БД, 4 - MCБ, 5 - все"*/
       v-rep label ' Вид отчета '  format "9" validate ( v-rep > 0 and v-rep < 3, " Вид отчета - 1 (ФС_ЗПД) или 2 (ФС_ЗПД_МСФО)") help "1 - ФС_ЗПД, 2 - ФС_ЗПД_МСФО" skip
       v-vid label ' Вид сумм '  format "9" validate ( v-vid > 0 and v-vid < 3, " Вид сумм - 1 (в тенге) или 2 (в тысячах тенге)") help "1 - в тенге, 2 - в тысячах тенге" skip
       v-rash label ' Расшифровка ' format "да/нет"
       skip with side-label row 5 centered frame dat.


def new shared var d-rates as deci no-undo extent 20.
def new shared var c-rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < d1 no-lock no-error.
  if avail crchis then d-rates[crc.crc] = crchis.rate[1].
  c-rates[crc.crc] = crc.rate[1].
end.
empty temp-table wrkFS.

{r-brfilial.i &proc = "rasshlons(d1)"}

i = 0.
empty temp-table FSZPD.
repeat while i < 376:
    i = i + 1.
    sname = " ".
    /*if lookup(string(i),"1,68,135,202,310") > 0 then next.*/
    if i >= 310 then do: n1 = 5. k = 310. end.
    else if i >= 202 then do: n1 = 4. k = 202. end.
         else if i >= 135 then do: n1 = 3. k = 135. end.
              else if i >= 68 then do: n1 = 2. k = 68. end.
                   else do: n1 = 1. k = 1. end.
    if i >= 212 and n1 = 4 then x1 = 8. else x1 = 0.
    n2 = integer(truncate((i - x1 - 1 - k) / 33,0)) + 1.
    s1 = (n2 - 1) * 33 + k + 1.
    if k = 202 and n2 > 1 then s1 = s1 + x1.
    n3 = integer(truncate((i - (s1 + 1)) / 8,0)) + 1.
    s2 = s1 + 1 + (n3 - 1)* 8.
    s3 = i - s2.
    if s3 <= 0 then n4 = 0.
    else if s3 = 1 then n4 = 1. else n4 = 2.
    if s3 - 2 <= 0 then n5 = 0. else n5 = s3 - 2.
    if i = s2 then do: n4 = 0. n5 = 0. end.
    if i = s1 then do: n3 = 0. n4 = 0. n5 = 0. end.
    if i = k then do: n2 = 0. n3 = 0. n4 = 0. n5 = 0. end.



    if n5 = 1 then sname = "От 1 до 15 дней".
    if n5 = 2 then sname = "От 16 до 30 дней".
    if n5 = 3 then sname = "От 31 до 60 дней".
    if n5 = 4 then sname = "От 61 до 90 дней".
    if n5 = 5 then sname = "Более 90 дней".
    if n5 = 0 then do:
        if n4 = 1 then sname = "займы, по которым просроченная задолженность отсутствует".
        if n4 = 2 then sname = "займы, по  которым имеется просроченная задолженность по основному долгу и (или) по начисленному вознаграждению, в том числе:".
        if n4 = 0 then do:
            if n3 = 1 then sname = "–под залог недвижимости".
            if n1 = 4 and n2 = 1 then do:
                if n3 = 2 then sname = "Справочно: обеспеченные ипотекой недвижимого имущества (ипотечные жилищные займы):".
                if n3 = 3 then sname = "–под другое обеспечение".
                if n3 = 4 then sname = "–многозалоговые".
                if n3 = 5 then sname = "–без обеспечения".
            end.
            else do:
                if n3 = 2 then sname = "–под другое обеспечение".
                if n3 = 3 then sname = "–многозалоговые".
                if n3 = 4 then sname = "–без обеспечения".
            end.
            if n3 = 0 then do:
                if n2 = 1 then sname = "на строительство, покупку и/или ремонт жилья, в том числе:".
                if n2 = 2 then
                    if n1 = 4 then sname = "на потребительские цели, в т.ч.".
                    else sname = "на прочие цели, в т.ч.".
                if n2 = 3 then sname = "на прочие цели, в т.ч.".
                if n2 = 0 then do:
                    if n1 = 1 then sname = "Банковские  займы, предоставленные другим банкам и организациям, осуществляющим отдельные виды банковских операций, в том числе:".
                    if n1 = 2 then sname = "Займы, выданные юридическим лицам в т.ч.:".
                    if n1 = 3 then sname = "Займы, выданные субъектам малого и среднего предпринимательства, в т.ч.:".
                    if n1 = 4 then sname = "Займы, выданные физическим лицам, в т.ч.:".
                    if n1 = 5 then sname = "Займы, выданные индивидуальным предпринимателям, в т.ч.:".
                end.
            end.
        end.
    end.
    create FSZPD.
    assign  FSZPD.num = i
            FSZPD.nnum = string(n1) + "." + string(n2) + "." + string(n3) + "." + string(n4) + "." + string(n5)
            FSZPD.nname = sname
            FSZPD.lev[1] = n1
            FSZPD.lev[2] = n2
            FSZPD.lev[3] = n3
            FSZPD.lev[4] = n4
            FSZPD.lev[5] = n5.
end.

create FSZPD.
assign  FSZPD.num = 377
        FSZPD.nnum = "6.0.0.0.0"
        FSZPD.nname = "операции Обратное 'РЕПО'"
        FSZPD.lev[1] = 6
        FSZPD.lev[2] = 0
        FSZPD.lev[3] = 0
        FSZPD.lev[4] = 0
        FSZPD.lev[5] = 0.
create FSZPD.
assign  FSZPD.num = 378
        FSZPD.nnum = "1"
        FSZPD.nname = "Займы, по которым отсутствует просроченная задолженность по основному долгу и/или начисленному вознаграждению ".
create FSZPD.
assign  FSZPD.num = 379
        FSZPD.nnum = "2"
        FSZPD.nname = "Сумма займов, по которым просроченная задолженность составляет от 1 до 15 дней".

create FSZPD.
assign  FSZPD.num = 380
        FSZPD.nnum = "3"
        FSZPD.nname = "Сумма займов, по которым просроченная задолженность составляет от 16 до 30 дней".

create FSZPD.
assign  FSZPD.num = 381
        FSZPD.nnum = "4"
        FSZPD.nname = "Сумма займов, по которым просроченная задолженность составляет от 31 до 60 дней".
create FSZPD.
assign  FSZPD.num = 382
        FSZPD.nnum = "5"
        FSZPD.nname = "Сумма займов, по которым просроченная задолженность составляет от 61 до 90 дней".
create FSZPD.
assign  FSZPD.num = 383
        FSZPD.nnum = "6"
        FSZPD.nname = "Сумма займов, по которым просроченная задолженность составляет свыше 90 дней".
create FSZPD.
assign  FSZPD.num = 384
        FSZPD.nnum = "7"
        FSZPD.nname = "Итого ссудный портфель".

for each wrkFS no-lock:
    if lookup(substring(wrkFS.schet_gk,1,4),"1301,1302,1303,1304,1305,1306,1309,1310,1311,1321,1322,1323,1324,1325,1326,1327,1328") <> 0 then n1 = 1.
    else if lookup(string(wrkFS.grp),"10,50,15") <> 0 then n1 = 2.
        else if lookup(string(wrkFS.grp),"11,14,16,53,54,55,56,70,13") <> 0 then n1 = 3.
            else if lookup(string(wrkFS.grp),"20,60,81,82,90,92,95,96,27,28,67,68") <> 0 then n1 = 4.
                else if lookup(string(wrkFS.grp),"24,26,66,25,64,65,80,63,21,23") <> 0 then n1 = 5.
                    else next.
    if v-rep = 1 then do:
        rezsum = absolute(wrkFS.rezsum_afn).
        sum_od = wrkFS.ostatok_kzt.
    end.
    else do:
        rezsum = absolute(wrkFS.rezsum_msfo).
        sum_od = wrkFS.ostatok_kzt + wrkFS.penalty + wrkFS.nach_prc_kzt.
    end.
    kat = 0.
    if sum_od = 0 then do:
        if rezsum = 0 then kat = 1.
        else kat = 7.
    end.
    else do:
        if round(rezsum / sum_od,3) = 0 then kat = 1.
        if round(rezsum / sum_od,3) > 0 and round(rezsum / sum_od,4) <= 0.05 then kat = 2.
        if round(rezsum / sum_od,4) > 0.05 and round(rezsum / sum_od,4) <= 0.1 then kat = 3.
        if round(rezsum / sum_od,4) > 0.1 and round(rezsum / sum_od,4) <= 0.2 then kat = 4.
        if round(rezsum / sum_od,4) > 0.2 and round(rezsum / sum_od,4) <= 0.25 then kat = 5.
        if round(rezsum / sum_od,4) > 0.25 and round(rezsum / sum_od,4) <= 0.5 then kat = 6.
        if round(rezsum / sum_od,4) > 0.5 then kat = 7.
    end.
    daypr = maximum(wrkFS.dayc_od,wrkFS.dayc_prc).
    if daypr = 0 then prosr = 0.
    else if daypr <= 15 then prosr = 1.
        else if daypr > 15 and daypr <= 30 then prosr = 2.
            else if daypr > 30 and daypr <= 60 then prosr = 3.
                else if daypr > 60 and daypr <= 90 then prosr = 4.
                    else if daypr > 90 then prosr = 5.
    if lookup(wrkFS.tgtc,"12,13,14") <> 0 then target = 1.
    else if lookup(wrkFS.tgtc,"15") <> 0 then target = 2.
        else target = 3.

    if trim(wrkFS.obescod) = "5" or length(trim(wrkFS.obescod)) = 0 then nzal = 4.
    else do:
        obesmax = maximum(0,wrkFS.obessum_kzt[1],wrkFS.obessum_kzt[2],wrkFS.obessum_kzt[3],wrkFS.obessum_kzt[4],wrkFS.obessum_kzt[6]).
        if obesmax <> 0 then do:
            kol = 0.
            if obesmax = wrkFS.obessum_kzt[1] then kol = kol + 1.
            if obesmax = wrkFS.obessum_kzt[2] then kol = kol + 1.
            if obesmax = wrkFS.obessum_kzt[3] then kol = kol + 1.
            if obesmax = wrkFS.obessum_kzt[4] then kol = kol + 1.
            if obesmax = wrkFS.obessum_kzt[6] then kol = kol + 1.
            if kol > 1 then nzal = 3.
            else if obesmax = wrkFS.obessum_kzt[2] then nzal = 1.
            else nzal = 2.
        end.
        else do:
            if lookup("2",wrkFS.obescod) <> 0 then nzal = 1.
            else nzal = 2.
        end.
    end.
    if n1 = 5 then k = 310.
    else if n1 = 4 then k = 202.
         else if n1 = 3 then k = 135.
              else if n1 = 2 then k = 68.
                   else k = 1.
    if target = 1 then n2 = 1.
    else n2 = 2.
    if n1 = 4 then
        if target = 2 then n2 = 2.
        else n2 = 3.

    if n1 = 4 and n2 = 1 and (nzal > 1 or lookup(string(wrkFS.grp),"95,96") <> 0) then n3 = nzal + 1.
    else n3 = nzal.


    if prosr = 0 then do:
        n4 = 1.
        n5 = 0.
    end.
    else do:
        n4 = 2.
        n5 = prosr.
    end.
    if lookup(string(wrkFS.grp),"95,96") <> 0 then do:
        n1 = 4.
        n2 = 1.
        n3 = 2.
        k = 202.
    end.
    if n1 = 4 and n2 > 1 then x1 = 8. else x1 = 0.
    s1 = k + 33 * maximum(n2 - 1,0) + 1 + x1.
    s2 = k + 33 * maximum(n2 - 1,0) + 1 + maximum(n3 - 1,0) * 8 + 1 + x1.
    s3 = k + 33 * maximum(n2 - 1,0) + 1 + maximum(n3 - 1,0) * 8 + 1 + n4 + x1.
    i = k + 33 * maximum(n2 - 1,0) + 1 + 8 * maximum(n3 - 1,0) + 1 + n4 + n5 + x1.
    /*message "i=" + string(i) + ",n1=" + string(n1) + ",n2=" + string(n2) + ",n3=" + string(n3) + ",n4=" + string(n4) + ",n5=" + string(n5)  + ",sum=" + string(wrkFS.ostatok_kzt,"->>>>>>>>>>>>>>>9.99<<<<<<") view-as alert-box.*/
    find first FSZPD where FSZPD.num = i no-error.
    if avail FSZPD then do:
        FSZPD.odost[kat]    = FSZPD.odost[kat] + wrkFS.ostatok_kzt.
        FSZPD.disc[kat]     = FSZPD.disc[kat] + wrkFS.zam_dk.
        FSZPD.prcnach[kat]  = FSZPD.prcnach[kat] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[kat]  = FSZPD.korrect[kat] + 0.
        FSZPD.stpriv[kat]   = FSZPD.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[kat]    = FSZPD.obesp[kat] + wrkFS.obesall.
        FSZPD.odprov[kat]   = FSZPD.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[kat]  = FSZPD.prcprov[kat] + wrkFS.rezsum_prc.
        FSZPD.allprov[kat]  = FSZPD.allprov[kat] + wrkFS.rezsum_afn.
        FSZPD.odost[8]      = FSZPD.odost[8] + wrkFS.ostatok_kzt.
        FSZPD.disc[8]       = FSZPD.disc[8] + wrkFS.zam_dk.
        FSZPD.prcnach[8]    = FSZPD.prcnach[8] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[8]    = FSZPD.korrect[8] + 0.
        FSZPD.stpriv[8]     = FSZPD.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[8]      = FSZPD.obesp[8] + wrkFS.obesall.
        FSZPD.odprov[8]     = FSZPD.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[8]    = FSZPD.prcprov[8] + wrkFS.rezsum_prc.
        FSZPD.allprov[8]    = FSZPD.allprov[8] + wrkFS.rezsum_afn.
    end.
    if i <> s3 then do:
        find first FSZPD where FSZPD.num = s3 no-error.
        if avail FSZPD then do:
            FSZPD.odost[kat]    = FSZPD.odost[kat] + wrkFS.ostatok_kzt.
            FSZPD.disc[kat]     = FSZPD.disc[kat] + wrkFS.zam_dk.
            FSZPD.prcnach[kat]  = FSZPD.prcnach[kat] + wrkFS.nach_prc_kzt.
            FSZPD.korrect[kat]  = FSZPD.korrect[kat] + 0.
            FSZPD.stpriv[kat]   = FSZPD.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
            FSZPD.obesp[kat]    = FSZPD.obesp[kat] + wrkFS.obesall.
            FSZPD.odprov[kat]   = FSZPD.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
            FSZPD.prcprov[kat]  = FSZPD.prcprov[kat] + wrkFS.rezsum_prc.
            FSZPD.allprov[kat]  = FSZPD.allprov[kat] + wrkFS.rezsum_afn.
            FSZPD.odost[8]      = FSZPD.odost[8] + wrkFS.ostatok_kzt.
            FSZPD.disc[8]       = FSZPD.disc[8] + wrkFS.zam_dk.
            FSZPD.prcnach[8]    = FSZPD.prcnach[8] + wrkFS.nach_prc_kzt.
            FSZPD.korrect[8]    = FSZPD.korrect[8] + 0.
            FSZPD.stpriv[8]     = FSZPD.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
            FSZPD.obesp[8]      = FSZPD.obesp[8] + wrkFS.obesall.
            FSZPD.odprov[8]     = FSZPD.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
            FSZPD.prcprov[8]    = FSZPD.prcprov[8] + wrkFS.rezsum_prc.
            FSZPD.allprov[8]    = FSZPD.allprov[8] + wrkFS.rezsum_afn.
        end.
    end.
    find first FSZPD where FSZPD.num = s2 no-error.
    if avail FSZPD then do:
        FSZPD.odost[kat]    = FSZPD.odost[kat] + wrkFS.ostatok_kzt.
        FSZPD.disc[kat]     = FSZPD.disc[kat] + wrkFS.zam_dk.
        FSZPD.prcnach[kat]  = FSZPD.prcnach[kat] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[kat]  = FSZPD.korrect[kat] + 0.
        FSZPD.stpriv[kat]   = FSZPD.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[kat]    = FSZPD.obesp[kat] + wrkFS.obesall.
        FSZPD.odprov[kat]   = FSZPD.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[kat]  = FSZPD.prcprov[kat] + wrkFS.rezsum_prc.
        FSZPD.allprov[kat]  = FSZPD.allprov[kat] + wrkFS.rezsum_afn.
        FSZPD.odost[8]      = FSZPD.odost[8] + wrkFS.ostatok_kzt.
        FSZPD.disc[8]       = FSZPD.disc[8] + wrkFS.zam_dk.
        FSZPD.prcnach[8]    = FSZPD.prcnach[8] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[8]    = FSZPD.korrect[8] + 0.
        FSZPD.stpriv[8]     = FSZPD.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[8]      = FSZPD.obesp[8] + wrkFS.obesall.
        FSZPD.odprov[8]     = FSZPD.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[8]    = FSZPD.prcprov[8] + wrkFS.rezsum_prc.
        FSZPD.allprov[8]    = FSZPD.allprov[8] + wrkFS.rezsum_afn.
    end.
    if s2 = 212 then do:
        find first FSZPD where FSZPD.num = 204 no-error.
        if avail FSZPD then do:
            FSZPD.odost[kat]    = FSZPD.odost[kat] + wrkFS.ostatok_kzt.
            FSZPD.disc[kat]     = FSZPD.disc[kat] + wrkFS.zam_dk.
            FSZPD.prcnach[kat]  = FSZPD.prcnach[kat] + wrkFS.nach_prc_kzt.
            FSZPD.korrect[kat]  = FSZPD.korrect[kat] + 0.
            FSZPD.stpriv[kat]   = FSZPD.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
            FSZPD.obesp[kat]    = FSZPD.obesp[kat] + wrkFS.obesall.
            FSZPD.odprov[kat]   = FSZPD.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
            FSZPD.prcprov[kat]  = FSZPD.prcprov[kat] + wrkFS.rezsum_prc.
            FSZPD.allprov[kat]  = FSZPD.allprov[kat] + wrkFS.rezsum_afn.
            FSZPD.odost[8]      = FSZPD.odost[8] + wrkFS.ostatok_kzt.
            FSZPD.disc[8]       = FSZPD.disc[8] + wrkFS.zam_dk.
            FSZPD.prcnach[8]    = FSZPD.prcnach[8] + wrkFS.nach_prc_kzt.
            FSZPD.korrect[8]    = FSZPD.korrect[8] + 0.
            FSZPD.stpriv[8]     = FSZPD.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
            FSZPD.obesp[8]      = FSZPD.obesp[8] + wrkFS.obesall.
            FSZPD.odprov[8]     = FSZPD.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
            FSZPD.prcprov[8]    = FSZPD.prcprov[8] + wrkFS.rezsum_prc.
            FSZPD.allprov[8]    = FSZPD.allprov[8] + wrkFS.rezsum_afn.
        end.
    end.
    /*if s1 <> 203 then do:*/
        find first FSZPD where FSZPD.num = s1 no-error.
        if avail FSZPD then do:
            FSZPD.odost[kat]    = FSZPD.odost[kat] + wrkFS.ostatok_kzt.
            FSZPD.disc[kat]     = FSZPD.disc[kat] + wrkFS.zam_dk.
            FSZPD.prcnach[kat]  = FSZPD.prcnach[kat] + wrkFS.nach_prc_kzt.
            FSZPD.korrect[kat]  = FSZPD.korrect[kat] + 0.
            FSZPD.stpriv[kat]   = FSZPD.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
            FSZPD.obesp[kat]    = FSZPD.obesp[kat] + wrkFS.obesall.
            FSZPD.odprov[kat]   = FSZPD.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
            FSZPD.prcprov[kat]  = FSZPD.prcprov[kat] + wrkFS.rezsum_prc.
            FSZPD.allprov[kat]  = FSZPD.allprov[kat] + wrkFS.rezsum_afn.
            FSZPD.odost[8]      = FSZPD.odost[8] + wrkFS.ostatok_kzt.
            FSZPD.disc[8]       = FSZPD.disc[8] + wrkFS.zam_dk.
            FSZPD.prcnach[8]    = FSZPD.prcnach[8] + wrkFS.nach_prc_kzt.
            FSZPD.korrect[8]    = FSZPD.korrect[8] + 0.
            FSZPD.stpriv[8]     = FSZPD.stpriv[8] + + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
            FSZPD.obesp[8]      = FSZPD.obesp[8] + wrkFS.obesall.
            FSZPD.odprov[8]     = FSZPD.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
            FSZPD.prcprov[8]    = FSZPD.prcprov[8] + wrkFS.rezsum_prc.
            FSZPD.allprov[8]    = FSZPD.allprov[8] + wrkFS.rezsum_afn.
        end.
    /*end.*/
    find first FSZPD where FSZPD.num = k no-error.
    if avail FSZPD then do:
        FSZPD.odost[kat]    = FSZPD.odost[kat] + wrkFS.ostatok_kzt.
        FSZPD.disc[kat]     = FSZPD.disc[kat] + wrkFS.zam_dk.
        FSZPD.prcnach[kat]  = FSZPD.prcnach[kat] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[kat]  = FSZPD.korrect[kat] + 0.
        FSZPD.stpriv[kat]   = FSZPD.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[kat]    = FSZPD.obesp[kat] + wrkFS.obesall.
        FSZPD.odprov[kat]   = FSZPD.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[kat]  = FSZPD.prcprov[kat] + wrkFS.rezsum_prc.
        FSZPD.allprov[kat]  = FSZPD.allprov[kat] + wrkFS.rezsum_afn.
        FSZPD.odost[8]      = FSZPD.odost[8] + wrkFS.ostatok_kzt.
        FSZPD.disc[8]       = FSZPD.disc[8] + wrkFS.zam_dk.
        FSZPD.prcnach[8]    = FSZPD.prcnach[8] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[8]    = FSZPD.korrect[8] + 0.
        FSZPD.stpriv[8]     = FSZPD.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[8]      = FSZPD.obesp[8] + wrkFS.obesall.
        FSZPD.odprov[8]     = FSZPD.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[8]    = FSZPD.prcprov[8] + wrkFS.rezsum_prc.
        FSZPD.allprov[8]    = FSZPD.allprov[8] + wrkFS.rezsum_afn.
    end.
    find first FSZPD where FSZPD.num = 378 + n5 no-error.
    if avail FSZPD then do:
        FSZPD.odost[kat]    = FSZPD.odost[kat] + wrkFS.ostatok_kzt.
        FSZPD.disc[kat]     = FSZPD.disc[kat] + wrkFS.zam_dk.
        FSZPD.prcnach[kat]  = FSZPD.prcnach[kat] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[kat]  = FSZPD.korrect[kat] + 0.
        FSZPD.stpriv[kat]   = FSZPD.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[kat]    = FSZPD.obesp[kat] + wrkFS.obesall.
        FSZPD.odprov[kat]   = FSZPD.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[kat]  = FSZPD.prcprov[kat] + wrkFS.rezsum_prc.
        FSZPD.allprov[kat]  = FSZPD.allprov[kat] + wrkFS.rezsum_afn.
        FSZPD.odost[8]      = FSZPD.odost[8] + wrkFS.ostatok_kzt.
        FSZPD.disc[8]       = FSZPD.disc[8] + wrkFS.zam_dk.
        FSZPD.prcnach[8]    = FSZPD.prcnach[8] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[8]    = FSZPD.korrect[8] + 0.
        FSZPD.stpriv[8]     = FSZPD.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[8]      = FSZPD.obesp[8] + wrkFS.obesall.
        FSZPD.odprov[8]     = FSZPD.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[8]    = FSZPD.prcprov[8] + wrkFS.rezsum_prc.
        FSZPD.allprov[8]    = FSZPD.allprov[8] + wrkFS.rezsum_afn.
    end.
    find first FSZPD where FSZPD.num = 384 no-error.
    if avail FSZPD then do:
        FSZPD.odost[kat]    = FSZPD.odost[kat] + wrkFS.ostatok_kzt.
        FSZPD.disc[kat]     = FSZPD.disc[kat] + wrkFS.zam_dk.
        FSZPD.prcnach[kat]  = FSZPD.prcnach[kat] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[kat]  = FSZPD.korrect[kat] + 0.
        FSZPD.stpriv[kat]   = FSZPD.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[kat]    = FSZPD.obesp[kat] + wrkFS.obesall.
        FSZPD.odprov[kat]   = FSZPD.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[kat]  = FSZPD.prcprov[kat] + wrkFS.rezsum_prc.
        FSZPD.allprov[kat]  = FSZPD.allprov[kat] + wrkFS.rezsum_afn.
        FSZPD.odost[8]      = FSZPD.odost[8] + wrkFS.ostatok_kzt.
        FSZPD.disc[8]       = FSZPD.disc[8] + wrkFS.zam_dk.
        FSZPD.prcnach[8]    = FSZPD.prcnach[8] + wrkFS.nach_prc_kzt.
        FSZPD.korrect[8]    = FSZPD.korrect[8] + 0.
        FSZPD.stpriv[8]     = FSZPD.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSZPD.obesp[8]      = FSZPD.obesp[8] + wrkFS.obesall.
        FSZPD.odprov[8]     = FSZPD.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSZPD.prcprov[8]    = FSZPD.prcprov[8] + wrkFS.rezsum_prc.
        FSZPD.allprov[8]    = FSZPD.allprov[8] + wrkFS.rezsum_afn.
    end.
end.

if v-vid = 1 then do:
    m = 1.
    m1 = 2.
    vivod = '->>>>>>>>>>>>>>9.99'.
end.
else do:
    m = 1000.
    m1 = 0.
    vivod = '->>>>>>>>>>>>>>9'.
end.

define stream m-out.
output stream m-out to formFSZPD.htm.

put stream m-out unformatted "<html><head><title>FORTEBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
if v-rep = 1 then do:
    put stream m-out unformatted "<br><br><h3 h3 colspan=20 align=""center"">Займы, по которым имеется просроченная  задолженность  по основному долгу и/или по начисленному вознаграждению в деталях'</h3><br>" skip.
    put stream m-out unformatted "<br><br><h3 h3 colspan=20 align=""center"">АО 'ForteBank'</h3><br>" skip.
    put stream m-out unformatted "<h3 colspan=20 align=""center"">Отчет на " string(d1,"99/99/9999") "</h3><br><br>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                        "<tr style=""font:bold"">"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>№</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Наименование</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Стандартные</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Сомнительные</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Провизии</td>"
                        "<td colspan=10 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>в том числе:</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Безнадеждные</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Итого</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Всего провизии</td>"
                        skip.
    put stream m-out unformatted "<tr style=""font:bold"">"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 1 категории</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 2 категории</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 3 категории</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 4 категории</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 5 категории</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td></tr>" skip.
end.
if v-rep = 2 then do:
    put stream m-out unformatted "<br><br><h3 h3 colspan=20 align=""center"">Сведения о займах, по которым имеется просроченная задолженность по основному долгу и (или) по начисленному вознаграждению в деталях, а также о размере провизий (резервов) сформированных в соответствии с международными стандартами финансовой отчетности'</h3><br>" skip.
    put stream m-out unformatted "<br><br><h3 h3 colspan=20 align=""center"">АО 'ForteBank'</h3><br>" skip.
    put stream m-out unformatted "<h3 colspan=20 align=""center"">Отчет на " string(d1,"99/99/9999") "</h3><br><br>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                        "<tr style=""font:bold"">"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=4>№</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=4>Наименование</td>"
                        "<td colspan=8 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Стандартные</td>"
                        "<td colspan=40 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные</td>"
                        "<td colspan=8 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Безнадежные (в случае начисления провизий в размере 100%)</td>"
                        "<td colspan=8 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Всего</td></tr>" skip.
    put stream m-out unformatted "<tr style=""font:bold"">"
                        "<td colspan=8 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 1 категории (в случае начисления провизий в размере до 5%)</td>"
                        "<td colspan=8 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 2 категории (в случае начисления провизий в размере от 5% до 10%)</td>"
                        "<td colspan=8 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 3 категории (в случае начисления провизий в размере от 10% до 20%)</td>"
                        "<td colspan=8 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 4 категории (в случае начисления провизий в размере от 20% до 25%)</td>"
                        "<td colspan=8 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Сомнительные 5 категории (в случае начисления провизий в размере от 25% до 50%)</td></tr>"
                        skip.
    put stream m-out unformatted "<tr style=""font:bold"">"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Основной долг</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт, премия</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленное вознаграждение</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Положительная/отрицательная корректировкаи</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Справочно: стоимость обеспечения включаемая в расчет</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Основной долг</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт, премия</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленное вознаграждение</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Положительная/отрицательная корректировкаи</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Справочно: стоимость обеспечения включаемая в расчет</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Основной долг</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт, премия</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленное вознаграждение</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Положительная/отрицательная корректировкаи</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Справочно: стоимость обеспечения включаемая в расчет</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Основной долг</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт, премия</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленное вознаграждение</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Положительная/отрицательная корректировкаи</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Справочно: стоимость обеспечения включаемая в расчет</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Основной долг</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт, премия</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленное вознаграждение</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Положительная/отрицательная корректировкаи</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Справочно: стоимость обеспечения включаемая в расчет</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Основной долг</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт, премия</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленное вознаграждение</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Положительная/отрицательная корректировкаи</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Справочно: стоимость обеспечения включаемая в расчет</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Основной долг</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт, премия</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленное вознаграждение</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Положительная/отрицательная корректировкаи</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Справочно: стоимость обеспечения включаемая в расчет</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Основной долг</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт, премия</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленное вознаграждение</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Положительная/отрицательная корректировкаи</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Справочно: стоимость обеспечения включаемая в расчет</td>"
                        "<td colspan=2 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>Провизии</td></tr>"
                        skip.
    put stream m-out unformatted "<tr style=""font:bold"">"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По основному долгу</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По начисленному вознаграждению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По основному долгу</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По начисленному вознаграждению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По основному долгу</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По начисленному вознаграждению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По основному долгу</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По начисленному вознаграждению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По основному долгу</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По начисленному вознаграждению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По основному долгу</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По начисленному вознаграждению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По основному долгу</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По начисленному вознаграждению</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По основному долгу</td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>По начисленному вознаграждению</td></tr>"
                        skip.
    put stream m-out unformatted "<tr style=""font:bold"">"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1></td>"
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1></td>".
    i = 0.
    repeat while i < 63:
        i = i + 1.
        put stream m-out unformatted
                        "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>" i "</td>".
    end.

    put stream m-out unformatted "<td colspan=1 bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=1>64</td></tr>"
                        skip.
end.

for each FSZPD no-lock by FSZPD.num:

    put stream m-out unformatted
            "<tr>" skip
            "<td align=""left"">" "'" + replace(FSZPD.nnum,".0"," ") "</td>" skip
            "<td>" FSZPD.nname "</td>" skip.
    if v-rep = 1 then do:
        put stream m-out unformatted
                "<td align=""right"">" replace(trim(string(round(FSZPD.odost[1] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round((FSZPD.odost[2] + FSZPD.odost[3] + FSZPD.odost[4] + FSZPD.odost[5] + FSZPD.odost[6]) / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round((FSZPD.allprov[2] + FSZPD.allprov[3] + FSZPD.allprov[4] + FSZPD.allprov[5] + FSZPD.allprov[6]) / m,m1),vivod)),'.',',') "</td>" skip.
        repeat i = 2 to 8 by 1:
            put stream m-out unformatted
                "<td align=""right"">" replace(trim(string(round(FSZPD.odost[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSZPD.allprov[i] / m,m1),vivod)),'.',',') "</td>" skip.
        end.
    end.
    else repeat i = 1 to 8 by 1:
        put stream m-out unformatted
                "<td align=""right"">" replace(trim(string(round(FSZPD.odost[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSZPD.disc[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSZPD.prcnach[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSZPD.korrect[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSZPD.stpriv[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSZPD.obesp[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSZPD.odprov[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSZPD.prcprov[i] / m,m1),vivod)),'.',',') "</td>" skip.
    end.
    put stream m-out unformatted "</tr>" skip.
end.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin formFSZPD.htm excel.

m = 1.
m1 = 2.
vivod = '->>>>>>>>>>>>>>9.99'.
if v-rash then do:
    define stream m-out1.
    output stream m-out1 to formFSZPDrassh.htm.
    put stream m-out1 unformatted "<html><head><title>FORTEBANK</title>"
                    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out1 unformatted "<br><br><h3 h3 colspan=20 align=""center"">Стандартные и классифицированные банковские займы по видам экономической деятельности'</h3><br>" skip.
    put stream m-out1 unformatted "<br><br><h3 h3 colspan=20 align=""center"">АО 'ForteBank'</h3><br>" skip.
    put stream m-out1 unformatted "<h3 colspan=20 align=""center"">Отчет на " string(d1) "</h3><br><br>" skip.

    put stream m-out1 unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                    "<tr style=""font:bold"">"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">N бал. счета</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Наименование заемщика</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Код<BR>заемщика</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Филиал</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Пул МСФО</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Группа</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">N договора<BR>банк. займа</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Объект<BR>кредитования</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта<BR>кредита</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата<BR>выдачи</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Срок<BR>погашения</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата<BR>пролонгации</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дней<BR>просрочки ОД</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Код просрочки</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дней<BR>просрочки %</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Остаток ОД<BR>(в тенге)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Проср. ОД(в тенге)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Начисл. %<BR>(в тенге)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Проср. %<BR>(в тенге)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Штрафы</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дисконт<BR>по займам</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">%<BR>резерва</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв АФН(KZT)<BR>(1428+3305)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв АФН(KZT)<BR> (9100) </td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв МСФО ОД,<BR>(KZT)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв МСФО %%,<BR>(KZT)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резерв МСФО Пеня,<BR>(KZT)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Общая сумма резерва МСФО,<BR>(KZT)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Истор.ставка</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Вид залога</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Общая сумма залога</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма залога, недвижимость</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма залога, вклад</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма залога, гарантия</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма залога, прочее</td></tr>" skip.
    i = 0.
    for each wrkFS no-lock  by wrkFS.cif:

        if lookup(substring(wrkFS.schet_gk,1,4),"1301,1302,1303,1304,1305,1306,1309,1310,1311,1321,1322,1323,1324,1325,1326,1327,1328") <> 0 then n1 = 1.
        else if lookup(string(wrkFS.grp),"10,50,15") <> 0 then n1 = 2.
            else if lookup(string(wrkFS.grp),"11,13,14,16,53,54,55,56,70") <> 0 then n1 = 3.
                else if lookup(string(wrkFS.grp),"20,60,81,82,90,92,95,96,27,28,67,68") <> 0 then n1 = 4.
                    else if lookup(string(wrkFS.grp),"26,66,25,64,65,80,24,63,21,23") <> 0 then n1 = 5.
        if v-rep = 1 then do:
            rezsum = absolute(wrkFS.rezsum_afn).
            sum_od = wrkFS.ostatok_kzt.
        end.
        else do:
            rezsum = absolute(wrkFS.rezsum_msfo).
            sum_od = wrkFS.ostatok_kzt + wrkFS.penalty + wrkFS.nach_prc_kzt.
        end.
        kat = 0.
        if sum_od = 0 then do:
            if rezsum = 0 then kat = 1.
            else kat = 7.
        end.
        else do:
            if round(rezsum / sum_od,3) = 0 then kat = 1.
            if round(rezsum / sum_od,3) > 0 and round(rezsum / sum_od,4) <= 0.05 then kat = 2.
            if round(rezsum / sum_od,4) > 0.05 and round(rezsum / sum_od,4) <= 0.1 then kat = 3.
            if round(rezsum / sum_od,4) > 0.1 and round(rezsum / sum_od,4) <= 0.2 then kat = 4.
            if round(rezsum / sum_od,4) > 0.2 and round(rezsum / sum_od,4) <= 0.25 then kat = 5.
            if round(rezsum / sum_od,4) > 0.25 and round(rezsum / sum_od,4) <= 0.5 then kat = 6.
            if round(rezsum / sum_od,4) > 0.5 then kat = 7.
        end.
        daypr = maximum(wrkFS.dayc_od,wrkFS.dayc_prc).
        if daypr = 0 then prosr = 0.
        else if daypr <= 15 then prosr = 1.
            else if daypr > 15 and daypr <= 30 then prosr = 2.
                else if daypr > 30 and daypr <= 60 then prosr = 3.
                    else if daypr > 60 and daypr <= 90 then prosr = 4.
                        else if daypr > 90 then prosr = 5.
        if lookup(wrkFS.tgtc,"12,13,14") <> 0 then target = 1.
        else if lookup(wrkFS.tgtc,"15") <> 0 then target = 2.
            else target = 3.

        if trim(wrkFS.obescod) = "5" or length(trim(wrkFS.obescod)) = 0 then nzal = 4.
        else do:
            obesmax = maximum(0,wrkFS.obessum_kzt[1],wrkFS.obessum_kzt[2],wrkFS.obessum_kzt[3],wrkFS.obessum_kzt[4],wrkFS.obessum_kzt[6]).
            if obesmax <> 0 then do:
                kol = 0.
                if obesmax = wrkFS.obessum_kzt[1] then kol = kol + 1.
                if obesmax = wrkFS.obessum_kzt[2] then kol = kol + 1.
                if obesmax = wrkFS.obessum_kzt[3] then kol = kol + 1.
                if obesmax = wrkFS.obessum_kzt[4] then kol = kol + 1.
                if obesmax = wrkFS.obessum_kzt[6] then kol = kol + 1.
                if kol > 1 then nzal = 3.
                else if obesmax = wrkFS.obessum_kzt[2] then nzal = 1.
                    else nzal = 2.
            end.
            else do:
                if lookup("2",wrkFS.obescod) <> 0 then nzal = 1.
                else nzal = 2.
            end.
        end.
        if n1 = 5 then k = 310.
        else if n1 = 4 then k = 202.
            else if n1 = 3 then k = 135.
                else if n1 = 2 then k = 68.
                    else k = 1.
        if target = 1 then n2 = 1.
        else n2 = 2.
        if n1 = 4 then
            if target = 2 then n2 = 2.
            else n2 = 3.
        if n1 = 4 and n2 = 1 and (nzal > 1 or lookup(string(wrkFS.grp),"95,96") <> 0) then n3 = nzal + 1.
        else n3 = nzal.
        if prosr = 0 then do:
            n4 = 1.
            n5 = 0.
        end.
        else do:
            n4 = 2.
            n5 = prosr.
        end.
        if lookup(string(wrkFS.grp),"95,96") <> 0 then do:
            n1 = 4.
            n2 = 1.
            n3 = 2.
            k = 202.
        end.
        if n1 = 4 and n2 > 1 then x1 = 8. else x1 = 0.
        s1 = k + 33 * maximum(n2 - 1,0) + 1 + x1.
        s2 = k + 33 * maximum(n2 - 1,0) + 1 + maximum(n3 - 1,0) * 8 + 1 + x1.
        s3 = k + 33 * maximum(n2 - 1,0) + 1 + maximum(n3 - 1,0) * 8 + 1 + n4 + x1.
        i = k + 33 * maximum(n2 - 1,0) + 1 + 8 * maximum(n3 - 1,0) + 1 + n4 + n5 + x1.
        /*message "i=" + string(i) + ",n1=" + string(n1) + ",n2=" + string(n2) + ",n3=" + string(n3) + ",n4=" + string(n4) + ",n5=" + string(n5) view-as alert-box.*/
        /*i = i + 1.*/
        find first crc where crc.crc = wrkFS.crc no-lock no-error.
        if wrkFS.ostatok_kzt = 0 then prcrezafn = 0. else prcrezafn = 100 * rezsum / sum_od.
        daypr = maximum(wrkFS.dayc_od,wrkFS.dayc_prc).
        if daypr = 0 then prosr = 0.
        else if daypr <= 15 then prosr = 1.
            else if daypr > 15 and daypr <= 30 then prosr = 2.
                else if daypr > 30 and daypr <= 60 then prosr = 3.
                    else if daypr > 60 and daypr <= 90 then prosr = 4.
                        else if daypr > 90 then prosr = 5.
        put stream m-out1 unformatted
            "<tr>" skip
            "<td>" i "</td>" skip
            "<td align=""center"">" wrkFS.schet_gk "</td>" skip
            "<td>" wrkFS.name "</td>" skip
            "<td>" wrkFS.cif "</td>" skip
            "<td>" wrkFS.bankn "</td>" skip
            "<td></td>" skip
            "<td>" wrkFS.grp "</td>" skip
            "<td>&nbsp;" wrkFS.num_dog "</td>" skip
            "<td>" wrkFS.tgt "</td>" skip
            "<td align=""center"">" crc.code "</td>" skip
            "<td>" wrkFS.isdt format "99/99/9999" "</td>" skip
            "<td>" wrkFS.duedt format "99/99/9999" "</td>" skip
            "<td>" wrkFS.dprolong format "99/99/9999" "</td>" skip
            "<td align=""right"">" wrkFS.dayc_od  "</td>" skip
            "<td align=""right"">" prosr  "</td>" skip
            "<td align=""right"">" wrkFS.dayc_prc  "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.ostatok_kzt / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.prosr_od_kzt / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.nach_prc_kzt / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.prosr_prc_kzt / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.penalty / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.zam_dk / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(prcrezafn,4),'->>>>>9.99<<')),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_afn / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_afn41 / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_od / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_prc / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_pen / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.rezsum_msfo / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.prem_his / m,m1),'->>9.99')),'.',',') "</td>" skip
            "<td>" wrkFS.obesdes "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.obesall / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.obessum_kzt[2] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.obessum_kzt[3] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round(wrkFS.obessum_kzt[6] / m,m1),vivod)),'.',',') "</td>" skip
            "<td align=""right"">" replace(trim(string(round((wrkFS.obessum_kzt[1] + wrkFS.obessum_kzt[4] + wrkFS.obessum_kzt[5]) / m,m1),vivod)),'.',',') "</td>" skip
            "<td>" n1 "</td>" skip
            "<td>" n2 "</td>" skip
            "<td>" n3 "</td>" skip
            "<td>" n4 "</td>" skip
            "<td>" n5 "</td>" skip
            "<td>" kat "</td>" skip
            "</tr>" skip.
    end.
    put stream m-out1 "</table></body></html>" skip.
    output stream m-out1 close.
    hide message no-pause.
    unix silent cptwin formFSZPDrassh.htm excel.
end.
