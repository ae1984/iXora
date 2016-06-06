/* pr12.i
 * MODULE
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 12
 * DESCRIPTION
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 12
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

find sysc where sysc.sysc = 'pr12' no-lock no-error.
if avail sysc  then v-pr12 = sysc.chval.

find sysc where sysc.sysc = 'pr12_4' no-lock no-error.
if avail sysc  then v-pr12_4 = sysc.chval.

find sysc where sysc.sysc = 'pr12_5' no-lock no-error.
if avail sysc  then v-pr12_5 = sysc.chval.

find sysc where sysc.sysc = 'pr12_6' no-lock no-error.
if avail sysc  then v-pr12_6 = sysc.chval.

find sysc where sysc.sysc = 'pr12_7' no-lock no-error.
if avail sysc  then v-pr12_7 = sysc.chval.

find sysc where sysc.sysc = 'pr12_8' no-lock no-error.
if avail sysc  then v-pr12_8 = sysc.chval.

find sysc where sysc.sysc = 'pr12_9' no-lock no-error.
if avail sysc  then v-pr12_9 = sysc.chval.

find sysc where sysc.sysc = 'pr1210' no-lock no-error.
if avail sysc  then v-pr1210 = sysc.chval.


   for each t-cods where lookup(substr(t-cods.code,1,3),v-pr12) > 0    break by month(t-cods.jdt) by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).
   if last-of(substr(t-cods.code,1,7)) then do:                            
    for each temp where temp.mon = month(t-cods.jdt) .
       if lookup(substr(t-cods.code,1,7),v-pr12_4) > 0  then temp.pr12_4  =  temp.pr12_4 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
  else if lookup(substr(t-cods.code,1,7),v-pr12_5) > 0  then temp.pr12_5  =  temp.pr12_5 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
  else if lookup(substr(t-cods.code,1,7),v-pr12_6) > 0  then temp.pr12_6  =  temp.pr12_6 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
  else if lookup(substr(t-cods.code,1,7),v-pr12_7) > 0  then temp.pr12_7 =  temp.pr12_7 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
  else if lookup(substr(t-cods.code,1,7),v-pr12_8) > 0  then temp.pr12_8 =  temp.pr12_8 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
  else if lookup(substr(t-cods.code,1,7),v-pr12_9) > 0  then temp.pr12_9 =  temp.pr12_9 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
  else if lookup(substr(t-cods.code,1,7),v-pr1210) > 0  then temp.pr12_10 =  temp.pr12_10 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam)) / temp.tottn.
 end. /*temp*/
 end. 
end.
