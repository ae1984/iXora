/* getdeptxb.i
 * MODULE
        Ќ §ў ­ЁҐ ЏЮ®ёЮ ¬¬­®ё® Њ®¤Ц«О
 * DESCRIPTION
        Ќ §­ ГҐ­ЁҐ ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ ЇЮ®ФҐ¤ЦЮ Ё ДЦ­ЄФЁ©
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
        22/06/06 nataly
 * CHANGES
*/

function getdep returns char (v-cif as char).
def var vdep as integer no-undo.
def var vpoint as integer no-undo.
def var v-dep as char no-undo.

find txb.cif where cif.cif = v-cif no-lock no-error.
if avail txb.cif then do: 

 vpoint = integer(cif.jame) / 1000 - 0.5.
 vdep = integer(cif.jame) - vpoint * 1000.
 find txb.ppoint where  ppoin.depart = vdep no-lock no-error.
 if avail txb.ppoint then v-dep = ppoint.tel1  .
end.
else v-dep = "000" .

return string(v-dep, "999").
end function.

