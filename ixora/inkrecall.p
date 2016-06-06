/* inkrecall.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        17/11/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        27/11/2008 alex - перенёс обработку в отдельную программу
        02/12/2008 alex - убрал перикодировку DOS
        10/12/2008 alex - принятие отзывов до 18:00
        25/12/2008 alex - добавил проверку валюты счета (поле /PLAT/)
        04.04.2009 galina - исправила определение валюта счета
        02/06/2011 evseev - переход на ИИН/БИН
*/

def shared var g-today as date.
def shared var g-ofc like ofc.ofc.

def var v-str       as char no-undo.
def var i           as int no-undo.

def var v-ref       like inkor1.ref no-undo.
def var v-dt        like inkor1.dt no-undo.
def var v-num       like inkor1.num no-undo.
def var v-jss       like inkor1.jss no-undo.
def var v-clbin       like inkor1.bin no-undo.
def var v-aaa       like inkor1.aaa no-undo.
def var v-aaacrc    as char no-undo.
def var v-name      like inkor1.name no-undo.
def var v-crc       like inkor1.crc no-undo.
def var v-sum       like inkor1.sum no-undo.
def var v-inknum    like inkor1.inknum no-undo.
def var v-inkdt     like inkor1.inkdt no-undo.
def var v-inkref    like inkor1.inkref no-undo.
def var v-rson      like inkor1.rson no-undo.

def var v-rdt       like inkor1.rdt no-undo.
def var v-rtm       like inkor1.rtm no-undo.
def var v-stat      like inkor1.stat no-undo.
def var v-stat2     like inkor1.stat2 no-undo.
def var v-bankbik   as char no-undo.
def var v-file      as char no-undo.

def var v-filename  as char no-undo.
def var v-tsnum     as int no-undo.

def var v-text      as char no-undo.

def temp-table t-s400 no-undo
    field num as int
    field str as char format "x(70)"
    index idx is primary num.

def stream r-str.
def stream mt400.
def stream r-in.

def var v-mt100in   as char no-undo.
def var v-exist1    as char no-undo.
def var v-files0    as char no-undo.
def var v-files     as char no-undo.
def var v-txt       as char no-undo.

{chbin.i}

def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.
v-term = sysc.chval.


input through value( "find /tmp/inc100in/; echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir /tmp/inc100in/").
    unix silent value("chmod 777 /tmp/inc100in/").
end.
else unix silent value ("rm -f /tmp/inc100in/*.*").

v-files0 = "".

input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -lis ":77E:FORMS/OR1/" ' + replace(v-term,'/','\\\\') + 'Out\\\\*.998').

repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:
/* test v-str = entry(num-entries(v-str, "/"), v-str, "/"). */
        v-str = entry(num-entries(v-str, "\\"), v-str, "\\").
        if v-files0 <> "" then v-files0 = v-files0 + "|".
        v-files0 = v-files0 + v-str.
    end.
end.

v-files = ''.
do i = 1 to num-entries(v-files0, "|"):
    find first inkor1 where inkor1.rdt = g-today and inkor1.filename = entry(i, v-files0, "|") no-lock no-error.
    if not avail inkor1 then do:
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + entry(i, v-files0, "|").
    end.
end.

if v-files = '' then return.

v-mt100in = "/data/import/inkarc/" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + "/".
input through value( "find " + v-mt100in + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-mt100in).
    unix silent value("chmod 777 " + v-mt100in).
end.

do i = 1 to num-entries(v-files, "|"):

    v-str = "".

    input through value('scp -q Administrator@db01:' + replace(v-term,'/','\\\\') + 'OUT\\\\' + entry(i, v-files, "|") + ' /tmp/inc100in/' + entry(i, v-files, "|") + ' ;echo $?').
    import unformatted v-str.
    if v-str <> "0" then do:
        run savelog( "inkps", "inkrecall: Ошибка копирования файлов mt100 из терминала!").
        return.
    end.
end.

unix silent value('cp /tmp/inc100in/*.998 ' + v-mt100in).

v-str = "".

do i = 1 to num-entries(v-files, "|"):
    v-stat = "".
    v-filename = entry(i, v-files, "|").

    unix silent value('echo "" >> /tmp/inc100in/' + v-filename). /* на случай если нет возврата каретки в последней строке - добавляем */
    /*
    unix silent value("/pragma/bin9/dos-un /tmp/inc100in/" + v-filename + " /tmp/inc100in/r" + v-filename).
    unix silent value("rm -f /tmp/inc100in/" + v-filename).
    unix silent value("mv /tmp/inc100in/r" + v-filename + " /tmp/inc100in/" + v-filename).
*/

    empty temp-table t-s400.
    assign v-tsnum = 0 v-str = "".

    input stream r-in from value("/tmp/inc100in/" + v-filename).

    repeat:
        import stream r-in unformatted v-txt.
        if v-txt ne "" then do:
            create t-s400.
            assign t-s400.num = v-tsnum
                t-s400.str = v-txt.
        end.
        v-tsnum = v-tsnum + 1.
    end.

    input stream r-in close.

    find first t-s400 where t-s400.str begins ":20:" no-lock no-error.
    if avail t-s400 then v-ref = entry(3, t-s400.str, ":").

    find first t-s400 where t-s400.str begins ":77E:" no-lock no-error.
    if avail t-s400 then do:
        v-dt = date(substr(entry(3, t-s400.str, "/"), 5, 2) + substr(entry(3, t-s400.str, "/"), 3, 2) + substr(entry(3, t-s400.str, "/"), 1, 2)).
        v-num = int(entry(4, t-s400.str, "/")).
    end.

    find first t-s400 where t-s400.str begins "/PLAT/" no-lock no-error.
    if avail t-s400 then do:
        if v-bin then do:
           v-jss = ''.
           v-clbin = entry(3, t-s400.str, "/").
        end.
        else do:
           v-clbin = ''.
           v-jss = entry(3, t-s400.str, "/").
        end.
        v-aaa = entry(4, t-s400.str, "/").
        v-aaacrc = "".
        if length(v-aaa) > 20 then do:
            v-aaacrc = substring(v-aaa, 21).
            v-aaa = substring(v-aaa, 1, 20).
        end.
        v-name = entry(5, t-s400.str, "/").
    end.

    find first t-s400 where t-s400.str begins "/REFDOC/" no-lock no-error.
    if avail t-s400 then do:
        t-s400.str = replace(t-s400.str, ",", ".").
        v-crc = entry(3, t-s400.str, "/").
        v-sum = dec(entry(4, t-s400.str, "/")).
        v-inknum = int(entry(5, t-s400.str, "/")).
        v-inkdt = date(entry(6, t-s400.str, "/")).
        v-inkref = entry(7, t-s400.str, "/").
    end.

    find first t-s400 where t-s400.str begins "/REASON/" no-lock no-error.
    if avail t-s400 then v-rson = entry(3, t-s400.str, "/").

    if (time ge 64800) or (g-today <> today) then v-stat = "wait". else v-stat = "".

    find first inkor1 where inkor1.ref eq v-ref no-lock no-error.
    if not avail inkor1 then do:
        create inkor1.
        assign inkor1.ref = v-ref
            inkor1.num    = v-num
            inkor1.dt     = v-dt
            inkor1.jss    = v-jss
            inkor1.aaa    = v-aaa
            inkor1.name   = v-name
            inkor1.crc    = v-crc
            inkor1.sum    = v-sum
            inkor1.inknum = v-inknum
            inkor1.inkdt  = v-inkdt
            inkor1.inkref = v-inkref
            inkor1.rson   = v-rson
            inkor1.filename = v-filename
            inkor1.rdt    = g-today
            inkor1.rtm    = time
            inkor1.stat   = v-stat
            inkor1.reschar[5] = v-aaacrc
            inkor1.bin    = v-clbin.

    end.
end.


