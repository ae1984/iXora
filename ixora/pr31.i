/* pr31.i
 * MODULE
        ЌҐЇЮ®ФҐ­Б­КҐ ¤®Е®¤К
 * DESCRIPTION
        ЌҐЇЮ®ФҐ­Б­КҐ ¤®Е®¤К
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

find sysc where sysc.sysc = 'pr31' no-lock no-error.
if avail sysc  then v-pr31 = sysc.chval.
find sysc where sysc.sysc = 'pr31_4' no-lock no-error.
if avail sysc  then v-pr31_4 = sysc.chval.
find sysc where sysc.sysc = 'pr31_5' no-lock no-error.
 if avail sysc  then v-pr31_5 = sysc.chval.
find sysc where sysc.sysc = 'pr31_6' no-lock no-error.
if avail sysc  then v-pr31_6 = sysc.chval.
find sysc where sysc.sysc = 'pr31_7' no-lock no-error.
if avail sysc  then v-pr31_7 = sysc.chval.
find sysc where sysc.sysc = 'pr31_8' no-lock no-error.
if avail sysc  then v-pr31_8 = sysc.chval.
find sysc where sysc.sysc = 'pr31_9' no-lock no-error.
if avail sysc  then v-pr31_9 = sysc.chval.

find sysc where sysc.sysc = 'pr3110' no-lock no-error.
if avail sysc  then v-pr31_10 = sysc.chval.
find sysc where sysc.sysc = 'pr3111' no-lock no-error.
if avail sysc  then v-pr31_11 = sysc.chval.
find sysc where sysc.sysc = 'pr3112' no-lock no-error.
if avail sysc  then v-pr31_12 = sysc.chval.
find sysc where sysc.sysc = 'pr3113' no-lock no-error.
if avail sysc  then v-pr31_13 = sysc.chval.
find sysc where sysc.sysc = 'pr3114' no-lock no-error.
if avail sysc  then v-pr31_14 = sysc.chval.
find sysc where sysc.sysc = 'pr3115' no-lock no-error.
if avail sysc  then v-pr31_15 = sysc.chval.

   for each t-cods where  {&dep}  and  lookup(substr(t-cods.code,1,3),v-pr31) > 0
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
        message temp2.dep temp2.depname.
      end.       
    for each temp2 where temp2.mon = month(t-cods.jdt)  and temp2.dep = codfr.name[3].
        if lookup(substr(t-cods.code,1,7),v-pr31_4) > 0 then temp2.pr31_4 =  temp2.pr31_4 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_5) > 0  then temp2.pr31_5 = temp2.pr31_5 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_6) > 0  then temp2.pr31_6 = temp2.pr31_6 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_7) > 0  then temp2.pr31_7 = temp2.pr31_7 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_8) > 0  then temp2.pr31_8 = temp2.pr31_8 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_9) > 0  then temp2.pr31_9 = temp2.pr31_9 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_10) > 0  then temp2.pr31_10 = temp2.pr31_10 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_11) > 0  then temp2.pr31_11 = temp2.pr31_11 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_12) > 0  then temp2.pr31_12 = temp2.pr31_12 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_13) > 0  then temp2.pr31_13 = temp2.pr31_13 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_14) > 0  then temp2.pr31_14 = temp2.pr31_14 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr31_15) > 0  then temp2.pr31_15 = temp2.pr31_15 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
/*         message temp2.pr31_4 temp2.pr31_5 temp2.pr31_6  temp2.pr31_7 temp2.pr31_8  temp2.pr31_9 temp2.pr31_10.*/
      end. /*temp*/
     end. /*if avail*/
    else do:
    for each temp2 where temp2.mon = month(t-cods.jdt) and temp2.tn <> "" .
        if lookup(substr(t-cods.code,1,7),v-pr31_4) > 0 then temp2.pr31_4 =  temp2.pr31_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_5) > 0 then temp2.pr31_5 =  temp2.pr31_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_6) > 0 then temp2.pr31_6 =  temp2.pr31_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_7) > 0 then temp2.pr31_7 =  temp2.pr31_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_8) > 0 then temp2.pr31_8 =  temp2.pr31_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_9) > 0 then temp2.pr31_9 =  temp2.pr31_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_10) > 0 then temp2.pr31_10 =  temp2.pr31_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_11) > 0 then temp2.pr31_11 =  temp2.pr31_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_12) > 0 then temp2.pr31_12 =  temp2.pr31_12 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_13) > 0 then temp2.pr31_13 =  temp2.pr31_13 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_14) > 0 then temp2.pr31_14 =  temp2.pr31_14 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr31_15) > 0 then temp2.pr31_15 =  temp2.pr31_15 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
      end.
     end. /*else*/
    end.  /*last-of t-cods.code*/
   end.
