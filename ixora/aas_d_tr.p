/* aas_d_tr.p
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

TRIGGER PROCEDURE FOR Delete OF aas.

find first tree where tree.account = aas.aaa no-lock no-error.

if not available tree then
  find first tree where tree.old_acc = aas.aaa use-index old_acc_idx no-lock no-error.
  
     if available tree then do:
         run remove_hold(aas.aaa, aas.ln, aas.payee).
     end.
