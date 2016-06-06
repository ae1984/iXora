/* wood_asg_ac.p
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

TRIGGER PROCEDURE FOR Assign OF wood.account OLD VALUE old_account.

 {vkr_log.i}

 define shared variable g-ofc as character.
 define buffer b_tree 		 for tree.
 define buffer b_wood 		 for wood.
 define buffer a_tree for tree.
 define buffer a_wood for wood.
 
 define variable acc  	like wood.account.
 define variable acct 	like wood.acctype.
 define variable dt   	like wood.date.
 define variable grps	like wood.grp.
 define variable o_b  	like wood.balance.
 define variable act_acc	like wood.account.
 define variable rec_idd         as integer.
 
 define variable my_account 	 as character.
 define variable my_uniq 	 as logical.
 define variable my_active       as logical.
 
 define variable dad_account 	 as character.
 define variable dad_uniq 	 as logical.
 
 define variable old_my_account	 as character.
 define variable old_my_uniq 	 as logical.
 define variable old_my_active   as logical. 
 
 define variable old_dad_account as character.
 define variable old_dad_uniq 	 as logical.
 
 define variable current_account as character.
 
 define variable prefix as character format "x(2)".
 
 define variable sum_to_acc      like wood.account.
 define variable c_date		 like wood.date.
 
 
 if old_account = ? or old_account = "" then return.

 /* -------------------Family Relation Setup----------------------------------- */

do transaction:
 
 find first tree where tree.account = wood.account and tree.grp = wood.grp no-lock no-error.
 
 if not available tree then do:
    run event_rgt ( "AsgnAcc", "Asign", wood.account, ?, g-ofc, " Not Registred Account. Terminated" ).
    return.
 end.     
 if tree.uniq = yes and wood.acctype <> "D"  then do:
    run event_rgt ( "AsgnAcc", "Asign", wood.account, ?, g-ofc, " Unique Account Changing. Terminated" ).
    return.
 end.   
 
 my_account      = wood.account.
 if wood.acctype <> "D" then  
    dad_account     = tree.ancestor.
 else 
    dad_account     = wood.account.
 my_uniq         = tree.uniq.
 my_active       = tree.active.
 
 find first tree where tree.account = dad_account and tree.grp = wood.grp no-lock no-error.
 if not available tree then do:
    run event_rgt ( "AsgnAcc", "Asign", dad_account, ?, g-ofc, " Not Registred Ancestor Account. Terminated" ).
    return.
 end.   
 
 dad_uniq = tree.uniq.
 
/* ---------------------------------------------------------------------------------- */

  if dad_uniq = no then do:
     run event_rgt ( "AsgnAcc", "Asign", dad_account, ?, g-ofc, " Ancestor Account Not Unique. Terminated.").
     return.
  end.   
 
/* ============================ Account Changing Processing ========================= */


if old_account = ? or old_account = "" then return.       /* if NEW deals created then return */

/* --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -- */

/* Deals Status Changing ( Account Changing )  New Account Processing */

if my_active = yes then do: 
      
      find first b_wood where b_wood.account  = dad_account
                          and b_wood.acctype <> "D"
                          and b_wood.grp = wood.grp
                    	  and b_wood.date = wood.date exclusive-lock no-error.
                    	  
      if not available b_wood then do:
      
      sum_to_acc = dad_account.
      c_date  =    wood.date.
      grps    =    wood.grp.
      
      {papa_add.i}      
      
      find first b_wood where b_wood.account  = dad_account
                          and b_wood.acctype <> "D"
                          and b_wood.grp = wood.grp
                          and b_wood.date = wood.date exclusive-lock no-error.
      end.               	  
                    	  
      if available b_wood then do: 		/* ===== Changing New PAPA ======== */           

         b_wood.i_amt   = b_wood.i_amt + wood.i_amt.
     	 b_wood.o_amt   = b_wood.o_amt + wood.o_amt.

      end.                
       else do:
             run event_rgt ( "AccAsgnAcc", "ERROR", dad_account, string(wood.date), g-ofc, " Ancestor Account Still not present. ERROR").
            end.
end.  
   else do:
           run event_rgt ( "AccAsgnAcc", "Asign", wood.account, ?, g-ofc, " New Account Not Active. Skipped.").
        end.

/* =============  OLD Account Processing ======================== */
 
 find first tree where tree.account = old_account and tree.grp = wood.grp no-lock no-error.
 
 if not available tree then do:
    run event_rgt ( "AsgnAcc", "Asign", old_account, ?, g-ofc, " Old Account Not Registred. Terminated.").
    return.
 end.   
 
 old_my_account = old_account. 
 old_my_uniq    = tree.uniq.
 old_my_active  = tree.active.  
 
 if wood.acctype <> "D" then  
    old_dad_account = tree.ancestor.
 else 
    old_dad_account = old_account.
    
 find first tree where tree.account = old_dad_account and tree.grp = wood.grp no-lock no-error. 

 if not available tree then do:
    run event_rgt ( "AsgnAcc", "Asign", old_dad_account, ?, g-ofc, " Old Ancestor Account Not Registred. Terminated.").
    return.
 end.   
 
 old_dad_uniq = tree.uniq.
 
 if old_dad_uniq = no then do:
    run event_rgt ( "AsgnAcc", "Asign", old_dad_account, ?, g-ofc, " Old Ancestor Account Not Unique. Terminated.").
    return.
 end. 
 
 /* ----------------------------------------------------------------------------------- */
 
 /* Deals Status Changing ( Account Changing )  Old Account Processing */

if old_my_active = yes then do: 
     
     find first b_wood where b_wood.account  = old_dad_account
                         and b_wood.acctype <> "D"
                         and b_wood.grp = wood.grp
                         and b_wood.date = wood.date exclusive-lock no-error.
      
      if not available b_wood then do:
      
      sum_to_acc = old_dad_account.
      c_date     = wood.date.
      
      {papa_add.i}
      
      find first b_wood where b_wood.account  = old_dad_account
                         and b_wood.acctype <> "D"
                         and b_wood.grp = wood.grp
                         and b_wood.date = wood.date exclusive-lock no-error.
      end.                   
                         
      if available b_wood then do: 		/* ===== Changing Old PAPA */           
      
         b_wood.i_amt   = b_wood.i_amt - wood.i_amt.
     	 b_wood.o_amt   = b_wood.o_amt - wood.o_amt.
      
      end.                
        else do:
                run event_rgt ( "AccAsgnAcc", "ERROR", old_dad_account, string(wood.date), g-ofc, " Old Ancestor Account Still not present. ERROR").
             end.
end.
  else do:
         run event_rgt ( "AsgnAcc", "Asign", old_account, ?, g-ofc, " Old Account Not Active. Skipped.").
       end. 

/* Prefix Changing -------------------------------------------- */

if wood.sts = "new" then wood.sts = "act".
 
end. 
 
 
 
 
 
 
