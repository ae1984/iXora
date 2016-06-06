/* astnal.i
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



astnal.sbal = astnal.ston + astnal.sper + astnal.sieg + astnal.damn2[1] - astnal.sizs.
astnal.snam = round(astnal.sbal * astnal.amn / 100,0).

/*astnal.srem10 = round(astnal.sbal * 0.1,0).*/

if astnal.srem10 >= astnal.sremk then 
 astnal.srem10 = astnal.sremk.
 astnal.sremos = astnal.sremk - astnal.srem10. 
 astnal.stok   = astnal.sbal - astnal.snam + astnal.sremos - astnal.k - astnal.l.

if {1} eq 1 then
displ        astnal.nrst  astnal.grup astnal.dam4   astnal.ast      astnal.amp astnal.amn 
             astnal.ston  astnal.sper astnal.sieg   astnal.damn2[1] astnal.sizs 
             astnal.sbal  astnal.snam astnal.srem10 astnal.sremos
             astnal.sremk astnal.k    astnal.l      astnal.stok     astnal.damn3[1] 
             WITH FRAME astn .
