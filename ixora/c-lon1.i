/* c-lon1.i
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

repeat on endkey undo,retry:
   display lonsec.apz
           lonsec.lonsec
           lonsec.des
           lonsec.des1
           lonsec.risk
           with frame sec.
   do:
      readkey pause 0.
      {c-lon.i &vecais = "v-apz"    &jaunais = "lonsec.apz" &frame = "sec"
             &no-ctr = "' '"}.
      {c-lon.i &vecais = "v-lonsec" &jaunais = "lonsec.lonsec"
             &frame = "sec" &no-ctr = "0"}.
      {c-lon.i &vecais = "v-des"    &jaunais = "lonsec.des" &frame = "sec"
             &no-ctr = "' '"}.
      {c-lon.i &vecais = "v-des1"   &jaunais = "lonsec.des1" &frame = "sec"
             &no-ctr = "' '"}.
      {c-lon.i &vecais = "v-risk"   &jaunais = "lonsec.risk" &frame = "sec"
             &no-ctr = "0"}.
   end.
   if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("U8") and
      lastkey <> keycode("F10") and lastkey <> keycode("PF4") and
      lastkey <> keycode("PF1")
   then if lonsec.risk < 0 or lonsec.risk > 100 or lonsec.lonsec = 0
        then undo,retry.
   if lonsec.apz = " " and lonsec.lonsec <> 0
   then undo,retry.
   if frame sec lonsec.lonsec entered
      or frame sec lonsec.apz   entered
      or frame sec lonsec.des    entered
      or frame sec lonsec.des1   entered
      or frame sec lonsec.risk   entered
   then do:
        lonsec.who = userid("bank").
        lonsec.whn = g-today.
        if lonsec.lonsec <> v-lonsec and v-lonsec <> 0
        then do:
             for each lonsec1 where lonsec1.lonsec = v-lonsec:
                 lonsec1.lonsec = lonsec.lonsec.
             end.
        end.
   end.
   leave.
end.
