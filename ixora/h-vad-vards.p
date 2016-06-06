/* h-vad-vards.p
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

{h-vad-vards.f}.
do transaction:
   find loncon where loncon.lon = s-lon.
   readkey pause 0.
   clear frame pase all.
   display loncon.pase-nr
           loncon.rez-char[1]
           loncon.pase-izd
           loncon.pase-pier
           loncon.rez-char[2]
   with frame pase.
   update loncon.pase-nr
          loncon.rez-char[1]
          loncon.pase-izd
          loncon.pase-pier
          loncon.rez-char[2] go-on("PF4")
   with frame pase.
   hide frame pase.
end.
