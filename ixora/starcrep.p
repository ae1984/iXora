/* starcrep.p
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

/* ====================================================================== 
=                                                                       =
=                Prostm Archive Table Update Procedure                  =
=                                                                       =
====================================================================== */


define shared variable  g-cif like cif.cif.
define shared variable  g-lang   as  character.
define shared variable  g-batch  as  log.
define shared variable  g-today  as  date.

define variable oper_date as date.
define variable cnt       as decimal initial 0.

form 
    oper_date format "99/99/999" label "Operational Date"
with side-label title "Statement archive repair" frame q1.     

update oper_date with frame q1.

/* 
find first sysc where sysc.sysc = "GLDATE" no-lock no-error.
if available sysc then do:
   oper_date = sysc.daval.
end.
else do:
   display "Can not find GLDATE variable in sysc. Terminated." with row 2 column 2 frame q1.
   run elog("UPDPRO","ERR", "Not found last Operation date. Terminated.").
   return "1".
end.
*/
/* ============ Transaction Processing ================ */

run elog("UPDPRO","SYS", "Update deals for " + string(oper_date) + " archive Started ...").   

display string(time, "HH:MM:SS") 
        oper_date  
        "Deals Archive Update Started ..." with no-label row 2 column 2 frame q2.

for each jl where jl.jdt = oper_date no-lock.

 find first gl where gl.gl = jl.gl and gl.subled = "cif" no-lock no-error.
    if available gl then do transaction:  /* --- If Customers Transaction --- */
        
        run adprost(recid(jl), "dft") .
        
        cnt = cnt + 1.
        
        display 
               jl.acc  label "Account"
               jl.jh   label "TRX"
               cnt     label "Nr." format "zzzzzzzz9" 
        with row 5 column 2 frame u.
        
        pause 0.
        
    end.
end.

/* ===================================================== */  

display string(time, "HH:MM:SS") "Update deals archive Completed." with row 8 column 2 frame q3.

run elog("UPDPRO","SYS", "Update " + trim(string(cnt,">>>,>>>,>>9")) + " deals archive Completed.").   
return "0".
      
