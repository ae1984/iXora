/* vcmsgparam_new.i
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Инициализация параметров, необходимых для создания телеграммы
 * RUN
        
 * CALLER
        vcmsg106.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15.5.4
 * AUTHOR
        11.04.2008 galina
*/


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

find vcparams where vcparams.parcode = "mtadres" no-lock no-error.
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

find vcparams where vcparams.parcode = "mt{&msg}-n" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mt{&msg}-n !"
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