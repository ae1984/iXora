/* put-sha.p
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

{put-sha.f}.

if index(raksts,"ђ•") = 0
then return.
if index(ident,"^") = 0 or index(ident,":") = 0
then return.
burts1 = "ђ•".
burts2 = "•©".
rinda  = raksts.
rinda1 = raksts.
raksts = substring(rinda1,1,index(rinda1,burts1) + length(burts1) - 1).
rinda1 = substring(rinda1,index(rinda1,burts1) + length(burts1)).
ident1 = substring(ident,index(ident,"^") + 1).
repeat:
   rez = "".
   kreisais = yes.
   r1 = substring(ident1,1,index(ident1,":") - 1).
   repeat:
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
           if length(trim(substring(rinda1,1,index(rinda1,burts2) - 1))) = 0
           then do:
                find first lonwrk where lonwrk.indekss = r3 and
                                   lonwrk.lon = r4 no-lock no-error.
                if available lonwrk
                then do:
                     p1 = trim(lonwrk.lcnt).
                     run value(r5) (p1,output p2).
                end.
                rez = rez + p2 + " ".
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
           if length(trim(substring(rinda1,1,index(rinda1,burts2) - 1))) = 0
           then do:
                find first lonwrk where lonwrk.indekss = r3 and
                                   lonwrk.lon = r4 no-lock no-error.
                if available lonwrk
                then rez = rez + trim(lonwrk.lcnt) + " ".
           end.
      end.
      if r1 = ""
      then leave.
   end.
   rez = trim(rez).
   if index(rinda1,burts2) = 0
   then do:
        message m1 ident m2 rinda.
        return.
   end.
   if length(trim(substring(rinda1,1,index(rinda1,burts2) - 1))) > 0
   then do:
        rez = substring(rinda1,1,index(rinda1,burts2) - 1).
        kreisais = no.
   end.
   if not kreisais
   then do:
        if index(rinda1,burts2) - 1 - length(rez) >= 0
        then r1 = substring(tuksums,1,index(rinda1,burts2) - 1 - length(rez))
                  + rez + burts2.
        else r1 = substring(rez,length(rez) - index(rinda1,burts2) +
                  length(burts2)) + burts2.
   end.
   else r1 = substring(rez + tuksums,1,index(rinda1,burts2) - 1) + burts2.
   raksts = raksts + r1.


   ident1 = substring(ident1,index(ident1,":") + 1).
   rinda1 = substring(rinda1,index(rinda1,burts2) + length(burts2)).
   if index(rinda1,"ђ") > 0
   then do:
        burts1 = "ђ•".
        burts2 = "•©".
   end.
   if index(rinda1,burts1) > 0
   then do:
        raksts = raksts + substring(rinda1,1,index(rinda1,burts1) +
                          length(burts1) - 1).
        rinda1 = substring(rinda1,index(rinda1,burts1) + length(burts1)).
   end.
   else do:
        raksts = raksts + rinda1.
        return.
   end.
   if length(trim(ident1)) = 0
   then return.
end.
