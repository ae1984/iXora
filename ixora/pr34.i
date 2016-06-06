/* pr34.i
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

find sysc where sysc.sysc = 'pr34' no-lock no-error.
if avail sysc  then v-pr34 = sysc.chval.
find sysc where sysc.sysc = 'pr34_4' no-lock no-error.
if avail sysc  then v-pr34_4 = sysc.chval.
find sysc where sysc.sysc = 'pr34_5' no-lock no-error.
if avail sysc  then v-pr34_5 = sysc.chval.
find sysc where sysc.sysc = 'pr34_6' no-lock no-error.
if avail sysc  then v-pr34_6 = sysc.chval.
find sysc where sysc.sysc = 'pr34_7' no-lock no-error.
if avail sysc  then v-pr34_7 = sysc.chval.
find sysc where sysc.sysc = 'pr34_8' no-lock no-error.
if avail sysc  then v-pr34_8 = sysc.chval.
find sysc where sysc.sysc = 'pr34_9' no-lock no-error.
if avail sysc  then v-pr34_9 = sysc.chval.
find sysc where sysc.sysc = 'pr3410' no-lock no-error.
if avail sysc  then v-pr34_10 = sysc.chval.
find sysc where sysc.sysc = 'pr3411' no-lock no-error.
if avail sysc  then v-pr34_11 = sysc.chval.


   for each t-cods where  {&dep}  and  lookup(substr(t-cods.code,1,3),v-pr34) > 0
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
        if lookup(substr(t-cods.code,1,7),v-pr34_4) > 0 then temp2.pr34_4 =  temp2.pr34_4 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr34_5) > 0  then temp2.pr34_5 = temp2.pr34_5 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr34_6) > 0  then temp2.pr34_6 = temp2.pr34_6 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr34_7) > 0  then temp2.pr34_7 = temp2.pr34_7 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr34_8) > 0  then temp2.pr34_8 = temp2.pr34_8 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr34_9) > 0  then temp2.pr34_9 = temp2.pr34_9 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr34_10) > 0  then temp2.pr34_10 = temp2.pr34_10 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr34_11) > 0  then temp2.pr34_11 = temp2.pr34_11 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
      end. /*temp*/
     end. /*if avail*/
    else do:
    for each temp2 where temp2.mon = month(t-cods.jdt) and temp2.tn <> "" .
        if lookup(substr(t-cods.code,1,7),v-pr34_4) > 0 then temp2.pr34_4 =  temp2.pr34_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr34_5) > 0 then temp2.pr34_5 =  temp2.pr34_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr34_6) > 0 then temp2.pr34_6 =  temp2.pr34_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr34_7) > 0 then temp2.pr34_7 =  temp2.pr34_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr34_8) > 0 then temp2.pr34_8 =  temp2.pr34_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr34_9) > 0 then temp2.pr34_9 =  temp2.pr34_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr34_10) > 0 then temp2.pr34_10 =  temp2.pr34_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr34_11) > 0 then temp2.pr34_11 =  temp2.pr34_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
      end.
     end. /*else*/
    end.  /*last-of t-cods.code*/
   end.
