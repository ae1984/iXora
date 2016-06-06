/*editor_update.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        редактирование длинной строки
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
        09/09/2010 galina
* BASES
        BANK
 * CHANGES
*/
empty temp-table wrk.

do i = 1 to {&num_lines}:
    create wrk.
    wrk.id = i.
    wrk.txt = substring({&var},(i - 1) * {&chars_in_line} + 1,{&chars_in_line}).
end.
define query q{&frame} for wrk.
define browse b{&frame} query q{&frame}
       displ wrk.id /*label "Стр"*/ format ">>9"
             wrk.txt /*label "Текст"*/ format "x({&chars_in_line})"
       enable wrk.txt AUTO-RETURN
             with {&num_down} down overlay no-label no-box.

define button bt{&frame} label "SAVE".
define frame {&frame} b{&frame} skip bt{&frame} with {&framep}.


on "end-error" of frame {&frame} do:
   hide frame {&frame} no-pause.
end.

on choose of bt{&frame} do:
    hide frame {&frame} no-pause.
end.

open query q{&frame} for each wrk.

enable all with frame {&frame}.

wait-for choose of bt{&frame} FOCUS b{&frame} /*or window-close of current-window*/.


{&var} = ''.
for each wrk no-lock:
if wrk.txt <> '' then {&var} = {&var} + wrk.txt + if wrk.id <> {&num_lines} then fill(' ',{&chars_in_line} - length(wrk.txt)) else ''.
end.


