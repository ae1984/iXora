/* s-lonpg2.p
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

/*----------------------------------------
  #3.Procentu izmai‡u koment–rs
----------------------------------------*/


{s-lonpg2.f}.
define variable i  as integer.
define variable j  as integer.
define variable k  as integer.
define variable v-dt as date.
define variable r  as character.
define variable r1 as character.

find lon where lon.lon = s-lon no-lock.
find loncon where loncon.lon = s-lon exclusive-lock.
r = loncon.rez-char[6].
repeat while index(r,"&") > 0:
   j = index(r,"&") - 12.
   r1 = substring(r,j + 2,2).
   i = integer(r1).
   r1 = substring(r,j + 8,4).
   k = integer(r1).
   r1 = substring(r,j + 5,2).
   v-dt = date(integer(r1),i,k).
   if v-dt >= s-dt
   then do:
        r = substring(r,j + 13).
        next.
   end.
   create w-pg.
   w-pg.dt = v-dt.
   i = index(r,"#") + 1.
   r1 = substring(r,i,12).
   w-pg.amt = decimal(r1).
   i = i + 12.
   r1 = substring(r,i,4).
   w-pg.dn = integer(r1).
   i = i + 4.
   r1 = substring(r,i,6).
   w-pg.prc = decimal(r1).
   i = i + 6.
   r1 = substring(r,i,8).
   w-pg.who = r1.
   i = i + 8.
   r1 = substring(r,i,10).
   w-pg.whn = r1.
   i = i + 10.
   w-pg.iem = substring(r,i,j - i + 1).
   r = substring(r,j + 13).
end.
readkey pause 0.
clear frame pg all.
find first w-pg no-error.
if not available w-pg
then do:
     create w-pg.
     w-pg.dt = ?.
     w-pg.amt = 0.
     w-pg.dn = 0.
     w-pg.prc = 0.
     w-pg.iem = "".
end.
repeat with frame pg:
   if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("CURSOR-DOWN")
   then do:
        display w-pg.dt
                w-pg.amt
                w-pg.dn
                w-pg.prc
                w-pg.iem
        with frame pg.
        find next w-pg no-error.
        if not available w-pg
        then do:
             find last w-pg.
             {s-lonpg2.i}.
        end.
        else do:
             down with frame pg.
        end.
        pause 0.
   end.
   if lastkey = keycode("CURSOR-UP")
   then do:
        find prev w-pg no-error.
        if not available w-pg
        then find first w-pg.
        else up with frame pg.
        {s-lonpg2.i}.
   end.
   if lastkey = keycode("CURSOR-DOWN")
   then do:
        find next w-pg no-error.
        if not available w-pg
        then do:
             find last w-pg.
             if w-pg.dt <> ?
             then do:
                  create w-pg.
                  w-pg.dt = ?.
                  w-pg.amt = 0.
                  w-pg.dn = 0.
                  w-pg.prc = 0.
                  w-pg.iem = "".
                  down with frame pg.
             end.
        end.
        else down with frame pg.
        {s-lonpg2.i}.
   end.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
end.

/* if lastkey = keycode("PF4")
then do:
     hide frame pg.
     hide frame br.
     readkey pause 0.
     for each w-pg:
         delete w-pg.
     end.
     return.
end.
*/
if lastkey = keycode("PF1") or lastkey = keycode("PF4")
then do:
     for each w-pg:
         if w-pg.dt = ?
         then next.
         i = index(loncon.rez-char[6],"/" + string(w-pg.dt,"99/99/9999") + "&").
         if i > 0
         then do:
              r1 = substring(loncon.rez-char[6],1,i - 1).
              if w-pg.amt <> 0 or w-pg.dn <> 0 or w-pg.prc <> 0
              then loncon.rez-char[6] = substring(r1,1,r-index(r1,"#")) +
                     string(w-pg.amt,"999999999.99") + string(w-pg.dn,"9999") +
                     string(w-pg.prc,"999.99") + string(w-pg.who,"x(8)") +
                     w-pg.whn + w-pg.iem + substring(loncon.rez-char[6],i).
              else loncon.rez-char[6] = substring(r1,1,r-index(r1,"#") - 1) +
                     substring(loncon.rez-char[6],i + 12).
         end.
         else if w-pg.amt <> 0 or w-pg.dn <> 0 or w-pg.prc <> 0
         then loncon.rez-char[6] = loncon.rez-char[6] + "#" +
               string(w-pg.amt,"999999999.99") + string(w-pg.dn,"9999") +
               string(w-pg.prc,"999.99") + string(w-pg.who,"x(8)") + w-pg.whn +
               w-pg.iem + "/" + string(w-pg.dt,"99/99/9999") + "&".
     end.
end.
readkey pause 0.
hide frame pg.
hide frame br.
for each w-pg:
    delete w-pg.
end.
