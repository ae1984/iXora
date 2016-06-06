/* vinchk.p
 * MODULE
        Загрузка обновлений базы VIN кодов
 * DESCRIPTION
        Проверка наличия VIN кода
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        освное меню Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU

 * BASES
       BANK COMM
 * AUTHOR
        22.07.2013 galina
 * CHANGES


*/



def var v-vin as char.
form
v-vin label 'VIN КОД' format "x(20)" validate(trim(v-vin) <> '','Введите VIN КОД')
with side-label centered frame fvin row 8.

update v-vin with frame fvin.
hide frame fvin.

find first vincode where vincode.vin = trim(v-vin) use-index vinbinidx no-lock no-error.
if not avail vincode then find first vincode where vincode.f45 = trim(v-vin) use-index f45idx no-lock no-error.
if avail vincode then message 'VIN-код верный!' view-as alert-box title 'ВНИМАНИЕ'.
else message 'VIN КОД НЕ найден!' view-as alert-box title 'ВНИМАНИЕ'.

