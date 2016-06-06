/* pr8.i
 * MODULE
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 8
 * DESCRIPTION
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 8
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

find sysc where sysc.sysc = 'pr8' no-lock no-error.
if avail sysc  then v-pr8 = sysc.chval.

find sysc where sysc.sysc = 'pr8_4' no-lock no-error.
if avail sysc  then v-pr8_4 = sysc.chval.

find sysc where sysc.sysc = 'pr8_5' no-lock no-error.
if avail sysc  then v-pr8_5 = sysc.chval.

find sysc where sysc.sysc = 'pr8_6' no-lock no-error.
if avail sysc  then v-pr8_6 = sysc.chval.

find sysc where sysc.sysc = 'pr8_7' no-lock no-error.
if avail sysc  then v-pr8_7 = sysc.chval.

find sysc where sysc.sysc = 'pr8_8' no-lock no-error.
if avail sysc  then v-pr8_8 = sysc.chval.

find sysc where sysc.sysc = 'pr8_9' no-lock no-error.
if avail sysc  then v-pr8_9 = sysc.chval.

find sysc where sysc.sysc = 'pr8_10' no-lock no-error.
if avail sysc  then v-pr8_10 = sysc.chval.

find sysc where sysc.sysc = 'pr8_11' no-lock no-error.
if avail sysc  then v-pr8_11 = sysc.chval.


   for each t-cods where lookup(substr(t-cods.code,1,5),v-pr8) > 0  break by month(t-cods.jdt) by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).

   if last-of(substr(t-cods.code,1,7)) then do:                            
    for each temp where temp.mon = month(t-cods.jdt) and temp.tn <> ""  .
      if lookup(substr(t-cods.code,1,7),v-pr8_4) > 0 then temp.pr8_4 =  temp.pr8_4 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr8_5) > 0 then temp.pr8_5 =  temp.pr8_5 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr8_6) > 0 then temp.pr8_6 =  temp.pr8_6 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr8_7) > 0 then temp.pr8_7 =  temp.pr8_7 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr8_8) > 0 then temp.pr8_8 =  temp.pr8_8 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr8_9) > 0 then temp.pr8_9 =  temp.pr8_9 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr8_10) > 0 then temp.pr8_10 =  temp.pr8_10 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      if lookup(substr(t-cods.code,1,7),v-pr8_11) > 0 then temp.pr8_11 =  temp.pr8_11 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
   end. /*temp*/
    end. 
   end.
