/* aal_d_tr.p
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

TRIGGER PROCEDURE FOR Delete OF aal.


if aal.aax = 71 or aal.aax = 21 then return.

do transaction:

find first tree where tree.account = aal.aaa no-lock no-error.

 if not available tree then 
   find first tree where tree.old_acc = aal.aaa use-index old_acc_idx no-lock no-error.
 
 if available tree then do:
     run data_remove(aal.aah, aal.ln, aal.regdt, aal.aaa, 1).
 end.

end. 
      
