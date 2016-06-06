/* passval.i
 * MODULE
        Ќ §ў ­ЁҐ ЏЮ®ёЮ ¬¬­®ё® Њ®¤Ц«О
 * DESCRIPTION
        ќБ  i-ХЄ  ®ЇЁАКў ҐБ ЇҐЮҐ¬Ґ­­ЦН А®¤ҐЮ¦ ИЦН Ї Ю®«Л АЦЇҐЮН§ҐЮ  - ¬Ґ­Ґ¤¦ҐЮ  Ї« БҐ¦­®© АЁАБҐ¬К
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        ‘ЇЁА®Є ўК§Кў Ґ¬КЕ ЇЮ®ФҐ¤ЦЮ
 * MENU
        ЏҐЮҐГҐ­Л ЇЦ­ЄБ®ў ЊҐ­Н ЏЮ ё¬К 
 * AUTHOR
        05/11/2003 suchkov
 * CHANGES
*/

define variable vpass as character .
define variable iii as integer .

find sysc where sysc = "sys1" no-lock no-error .
if not available sysc then do:
    message "‚­Ё¬ ­ЁҐ! ЌҐ ­ АБЮ®Ґ­ sysc ­  Ї Ю®«Ё АЦЇҐЮН§ҐЮ®ў!!!" view-as alert-box.
    quit.
end.

do iii = 1 to num-entries (sysc.des):
    if ENTRY (iii, sysc.des) = "superman" then vpass = ENTRY (iii, sysc.chval) .
end.
