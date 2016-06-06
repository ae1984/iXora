/* rin-mas.i
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

{&r}[1] = {&lks}.
do {&i} = 2 to {&n}:
   if index({&r}[{&i} - 1],"&") >  0
   then do:
        {&r}[{&i}] = substring({&r}[{&i} - 1],index({&r}[{&i} - 1],"&") + 1).
        {&r}[{&i} - 1] =
            substring({&r}[{&i} - 1],1,index({&r}[{&i} - 1],"&") - 1).
        repeat while index({&r}[{&i} - 1],chr(126)) > 0:
           overlay({&r}[{&i} - 1],index({&r}[{&i} - 1],chr(126))) = "&".
        end.
   end.
   else {&r}[{&i}] = "".
end.
if index({&r}[{&n}],"&") > 0
then {&r}[{&n}] = substring({&r}[{&n}],1,index({&r}[{&n}],"&") - 1).
repeat while index({&r}[{&n}],chr(126)) > 0:
   overlay({&r}[{&n}],index({&r}[{&n}],chr(126))) = "&".
end.

