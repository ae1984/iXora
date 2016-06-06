/* pr20.i
 * MODULE
        Данные приложения 20
 * DESCRIPTION
        Данные приложения 20
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

find sysc where sysc.sysc = 'pr20' no-lock no-error.
if avail sysc  then v-pr20 = sysc.chval.

find sysc where sysc.sysc = 'pr20_4' no-lock no-error.
if avail sysc  then v-pr20_4 = sysc.chval.

find sysc where sysc.sysc = 'pr20_5' no-lock no-error.
if avail sysc  then v-pr20_5 = sysc.chval.

find sysc where sysc.sysc = 'pr20_6' no-lock no-error.
if avail sysc  then v-pr20_6 = sysc.chval.

find sysc where sysc.sysc = 'pr20_7' no-lock no-error.
if avail sysc  then v-pr20_7 = sysc.chval.

find sysc where sysc.sysc = 'pr20_8' no-lock no-error.
if avail sysc  then v-pr20_8 = sysc.chval.

find sysc where sysc.sysc = 'pr20_9' no-lock no-error.
if avail sysc  then v-pr20_9 = sysc.chval.

find sysc where sysc.sysc = 'pr2010' no-lock no-error.
if avail sysc  then v-pr2010 = sysc.chval.

find sysc where sysc.sysc = 'pr2011' no-lock no-error.
if avail sysc  then v-pr2011 = sysc.chval.


  for each t-cods where  {&dep} and  lookup(substr(t-cods.code,1,3),v-pr20) > 0  
      break by month(t-cods.jdt) by t-cods.dep by substr(t-cods.code,1,7). 
     accum t-cods.cam (total by substr(t-cods.code,1,7)).
     accum t-cods.dam (total by substr(t-cods.code,1,7)).

   if last-of(substr(t-cods.code,1,7)) then do:                            

    find first codfr where codfr = 'sproftcn' and trim(codfr.name[4]) = t-cods.dep  no-lock no-error.
   if avail codfr then do :
    find first temp1 where temp1.dep = trim(codfr.name[3]) no-lock no-error.
    if not avail temp1 then do:
     create temp1.
       assign 
        temp1.tn   = ""
        temp1.name = ""
        temp1.rnn  = ""
        temp1.dep  = codfr.name[3]
        temp1.depname = codfr.name[1]
        temp1.post   = ""
        temp1.tottndep = 1
        temp1.tottn = 0
        temp1.mon   = month(t-cods.jdt). 
      {add_temp.i &tmp = "temp"}. 
      end.       
   for each temp1 where temp1.mon = month(t-cods.jdt)  and temp1.dep = trim(codfr.name[3]).
      if temp1.tottndep = 0 then message 'Нулевое кол-во сотрудников деп-т' temp1.dep temp1.depname temp1.tottndep  temp1.mon substr(t-cods.code,1,7).
        if lookup(substr(t-cods.code,1,7),v-pr20_4) > 0 then temp1.pr20_4 =  temp1.pr20_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr20_5) > 0 then temp1.pr20_5 =  temp1.pr20_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr20_6) > 0 then temp1.pr20_6 =  temp1.pr20_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr20_7) > 0 then temp1.pr20_7 =  temp1.pr20_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr20_8) > 0 then temp1.pr20_8 =  temp1.pr20_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr20_9) > 0 then temp1.pr20_9 =  temp1.pr20_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr2010) > 0 then temp1.pr20_10 =  temp1.pr20_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr2011) > 0 then temp1.pr20_11 =  temp1.pr20_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottndep.

      end. /*temp*/
     end. /*if avail*/
    else do:
   for each temp1 where temp1.mon = month(t-cods.jdt)  and temp1.tn <> "" .
         if lookup(substr(t-cods.code,1,7),v-pr20_4) > 0 then temp1.pr20_4 =  temp1.pr20_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr20_5) > 0 then temp1.pr20_5 =  temp1.pr20_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr20_6) > 0 then temp1.pr20_6 =  temp1.pr20_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr20_7) > 0 then temp1.pr20_7 =  temp1.pr20_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr20_8) > 0 then temp1.pr20_8 =  temp1.pr20_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr20_8) > 0 then temp1.pr20_8 =  temp1.pr20_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr20_9) > 0 then temp1.pr20_9 =  temp1.pr20_9 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr2010) > 0 then temp1.pr20_10 =  temp1.pr20_10 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr2011) > 0 then temp1.pr20_11 =  temp1.pr20_11 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp1.tottn.
      end. 

     end. /*else*/
    end. 
  end.

