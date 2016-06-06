/* wood_asgn.p
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

/*===================================================================================
=                                                                                                                                                =
=                                      Triggers Processing Procedure                                                               =
=                                   VKR System by Andrey Popov, April 1998                                                  =
=                                                                                                                                                =
===================================================================================*/

{vkr_log.i}

define shared variable g-ofc as character.

define input parameter account            as character. /* Wood pif         */
define input parameter c_date	             as date.      /* Wood Date        */ 
define input parameter amount             as decimal.   /* Wood amount      */
define input parameter old_amount       as decimal.   /* Wood old_amount  */
define input parameter am_type           as character.    /* Wood Amount Type */
define input parameter act             as character.    /* Account Type */
define input parameter grps	       as integer.	/* Customers Group */

/* --------------------------------------------------------------------------- */

define variable sum_to_acc 	like wood.account.
define variable delta           as decimal.

define buffer a_tree for tree.
define buffer a_wood for wood.
define buffer b_wood for wood.

define variable acc  	like wood.account.
define variable acct 	like wood.acctype.
define variable dt   	like wood.date.
define variable o_b  	like wood.balance.
define variable act_acc	like wood.account.
define variable rec_idd         as integer.

do transaction:

 delta  = amount - old_amount.

find first tree where tree.account = account and tree.grp = grps no-lock no-error.

if not available tree then do: /* No Correct Account */
   run event_rgt ( "AsgnTrig", "Asign", account, string(c_date), g-ofc, " Not Registred Account. Terminated" ).
  return.
end.


   if tree.active = yes then do: 
    

     if act <> "D" then 
         sum_to_acc = tree.ancestor. /* Processing mode for Accounts */
     else 
         sum_to_acc = account.  /* Processing mode for Deals    */
      
       find first b_wood where b_wood.account = sum_to_acc
                     and b_wood.acctype <> "D"
                     and b_wood.grp = grps
                     and b_wood.date = c_date exclusive-lock no-error.               

      /* here may insert condition running procedures */
      
      
       if not available b_wood then do: /* New Tree Structure Elements Creating ... */
       
             {papa_add.i}  
     
             find first b_wood where b_wood.account = sum_to_acc
                     and b_wood.acctype <> "D"
                     and b_wood.grp = grps 
                     and b_wood.date = c_date exclusive-lock no-error.               
                     
       end.
       
       if available b_wood then do:
          if am_type = "i" then do: 
                        b_wood.i_amt   = b_wood.i_amt   + delta.
          end. 
            else
              if am_type = "o" then do: 
                        b_wood.o_amt = b_wood.o_amt   + delta.  
              end. 
               else
                 if am_type = "b" then 
                        b_wood.balance = b_wood.balance + delta.

          b_wood.savedate = today.
          b_wood.savetime = time.
          run event_rgt ( "AsgnTrig", "Asign", account, string(c_date), g-ofc, " Tree Processing Completed" ).
       end.

   end.     /* if tree.active = yes ... */

end.

release b_wood no-error.


       
