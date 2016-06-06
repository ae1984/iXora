/* pr10.i
 * MODULE
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 10
 * DESCRIPTION
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 10
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

find sysc where sysc.sysc = 'pr10' no-lock no-error.
if avail sysc  then v-pr10 = sysc.chval.
find sysc where sysc.sysc = 'pr10_4' no-lock no-error.
if avail sysc  then v-pr10_4 = sysc.chval.
find sysc where sysc.sysc = 'pr10_5' no-lock no-error.
if avail sysc  then v-pr10_5 = sysc.chval.
find sysc where sysc.sysc = 'pr10_6' no-lock no-error.
if avail sysc  then v-pr10_6 = sysc.chval.
find sysc where sysc.sysc = 'pr10_7' no-lock no-error.
if avail sysc  then v-pr10_7 = sysc.chval.
find sysc where sysc.sysc = 'pr10_8' no-lock no-error.
if avail sysc  then v-pr10_8 = sysc.chval.
find sysc where sysc.sysc = 'pr10_9' no-lock no-error.
if avail sysc  then v-pr10_9 = sysc.chval.
find sysc where sysc.sysc = 'pr1010' no-lock no-error.
if avail sysc  then v-pr1010 = sysc.chval.

   for each t-cods where lookup(substr(t-cods.code,1,5),v-pr10) > 0  break by month(t-cods.jdt) by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).
   if last-of(substr(t-cods.code,1,7)) then do:                            
    for each temp where temp.mon = month(t-cods.jdt) and temp.tn <> ""  .
    if lookup(substr(t-cods.code,1,7),v-pr10_4) > 0 then temp.pr10_4 =  temp.pr10_4 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr10_5) > 0 then temp.pr10_5 =  temp.pr10_5 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr10_6) > 0 then temp.pr10_6 =  temp.pr10_6 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr10_7) > 0  then temp.pr10_7 = temp.pr10_7 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr10_8) > 0 then temp.pr10_8 =  temp.pr10_8 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr10_9) > 0 then temp.pr10_9 =  temp.pr10_9 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
     else if lookup(substr(t-cods.code,1,7),v-pr1010) > 0 then temp.pr10_10 =  temp.pr10_10 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn. 
    end. /*temp*/ 
   end. 
   end.
