/* desp.i
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

find msg where msg.lang eq g-lang and msg.ln eq {1} no-lock.
disp  "[MSG# " + string(msg.ln) + "] " + msg.msg format "x(70)" {3}
      with no-label row {2} frame uniques{2} centered overlay top-only.
      update {3} with frame uniques{2}.
