/* c-lon20.p
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

{c-lon2.f}.
define variable dzest as logical.
{mainhead.i CLC2}.
readkey pause 0.
clear frame stat all.
repeat with frame stat:
   if lastkey <> keycode("CURSOR-UP") and lastkey <>
      keycode("CURSOR-DOWN")
   then do:
        find next lonstat  no-error.
        if not available lonstat
        then do:
             find last lonstat no-error.
             if not available lonstat
             then do:
                  create lonstat.
                  lonstat.ln = m-ln + 1.
                  find last lonstat .
             end.
             {c-lon2.i}.
        end.
        else do:
             down with frame stat.
             display lonstat.lonstat
                     lonstat.apz
                     lonstat.prc
                     lonstat.who
                     lonstat.whn
                     with frame stat.
        end.
        m-ln = lonstat.ln.
   end.
   if lastkey = keycode("CURSOR-UP")
   then do:
        find prev lonstat no-error.
        if not available lonstat
        then find first lonstat .
        else up with frame stat.
        {c-lon2.i}.
        m-ln = lonstat.ln.
   end.
   if lastkey = keycode("CURSOR-DOWN")
   then do:
        find next lonstat  no-error.
        if not available lonstat
        then do:
             create lonstat.
             lonstat.ln = m-ln + 1.
             find last lonstat.
        end.
        down with frame stat.
        {c-lon2.i}.
        m-ln = lonstat.ln.
   end.
   if lastkey = keycode("U8") or lastkey = keycode("F10")
   then do:
        readkey pause 0.
        dzest = no.
        message "Nodzёst rindi‡u" lonstat.lonstat lonstat.apz lonstat.prc
                "?" update dzest.
        if dzest
        then do:
             delete lonstat.
             clear frame stat all.
             for each lonstat  no-lock:
                 display lonstat.lonstat
                         lonstat.apz
                         lonstat.prc
                         lonstat.who
                         lonstat.whn
                         with frame stat.
                 down with frame stat.
                 pause 0.
             end.
             if frame-line(stat) > 1
             then up with frame stat.
        end.
   end.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
end.
find lonstat where lonstat.lonstat = 0 no-error.
if available lonstat
then delete lonstat.
hide frame stat.
