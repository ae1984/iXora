/* fold.p
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

    
def var v-aaa as char format "x(10)" label "Old account".
def var v-cifname like cif.name.
form 
    v-aaa aaa.aaa label "New account "  aaa.cif label "Client " skip
    cif.name label "Name" with frame a side-label row 8 centered.
repeat :
update v-aaa with frame a.
find first aaa  where aaa.name eq v-aaa no-lock no-error.
if available aaa then do :
find cif where cif.cif eq aaa.cif no-lock no-error.
v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
displ aaa.aaa aaa.cif v-cifname format "x(30)" when available cif with frame a.
end.
end.


