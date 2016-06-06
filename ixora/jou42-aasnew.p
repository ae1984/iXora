/* jou42-aasnew.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Блокирует сумму на счете получателя при помощи спец. инструкций для контроля старшим менеджером
        Вызывается для вида проводки ARP -> СЧЕТ и блокирует средства, переведенные с ARP-счетов КРЕДИТОРОВ Валютного Контроля
 * RUN
        
 * CALLER
        jou_main.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2-1
 * AUTHOR
        03.10.2003 nadejda  - скопирован jou-aasnew.p
 * CHANGES
        12.11.2003 nadejda  - проставление признака снятия средств в списке блокированных сумм вынесено в vcjoublk.p
*/

def input parameter v-dracc as char.

find arp where arp.arp = v-dracc no-lock no-error.
if not avail arp then return.


/* если это не счет валютного контроля - не надо специнструкции, выход */
def var v-arpblkgl as char init "286060".

find sysc where sysc.sysc = "ARPBGL" no-lock no-error.
if avail sysc then v-arpblkgl = sysc.chval.

if lookup(string(arp.gl), v-arpblkgl) = 0 then return.


{jou-aasnew.i 
 &start = "  "
}


