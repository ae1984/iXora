/* r-kbs.p
 * MODULE
        Финансовая отчетность
 * DESCRIPTION
        Консолидированный баланс - крутит программу сборки балансов по всем филиалам
 * RUN

 * CALLER
        r-konbs2.p
 * SCRIPT

 * INHERIT

 * MENU
        9.12.3
 * AUTHOR
        29.01.2002 pragma
 * BASES
        BANK COMM
 * CHANGES
        05.07.2002 nataly   - 1. убраны ГК с нулевыми оборотами
        2. изменен порядок следования счетов ГК  - основа прогр-ма gl_list.p
        27.08.2002 nadejda  - IP-адрес для определения диска L изменен на IP-адрес сервера
        04.09.2003 nadejda  - 1. внесла каталог складывания балансов в SYSC и сделала переменные шаренными
        2. добавила запись файла баланса и в архив тоже
        04.12.2003 nadejda  - перевела расчеты с реальной базы BANK на копию BANKS
        07.03.2004 sasco    - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        01.06.2003 nadejda  - переделала балансы так, чтобы считать на любую дату
        20.07.2004 saltanat - Добавлено сохранение данных в Excel.
        12.08.2004 suchkov  - Добавил отправку на E-Mail
        11/10/05 nataly     - был добавлен итоговый уровень по счетам ГК
        12/10/05 nataly     - был добавлен разделитель ;
        08/08/06 nataly     - Валюта была разбита на USD,RUB,EUR
        02/08/07 marinav    - Замена rcp на  scp
        25/12/07 marinav    - r-branch3 -> r-branch
        13/11/08 marinav    - добавила валюту фунты
        28.10.10 marinav    - расширено поле наименование
        10/09/2011 madiyar  - добавил шведские кроны, австралийские доллары и швейцарские франки
        06.04.2012 damir    - изменений не вносил, перекомпиляция.
        11.04.2012 id00004  - исправил косяк при отображении счетов 185800 для двухуровневой привязки счета
        14/06/2012 madiyar  - добавил ранды
        15.06.2012 damir    - ЮАР (ZAR) - корректировка, не отражался 9 класс (перекомпиляция)..
        04.07.2012 damir    - добавил CAD.
        30.11.2012 Lyubov   - перекомпиляция в связи с изменениями в gl_list2.i
        04.12.2012 Lyubov   - перекомпиляция в связи с изменениями в gl_list2.i и gl-utils.i
*/

{global.i}
{gl-utils.i}

define buffer b-gl      for gl.
define buffer basecrc   for crchis.
define buffer crc2      for crchis.
define buffer b-crc     for crchis.
define buffer d-gl      for gl.
define buffer d-gl2     for gl.

define new shared var vbal as decimal extent 10.
define new shared var vbaltot as decimal format 'zzz,zzz,zzz,zz9.99-'.
define new shared var vsver as decimal extent 8 initial 0.00.
define shared var v-dat as date.
define new shared var rate1 as decimal.
define new shared var rate9 as decimal.
define new shared var flag as logical init false.
define new shared var v-pass as char.

for each sysc where sysc.sysc="SYS1" no-lock.
    v-pass = ENTRY(1,sysc.chval).
end.

g-fname = "MBSPL2".
g-mdes = "".

find nmenu where nmenu.fname eq "MBSPL2" no-error.
find nmdes where nmdes.fname eq "MBSPL2" and  nmdes.lang  eq g-lang no-error.
if available nmdes then g-mdes = nmdes.des.

if g-batch eq false then display
g-fname g-mdes "PRAGMA" g-ofc to 71 g-today to 80 with color messages overlay no-box no-label row 2 col 1 frame mainhead.

define var vasof as date.

define var savefile as cha.
define var vtitle-1 as char format "x(155)".
define var v-crc like crc.crc initial 1.
/***********/

def var tt as cha.
def var v-gll as char format "x(10)".
def var v-name like gl.des init "".
def var vgl like pglbal.gl.
def var c1 as char.
def var c2 as char init "".
/*def var v-sysc like sysc.chval.*/
def var vimgfname as char init "rpt.img".
def var vfilebody as char.
def var vfileext as char.
def var vtitle as char format "x(150)".
def var vtoday as date.
def var vtime  as cha format "x(8)".
def var v-result as char.

def temp-table gll field gllist as char format "x(10)".

define new shared temp-table temp
    field gl        as integer format 'zzzzz9'
    field des       as char  format 'x(40)'
    field totgl     as integer format  'zzzzz9'
    field totlev    as integer format 'z9'
    field bal1      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* kzt */
    field bal2      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* usd */
    field bal3      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* eur */
    field bal4      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* rub */
    field bal5      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* gbp */
    field bal6      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* sek */
    field bal7      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* aud */
    field bal8      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* chf */
    field bal9      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* ранды ЮАР */
    field bal10     as deci format 'z,zzz,zzz,zzz,zz9.99-' /* CAD */
    field baltot    as deci format 'z,zzz,zzz,zzz,zz9.99-'
    field usd       as inte init 0.

define temp-table r-temp /*final temp*/
    field gl        like gl.gl
    field des       like gl.des
    field totgl     like gl.gl
    field totlev    as inte format "z9"
    field bal1      as deci format "z,zzz,zzz,zzz,zz9.99-" /* kzt */
    field bal2      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* usd */
    field bal3      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* eur */
    field bal4      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* rub */
    field bal5      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* gbp */
    field bal6      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* sek */
    field bal7      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* aud */
    field bal8      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* chf */
    field bal9      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* ранды ЮАР */
    field bal10     as deci format 'z,zzz,zzz,zzz,zz9.99-' /* CAD */
    field baltot    as deci format 'z,zzz,zzz,zzz,zz9.99-'
    field usd       as inte init 0.

define buffer b-temp    for temp.
define buffer d-temp    for temp.

def var n-point as char format "x(30)".
def var v-point like point.point.
def var pvglbal like glbal.bal.
def var pvsubbal like glbal.bal.
define variable fname as character format "x(12)".

def shared var dirc     as char format "x(15)".
def shared var dircarc  as char format "x(15)".
def shared var ipaddr   as char format "x(15)".

def stream exc.  /* For Excel*/
define variable exname as character format "x(12)".

find sysc where sysc.sysc = "GLPNT" no-lock no-error.
tt = sysc.chval .

repeat :
    create gll .
    gll.gllist = substr(tt,1,index(tt,",") - 1 ).
    tt = substr(tt,index(tt,",") + 1,length(sysc.chval)).
    if tt = "" then leave .
end.

if not g-batch then do:
    update v-dat validate (v-dat < g-today, " Неверная дата!") label " ДАТА ОТЧЕТА " format "99/99/9999" skip
    v-crc validate(can-find(crc where crc.crc eq v-crc no-lock),
    " Неверный код валюты!")             label "      ВАЛЮТА " help " F2 - выбор валюты"
    with centered row 5 side-label no-box frame crc.
end.
hide frame crc no-pause.

/*find sysc where sysc.sysc eq "GLDATE" no-lock no-error.*/
vasof = v-dat.  /*sysc.daval.*/


display "   Ждите...  "  with row 5 frame ww centered .

{file-ext.i vimgfname}

if search(vimgfname) eq vimgfname then do:
    if opsys = "unix" then do:
        if search(vfilebody + ".bak") eq vfilebody + ".bak" then
        unix silent rm -f value(vfilebody + ".bak").
        unix silent mv value(vimgfname) value(vfilebody + ".bak").
    end.
    else if opsys = "msdos" then do:
        if search(vfilebody + ".bak") eq vfilebody + ".bak" then
        dos silent del value(vfilebody + ".bak").
        dos silent ren value(vimgfname) value(vfilebody + ".bak").
    end.
end.

vtoday = today.
vtime  = string(time,"HH:MM:SS").

output to value(vimgfname) page-size 59.
output stream exc to rpt1.img.

vtitle = "КОНСОЛИДИРОВАННЫЙ БАЛАНС (ТЕНГЕ)    ЗА " + string(vasof).

vtitle-1 =
"Итог ур Г/К          НАЗВАНИЕ                          KZT                     USD                     RUB                    EUR                    GBP                    SEK                    AUD                    CHF                    ZAR                    CAD            ВСЕГО".

{report2.i 155 "vtitle-1 skip fill(""="",155) format ""x(155)"" skip" aa}

put stream exc unformatted g-comp " " vtoday " " vtime " Исп. " caps(g-ofc) skip(1).
put stream exc unformatted g-fname " " g-mdes skip.
put stream exc unformatted vtitle skip.
put stream exc unformatted fill( "=", 110 )  format "x(110)" skip.
put stream exc unformatted ("Итог ур;Г/К;НАЗВАНИЕ;KZT;USD;RUB;EUR;GBP;SEK;AUD;CHF;ZAR;CAD;ВСЕГО") skip.

put stream exc unformatted fill("=",110) format "x(110)" skip(1).
put stream exc unformatted ("ВАЛ.;НАЗВАНИЕ;КУРС;РАЗМЕРНОСТЬ; ") skip.
put stream exc unformatted fill("-",220) format "x(220)" skip.

find last crchis where crchis.crc = 1 and crchis.rdt <= v-dat no-lock no-error.
find last basecrc where basecrc.crc = v-crc and basecrc.rdt <= v-dat no-lock no-error.

rate9 = basecrc.rate[9].
rate1 = basecrc.rate[1].

output stream exc close.

/* 04.12.2003 nadejda - цикл по базам banks */
{r-branch.i &proc = "gm-konbs22"}

output stream exc to rpt1.img append.

{gl_list2.i}

define buffer b-tlist for tlist.

for each tlist where tlist.child < 600000 no-lock break  by  substr(trim(string(tlist.child)),1,1) /*by  substr(trim(string(tlist.child)),1,2)*/ :
    find temp where temp.gl = tlist.child no-lock no-error.
    c1 = substr(trim(string(tlist.child)),1,1).
    if available temp and (substr(string(temp.gl),2,4) <> "9999" and substr(string(temp.gl),2,4) <> "4999") then do:

        find last d-temp where d-temp.gl < temp.gl and d-temp.usd = 0  no-lock no-error.
        if available d-temp  and substr(string(temp.gl),5,2) <> "99" then do:
            find b-tlist where b-tlist.child = d-temp.gl  no-lock no-error.
            /* Если имеется счет ГК из temp.gl <  текущего счета то он выводится
            Только в том случае когда его нет в таблице tlist
            пример 460810 - 11,14*/
            if not available b-tlist then do:
                find d-gl2 where d-temp.gl = d-gl2.gl no-lock no-error.
                d-temp.usd = 1.
                create r-temp.
                BUFFER-COPY d-temp TO  r-temp.
            end.
        end.

        find d-gl where temp.gl = d-gl.gl no-lock no-error.
        temp.usd = 1.
        create r-temp.
        BUFFER-COPY temp TO  r-temp.
    end.  /*if available temp*/

    if last-of(substr(trim(string(tlist.child)),1,1)) then do:

        for each b-temp where substr(string(b-temp.gl),1,1)  = c1 and substr(string(b-temp.gl),2,4) = "9999" no-lock:
            find d-temp where d-temp.gl < b-temp.gl and d-temp.usd = 0  no-lock no-error.
            if available d-temp  then do:
                find d-gl2 where d-temp.gl = d-gl2.gl no-lock no-error.
                d-temp.usd = 1.
                create r-temp.
                BUFFER-COPY d-temp TO  r-temp.
            end.
            find d-gl where b-temp.gl = d-gl.gl no-lock no-error.
            b-temp.usd = 1.
            create r-temp.
            BUFFER-COPY b-temp TO  r-temp.

        end. /*for each b-temp*/
    end.  /*if c1 <> */
    c2 = substr(trim(string(tlist.child)),1,2).
end.  /*for each tlist*/

/*--------------*/
for each tlist  where tlist.child >= 600000 no-lock break by substr(trim(string(tlist.child)),1,1) by  substr(trim(string(tlist.child)),1,2)
by substr(trim(string(tlist.child)),1,3):
    find temp where temp.gl = tlist.child no-lock no-error.
    c1 = substr(trim(string(tlist.child)),1,1).
    if available temp and (substr(string(temp.gl),2,4) <> "9999" and substr(string(temp.gl),2,4) <> "4999") then do:

        find d-temp where d-temp.gl < temp.gl and d-temp.usd = 0  no-lock no-error.
        if available d-temp  and substr(string(temp.gl),5,2) <> "99" then do:
            find b-tlist where b-tlist.child = d-temp.gl  no-lock no-error.
            /* Если имеется счет ГК из temp.gl <  текущего счета то он выводится
            Только в том случае когда его нет в таблице tlist
            пример 460810 - 11,14*/
            if not available b-tlist then do:
                find d-gl2 where d-temp.gl = d-gl2.gl no-lock no-error.
                d-temp.usd = 1.
                create r-temp.
                BUFFER-COPY d-temp TO  r-temp.
            end.
        end.

        find d-gl where temp.gl = d-gl.gl no-lock no-error.
        temp.usd = 1.
        create r-temp.
        BUFFER-COPY temp TO  r-temp.
    end.  /*if available temp*/
    if last-of(substr(trim(string(tlist.child)),1,2)) and ( substr(trim(string(tlist.child)),1,2) eq "64" or substr(trim(string(tlist.child)),1,2) eq "74") /* and
    substr(trim(string(tlist.child)),2,4) = "4999"*/ then do:
        case c1:
            when "6" then
            find first b-temp where substr(string(b-temp.gl),1,1)  = c1 and substr(trim(string(b-temp.gl)),1,5) = "64999".
            when "7" then
            find b-temp where substr(string(b-temp.gl),1,1)  = c1 and substr(trim(string(b-temp.gl)),1,5) = "74999".
        end case.

        find d-temp where d-temp.gl < b-temp.gl and d-temp.usd = 0  no-lock no-error.
        if available d-temp  then do:
            find d-gl2 where d-temp.gl = d-gl2.gl no-lock no-error.
            d-temp.usd = 1.
            create r-temp.
            BUFFER-COPY d-temp TO  r-temp.
        end.

        find d-gl where b-temp.gl = d-gl.gl no-lock no-error.
        b-temp.usd = 1.
        create r-temp.
        BUFFER-COPY b-temp TO  r-temp.
    end.  /*if c2<> */

    if last-of(substr(trim(string(tlist.child)),1,1)) then do:
        for each b-temp where substr(string(b-temp.gl),1,1)  = c1 and substr(string(b-temp.gl),2,4) = "9999".
            find d-temp where d-temp.gl < b-temp.gl and d-temp.usd = 0  no-lock no-error.
            if available d-temp  then do:
                find d-gl2 where d-temp.gl = d-gl2.gl no-lock no-error.
                d-temp.usd = 1.
                create r-temp.
                BUFFER-COPY d-temp TO  r-temp.
            end.
            find d-gl where b-temp.gl = d-gl.gl no-lock no-error.
            b-temp.usd = 1.
            create r-temp.
            BUFFER-COPY b-temp TO  r-temp.
        end. /*for each b-temp*/
    end.  /*if c1 <> */
    c2 = substr(trim(string(tlist.child)),1,2).
end.  /*for each tlist*/

/*-------------*/

for each r-temp no-lock break by substr(trim(string(r-temp.gl)),1,1) by substr(trim(string(r-temp.gl)),1,2) by substr(trim(string(r-temp.gl)),1,3) .
    if first-of(substr(trim(string(r-temp.gl)),1,1)) then do:
        if substr(trim(string(r-temp.gl)),1,1) eq "1" then do:
            put skip(1) "*** АКТИВЫ ***" skip(1).
            put stream exc unformatted skip(1) "*** АКТИВЫ ***" skip(1).
        end.
        else if substr(trim(string (r-temp.gl)),1,1) eq "2" then do:
            /*   page.  */
            put skip(1) "*** ПАССИВЫ ***" skip(1).
            put stream exc unformatted skip(1) "*** ПАССИВЫ ***" skip(1).
        end.
        else if substr(trim(string(r-temp.gl)),1,1) eq "3" then do:
            put skip(1) "*** КАПИТАЛ ***" skip(1).
            put stream exc unformatted skip(1) "*** КАПИТАЛ ***" skip(1).
        end.
        else if  substr(trim(string(r-temp.gl)),1,1) eq "4" then do:
            put skip(1) "*** ДОХОДЫ ***" skip(1).
            put stream exc unformatted skip(1) "*** ДОХОДЫ ***" skip(1).
        end.
        else if substr(trim(string(r-temp.gl)),1,1) eq "5" then do:
            put skip(1) "*** РАСХОДЫ ***" skip(1).
            put stream exc unformatted skip(1) "*** РАСХОДЫ ***" skip(1).
        end.
        else if substr(trim(string(r-temp.gl)),1,1) eq "6" then do:
            put skip(1) "*** ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 6-ОЙ КЛАСС ) ***" skip(1).
            put stream exc unformatted skip(1) "*** ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 6-ОЙ КЛАСС ) ***" skip(1).
        end.
        else if substr(trim(string(r-temp.gl)),1,1) eq "7" then do:
            put skip(1) "*** ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 7-ОЙ КЛАСС ) ***" skip(1).
            put stream exc unformatted skip(1) "*** ВНЕБАЛАНСОВЫЕ СТАТЬИ ( 7-ОЙ КЛАСС ) ***" skip(1).
        end.
    end. /*if first-of*/

    find d-gl where r-temp.gl = d-gl.gl no-lock no-error.

    display r-temp.totlev ' ' r-temp.gl when d-gl.gldisp r-temp.des form "x(63)"  r-temp.bal1  r-temp.bal2  r-temp.bal3  r-temp.bal4   r-temp.bal5
    r-temp.bal6  r-temp.bal7  r-temp.bal8 r-temp.bal9 r-temp.bal10 r-temp.baltot with width 160 no-label down frame glis1.

    put stream exc unformatted
        r-temp.totlev  " ; "
        if d-gl.gldisp then string(r-temp.gl) else " " " ; "
        r-temp.des form "x(63)"   " ; "
        XLS-NUMBER (r-temp.bal1)  " ; "
        XLS-NUMBER (r-temp.bal2)  " ; "
        XLS-NUMBER (r-temp.bal3)  " ; "
        XLS-NUMBER (r-temp.bal4)  " ; "
        XLS-NUMBER (r-temp.bal5)  " ; "
        XLS-NUMBER (r-temp.bal6)  " ; "
        XLS-NUMBER (r-temp.bal7)  " ; "
        XLS-NUMBER (r-temp.bal8)  " ; "
        XLS-NUMBER (r-temp.bal9)  " ; "
        XLS-NUMBER (r-temp.bal10) " ; "
        XLS-NUMBER (r-temp.baltot) skip.

    if d-gl.nskip ne 0 then down 1 with frame glis1.
end.  /*for each r-temp*/

if vsver[1] ne vsver[2] then do:
    display skip "135100 - 215200 = " vsver[1] - vsver[2]  format "->>>,>>>,>>>,>>9.99"skip.
    put stream exc unformatted skip "135100 - 215200 = " vsver[1] - vsver[2]  format "->>>,>>>,>>>,>>9.99"skip.
end.

if vsver[3] ne vsver[4] then do:
    display "135200 - 215100 = " vsver[3] - vsver[4] format "->>>,>>>,>>>,>>9.99" skip.
    put stream exc unformatted "135200 - 215100 = " vsver[3] - vsver[4] format "->>>,>>>,>>>,>>9.99" skip.
end.

/*--Валютная позиция, id00700, 14-05-2013*/
/*if vsver[3] ne vsver[4] then do:*/
    display "185800 - 285900 = " vsver[5] - vsver[6] format "->>>,>>>,>>>,>>9.99" skip.
    put stream exc unformatted "185800 - 285900 = " vsver[5] - vsver[6] format "->>>,>>>,>>>,>>9.99" skip.
/*end.*/

/*if vsver[3] ne vsver[4] then do:*/
    display "185900 - 285800 = " vsver[7] - vsver[8] format "->>>,>>>,>>>,>>9.99" skip.
    put stream exc unformatted "185900 - 285800 = " vsver[7] - vsver[8] format "->>>,>>>,>>>,>>9.99" skip.
/*end.*/
/*Валютная позиция, id00700, 14-05-2013--*/

hide frame rptbottombb no-pause.

display skip(2)
" =====      КОНЕЦ ДОКУМЕНТА     ====="
SKIP(15)
with frame rptendbb no-box no-label .
output stream exc close.
output close.

define buffer cdser for sysc.
define var size as int format ">>>>>>>>>".

if g-cdlib then do transaction:
    create cdlib.
    find cdser where cdser.sysc eq "CDSER" no-lock.
    find sysc where sysc.sysc eq "CDLIB" no-lock.
    if sysc.daval ne g-today then do:
        sysc.daval = g-today.
        sysc.inval = 1.
    end.
    else sysc.inval = sysc.inval + 1.
    cdlib.cdlib = integer(substring(string(g-today),7,2) + substring(string(g-today),1,2) + substring(string(g-today),4,2) + string(sysc.inval,"999")).
    cdlib.gdt = g-today.
    cdlib.who = g-ofc.
    cdlib.ttl = g-mdes.
    cdlib.cd = cdser.inval.
    cdlib.dest = dest.
    unix silent cp value(vimgfname) value(sysc.chval + "/" + string(cdlib.cdlib)). pause 0.
end.

hide all no-pause.

fname = "konb" + substring(string(vasof),1,2) +  substring(string(vasof),4,2) + ".all".
exname = "konb" + substring(string(vasof),1,2) + substring(string(vasof),4,2) + ".csv".

find sysc where sysc.sysc eq "GLDATE" no-lock no-error.
if v-dat < sysc.daval then do:
    message skip " Балансы уже были сохранены!~n~n Сохранить новый баланс" fname "в каталог" dirc "?"
    skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans as logical.
    if not v-ans then return.
end.

unix silent un-dos rpt.img value(fname). pause 0.


input through value("scp -q " + fname + " Administrator@fs01.metrobank.kz:" + dirc + ";echo $?").
repeat:
    import v-result.
end.
pause 0.

if v-result <> "0" then do:
    message skip " Произошла ошибка при копировании файла" fname "в каталог" dirc "!"
    skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.

/*  FOR EXCEL */
unix silent un-win rpt1.img value(exname).

input through value("scp -q " + exname + " Administrator@fs01.metrobank.kz:" + dirc + ";echo $?" ).
repeat:
    import v-result.
end.
pause 0.

if v-result <> "0" then do:
    message skip " Произошла ошибка при копировании файла" exname "в каталог" dirc "!"
    skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.

/* сохранить созданный файл сразу и в архив тоже! */
input through value("scp -q " + fname + " Administrator@fs01.metrobank.kz:" + dircarc + ";echo $?" ).
repeat:
    import v-result.
end.
pause 0.

if v-result <> "0" then do:
    message skip " Произошла ошибка при копировании файла" fname "в каталог" dircarc "!"
    skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.

  /*  FOR EXCEL */
input through value("scp -q " + exname + " Administrator@fs01.metrobank.kz:" + dircarc + ";echo $?" ).
repeat:
    import v-result.
end.
pause 0.

if v-result <> "0" then do:
    message skip " Произошла ошибка при копировании файла" exname "в каталог" dircarc "!"
    skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end.

/* suchkov - Отправить готовые файлы по почте! */
find sysc where sysc.sysc = "baladr" no-lock no-error.
if not available sysc then message "Не настроен адрес отправки баланса!" view-as alert-box.
else do:
    run mail (sysc.chval,"abpk@metrobank.kz","Баланс", "В приложении содержится консолидированный баланс","1","", fname + ";" + exname ) .
    pause 0 .
end.

find _MyConnection no-lock no-error.
if avail _MyConnection then do:

    find first _Connect no-lock where _Connect-Usr = _MyConn-UserId.

    if _Connect._Connect-Name = "id00700" then do:
        unix silent cptwin value(fname) akelpad.
    end.

    if _Connect._Connect-Name = "id00477" then do:
        unix silent cptwin value(fname) editplus.
    end.

end.