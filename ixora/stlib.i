/* stlib.i
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

/* =========================================================================== 
=									     =
=			Statement Generator System 			     =
=		 	Common System's Library 			     =
=				stlib.i					     =
=========================================================================== */ 	

procedure pskip :

define input parameter n as integer.
 
  put "" skip (n).
  
  row_in_page = row_in_page + n + 1.

  if row_in_page >= rows then do:   
     new_page = yes.
     page_num = page_num + 1.
     total_page = total_page + 1.
     {pagenum.i}
     if new_acc = no then do:
      put "Счет  " + acc_list.aaa + " " + tcrc + t2 at 1 + margin format "x(40)".
      put "( продолжение )" to 70 + margin. 
      run pskip(0).
     end.
  end.    

end.

procedure pwskip :

define input parameter n as integer.
 
  
  put "" skip(n).
  
  row_in_page = row_in_page + n + 1.
  
  if row_in_page >= rows then do: 
     new_page = yes.
     page_num = page_num + 1.
     total_page = total_page + 1.
     {pgwnum.i}
     if new_acc = no then do:
      put "Счет " + acc_list.aaa + " " + tcrc + t2 at 1 + margin format "x(40)".
      put "( продолжение )" at 80 + margin. 
      run pwskip(0).
     end.
  end.    

end.

procedure setv:

   define input parameter i_name  as character.
   define input parameter i_chval as character.
   define input parameter i_inval as integer.
   define input parameter i_dval  as date.


   find first t-header where t-header.name = i_name exclusive-lock no-error.
   if not available t-header then return "1".
   
   t-header.chval = i_chval.
   t-header.inval = i_inval.
   t-header.dval  = i_dval.

   return "0". 

end.

/* ------------------- Get by Name - Character ----------------------------- */

procedure getcv:

   define input  parameter  i_name as character.
   define output parameter o_name as character.

   find first t-header where t-header.name = i_name exclusive-lock no-error.
   if not available t-header then return "1".
   
   o_name = t-header.chval.

end.


/* ------------------- Get by Name - Integer  ----------------------------- */

procedure getiv :

   define input parameter i_name as character.  
   define output parameter o_name as integer.

   find first t-header where t-header.name = i_name exclusive-lock no-error.
   if not available t-header then return "1".
   
   o_name = t-header.inval. 

end.


/* ------------------- Get by Name - Date ----------------------------- */

procedure getdv:

   define input parameter i_name  as character .
   define output parameter o_name as date. 

   find first t-header where t-header.name = i_name exclusive-lock no-error.
   if not available t-header then return "01/01/01".

   o_name = t-header.dval. 

end.



/* ----------------- Get Strings X Format ---------------------------------------- */

procedure getformat:

   define input parameter i_code   as character.
   define input parameter i_fid    as character.
   define input parameter i_frcode as character. 
   define output parameter o_name  as character.


   find first stitem where stitem.icode  = i_code and
                           stitem.frcode = i_frcode no-lock no-error.

   if not available stitem then return "1".

   o_name =  string(stitem.strings) + " " + stitem.ie_format.  

end.




/* --------- Temporary Table 'deals' adding procedure ------------------ */


procedure add_deal:


DEFINE INPUT PARAMETER in_recid    AS recid.
DEFINE INPUT PARAMETER in_account  AS CHARACTER .

DEFINE INPUT PARAMETER in_d_date   AS DATE      .
DEFINE INPUT PARAMETER in_amount   AS DECIMAL   .
DEFINE INPUT PARAMETER in_crc      AS INTEGER   .

DEFINE INPUT PARAMETER in_trxtrn   AS CHARACTER .

DEFINE INPUT PARAMETER in_servcode AS CHARACTER .

DEFINE INPUT PARAMETER in_in_value AS INTEGER .

define variable o_dealtrn	as character initial ?.
define variable o_custtrn	as character initial ?.
define variable o_ordins	as character initial ?.
define variable o_ordcust	as character initial ?.
define variable o_ordacc	as character initial ?.
define variable o_benfsr	as character initial ?.
define variable o_benacc	as character initial ?.
define variable o_benbank	as character initial ?.
define variable o_dealsdet	as character initial ?.
define variable o_trxcode       as character initial ?.
define variable o_bankinfo      as character initial ?.

define buffer b-jl for jl.
define buffer b-aal for aal.
define buffer b-aax for aax.
define buffer b-jh  for jh.

do transaction :

   create deals.

    deals.account  = in_account.
    deals.crc      = in_crc.
    deals.d_date   = in_d_date.
    deals.amount   = in_amount.
    deals.servcode = in_servcode.
    deals.trxtrn   = in_trxtrn.
    deals.in_value = in_in_value.
 
    /* --- Transaction Details Processing --- */
    
    case deals.servcode:
      
      when "lt" then do:

         find b-jl where recid(b-jl) = in_recid no-lock no-error.
            if not available b-jl then return "1".  
         find first b-jh where b-jh.jh = b-jl.jh no-lock no-error.
            if not available b-jh then return "1".

          {lt-trx.i "deals"} 
      
      end.
 
      when "hb" then do:
           define buffer b-aas for aas.
           find b-aas where recid ( b-aas ) = in_recid no-lock no-error.
            if not available b-aas then return "1".
            find first sic where sic.sic = b-aas.sic no-lock.
            
            deals.ordcust = b-aas.payee.
            deals.dealsdet = sic.des. 
            deals.who = b-aas.who.
      end.

      when "hbi" then do:
           define buffer c-aas for aas_hist.
           find c-aas where recid ( c-aas ) = in_recid no-lock no-error.
            if not available c-aas then return "1".
            find first sic where sic.sic = c-aas.sic no-lock.
            
            deals.in_value = c-aas.ln.
            deals.d_date = c-aas.regdt.
            deals.ordcust = c-aas.payee.
            deals.dealsdet = sic.des. 
            deals.who = c-aas.who.
      end.
      
      
      when "st" then do: 
        find b-aal where recid(b-aal) = in_recid no-lock no-error.
                  if not available b-aal then return "1".
        
         find trxcods where trxcods.trxh = b-jl.jh  and
                            trxcods.trxln = b-jl.ln and
	   		    trxcods.codfr = v-codfr no-lock no-error.

         if available trxcods then deals.trxcode = trxcods.code.
                               else deals.trxcode = "MSC".	 

        find b-aax  where integer(recid(b-aax)) = in_in_value no-lock no-error.
   
         if in_amount < 0   then deals.dc = "c".
         if in_amount >= 0  then deals.dc = "d". 
       
         deals.amount = absolute(in_amount).

         deals.dealsdet = trim(b-aax.des) + " " + 
                          trim(b-aal.rem[1]) + " " + 
			  trim(b-aal.rem[2]) + " " + 
			  trim(b-aal.rem[3]) + " " + 
			  trim(b-aal.rem[4]) + " " + 
			  trim(b-aal.rem[5]). 

         if deals.trxcode = ? or deals.trxcode = "MSC" then do:
            case b-aal.aax :
                 when 1  then deals.trxcode = "CSH".
                 when 51 then deals.trxcode = "CSH".
                 when 11 then deals.trxcode = "CHG".
                 when 14 then deals.trxcode = "CHG".
                 when 12 then deals.trxcode = "TAX". 
                 when 17 then deals.trxcode = "TAX". 
                 when 66 then deals.trxcode = "TAX". 
                 when 85 then deals.trxcode = "TAX".  
            end. 
         end.  
      end.
      otherwise do:
      end.
    end.
    /* -------------------------------------- */
end.
return "0".
end procedure.

