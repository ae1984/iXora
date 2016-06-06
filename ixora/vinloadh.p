/* vinloadh.p
 * MODULE
        Загрузка обновлений базы VIN кодов
 * DESCRIPTION
        Добавление новой записи в ручную в базу VIN кодов
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
        22/07/2013 galina
 * BASES
        BANK COMM
 * CHANGES
       23/07/2013 galina - ТЗ 1906 вывод информационного сообщения, если запись уже существует в базе
*/

{chk12_innbin.i}

def var v-vin as char no-undo.
def var v-f45 as char no-undo.
def var v-f40 as char no-undo.
def var v-iin as char no-undo.
def var v-mess as char no-undo.

form
v-vin label 'VIN код' format "x(20)" skip
v-f45 label 'F45    ' format "x(17)" skip
v-f40 label 'Статус ' format "x(1)" validate (trim(v-f40) = '' or lookup(trim(v-f40),'V,P,B,S') > 0 ,'Неверный статус. Введите одно из значений: V,P,B,S') skip
v-iin label 'ИИН/БИН' format "x(12)" validate(trim(v-iin) = '' or chk12_innbin(v-iin),'Неправильно введён БИН/ИИН') skip

with overlay row 5 side-label centered  title 'VIN КОД' width 50 frame fvin .
repeat on endkey undo,return:
   update v-vin with frame  fvin.
   update v-f45 with frame  fvin.
   if trim(v-vin) <> '' or trim(v-f45) <> '' then do: hide message. leave. end.
   else message 'Необходимо заполнить одно из значений VIN код или F45'.
end.
update v-f40 with frame  fvin.
update v-iin with frame  fvin.


find first vincode where vincode.vin = v-vin and vincode.f45 = v-f45  and vincode.bin = v-iin use-index vinbinidx exclusive-lock no-error.
if avail vincode then do:
    if vincode.f40 <> trim(v-f40) then assign vincode.f40 = v-f40 v-mess = 'Поле F40 обновлено'.
    else v-mess = 'Запись уже существует в базе'.
end.
else do:
   create vincode.
   assign vincode.vin  = v-vin
          vincode.f45  = v-f45
          vincode.f40  = v-f40
          vincode.bin  = v-iin
          v-mess = 'Добавлена новая запись'.
end.
message v-mess view-as alert-box title 'ВНИМАНИЕ'.
