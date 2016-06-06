/* vcmsgparam.i
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Инициализация параметров, необходимых для создания телеграммы
 * RUN
        
 * CALLER
        vcmsg104.p, vcmsg105.p, vcmsg106.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15.5.2, 15.5.3, 15.5.4
 * AUTHOR
        19.03.2003 nadejda
 * CHANGES
        19.08.2003 nadejda - добавлено удаление тестового файла из домашнего каталога юзера
*/


def var v-dir as char.
def var v-ipaddr as char.
def var v-exitcod as char.
def var v-minus as char.
def var v-plus as char.
def var v-text as char.
def var v-filename as char.
def var v-filename0 as char init "vcmsg.txt".

/* путь к каталогу исходящих телеграмм */
find vcparams where vcparams.parcode = "mttstout" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mttstout !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-dir = vcparams.valchar.


if substr(v-dir, length(v-dir), 1) <> "/" then v-dir = v-dir + "/".
v-dir = v-dir + substr(string(year(g-today), "9999"), 3, 2) + string(month(g-today), "99") + 
  string(day(g-today), "99") + "/".

v-ipaddr = "ntmain.texakabank.kz".

/* проверка существования каталога за сегодняшнее число */
output to sendtest.
put "Ok".
output close .

input through value("rcp sendtest " + v-ipaddr + ":" + v-dir + ";echo $?" ). 
repeat :
  import v-exitcod.
end.

unix silent rm -f sendtest.

if v-exitcod <> "0" then do :
  message skip " Не найден каталог " + replace(v-dir, "/", "\\") 
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

find vcparams where vcparams.parcode = "symminus" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр symminus !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-minus = vcparams.valchar.

find vcparams where vcparams.parcode = "symplus" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр symplus !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-plus = vcparams.valchar.


/* формирование телеграммы */
def stream rpt.
output stream rpt to value(v-filename0).


find vcparams where vcparams.parcode = "ouradres" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр ouradres !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = "\{1:F01" + trim(vcparams.valchar).
v-filename = trim(vcparams.valchar).

find vcparams where vcparams.parcode = "mtresrv1" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtresrv1 !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = v-text + trim(vcparams.valchar).

find vcparams where vcparams.parcode = "mtsessn" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtsessn !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = v-text + trim(vcparams.valchar).

find vcparams where vcparams.parcode = "mtsessnm" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtsessnm !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = v-text + trim(vcparams.valchar) + "\}".
put stream rpt unformatted v-text skip.

find vcparams where vcparams.parcode = "mttyp" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mttyp !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = "\{2:I" + trim(vcparams.valchar).

find vcparams where vcparams.parcode = "mttstadr" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtadres !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = v-text + trim(vcparams.valchar).

find vcparams where vcparams.parcode = "mtresrv2" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtresrv2 !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = v-text + trim(vcparams.valchar) + "U3003}".

put stream rpt unformatted v-text skip.
put stream rpt unformatted "\{4:" skip.

find vcparams where vcparams.parcode = "mt{&msg}-nt" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mt{&msg}-nt !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-filename = v-filename + string(vcparams.valinte + 1, "99999") + "{&msg}".
v-text = ":20:" + v-filename. 
put stream rpt unformatted v-text skip.

find vcparams where vcparams.parcode = "mtext" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtext !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-filename = v-filename + "." + trim(vcparams.valchar).

find vcparams where vcparams.parcode = "mtsubtyp" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtsubtyp !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = ":12:" + string(vcparams.valinte).
put stream rpt unformatted v-text skip.

find vcparams where vcparams.parcode = "mtkeywrd" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtkeywrd !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-text = ":77E:/" + trim(vcparams.valchar) + "/{&msg}".
put stream rpt unformatted v-text skip.

