/* pr13.i
 * MODULE
        Данные приложения 13
 * DESCRIPTION
        Данные приложения 13
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        codsdat.p
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        22/06/06 nataly
 * CHANGES
*/

find sysc where sysc.sysc = 'pr13' no-lock no-error.
if avail sysc  then v-pr13 = sysc.chval.

find sysc where sysc.sysc = 'pr13_4' no-lock no-error.
if avail sysc  then v-pr13_4 = sysc.chval.

find sysc where sysc.sysc = 'pr13_5' no-lock no-error.
if avail sysc  then v-pr13_5 = sysc.chval.

find sysc where sysc.sysc = 'pr13_6' no-lock no-error.
if avail sysc  then v-pr13_6 = sysc.chval.

find sysc where sysc.sysc = 'pr13_7' no-lock no-error.
if avail sysc  then v-pr13_7 = sysc.chval.

find sysc where sysc.sysc = 'pr13_8' no-lock no-error.
if avail sysc  then v-pr13_8 = sysc.chval.

find sysc where sysc.sysc = 'pr13_9' no-lock no-error.
if avail sysc  then v-pr13_9 = sysc.chval.

find sysc where sysc.sysc = 'pr1310' no-lock no-error.
if avail sysc  then v-pr1310 = sysc.chval.

find sysc where sysc.sysc = 'pr1311' no-lock no-error.
if avail sysc  then v-pr1311 = sysc.chval.

find sysc where sysc.sysc = 'pr1312' no-lock no-error.
if avail sysc  then v-pr1312 = sysc.chval.

find sysc where sysc.sysc = 'pr1313' no-lock no-error.
if avail sysc  then v-pr1313 = sysc.chval.

find sysc where sysc.sysc = 'pr1314' no-lock no-error.
if avail sysc  then v-pr1314 = sysc.chval.

find sysc where sysc.sysc = 'pr1315' no-lock no-error.
if avail sysc  then v-pr1315 = sysc.chval.

find sysc where sysc.sysc = 'pr1316' no-lock no-error.
if avail sysc  then v-pr1316 = sysc.chval.


  for each t-cods where  {&dep} and  lookup(substr(t-cods.code,1,3),v-pr13) > 0  
      break by month(t-cods.jdt) by t-cods.dep by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).

   if last-of(substr(t-cods.code,1,7)) then do:                            

    find first codfr where codfr = 'sproftcn' and trim(codfr.name[4]) = t-cods.dep  no-lock no-error.
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
   for each temp where temp.mon = month(t-cods.jdt)  and temp.dep = trim(codfr.name[3]).
      if temp.tottndep = 0 then message 'Нулевое кол-во сотрудников деп-т' temp.dep temp.depname temp.tottndep  temp.mon substr(t-cods.code,1,7).
        if lookup(substr(t-cods.code,1,7),v-pr13_4) > 0 then temp.pr13_4 =  temp.pr13_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr13_5) > 0 then temp.pr13_5 =  temp.pr13_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr13_6) > 0 then temp.pr13_6 =  temp.pr13_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr13_7) > 0 then temp.pr13_7 =  temp.pr13_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr13_8) > 0 then temp.pr13_8 =  temp.pr13_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr13_9) > 0 then temp.pr13_9 =  temp.pr13_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1310) > 0 then temp.pr13_10 =  temp.pr13_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1311) > 0 then temp.pr13_11 =  temp.pr13_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1312) > 0 then temp.pr13_12 =  temp.pr13_12 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1313) > 0 then temp.pr13_13 =  temp.pr13_13 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1314) > 0 then temp.pr13_14 =  temp.pr13_14 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1315) > 0 then temp.pr13_15 =  temp.pr13_15 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1316) > 0 then temp.pr13_16 =  temp.pr13_16 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
      end. /*temp*/
     end. /*if avail*/
    else do:
   for each temp where temp.mon = month(t-cods.jdt)  and temp.tn <> "" .
         if lookup(substr(t-cods.code,1,7),v-pr13_4) > 0 then temp.pr13_4 =  temp.pr13_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr13_5) > 0 then temp.pr13_5 =  temp.pr13_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr13_6) > 0 then temp.pr13_6 =  temp.pr13_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr13_7) > 0 then temp.pr13_7 =  temp.pr13_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr13_8) > 0 then temp.pr13_8 =  temp.pr13_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr13_8) > 0 then temp.pr13_8 =  temp.pr13_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr13_9) > 0 then temp.pr13_9 =  temp.pr13_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1310) > 0 then temp.pr13_10 =  temp.pr13_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1311) > 0 then temp.pr13_11 =  temp.pr13_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1312) > 0 then temp.pr13_12 =  temp.pr13_12 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1313) > 0 then temp.pr13_13 =  temp.pr13_13 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1314) > 0 then temp.pr13_14 =  temp.pr13_14 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1314) > 0 then temp.pr13_14 =  temp.pr13_14 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1314) > 0 then temp.pr13_14 =  temp.pr13_14 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1315) > 0 then temp.pr13_15 =  temp.pr13_15 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1316) > 0 then temp.pr13_16 =  temp.pr13_16 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      end. 

     end. /*else*/
    end. 
  end.

