/* menu-prt1.p
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

/* menu-prt1.p 
   Короткое меню: Просмотр - Печать
   27.03.2000 */
      
def input parameter cFile as char.
def button btn-joe   label  "Просмотр".
def button btn-prit  label  "Печать  ".
def button btn-exit  label  "Выход   ".
def frame frame2
    skip(1) btn-joe btn-prit btn-exit
    with centered title "Сделайте выбор:" row 5 .
on choose of btn-joe do:
   unix value( 'joe -rdonly ' + cfile ).
end.
on choose of btn-prit do:
   unix value( 'prit ' + cfile ).
end.
on choose of btn-exit pause 0 no-message. 
enable all with frame frame2.
wait-for choose of btn-exit.

return. 