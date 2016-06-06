/* mnklasif.f
 * MODULE
        Кредитное досье мониторинг
 * DESCRIPTION
        Классификация кредита 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур ПО МОЕМУ ЗДЕСЬ ВЫЗЫВАЕТСЯ kd-krit
 * MENU
        4-11- Класифик
 * AUTHOR
        16.03.2005 marinav
 * CHANGES
*/



/*def var v-cod as char.*/

form
     kdklas.name format "x(30)" label "Код "
     kdlonklh.val1 format "x(5)" label " Данные "
     kdlonklh.valdesc format "x(25)" label "Описание"
     kdlonklh.rating format "->>9" label "Рейт"
     with row 5 centered scroll 1 down title " КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВА "
     frame kdklass.


on help of kdlonklh.val1 in frame kdklass do: 
  run kd-krit (kdlonklh.kod, output v-cod).
  if v-cod <> "" then kdlonklh.val1 = entry(1, v-cod).
  displ kdlonklh.val1 with frame kdklass. 
end.
