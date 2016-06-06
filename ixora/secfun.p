/* secfun.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

def var v-nmenu like nmenu.fname.
def var v-pass as char.
def var i as int init 0.

repeat:
update v-nmenu with frame aaa.
hide frame aaa.

run savelog ("secfun", "- - - - - - - - - - - - - - - - - - - - - - -").
run savelog ("secfun", "Запустил процедуру secfun для функции " + v-nmenu).

find first nmenu where nmenu.fname = v-nmenu no-lock no-error.

if available nmenu then do:

find sysc where sysc.sysc="SYS1" no-lock.

v-pass = "".

do while true:

   i = i + 1.
   update v-pass label "Введите пароль для bankadm" blank with centered side-label frame fpwd.

   if v-pass = ENTRY (4, sysc.chval) then do: i = 0. leave. end.

   if i = 3 then do:
      run savelog ("secfun", "Не ввел правильный пароль для bankadm! Завершение процедуры").
      message "Не верный пароль!" view-as alert-box.
      hide frame fpwd.
      return.
   end.
end.
hide frame fpwd.

run savelog ("secfun", "Успешно для функции " + v-nmenu).

for each ofc.
 find first sec where sec.fname = v-nmenu and sec.ofc = ofc.ofc no-error.
 if not available sec then do:
    display ofc.ofc .
    pause 0.
    create sec.
    sec.ofc = ofc.ofc.
    sec.fname = nmenu.fname.
    sec.proc = nmenu.proc.
    end.
end.

end.
else
display " Not function !!! ".
end.

