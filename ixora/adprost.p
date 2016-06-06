/* adprost.p
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
=                                                                        =
=                 Pro Statement Deals Registrator                        =
=                                                                        =
====================================================================== */


DEFINE INPUT PARAMETER in_recid    AS RECID.
DEFINE INPUT PARAMETER in_codfr    AS CHARACTER.


define shared variable  g-cif like cif.cif.
define shared variable  g-lang   as  character.
define shared variable  g-batch  as  log.
define shared variable  g-today  as  date.

define variable o_dealtrn        as character initial ?.
define variable o_custtrn        as character initial ?.
define variable o_ordins        as character initial ?.
define variable o_ordcust        as character initial ?.
define variable o_ordacc        as character initial ?.
define variable o_benfsr        as character initial ?.
define variable o_benacc        as character initial ?.
define variable o_benbank        as character initial ?.
define variable o_dealsdet        as character initial ?.
define variable o_bankinfo      as character initial ?.
define variable o_trxcode       as character initial ?.

define buffer b-jl for jl.
define buffer b-aal for aal.
define buffer b-aax for aax.
define buffer b-jh  for jh.
define variable v-codfr like codfr.codfr.

do transaction :


    /* --- Transaction Details Processing --- */
    
         find b-jl where recid(b-jl) = in_recid no-lock no-error.
            if not available b-jl then return "1".  
         find first b-jh where b-jh.jh = b-jl.jh no-lock no-error.
            if not available b-jh then return "1".      
            
         if b-jl.rem[1] begins "O/D PROTECT" or
            b-jl.rem[1] begins "O/D PAYMENT" then return "0".  
            
         
                    
         create prostm.
         
         prostm.servcode = "lt".
         prostm.account  = b-jl.acc.
         prostm.crc      = b-jl.crc.
         prostm.d_date   = b-jl.jdt.
         prostm.trxtrn   = string(b-jl.jh).  
         prostm.trxln    = b-jl.ln.
         
         {lt-trx.i "prostm"}
              
end. /* end transaction ... */

return "0".


/* --------------------------------------------------------------------- */

