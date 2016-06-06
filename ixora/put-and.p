/* put-and.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{put-and.f}.
define shared stream s2.
if index(raksts,"&") = 0
then return.
if index(ident,"^") = 0 or index(ident,":") = 0
then do:
     message m1 ident m2 raksts.
     return.
end.
ident1 = substring(ident,index(ident,"^") + 1).
i = 0.
repeat:
   i = i + 1.
   rez = "".
   r1 = substring(ident1,1,index(ident1,":") - 1).
   ident1 = substring(ident1,index(ident1,":") + 1).
   repeat:
      kreisais = yes.
      if index(r1,"+") > 0
      then do:
           r2 = trim(substring(r1,1,index(r1,"+") - 1)).
           r1 = trim(substring(r1,index(r1,"+") + 1)).
      end.
      else do:
           r2 = trim(r1).
           r1 = "".
      end.
      if substring(r2,1,1) = "#"
      then do:
           r2 = substring(r2,2).
           kreisais = no.
      end.
      if index(r2,"(") > 0
      then do:
           if index(r2,")") = 0
           then do:
                message m1 ident m2 rinda.
                return.
           end.
           r5 = substring(r2,1,index(r2,"(") - 1).
           r3 = substring(r2,index(r2,"(") + 1).
           r3 = substring(r3,1,index(r3,")") - 1).
           if index(r3,".") = 0
           then do:
                message m1 ident m2 rinda.
                return.
           end.
           r4 = trim(substring(r3,index(r3,".") + 1)) + ":".
           r3 = trim(substring(r3,1,index(r3,".") - 1)).
           n = 0.
           for each lonwrk where lonwrk.indekss = r3 and
                                   lonwrk.lon = r4 no-lock:
                n = n + 1.
                p1 = trim(lonwrk.lcnt).
                run value(r5) (p1,output p2).
                if not kreisais
                then p2 = "#" + p2.
                find first wrk where wrk.nr = n no-error.
                if not available wrk
                then do:
                     create wrk.
                     wrk.nr = n.
                     do j = 1 to 16:
                        wrk.info[j] = "".
                     end.
                end.
                wrk.info[i] = wrk.info[i] + p2 + " ".
           end.
      end.
      else do:
           r3 = r2.
           if index(r3,".") = 0
           then do:
                message m1 ident m2 rinda.
                return.
           end.
           r4 = trim(substring(r3,index(r3,".") + 1)) + ":".
           r3 = trim(substring(r3,1,index(r3,".") - 1)).
           n = 0.
           for each lonwrk where lonwrk.indekss = r3 and
                                   lonwrk.lon = r4 no-lock:
                n = n + 1.
                p2 = trim(lonwrk.lcnt).
                if not kreisais
                then p2 = "#" + p2.
                find first wrk where wrk.nr = n no-error.
                if not available wrk
                then do:
                     create wrk.
                     wrk.nr = n.
                     do j = 1 to 16:
                        wrk.info[j] = "".
                     end.
                end.
                wrk.info[i] = wrk.info[i] + p2 + " ".
           end.
      end.
      if r1 = ""
      then leave.
   end.
   if length(trim(ident1)) = 0
   then leave.
end.
n = i.
k = 0.
for each wrk:
    k = k + 1.
    do i = 1 to n:
       wrk.info[i] = trim(wrk.info[i]).
    end.
end.
rinda = substring(raksts,index(raksts,"&") + 1).
l = 0.
for each wrk:
   l = l + 1.
   raksts = substring(raksts,1,index(raksts,"&")).
   rinda1 = rinda.
   do i = 1 to n:
      kreisais = yes.
      j = minimum(r-index(rinda1,"&"),index(rinda1,":")).
      if j = 0
      then j = r-index(rinda1,"&").
      if substring(wrk.info[i],1,1) = "#"
      then do:
           wrk.info[i] = substring(wrk.info[i],2).
           kreisais = no.
      end.
      if length(wrk.info[i]) > j - 1
      then do:
           if kreisais
           then p2 = substring(wrk.info[i],1,j - 1).
           else p2 = substring(wrk.info[i],length(wrk.info[i]) - j).
      end.
      else do:
           if kreisais
           then p2 = wrk.info[i] + fill(" ",j - length(wrk.info[i]) - 1).
           else do:
                p2 = wrk.info[i].
                if length(p2) < j - 1
                then p2 = p2 + "".
                p2 = fill(" ",j - length(p2) - 1) + p2.
           end.
      end.
      raksts = raksts + p2 + substring(rinda1,j,1).
      rinda1 = substring(rinda1,j + 1).
   end.
   raksts = raksts + rinda1.
   if l < k
   then export stream s2 raksts.
end.
