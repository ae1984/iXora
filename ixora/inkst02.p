/* inkst02.p
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
        02/12/2008 alex - убрал перикодировку в DOS
        10/06/2009 galina - добавила обработку ОПВ и СО
        15.06.2009 galina - исправила ошибку при выводе поля 400:
        06/06/2011 evseev - переход на ИИН/БИН
        22/06/2011 evseev - запись в inchist "02INC"
        23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
        24/06/2011 evseev - добавил пробел между комментом и unix silent
        17.09.2012 evseev - ТЗ-1445

*/

{global.i}
{chbin.i}
def input parameter v-aaa like aas.aaa no-undo.
def input parameter v-num like aas.fnum no-undo.
def input parameter v-rgref like aas.rgref no-undo.

def var v-crc like inc100.crc no-undo.
def var v-sumans as dec no-undo.
def var v-kol as int no-undo.
def var v-kref as char no-undo.
def var v-text as char no-undo.
def var v-bankbik as char no-undo.
def var v-file as char no-undo.
def var v-counter as int no-undo.
def var v-str as char no-undo.

def var v-mt100out as char no-undo.
def var v-exist1 as char no-undo.

def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.
v-term = sysc.chval.

v-mt100out = "/data/export/inkarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-mt100out + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-mt100out).
    unix silent value("chmod 777 " + v-mt100out).
end.

def stream mt400.



do transaction:
    find last inc100 where inc100.iik eq v-aaa and inc100.num eq integer(v-num) and inc100.rgref = v-rgref exclusive-lock no-error.
    if not avail inc100 then return.

    find first pksysc where pksysc.sysc = "inccou" exclusive-lock no-error.
    if avail pksysc then do:
        pksysc.inval = pksysc.inval + 1.
        v-counter = pksysc.inval.
        find current pksysc no-lock.
    end.
    else do:
        run savelog( "inkps", "inkst02: Ошибка определения текущего значения счетчика сообщений!").
        return.
    end.

    inc100.stat2 = "02".
    inc100.mnu = "returned".
    find current inc100 no-lock no-error.
end. /* transaction */

if (not avail inc100) or (inc100.mnu <> "returned") then return.

v-kref = string(v-counter, "999999").
v-file = 'INC' + string(v-counter, "9999999999999") + ".txt".

output stream mt400 to value(v-file).

v-text = "\{1:F01K054700000000010" + v-kref + "\}".
put stream mt400 unformatted v-text skip.

v-text = "\{2:I998KNALOG000000U3003\}".
put stream mt400 unformatted v-text skip.

v-text = "\{4:".
put stream mt400 unformatted v-text skip.

v-text = ":20:INC" + string(v-counter, "9999999999999").
put stream mt400 unformatted v-text skip.

v-file = string(v-counter, "999999999") + ".txt".

v-text = ":12:400".
put stream mt400 unformatted v-text skip.

if inc100.vo = '07' then do:
    v-text = ":77E:FORMS/WRP/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат инкассового распоряжения по ОПВ".
    put stream mt400 unformatted v-text skip.
end.

if inc100.vo = '09' then do:
    v-text = ":77E:FORMS/WRS/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат инкассового распоряжения по СО".
    put stream mt400 unformatted v-text skip.
end.


if inc100.vo <> '09' and inc100.vo <> '07' then do:
    v-text = ":77E:FORMS/WR1/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат инкассового распоряжения".
    put stream mt400 unformatted v-text skip.
end.

{sysc.i}
v-bankbik = get-sysc-cha("clecod").

v-text = "/BANK/" + v-bankbik.
put stream mt400 unformatted v-text skip.

if v-bin then v-text = "/PLAT/" + inc100.bin + "/" + string(inc100.iik,'x(20)') + "/" + inc100.name.
else v-text = "/PLAT/" + inc100.jss + "/" + string(inc100.iik,'x(20)') + "/" + inc100.name.
put stream mt400 unformatted v-text format "x(70)" skip.

v-text = "/REFDOC/KZT/" + replace(trim(string(inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(inc100.num) + "/" + string(year(inc100.dtz) mod 1000,'99') + string(month(inc100.dtz),'99') + string(day(inc100.dtz),'99') + "/" + inc100.ref.
put stream mt400 unformatted v-text skip.

v-text = "/REASON/" + inc100.stat2.
put stream mt400 unformatted v-text skip.

v-text = "-\}".
put stream mt400 unformatted v-text skip.

output stream mt400 close.

/*unix silent value('echo "" >> ' + v-file).
unix silent value("/pragma/bin9/win2dos mt.txt " + v-file).*/
unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /* положили в терминал для отправки */
unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */

do transaction:
    create inchist.
    assign inchist.ref = "INC" + string(v-counter, "9999999999999")
           inchist.incref = inc100.ref
           inchist.rdt = g-today
           inchist.rtm = time.
end. /* transaction */

do transaction:
    create inchist.
    assign inchist.ref = "02INC" + string(v-counter, "9999999999999")
           inchist.incref = inc100.ref
           inchist.rdt = g-today
           inchist.rtm = time.
end. /* transaction */
