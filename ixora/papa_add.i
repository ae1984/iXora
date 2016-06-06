/* papa_add.i
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

/* ========================================================================
=									  =
=		Account Structure in Wood Update Utility		  =
=									  =
========================================================================= */

             find a_tree where a_tree.account = sum_to_acc and a_tree.grp = grps no-lock no-error.
             if available a_tree then do:

                run event_rgt ( "AsgnTrig", "NewAcc", sum_to_acc, string(c_date), g-ofc, "Not found ancestor account. Trying to create Ancestor.").
             
                create a_wood.
                
                rec_idd = recid(a_wood).
                a_wood.crc = a_tree.crc.
          	a_wood.acctype = a_tree.acctype.
          	a_wood.savedate = today.
          	a_wood.savetime = time.
          	a_wood.date = c_date.
          	a_wood.i_amt = 0.
          	a_wood.o_amt = 0.
                a_wood.balance = 0.
          	a_wood.account = a_tree.account.
                a_wood.grp = grps.

                acc  = a_wood.account.
                acct = a_wood.acctype. 
                dt   = a_wood.date.	
               
                find last a_wood where a_wood.account = acc and
                                     a_wood.acctype = acct and
                                     a_wood.grp = grps and
                                     a_wood.date < dt use-index acc_date_idx exclusive-lock no-error. 

                if available a_wood then 
                   o_b = a_wood.balance .
                else 
                   o_b = 0.

                if o_b <> 0 then do:
                   find a_wood where recid(a_wood) = rec_idd exclusive-lock no-error.
                        if available a_wood then a_wood.balance = o_b.
                end.
               
               run event_rgt ( "AsgnTrig", "NewAcc", sum_to_acc, string(c_date), g-ofc, "Ancestor Created.").              
             
             end. /* if available a_tree .. */   
              else do: 
                      run event_rgt ( "AsgnTrig", "NewAcc", sum_to_acc, string(c_date), g-ofc, "Not Registred Account.").              
                      return.                     
                   end.
             
