/* payseccheck.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Проверка прав на платежную систему
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        23.08.2004 sasco
 * CHANGES
*/


define input parameter g-ofc as character.
define input parameter g-proc as character.

define variable ofc_stack as character. /* стэк для поиска прав - какие пакеты просмотрели, */
                                        /* чтобы избежать циклических ссылок */
function pay_check_permis returns logical (wofc as character, wproc as character).

   define variable ggi as integer.
   define variable wpar as character.
   define variable wlog as logical.

   wlog = no.

   find ofc where ofc.ofc = wofc no-lock no-error.
   if not avail ofc then return no.

   if lookup (wofc, ofc_stack) > 0 then return no.
   wpar = trim(ofc.expr[1]).

   if index(wproc, ".") eq 0 
       then find first pssec where trim(pssec.proc) = wproc no-lock no-error .
       else find first pssec where trim(pssec.proc) + ".p" = wproc no-lock no-error .

   if avail pssec 
      then if lookup(wofc, pssec.ofcs) > 0 
              then return yes.

   ofc_stack = ofc_stack + "," + wofc.
   do ggi = 1 to num-entries (wpar):
      find ofc where ofc.ofc = entry(ggi, wpar) no-lock no-error.
      if not avail ofc then next.
      if not wlog then wlog = pay_check_permis (entry(ggi, wpar), wproc).
   end.
   return wlog.
    
end function.

ofC_stack = "".

if pay_check_permis (g-ofc, g-proc) then return "yes".
                                    else return "no".
