/* pr9.i
 * MODULE
        ЋБГҐБ Ї® Ю АЕ®¤ ¬ Ї® ’Њ–
 * DESCRIPTION
        ЋБГҐБ Ї® Ю АЕ®¤ ¬ Ї® ’Њ–
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

find sysc where sysc.sysc = 'pr9' no-lock no-error.
if avail sysc  then v-pr9 = sysc.chval.
find sysc where sysc.sysc = 'pr9_4' no-lock no-error.
if avail sysc  then v-pr9_4 = sysc.chval.
find sysc where sysc.sysc = 'pr9_5' no-lock no-error.
if avail sysc  then v-pr9_5 = sysc.chval.
find sysc where sysc.sysc = 'pr9_6' no-lock no-error.
if avail sysc  then v-pr9_6 = sysc.chval.
find sysc where sysc.sysc = 'pr9_7' no-lock no-error.
if avail sysc  then v-pr9_7 = sysc.chval.

   for each t-cods where  {&dep}  and  lookup(substr(t-cods.code,1,5),v-pr9) > 0
                     break by month(t-cods.jdt) by t-cods.dep by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).
   if last-of(substr(t-cods.code,1,7)) then do:                            

    find first codfr where codfr = 'sproftcn' and codfr.name[4] = t-cods.dep no-lock no-error.
   if avail codfr then do :
    find first temp where temp.dep = trim(codfr.name[3]) no-lock no-error.
    if not avail temp then do:
     create temp.
       assign 
        temp.tn   = ""
        temp.name = ""
        temp.rnn  = ""
        temp.dep  = codfr.name[3]
        temp.depname = codfr.name[1]
        temp.post   = ""
        temp.tottndep = 1
        temp.tottn = 0
        temp.mon   = month(t-cods.jdt). 
      {add_temp.i &tmp = "temp1"}. 

        message temp.dep temp.depname.
      end.       
    for each temp where temp.mon = month(t-cods.jdt)  and temp.dep = codfr.name[3].
        if lookup(substr(t-cods.code,1,7),v-pr9_4) > 0 then temp.pr9_4 =  temp.pr9_4 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr9_5) > 0  then temp.pr9_5 = temp.pr9_5 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr9_6) > 0  then temp.pr9_6 = temp.pr9_6 + ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr9_7) > 0  then temp.pr9_7 = temp.pr9_7 +   ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
      end. /*temp*/
     end. /*if avail*/
    else do:
    for each temp where temp.mon = month(t-cods.jdt) and temp.tn <> "" .
        if lookup(substr(t-cods.code,1,7),v-pr9_4) > 0 then temp.pr9_4 =  temp.pr9_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr9_5) > 0 then temp.pr9_5 =  temp.pr9_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr9_6) > 0 then temp.pr9_6 =  temp.pr9_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr9_7) > 0 then temp.pr9_7 =  temp.pr9_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      end.
     end. /*else*/
    end.  /*last-of t-cods.code*/
   end.
