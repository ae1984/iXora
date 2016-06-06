/* vip_rmze.p
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

/* ==============================================================
=                                                                =
=                Remittance Details Processor                        =
=                                                                =
============================================================== */

define input  parameter rec_id 		as recid.
define output parameter o_dealtrn 	as character.
define output parameter o_custtrn 	as character.
define output parameter o_ordinsN	as character.
define output parameter o_ordins	as character.
define output parameter o_ordcustN	as character.
define output parameter o_ordcust	as character.
define output parameter o_ordacc	as character.
define output parameter o_ordacc1	as character.
define output parameter o_benfsrN	as character.
define output parameter o_benfsr	as character.
define output parameter o_benacc	as character.
define output parameter o_benacc1	as character.
define output parameter o_benbankN	as character.
define output parameter o_benbank	as character.
define output parameter o_dealsdet	as character.
define output parameter o_bankinfo      as character.
define output parameter o_vidop         as character init "".

define buffer s-jl for jl.
define buffer s-jh for jh.

find s-jl where recid(s-jl) = rec_id no-lock no-error.
if not available s-jl then return "1".

find s-jh where s-jh.jh = s-jl.jh no-lock no-error.
if not available s-jh then do: 
   return "1".
end.

/*
find remtrz where remtrz.remtrz = substring(s-jl.rem[1],1,10) no-lock no-error.
*/
find first remtrz where s-jh.ref = remtrz.remtrz no-lock no-error .
if not available remtrz then return "1".

o_dealtrn = remtrz.remtrz.

if remtrz.sqn <> ? then o_custtrn = trim(substr(remtrz.sqn,19,8)).  /* Customers TRN */
if o_custtrn ="" then o_custtrn=remtrz.remtrz.


/*------ maksatajs -------*/
if remtrz.sbank begins "TXB" then do:
   find sysc where sysc.sysc eq "CLECOD" no-lock no-error. 
   if available sysc then o_ordinsN = sysc.chval.   

find first bankl where bankl.bank = remtrz.sbank no-lock no-error. 

 if available bankl and bankl.name <> "" then do:
  o_ordins = trim(bankl.name). 
 end.
 else do:
   if remtrz.ordins[1] <> ? then o_ordins = trim (remtrz.ordins[1]).
   if remtrz.ordins[2] <> ? then o_ordins = o_ordins + " " + trim (remtrz.ordins[2]).              
   if remtrz.ordins[3] <> ? then o_ordins = o_ordins + " " + trim (remtrz.ordins[3]).              
   if remtrz.ordins[4] <> ? then o_ordins = o_ordins + " " + trim (remtrz.ordins[4]).               
 end. 
end.
else do:
 o_ordinsN=remtrz.sbank.
 if remtrz.ordins[1] = "NONE" then do:
    find first bankl where bankl.bank = remtrz.sbank no-lock no-error. 

    if available bankl and bankl.name <> "" then do:
      o_ordins = trim(bankl.name).
    end.
 end.
 else do: 
   if remtrz.ordins[1] <> ? then o_ordins = trim (remtrz.ordins[1]).
   if remtrz.ordins[2] <> ? then o_ordins = o_ordins + " " + trim (remtrz.ordins[2]).              
   if remtrz.ordins[3] <> ? then o_ordins = o_ordins + " " + trim (remtrz.ordins[3]).              
   if remtrz.ordins[4] <> ? then o_ordins = o_ordins + " " + trim (remtrz.ordins[4]).              
 end.
end.      


if remtrz.ord <> ? then o_ordcust = trim(remtrz.ord).
 if index(o_ordcust,"/RNN/") ne 0 then do:
   o_ordcustN= substring(o_ordcust,index(o_ordcust,"/RNN/") + 5).
   o_ordcust = substring(o_ordcust,1,index(o_ordcust,"/RNN/") - 1) .
end.

if remtrz.sacc <> "" then o_ordacc = trim(remtrz.sacc).
                     else o_ordacc = trim(remtrz.dracc).

  if index(o_ordacc,"/") ne 0 then do:
    o_ordacc1 = entry(1,o_ordacc,"/").
    o_ordacc  = entry(2,o_ordacc,"/").
  end.

/*----  sanemejs -----*/
if remtrz.rbank begins "TXB" then do:
   find sysc where sysc.sysc eq "CLECOD" no-lock no-error. 
   if available sysc then o_benbankN = sysc.chval.   

 find first bankl where bankl.bank = remtrz.rbank no-lock no-error. 
  if available bankl and bankl.name <> "" then do:
    o_benbank = trim(bankl.name) .
  end.
  else do:
    o_benbank  = trim(remtrz.bb[1]) + " " + trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3]).   
  end.
end.
else do:
  o_benbankN=remtrz.rbank.
  if remtrz.bb[1] = "NONE" then do:
     find first bankl where bankl.bank = remtrz.rbank no-lock no-error. 

    if available bankl and bankl.name <> "" then do:
      o_benbank = trim(bankl.name).
    end.
  end.
  else do:
    o_benbank  = trim(remtrz.bb[1]) + " " + trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3]). 
  end.  
end.


if remtrz.bn[1] <> ? then o_benfsr = trim ( remtrz.bn[1] ).
if remtrz.bn[2] <> ? then o_benfsr = o_benfsr + " " + trim (remtrz.bn[2]).
if remtrz.bn[3] <> ? then o_benfsr = o_benfsr + " " + trim (remtrz.bn[3]).
 if index(o_benfsr,"/RNN/") ne 0 then do:
   o_benfsrN= substring(o_benfsr,index(o_benfsr,"/RNN/") + 5).
   o_benfsr = substring(o_benfsr,1,index(o_benfsr,"/RNN/") - 1) .
end.

if remtrz.ba <> ? then  o_benacc = trim(remtrz.ba).
  if index(o_benacc,"/") ne 0 then do:
    o_benacc1 = entry(1,o_benacc,"/").
    o_benacc  = entry(2,o_benacc,"/").
  end.

if (remtrz.detpay[1]) matches (remtrz.ba + "*") or
   (remtrz.detpay[1]) matches (substring(remtrz.ba,2) + "*") then do:
    o_dealsdet = trim(substring(remtrz.detpay[1], length(o_benacc) + 1)) + " " + trim(remtrz.detpay[2]) + " " + trim(remtrz.detpay[3]) + " " + trim(remtrz.detpay[4]) .
end.
else do:
    o_dealsdet = trim(remtrz.detpay[1]) + " " + trim(remtrz.detpay[2]) + " " + trim(remtrz.detpay[3]) + " " + trim(remtrz.detpay[4]) .
    /* o_dealsdet = o_dealsdet + " " + trim(s-remtrz.rcvinfo[1]) + " " + trim(s-remtrz.rcvinfo[2]). */          
end.



/*
if s-remtrz.fcrc <> s-remtrz.tcrc then do:
  define variable exchange as character.
  o_dealsdet = o_dealsdet + " " + exchange.
end.
*/

          
return "0".          
          
          