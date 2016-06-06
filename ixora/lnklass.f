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


form
     kdklas.name format "x(50)" label "Код "
     t-klass.val1 format "x(5)" label " Данные "
     t-klass.valdesc format "x(40)" label "Описание"
     t-klass.rating format "->>9.99" label "Рейт"
     with row 4 centered scroll 1 down width 110 title " КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВА "
     frame lnklass.


on help of t-klass.val1 in frame lnklass do: 
  run kd-krit (t-klass.kod, output v-cod).
  if v-cod <> "" then t-klass.val1 = entry(1, v-cod).
  displ t-klass.val1 with frame lnklass. 
end.
