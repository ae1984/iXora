/* get-mrp.p
 * MODULE
       Валютный контроль
 * DESCRIPTION
       Письма о лицензировнаии 
 * RUN
        
 * CALLER
    vcltrlic-e.r
    vcltrlic-i.r
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15.8
 * AUTHOR
        17.05.2004 tsoy
 * CHANGES
*/

{global.i}
def var v-mrp as deci.

find first rmin where rmin.god = year (g-today) and rmin.mc = month (g-today) no-lock no-error.
if not avail rmin or rmin.rpm = ? then do:
     v-mrp = 919.
end.  else                  
v-mrp = rmin.rpm. 

return string(v-mrp).

