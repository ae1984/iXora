/* pr6.i
 * MODULE
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 6
 * DESCRIPTION
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 6
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        codsdat.p
 * MENU
        ЏҐЮҐГҐ­Л ЇЦ­ЄБ®ў ЊҐ­Н ЏЮ ё¬К 
 * AUTHOR
        22/06/06 nataly
 * CHANGES
*/

find sysc where sysc.sysc = 'pr6' no-lock no-error.
if avail sysc  then v-pr6 = sysc.chval.

find sysc where sysc.sysc = 'pr6_7' no-lock no-error.
if avail sysc  then v-pr6_7 = sysc.chval.

find sysc where sysc.sysc = 'pr6_8' no-lock no-error.
if avail sysc  then v-pr6_8 = sysc.chval.

   for each t-cods where lookup(substr(t-cods.code,1,5),v-pr6) > 0  break by month(t-cods.jdt) by substr(t-cods.code,1,7). 
     accum t-cods.cam  (total by substr(t-cods.code,1,7)).
     accum t-cods.dam  (total by substr(t-cods.code,1,7)).
   if last-of(substr(t-cods.code,1,7)) then do:                            
    for each temp where temp.mon = month(t-cods.jdt) and temp.tn <> "" . /*ҐА«Ё § ЇЁАЛ ­®¬Ё­ «Л­ О, Б® ­  ­ҐҐ Ќ… А ¦ Ґ¬ Ю АЕ®¤К*/

      if lookup(substr(t-cods.code,1,7),v-pr6_7) > 0 then temp.pr6_7 =  temp.pr6_7 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr6_8) > 0 then temp.pr6_8 =  temp.pr6_8 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.

    end. /*temp*/
    end. 
   end.
