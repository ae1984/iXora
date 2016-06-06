/* jl-stmp.p
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

def shared var g-ofc like ofc.ofc.
def shared var s-jh like jh.jh.

find first jh where jh.jh = s-jh.
if jh.sts = 6 then do:
 message " Transaction was stamped allready !!" chr(7) chr(7).
pause.
return.
end.
if g-ofc <> "root" and jh.sts < 5 then do:
message " Transaction wasn't printed yet !!" chr(7) chr(7).
pause.
return.
end.
find sysc where sysc.sysc eq "CASHGL" no-lock .
for each jl of jh no-lock:
    if jl.gl eq sysc.inval then do on error undo, return:
        message "Кассовая транзакция !!! "
        chr(7) chr(7) chr(7).
        pause.
        return.
    end.
end.

if keyfunction(lastkey) = "end-error" then return.

for each jl of jh.
jl.sts = 6.
jl.teller = g-ofc.
end.
jh.sts = 6.
