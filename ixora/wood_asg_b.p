/* wood_asg_b.p
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

TRIGGER PROCEDURE FOR Assign OF wood.balance OLD VALUE old_amount.


/* ---- Processing the same account balances for futures dates ------------------ */

if wood.acctype = "D" then return.

define buffer n_wood for wood.
define variable delta like wood.balance.  


delta = wood.balance - old_amount.

find first n_wood where n_wood.account = wood.account and
                        n_wood.acctype = wood.acctype and 
                        n_wood.grp  = wood.grp and  
                        n_wood.date > wood.date use-index acc_date_idx exclusive-lock no-error.
  if available n_wood then do:
      n_wood.balance = n_wood.balance + delta.
      n_wood.savedate = today.
      n_wood.savetime = time.
  end.                 

 
