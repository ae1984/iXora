/* rnn-is-client2.p
 * MODULE
         Общий
 * DESCRIPTION
        Проверка по РНН является ли владелец клиентом бака
 * RUN
        
 * CALLER
   rnn-is-client.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        02.05.2004 tsoy
*/


def input parameter v-rnn as char.
def input-output parameter v-ans as logical.

v-ans = no.
find first cif where jss = v-rnn no-lock no-error.
if avail cif then do:
   find first aaa where aaa.cif = cif.cif and trim(aaa.sta) <> "C" no-lock no-error.
   if avail aaa then do:
     v-ans = yes.
     return.
   end.
end. 
    
