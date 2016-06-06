/*inkst01.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отправка уведомления о возврате ИР при закрытии счета
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
        11/06/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        06/06/2011 evseev - переход на ИИН/БИН
        22/06/2011 evseev - запись в inchist "01INC"
        23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
*/
{global.i}
{chbin.i}
def input parameter v-aaa like aaa.aaa.
def input parameter v-num as integer.
def var v-kref as char no-undo.
def var v-text as char no-undo.
def var v-bankbik as char no-undo.
def var v-file as char no-undo.
def var v-counter as int no-undo.
def var v-str as char no-undo.

def var v-mt100out as char no-undo.
def var v-exist1 as char no-undo.
def stream mt400.

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

  /**/
find last inc100 where inc100.iik = v-aaa and inc100.num = v-num no-lock no-error.
if avail inc100 then do:
  do transaction:
  find first pksysc where pksysc.sysc = "inccou" exclusive-lock no-error.
  if avail pksysc then do:
     pksysc.inval = pksysc.inval + 1.
     v-counter = pksysc.inval.
     find current pksysc no-lock.
  end.
  else do:
     run savelog( "inkaaacls", "inkaaacls: Ошибка определения текущего значения счетчика сообщений!").
     return.
  end.
  end.
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

  v-text = ":12:400".
  put stream mt400 unformatted v-text skip.
  if inc100.vo <> '07' and inc100.vo <> '09' then
  v-text = ":77E:FORMS/WR1/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат инкассового распоряжения".
  if inc100.vo = '07' then
  v-text = ":77E:FORMS/WRP/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат инкассового распоряжения по ОПВ".
  if inc100.vo = '09' then
  v-text = ":77E:FORMS/WRS/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат инкассового распоряжения по СО".
  put stream mt400 unformatted v-text skip.

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

/* положили в терминал для отправки */
  unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).


 /* положили в архив отправленных */
  unix silent value("mv " + v-file + " " + v-mt100out).
  message "Отправлено уведомление о возврате инкассового распоряжения ~nномер ИР " + string(inc100.num,'999999999')  + '~nДата ИР ' + string(inc100.rdt,'99/99/9999') + '~nСумма ИР ' + trim(string(inc100.sum,">,>>>,>>>,>>9.99"))  view-as alert-box title 'ВНИМАНИЕ'.
  do transaction:
    create inchist.
    assign inchist.ref = "INC" + string(v-counter, "9999999999999")
           inchist.incref = inc100.ref
           inchist.rdt = g-today
           inchist.rtm = time.
  end. /* transaction */
  do transaction:
    create inchist.
    assign inchist.ref = "01INC" + string(v-counter, "9999999999999")
           inchist.incref = inc100.ref
           inchist.rdt = g-today
           inchist.rtm = time.
  end. /* transaction */
end.