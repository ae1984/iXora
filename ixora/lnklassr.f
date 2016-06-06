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
        4-11-3 КлассРиск
 * AUTHOR
        20/08/2004 madiar - скопировал из lnklass.f с редакцией
 * CHANGES
*/


form
     kdklass.name format "x(29)" label "Код "
     t-klass.val1 format "x(5)" label "ДанныеКД"
     t-klass.info[1] format "x(5)" label "ДанныеРМ"
     t-klass.info[2] format "x(22)" label "Описание"
     t-klass.info[3] format "x(5)" label "Рейт"
     with row 5 centered scroll 1 down title " КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВА "
     frame lnklassr.


on help of t-klass.info[1] in frame lnklassr do: 
  run kd-krit (t-klass.kod, output v-cod).
  if v-cod <> "" then t-klass.info[1] = entry(1, v-cod).
  displ t-klass.info[1] with frame lnklassr. 
end.
