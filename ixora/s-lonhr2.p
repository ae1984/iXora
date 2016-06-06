/* s-lonhr2.p
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
        01/07/2011 id00810 - для гарантий (2-1-9), временный вариант
*/

/*----------------------------------------
  #3.KredЁta statusa un uzkr–jumu ievade
     1.izmai‡a - uzkr–jumus vairs
                 neievad–m
----------------------------------------*/
{s-lonhr2.f}.
def var v-cif as char.
find lon where lon.lon = s-lon no-lock no-error.
if not avail lon then find garan where garan.garan = s-lon no-lock no-error.
if avail lon then v-cif = lon.cif. else v-cif = garan.cif.
readkey pause 0.
clear frame har all.
repeat with frame har:
   if lastkey <> keycode("CURSOR-UP") and lastkey <>
      keycode("CURSOR-DOWN")
   then do:
        find next lonhar  where lonhar.lon = s-lon no-error.
        if not available lonhar
        then do:
             find last lonhar  where lonhar.lon = s-lon no-error.
             if not available lonhar
             then do:
                  create lonhar.
                  lonhar.ln = m-ln + 1.
                  lonhar.lon = s-lon.
                  lonhar.fdt = g-today.
                  lonhar.cif = /*lon.cif*/ v-cif.
                  lonhar.who = userid("bank").
                  lonhar.whn = today.
                  find last lonhar  where lonhar.lon = s-lon.
             end.
             else do:
                  if lonhar.lonstat > 0
                  then do:
                       find lonstat where lonstat.lonstat = lonhar.lonstat
                            no-lock.
                       display lonstat.apz with frame har.
                  end.
             end.
             {s-lonhr2.i}.
        end.
        else do:
             down with frame har.
             if lonhar.lonstat > 0
             then do:
                  find lonstat where lonstat.lonstat = lonhar.lonstat no-lock.
                  display lonstat.apz with frame har.
             end.
             if lonhar.rez-log[1]
             then z = "*".
             else z = "".
             display lonhar.fdt
                     lonhar.lonstat
                     z
                     lonhar.who
                     lonhar.whn
                     with frame har.
        end.
        m-ln = lonhar.ln.
   end.
   if lastkey = keycode("CURSOR-UP")
   then do:
        find prev lonhar  where lonhar.lon = s-lon no-error.
        if not available lonhar
        then find first lonhar  where lonhar.lon = s-lon.
        else up with frame har.
        if lonhar.lonstat > 0
        then do:
             find lonstat where lonstat.lonstat = lonhar.lonstat no-lock.
             display lonstat.apz with frame har.
        end.
        {s-lonhr2.i}.
        m-ln = lonhar.ln.
   end.
   if lastkey = keycode("CURSOR-DOWN")
   then do:
        find next lonhar  where lonhar.lon = s-lon no-error.
        if not available lonhar
        then do:
             find last lonhar where lonhar.lon = s-lon.
             if lonhar.fdt < s-dt
             then do:
                  create lonhar.
                  lonhar.ln = m-ln + 1.
                  lonhar.lon = s-lon.
                  lonhar.fdt = s-dt.
                  lonhar.who = userid("bank").
                  lonhar.whn = today.
                  find last lonhar  where lonhar.lon = s-lon.
                  down with frame har.
             end.
             else if lonhar.lonstat > 0
             then do:
                  find lonstat where lonstat.lonstat = lonhar.lonstat no-lock.
                  display lonstat.apz with frame har.
             end.
        end.
        else do:
             down with frame har.
             if lonhar.lonstat > 0
             then do:
                  find lonstat where lonstat.lonstat = lonhar.lonstat no-lock.
                  display lonstat.apz with frame har.
             end.
        end.
        {s-lonhr2.i}.
        m-ln = lonhar.ln.
   end.
   if lastkey = keycode("U8") or lastkey = keycode("F10")
   then do:
        readkey pause 0.
        bell.
        dzest = no.
        if lonhar.rez-log[1]
        then do:
             message "После строки" lonhar.fdt lonhar.lonstat "введены"
                     "накопления - удалять нельзя".
             pause.
        end.
        else message "Удалить строку" lonhar.fdt lonhar.lonstat "?"
                     update dzest.
        if dzest
        then delete lonhar.
        clear frame har all.
        for each lonhar where lonhar.lon = s-lon no-lock:
            if lonhar.lonstat > 0
            then do:
                 find lonstat where lonstat.lonstat = lonhar.lonstat no-lock.
                 display lonstat.apz with frame har.
            end.
            display lonhar.fdt
                    lonhar.lonstat
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
for each lonhar where lonhar.lon = s-lon and lonhar.lonstat = 0:
    delete lonhar.
end.
hide frame har.
readkey pause 0.
