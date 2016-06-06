/* data_rgt.p
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

/*==========================================================================
=                                                                                                                                =
=                   Data Registrator Utility                                                                               =
=              VKR System by Andrey Popov April 1998.                                                       =
=                                                                                                                                =
==========================================================================*/                                                                 

define variable rgt_active_group like wood.grp initial ?.	  /* Customer Group */

{vkr_lib.i}
{r-htrx2.f}

/* _________________________________________________________________________________________ */

define input parameter r_id	as integer.
define input parameter in_trx_type	as integer.


/* ------------- Data Definition & Searching --------------------------- */

define variable account   like wood.account initial "". 	/* Deals / Account 	*/
define variable d_date    as date initial ?.            	/* Deals / Account Date   */
define variable inward    as decimal initial 0.         	/* Deals / Account Inward  */
define variable outward   as decimal initial 0.        	/* Deals / Account Outward */   
define variable vjh       as integer.        	/* Transaction Reference */  
define variable vjl       as integer.         	/* Transaction Reference */  
define variable reference as character.   	/* Deals Reference */
define variable customer  as character.		/* Customer Name */
define variable details   as character.    	/* Deals Details */	
define variable source    as character.      	/* Deals Source Code */
define variable whois	  like wood.who.	/* Username */
define variable opr_type  as integer.		/* Operation Type */

define variable trxcode	  as character initial "trf".		/* Transaction Code */	

define variable rmzsqn	  as character.		/* Remtrz Sequence */
define variable parv_amt  as character.		/* Parveduma Summa */ 
define variable ordcust	  as character.         /* Ordering Customer */
define variable benacc	  as character.		/* Bneficiary Account */
define variable ordins    as character.         /* Ordering Institution */
define variable benyafisher as character.	/* Beneficiary Customer */
define variable benyabank as character.         /* Beneficiary Bank */
define variable detpay	  as character.		/* Details of Payment */
define variable rcvinfo	  as character.		/* Receiver Information */



define variable rec_id as integer.
define variable messg  as character format "x(100)".
define variable crc    as integer initial 0.
define variable r-codr like nmbr.code initial "REMTRZ".
define variable r-sufr like nmbr.sufix.
define variable r-ler  as integer.
define variable src    like wood.source.

define buffer   s-jl   for jl.
define buffer   s-tree for tree.

 if in_trx_type = 0 then do: /* ------------------ Long Transaction Processing ------------ */
 
    define buffer m_jl for jl.
    
    find m_jl where recid(m_jl) = r_id no-lock no-error.
    
    if not available m_jl then return.
    
    account = trim(m_jl.acc).
    d_date  = m_jl.jdt.
    inward  = m_jl.cam.
    outward = m_jl.dam.  
    crc = m_jl.crc.
    vjh = m_jl.jh.
    vjl = m_jl.ln.
    whois = m_jl.who.
    opr_type = m_jl.aax.
    
    reference = substring(m_jl.rem[1],1,10).
    
    if reference begins "RMZ" then do: /* ------------- Remittance Processing ---------- */
       find remtrz where remtrz.remtrz = reference no-lock no-error.
         if not available remtrz then do:
            run event_rgt ( "DataRgt", "Insert", account, reference, g-ofc, "Not found remittance" ).
         end.
         
         
          if remtrz.sqn <> ? then rmzsqn = "Nr. " + trim(substr(remtrz.sqn,19)) + " " .
          
          if remtrz.ordins[1] <> ? then ordins = trim (remtrz.ordins[1]) + " ".
          if remtrz.ordins[2] <> ? then ordins = ordins + trim (remtrz.ordins[2]) + " ".              
          if remtrz.ordins[3] <> ? then ordins = ordins + trim (remtrz.ordins[3]) + " ".              
          if remtrz.ordins[4] <> ? then ordins = ordins + trim (remtrz.ordins[4]) + " ".              
          
          if remtrz.ord <> ? then ordcust = trim(remtrz.ord) + " ".
          
          if remtrz.bn[1] <> ? then benyafisher = trim ( remtrz.bn[1] ) + " ".
          if remtrz.bn[2] <> ? then benyafisher = benyafisher + trim ( remtrz.bn[2] ) + " ".
          if remtrz.bn[3] <> ? then benyafisher = benyafisher + trim ( remtrz.bn[3] ) + " ".
          
          benyabank  = trim ( trim(remtrz.bb[1]) + " " + trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3])). 
          benacc = trim(remtrz.ba).
          detpay = benacc + " " + trim( trim(remtrz.detpay[1]) + " " + trim(remtrz.detpay[2]) + " " + trim(remtrz.detpay[3]) + " " + trim(remtrz.detpay[4]) ).
          rcvinfo = trim ( trim(remtrz.rcvinfo[1]) + " " + trim(remtrz.rcvinfo[2])).
          src = reference.          
          
          /* Inward Payment Processing ------------------------------ */
         if ( m_jl.cam > 0  OR ( m_jl.dam > 0 AND remtrz.ptype = "7" ) ) then do: /* Inward */
         
          customer = benyafisher.       
          
          details = reference + " " + 
                    rmzsqn + " " + 
                    ordins + " " + 
                    ordcust + " " +
                    benyafisher + " " + 
                    detpay + " " + 
                    rcvinfo.
          
          /*
          find crc where crc.crc = remtrz.fcrc no-lock no-error.
          details = trim(details) + pu2 + trim(string(remtrz.amt, "zzz,zzz,zzz,zz9.99")) + " " + crc.code.    
          */
          /* Comission Fees ------------------------- */         
             
             find s-jl where s-jl.jh = m_jl.jh and
                             s-jl.jdt = m_jl.jdt and
                             s-jl.gl > 700000 and s-jl.gl < 800000 and
                             s-jl.dam = m_jl.cam no-lock no-error.
             if available s-jl then do:
                details = reference + " " + "Komisija.".
                trxcode = "com".
             end.                    

          /* ---------------------------------------- */
          
         end. /* Inward end. */            
         
         /* Outward Payment Processing ------------------------------ */
         if ( m_jl.dam > 0  AND remtrz.ptype <> "7" ) then do: /* Outward */
         
          customer = ordcust.          
          
          details = reference + " " + 
                    rmzsqn + " " + 
                    ordcust + " " +
                    benyabank + " " + 
                    benyafisher + " " + 
                    detpay + " " + 
                    rcvinfo.
          
          /* Comission Fees ------------------------- */         

             find s-jl where s-jl.jh = m_jl.jh and
                             s-jl.jdt = m_jl.jdt and
                             s-jl.gl > 700000 and s-jl.gl < 800000 and
                             s-jl.cam = m_jl.dam no-lock no-error.
             if available s-jl then do:
                details = reference + " " + "Komisija.".
                trxcode = "com".
             end. /* Outward end. */                    

          /* ---------------------------------------- */
          
         end. /* Inward end. */            
         
    end.
     else do: /* ---------------- Other Deals Processing -------------------- */
      details = trim ( m_jl.rem[1] + m_jl.rem[2] + m_jl.rem[3] + m_jl.rem[4] + m_jl.rem[5]).
     end. 
     
     /* -------------------------------------------------------------- */
 
 end.  /* if in_trx_type = 0 ... Long Transaction Processing ... Done */ 
  else 
 do: /* ----------------------- Short Transaction Processing -------------------- */
    define buffer m_aal for aal.
    
    find m_aal where recid(m_aal) = r_id no-lock no-error.
    
    if not available m_aal then return.
    
    account = trim(m_aal.aaa).
    d_date =  m_aal.regdt.
    
    find aaa where aaa.aaa = account no-lock no-error.
    
    if not available aaa then do:
      run event_rgt ( "DataRgt", "Insert", account, "", g-ofc, "Not found found in aaa").
      return "1".   
    end.
    
    find aax where aax.lgr = aaa.lgr and aax.ln = m_aal.aax no-lock no-error.  
    
    if not available aax then do:
       run event_rgt ( "DataRgt", "Insert", account, m_aal.aax, g-ofc, "Not found found in aax").
       return "1".
    end.
    
    if aax.drcr < 0 then  do:  
       inward =  m_aal.amt.
       outward = 0.
    end.   
    else do: 
       inward = 0.
       outward = m_aal.amt. 
    end.
       
    crc = m_aal.crc.
    vjh = m_aal.aah.
    vjl = m_aal.ln.
    whois = m_aal.who.
    opr_type = m_aal.aax.
    
    details = trim ( trim(m_aal.rem[1]) + " " + trim(m_aal.rem[2]) + " " 
            + trim(m_aal.rem[3]) + " " + trim(m_aal.rem[4]) + " " + trim(m_aal.rem[5]) ). 
 end.      


/* ------------------------------------------------------------------------------ */

/* ------------- Incoming Data Checking ----------------------------------------- */

if ( account <> "" and ( inward <> 0 or outward <> 0 ) and d_date <> ? ) then do:

/* ------------- Account Checking Procedure ------------------------------------- */

 run checker ( reference, account, customer, details, opr_type, output rgt_active_group ).
 new_account = return-value. 

/* ------------------------------------------------------------------------------ */		                 

reference = string(vjh) + "-" + string(vjl).

if new_account = "" or new_account = ? or new_account = "1" or rgt_active_group = ?  then do:
   run event_rgt ( "DataRgt", "Deal. Add", account, reference, g-ofc,"Checker Error. Terminated").
   return "1".
end.

if new_account = "2" then do:
   run event_rgt ( "DataRgt", "Deal. Add", account, reference, g-ofc,"Found Money Transfer to Main Account. Skipped").
   return "0".
end.

/* -------- New-Date Data Structure Creating ---------------- */

find first wood where wood.date = d_date and wood.grp = rgt_active_group no-lock no-error.		/* Checking for account structure for date availability */
 
if not available wood then do:
  run structure (d_date, 0, rgt_active_group).
  if return-value = "1" then do:
     run event_rgt ( "DataRgt", "Str.Creation", new_account, reference, g-ofc,"Account Structure for " + string(date) + " NOT created !. Terminated." ).
     return "1". 
  end.
end. 

/* ----------------------------------------------------------- */

do transaction: 

find first wood where wood.date = d_date  and
                      wood.trx_type = in_trx_type and 
                      wood.jh = vjh and
                      wood.jl = vjl   exclusive-lock no-error.
     
 if not available wood then do:  /* Found the same deal entry */
    create wood.
    
    wood.grp = rgt_active_group.
    wood.acctype = "D".
    wood.trx_type = in_trx_type.
    wood.date = d_date.  
    wood.jh = vjh.
    wood.jl = vjl.
    wood.account = new_account.
    wood.reference = reference.
    
    run h_w ( integer(recid(wood)), "create", new_account, "" , "", g-ofc).

    if inward <> 0 then messg = "Inward: " +  trim ( string ( inward ,">,>>>,>>>,>99.99"))   .
     else 
       if outward <> 0 then messg = "Outward: " +  trim ( string ( outward ,">,>>>,>>>,>99.99")) .
        else 
          if balance <> 0 then messg = "Balance: " + trim ( string ( balance ,">,>>>,>>>,>99.99")) .

   run event_rgt ( "DataRgt", "Insert", new_account, reference, g-ofc, messg ). 
 end.   
    
    wood.account = new_account.
    wood.i_amt = inward.
    wood.o_amt = outward.
    wood.reference = reference.
    wood.crc = crc.
    wood.details = details.
    wood.sts = deal_sts.
    wood.who = whois.
    wood.aax = opr_type.
    wood.source = src.
    wood.trx_code = trxcode. 
    wood.savedate = today.
    wood.savetime = time.

end. /* transaction ... */

release wood no-error.

end.
