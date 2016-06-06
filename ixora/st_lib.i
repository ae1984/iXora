/* st_lib.i
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/


/* -------------------------- VKR Main Library ---------------------------------------------- */

{vkr_log.i}

define new shared variable log_level         as integer    initial 7.                /* Default Log Level = 7 ( Full Diagnostics ) */
define new shared variable prefix         as character  initial "D".                        /* Regular Deals Account Prefix */
define new shared variable def_prefix         as character.                                /* Default Account Prefix */
define new shared variable main_subacc        as character.                                /* Main Sub Account         */
define new shared variable form_title         as character format "x(50)" initial "Bobiki".
define variable prefix_length                as integer         initial 5.
define variable long_prefix_length        as integer         initial 10.
define variable prefix_format                as character format "x(5)" initial "99999".        
define variable delimiter_symbol         as character initial "/".
define new shared variable vkoa          as character.                                /* VK Own Account  Prefix */
define variable left_point                 as integer    initial 20.                        /* Left Coordinate Checking Window */
define variable top_point                as integer    initial 2.                        /* Top Coordinate Checking Window */
define variable window_title                   as character initial "Deals".                 /* Main Checking Window Frame */
define variable bs_label                as character initial "PLATON"        .                 /* Banking System Label */
define new shared variable condition         as character format "x(100)".                /* Find Condition for find */
define new shared variable condition_2  as integer   initial 0.
define new shared variable new_account         like wood.account.                         /* New Account */
define new shared variable deal_sts         as character format "x(3)".                  /* Deal Status */
define new shared variable mt_prefix        as character initial "-VK_MT-".
define new shared variable mt_template  as character.
define new shared variable active_group as integer initial 1.
define new shared variable main_acc_bin as character initial "999".
define new shared variable card_acc_len        as integer   initial 10.
define new shared variable card_acc_err as integer   initial 8.
define new shared variable vk_active_group as integer initial 1.
define new shared variable a_group        as integer initial 999.
define variable main_title                 as character format "x(30)".

define new shared temp-table act_g
        field grp like wood.grp.

/* --- Allowed groups list Creating --- */

for each groups no-lock.
   if groups.ofc matches("*" + g-ofc + "*" )  then do:
      create act_g.
      act_g.grp = groups.grp. 
      a_group = groups.grp.
   end.
end.

/* ------------------------------------ */

mt_template = "*" + mt_prefix + "*".

main_title = "VKR System " + fill ( " " , 20) + string ( g-today )  + fill ( " ", 3) + g-ofc + "  " + bs_label. 

 
/*=================================================================
=                                                                                                                =
=            Account Tree in Main Data Table Creation Procedure                                          =
=               VKR System by Andrey Popov, April 1998                                      =
=                                                                                                                =
=================================================================*/

procedure structure:

define input parameter d_date   as date.  /* Value Date */
define input parameter type        as integer.
define input parameter grop        like wood.grp.

define variable check_flag         as logical initial no.
define variable rec_idd                as integer.
define variable o_b                as decimal.
define variable acc                like wood.account.
define variable acct                like wood.acctype.
define variable dt                 like wood.date.
define variable grps                like wood.grp.

/* Account Structure Building --------------------------------------------------------- */

find first wood where wood.date = d_date and wood.grp = grop no-lock no-error.
if not available wood or type = 1 then do transaction:
   check_flag = yes.
    for each tree where tree.uniq = yes and tree.grp = grop and tree.sts <> "C" exclusive-lock:

         find wood where wood.account = tree.account 
                     and wood.acctype = tree.acctype
                     and wood.date    = d_date 
                     and wood.grp     = grop no-lock no-error.

          if not available wood then do:

                  create wood.
                
                rec_idd = recid(wood). 
                  wood.crc = tree.crc.
                  wood.acctype = tree.acctype.
                  wood.savedate = today.
                  wood.savetime = time.
                  wood.date = d_date.
                  wood.i_amt = 0.
                  wood.o_amt = 0.
                wood.balance = 0.
                  wood.account = tree.account.
                wood.sts = "a".
                wood.grp = grop. 

                acc  = wood.account.
                acct = wood.acctype. 
                dt   = wood.date.
                grps = wood.grp.        
               
                find last wood where wood.account = acc  and
                                     wood.date < dt      and
                                     wood.acctype = acct and
                                     wood.grp     = grps use-index acc_date_idx exclusive-lock no-error. 

                if available wood then 
                   o_b = wood.balance .
                else 
                   o_b = 0.

                if o_b <> 0 then do:
                   find wood where recid(wood) = rec_idd exclusive-lock no-error.
                        if available wood then wood.balance = o_b.
                end.
          end.
    end. 
   end.    

run event_rgt ( "StrCreate", "StrBld", "", "", g-ofc, "Account Structure Creating for group " + string(grop) + " " + string(d_date) + " completed.").
return "0".
end.


/* ====================================================================================
=                                                                                     =
=                        User Interface Utility                                       =
=                   VKR System by Andrey Popov, April 1998                            =
=                                                                                     =
==================================================================================== */

procedure vkr_manual:

define input parameter rec_id as integer. /* Processing Record ID */


define variable hold_balance         like wood.balance.                   /* Account Hold balance */         
define variable avail_balance  like wood.balance.                  /* Account Available Balance */
define variable ciff                  as character format "x(6)".        /* Customer CIF */
define variable officer         as character format "x(8)".        /* Transaction Officer */
define variable gl-acc                as character.                           /* General Ledger Account */
define variable acc_name        like customers.name.                    /* Current Account Name */
define variable oper_date       as date initial today.                   /* Operation Date */
define variable i_account              like wood.account.                   /* Temporary Account */ 
define variable temp_details         like wood.details format "x(150)". /* Operation Details ( Temporary ) */
define variable design_line         as character format "x(76)".       /* Delimiter Line */
define variable msg                as character format "x(60)".           /* Message Variable */ 
define variable r_code          as integer.                        /* Command to return */
define buffer f_wood for wood.
define buffer g_wood for wood.
define frame main_window.
define frame account_list.

/* ------------------------User Interface Module------------------------------------- */

/* ------------------------ Frames Description -------------------------------------- */

design_line = fill("-",76).
window_title = window_title.


define button acpt                  label "Accept".
define button can DEFAULT         label "Cancel" .
define button edt                  label "Continue".



form
      wood.jh            at row 1 column 2           label "TRX Ref."   
      wood.jl            at row 2 column 2        label "TRX Line"
      oper_date          at row 3 column 2            label "TRX Date"           
      officer            at row 1 column 50            label "TRX Officer"  
      wood.source        at row 2 column 50         format "x(10)" label "Source"      
      wood.sts            at row 3 column 50        label "Status"
      design_line        at row 4 column 2          no-label    
      wood.reference     at row 5 column 2        label "Reference"
      wood.date          at row 5 column 30         label "Date"
      wood.crc                  at row 5 column 60           label "Currency"          
      hold_balance       at row 7 column  2     label "Hold Bal. "
      avail_balance      at row 8 column 2         label "Avail Bal."
      wood.o_amt         at row 7 column 40         label "Debit     " 
      wood.i_amt         at row 8 column 40         label "Credit    "
      i_account          at row 10 column 2          label "Account"        
      acc_name            at row 10 column 30   view-as editor inner-chars 35 inner-lines 2 label "Acc. Name"
      temp_details       at row 12 column 2         view-as editor inner-chars 35 inner-lines 6 label "Details"
      acpt               at row 16 column 48
      edt                at row 16 column 58
      can                at row 16 column 70
      " "                at row 19 column 78             /* Bottom & Right Corner of frame */           
with side-labels overlay row 3 title window_title frame main_frame.        


on choose of acpt do:

define buffer com_wood for wood.
define variable old_acc        like wood.account.

     find wood where recid(wood) = rec_id exclusive-lock no-error.
      if available wood then do:
        
        if  wood.details <>  temp_details then do:
                 /* wood.details = temp_details.
            message "Change Accepted" . */
        end.
         if wood.account <>  i_account then do:
           run h_w ( rec_id, "change", wood.account , i_account , "account", g-ofc).  
           old_acc = wood.account.
           wood.account = i_account.
           wood.sts = "act".
           run event_rgt ( "AccChg", "manual", wood.reference, wood.account, g-ofc, "Transaction Account & Status Changed.").
           /* --- Comission fee transaction processing --- */           

           for each com_wood where com_wood.jh   = wood.jh 
                               and com_wood.jl   <> wood.jl
                               and com_wood.account = old_acc
                               and com_wood.trx_code = "com" exclusive-lock.
              
              run h_w ( recid(com_wood), "change", com_wood.account , i_account , "account", g-ofc).   
              com_wood.account = i_account.
              run h_w ( recid(com_wood), "change", com_wood.sts, "act" , "sts", g-ofc).
              com_wood.sts = "act".
              run event_rgt ( "AccChg", "manual", com_wood.reference, com_wood.account, g-ofc, "Related Comission transaction Account & Status Changed.").

           end.     
           /* -------------------------------------------- */

           run h_w ( rec_id, "change", wood.sts, "act" , "sts", g-ofc).
           message "New Account Change Accepted" .  
        end.
         else do:
           wood.sts = "act".
           run h_w ( rec_id, "change", wood.sts, "act" , "sts", g-ofc).
           message "Status Change Accepted" .  
         end.
         

        r_code = 1.                
      end.
      release wood no-error.       
end.

on choose of can do:
message "Processing Interrupted". 
 r_code = 1.
end. 

on choose of edt do:
  r_code = 0.
end.        
        
/* ------------------------------------------------------------------------------ */


find wood where recid(wood) = rec_id no-lock no-error.

if not available wood then do:
  return "1".
end.  

/* Related Account Exploring ------------------------------------------------ */

find f_wood where f_wood.account = wood.account and f_wood.acctype = "A" and f_wood.grp = wood.grp no-lock no-error.
if available f_wood then avail_balance = f_wood.balance.

temp_details = wood.details.
i_account = wood.account.

find first tree where tree.account = wood.account and tree.grp = wood.grp no-lock.
find first customers where customers.prefix = tree.prefix and customers.grp = tree.grp no-lock.
if available tree then  acc_name = customers.name.  

if wood.trx_type = 0 then 
   find jl where jl.jh = wood.jh and jl.ln = wood.jl no-lock no-error.
    if available jl then officer = jl.who.

if wood.trx_type = 1 then 
   find aal where aal.aah = wood.jh and aal.ln = wood.jl no-lock no-error.
    if available aal then officer = aal.who.

/* ----- Hold & Available Balance ---------------------------------- */

 avail_balance = 0.
 hold_balance = 0.

find g_wood where g_wood.account = wood.account 
              and g_wood.acctype <> wood.acctype /* not DEAL */
              and g_wood.grp = wood.grp
              and g_wood.date = wood.date no-lock no-error.

if available g_wood then do:
   for each hold where hold.account = g_wood.account no-lock.
       find first aas where aas.aaa = hold.aas_aaa and aas.ln = hold.aas_ln no-lock no-error.
         if available aas then hold_balance = hold_balance + aas.chkamt.  
   end.   
   avail_balance = g_wood.balance - hold_balance.
end. 

/* ------------------------------------------------------------------- */

/* ------------------------------------------------------------------- */

display  officer                      with frame main_frame.
display  oper_date                 with frame main_frame.
display  ciff                  with frame main_frame.
display  wood.jh                 with frame main_frame.
display  wood.jl                 with frame main_frame.
display  wood.source          with frame main_frame.
display  wood.sts                  with frame main_frame.
display  design_line               with frame main_frame. 
display  wood.reference         with frame main_frame.
display  wood.date                 with frame main_frame.
display  wood.crc                 with frame main_frame.
display  wood.i_amt         format "-z,zzz,zzz,zz9.99" with frame main_frame.
display  wood.o_amt         format "-z,zzz,zzz,zz9.99" with frame main_frame.
display  avail_balance        format "-z,zzz,zzz,zz9.99" with frame main_frame.
display  hold_balance         format "-z,zzz,zzz,zz9.99" with frame main_frame.
display  acc_name        with frame main_frame.
display  i_account      with frame main_frame.
display  temp_details         with frame main_frame.

repeat:

repeat:  
          if wood.date <> g-today and wood.sts <> "new" then do:
            message "Not Allowed changing account".
            leave.           
          end.
              condition = tree.ancestor.                 /* Tree list selection condition ... */ 
              condition_2 = tree.grp.

              update i_account with frame main_frame.         /* New deal account update .. */        
               
         /* ----- Hold & Available Balance ---------------------------------- */
         
         avail_balance = 0.
         hold_balance = 0. 
         find g_wood where g_wood.account = i_account 
                             and g_wood.acctype <> "D" 
                       and g_wood.grp = wood.grp
                       and g_wood.date = wood.date no-lock no-error.

        if available g_wood then do:
           for each hold where hold.account = g_wood.account no-lock.
             find first aas where aas.aaa = hold.aas_aaa and aas.ln = hold.aas_ln no-lock no-error.
              if available aas then hold_balance = hold_balance + aas.chkamt.  
          end.   
          avail_balance = g_wood.balance - hold_balance.
        end. 
        
        display  avail_balance        format "-z,zzz,zzz,zz9.99" with frame main_frame.
        display  hold_balance         format "-z,zzz,zzz,zz9.99" with frame main_frame.
        
       /* ------------------------------------------------------------------- */              

              find first tree where tree.account = i_account and tree.grp = wood.grp  no-lock no-error.
              if not available tree then do: 
                msg = "Not Registred account '" + i_account + "'". 
                message msg.
               end.
               else do:
                    find first customers where customers.prefix = tree.prefix and customers.grp = tree.grp no-lock.                   
                    acc_name = customers.name.
                          display acc_name         with frame main_frame.                
                            update  temp_details  with frame main_frame.                                              
                          display temp_details  with frame main_frame.                      
                               
                          leave.
               end.

end. /* Account Changing internal cycle ... */

enable acpt  can edt  with frame main_frame.

wait-for window-close of current-window 
                                 or choose of can 
                                 or choose of acpt
                                 or choose of edt  focus edt.

if r_code = 1 then do:
hide frame main_frame.
leave.
end.

end. /* Update cycle ... */

hide frame main_frame.
return "0".

end. 


/* =========================================================================================== 
=                                                                                            =
=                      Common Account Checker                                                =
=               VKR System by Andrey Popov, April 1998                                       =
=                                                                                            =
=========================================================================================== */  

procedure checker:

define input parameter reference          as character.
define input parameter acc                  like wood.account. 
define input parameter in_customer           as character format "x(150)".
define input parameter in_details           as character format "x(150)".
define input parameter opr_type          like wood.trx_type.
define output parameter rgt_active_group like wood.grp. 


define variable det         as character.
define variable run_me        as character format "x(16)" initial ?. /* Group Account Processor */

acc = trim(acc).

/* --- Money Transfer Transaction Checking ----- */

if in_details matches mt_template then return "2".

/* --------------------------------------------- */

/* --- Checking and/or changing account / changing to new account /  ----- */

find first tree where tree.account = acc no-lock no-error.
  if not available tree then do:
     find first tree where tree.old_acc = acc use-index old_acc_idx no-lock no-error.
        if available tree then do:
           run event_rgt ( "AccChk", "Check", tree.account, acc, g-ofc, "Changing to new account").
           acc = tree.account.
        end.
         else do:
                 run event_rgt ( "AccChk", "Check", acc, "", g-ofc, "Not Registred Account").
                 return "1".                         /* Return 1 If not Registred Account         */
         end. 
  end.

/* ----- Find Account Group ----------------------------------------------------------- */

find first groups where groups.grp = tree.grp no-lock no-error.

if available groups then do:
    run_me = groups.processor. /* --- Selecting Processor for group --- */
    rgt_active_group = groups.grp.
end.
 else do:
    run event_rgt ( "AccChk", "Check", acc, "", g-ofc, "Not Registred Group : " + string(tree.grp)).
    return "1".                         /* Return 1 --> If not Registred Group         */   
 end.

if run_me = ? or rgt_active_group = ? then do:
    run event_rgt ( "AccChk", "Check", acc, "", g-ofc, "ERROR: processor: " + run_me + ", group: " + string(rgt_active_group) ).
    return "1".                         /* Return 1 --> If ERROR                */   
end. 

/* ----------------------------------------------------------------------- */

  if reference begins "RMZ" and rgt_active_group = vk_active_group then 
     det = in_customer. /* Valsts Kase ------------- */
  else                 
     det = in_details.

  run value(run_me) ( acc, det, opr_type, rgt_active_group, tree.def_prefix ). 
     
  return return-value.  
  
end.

/* =======================================================================================
=                                                                                         =
=                                Valsts Kase Processor                                         =
=                                                                                         =
======================================================================================= */

procedure vk_check:

define input parameter acc         like wood.account. 
define input parameter det          as character format "x(150)".
define input parameter opr_type like wood.trx_type.
define input parameter grps        like wood.grp.
define input parameter pref        like tree.prefix.

define variable t_account         like wood.account.
define variable prefix                as character format "x(10)".
define variable details         as character format "x(100)".
define variable d_length        as integer.
define variable pre_prefix         as character format "x(5)".


/* ---------- Account Group Default Prefix Selection ---------------------- */

find first customers where customers.prefix = pref and customers.grp = grps no-lock no-error.
 if not available customers then do:
    run event_rgt ( "AccChk", "Check", acc, "", g-ofc, "Not Registred prefix : " + pref ).
    return "1".                         /* Return 1 If not found prefix */
 end.

 def_prefix = delimiter_symbol + customers.prefix.


/* ------------------------------------------------------------------------ */

find first tree where tree.account = acc and tree.grp = grps no-lock no-error.

  
  if opr_type = 14 or opr_type = 66 or opr_type = 85 then do: /* Special Operations Commisison, Fees ... */
      prefix = def_prefix.
      deal_sts = "aua".
      t_account =  acc + prefix. 
  end. 

  if tree.acctype = "S" then do:                        /* Not Prefixed Account                 */
    t_account = acc.
    deal_sts = "aua".
  end. 
  else  do:
      
            d_length = length ( trim ( det ) ).
         if d_length < ( prefix_length + length(delimiter_symbol)) then  do:  /* Not set not one prefix */
            prefix = def_prefix.
            deal_sts = "new".
            t_account = acc + prefix.
         end.
          else do:
           
           pre_prefix = substring(det,(d_length - prefix_length ) ,prefix_length + length(delimiter_symbol) ) no-error.
           if pre_prefix begins delimiter_symbol then do:
              prefix = pre_prefix. 
              deal_sts = "aua".
              t_account = acc + prefix.
           end.
           else do:
              pre_prefix = substring(det,(d_length - long_prefix_length ) ,long_prefix_length + length(delimiter_symbol) ) no-error. 
              if pre_prefix begins delimiter_symbol then do:
                 deal_sts = "aua".
                 t_account = substring(pre_prefix,(length(delimiter_symbol) + 1) ,long_prefix_length ) no-error.
              end. 
               else do:
                 t_account = acc + def_prefix.        
                 deal_sts = "new".
               end. 
           end. 
          end.

           find first tree where tree.account = t_account and tree.grp = grps no-lock no-error.
               if  not available tree then do: 
             run event_rgt ( "AccChk", "Check", t_account, "", g-ofc, "Wrong inward prefix, changed to default prefix" ).               
             t_account = acc + def_prefix.        
             deal_sts = "new".
               end.                       
           else do:
             if tree.acctype = "C" then do:   /* --- Collection Account Case --- */
                
                t_account = acc + delimiter_symbol + tree.def_prefix.
                
                find first tree where tree.account = t_account and tree.grp = grps no-lock no-error.
                  if not available tree  then do: 
                    run event_rgt ( "AccChk", "Check", t_account, "", g-ofc, "Wrong inward prefix ( Check 'C' Account Setting ) , changed to default prefix" ).               
                    t_account = acc + def_prefix.        
                    deal_sts = "new".
                      end.                       
             end. 
           end.
      end.

/* --------------- Closed Account Processing ------------------------------ */

   {vk_c_acc.i}

/* ------------------------------------------------------------------------ */ 

return t_account.

end.

/* =======================================================================================
=                                                                                         =
=                           Fuel Card Processor                                                 =
=                                                                                         =
======================================================================================= */

procedure sfc_check:

define input parameter acc                 like wood.account. 
define input parameter det                  as character format "x(150)".
define input parameter opr_type         like wood.trx_type.
define input parameter grps                like wood.grp.
define input parameter pref                like tree.prefix.

define variable t_account         like wood.account.

find first customers where customers.prefix = pref and customers.grp = grps no-lock no-error.
         if not available customers then do:
              run event_rgt ( "SFCChk", "Check", acc, "", g-ofc, "Not Registred prefix : " + pref ).
           return "1".                         /* Return 1 If not found prefix */
        end. 
 
def_prefix = delimiter_symbol + customers.prefix.


run replace( input-output det, "000314458", "").  /* --- Registartion Code Skipping ... */

run parser(det).

if return-value = "0" or return-value = "1" or return-value = ? or return-value = "" then do:
   t_account = acc + def_prefix.
   deal_sts = "new".
   run event_rgt ( "SFCChk", "Check", t_account, "", g-ofc, "Assigned to default account." ).               
end.
  else do:

         find first tree where tree.account = return-value  
                           and tree.grp = grps no-lock no-error.
         
         if available tree then do:
             if tree.acctype = "C" then do:
                 t_account = acc + delimiter_symbol + tree.def_prefix.
                
                 find first tree where tree.account = t_account and tree.grp = grps no-lock no-error.
                   if not available tree  then do: 
                     run event_rgt ( "AccChk", "Check", t_account, "", g-ofc, "Wrong inward prefix ( Check 'C' Account Setting ) , changed to default prefix" ).               
                     t_account = acc + def_prefix.        
                     deal_sts = "new".
                       end.                       
             end. 
             else do:
               t_account = tree.account.
               deal_sts = "aua".
             end. 
         end.
           else do: /* ------- Card Default Account Processing ------------- */
                   t_account = acc + def_prefix.
                   deal_sts = "new". 
                   run event_rgt ( "SFCChk", "Check", t_account, "", g-ofc, "Assigned to default account." ).               
                end.  

       end. 

         
   

/* --------------- Closed Account Processing ------------------------------ */

  {vk_c_acc.i}

/* ------------------------------------------------------------------------ */ 



return t_account.

end.

/* =======================================================================================
=                                                                                         =
=                                 Text parser                                                =
=                                                                                         =
======================================================================================= */                                                                                        

procedure parser:

define input parameter in_source        as character.

define variable src_len         as integer.         /* Source Length            */
define variable src_pos         as integer.        /* Source Current Position */
define variable acc_buffer         as character.   /* Parsed Account Number   */
define variable source                as character.   /* Replaced Source   */

define variable tmp_symbol         as character.
define variable err_position        as integer.
define variable test_symbol         as decimal.
define variable one_test        as character.
define variable i                 as integer.
define variable account_length  as integer.
define variable acc_err_length  as integer.

source = in_source.
account_length = card_acc_len.
acc_err_length = card_acc_err.

run replace ( input-output source, ".", "x" ). /* Remove .     */
run replace ( input-output source, ",", "x" ). /* Remove ,     */
run replace ( input-output source, " ", "_" ). /* Remove space */

i = 0.
src_pos = 1.
src_len = length(source).

 repeat:  /* ------------------ Source Scanning --------------------------- */
   
   one_test = substring ( source, src_pos, 1 ).
  
   if one_test = "-" or
      one_test = "+" then do: 
                             src_pos = src_pos + 1.
                             if src_pos > src_len then leave.
                                   next.
                          end. 

   if i = 0 then do: /* Checking for corrupted "first" account ---- */

      tmp_symbol = trim ( substring ( source, src_pos, acc_err_length ) ).

      if length(tmp_symbol) = acc_err_length and tmp_symbol begins "12" then do:

       ASSIGN test_symbol = decimal(tmp_symbol) NO-ERROR. 
  
       if NOT ERROR-STATUS:ERROR then do:
          err_position = src_pos.
       end.

      end.
   end.

   tmp_symbol = trim ( substring ( source, src_pos, account_length ) ).

   if length(tmp_symbol) <> account_length or not (tmp_symbol begins "12") then do: 
      src_pos = src_pos + 1.
      if src_pos > src_len then leave.
      next.
   end.
 
   ASSIGN test_symbol = decimal(tmp_symbol) NO-ERROR. 
  
   if ERROR-STATUS:ERROR then do:
      if err_position <> 0 then i = i + 1.
      src_pos = src_pos + 1.
      if src_pos > src_len then leave.
   end.
   else do:
      if err_position = src_pos then err_position = 0.
      
      i = i + 1. 
      
      if i = 1 then account_length = acc_err_length. /* Changing account length to error length */
    
      if i > 1 then leave.
      acc_buffer = tmp_symbol.
      src_pos = src_pos + card_acc_len.
      if src_pos > src_len then leave.
   end. 

 end. /* repeat ... */

 /* --- Analysing ----------------------------------------------------------- */

    if i = 0 then return "0". /* Not Parsed any one account ----------------- */
     else
       if i = 1 then return acc_buffer.
        else 
          return "1".         /* Parsed More Than One Account */  
               

 /* ------------------------------------------------------------------------- */

end.


/* ========================================================================================
=                                                                                         =
=                           History Writer Procedure                                             =
=                    VKR System by Andrey Popov, April 1998                               =
=                                                                                         =
======================================================================================== */ 

procedure h_w:

define input parameter id                 as integer.                /* Related Wood Record ID */
define input parameter event                 as character.
define input parameter old_value              as character.         
define input parameter new_value              as character.
define input parameter what                as character.
define input parameter usr              as character.
define buffer q_w for wood.

do transaction:
find q_w where recid(q_w) = id no-lock no-error.

create vkr_hist.
  if available q_w then vkr_hist.reference = q_w.reference.
  vkr_hist.event = event.
  vkr_hist.val = new_value.
  vkr_hist.old_val = old_value.
  vkr_hist.who = usr.
  vkr_hist.id = id.
  vkr_hist.what = what.
  vkr_hist.savedate = today.
  vkr_hist.savetime = time.
end.
 
end.

/*=====================================================================
=                                                                     =
=              Account Setup Module from customer setup               =
=                VKR System by Andrey Popov, May 1998                 =
=                                                                       =
=====================================================================*/

procedure acc_cst_st:

define input parameter i_prefix like customers.prefix.
define input parameter i_grp        like customers.grp.

define variable rec_id  as integer.
define variable back_code       as integer initial 0.
define variable grps as integer initial 0.
define buffer s_tree for tree.
define buffer s_customers for customers.

find s_customers where s_customers.prefix = i_prefix and s_customers.grp = i_grp no-lock .
     if available s_customers then do: 
           form_title = s_customers.name. 
           grps = s_customers.grp.
     end.
         else form_title = tree.prefix.

repeat:

{jabro.i

&start             = " "
&head      =         "tree"
&headkey   =         "tree"
&index     =         "account_idx"
&formname  =         "acc_cst_stp"
&framename =         "acc_cst_stp"
&where     =         "tree.prefix = i_prefix and tree.grp = i_grp" 
&addcon    =         "true"
&deletecon =         "true"
&predelete =         " " 
&precreate =         " "
&postadd    =         "
                tree.old_acc  = 'no'.
                tree.prefix   = i_prefix.
                tree.grp = grps.
                update tree.ancestor with frame acc_cst_stp.
                tree.ancestor = trim(tree.ancestor). 
                
                if tree.ancestor <> ? and tree.ancestor <> '' then do:
                   tree.account = tree.ancestor + delimiter_symbol + i_prefix.
                   display tree.account with frame acc_cst_stp.  
                end.
                
                update tree.account  with frame acc_cst_stp.
                update tree.old_acc  with frame acc_cst_stp.
                tree.account = trim(tree.account).
                tree.old_acc = trim(tree.old_acc).                 
                update tree.uniq     with frame acc_cst_stp.
                
                if tree.ancestor <> ? and tree.ancestor <> '' then do:
                  tree.acctype = 'S'.
                  display tree.acctype with frame acc_cst_stp. 
                  find s_tree where s_tree.account = tree.ancestor and tree.grp = grps exclusive-lock no-error.  
                   if available s_tree then do:
                      if s_tree.acctype <> 'A' then s_tree.acctype = 'C'.
                      tree.crc = s_tree.crc.  
                      display tree.crc with frame acc_cst_stp.
                   end.
                end.
                else do:
                tree.acctype = 'A'.
                display tree.acctype with frame acc_cst_stp.
                find aaa where aaa.aaa = tree.account no-lock no-error.
                   if available aaa then do:
                      tree.crc = aaa.crc.
                      display tree.crc with frame acc_cst_stp.
                   end.
                   else do:
                      message 'Not found account :' + tree.account.
                      undo,retry.
                   end.

                end.
                update tree.statement  with frame acc_cst_stp.
                if tree.prefix begins main_acc_bin /* Main Platon Account Always Not Active !!! */
                   then tree.active = no.
                else 
                   tree.active = yes. 
                tree.savedate = today.
                tree.savetime = time. 
                if grps <> 0 then 
                run structure ( g-today, 1, grps).
                "
&prechoose =         " "
&predisplay =         " "  
&display   =         "tree.account
                  tree.ancestor 
                 tree.old_acc
                 tree.uniq
                 tree.crc 
                 tree.acctype
                 tree.statement"
&highlight =         "tree.account"
&postkey   =         "
                else 
                if keyfunction (lastkey) = 'return' then do:
                   run account_setup(crec).
                   pause 0 no-message.
                end.
                "
&end =                 "hide frame acc_cst_stp."

}

if keyfunction (lastkey) = "end-error" then return.

end. /* repeat ... */
end. 

/*=====================================================================
=                                                                     =
=           Hold Balance Setup Module from customer setup             =
=                VKR System by Andrey Popov, May 1998                 =
=                                                                       =
=====================================================================*/

procedure hold_setup:

define variable rec_id  as integer.
define variable back_code       as integer initial 0.

{jabro.i

&start     =    " "
&head      =         " hold "
&headkey   =         " hold "
&index     =         " acc_idx "
&formname  =         "f_hold"
&framename =         "f_hold"
&where     =         " " 
&addcon    =         " true "
&deletecon =         " true "
&predelete =         " " 
&precreate =         " "
&postadd    =         " " 
&prechoose =         " "
&predisplay =         " find aas where aas.aaa = hold.aas_aaa and aas.ln = hold.aas_ln no-lock no-error."
&display   =         " hold.account format 'x(16)' no-label
                  aas.aaa      format 'x(10)' no-label                         
                      aas.ln       format '99'    no-label     
                      aas.chkamt   format '->>>,>>>,>>>,>>9.99' no-label        
                  aas.paye     format 'x(25)' no-label        
                 "
&highlight =         " hold.account "
&postkey   =         " else 
                   if keyfunction(lastkey) = 'return' then do:
                          end. 
                "
&end =                 " hide frame f_hold. "

}
end. 

/* =========================================================================
=                                                                           =
=                                Replace                                           =
=                                                                           =
========================================================================= */

procedure replace:
   define input-output parameter source as character.
   define input parameter old_symbol         as character.
   define input parameter new_symbol        as character.

   define variable src_len as integer.
   define variable src_pos as integer.
   define variable old_len as integer.

   src_pos = 1.
   old_len = length ( old_symbol ).
   src_len = length ( source ).

repeat:
  if src_pos > src_len then leave.   
  if substring(source, src_pos, old_len) = old_symbol then 
               substring(source, src_pos, old_len) = new_symbol.       
  src_pos = src_pos + 1.
end.

end.

/* =========================================================================
=                                                                          =
=                            Setup of account                              =
=                                                                          =
========================================================================= */

procedure account_setup:

define input parameter crec as recid.

define variable rec_id         as integer.
define variable back_code         as integer initial 0.
define variable sts_key as character.

find tree where recid(tree) = crec exclusive-lock no-error.

define variable r-code as integer initial 0.

define button acpt              label "Accept".
define button can DEFAULT       label "Cancel" .
define button edt               label "Continue".

form
        tree.account        at row 2 column 2      label "Account "
        tree.ancestor        at row 2 column 30     label "Ancestor"
        tree.old_acc        at row 4 column 2      label "Old. Acc"
        tree.prefix        at row 4 column 30     label "Prefix         "
        tree.def_prefix at row 5 column 30     label "Default Prefix "        
        tree.name        at row 6 column 2      view-as editor inner-chars 25 inner-lines 2 label "Name"
        
        tree.acctype        at row 8 column 2      label "Acc. Type   "
        tree.active        at row 8 column 30     label "Acc. Active "
        tree.crc        at row 9 column 2      label "CRC         "  
        tree.statement        at row 9 column 30     label "Statement   "
        tree.uniq        at row 10 column 2     label "Uniqueness  "
        tree.sts         at row 10 column 30    label "Status      "
        tree.sts_date        at row 10 column 50    no-label
        tree.grp        at row 11 column 2     label "Group       "

        acpt                at row 12 column 28      
        can                at row 12 column 38      
        edt                at row 12 column 50
        " "                at row 13 column 60      

with side-labels overlay title "Account Setup" at row 5 column 10 frame set_account.

on choose of can do:
   r-code = 1.
end.

on choose of acpt do:
   r-code = 2.
end.

on choose of edt do:
   r-code = 0.
end.


 repeat:

                 
                           display tree.account          with frame set_account.
                           display tree.ancestor         with frame set_account.
                           display tree.name                with frame set_account.
                           display tree.prefix                with frame set_account.
                           display old_acc                with frame set_account.
                           display tree.acctype                with frame set_account.
                           display tree.active                with frame set_account.
                           display tree.crc                with frame set_account.
                           display tree.statement        with frame set_account.
                           display tree.uniq                with frame set_account.
                           display tree.sts              with frame set_account.
                           display tree.sts_date         with frame set_account.
                           display tree.def_prefix         with frame set_account.
                           display tree.grp              with frame set_account.

                          update tree.def_prefix         with frame set_account.
                           update tree.name              with frame set_account.
                           update tree.statement         with frame set_account.
                           sts_key = tree.sts. 
                           update tree.sts                with frame set_account.
                          if tree.sts = "c" then tree.sts = "C".
                          tree.who = g-ofc.
                           if tree.sts <> sts_key then tree.sts_date = g-today.
                           tree.savedate = today.
                                 tree.savetime = time.
                              enable acpt can edt  with frame set_account. 
                              
                          wait-for window-close of current-window
                                                           or choose of can
                                                           or choose of acpt
                                                           or choose of edt focus edt.

if r-code = 1 then do:
   undo, leave.
end.

if r-code = 2 then do:
   leave.
end.

if keyfunction(lastkey) = "end-error" then do:
   leave.
end.

end.

hide frame set_account.

return.
end.
