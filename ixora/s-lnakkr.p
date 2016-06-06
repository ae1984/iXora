/* s-lnakkr.p
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

{s-lnakkr.f}.

def var v-sum as decimal.

find lon where lon.lon = s-lon no-lock.
find last crchis where crchis.crc = lon.crc and crchis.rdt <= lon.rdt
          no-lock no-error.
if not available crchis
then find first crchis where crchis.crc = lon.crc and crchis.rdt > lon.rdt
          no-lock no-error.

readkey pause 0.
clear frame akkr all.
repeat with frame akkr:
   if lastkey <> keycode("CURSOR-UP") and lastkey <>
      keycode("CURSOR-DOWN")
   then do:
        find next lnakkred where lnakkred.lon = s-lon no-error.
        if not available lnakkred
        then do:
             find last lnakkred where lnakkred.lon = s-lon no-error.
             if not available lnakkred
             then do:
                  create lnakkred.
                  lnakkred.ln = m-ln + 1.
                  lnakkred.lon = s-lon.
                  lnakkred.uno = 1. 
                  lnakkred.regdt = g-today.
                  lnakkred.duedt = g-today.
                  lnakkred.amount = 0.
                  find last lnakkred where lnakkred.lon = s-lon.
                  display lnakkred.uno
                          lnakkred.regdt
                          lnakkred.duedt
                          lnakkred.crc
                          lnakkred.amount
                          with frame akkr.  
             end.
             {s-lnakkr.i}.
        end.
        else do:
             down with frame akkr.
             display lnakkred.uno
                     lnakkred.regdt
                     lnakkred.duedt
                     lnakkred.crc
                     lnakkred.amount
                     with frame akkr.  
        end.
        m-ln =lnakkred.ln.
   end.
   if lastkey = keycode("CURSOR-UP")
   then do:
        find prev lnakkred where lnakkred.lon = s-lon no-error.
        if not available lnakkred
        then find first lnakkred where lnakkred.lon = s-lon.
        else up with frame akkr.
        {s-lnakkr.i}.
        m-ln = lnakkred.ln.
   end.
   if lastkey = keycode("CURSOR-DOWN")
   then do:
        find next lnakkred where lnakkred.lon = s-lon no-error.
        if not available lnakkred
        then do:
             create lnakkred.
             lnakkred.ln = m-ln + 1.
             lnakkred.lon = s-lon.
             lnakkred.uno = 1. 
             lnakkred.regdt = g-today.
             lnakkred.duedt = g-today.
             lnakkred.amount = 0.
             find last lnakkred where lnakkred.lon = s-lon.
             down with frame akkr.
             display lnakkred.uno
                     lnakkred.regdt
                     lnakkred.duedt
                     lnakkred.crc
                     lnakkred.amount
                     with frame akkr.  
        end.
        else down with frame akkr.
        {s-lnakkr.i}.
        m-ln = lnakkred.ln.
   end.
/*   if lastkey = keycode("U8") or lastkey = keycode("F10")
   then do:
        readkey pause 0.
        dzest = no.
        bell.
        message "Удалить строку ?" update dzest.
        if dzest
        then delete lonsec1.
        clear frame akkr all.
        s1 = 0.
        s4 = 0.
        for each lonsec1 where lonsec1.lon = s-lon no-lock:
            {s-lonnd1a.i}.
            down with frame akkr.
        end.
        if frame-line(akkr) > 1
        then up with frame akkr.
   end.*/

   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
end.
for each lnakkred where lnakkred.lon = s-lon and lnakkred.amount = 0:
    delete lnakkred.
end.
hide frame akkr.
readkey pause 0.
