/* valpozsv.p
 * MODULE

 * DESCRIPTION
        Валютная позиция (Сводная)
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        7.4.3.5
 * BASES
        BANK COMM
 * AUTHOR
        05.02.2002 nataly
 * CHANGES
        13.12.2003 nataly   - введена переменная v-ast1 тк не учитывалось отсутсвие оборотов на Атырау
        10.02.2004 nadejda  - переделано в один цикл
        07.03.2004 sasco    - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        11/02/2005 nataly   - добавила счет sysc.sysc = "vadip5", доработала прогу в Excel
        10/10/2006 u00600   - добавила условие if avail crchis
        19.09.2011 damir    - просто подкинул в библиотеку.
        10.10.2011 damir    - в round убрал округление до 2 знаков после запятой.
        19.06.2012 damir    - добавил Южно-Африканский ранд ZAR; для i = 3 расчет v-bal = v-bal - v-sum1 - v-sum2.
        25.06.2012 damir    - добавил p-date,p-option,p-file.
        04.07.2012 damir    - убрал input parameter p-file, добавил RepPath,RepName,stream rep, Канадский Доллар (CAD).
        23.10.2012 damir    - Внедрено Т.З. № 1491.Выявлена ошибка,устранено,добавил запись в файл valpozsv.htm.
*/

{global.i}

def input parameter  p-date   as date.
def input parameter  p-option as char.

def new shared var v-stop   as logi init false.
def new shared var tt1      as char extent 13.
def new shared var vcrc     as inte format ">9" .
def new shared var vbal     as deci decimals 2 format "-z,zzz,zzz,zz9.99" .
def new shared var vbeur    as deci format "-z,zzz,zzz,zz9.99".
def new shared var vrate    as deci .
def new shared var dat1     as date format "99/99/9999".
def new shared var v-ast    as logi init true.
def new shared var i        as inte init 1.
def new shared var j        as inte init 11.
def new shared var v-sum1   as deci.
def new shared var v-sum2   as deci.

def shared var RepPath as char init "/data/reports/valpoz/".
def shared var RepName as char.

def temp-table gll field gllist as char format "x(10)".

def var vasof       as date.
def var savefile    as char.
def var v-ast1      as logi.
def var vtitle-1    as char format "x(80)".
def var vdes        like crc.des.
def var pcrc        like crc.crc initial 1.
def var bbal        like glbal.bal.
def var tt          as char.
def var tt-ast      as char.
def var v-gll       as char format "x(10)".
def var v-name      like gl.des init "".
def var vgl         like pglbal.gl.
def var hostmy      as char format "x(15)".
def var dirc        as char format "x(15)".
def var ipaddr      as char format "x(15)".
def var v-str       as char.

def stream rep.
def stream bal.

dirc = "c:/valpoz".

find sysc where sysc.sysc eq "GLDATE" no-lock no-error.
vasof = sysc.daval.

/*********************/
find sysc where sysc.sysc = "vadia1" no-lock no-error.
tt = sysc.chval .
tt1[1] = sysc.chval.
find sysc where sysc.sysc = "vadia2" no-lock no-error.
tt = tt + sysc.chval .
tt1[2] = sysc.chval.
find sysc where sysc.sysc = "vadia3" no-lock no-error.
tt = tt + sysc.chval .
tt1[3] = sysc.chval.
find sysc where sysc.sysc = "vadia4" no-lock no-error.
tt = tt + sysc.chval .
tt1[4] = sysc.chval.
find sysc where sysc.sysc = "vadia5" no-lock no-error.
tt = tt + sysc.chval .
tt1[5] = sysc.chval.
find sysc where sysc.sysc = "vadia6" no-lock no-error.
tt = tt + sysc.chval .
tt1[6] = sysc.chval.
find sysc where sysc.sysc = "vadip2" no-lock no-error.
tt = tt + sysc.chval .
tt1[7] = sysc.chval.
find sysc where sysc.sysc = "vadip3" no-lock no-error.
tt = tt + sysc.chval .
tt1[8] = sysc.chval.
find sysc where sysc.sysc = "vadip4" no-lock no-error.
tt = tt + sysc.chval .
tt1[9] = sysc.chval.
find sysc where sysc.sysc = "vadip5" no-lock no-error.
tt = tt + sysc.chval .
tt1[10] = sysc.chval.
find sysc where sysc.sysc = "vadip6" no-lock no-error.
tt = tt + sysc.chval .
tt1[11] = sysc.chval.
find sysc where sysc.sysc = "vadiv1" no-lock no-error.
tt1[12] = sysc.chval.
find sysc where sysc.sysc = "vadiv2" no-lock no-error.
tt1[13] = sysc.chval.

if p-option = "valpozsv0" then do:
    apply "go" to this-procedure.

    {image1.i valpozsv.htm}

    find last cls no-lock no-error.
    dat1 = cls.whn.
    find sysc where sysc.sysc eq "BEGDAY" no-lock no-error.
    update dat1 label " Укажите дату " format "99/99/9999" validate (dat1 >= sysc.daval and dat1 < g-today, "Дата меньше начала работы или больше текущей!") skip
    with side-label row 5 centered frame opt.
    update dirc label " Каталог " help " Ваш директорий для валютной позиции "
    with centered side-label row 8 frame opt.

    {image2.i}
    {report1.i 59}
end.

if p-option = "CRCPOS" then do:
    dat1 = p-date.
    output stream rep to value(RepPath + RepName).
end.

/* для внебалансовых v-txb and v-ast сделано только для ГО*/
do i = 1 to 13 :
    for each crc where crc.crc > 1 no-lock use-index crc:
        if crc.sts <> 0 then next.
        vcrc = crc.crc.
        vdes = crc.des.

        find last crchis where crchis.crc = crc.crc and crchis.rdt <= dat1 no-lock no-error.

        if avail crchis then vrate = crchis.rate[1].
        else vrate = 0 .

        {r-branch.i &proc = "r-valpozsv3"}

        if i = 3 then vbal = vbal - v-sum1 - v-sum2.

        v-ast1 = (vcrc =  2 or vcrc = 4 or vcrc = 3 or vcrc = 6 or vcrc = 7 or vcrc = 8 or vcrc = 9 or vcrc = 10 or vcrc = 11).
        if (v-ast or v-ast1)  then do:
            if i > 10 and vbal < 0 then vbal = 0.
            vbal = Round(vbal / 1000, 0).
            if p-option = "valpozsv0" then put vbal ";" vcrc ";" skip.
            if p-option = "CRCPOS" then put stream rep unformatted string(vbal,"zzzzzzzzzzzzzzz9.99") ";" string(vcrc,"z9") ";" skip.
        end.
        assign vbal = 0 v-sum1 = 0 v-sum2 = 0.
    end.
end.

if p-option = "valpozsv0" then output close.
if p-option = "CRCPOS" then output stream rep close.

/*******************************/

if p-option = "valpozsv0" then do:
    output stream bal to value('valpozsv.txt').
    input from value('valpozsv.htm') no-echo.
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches '*page-break-before:always*' then do:
                v-str = replace(v-str,'page-break-before:always','').
                next.
            end.
            if v-str matches '**' then do:
                v-str = replace(v-str,'','').
                next.
            end.
            leave.
        end.
        put stream bal unformatted v-str skip.
    end.
    output stream bal close.

    input through askhost.
        repeat:
            import hostmy.
        end.
    input close.

    input through value("scp -q valpozsv.txt Administrator@" + hostmy + ":" + dirc + ";echo $?").
    pause 0.
    /* открыть файл в joe/prit/cptwo */
    {image3.i no}
end.

/*run menu-prt("valpozsv.txt").
pause 0.*/

return.