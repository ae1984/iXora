/* s-lonrdl.i
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

update {&jaunais} {&nosac} with frame lon.
if frame lon {&jaunais} entered
then do:
     if v-londam1 <> 0 or lon.gua = "OD"
     then do: 
          ja-ne = no.
          message m3 {&vecais} m4 {&jaunais} update ja-ne.
          if not ja-ne
          then do:
               bell.
               {&jaunais} = {&vecais}.
               display {&jaunais} with frame lon.
          end.
     end.   
end.
