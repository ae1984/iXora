/* pr5.i
 * MODULE
        Данные приложения 5
 * DESCRIPTION
        Данные приложения 5
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

find sysc where sysc.sysc = 'pr5' no-lock no-error.
if avail sysc  then v-pr5 = sysc.chval.

find sysc where sysc.sysc = 'pr5_9' no-lock no-error.
if avail sysc  then v-pr5_9 = sysc.chval.

find sysc where sysc.sysc = 'pr5_10' no-lock no-error.
if avail sysc  then v-pr5_10 = sysc.chval.

find sysc where sysc.sysc = 'pr5_11' no-lock no-error.
if avail sysc  then v-pr5_11 = sysc.chval.

find sysc where sysc.sysc = 'pr5_13' no-lock no-error.
if avail sysc  then v-pr5_13 = sysc.chval.

find sysc where sysc.sysc = 'pr5_14' no-lock no-error.
if avail sysc  then v-pr5_14 = sysc.chval.

find sysc where sysc.sysc = 'pr5_15' no-lock no-error.
if avail sysc  then v-pr5_15 = sysc.chval.

find sysc where sysc.sysc = 'pr5_16' no-lock no-error.
if avail sysc  then v-pr5_16 = sysc.chval.

find sysc where sysc.sysc = 'pr5_17' no-lock no-error.
if avail sysc  then v-pr5_17 = sysc.chval.

find sysc where sysc.sysc = 'pr5_18' no-lock no-error.
if avail sysc  then v-pr5_18 = sysc.chval.

find sysc where sysc.sysc = 'pr5_19' no-lock no-error.
if avail sysc  then v-pr5_19 = sysc.chval.

find sysc where sysc.sysc = 'pr5_20' no-lock no-error.
if avail sysc  then v-pr5_20 = sysc.chval.

find sysc where sysc.sysc = 'pr5_21' no-lock no-error.
if avail sysc  then v-pr5_21 = sysc.chval.

find sysc where sysc.sysc = 'pr5_22' no-lock no-error.
if avail sysc  then v-pr5_22 = sysc.chval.


  for each t-cods where {&dep} and  lookup(substr(t-cods.code,1,5),v-pr5) > 0  
    break by month(t-cods.jdt) by t-cods.dep by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).

   if last-of(substr(t-cods.code,1,7)) then do:                            

    find first codfr where codfr = 'sproftcn' and trim(codfr.name[4]) = t-cods.dep /*and  trim(codfr.name[3]) <> ""*/ no-lock no-error.
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
        if lookup(substr(t-cods.code,1,7),v-pr5_9) > 0 then temp.pr5_9 =  temp.pr5_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_10) > 0 then temp.pr5_10 =  temp.pr5_10 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep. 
        if lookup(substr(t-cods.code,1,7),v-pr5_11) > 0 then temp.pr5_11 = temp.pr5_11 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep. 
        if lookup(substr(t-cods.code,1,7),v-pr5_13) > 0 then temp.pr5_13 =  temp.pr5_13 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_14) > 0 then temp.pr5_14 =  temp.pr5_14 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_15) > 0 then temp.pr5_15 =  temp.pr5_15 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_16) > 0 then temp.pr5_16 =  temp.pr5_16 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_17) > 0 then temp.pr5_17 =  temp.pr5_17 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_18) > 0 then temp.pr5_18 =  temp.pr5_18 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_19) > 0 then temp.pr5_19 =  temp.pr5_19 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_20) > 0 then temp.pr5_20 =  temp.pr5_20 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_21) > 0 then temp.pr5_21 =  temp.pr5_21 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr5_22) > 0 then temp.pr5_22 =  temp.pr5_22 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
      end. /*temp*/
     end. /*if avail*/
    else do:
   for each temp where temp.mon = month(t-cods.jdt)  and temp.tn <> "" .
     if lookup(substr(t-cods.code,1,7),v-pr5_9) > 0 then temp.pr5_9 =  temp.pr5_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_10) > 0 then temp.pr5_10 =  temp.pr5_10 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn. 
         if lookup(substr(t-cods.code,1,7),v-pr5_11) > 0 then temp.pr5_11 = temp.pr5_11 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn. 
         if lookup(substr(t-cods.code,1,7),v-pr5_13) > 0 then temp.pr5_13 =  temp.pr5_13 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_14) > 0 then temp.pr5_14 =  temp.pr5_14 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_15) > 0 then temp.pr5_15 =  temp.pr5_15 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_16) > 0 then temp.pr5_16 =  temp.pr5_16 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_17) > 0 then temp.pr5_17 =  temp.pr5_17 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_18) > 0 then temp.pr5_18 =  temp.pr5_18 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_19) > 0 then temp.pr5_19 =  temp.pr5_19 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_20) > 0 then temp.pr5_20 =  temp.pr5_20 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_21) > 0 then temp.pr5_21 =  temp.pr5_21 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr5_22) > 0 then temp.pr5_22 =  temp.pr5_22 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      end. 

     end. /*else*/
    end. 
  end.
