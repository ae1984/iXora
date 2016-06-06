/* c-lon2.i
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

repeat:
   display lonstat.lonstat
           lonstat.apz
           lonstat.prc 
           lonstat.who
           lonstat.whn
           with frame stat.
   v-lonstat = lonstat.lonstat.
   v-apz = lonstat.apz.
   v-prc = lonstat.prc.
   readkey pause 0.
   do:
      {c-lon.i &vecais = "v-lonstat" &jaunais = "lonstat.lonstat"
       &frame = "stat" &no-ctr = "0"}.
      {c-lon.i &vecais = "v-apz" &jaunais = "lonstat.apz"
       &frame = "stat" &no-ctr = "' '"}.
      {c-lon.i &vecais = "v-prc" &jaunais = "lonstat.prc"
       &frame = "stat" &no-ctr = "0"}.
   end.
   if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("U8") and
      lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and
      lastkey <> keycode("F10")
   then if lonstat.lonstat <= 0
        then undo,next.
   if frame stat lonstat.lonstat   entered
      or frame stat lonstat.apz    entered
      or frame stat lonstat.prc    entered
   then do:
        lonstat.who = userid("bank").
        lonstat.whn = g-today.
        if v-lonstat <> lonstat.lonstat and v-lonstat <> 0
        then do:
             for each lonhar where lonhar.lonstat = v-lonstat:
                 lonhar.lonstat = lonstat.lonstat.
             end.
        end.
   end.
   leave.
end.
