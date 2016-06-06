/* s-lonnda1.p
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

/*------------------------------
  #3.NodroЅin–juma p–rvёrtёЅana
------------------------------*/

{s-lonnda1.f}.
define variable i as integer.

find lon where lon.lon = s-lon no-lock.
find last crchis where crchis.crc = lon.crc and crchis.rdt <= s-dt
          no-lock no-error.
run atl-dat(s-lon,s-dt,output v-atl).
v-atl = crchis.rate[1] / crchis.rate[9] * v-atl.

s1 = 0.
for each lonsec1 where lonsec1.lon = s-lon and lonsec1.fdt <= s-dt and
    lonsec1.tdt >= s-dt no-lock:
    create w-sec.
    w-sec.lonsec = lonsec1.lonsec.
    w-sec.ln = lonsec1.ln.
    find last crchis where crchis.crc = lonsec1.crc and crchis.rdt <= lon.rdt
         no-lock no-error.
    kurss = crchis.rate[1] / crchis.rate[9].
    w-sec.secamt0 = lonsec1.secamt * kurss.
    find last crchis where crchis.crc = lonsec1.crc and crchis.rdt <= s-dt
         no-lock no-error.
    kurss = crchis.rate[1] / crchis.rate[9].
    w-sec.secamt = lonsec1.secamt * kurss.
    w-sec.secamt1 = w-sec.secamt.
    w-sec.kurss = kurss.
    s1 = s1 + w-sec.secamt.
    w-sec.des = lonsec1.prm.
    if index(w-sec.des,"&") > 0
    then w-sec.des = substring(w-sec.des,1,index(w-sec.des,"&") - 1).
    w-sec.chdt = ?.
    w-sec.who = lonsec1.who.
    w-sec.whn = lonsec1.whn.
end.
if s1 = 0
then do:
     bell.
     message "Кредит " s-lon "  без обеспечения !!!".
     pause.
     return.
end.
if v-atl = 0
then ja-ne = yes.
else if s1 / v-atl >= 1
then ja-ne = yes.
else ja-ne = no.
for each w-sec:
    w-sec.pietiek = ja-ne.
    w-sec.pietiek1 = ja-ne.
end.
find last sechis where sechis.lon = s-lon and sechis.chdt <= s-dt
     no-lock no-error.
if available sechis
then do:
     v-dt = sechis.chdt.
     run atl-dat(s-lon,v-dt,output v-atl).
     find last crchis where crchis.crc = lon.crc and crchis.rdt <= v-dt no-lock.
     v-atl = crchis.rate[1] / crchis.rate[9] * v-atl.
     for each sechis where sechis.lon = s-lon and sechis.chdt = v-dt no-lock:
         find first w-sec where w-sec.lonsec = sechis.lonsec and
              w-sec.ln = sechis.ln no-error.
         if available w-sec
         then do:
              find last crchis where crchis.crc = sechis.crc and
                   crchis.rdt <= sechis.chdt no-lock.
             w-sec.secamt = sechis.rez-dec[1] * crchis.rate[1] / crchis.rate[9].
              w-sec.secamt1 = w-sec.secamt.
              w-sec.pietiek = sechis.rez-int[1] = 1.
              w-sec.pietiek1 = w-sec.pietiek.
              w-sec.des = sechis.prm.
              if index(w-sec.des,"&") > 0
              then w-sec.des = substring(w-sec.des,1,index(w-sec.des,"&") - 1).
              w-sec.chdt = sechis.chdt.
              w-sec.who = sechis.who.
              w-sec.whn = sechis.whn.
         end.
     end.
end.
find first sechis where sechis.lon = s-lon and sechis.chdt > s-dt
     no-lock no-error.
ja-ne = not available sechis.
s1 = 0.
s4 = 0.
readkey pause 0.
clear frame sec1 all.
find first w-sec.
repeat with frame sec1:
   if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("CURSOR-DOWN")
   then do transaction:
        if lastkey <> keycode("RETURN")
        then do:
             s1 = s1 + w-sec.secamt.
             s4 = s4 + w-sec.secamt0.
        end.
        display w-sec.lonsec
                w-sec.des
                w-sec.secamt0
                w-sec.secamt
                w-sec.pietiek
        with frame sec1.
        find next w-sec no-error.
        if not available w-sec
        then do:
             find last w-sec.
             {s-lonnda1.i}.
        end.
        else do:
             down with frame sec1.
        end.
   end.
   if lastkey = keycode("CURSOR-UP")
   then do transaction:
        find prev w-sec no-error.
        if not available w-sec
        then find first w-sec.
        else up with frame sec1.
        {s-lonnda1.i}.
   end.
   if lastkey = keycode("CURSOR-DOWN")
   then do transaction:
        find next w-sec no-error.
        if not available w-sec
        then do:
             find last w-sec.
        end.
        else down with frame sec1.
        {s-lonnda1.i}.
   end.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4") or
      lastkey = keycode("U8") or lastkey = keycode("F10")
   then leave.
end.

/* if lastkey = keycode("PF4")
then do:
     hide frame sec1.
     hide frame br.
     readkey pause 0.
     for each w-sec:
         delete w-sec.
     end.
     return.
2end.
*/
if lastkey = keycode("U8") or lastkey = keycode("F10")
then do:
     ja-ne = no.
     find first w-sec.
     message "Удалить за " w-sec.chdt " информацию ?" update ja-ne.
     if ja-ne
     then do:
          for each sechis where sechis.lon = s-lon and sechis.chdt = w-sec.chdt:
              delete sechis.
          end.
     end.
     hide frame sec1.
     hide frame br.
     readkey pause 0.
     for each w-sec:
         delete w-sec.
     end.
     return.
end.
if lastkey = keycode("PF1") or lastkey = keycode("PF4")
then do:
     find first w-sec.
     ja-ne = no.
     if w-sec.chdt <> s-dt
     then do:
          for each w-sec:
              if w-sec.secamt <> w-sec.secamt1 or
                 w-sec.pietiek <> w-sec.pietiek1
              then do:
                   ja-ne = yes.
                   leave.
              end.
          end.
          if ja-ne
          then do:
               ja-ne = no.
               message "Ввести новую информацию с датой " s-dt " ?"
               update ja-ne.
          end.
          else ja-ne = no.
          if ja-ne
          then do:
               for each w-sec:
                   find lonsec1 where lonsec1.lon = s-lon and
                        lonsec1.lonsec = w-sec.lonsec and lonsec1.ln = w-sec.ln
                        no-lock.
                   create sechis.
                   sechis.lon = s-lon.
                   sechis.lonsec = w-sec.lonsec.
                   sechis.ln  = w-sec.ln.
                   sechis.chdt = s-dt.
                   sechis.secamt = lonsec1.secamt.
                   sechis.apdr = lonsec1.apdr.
                   sechis.crc = lonsec1.crc.
                   sechis.fdt = lonsec1.fdt.
                   sechis.tdt = lonsec1.tdt.
                   sechis.novert = lonsec1.novert.
                   sechis.proc = lonsec1.proc.
                   do i = 1 to 10:
                      if i <= 5
                      then sechis.rez-int[i] = lonsec1.rez-int[i].
                      sechis.rez-dec[i] = lonsec1.rez-dec[i].
                      sechis.rez-char[i] = sechis.rez-char[i].
                   end.
                   sechis.rez-dec[1] = w-sec.secamt / w-sec.kurss.
                   sechis.uno = lonsec1.uno.
                   sechis.vert = lonsec1.vert.
                   sechis.vieta = lonsec1.vieta.
                   sechis.whn = today.
                   sechis.who = userid("bank").
               end.
          end.
     end.
     if not ja-ne
     then do:
          find first w-sec.
          if w-sec.chdt <> ?
          then do:
               for each w-sec:
                   if w-sec.secamt <> w-sec.secamt1 or
                      w-sec.pietiek <> w-sec.pietiek1
                   then do:
                        ja-ne = yes.
                        leave.
                   end.
               end.
          end.
          if ja-ne
          then do:
               ja-ne = no.
               message "Изменить за" w-sec.chdt " информацию ?"
                       update ja-ne.
          end.
          if ja-ne
          then do:
               v-dt = w-sec.chdt.
               for each sechis where sechis.lon = s-lon and sechis.chdt = v-dt:
                   find first w-sec where w-sec.lonsec = sechis.lonsec and
                        w-sec.ln = sechis.ln.
                   if w-sec.secamt <> w-sec.secamt1 or
                      w-sec.pietiek <> w-sec.pietiek1
                   then do:
                        sechis.rez-dec[1] = w-sec.secamt / w-sec.kurss.
                        if w-sec.pietiek
                        then sechis.rez-int[1] = 1.
                        else sechis.rez-int[1] = 0.
                        sechis.whn = today.
                        sechis.who = userid("bank").
                   end.
               end.
          end.
     end.
end.
readkey pause 0.
hide frame sec1.
hide frame br.
for each w-sec:
    delete w-sec.
end.
