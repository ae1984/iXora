/* pr32.i
 * MODULE
        Коммунальные доходы
 * DESCRIPTION
        Коммунальные доходы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-12
 * AUTHOR
        22/06/06 nataly
 * CHANGES
*/

find sysc where sysc.sysc = 'pr32' no-lock no-error.
if avail sysc  then v-pr32 = sysc.chval.
find sysc where sysc.sysc = 'pr32_4' no-lock no-error.
if avail sysc  then v-pr32_4 = sysc.chval.
find sysc where sysc.sysc = 'pr32_5' no-lock no-error.
if avail sysc  then v-pr32_5 = sysc.chval.
find sysc where sysc.sysc = 'pr32_6' no-lock no-error.
if avail sysc  then v-pr32_6 = sysc.chval.
find sysc where sysc.sysc = 'pr32_7' no-lock no-error.
if avail sysc  then v-pr32_7 = sysc.chval.
find sysc where sysc.sysc = 'pr32_8' no-lock no-error.
if avail sysc  then v-pr32_8 = sysc.chval.
find sysc where sysc.sysc = 'pr32_9' no-lock no-error.
if avail sysc  then v-pr32_9 = sysc.chval.

find sysc where sysc.sysc = 'pr3210' no-lock no-error.
if avail sysc  then v-pr32_10 = sysc.chval.
find sysc where sysc.sysc = 'pr3211' no-lock no-error.
if avail sysc  then v-pr32_11 = sysc.chval.
find sysc where sysc.sysc = 'pr3212' no-lock no-error.
if avail sysc  then v-pr32_12 = sysc.chval.
find sysc where sysc.sysc = 'pr3213' no-lock no-error.
if avail sysc  then v-pr32_13 = sysc.chval.
find sysc where sysc.sysc = 'pr3214' no-lock no-error.
if avail sysc  then v-pr32_14 = sysc.chval.
find sysc where sysc.sysc = 'pr3215' no-lock no-error.
if avail sysc  then v-pr32_15 = sysc.chval.
find sysc where sysc.sysc = 'pr3216' no-lock no-error.
if avail sysc  then v-pr32_16 = sysc.chval.
find sysc where sysc.sysc = 'pr3217' no-lock no-error.
if avail sysc  then v-pr32_17 = sysc.chval.
find sysc where sysc.sysc = 'pr3218' no-lock no-error.
if avail sysc  then v-pr32_18 = sysc.chval.

find sysc where sysc.sysc = 'pr3219' no-lock no-error.
if avail sysc  then v-pr32_19 = sysc.chval.
find sysc where sysc.sysc = 'pr3220' no-lock no-error.
if avail sysc  then v-pr32_20 = sysc.chval.
find sysc where sysc.sysc = 'pr3221' no-lock no-error.
if avail sysc  then v-pr32_21 = sysc.chval.
find sysc where sysc.sysc = 'pr3222' no-lock no-error.
if avail sysc  then v-pr32_22 = sysc.chval.
find sysc where sysc.sysc = 'pr3223' no-lock no-error.
if avail sysc  then v-pr32_23 = sysc.chval.
find sysc where sysc.sysc = 'pr3224' no-lock no-error.
if avail sysc  then v-pr32_24 = sysc.chval.
find sysc where sysc.sysc = 'pr3225' no-lock no-error.
if avail sysc  then v-pr32_25 = sysc.chval.

   for each t-cods where  {&dep}  and  lookup(substr(t-cods.code,1,3),v-pr32) > 0
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
        message temp2.dep temp2.depname t-cods.code t-cods.dep  t-cods.gl.
      end.       
    for each temp2 where temp2.mon = month(t-cods.jdt)  and temp2.dep = codfr.name[3].
        if lookup(substr(t-cods.code,1,7),v-pr32_4) > 0 then temp2.pr32_4 =  temp2.pr32_4 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_5) > 0  then temp2.pr32_5 = temp2.pr32_5 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_6) > 0  then temp2.pr32_6 = temp2.pr32_6 + ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,5),v-pr32_7) > 0  then temp2.pr32_7 = temp2.pr32_7 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_8) > 0  then temp2.pr32_8 = temp2.pr32_8 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,5),v-pr32_9) > 0  then temp2.pr32_9 = temp2.pr32_9 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_10) > 0  then temp2.pr32_10 = temp2.pr32_10 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_11) > 0  then temp2.pr32_11 = temp2.pr32_11 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_12) > 0  then temp2.pr32_12 = temp2.pr32_12 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_13) > 0  then temp2.pr32_13 = temp2.pr32_13 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_14) > 0  then temp2.pr32_14 = temp2.pr32_14 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_15) > 0  then temp2.pr32_15 = temp2.pr32_15 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_16) > 0  then temp2.pr32_16 = temp2.pr32_16 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_17) > 0  then temp2.pr32_17 = temp2.pr32_17 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_18) > 0  then temp2.pr32_18 = temp2.pr32_18 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_19) > 0  then temp2.pr32_19 = temp2.pr32_19 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,5),v-pr32_20) > 0  then temp2.pr32_20 = temp2.pr32_20 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_21) > 0  then temp2.pr32_21 = temp2.pr32_21 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_22) > 0  then temp2.pr32_22 = temp2.pr32_22 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_23) > 0  then temp2.pr32_23 = temp2.pr32_23 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,5),v-pr32_24) > 0  then temp2.pr32_24 = temp2.pr32_24 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        else if lookup(substr(t-cods.code,1,7),v-pr32_25) > 0  then temp2.pr32_25 = temp2.pr32_25 +   ((accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottndep.
        /*   message temp2.dep ' 1 ' temp2.pr32_7 temp2.pr32_8 temp2.pr32_9  temp2.pr32_10 temp2.pr32_25.*/
      end. /*temp*/
     end. /*if avail*/
    else do:
    for each temp2 where temp2.mon = month(t-cods.jdt) and temp2.tn <> "" .
        if lookup(substr(t-cods.code,1,7),v-pr32_4) > 0 then temp2.pr32_4 =  temp2.pr32_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_5) > 0 then temp2.pr32_5 =  temp2.pr32_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_6) > 0 then temp2.pr32_6 =  temp2.pr32_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,5),v-pr32_7) > 0 then temp2.pr32_7 =  temp2.pr32_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_8) > 0 then temp2.pr32_8 =  temp2.pr32_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,5),v-pr32_9) > 0 then temp2.pr32_9 =  temp2.pr32_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_10) > 0 then temp2.pr32_10 =  temp2.pr32_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_11) > 0 then temp2.pr32_11 =  temp2.pr32_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_12) > 0 then temp2.pr32_12 =  temp2.pr32_12 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_13) > 0 then temp2.pr32_13 =  temp2.pr32_13 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_14) > 0 then temp2.pr32_14 =  temp2.pr32_14 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_15) > 0 then temp2.pr32_15 =  temp2.pr32_15 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_16) > 0 then temp2.pr32_16 =  temp2.pr32_16 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_17) > 0 then temp2.pr32_17 =  temp2.pr32_17 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_18) > 0 then temp2.pr32_18 =  temp2.pr32_18 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_19) > 0 then temp2.pr32_19 =  temp2.pr32_19 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,5),v-pr32_20) > 0 then temp2.pr32_20 =  temp2.pr32_20 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_21) > 0 then temp2.pr32_21 =  temp2.pr32_21 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_22) > 0 then temp2.pr32_22 =  temp2.pr32_22 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_23) > 0 then temp2.pr32_23 =  temp2.pr32_23 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,5),v-pr32_24) > 0 then temp2.pr32_24 =  temp2.pr32_24 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
        if lookup(substr(t-cods.code,1,7),v-pr32_25) > 0 then temp2.pr32_25 =  temp2.pr32_25 + ( (accum total by substr(t-cods.code,1,7) t-cods.cam) - (accum total by substr(t-cods.code,1,7) t-cods.dam))  / temp2.tottn.
      end.
     end. /*else*/
    end.  /*last-of t-cods.code*/
   end.
