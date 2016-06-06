/* st_inbank.p
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
=								=
=		   Inbank	    			        =
=								=
============================================================== */

define input  parameter rec_id 		as recid.
define output parameter o_dealtrn 	as character.
define output parameter o_custtrn 	as character.
define output parameter o_ordins	as character.
define output parameter o_ordcust	as character.
define output parameter o_ordacc	as character.
define output parameter o_benfsr	as character.
define output parameter o_benacc	as character.
define output parameter o_benbank	as character.
define output parameter o_dealsdet	as character.
define output parameter o_bankinfo      as character.

define buffer s-jh for jh.
define buffer s-jl for jl.
define buffer s-jou for joudoc.
define variable t_string as character extent 2.
define variable entrys as integer.

define variable c1 as character.
define variable c2 as character. 

define variable s1 as character.
define variable s2 as character.

find s-jl where recid(s-jl) = rec_id no-lock no-error.
if not available s-jl then do:
  return "1".
end.  

find s-jh where s-jh.jh = s-jl.jh no-lock no-error.
if not available s-jh then do: 
   return "1".
end.

if trim(s-jh.party)  <> ? then o_dealtrn = trim(s-jh.party).
if trim(s-jl.rem[4]) <> ? then o_custtrn = "Nr." + trim(s-jl.rem[4]).
o_dealsdet = trim(s-jl.rem[1]) .

entrys = 1.

if s-jl.dam <> 0 then do:  /* CounterParty - Credit Part */

     t_string[1] = entry(entrys,s-jl.rem[3],"^") no-error.
     entrys = entrys + 1.
     t_string[2] = entry(entrys,s-jl.rem[3],"^") no-error.

     o_benfsr = trim(t_string[1]).
     o_benacc = trim(t_string[2]).
     
     entrys = 1.
     
     t_string[1] = entry(entrys,s-jl.rem[2],"^") no-error.
     entrys = entrys + 1.
     t_string[2] = entry(entrys,s-jl.rem[2],"^") no-error. 
   
     o_ordcust = trim(t_string[1]).
     o_ordacc =  trim(t_string[2]).   
  
end.

if s-jl.cam <> 0 then do:  /* CounterParty - Debit Part  */ 
   
     t_string[1] = entry(entrys,s-jl.rem[2],"^") no-error.
     entrys = entrys + 1.
     t_string[2] = entry(entrys,s-jl.rem[2],"^") no-error. 
   
     o_ordcust = trim(t_string[1]).
     o_ordacc =  trim(t_string[2]).   
     
     entrys = 1.
     
     t_string[1] = entry(entrys,s-jl.rem[3],"^") no-error.
     entrys = entrys + 1.
     t_string[2] = entry(entrys,s-jl.rem[3],"^") no-error.

     o_benfsr = trim(t_string[1]).
     o_benacc = trim(t_string[2]).
   
end.


return "0".          


          
          
