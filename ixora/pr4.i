/* pr4.i
 * MODULE
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 4
 * DESCRIPTION
        „ ­­КҐ ЇЮЁ«®¦Ґ­ЁО 4
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

find sysc where sysc.sysc = 'pr4' no-lock no-error.
if avail sysc  then v-pr4 = sysc.chval.

find sysc where sysc.sysc = 'pr4_7' no-lock no-error.
if avail sysc  then v-pr4_7 = sysc.chval.

find sysc where sysc.sysc = 'pr4_8' no-lock no-error.
if avail sysc  then v-pr4_8 = sysc.chval.

find sysc where sysc.sysc = 'pr4_9' no-lock no-error.
if avail sysc  then v-pr4_9 = sysc.chval.

find sysc where sysc.sysc = 'pr4_10' no-lock no-error.
if avail sysc  then v-pr4_10 = sysc.chval.

find sysc where sysc.sysc = 'pr4_11' no-lock no-error.
if avail sysc  then v-pr4_11 = sysc.chval.

find sysc where sysc.sysc = 'pr4_12' no-lock no-error.
if avail sysc  then v-pr4_12 = sysc.chval.

find sysc where sysc.sysc = 'pr4_14' no-lock no-error.
if avail sysc  then v-pr4_14 = sysc.chval.

find sysc where sysc.sysc = 'pr4_15' no-lock no-error.
if avail sysc  then v-pr4_15 = sysc.chval.

find sysc where sysc.sysc = 'pr4_16' no-lock no-error.
if avail sysc  then v-pr4_16 = sysc.chval.

                                     
   for each t-cods where lookup(substr(t-cods.code,1,3),v-pr4) > 0 
                         break by month(t-cods.jdt) by trim(t-cods.ls) by substr(t-cods.code,1,7). 
     accum t-cods.cam  (total by substr(t-cods.code,1,7)).
     accum t-cods.dam  (total by substr(t-cods.code,1,7)).

    if last-of(substr(t-cods.code,1,7)) then do:                            
     find temp where trim(temp.tn) = trim(t-cods.ls) and temp.mon = month(t-cods.jdt) no-error.
     if not avail temp then  next.   
     if lookup(substr(t-cods.code,1,7),v-pr4_7) > 0 then temp.pr4_7 = temp.pr4_7 +  (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam).
    else   if lookup(substr(t-cods.code,1,7),v-pr4_8) > 0  then temp.pr4_8 =  temp.pr4_8 +  (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam) .
    else   if lookup(substr(t-cods.code,1,7),v-pr4_9) > 0  then temp.pr4_9 =  temp.pr4_9 +  (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam) .
    else   if lookup(substr(t-cods.code,1,7),v-pr4_10) > 0  then temp.pr4_10 =  temp.pr4_10 +  (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam) .
    else   if lookup(substr(t-cods.code,1,7),v-pr4_11) > 0  then temp.pr4_11 = temp.pr4_11 + (accum  total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam).
    else   if lookup(substr(t-cods.code,1,7),v-pr4_12) > 0  then temp.pr4_12 = temp.pr4_12 + (accum  total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam).
    else   if lookup(substr(t-cods.code,1,7),v-pr4_14) > 0  then temp.pr4_14 = temp.pr4_14 + (accum  total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam).
    else   if lookup(substr(t-cods.code,1,7),v-pr4_15) > 0  then temp.pr4_15 = temp.pr4_15 + (accum  total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam).
    else   if lookup(substr(t-cods.code,1,7),v-pr4_16) > 0  then temp.pr4_16 = temp.pr4_16 + (accum  total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam).
    end. 
   end.

