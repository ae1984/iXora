/* rin-dal.p
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

define input-output parameter rin1  as character.
define output       parameter rin2  as character.
define input        parameter l     as integer.

define              variable  rinda as character.
define              variable  i     as integer.

rin1 = trim(rin1).
if length(rin1) <= l
then do:
     rin2 = rin1.
     rin1 = "".
     return.
end.
rin2 = substring(rin1,1,l).
rinda = substring(rin2,l,1).
if rinda = " " or rinda = "," or rinda = ":" or rinda = ";" or
   substring(rin1,l + 1,1) = " "
then do:
     rin1 = trim(substring(rin1,l + 1)).
     return.
end.
i = maximum(r-index(rin2," "),r-index(rin2,",")).
i = maximum(i,r-index(rin2,":")).
i = maximum(i,r-index(rin2,";")).
if i = 0
then i = l.
rin2 = trim(substring(rin1,1,i)).
rin1 = trim(substring(rin1,i + 1)).
/*----------------------------------------------------------------------------
  #3.
     1.izmai‡a - vienk–rЅots algoritms un par atdalЁt–jiem programma uzskata
       arЁ simbolus ,;:
---------------------------------------------------------------------------*/
