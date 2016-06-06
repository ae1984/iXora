/* wood_del.p
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

TRIGGER PROCEDURE FOR Delete OF wood.

define variable sum_to_acc             as character.
define variable delta_i             as decimal.
define variable delta_o             as decimal.
define variable delta_a             as decimal.

define buffer b_wood for wood.

delta_o   = - wood.o_amt .
delta_i   = - wood.i_amt .
delta_a   = - wood.balance .
 
find tree where tree.account = wood.account and tree.grp = wood.grp no-lock no-error.
   
  if available tree then do: 
  
      if wood.acctype <> "D" then 
         sum_to_acc = tree.ancestor. /* Processing mode for Accounts */
      else 
         sum_to_acc = wood.account.  /* Processing mode for Deals    */

      find b_wood where b_wood.account = sum_to_acc
                        and b_wood.acctype <> "D"
                        and b_wood.grp = wood.grp 
                        and b_wood.date = wood.date exclusive-lock no-error. 
 
       if available b_wood then do:
          b_wood.o_amt   = b_wood.o_amt   + delta_o.
          b_wood.i_amt   = b_wood.i_amt   + delta_i.
          b_wood.balance = b_wood.balance + delta_a.
            
       end. /* if available b_wood ... */
  end. /* if available tree ... */
























