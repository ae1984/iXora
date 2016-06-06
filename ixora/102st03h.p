/* 102st03h.p
 * MODULE
       Клиенты и счета
 * DESCRIPTION
       Отправка сообщения о постановке на картотеку ИР по ОПВ и СО
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
        07/10/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        06/06/2011 evseev - переход на ИИН/БИН
        22/06/2011 evseev - запись в inchist "03hINC"
        23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
*/

{global.i}
{chbin.i}
def input parameter p-ref as char.

def var v-text as char no-undo.
def var v-bankbik as char no-undo.
def var v-file as char no-undo.
def var v-counter as int no-undo.
def var v-str as char no-undo.

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

find first inc100 where inc100.ref eq p-ref no-lock no-error.
if not avail inc100 then next.

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

if inc100.vo = '09' then do:
  v-text = ":77E:FORMS/P3S/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Помещение инк. распоряжений по СО в картотеку".
  put stream mt400 unformatted v-text skip.
end.

if inc100.vo = '07' then do:
  v-text = ":77E:FORMS/P3P/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Помещение инк. распоряжений по ОПВ в картотеку".
  put stream mt400 unformatted v-text skip.
end.

{sysc.i}
v-bankbik = get-sysc-cha("clecod").

v-text = "/BANK/" + v-bankbik.
put stream mt400 unformatted v-text skip.


if v-bin then v-text = "//07/" +  inc100.bin + "/" +  string(inc100.iik,'x(20)') + "/" +  inc100.crc + "/" + replace(trim(string( inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string( inc100.num) + "/" +  inc100.ref + "/" +  inc100.stat2.
else v-text = "//07/" +  inc100.jss + "/" +  string(inc100.iik,'x(20)') + "/" +  inc100.crc + "/" + replace(trim(string( inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string( inc100.num) + "/" +  inc100.ref + "/" +  inc100.stat2.
put stream mt400 unformatted v-text skip.

create inchist.
assign inchist.ref = "INC" + string(v-counter, "9999999999999")
       inchist.incref = inc100.ref
       inchist.rdt = g-today
       inchist.rtm = time.

create inchist.
assign inchist.ref = "03hINC" + string(v-counter, "9999999999999")
       inchist.incref = inc100.ref
       inchist.rdt = g-today
       inchist.rtm = time.

v-text = "/TOTAL/1/" + inc100.crc + "/" + replace(trim(string(inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",").
put stream mt400 unformatted v-text skip.

v-text = "-\}".
put stream mt400 unformatted v-text.

output stream mt400 close.


unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).  /* положили в терминал для отправки */
input through value( "ssh Administrator@db01 dir /B " + replace(v-term,'/','\\\\') + "IN\\\\" + v-file).
/*unix silent value("scp -q " + v-file + " Administrator@db01:C:/STAT/NK/IN").
input through value( "ssh Administrator@db01 dir /B C:\\\\STAT\\\\NK\\\\IN\\\\" + v-file).*/
repeat:
 import unformatted v-str.
end.
if v-str = v-file then message "Сообщение отправлено" view-as alert-box.
unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
unix silent value("rm -f " + v-file). /* положили в архив отправленных */
