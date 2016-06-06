/* st_fexp.p
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
=		   FOREX Details Processor			=
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
define buffer s-fexp for fexp.

define variable c1 as character.
define variable c2 as character. 

define variable s1 as character.
define variable s2 as character.

find s-jl where recid(s-jl) = rec_id no-lock no-error.
if not available s-jl then return "1".

find s-jh where s-jh.jh = s-jl.jh no-lock no-error.
if not available s-jh then return "1".

find s-fexp where s-fexp.fex = substring(trim(s-jh.party),1,10) no-lock no-error.
if not available s-fexp then return "1".

o_dealtrn = s-fexp.fex.

find first crc where crc.crc = fcrc no-lock no-error.
if not available crc then return "1".
c1 = crc.code.

find first crc where crc.crc = tcrc no-lock no-error.
if not available crc then return "1".
c2 = crc.code.

o_custtrn = "".
o_ordins = "".
o_ordcust = "".
o_ordacc = "".
o_benfsr = "".
o_benbank  = "".
o_benacc   = "".

o_bankinfo = string(amt)     + " " + string(c1,"x(3)") + " -> " + 
             string(payment) + " " + string(c2,"x(3)") .
             
case s-fexp.type:
     when 7 then do:
               s1 = substring(s-fexp.party,12,32).
               s2 = substring(s-fexp.party,45,32).
            end.
     when 5 then do:
               s1 = substring(s-fexp.party,12,32).
               s2 = substring(s-fexp.party,45,32).
            end.       
     when 6 then do:
               s1 = substring(s-fexp.party,12,40).
               s2 = "".
            end.       
     otherwise do:
               s1 = " Rate: " + string(payment / amt, ">>9.9999").
               s2 = "".
     end.   
end.        

o_dealsdet = trim( s-fexp.rem ).  

if s-jl.dam > 0  then 
   o_bankinfo = o_bankinfo + " " + s1 + " " + s2.
else 
   o_bankinfo = "".


return "0".          


          
          
