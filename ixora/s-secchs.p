/* s-secchs.p
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

/*-----------------------------------------------------------------------------
  #3.
     1.izmai‡a - izmainЁts ±Ёlu skaits no 5 uz 25
-----------------------------------------------------------------------------*/
{s-secchs.f}.
define variable r as character extent 2.
define variable k as integer.
find first lonsec1 where lonsec1.lon = s-lon use-index ln no-lock no-error.
if not available lonsec1
then do:
     message m1.
     pause.
     undo,return.
end.
{rin-mas.i &lks = "lonsec1.prm" &r = "r" &i = "k" &n = "1"}.
r1 = r[1].
{rin-mas.i &lks = "lonsec1.vieta" &r = "r" &i = "k" &n = "1"}.
r2 = r[1].
i = 1.
readkey pause 0.
repeat:
   atzime = "".
   do j = 1 to i - 1:
      if m-ln[j] = lonsec1.ln
      then do:
           {rin-mas.i &lks = "lonsec1.prm" &r = "r" &i = "k" &n = "1"}.
           r1 = r[1].
           {rin-mas.i &lks = "lonsec1.vieta" &r = "r" &i = "k" &n = "1"}.
           r2 = r[1].
           atzime = "********".
           leave.
      end.
   end.
   display r1
           r2
           lonsec1.novert
           lonsec1.proc
           lonsec1.secamt
           lonsec1.apdr
   with frame ln.
   choose row r1
          go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN") with frame ln.
   pause 0.
   if lastkey <> keycode("RETURN")
   then color display normal r1 with frame ln.
   if lastkey = keycode("CURSOR-UP")
   then do:
        find prev lonsec1 where lonsec1.lon = s-lon use-index ln
                  no-lock no-error.
        if not available lonsec1
        then find first lonsec1 where lonsec1.lon = s-lon use-index ln
                        no-lock.
        {rin-mas.i &lks = "lonsec1.prm" &r = "r" &i = "k" &n = "1"}.
        r1 = r[1].
        {rin-mas.i &lks = "lonsec1.vieta" &r = "r" &i = "k" &n = "1"}.
        r2 = r[1].
        atzime = "".
        do j = 1 to i - 1:
           if m-ln[j] = lonsec1.ln
           then do:
                atzime = "********".
                leave.
           end.
        end.
        display r1 r2 atzime with frame ln.
   end.
   if lastkey = keycode("CURSOR-DOWN")
   then do:
        find next lonsec1 where lonsec1.lon = s-lon use-index ln
                  no-lock no-error.
        if not available lonsec1
        then find last lonsec1 where lonsec1.lon = s-lon use-index ln no-lock.
        {rin-mas.i &lks = "lonsec1.prm" &r = "r" &i = "k" &n = "1"}.
        r1 = r[1].
        {rin-mas.i &lks = "lonsec1.vieta" &r = "r" &i = "k" &n = "1"}.
        r2 = r[1].
        atzime = "".
        do j = 1 to i - 1:
           if m-ln[j] = lonsec1.ln
           then do:
                atzime = "********".
                leave.
           end.
        end.
        display r1 r2 atzime with frame ln.
   end.
   if lastkey = keycode("RETURN")
   then do:
        atzime = "********".
        do j = 1 to i:
           if m-ln[j] = lonsec1.ln
           then do:
                m-ln[j] = 0.
                atzime = "".
           end.
           if m-ln[j] = 0
           then if j < 25
                then do:
                     m-ln[j] = m-ln[j + 1].
                     m-ln[j + 1] = 0.
                end.
        end.
        if atzime = "********"
        then do:
             m-ln[i] = lonsec1.ln.
             i = i + 1.
             if i > 25
             then i = 25.
        end.
        display r1 r2 atzime with frame ln.
   end.
   if lastkey = keycode("PF1")
   then leave.
end.
pause 0.
hide frame ln.
