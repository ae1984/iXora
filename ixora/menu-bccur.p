/* menu-bccur.p
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
 * BASES
        BANK
 * AUTHOR
        11.08.2011 aigul
 * CHANGES
*/

/* menu-prt1.p
   Короткое меню: Просмотр - Печать
   27.03.2000 */

def input parameter cFile as char.
def button btn-joe   label  "Просмотр".
def button btn-prit  label  "Печать  ".
def button btn-exit  label  "Выход   ".
def var e as char.
def var f as logical initial no.
def frame frame2
    skip(1) btn-joe btn-prit btn-exit
    with centered title "Сделайте выбор:" row 5 .
on choose of btn-joe do:
   unix value( 'joe -rdonly ' + cfile ).
end.
on choose of btn-prit do:
   unix value( 'prit ' + cfile ).
end.
on choose of btn-exit do:
    for each sysc where sysc.sysc = 'scrc' no-lock:
        e = sysc.chval.
        if substr(e,6,1) <> '1' or substr(e,9,1) <> '1' or substr(e,12,1) <> '1' then f = yes.
    end.
    if f then do:
        find sysc where sysc.sysc = 'SCRC-ORDER' exclusive-lock.
        sysc.daval = today.
        sysc.loval = no.
        find sysc where sysc.sysc = 'SCRC-ORDER' no-lock.
    end.
    pause 0 no-message.
end.
enable all with frame frame2.
wait-for choose of btn-exit.

return.