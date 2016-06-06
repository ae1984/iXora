/* histloadfile.p
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
        09.04.2013 evseev tz-1678
 * BASES
        BANK COMM
 * CHANGES
        22/07/2013 galina - ТЗ1906 выодим информацию по загрузке VIN
*/

{global.i}

def var v-title as char.
def var v-module as char.
def var v-select as int.

function getTime returns char (input v-param as int).
   return string(v-param, "HH:MM").
end function.

def button btnExit   label "Выход".
def QUERY q_histloadfile FOR histloadfile .
def browse b_histloadfile query q_histloadfile displ
        histloadfile.regdt     format "99/99/9999"  label 'Дата'
        getTime(histloadfile.tm)  format "x(5)"  label 'Время'
        histloadfile.fname  format "x(50)"  label 'Файл'
        with 20 down SEPARATORS title "" overlay.
def frame fMain b_histloadfile skip btnExit  with centered overlay row 3 width 75 top-only.


ON CHOOSE OF btnExit IN FRAME fMain do:
   return.
end.


run sel2 (" История загрузок ", " 1. Импорт общей базы РНН | 2. Импорт списков бездействующих налогоплательщиков| 3. Импорт списка лжепредприятий | 4. Импорт VIN кодов ", output v-select).

if v-select = 1 then do:
  v-title = "Импорт общей базы РНН".
  v-module = "bin".
end.
if v-select = 2 then do:
  v-title = "Импорт списков бездействующих налогоплательщиков".
  v-module = "inacttaxpayer".
end.
if v-select = 3 then do:
  v-title = "Импорт списка лжепредприятий".
  v-module = "fakecompany".
end.
if v-select = 4 then do:
  v-title = "Импорт VIN кодов".
  v-module = "vin".
end.


OPEN QUERY q_histloadfile FOR EACH histloadfile where histloadfile.module = v-module.
enable all with frame fMain title v-title.
WAIT-FOR CHOOSE OF btnExit.