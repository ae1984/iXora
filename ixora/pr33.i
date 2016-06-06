/* pr33.i
 * MODULE
        Љ®¬¬Ц­ «Л­КҐ ¤®Е®¤К
 * DESCRIPTION
        Љ®¬¬Ц­ «Л­КҐ ¤®Е®¤К
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

find sysc where sysc.sysc = 'pr33' no-lock no-error.
if avail sysc  then v-pr33 = sysc.chval.
find sysc where sysc.sysc = 'pr33_4' no-lock no-error.
if avail sysc  then v-pr33_4 = sysc.chval.
find sysc where sysc.sysc = 'pr33_5' no-lock no-error.
if avail sysc  then v-pr33_5 = sysc.chval.
find sysc where sysc.sysc = 'pr33_6' no-lock no-error.
if avail sysc  then v-pr33_6 = sysc.chval.
find sysc where sysc.sysc = 'pr33_7' no-lock no-error.
if avail sysc  then v-pr33_7 = sysc.chval.
find sysc where sysc.sysc = 'pr33_8' no-lock no-error.
if avail sysc  then v-pr33_8 = sysc.chval.
find sysc where sysc.sysc = 'pr33_9' no-lock no-error.
if avail sysc  then v-pr33_9 = sysc.chval.

find sysc where sysc.sysc = 'pr3310' no-lock no-error.
if avail sysc  then v-pr33_10 = sysc.chval.
find sysc where sysc.sysc = 'pr3311' no-lock no-error.
if avail sysc  then v-pr33_11 = sysc.chval.
find sysc where sysc.sysc = 'pr3312' no-lock no-error.
if avail sysc  then v-pr33_12 = sysc.chval.
find sysc where sysc.sysc = 'pr3313' no-lock no-error.
if avail sysc  then v-pr33_13 = sysc.chval.
find sysc where sysc.sysc = 'pr3314' no-lock no-error.
if avail sysc  then v-pr33_14 = sysc.chval.
find sysc where sysc.sysc = 'pr3315' no-lock no-error.
if avail sysc  then v-pr33_15 = sysc.chval.
find sysc where sysc.sysc = 'pr3316' no-lock no-error.
if avail sysc  then v-pr33_16 = sysc.chval.



   for each t-cods where  {&dep}  and  lookup(substr(t-cods.code,1,3),v-pr33) > 0
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
   /*   message t-cods.code t-cods.dep (accum total by substr(t-cods.code,1,7) t-cods.cam)  -  (accum total by substr(t-cods.code,1,7) t-cods.dam).*/
   for each temp2 where temp2.mon = month(t-cods.jdt)  and temp2.dep = codfr.name[3].
        if lookup(substr(t-cods.code,1,7),v-pr33_4) > 0 then temp2.pr33_4 =  temp2.pr33_4 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_5) > 0  then temp2.pr33_5 = temp2.pr33_5 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_6) > 0  then temp2.pr33_6 = temp2.pr33_6 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_7) > 0  then temp2.pr33_7 = temp2.pr33_7 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_8) > 0  then temp2.pr33_8 = temp2.pr33_8 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_9) > 0  then temp2.pr33_9 = temp2.pr33_9 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_10) > 0  then temp2.pr33_10 = temp2.pr33_10 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_11) > 0  then temp2.pr33_11 = temp2.pr33_11 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_12) > 0  then temp2.pr33_12 = temp2.pr33_12 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_13) > 0  then temp2.pr33_13 = temp2.pr33_13 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_14) > 0  then temp2.pr33_14 = temp2.pr33_14 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_15) > 0  then temp2.pr33_15 = temp2.pr33_15 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr33_16) > 0  then temp2.pr33_16 = temp2.pr33_16 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
      end. /*temp*/
     end. /*if avail*/
    else do:
    for each temp2 where temp2.mon = month(t-cods.jdt) and temp2.tn <> "" .
        if lookup(substr(t-cods.code,1,7),v-pr33_4) > 0 then temp2.pr33_4 =  temp2.pr33_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_5) > 0 then temp2.pr33_5 =  temp2.pr33_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_6) > 0 then temp2.pr33_6 =  temp2.pr33_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_7) > 0 then temp2.pr33_7 =  temp2.pr33_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_8) > 0 then temp2.pr33_8 =  temp2.pr33_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_9) > 0 then temp2.pr33_9 =  temp2.pr33_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_10) > 0 then temp2.pr33_10 =  temp2.pr33_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_11) > 0 then temp2.pr33_11 =  temp2.pr33_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_12) > 0 then temp2.pr33_12 =  temp2.pr33_12 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_13) > 0 then temp2.pr33_13 =  temp2.pr33_13 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_14) > 0 then temp2.pr33_14 =  temp2.pr33_14 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_15) > 0 then temp2.pr33_15 =  temp2.pr33_15 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr33_16) > 0 then temp2.pr33_16 =  temp2.pr33_16 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
      end.
     end. /*else*/
    end.  /*last-of t-cods.code*/
   end.
