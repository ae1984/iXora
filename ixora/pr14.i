/* pr14.i
 * MODULE
        Данные приложения 14
 * DESCRIPTION
        Данные приложения 14
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

find sysc where sysc.sysc = 'pr14' no-lock no-error.
if avail sysc  then v-pr14 = sysc.chval.

find sysc where sysc.sysc = 'pr14_4' no-lock no-error.
if avail sysc  then v-pr14_4 = sysc.chval.

find sysc where sysc.sysc = 'pr14_5' no-lock no-error.
if avail sysc  then v-pr14_5 = sysc.chval.

find sysc where sysc.sysc = 'pr14_6' no-lock no-error.
if avail sysc  then v-pr14_6 = sysc.chval.

find sysc where sysc.sysc = 'pr14_7' no-lock no-error.
if avail sysc  then v-pr14_7 = sysc.chval.

find sysc where sysc.sysc = 'pr14_8' no-lock no-error.
if avail sysc  then v-pr14_8 = sysc.chval.

  for each t-cods where  {&dep} and  lookup(substr(t-cods.code,1,3),v-pr14) > 0  
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
        if lookup(substr(t-cods.code,1,7),v-pr14_4) > 0 then temp.pr14_4 =  temp.pr14_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr14_5) > 0 then temp.pr14_5 =  temp.pr14_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr14_6) > 0 then temp.pr14_6 =  temp.pr14_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr14_7) > 0 then temp.pr14_7 =  temp.pr14_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
        if lookup(substr(t-cods.code,1,7),v-pr14_8) > 0 then temp.pr14_8 =  temp.pr14_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottndep.
      end. /*temp*/
     end. /*if avail*/
    else do:
   for each temp where temp.mon = month(t-cods.jdt)  and temp.tn <> "" .
         if lookup(substr(t-cods.code,1,7),v-pr14_4) > 0 then temp.pr14_4 =  temp.pr14_4 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr14_5) > 0 then temp.pr14_5 =  temp.pr14_5 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr14_6) > 0 then temp.pr14_6 =  temp.pr14_6 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr14_7) > 0 then temp.pr14_7 =  temp.pr14_7 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
         if lookup(substr(t-cods.code,1,7),v-pr14_8) > 0 then temp.pr14_8 =  temp.pr14_8 + ( (accum total by substr(t-cods.code,1,7) t-cods.dam) - (accum total by substr(t-cods.code,1,7) t-cods.cam))  / temp.tottn.
      end. 

     end. /*else*/
    end. 
  end.

