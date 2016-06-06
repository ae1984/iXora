/* formFSPZOMSFO.p
 * MODULE
        Внутренние операции
 * DESCRIPTION
        Сведения о займах, в том числе и выданных субъектам малого и среднего предпринимательства резидентам Республики Казахстан, по которым имеется просроченная задолженность по основному долгу и (или) начисленному вознаграждению, по отраслям и условные и возможные обязательства, а также о размере провизий (резервов) сформированных в соответствии с международными стандартами финансовой отчетности
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
        24/05/2013 sayat(id01143) - ТЗ 1303 от 01/03/2012 "Автоматизация отчетов «Сведения о займах, по которым имеется просроченная задолженность по основному долгу и (или) начисленному вознаграждению, по отраслям и условные и возможные обязательства, а также о размере провизий (резервов) сформированных в соответствии с международными стандартами финансовой отчетности» ФС_ПЗО_МСФО
                   «Сведения о займах, выданных субъектам малого и среднего предпринимательства резидентам Республики Казахстан, по которым имеется просроченная задолженность по основному долгу и (или) начисленному вознаграждению, по отраслям и условные и возможные обязательства, а также о размере провизий (резервов) сформированных в соответствии с международными стандартами финансовой отчетности» ФС_ПЗО_СМП_МСФО"
 * BASES
	    BANK COMM
 * CHANGES
        25.09.2013 damir - Внедрено Т.З. № 1869.
        07.11.2013 damir - Внедрено Т.З. № 2163.
*/

{global.i}
def var d1 as date no-undo.
def new shared var v-reptype as integer no-undo.
def var v-vid as integer no-undo init 1.
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

def new shared temp-table FSPZOMSFO no-undo
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

{stat.i "new"}

def new shared temp-table t-wrk no-undo
    field num as inte
    field nnum as char
    field nname as char
    field id_pokaz as char
    field znac as deci extent 64
index idx1 is primary num.

def temp-table t-temp no-undo
    field i as inte
    field id as inte
    field znac as deci
index idx1 is primary i ascending.

def var obesmax as deci.
def var target as int.
def var prosr as int.
def var x1 as int.
def var s1 as int.
def var s2 as int.
def var s3 as int.
def var kat as int.
def var v-RepTyp as char.
def var j as inte.
def var p as inte.
def var v-zo as logi.

def new shared var d-rates as deci no-undo extent 20.
def new shared var c-rates as deci no-undo extent 20.

define stream m-out.
define stream m-out1.

def sub-menu m-f1
    menu-item m-gen label "Сформировать отчет".

def sub-menu m-f2
    menu-item m-load label "Загрузить в АИС <Статистика>".

def sub-menu m-f3
    menu-item m-exit label "Выход".

def menu m-stat menubar
    sub-menu m-f1 label "Сформировать отчет"
    sub-menu m-f2 label "Загрузить в АИС <Статистика>"
    sub-menu m-f3 label "Выход".

on choose of menu-item m-gen do:

empty temp-table FSPZOMSFO.
empty temp-table t-wrk.

d1 = g-today.
v-zo = false.
update d1     label ' На дату                ' format '99/99/9999' /*validate (d1 <= g-today, " Дата должна быть не позже текущей!")*/ skip
       /*v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 6, " Тип отчета - 1, 2, 3, 4 или 5") help "1 - Юр, 2 - Физ, 3 - БД, 4 - MCБ, 5 - все"*/
       v-rep  label ' Вид отчета             '  format "9" validate ( v-rep > 0 and v-rep < 3, " Вид отчета - 1 или 2") help "1 - Все (fs_pzo_msfo), 2 - СМП (fs_pzo_smp_msfo)" skip
       v-vid  label ' Вид сумм               '  format "9" validate ( v-vid > 0 and v-vid < 3, " Вид сумм - 1 или 2") help "1 - в тенге, 2 - в тысячах тенге" skip
       v-rash label ' Расшифровка            ' format "да/нет" skip
       v-zo   label " Заключ.обор.(Статист.) " format "да/нет" skip
with side-label row 5 centered frame dat.

message "Ждите,идет формирование отчета...".

if v-rep = 2 then do:
    v-reptype = 4.
    v-RepTyp = "fs_pzo_smp_msfo".
end.
else do:
    v-reptype = 5.
    v-RepTyp = "fs_pzo_msfo".
end.

for each bank.crc no-lock:
  find last bank.crchis where bank.crchis.crc = bank.crc.crc and bank.crchis.rdt < d1 no-lock no-error.
  if avail bank.crchis then d-rates[bank.crc.crc] = bank.crchis.rate[1].
  c-rates[bank.crc.crc] = bank.crc.rate[1].
end.
empty temp-table wrkFS.

{r-brfilial.i &proc = "rasshlons(d1)"}

i = 0.
repeat while i < 168:
    i = i + 1.
    sname = " ".
    n1 = integer(truncate((i - 1)/ 8,0) + 1).
    s1 = i - (n1 - 1)* 8.
    case s1:
        when 1 then do: n2 = 0. n3 = 0. end.
        when 2 then do: n2 = 1. n3 = 0. end.
        when 3 then do: n2 = 2. n3 = 0. end.
        when 4 then do: n2 = 2. n3 = 1. end.
        when 5 then do: n2 = 2. n3 = 2. end.
        when 6 then do: n2 = 2. n3 = 3. end.
        when 7 then do: n2 = 2. n3 = 4. end.
        when 8 then do: n2 = 2. n3 = 5. end.
    end case.
    if n3 = 1 then sname = "От 1 до 15 дней".
    if n3 = 2 then sname = "От 16 до 30 дней".
    if n3 = 3 then sname = "От 31 до 60 дней".
    if n3 = 4 then sname = "От 61 до 90 дней".
    if n3 = 5 then sname = "Более 90 дней".
    if n3 = 0 then do:
        if n2 = 1 then sname = "займы, по которым просроченная задолженность отсутствует".
        if n2 = 2 then sname = "займы, по  которым имеется просроченная задолженность по основному долгу и (или) по начисленному вознаграждению, в том числе:".
        if n2 = 0 then do:
            case n1:
                when 1 then sname = "СЕЛЬСКОЕ, ЛЕСНОЕ И РЫБНОЕ ХОЗЯЙСТВО".
                when 2 then sname = "ГОРНОДОБЫВАЮЩАЯ ПРОМЫШЛЕННОСТЬ И РАЗРАБОТКА КАРЬЕРОВ".
                when 3 then sname = "ОБРАБАТЫВАЮЩАЯ ПРОМЫШЛЕННОСТЬ".
                when 4 then sname = "ЭЛЕКТРОСНАБЖЕНИЕ, ПОДАЧА ГАЗА, ПАРА И ВОЗДУШНОЕ  КОНДИЦИОНИРОВАНИЕ".
                when 5 then sname = "ВОДОСНАБЖЕНИЕ; КАНАЛИЗАЦИОННАЯ СИСТЕМА, КОНТРОЛЬ НАД СБОРОМ И РАСПРЕДЕЛЕНИЕМ ОТХОДОВ".
                when 6 then sname = "СТРОИТЕЛЬСТВО".
                when 7 then sname = "ОПТОВАЯ И РОЗНИЧНАЯ ТОРГОВЛЯ; РЕМОНТ АВТОМОБИЛЕЙ И МОТОЦИКЛОВ".
                when 8 then sname = "ТРАНСПОРТ И СКЛАДИРОВАНИЕ".
                when 9 then sname = "УСЛУГИ ПО ПРОЖИВАНИЮ И ПИТАНИЮ".
                when 10 then sname = "ИНФОРМАЦИЯ И СВЯЗЬ".
                when 11 then sname = "ФИНАНСОВАЯ И СТРАХОВАЯ ДЕЯТЕЛЬНОСТЬ".
                when 12 then sname = "ОПЕРАЦИИ С НЕДВИЖИМЫМ ИМУЩЕСТВОМ".
                when 13 then sname = "ПРОФЕССИОНАЛЬНАЯ, НАУЧНАЯ И ТЕХНИЧЕСКАЯ ДЕЯТЕЛЬНОСТЬ".
                when 14 then sname = "ДЕЯТЕЛЬНОСТЬ В ОБЛАСТИ АДМИНИСТРАТИВНОГО И ВСПОМОГАТЕЛЬНОГО ОБСЛУЖИВАНИЯ".
                when 15 then sname = "ГОСУДАРСТВЕННОЕ УПРАВЛЕНИЕ И ОБОРОНА; ОБЯЗАТЕЛЬНОЕ  СОЦИАЛЬНОЕ ОБЕСПЕЧЕНИЕ".
                when 16 then sname = "ОБРАЗОВАНИЕ".
                when 17 then sname = "ЗДРАВООХРАНЕНИЕ И СОЦИАЛЬНЫЕ УСЛУГИ".
                when 18 then sname = "ИСКУССТВО, РАЗВЛЕЧЕНИЯ И ОТДЫХ".
                when 19 then sname = "ПРЕДОСТАВЛЕНИЕ ПРОЧИХ ВИДОВ УСЛУГ".
                when 20 then sname = "ДЕЯТЕЛЬНОСТЬ ДОМАШНИХ ХОЗЯЙСТВ, НАНИМАЮЩИХ ДОМАШНЮЮ ПРИСЛУГУ И ПРОИЗВОДЯЩИХ ТОВАРЫ И УСЛУГИ ДЛЯ СОБСТВЕННОГО ПОТРЕБЛЕНИЯ".
                when 21 then sname = "ДЕЯТЕЛЬНОСТЬ ЭКСТЕРРИТОРИАЛЬНЫХ ОРГАНИЗАЦИЙ И ОРГАНОВ".
            end case.
        end.
    end.

    create FSPZOMSFO.
    assign  FSPZOMSFO.num = i
            FSPZOMSFO.nnum = string(n1) + "." + string(n2) + "." + string(n3)
            FSPZOMSFO.nname = sname
            FSPZOMSFO.lev[1] = n1
            FSPZOMSFO.lev[2] = n2
            FSPZOMSFO.lev[3] = n3.

    create t-wrk.
    t-wrk.num = i.
    t-wrk.nnum = string(n1) + "." + string(n2) + "." + string(n3).
    t-wrk.nnum = replace(t-wrk.nnum,".0"," ").
    t-wrk.nname = sname.
end.

create FSPZOMSFO.
assign  FSPZOMSFO.num = 169
        FSPZOMSFO.nnum = " "
        FSPZOMSFO.nname = "Всего"
        FSPZOMSFO.lev[1] = 0
        FSPZOMSFO.lev[2] = 0
        FSPZOMSFO.lev[3] = 0.

create t-wrk.
    t-wrk.num = 169.
    t-wrk.nnum = " ".
    t-wrk.nname = "Всего".

for each wrkFS no-lock:
    if lookup(wrkFS.okedlon,"0,msc") <> 0 then next.
        else if lookup(wrkFS.okedlon,"01,02,03") <> 0 then n1 = 1.
            else if lookup(wrkFS.okedlon,"04,05,06,07,08,09") <> 0 then n1 = 2.
                else if lookup(wrkFS.okedlon,"10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33") <> 0 then n1 = 3.
                    else if lookup(wrkFS.okedlon,"35") <> 0 then n1 = 4.
                        else if lookup(wrkFS.okedlon,"36,37,38,39") <> 0 then n1 = 5.
                            else if lookup(wrkFS.okedlon,"41,42,43") <> 0 then n1 = 6.
                                else if lookup(wrkFS.okedlon,"45,46,47") <> 0 then n1 = 7.
                                    else if lookup(wrkFS.okedlon,"49,50,51,52,53") <> 0 then n1 = 8.
                                        else if lookup(wrkFS.okedlon,"55,56") <> 0 then n1 = 9.
                                            else if lookup(wrkFS.okedlon,"58,59,60,61,62,63") <> 0 then n1 = 10.
                                                else if lookup(wrkFS.okedlon,"64,65,66") <> 0 then n1 = 11.
                                                    else if lookup(wrkFS.okedlon,"68") <> 0 then n1 = 12.
                                                        else if lookup(wrkFS.okedlon,"69,70,71,72,73,74,75") <> 0 then n1 = 13.
                                                            else if lookup(wrkFS.okedlon,"77,78,79,80,81,82") <> 0 then n1 = 14.
                                                                else if lookup(wrkFS.okedlon,"84") <> 0 then n1 = 15.
                                                                    else if lookup(wrkFS.okedlon,"85") <> 0 then n1 = 16.
                                                                        else if lookup(wrkFS.okedlon,"86,87,88") <> 0 then n1 = 17.
                                                                            else if lookup(wrkFS.okedlon,"90,91,92,93") <> 0 then n1 = 18.
                                                                                else if lookup(wrkFS.okedlon,"94,95,96") <> 0 then n1 = 19.
                                                                                    else if lookup(wrkFS.okedlon,"97,98") <> 0 then n1 = 20.
                                                                                        else if lookup(wrkFS.okedlon,"99") <> 0 then n1 = 21.
                                                                                            else next.

    rezsum = absolute(wrkFS.rezsum_msfo).
    sum_od = wrkFS.ostatok_kzt + wrkFS.penalty + wrkFS.nach_prc_kzt.
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

    if prosr = 0 then do:
        n2 = 1.
        n3 = 0.
    end.
    else do:
        n2 = 2.
        n3 = prosr.
    end.

    s1 = (n1 - 1) * 8 + 1.
    if n2 = 1 then s2 = s1 + 1.
    else s2 = s1 + 2.
    i = s1 + n2 + n3.

    find first FSPZOMSFO where FSPZOMSFO.num = i no-error.
    if avail FSPZOMSFO then do:
        FSPZOMSFO.odost[kat]    = FSPZOMSFO.odost[kat] + wrkFS.ostatok_kzt.
        FSPZOMSFO.disc[kat]     = FSPZOMSFO.disc[kat] + wrkFS.zam_dk.
        FSPZOMSFO.prcnach[kat]  = FSPZOMSFO.prcnach[kat] + wrkFS.nach_prc_kzt.
        FSPZOMSFO.korrect[kat]  = FSPZOMSFO.korrect[kat] + 0.
        FSPZOMSFO.stpriv[kat]   = FSPZOMSFO.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSPZOMSFO.obesp[kat]    = FSPZOMSFO.obesp[kat] + wrkFS.obesall.
        FSPZOMSFO.odprov[kat]   = FSPZOMSFO.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSPZOMSFO.prcprov[kat]  = FSPZOMSFO.prcprov[kat] + wrkFS.rezsum_prc.
        FSPZOMSFO.allprov[kat]  = FSPZOMSFO.allprov[kat] + wrkFS.rezsum_afn.
        FSPZOMSFO.odost[8]      = FSPZOMSFO.odost[8] + wrkFS.ostatok_kzt.
        FSPZOMSFO.disc[8]       = FSPZOMSFO.disc[8] + wrkFS.zam_dk.
        FSPZOMSFO.prcnach[8]    = FSPZOMSFO.prcnach[8] + wrkFS.nach_prc_kzt.
        FSPZOMSFO.korrect[8]    = FSPZOMSFO.korrect[8] + 0.
        if kat <> 1 then FSPZOMSFO.stpriv[8] = FSPZOMSFO.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSPZOMSFO.obesp[8]      = FSPZOMSFO.obesp[8] + wrkFS.obesall.
        FSPZOMSFO.odprov[8]     = FSPZOMSFO.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSPZOMSFO.prcprov[8]    = FSPZOMSFO.prcprov[8] + wrkFS.rezsum_prc.
        FSPZOMSFO.allprov[8]    = FSPZOMSFO.allprov[8] + wrkFS.rezsum_afn.
    end.
    if i <> s2 then do:
        find first FSPZOMSFO where FSPZOMSFO.num = s2 no-error.
        if avail FSPZOMSFO then do:
            FSPZOMSFO.odost[kat]    = FSPZOMSFO.odost[kat] + wrkFS.ostatok_kzt.
            FSPZOMSFO.disc[kat]     = FSPZOMSFO.disc[kat] + wrkFS.zam_dk.
            FSPZOMSFO.prcnach[kat]  = FSPZOMSFO.prcnach[kat] + wrkFS.nach_prc_kzt.
            FSPZOMSFO.korrect[kat]  = FSPZOMSFO.korrect[kat] + 0.
            FSPZOMSFO.stpriv[kat]   = FSPZOMSFO.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
            FSPZOMSFO.obesp[kat]    = FSPZOMSFO.obesp[kat] + wrkFS.obesall.
            FSPZOMSFO.odprov[kat]   = FSPZOMSFO.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
            FSPZOMSFO.prcprov[kat]  = FSPZOMSFO.prcprov[kat] + wrkFS.rezsum_prc.
            FSPZOMSFO.allprov[kat]  = FSPZOMSFO.allprov[kat] + wrkFS.rezsum_afn.
            FSPZOMSFO.odost[8]      = FSPZOMSFO.odost[8] + wrkFS.ostatok_kzt.
            FSPZOMSFO.disc[8]       = FSPZOMSFO.disc[8] + wrkFS.zam_dk.
            FSPZOMSFO.prcnach[8]    = FSPZOMSFO.prcnach[8] + wrkFS.nach_prc_kzt.
            FSPZOMSFO.korrect[8]    = FSPZOMSFO.korrect[8] + 0.
            if kat <> 1 then FSPZOMSFO.stpriv[8] = FSPZOMSFO.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
            FSPZOMSFO.obesp[8]      = FSPZOMSFO.obesp[8] + wrkFS.obesall.
            FSPZOMSFO.odprov[8]     = FSPZOMSFO.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
            FSPZOMSFO.prcprov[8]    = FSPZOMSFO.prcprov[8] + wrkFS.rezsum_prc.
            FSPZOMSFO.allprov[8]    = FSPZOMSFO.allprov[8] + wrkFS.rezsum_afn.
        end.
    end.
    find first FSPZOMSFO where FSPZOMSFO.num = s1 no-error.
    if avail FSPZOMSFO then do:
        FSPZOMSFO.odost[kat]    = FSPZOMSFO.odost[kat] + wrkFS.ostatok_kzt.
        FSPZOMSFO.disc[kat]     = FSPZOMSFO.disc[kat] + wrkFS.zam_dk.
        FSPZOMSFO.prcnach[kat]  = FSPZOMSFO.prcnach[kat] + wrkFS.nach_prc_kzt.
        FSPZOMSFO.korrect[kat]  = FSPZOMSFO.korrect[kat] + 0.
        FSPZOMSFO.stpriv[kat]   = FSPZOMSFO.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSPZOMSFO.obesp[kat]    = FSPZOMSFO.obesp[kat] + wrkFS.obesall.
        FSPZOMSFO.odprov[kat]   = FSPZOMSFO.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSPZOMSFO.prcprov[kat]  = FSPZOMSFO.prcprov[kat] + wrkFS.rezsum_prc.
        FSPZOMSFO.allprov[kat]  = FSPZOMSFO.allprov[kat] + wrkFS.rezsum_afn.
        FSPZOMSFO.odost[8]      = FSPZOMSFO.odost[8] + wrkFS.ostatok_kzt.
        FSPZOMSFO.disc[8]       = FSPZOMSFO.disc[8] + wrkFS.zam_dk.
        FSPZOMSFO.prcnach[8]    = FSPZOMSFO.prcnach[8] + wrkFS.nach_prc_kzt.
        FSPZOMSFO.korrect[8]    = FSPZOMSFO.korrect[8] + 0.
        if kat <> 1 then FSPZOMSFO.stpriv[8] = FSPZOMSFO.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSPZOMSFO.obesp[8]      = FSPZOMSFO.obesp[8] + wrkFS.obesall.
        FSPZOMSFO.odprov[8]     = FSPZOMSFO.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSPZOMSFO.prcprov[8]    = FSPZOMSFO.prcprov[8] + wrkFS.rezsum_prc.
        FSPZOMSFO.allprov[8]    = FSPZOMSFO.allprov[8] + wrkFS.rezsum_afn.
    end.

    find first FSPZOMSFO where FSPZOMSFO.num = 169 no-error.
    if avail FSPZOMSFO then do:
        FSPZOMSFO.odost[kat]    = FSPZOMSFO.odost[kat] + wrkFS.ostatok_kzt.
        FSPZOMSFO.disc[kat]     = FSPZOMSFO.disc[kat] + wrkFS.zam_dk.
        FSPZOMSFO.prcnach[kat]  = FSPZOMSFO.prcnach[kat] + wrkFS.nach_prc_kzt.
        FSPZOMSFO.korrect[kat]  = FSPZOMSFO.korrect[kat] + 0.
        FSPZOMSFO.stpriv[kat]   = FSPZOMSFO.stpriv[kat] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSPZOMSFO.obesp[kat]    = FSPZOMSFO.obesp[kat] + wrkFS.obesall.
        FSPZOMSFO.odprov[kat]   = FSPZOMSFO.odprov[kat] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSPZOMSFO.prcprov[kat]  = FSPZOMSFO.prcprov[kat] + wrkFS.rezsum_prc.
        FSPZOMSFO.allprov[kat]  = FSPZOMSFO.allprov[kat] + wrkFS.rezsum_afn.
        FSPZOMSFO.odost[8]      = FSPZOMSFO.odost[8] + wrkFS.ostatok_kzt.
        FSPZOMSFO.disc[8]       = FSPZOMSFO.disc[8] + wrkFS.zam_dk.
        FSPZOMSFO.prcnach[8]    = FSPZOMSFO.prcnach[8] + wrkFS.nach_prc_kzt.
        FSPZOMSFO.korrect[8]    = FSPZOMSFO.korrect[8] + 0.
        if kat <> 1 then FSPZOMSFO.stpriv[8] = FSPZOMSFO.stpriv[8] + wrkFS.ostatok_kzt + wrkFS.zam_dk + wrkFS.nach_prc_kzt - wrkFS.rezsum_od - wrkFS.rezsum_prc.
        FSPZOMSFO.obesp[8]      = FSPZOMSFO.obesp[8] + wrkFS.obesall.
        FSPZOMSFO.odprov[8]     = FSPZOMSFO.odprov[8] + wrkFS.rezsum_od + wrkFS.rezsum_pen.
        FSPZOMSFO.prcprov[8]    = FSPZOMSFO.prcprov[8] + wrkFS.rezsum_prc.
        FSPZOMSFO.allprov[8]    = FSPZOMSFO.allprov[8] + wrkFS.rezsum_afn.
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

output stream m-out to formFSPZOMSFO.htm.

put stream m-out unformatted "<html><head><title>FORTEBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
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

/*Используемые показатели входных форм отчета*/
{CreatePokaz.i v-RepTyp}

/*TEMP*/
/*for each FSPZOMSFO exclusive-lock by FSPZOMSFO.num:
    repeat i = 1 to 8 by 1:
        if i = 1 then do:
            FSPZOMSFO.odost[i] = random(-100000,100000).
            FSPZOMSFO.disc[i] = random(-100000,100000).
            FSPZOMSFO.prcnach[i] = random(-100000,100000).
            FSPZOMSFO.korrect[i] = random(-100000,100000).

            FSPZOMSFO.obesp[i] = random(-100000,100000).
            FSPZOMSFO.odprov[i] = random(-100000,100000).
            FSPZOMSFO.prcprov[i] = random(-100000,100000).
        end.
        else do:
            FSPZOMSFO.odost[i] = random(-100000,100000).
            FSPZOMSFO.disc[i] = random(-100000,100000).
            FSPZOMSFO.prcnach[i] = random(-100000,100000).
            FSPZOMSFO.korrect[i] = random(-100000,100000).
            FSPZOMSFO.stpriv[i] = random(-100000,100000).
            FSPZOMSFO.obesp[i] = random(-100000,100000).
            FSPZOMSFO.odprov[i] = random(-100000,100000).
            FSPZOMSFO.prcprov[i] = random(-100000,100000).
        end.
    end.
end.*/

for each FSPZOMSFO no-lock by FSPZOMSFO.num:
    find t-wrk where t-wrk.num = FSPZOMSFO.num exclusive-lock no-error.

    put stream m-out unformatted
            "<tr>" skip
            "<td align=""left"">&nbsp;" replace(FSPZOMSFO.nnum,".0"," ") "</td>" skip
            "<td>" FSPZOMSFO.nname "</td>" skip.

    p = 0.
    repeat i = 1 to 8 by 1:
        put stream m-out unformatted
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.odost[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.disc[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.prcnach[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.korrect[i] / m,m1),vivod)),'.',',') "</td>" skip.
        if i = 1 then
            put stream m-out unformatted
                "<td align=""right""></td>" skip
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.obesp[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right""></td>" skip
                "<td align=""right""></td>" skip.
        else
            put stream m-out unformatted
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.stpriv[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.obesp[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.odprov[i] / m,m1),vivod)),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(round(FSPZOMSFO.prcprov[i] / m,m1),vivod)),'.',',') "</td>" skip.

        repeat j = 1 to 8 by 1:
            p = p + 1.
            if j = 1 then t-wrk.znac[p] = round(FSPZOMSFO.odost[i] / m,m1).
            if j = 2 then t-wrk.znac[p] = round(FSPZOMSFO.disc[i] / m,m1).
            if j = 3 then t-wrk.znac[p] = round(FSPZOMSFO.prcnach[i] / m,m1).
            if j = 4 then t-wrk.znac[p] = round(FSPZOMSFO.korrect[i] / m,m1).
            if i <> 1 then do: if j = 5 then t-wrk.znac[p] = round(FSPZOMSFO.stpriv[i] / m,m1). end.
            if j = 6 then t-wrk.znac[p] = round(FSPZOMSFO.obesp[i] / m,m1).
            if i <> 1 then do: if j = 7 then t-wrk.znac[p] = round(FSPZOMSFO.odprov[i] / m,m1). end.
            if i <> 1 then do: if j = 8 then t-wrk.znac[p] = round(FSPZOMSFO.prcprov[i] / m,m1). end.
        end.
    end.
    put stream m-out unformatted "</tr>" skip.
end.

put stream m-out "</table></body></html>" skip.
output stream m-out close.

unix silent cptwin formFSPZOMSFO.htm excel.

m = 1.
m1 = 2.
vivod = '->>>>>>>>>>>>>>9.99'.
if v-rash then do:
    output stream m-out1 to formFSPZOMSFOrassh.htm.
    put stream m-out1 unformatted "<html><head><title>FORTEBANK</title>"
                    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out1 unformatted "<br><br><h3 h3 colspan=20 align=""center"">Расшифровка по отчету ""Сведения о займах, по которым имеется просроченная задолженность по основному долгу и (или) по начисленному вознаграждению в деталях, а также о размере провизий (резервов) сформированных в соответствии с международными стандартами финансовой отчетности"" '</h3><br>" skip.
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
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ОКЭД(согласно<BR>карточке клиента)</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ОКЭД(по<BR>банковскому займу) клиента</td>"
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
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма залога, прочее</td>"
                    "<td bgcolor=""#C0C0C0"" colspan=3 align=""center"" valign=""top"">Вид ОКЭД</td>"
                    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Классификация</td>"
                    "</tr>" skip.
    i = 0.
    for each wrkFS no-lock  by wrkFS.cif:

        if lookup(wrkFS.okedlon,"0,msc") <> 0 then next.
        else if lookup(wrkFS.okedlon,"01,02,03") <> 0 then n1 = 1.
            else if lookup(wrkFS.okedlon,"04,05,06,07,08,09") <> 0 then n1 = 2.
                else if lookup(wrkFS.okedlon,"10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33") <> 0 then n1 = 3.
                    else if lookup(wrkFS.okedlon,"35") <> 0 then n1 = 4.
                        else if lookup(wrkFS.okedlon,"36,37,38,39") <> 0 then n1 = 5.
                            else if lookup(wrkFS.okedlon,"41,42,43") <> 0 then n1 = 6.
                                else if lookup(wrkFS.okedlon,"45,46,47") <> 0 then n1 = 7.
                                    else if lookup(wrkFS.okedlon,"49,50,51,52,53") <> 0 then n1 = 8.
                                        else if lookup(wrkFS.okedlon,"55,56") <> 0 then n1 = 9.
                                            else if lookup(wrkFS.okedlon,"58,59,60,61,62,63") <> 0 then n1 = 10.
                                                else if lookup(wrkFS.okedlon,"64,65,66") <> 0 then n1 = 11.
                                                    else if lookup(wrkFS.okedlon,"68") <> 0 then n1 = 12.
                                                        else if lookup(wrkFS.okedlon,"69,70,71,72,73,74,75") <> 0 then n1 = 13.
                                                            else if lookup(wrkFS.okedlon,"77,78,79,80,81,82") <> 0 then n1 = 14.
                                                                else if lookup(wrkFS.okedlon,"84") <> 0 then n1 = 15.
                                                                    else if lookup(wrkFS.okedlon,"85") <> 0 then n1 = 16.
                                                                        else if lookup(wrkFS.okedlon,"86,87,88") <> 0 then n1 = 17.
                                                                            else if lookup(wrkFS.okedlon,"90,91,92,93") <> 0 then n1 = 18.
                                                                                else if lookup(wrkFS.okedlon,"94,95,96") <> 0 then n1 = 19.
                                                                                    else if lookup(wrkFS.okedlon,"97,98") <> 0 then n1 = 20.
                                                                                        else if lookup(wrkFS.okedlon,"99") <> 0 then n1 = 21.
                                                                                            else next.

        rezsum = absolute(wrkFS.rezsum_msfo).
        sum_od = wrkFS.ostatok_kzt + wrkFS.penalty + wrkFS.nach_prc_kzt.
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

        if prosr = 0 then do:
            n2 = 1.
            n3 = 0.
        end.
        else do:
            n2 = 2.
            n3 = prosr.
        end.

        find first bank.crc where bank.crc.crc = wrkFS.crc no-lock no-error.
        if wrkFS.ostatok_kzt = 0 then prcrezafn = 0. else prcrezafn = 100 * rezsum / sum_od.

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
            "<td align=""center"">" bank.crc.code "</td>" skip
            "<td>" wrkFS.otrasl "</td>" skip
            "<td>" wrkFS.finotrasl "</td>" skip
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
            "<td>" kat "</td>" skip
            "</tr>" skip.
    end.
    put stream m-out1 "</table></body></html>" skip.
    output stream m-out1 close.
    unix silent cptwin formFSPZOMSFOrassh.htm excel.
end.

hide message no-pause.

end. /*on choose of menu-item m-gen do:*/

on choose of menu-item m-load do:

def var v-ans as logi init false.
run yn("ВНИМАНИЕ","Выбран тип отчета - << " + v-RepTyp + " >>","Отправить данные в АИС << Статистику >>","",output v-ans).
if v-ans then do:
    message "Ждите,идет отправка данных...".
    /*Тип отчета*/
    ReportType = "STAT".
    /*Форма отчета*/
    if v-RepTyp = "fs_pzo_msfo" then id_form = "6515".
    if v-RepTyp = "fs_pzo_smp_msfo" then id_form = "6516".

    d_rep_file = STRING(today,"99/99/9999") + " " + string(time,"HH:MM:SS").
    d_report = d1.
    if month(d_report) = 1 then do:
        /*Признак, с заключительными оборотами или нет*/
        if v-zo then zo = "1".
        else zo = " ".
        /*Признак периода*/
        pr_period = "99" + SUBSTR(STRING(year(d_report),"9999"),2,3).
    end.
    else do:
        zo = " ".
        pr_period = STRING(month(d_report)) + SUBSTR(STRING(year(d_report),"9999"),2,3).
    end.
    /*Статус отчета,1-новый,2-проверенный с ошибками,3-проверка прошла успешно*/
    status_ = "1".

    oracleHost = "db01.metrobank.kz".
    oracleDb = "stat".
    oracleUser = "stat".
    oraclePassword = "dec_2007".

    empty temp-table t-temp.

    def var v-res as char.
    def var v-id as inte.
    j = 0.
    for each t-wrk no-lock by t-wrk.num:
        repeat p = 1 to 64 by 1:
            if t-wrk.znac[p] = 0 then next.
            j = j + 1.
            v-id = INTEGER(ENTRY(p,t-wrk.id_pokaz,";")) no-error.

            create t-temp.
            t-temp.i = j.
            t-temp.id = v-id.
            t-temp.znac = t-wrk.znac[p].
        end.
    end.
    def buffer b-t-temp for t-temp.
    for each t-temp no-lock:
        run AddData( t-temp.i, t-temp.id, t-temp.znac , "" , false , "", "", "", "" ).
        if (t-temp.i mod 3000) = 0 then do:
            run stat_send(output v-res).
            empty temp-table t-stat.
            if v-res = "ERROR" then do:
                MESSAGE "Данные не были загружены в АИС Статистику!" skip
                        "Попробуйте удалить данные в АИС Статистике за дату " string(d1,"99/99/9999") " !" VIEW-AS ALERT-BOX BUTTONS OK TITLE "ОШИБКА".
                RETURN.
            end.
        end.
        else do:
            find b-t-temp where b-t-temp.i = t-temp.i + 1 no-lock no-error.
            if not avail b-t-temp then do:
                run stat_send(output v-res).
                empty temp-table t-stat.
                if v-res = "OK" then do:
                    MESSAGE "Данные успешно загружены в АИС Статистику!" VIEW-AS ALERT-BOX BUTTONS OK TITLE "ВНИМАНИЕ".
                end.
                if v-res = "ERROR" then do:
                    MESSAGE "Данные не были загружены в АИС Статистику!" skip
                            "Попробуйте удалить данные в АИС Статистике за дату " string(d1,"99/99/9999") " !" VIEW-AS ALERT-BOX BUTTONS OK TITLE "ОШИБКА".
                    RETURN.
                end.
            end.
        end.
    end.
    hide message no-pause.
end.

end. /*on choose of menu-item m-load do:*/

CURRENT-WINDOW:MENUBAR = MENU m-stat:HANDLE.
WAIT-FOR CHOOSE OF MENU-ITEM m-exit.

procedure AddData:
    def input parameter i as inte.
    def input parameter id_pokaz as inte.
    def input parameter znac as deci.
    def input parameter stroka as char.
    def input parameter pr_spr as logi.
    def input parameter tname_spr as char.
    def input parameter field_spr as char.
    def input parameter znac_spr as char.
    def input parameter line as char.

    create t-stat.
    t-stat.i = i.
    t-stat.id_pokaz = id_pokaz.
    t-stat.znac = znac.
    t-stat.stroka = stroka.
    t-stat.pr_spr = pr_spr.
    t-stat.tname_spr = tname_spr.
    t-stat.field_spr = field_spr.
    t-stat.znac_spr = znac_spr.
    t-stat.line = line.
end procedure.


