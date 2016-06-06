/* s-lonpg1.p
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

/*-----------------------------------
  #3.Pamatsummu izmai‡u koment–rs
-----------------------------------*/

{s-lonpg1.f}.
define variable i  as integer.
define variable r1 as character.

find lon where lon.lon = s-lon no-lock.
find loncon where loncon.lon = s-lon exclusive-lock.

for each ln%his where ln%his.lon = s-lon and ln%his.stdat < s-dt no-lock:
    if ln%his.stdat < date(1,1,1000)
    then next.
    create w-pg.
    w-pg.dt = ln%his.stdat.
    w-pg.rdt = ln%his.rdt.
    w-pg.duedt = ln%his.duedt.
    w-pg.opnamt = ln%his.opnamt.
    run atl-dat(s-lon,ln%his.stdat,output w-pg.atl).
    w-pg.prem = ln%his.intrate.
    w-pg.who = ln%his.who.
    w-pg.whn = ln%his.whn.
    i = index(loncon.rez-char[4],"/" + string(ln%his.stdat,"99/99/9999") + "&").
    if i > 0
    then do:
         r1 = substring(loncon.rez-char[4],1,i - 1).
         w-pg.nr = substring(r1,r-index(r1,"#") + 1).
    end.
    else w-pg.nr = "".
    i = index(loncon.rez-char[5],"/" + string(ln%his.stdat,"99/99/9999") + "&").
    if i > 0
    then do:
         r1 = substring(loncon.rez-char[5],1,i - 1).
         w-pg.iem = substring(r1,r-index(r1,"#") + 1).
    end.
    else w-pg.iem = "".
end.
readkey pause 0.
clear frame pg all.
find first w-pg.
repeat with frame pg:
   if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("CURSOR-DOWN")
   then do:
        display w-pg.nr
                w-pg.dt
                w-pg.duedt
                w-pg.atl
                w-pg.iem
        with frame pg.
        find next w-pg no-error.
        if not available w-pg
        then do:
             find last w-pg.
             {s-lonpg1.i}.
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
        {s-lonpg1.i}.
   end.
   if lastkey = keycode("CURSOR-DOWN")
   then do:
        find next w-pg no-error.
        if not available w-pg
        then do:
             find last w-pg.
        end.
        else down with frame pg.
        {s-lonpg1.i}.
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
         i = index(loncon.rez-char[4],"/" + string(w-pg.dt,"99/99/9999") + "&").
         if i > 0
         then do:
              r1 = substring(loncon.rez-char[4],1,i - 1).
              if trim(w-pg.nr) <> ""
              then loncon.rez-char[4] = substring(r1,1,r-index(r1,"#")) +
                     string(w-pg.nr,"xx") + substring(loncon.rez-char[4],i).
              else loncon.rez-char[4] = substring(r1,1,r-index(r1,"#") - 1) +
                     substring(loncon.rez-char[4],i + 12).
         end.
         else if trim(w-pg.nr) <> ""
         then loncon.rez-char[4] = loncon.rez-char[4] + "#" +
               string(w-pg.nr,"xx") + "/" + string(w-pg.dt,"99/99/9999") + "&".
         i = index(loncon.rez-char[5],"/" + string(w-pg.dt,"99/99/9999") + "&").
         if i > 0
         then do:
              r1 = substring(loncon.rez-char[5],1,i - 1).
              loncon.rez-char[5] = substring(r1,1,r-index(r1,"#")) + w-pg.iem +
                     substring(loncon.rez-char[5],i).
         end.
         else loncon.rez-char[5] = loncon.rez-char[5] + "#" + w-pg.iem + "/" +
                                   string(w-pg.dt,"99/99/9999") + "&".
     end.
end.
readkey pause 0.
hide frame pg.
hide frame br.
for each w-pg:
    delete w-pg.
end.
