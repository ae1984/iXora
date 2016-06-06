/* inkrgin.p
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
        02/12/2008 alex - убрал перикодировку DOS
        11/10/2011 evseev - в стр. 74 добавил конечную папку OUT
*/

def shared var g-today as date.
def shared var g-ofc like ofc.ofc.

def var v-str       as char no-undo.
def var v-files     as char no-undo.
def var v-files0    as char no-undo.
def var v-exist1    as char no-undo.
def var v-mt100in   as char no-undo.
def var i           as int no-undo.
def var v-filename  as char no-undo.
def var v-tsnum     as int no-undo.
def var v-txt       as char no-undo.
def var v-amount    as int no-undo.
def var v-ref       as char no-undo.
def var v-dt        as date no-undo.
def var v-type      as char no-undo.
def var v-num       as int no-undo.
def var v-form      as char init "40,WP,WS".

def stream r-in.

def temp-table t-s400 no-undo
    field num as int
    field str as char format "x(100)"
    index idx is primary num.

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


v-files0 = ''.

do i = 1 to num-entries(v-form):
    input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -Elis ":77E:FORMS/R' + trim(entry(i, v-form)) + '/" ' + replace(v-term + "/OUT",'/','\\\\') + '\\\\*.998').
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        if v-str <> '' then do:
            v-str = entry(num-entries(v-str, "\\"), v-str, "\\").
            if v-files0 <> "" then v-files0 = v-files0 + "|".
            v-files0 = v-files0 + v-str.
            /*displ v-str.*/
        end.
    end.
end.


v-files = ''.
do i = 1 to num-entries(v-files0, "|"):
    find first increg where increg.rdt = g-today and increg.filename = entry(i, v-files0, "|") no-lock no-error.
    if not avail increg then do:
        if v-files <> "" then v-files = v-files + "|".
        v-files = v-files + entry(i, v-files0, "|").
    end.
end.

if v-files = '' then return.

v-mt100in = "/data/import/inkarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-mt100in + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-mt100in).
    unix silent value("chmod 777 " + v-mt100in).
end.

do i = 1 to num-entries(v-files, "|"):
    v-str = ''.
    input through value('scp -q Administrator@db01:' + replace(v-term,'/','\\\\') + 'OUT\\\\' + entry(i, v-files, "|") + ' /tmp/inc100in/' + entry(i, v-files, "|") + ' ;echo $?').
    import unformatted v-str.
    if v-str <> "0" then do:
        run savelog( "inkps", "inkrgin: Ошибка копирования файлов из терминала!").
        return.
    end.
end.
unix silent value('cp /tmp/inc100in/*.998 ' + v-mt100in).

do i = 1 to num-entries(v-files, "|"):

    v-filename = entry(i, v-files, "|").

    unix silent value('echo "" >> /tmp/inc100in/' + v-filename). /* на случай если нет возврата каретки в последней строке - добавляем */
    /*
    unix silent value("/pragma/bin9/dos-un /tmp/inc100in/" + v-filename + " /tmp/inc100in/r" + v-filename).
    unix silent value("rm -f /tmp/inc100in/" + v-filename).
    unix silent value("mv /tmp/inc100in/r" + v-filename + " /tmp/inc100in/" + v-filename).
*/

    empty temp-table t-s400.

    v-tsnum = 0.
    v-str = "".

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

    find first t-s400 where t-s400.str begins "/TOTAL/" no-lock no-error.
    if avail t-s400 then v-amount = int(entry(3, t-s400.str, "/")).

    find first t-s400 where t-s400.str begins ":77E:" no-lock no-error.
    if avail t-s400 then do:
        v-type = entry(2, t-s400.str, "/").
        v-dt = date(substr(entry(3, t-s400.str, "/"), 5, 2) + substr(entry(3, t-s400.str, "/"), 3, 2) + substr(entry(3, t-s400.str, "/"), 1, 2)).
        v-num = int(entry(4, t-s400.str, "/")).
    end.

    find first increg where increg.ref eq v-ref no-lock no-error.
    if not avail increg then do:
        create increg.
        assign increg.ref = v-ref
            increg.type = v-type
            increg.num = v-num
            increg.dt = v-dt
            increg.rdt = g-today
            increg.rtm = time
            increg.amount = v-amount
            increg.filename = v-filename.
    end.

end.
