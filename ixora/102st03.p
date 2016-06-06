/* 102st03.p
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
        --/--/2008 alex
 * BASES
        BANK COMM
 * CHANGES
       10.06.2009 galina - добавила параметр p-vo
       26.06.2009 galina - небольшие испраления в формате сообщения
       06/06/2011 evseev - переход на ИИН/БИН
       22/06/2011 evseev - запись в inchist "03INC"
       23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
*/

{global.i}
{chbin.i}
def input parameter p-vo as char.
def shared temp-table t-inc no-undo
    field jss like inc100.jss
    field iik like inc100.iik
    field crc like inc100.crc
    field sum like inc100.sum
    field num like inc100.num
    field ref like inc100.ref
    field stat2 like inc100.stat2
    field vo like inc100.vo
    field bin like inc100.bin.

def var v-crc like inc100.crc no-undo.
def var v-sumans as dec no-undo.

def var v-text as char no-undo.
def var v-bankbik as char no-undo.
def var v-file as char no-undo.


def var v-counter as int no-undo.
def var v-str as char no-undo.

def var v-kol as int no-undo.
def var v-kref as char no-undo.

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


/* постановка в картотеку */
v-str = "".

find first pksysc where pksysc.sysc = "inccou" exclusive-lock no-error.
if not avail pksysc then return.
else pksysc.inval = pksysc.inval + 1.
find current pksysc no-lock.
v-counter = pksysc.inval.

v-kref = string(v-counter, "999999").
v-file = 'INC' + string(v-counter, "9999999999999") + ".txt".
output stream mt400 to value(v-file).

v-text = "\{1:F01K054700000000010" + v-kref + "\}".
put stream mt400 unformatted v-text skip.

v-text = "\{2:I998KNALOG000000N2020\}".
put stream mt400 unformatted v-text skip.

v-text = "\{4:".
put stream mt400 unformatted v-text skip.

v-text = ":20:INC" + string(v-counter, "9999999999999").
put stream mt400 unformatted v-text skip.

v-text = ":12:400".
put stream mt400 unformatted v-text skip.

if p-vo = '09' then do:
  v-text = ":77E:FORMS/P3S/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Помещение инк. распоряжений по СО в картотеку".
  put stream mt400 unformatted v-text skip.
end.

if p-vo = '07' then do:
  v-text = ":77E:FORMS/P3P/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Помещение инк. распоряжений по ОПВ в картотеку".
  put stream mt400 unformatted v-text skip.
end.

{sysc.i}
v-bankbik = get-sysc-cha("clecod").

v-text = "/BANK/" + v-bankbik.
put stream mt400 unformatted v-text skip.

v-sumans = 0.
v-kol = 0.

for each t-inc where t-inc.vo = p-vo no-lock:
    if v-bin then v-text = "//07/" + t-inc.bin + "/" + string(t-inc.iik) + "/" + t-inc.crc + "/" + replace(trim(string(t-inc.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(t-inc.num) + "/" + t-inc.ref + "/" + t-inc.stat2.
    else  v-text = "//07/" + t-inc.jss + "/" + string(t-inc.iik) + "/" + t-inc.crc + "/" + replace(trim(string(t-inc.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(t-inc.num) + "/" + t-inc.ref + "/" + t-inc.stat2.
    put stream mt400 unformatted v-text skip.
    v-sumans = v-sumans + t-inc.sum.
    v-kol = v-kol + 1.
    v-crc = t-inc.crc.

    find first inc100 where inc100.num eq t-inc.num and inc100.iik eq t-inc.iik no-lock no-error.
    create inchist.
    assign inchist.ref = "INC" + string(v-counter, "9999999999999")
           inchist.incref = inc100.ref
           inchist.rdt = g-today
           inchist.rtm = time.
    create inchist.
    assign inchist.ref = "03INC" + string(v-counter, "9999999999999")
           inchist.incref = inc100.ref
           inchist.rdt = g-today
           inchist.rtm = time.
end.

v-text = "/TOTAL/" + string(v-kol) + "/" + v-crc + "/" + replace(trim(string(v-sumans, ">>>>>>>>>>>>9.99")), ".", ",").
put stream mt400 unformatted v-text skip.

v-text = "-\}".
put stream mt400 unformatted v-text.

output stream mt400 close.


/*unix silent value('echo "" >> mt.txt').
unix silent value("/pragma/bin9/win2dos mt.txt " + v-file).*/
unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /* положили в терминал для отправки */
unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
