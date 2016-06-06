/* stnacc.p
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

/* ==============================================================================
=										=
=		   Statement Generator Account Adding Procedure                 =
=										=
============================================================================== */


define input parameter in_cif 	  like cif.cif.
define input parameter in_account like aaa.aaa.
define input parameter in_period  as integer.

define shared variable g-today as date.
define shared variable g-ofc   like ofc.ofc.
define variable rrr  as recid.

find first stmset where stmset.aaa = in_account no-lock no-error.
if available stmset and stmset.cif = in_cif then return "0".  

rrr = recid(stmset).

if available stmset and stmset.cif <> in_cif then do transaction:

   find stmset where recid(stmset) = rrr exclusive-lock.
   
   for each stmshi where stmshi.cif = stmset.cif.
       stmshi.cif = in_cif.
   end.
   
   for each stgenhi where stgenhi.cif = stmset.cif.
       stgenhi.cif = in_cif.
   end.
   
   stmset.cif = in_cif.
   
   return "0".
   
end.

if not available stmset then do transaction:
   
   create stmset.
   
      stmset.cif = in_cif.
      stmset.aaa = in_account.
      stmset.pstart = g-today.
      stmset.seq = 1.
      stmset.period = in_period.
      stmset.iseq = 1.
      stmset.print = "".
      stmset.who = g-ofc.
      stmset.whn = g-today.
                              

   create stmshi.
     
      stmshi.cif = in_cif.
      stmshi.aaa = in_account.
      stmshi.seq = 1.
      stmshi.period = in_period.
      stmshi.pstart = g-today.
      stmshi.who    = g-ofc.
      stmshi.data   = g-today. 

end.



