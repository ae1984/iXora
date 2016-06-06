/* jl_w_tr.p
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

TRIGGER PROCEDURE FOR Write OF jl OLD BUFFER old_jl.


/* -------------------- Valsts Kase Processing ( VKR System ) ------------- */

define variable newacc as logical initial no.
define variable oldacc as logical initial no.

do transaction:

/* -------------- New Account ----------------------------- */

 find first tree where tree.account = jl.acc no-lock no-error.    /* New Buffer Checking ... */
 
 if not available tree then 
    find first tree where tree.old_acc = jl.acc use-index old_acc_idx no-lock no-error.    /* New Buffer Checking .find first tree where tree.account = jl.acc no-lock no-error.    /* New Buffer Checking ... */.. */
     
  if available tree then newacc = yes.

/* -------------- Old Account ----------------------------- */
 
 find first tree where tree.account = old_jl.acc no-lock no-error. /* Old Buffer Checking ... */
 
 if not available tree then 
    find first tree where tree.old_acc = old_jl.acc use-index old_acc_idx no-lock no-error. /* Old Buffer Checking ... */ 
  
  if available tree then oldacc = yes.

/* -------------------------------------------------------- */

if newacc = yes and jl.aah <> 0 then do:
   for each wood where wood.jh = jl.aah 
        and wood.trx_type = 1 use-index jh_jl_idx no-lock.  /* Remove Short Transaction */
        run data_remove(wood.jh, wood.jl, wood.date, wood.account, wood.trx_type).
   end. 
end.
 
 if newacc = yes then do:
    run data_rgt(integer( recid(jl) ), 0).
 end. 
 
 if oldacc = yes and newacc = no then do:
    run data_remove(old_jl.jh, old_jl.ln, old_jl.jdt, old_jl.acc, 0).
 end.
 
end.
