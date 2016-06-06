/* to_crc.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        возвращает иднтификатор валюты  по коду. 
          
 * RUN
        
 * CALLER
        VALM_ps.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        31.05.2004 tsoy
 * CHANGES
*/

def input  parameter p-chcrc as char.
def output parameter p-icrc as integer.

find first crc where crc.code = entry (1,trim(p-chcrc), " ") no-lock no-error.
if avail crc then 
   p-icrc = integer(crc.crc).
else
   p-icrc = 0.




