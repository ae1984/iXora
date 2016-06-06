/* menudepth.p
 * MODULE
        Главное меню
 * DESCRIPTION
        Нахождение глубины вложенности пункта меню (dfname) 
        относительно его родителя (pfname)
 * RUN
        
 * CALLER
        nmenu.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        12/05/04 sasco
 * CHANGES

*/


define input parameter pfname as character. /* parent fname - для курня меню указать MENU или "" */
define input parameter dfname as character. /* fname того пункта, для которого ищем глубину */
define output parameter depth as character. /* глубина вложенности, считая от указанного pfname */

define variable curfn as character.

if pfname = "" then pfname = "MENU".

define buffer bnmenu for nmenu.

find nmenu where nmenu.fname = pfname no-lock no-error.
if not avail nmenu and pfname <> "MENU" then do:
   depth = ?.
   return.
end.

find nmenu where nmenu.fname = dfname no-lock no-error.
if not avail nmenu then do:
   depth = ?.
   return.
end.

curfn = nmenu.father.
depth = string (nmenu.ln).

do while true:
   if curfn = pfname then leave.
   find nmenu where nmenu.fname = curfn no-lock no-error.
   if not avail nmenu then do:
      depth = ?.
      return.
   end.
   curfn = nmenu.father.
   depth = string (nmenu.ln) + "." + depth.
end.

return.

