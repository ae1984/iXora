/* amr_tun.p
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

/*

*/

find sysc where sysc.sysc = 'amr2' no-error.

if avail sysc then
   do:
      update "Карточки исключения: " sysc.chval VIEW-AS EDITOR SIZE 78 by 10 SCROLLBAR-VERTICAL
 no-label.
   end. 
else
  do:
     message "В настречном файле нет параметра amr2" view-as alert-box.
  end.
