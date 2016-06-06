/* insrecall.p
 * MODULE
        Название модуля
 * DESCRIPTION
       Загрузка отзывов РПРО
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
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        08/06/2011 evseev - переход на ИИН/БИН
*/

{chbin.i}

def shared var g-today as date.
def shared var g-ofc    like ofc.ofc.

def var v-str       as char no-undo.
def var i           as int no-undo.

def var v-ref       like insrec.ref no-undo.
def var v-dt        like insrec.dt no-undo.
def var v-num       like insrec.num no-undo.
def var v-jss       like insrec.jss no-undo.
def var v-clbin       like insrec.bin no-undo.
def var v-name      like insrec.name no-undo.
def var v-insnum    like insrec.insnum no-undo.
def var v-insdt     like insrec.insdt no-undo.
def var v-insref    like insrec.insref no-undo.
def var v-rson      like insrec.rson no-undo.

def var v-rdt       like insrec.rdt no-undo.
def var v-rtm       like insrec.rtm no-undo.
def var v-stat      like insrec.stat no-undo.
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

def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.
v-term = sysc.chval.

input through value( "find /tmp/insin/; echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir /tmp/insin/").
    unix silent value("chmod 777 /tmp/insin/").
end.
else unix silent value ("rm -f /tmp/insin/*.*").

v-files0 = "".

input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -lis ":77E:FORMS/ACR/" ' + replace(v-term,'/','\\\\') + 'Out\\\\*.998').
/*тестовый сервер*/
/*input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -Elis ":77E:FORMS/ACR/" C:\\\\STAT\\\\NK\\\\IN\\\\*.998').*/


repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:
        v-str = entry(num-entries(v-str, "\\"), v-str, "\\").
        if v-files0 <> "" then v-files0 = v-files0 + "|".
        v-files0 = v-files0 + v-str.
    end.
end.

v-files = ''.
do i = 1 to num-entries(v-files0, "|"):
    find first insrec where insrec.rdt = g-today and insrec.filename = entry(i, v-files0, "|") no-lock no-error.
    if not avail insrec then do:
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + entry(i, v-files0, "|").
    end.
end.

if v-files = '' then return.

v-mt100in = "/data/import/insarc/" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + "/".
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

    input through value('scp -q Administrator@db01:' + replace(v-term,'/','\\\\') + 'OUT\\\\' + entry(i, v-files, "|") + ' /tmp/insin/' + entry(i, v-files, "|") + ' ;echo $?').
    /*тестовый сервер
    input through value('scp -q Administrator@db01:\\\\STAT\\\\NK\\\\IN\\\\' + entry(i, v-files, "|") + ' /tmp/insin/' + entry(i, v-files, "|") + ' ;echo $?').*/

    import unformatted v-str.
    if v-str <> "0" then do:
        run savelog( "insps", "insrecall: Ошибка копирования файлов mt100 из терминала!").
        return.
    end.
end.

unix silent value('cp /tmp/insin/*.998 ' + v-mt100in).

v-str = "".

do i = 1 to num-entries(v-files, "|"):
    v-stat = "".
    v-filename = entry(i, v-files, "|").

    unix silent value('echo "" >> /tmp/insin/' + v-filename). /* на случай если нет возврата каретки в последней строке - добавляем */

    empty temp-table t-s400.
    assign v-tsnum = 0 v-str = "".

    input stream r-in from value("/tmp/insin/" + v-filename).

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
        v-num = entry(4, t-s400.str, "/").
    end.

    find first t-s400 where t-s400.str begins "/PLAT/" no-lock no-error.
    if avail t-s400 then do:
        if v-bin then do:
           v-jss = ''.
           v-clbin =  entry(3,t-s400.str, "/").
        end. else do:
           v-clbin = ''.
           v-jss =  entry(3,t-s400.str, "/").
        end.

        v-name = entry(4, t-s400.str, "/").
    end.

    find first t-s400 where t-s400.str begins "/REFDOC/" no-lock no-error.
    if avail t-s400 then do:

        v-insnum = entry(3, t-s400.str, "/").
        v-insdt = date(substr(entry(4,t-s400.str, "/"),5,2) + substr(entry(4,t-s400.str, "/"),3,2) + substr(entry(4,t-s400.str, "/"),1,2)).
        v-insref = entry(5, t-s400.str, "/").
    end.

    find first t-s400 where t-s400.str begins "/REASON/" no-lock no-error.
    if avail t-s400 then v-rson = entry(3, t-s400.str, "/").

    if (time ge 64800) or (g-today <> today) then v-stat = "wait". else v-stat = "".

    find first insrec where insrec.ref eq v-ref no-lock no-error.
    if not avail insrec then do:
        create insrec.
        assign insrec.ref = v-ref
            insrec.num    = v-num
            insrec.dt     = v-dt
            insrec.jss    = v-jss
            insrec.bin    = v-clbin
            insrec.name   = v-name
            insrec.insnum = v-insnum
            insrec.insdt  = v-insdt
            insrec.insref = v-insref
            insrec.rson   = v-rson
            insrec.filename = v-filename
            insrec.rdt    = g-today
            insrec.rtm    = time
            insrec.stat   = v-stat.
    end.
end.


