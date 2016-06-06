/* aile.p
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

/* 1.izmai‡a - kµ­das labojums: konsekvent–k ievёro ailes platumu */
define input-output parameter rin1  as character.
define input        parameter l     as integer.
define output       parameter rin2  as character.

define              variable  rinda as character.
define              variable  i     as integer.
define              variable  j     as integer.
define              variable  kreisais as logical.

kreisais = yes.
rin2 = "".
rin1 = trim(rin1).
if substring(rin1,1,1) = "!"
then rin1 = trim(substring(rin1,2)).
if substring(rin1,1,1) = "#"
then do:
     kreisais = no.
     rin1 = trim(substring(rin1,2)).
end.
repeat:
   i = index(rin1," ").
   j = index(rin1,"#").
   if minimum(i,j) = 0
   then i = maximum(i,j).
   else i = minimum(i,j).
   j = index(rin1,"!").
   if minimum(i,j) = 0
   then i = maximum(i,j).
   else i = minimum(i,j).
   if i = 0
   then i = length(rin1).
   else i = i - 1.
   if i = 0
   then leave.
   if length(rin2) + i < l
   then do:
        rin2 = rin2 + substring(rin1,1,i) + " ".
        rin1 = substring(rin1,i + 1).
        rin1 = trim(rin1).
        if length(rin1) = 0 or substring(rin1,1,1) = "!" or
           substring(rin1,1,1) = "#"
        then leave.
   end.
   else do:
        if length(rin2) = 0
        then do:
             rin2 = substring(rin1,1,l - 1).
             rin1 = substring(rin1,l).
        end.
        leave.
   end.
end.
/* if length(rin2) >= l
then rin2 = trim(rin2). */
rin2 = trim(rin2).
if kreisais
then rin2 = rin2 + fill(" ",l - length(rin2) - 1).
else rin2 = fill(" ",l - length(rin2) - 1) + rin2.
