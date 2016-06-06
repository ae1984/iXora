/* aal_w_tr.p
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

TRIGGER PROCEDURE FOR Write OF aal OLD BUFFER old_aal.


/* --------- Valsts Kase Processing ( VKR System ) -------------- */

define variable newacc as logical initial no.
define variable oldacc as logical initial no.

/* --------------- New Account ----------------------- */

find first tree where tree.account = aal.aaa no-lock no-error.    /* New Buffer Processing ... */
   
if not available tree then 
   find first tree where tree.old_acc = aal.aaa use-index old_acc_idx no-lock no-error.  
   
   if available tree then newacc = yes.

/* --------------- Old Account ----------------------- */

find first tree where tree.account = old_aal.aaa no-lock no-error. /* Old Buffer Processing ... */

if not available tree then 
   find first tree where tree.old_acc = old_aal.aaa use-index old_acc_idx no-lock no-error. /* Old Buffer Processing ... */     
   
   if available tree then oldacc = yes.
   
/* --------------------------------------------------- */   

if ( aal.jh <> 0 and can-find ( jh where jh.jh = aal.jh )) 
     or aal.aax = 21 or aal.aax = 71  then return.

do transaction:

   if newacc = yes then do:
     run data_rgt(integer(recid(aal)), 1).
   end.
   
   if oldacc = yes and newacc = no then do:
     run data_remove(old_aal.aah, old_aal.ln, old_aal.regdt, old_aal.aaa, 1).
   end.

end.  
  
