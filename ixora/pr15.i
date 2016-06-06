/* pr15.i
 * MODULE
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 15
 * DESCRIPTION
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 15
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

find sysc where sysc.sysc = 'pr15' no-lock no-error.
if avail sysc  then v-pr15 = sysc.chval.
find sysc where sysc.sysc = 'pr15_4' no-lock no-error.
if avail sysc  then v-pr15_4 = sysc.chval.
find sysc where sysc.sysc = 'pr15_5' no-lock no-error.
if avail sysc  then v-pr15_5 = sysc.chval.
find sysc where sysc.sysc = 'pr15_6' no-lock no-error.
if avail sysc  then v-pr15_6 = sysc.chval.
find sysc where sysc.sysc = 'pr15_7' no-lock no-error.
if avail sysc  then v-pr15_7 = sysc.chval.
find sysc where sysc.sysc = 'pr15_8' no-lock no-error.
if avail sysc  then v-pr15_8 = sysc.chval.
find sysc where sysc.sysc = 'pr15_9' no-lock no-error.
if avail sysc  then v-pr15_9 = sysc.chval.

   for each t-cods where lookup(substr(t-cods.code,1,5),v-pr15) > 0  break by month(t-cods.jdt) by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).
   if last-of(substr(t-cods.code,1,7)) then do:                            
    for each temp where temp.mon = month(t-cods.jdt) and temp.tn <> ""  .
    if lookup(substr(t-cods.code,1,7),v-pr15_4) > 0 then temp.pr15_4 =  temp.pr15_4 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr15_5) > 0 then temp.pr15_5 =  temp.pr15_5 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr15_6) > 0 then temp.pr15_6 =  temp.pr15_6 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr15_7) > 0  then temp.pr15_7 = temp.pr15_7 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr15_8) > 0 then temp.pr15_8 =  temp.pr15_8 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr15_9) > 0 then temp.pr15_9 =  temp.pr15_9 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
    end. /*temp*/ 
   end. 
   end.
