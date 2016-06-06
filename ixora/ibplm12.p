/* ibplm12.p
 * MODULE
        IOFFICE
 * DESCRIPTION
        Проверка ЭЦП
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-5-12
 * BASES
        BANK COMM IB
 * AUTHOR
        21/01/2006 tsoy 
 * CHANGES
*/                                                 

find sysc where sysc.sysc = "IBHOST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do :

 message " Нет IBHOST записи в sysc файле ! ".
 return.

end.

if not connected("ib") then 
  connect value(sysc.chval) no-error .

if not connected("ib") 
then do:
 message  " INTERNET HOST не отвечает ." .
 return .
end.

run viewib. 

