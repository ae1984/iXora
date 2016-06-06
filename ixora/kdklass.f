/* kdklasif.f
 * MODULE
        Кредитное досье
 * DESCRIPTION
        Классификация кредита на момент выдачи
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3 Класифик
 * AUTHOR
        22.12.2003 marinav
 * CHANGES
*/



/*def var v-cod as char.*/

form
     kdklas.name format "x(30)" label "Код "
     kdlonkl.val1 format "x(5)" label " Данные "
     kdlonkl.valdesc format "x(25)" label "Описание"
     kdlonkl.rating format "->>9" label "Рейт"
     with row 5 centered scroll 1 down title " КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВА "
     frame kdklass.


on help of kdlonkl.val1 in frame kdklass do: 
  run kd-krit (kdlonkl.kod, output v-cod).
  if v-cod <> "" then kdlonkl.val1 = entry(1, v-cod).
  displ kdlonkl.val1 with frame kdklass. 
end.
