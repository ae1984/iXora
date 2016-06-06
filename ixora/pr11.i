/* pr11.i
 * MODULE
        Данные приложения 11
 * DESCRIPTION
        Данные приложения 11
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

find sysc where sysc.sysc = 'pr11' no-lock no-error.
if avail sysc  then v-pr11 = sysc.chval.

find sysc where sysc.sysc = 'pr11_4' no-lock no-error.
if avail sysc  then v-pr11_4 = sysc.chval.

find sysc where sysc.sysc = 'pr11_5' no-lock no-error.
if avail sysc  then v-pr11_5 = sysc.chval.

find sysc where sysc.sysc = 'pr11_6' no-lock no-error.
if avail sysc  then v-pr11_6 = sysc.chval.

find sysc where sysc.sysc = 'pr11_7' no-lock no-error.
if avail sysc  then v-pr11_7 = sysc.chval.

find sysc where sysc.sysc = 'pr11_8' no-lock no-error.
if avail sysc  then v-pr11_8 = sysc.chval.

find sysc where sysc.sysc = 'pr11_9' no-lock no-error.
if avail sysc  then v-pr11_9 = sysc.chval.

find sysc where sysc.sysc = 'pr1110' no-lock no-error.
if avail sysc  then v-pr1110 = sysc.chval.

find sysc where sysc.sysc = 'pr1111' no-lock no-error.
if avail sysc  then v-pr1111 = sysc.chval.

find sysc where sysc.sysc = 'pr1112' no-lock no-error.
if avail sysc  then v-pr1112 = sysc.chval.

find sysc where sysc.sysc = 'pr1113' no-lock no-error.
if avail sysc  then v-pr1113 = sysc.chval.

find sysc where sysc.sysc = 'pr1114' no-lock no-error.
if avail sysc  then v-pr1114 = sysc.chval.

find sysc where sysc.sysc = 'pr1115' no-lock no-error.
if avail sysc  then v-pr1115 = sysc.chval.

find sysc where sysc.sysc = 'pr1116' no-lock no-error.
if avail sysc  then v-pr1116 = sysc.chval.

find sysc where sysc.sysc = 'pr1117' no-lock no-error.
if avail sysc  then v-pr1117 = sysc.chval.

find sysc where sysc.sysc = 'pr1118' no-lock no-error.
if avail sysc  then v-pr1118 = sysc.chval.

find sysc where sysc.sysc = 'pr1119' no-lock no-error.
if avail sysc  then v-pr1119 = sysc.chval.

find sysc where sysc.sysc = 'pr1120' no-lock no-error.
if avail sysc  then v-pr1120 = sysc.chval.

find sysc where sysc.sysc = 'pr1121' no-lock no-error.
if avail sysc  then v-pr1121 = sysc.chval.

find sysc where sysc.sysc = 'pr1122' no-lock no-error.
if avail sysc  then v-pr1122 = sysc.chval.

find sysc where sysc.sysc = 'pr1123' no-lock no-error.
if avail sysc  then v-pr1123 = sysc.chval.

find sysc where sysc.sysc = 'pr1124' no-lock no-error.
if avail sysc  then v-pr1124 = sysc.chval.

find sysc where sysc.sysc = 'pr1125' no-lock no-error.
if avail sysc  then v-pr1125 = sysc.chval.

find sysc where sysc.sysc = 'pr1126' no-lock no-error.
if avail sysc  then v-pr1126 = sysc.chval.

find sysc where sysc.sysc = 'pr1127' no-lock no-error.
if avail sysc  then v-pr1127 = sysc.chval.

  for each t-cods where  {&dep} and  lookup(substr(t-cods.code,1,3),v-pr11) > 0  
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
        if lookup(substr(t-cods.code,1,7),v-pr11_4) > 0 then temp.pr11_4 =  temp.pr11_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr11_5) > 0 then temp.pr11_5 =  temp.pr11_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr11_6) > 0 then temp.pr11_6 =  temp.pr11_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr11_7) > 0 then temp.pr11_7 =  temp.pr11_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr11_8) > 0 then temp.pr11_8 =  temp.pr11_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr11_9) > 0 then temp.pr11_9 =  temp.pr11_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1110) > 0 then temp.pr11_10 =  temp.pr11_10 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep. 
        if lookup(substr(t-cods.code,1,7),v-pr1111) > 0 then temp.pr11_11 = temp.pr11_11 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep. 
        if lookup(substr(t-cods.code,1,7),v-pr1112) > 0 then temp.pr11_12 = temp.pr11_12 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep. 
        if lookup(substr(t-cods.code,1,7),v-pr1113) > 0 then temp.pr11_13 =  temp.pr11_13 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1114) > 0 then temp.pr11_14 =  temp.pr11_14 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1115) > 0 then temp.pr11_15 =  temp.pr11_15 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1116) > 0 then temp.pr11_16 =  temp.pr11_16 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1117) > 0 then temp.pr11_17 =  temp.pr11_17 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1118) > 0 then temp.pr11_18 =  temp.pr11_18 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1119) > 0 then temp.pr11_19 =  temp.pr11_19 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1120) > 0 then temp.pr11_20 =  temp.pr11_20 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1121) > 0 then temp.pr11_21 =  temp.pr11_21 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1122) > 0 then temp.pr11_22 =  temp.pr11_22 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1123) > 0 then temp.pr11_23 =  temp.pr11_23 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1124) > 0 then temp.pr11_24 =  temp.pr11_24 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1125) > 0 then temp.pr11_25 =  temp.pr11_25 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1126) > 0 then temp.pr11_26 =  temp.pr11_26 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr1127) > 0 then temp.pr11_27 =  temp.pr11_27 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
      end. /*temp*/
     end. /*if avail*/
    else do:
   for each temp where temp.mon = month(t-cods.jdt)  and temp.tn <> "" .
         if lookup(substr(t-cods.code,1,7),v-pr11_4) > 0 then temp.pr11_4 =  temp.pr11_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr11_5) > 0 then temp.pr11_5 =  temp.pr11_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr11_6) > 0 then temp.pr11_6 =  temp.pr11_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr11_7) > 0 then temp.pr11_7 =  temp.pr11_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr11_8) > 0 then temp.pr11_8 =  temp.pr11_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr11_9) > 0 then temp.pr11_9 =  temp.pr11_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1110) > 0 then temp.pr11_10 =  temp.pr11_10 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn. 
         if lookup(substr(t-cods.code,1,7),v-pr1111) > 0 then temp.pr11_11 = temp.pr11_11 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn. 
         if lookup(substr(t-cods.code,1,7),v-pr1113) > 0 then temp.pr11_13 =  temp.pr11_13 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1114) > 0 then temp.pr11_14 =  temp.pr11_14 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1115) > 0 then temp.pr11_15 =  temp.pr11_15 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1116) > 0 then temp.pr11_16 =  temp.pr11_16 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1117) > 0 then temp.pr11_17 =  temp.pr11_17 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1118) > 0 then temp.pr11_18 =  temp.pr11_18 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1119) > 0 then temp.pr11_19 =  temp.pr11_19 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1120) > 0 then temp.pr11_20 =  temp.pr11_20 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1121) > 0 then temp.pr11_21 =  temp.pr11_21 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1122) > 0 then temp.pr11_22 =  temp.pr11_22 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1123) > 0 then temp.pr11_23 =  temp.pr11_23 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1124) > 0 then temp.pr11_24 =  temp.pr11_24 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1125) > 0 then temp.pr11_25 =  temp.pr11_25 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1126) > 0 then temp.pr11_26 =  temp.pr11_26 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr1127) > 0 then temp.pr11_27 =  temp.pr11_27 +  ((accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      end. 

     end. /*else*/
    end. 
  end.

