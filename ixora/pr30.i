/* pr30.i
 * MODULE
        ЏЮ®ФҐ­Б­КҐ ¤®Е®¤К
 * DESCRIPTION
        ЏЮ®ФҐ­Б­КҐ ¤®Е®¤К
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-12
 * AUTHOR
        22/06/06 nataly
 * CHANGES
*/

find sysc where sysc.sysc = 'pr30' no-lock no-error.
if avail sysc  then v-pr30 = sysc.chval.
find sysc where sysc.sysc = 'pr30_4' no-lock no-error.
if avail sysc  then v-pr30_4 = sysc.chval.
find sysc where sysc.sysc = 'pr30_5' no-lock no-error.
if avail sysc  then v-pr30_5 = sysc.chval.
find sysc where sysc.sysc = 'pr30_6' no-lock no-error.
if avail sysc  then v-pr30_6 = sysc.chval.
find sysc where sysc.sysc = 'pr30_7' no-lock no-error.
if avail sysc  then v-pr30_7 = sysc.chval.
find sysc where sysc.sysc = 'pr30_8' no-lock no-error.
if avail sysc  then v-pr30_8 = sysc.chval.
find sysc where sysc.sysc = 'pr30_9' no-lock no-error.
if avail sysc  then v-pr30_9 = sysc.chval.

find sysc where sysc.sysc = 'pr3010' no-lock no-error.
if avail sysc  then v-pr30_10 = sysc.chval.
find sysc where sysc.sysc = 'pr3011' no-lock no-error.
if avail sysc  then v-pr30_11 = sysc.chval.
find sysc where sysc.sysc = 'pr3012' no-lock no-error.
if avail sysc  then v-pr30_12 = sysc.chval.
find sysc where sysc.sysc = 'pr3013' no-lock no-error.
if avail sysc  then v-pr30_13 = sysc.chval.
find sysc where sysc.sysc = 'pr3014' no-lock no-error.
if avail sysc  then v-pr30_14 = sysc.chval.
find sysc where sysc.sysc = 'pr3015' no-lock no-error.
if avail sysc  then v-pr30_15 = sysc.chval.
find sysc where sysc.sysc = 'pr3016' no-lock no-error.
if avail sysc  then v-pr30_16 = sysc.chval.
find sysc where sysc.sysc = 'pr3017' no-lock no-error.
if avail sysc  then v-pr30_17 = sysc.chval.
find sysc where sysc.sysc = 'pr3018' no-lock no-error.
if avail sysc  then v-pr30_18 = sysc.chval.

find sysc where sysc.sysc = 'pr3019' no-lock no-error.
if avail sysc  then v-pr30_19 = sysc.chval.
find sysc where sysc.sysc = 'pr3020' no-lock no-error.
if avail sysc  then v-pr30_20 = sysc.chval.
find sysc where sysc.sysc = 'pr3021' no-lock no-error.
if avail sysc  then v-pr30_21 = sysc.chval.
find sysc where sysc.sysc = 'pr3022' no-lock no-error.
if avail sysc  then v-pr30_22 = sysc.chval.
find sysc where sysc.sysc = 'pr3023' no-lock no-error.
if avail sysc  then v-pr30_23 = sysc.chval.
find sysc where sysc.sysc = 'pr3024' no-lock no-error.
if avail sysc  then v-pr30_24 = sysc.chval.
find sysc where sysc.sysc = 'pr3025' no-lock no-error.
if avail sysc  then v-pr30_25 = sysc.chval.
find sysc where sysc.sysc = 'pr3026' no-lock no-error.
if avail sysc  then v-pr30_26 = sysc.chval.
find sysc where sysc.sysc = 'pr3027' no-lock no-error.
if avail sysc  then v-pr30_27 = sysc.chval.
find sysc where sysc.sysc = 'pr3028' no-lock no-error.
if avail sysc  then v-pr30_28 = sysc.chval.
find sysc where sysc.sysc = 'pr3029' no-lock no-error.
if avail sysc  then v-pr30_29 = sysc.chval.
find sysc where sysc.sysc = 'pr3030' no-lock no-error.
if avail sysc  then v-pr30_30 = sysc.chval.

find sysc where sysc.sysc = 'pr3031' no-lock no-error.
if avail sysc  then v-pr30_31 = sysc.chval.
find sysc where sysc.sysc = 'pr3032' no-lock no-error.
if avail sysc  then v-pr30_32 = sysc.chval.
find sysc where sysc.sysc = 'pr3033' no-lock no-error.
if avail sysc  then v-pr30_33 = sysc.chval.
find sysc where sysc.sysc = 'pr3034' no-lock no-error.
if avail sysc  then v-pr30_34 = sysc.chval.
find sysc where sysc.sysc = 'pr3035' no-lock no-error.
if avail sysc  then v-pr30_35 = sysc.chval.
find sysc where sysc.sysc = 'pr3036' no-lock no-error.
if avail sysc  then v-pr30_36 = sysc.chval.

   for each t-cods where  {&dep}  and  lookup(substr(t-cods.code,1,3),v-pr30) > 0
                     break by month(t-cods.jdt) by t-cods.dep by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).
   if last-of(substr(t-cods.code,1,7)) then do:                            
    find first codfr where codfr = 'sproftcn' and codfr.name[4] = t-cods.dep no-lock no-error.
   if avail codfr then do :
    find first temp2 where temp2.dep = trim(codfr.name[3]) no-lock no-error.
    if not avail temp2 then do:
     create temp2.
       assign 
        temp2.tn   = ""
        temp2.name = ""
        temp2.rnn  = ""
        temp2.dep  = codfr.name[3]
        temp2.depname = codfr.name[1]
        temp2.post   = ""
        temp2.tottndep = 1
        temp2.tottn = 0
        temp2.mon   = month(t-cods.jdt). 
      end.       
    for each temp2 where temp2.mon = month(t-cods.jdt)  and temp2.dep = codfr.name[3].
        if lookup(substr(t-cods.code,1,7),v-pr30_4) > 0 then temp2.pr30_4 =  temp2.pr30_4 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_5) > 0  then temp2.pr30_5 = temp2.pr30_5 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_6) > 0  then temp2.pr30_6 = temp2.pr30_6 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
       /* else if lookup(substr(t-cods.code,1,7),v-pr30_7) > 0  then temp2.pr30_7 = temp2.pr30_7 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.*/
        else if lookup(substr(t-cods.code,1,7),v-pr30_8) > 0  then temp2.pr30_8 = temp2.pr30_8 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_9) > 0  then temp2.pr30_9 = temp2.pr30_9 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_10) > 0  then temp2.pr30_10 = temp2.pr30_10 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_11) > 0  then temp2.pr30_11 = temp2.pr30_11 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_12) > 0  then temp2.pr30_12 = temp2.pr30_12 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_13) > 0  then temp2.pr30_13 = temp2.pr30_13 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_14) > 0  then temp2.pr30_14 = temp2.pr30_14 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_15) > 0  then temp2.pr30_15 = temp2.pr30_15 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_16) > 0  then temp2.pr30_16 = temp2.pr30_16 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_17) > 0  then temp2.pr30_17 = temp2.pr30_17 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_18) > 0  then temp2.pr30_18 = temp2.pr30_18 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_19) > 0  then temp2.pr30_19 = temp2.pr30_19 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_20) > 0  then temp2.pr30_20 = temp2.pr30_20 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_21) > 0  then temp2.pr30_21 = temp2.pr30_21 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_22) > 0  then temp2.pr30_22 = temp2.pr30_22 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_23) > 0  then temp2.pr30_23 = temp2.pr30_23 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_24) > 0  then temp2.pr30_24 = temp2.pr30_24 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_25) > 0  then temp2.pr30_25 = temp2.pr30_25 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_26) > 0  then temp2.pr30_26 = temp2.pr30_26 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_27) > 0  then temp2.pr30_27 = temp2.pr30_27 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_28) > 0  then temp2.pr30_28 = temp2.pr30_28 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_29) > 0  then temp2.pr30_29 = temp2.pr30_29 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_30) > 0  then temp2.pr30_30 = temp2.pr30_30 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_31) > 0  then temp2.pr30_31 = temp2.pr30_31 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_32) > 0  then temp2.pr30_32 = temp2.pr30_32 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_33) > 0  then temp2.pr30_33 = temp2.pr30_33 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_34) > 0  then temp2.pr30_34 = temp2.pr30_34 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_35) > 0  then temp2.pr30_35 = temp2.pr30_35 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr30_36) > 0  then temp2.pr30_36 = temp2.pr30_36 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
      end. /*temp*/
     end. /*if avail*/
    else do:
    for each temp2 where temp2.mon = month(t-cods.jdt) and temp2.tn <> "" .
        if lookup(substr(t-cods.code,1,7),v-pr30_4) > 0 then temp2.pr30_4 =  temp2.pr30_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_5) > 0 then temp2.pr30_5 =  temp2.pr30_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_6) > 0 then temp2.pr30_6 =  temp2.pr30_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_7) > 0 then temp2.pr30_7 =  temp2.pr30_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_8) > 0 then temp2.pr30_8 =  temp2.pr30_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_9) > 0 then temp2.pr30_9 =  temp2.pr30_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_10) > 0 then temp2.pr30_10 =  temp2.pr30_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_11) > 0 then temp2.pr30_11 =  temp2.pr30_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_12) > 0 then temp2.pr30_12 =  temp2.pr30_12 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_13) > 0 then temp2.pr30_13 =  temp2.pr30_13 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_14) > 0 then temp2.pr30_14 =  temp2.pr30_14 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_15) > 0 then temp2.pr30_15 =  temp2.pr30_15 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_16) > 0 then temp2.pr30_16 =  temp2.pr30_16 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_17) > 0 then temp2.pr30_17 =  temp2.pr30_17 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_18) > 0 then temp2.pr30_18 =  temp2.pr30_18 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_19) > 0 then temp2.pr30_19 =  temp2.pr30_19 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_20) > 0 then temp2.pr30_20 =  temp2.pr30_20 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_21) > 0 then temp2.pr30_21 =  temp2.pr30_21 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_22) > 0 then temp2.pr30_22 =  temp2.pr30_22 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_23) > 0 then temp2.pr30_23 =  temp2.pr30_23 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_24) > 0 then temp2.pr30_24 =  temp2.pr30_24 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_25) > 0 then temp2.pr30_25 =  temp2.pr30_25 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_26) > 0 then temp2.pr30_26 =  temp2.pr30_26 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_27) > 0 then temp2.pr30_27 =  temp2.pr30_27 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_28) > 0 then temp2.pr30_28 =  temp2.pr30_28 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_29) > 0 then temp2.pr30_29 =  temp2.pr30_29 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_30) > 0 then temp2.pr30_30 =  temp2.pr30_30 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_31) > 0 then temp2.pr30_31 =  temp2.pr30_31 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_32) > 0 then temp2.pr30_32 =  temp2.pr30_32 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_33) > 0 then temp2.pr30_33 =  temp2.pr30_33 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_34) > 0 then temp2.pr30_34 =  temp2.pr30_34 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_35) > 0 then temp2.pr30_35 =  temp2.pr30_35 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr30_36) > 0 then temp2.pr30_36 =  temp2.pr30_36 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
      end.
     end. /*else*/
    end.  /*last-of t-cods.code*/
   end.
