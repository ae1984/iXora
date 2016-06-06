/* pr7.i
 * MODULE
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 7
 * DESCRIPTION
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 7
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

find sysc where sysc.sysc = 'pr7' no-lock no-error.
if avail sysc  then v-pr7 = sysc.chval.

find sysc where sysc.sysc = 'pr7_6' no-lock no-error.
if avail sysc  then v-pr7_6 = sysc.chval.

find sysc where sysc.sysc = 'pr7_7' no-lock no-error.
if avail sysc  then v-pr7_7 = sysc.chval.

find sysc where sysc.sysc = 'pr7_8' no-lock no-error.
if avail sysc  then v-pr7_8 = sysc.chval.

find sysc where sysc.sysc = 'pr7_9' no-lock no-error.
if avail sysc  then v-pr7_9 = sysc.chval.

   for each t-cods where lookup(substr(t-cods.code,1,5),v-pr7) > 0  break by month(t-cods.jdt) by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).

   if last-of(substr(t-cods.code,1,7)) then do:                            
    for each temp where temp.mon = month(t-cods.jdt) and temp.tn <> ""  .
      if lookup(substr(t-cods.code,1,7),v-pr7_6) > 0 then temp.pr7_6 =  temp.pr7_6 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr7_7) > 0 then temp.pr7_7 =  temp.pr7_7 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr7_8) > 0 then temp.pr7_8 =  temp.pr7_8 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr7_9) > 0 then temp.pr7_9 =  temp.pr7_9 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
    end. /*temp*/
    end. 
   end.
