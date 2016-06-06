/* s-lonhr1.p
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

/*----------------------------------
  #3.KredЁt‡ёmёja bilances ievade
----------------------------------*/
{s-lonhr1.f}.
find lon where lon.lon = s-lon no-lock.
cifs = lon.cif.
m-dt = ?.
m-finrez = 999999999999.99.
m-akc = no.
for each lonhar where lonhar.cif = cifs and lonhar.lon = cifs no-lock:
    if m-dt = ? or m-dt < lonhar.fdt
    then do:
         m-finrez = lonhar.finrez.
         m-akc = lonhar.akc.
         m-dt = lonhar.fdt.
    end.
end.
find first lonhar where lonhar.cif <> cifs no-lock no-error.
readkey pause 0.
clear frame har all.
repeat with frame har:
   if lastkey <> keycode("CURSOR-UP") and lastkey <>
      keycode("CURSOR-DOWN")
   then do:
        find next lonhar where lonhar.lon = cifs no-error.
        if not available lonhar
        then do:
             find last lonhar where lonhar.lon = cifs
                  no-error.
             if not available lonhar
             then do:
                  create lonhar.
                  lonhar.ln = m-ln + 1.
                  lonhar.lon = cifs.
                  lonhar.fdt = s-dt.
                  lonhar.cif = cifs.
                  lonhar.finrez = 999999999999.99.
                  lonhar.akc = m-akc.
                  lonhar.who = userid("bank").
                  lonhar.whn = today.
                  find last lonhar where lonhar.lon = cifs.
             end.
             {s-lonhr1.i}.
        end.
        else do:
             down with frame har.
             display lonhar.fdt
                     lonhar.finrez
                     lonhar.akc
                     lonhar.who
                     lonhar.whn
                     with frame har.
        end.
        m-ln = lonhar.ln.
   end.
   if lastkey = keycode("CURSOR-UP")
   then do:
        find prev lonhar where lonhar.lon = cifs no-error.
        if not available lonhar
        then find first lonhar where lonhar.lon = cifs.
        else up with frame har.
        {s-lonhr1.i}.
        m-ln = lonhar.ln.
   end.
   if lastkey = keycode("CURSOR-DOWN")
   then do:
        find next lonhar where lonhar.lon = cifs no-error.
        if not available lonhar
        then do:
             find last lonhar where lonhar.lon = cifs no-error.
             if lonhar.fdt < s-dt
             then do:
                  create lonhar.
                  lonhar.ln = m-ln + 1.
                  lonhar.lon = cifs.
                  lonhar.fdt = s-dt.
                  lonhar.finrez = 999999999999.99.
                  lonhar.akc = m-akc.
                  lonhar.who = userid("bank").
                  lonhar.whn = today.
                  find last lonhar where lonhar.lon = cifs.
                  down with frame har.
             end.
             find last lonhar where lonhar.lon = cifs no-error.
        end.
        else down with frame har.
        {s-lonhr1.i}.
        m-ln = lonhar.ln.
   end.
   if lastkey = keycode("U8") or lastkey = keycode("F10")
   then do:
        readkey pause 0.
        bell.
        dzest = no.
        message "Удалить строку" lonhar.fdt lonhar.finrez lonhar.akc "?"
        update dzest.
        if dzest
        then delete lonhar.
        clear frame har all.
        for each lonhar where lonhar.lon = cifs no-lock:
            display lonhar.fdt
                    lonhar.finrez
                    lonhar.akc
                    lonhar.who
                    lonhar.whn
                    with frame har.
            down with frame har.
            pause 0.
        end.
        if frame-line(har) > 1
        then up with frame har.
   end.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
end.
for each lonhar where lonhar.lon = cifs and lonhar.fdt = ?:
    delete lonhar.
end.
hide frame har.
readkey pause 0.
