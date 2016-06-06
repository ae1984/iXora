/* aahaal.p
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

 def var ddd as date.
 find last jl.
 ddd = jl.jdt.
 display ddd.
 pause 10.
 for each jl where jl.jdt = ddd:
  display jl.
 for each jh where jh.jh = jl.jh:
  display jh with frame ddd.
 end.
 end.


pause 20
