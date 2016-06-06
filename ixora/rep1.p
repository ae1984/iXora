/* rep1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчеты по депозитам физических лиц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.3.1.15.11
 * BASES
        BANK COMM
 * AUTHOR
        23/01/2006 dpuchkov
 * CHANGES
        05.04.2006 dpuchkov добавил отчет по новой звезде.
        11.04.2006 dpuchkov разделил отчет по новой звезде на 3 отчета.
*/



{global.i}
  def new shared var vn-dt as date .
  def var v-dep as integer.

  run sel2 (" Параметры поиска", " 1. Dallas | 2. Classic | 3. Звезда(Старая ) | 4. Звезда(Белая  )| 5. Звезда(Синяя  ) | 6. Звезда(Красная) | 7. Выход", output v-dep).
  if v-dep = 0 then return. 
  if v-dep = 7 then return. 

  update vn-dt label "Отчет на дату    " with side-labels centered row 9.
  display "Ждите идет формирование отчетов..."  with row 10 frame ww centered.

/*
  if v-dep = 1 then do:
     {r-branch.i &proc = "bigdepdallas"}
  end.
  if v-dep = 2 then do:
     {r-branch.i &proc = "bigdepclass"}
  end.
  if v-dep = 3 then do:
    {r-branch.i &proc = "bigdepstar"}
  end.
  if v-dep = 4 then do:
     {r-branch.i &proc = "bigdepstarwhite"}
  end.
  if v-dep = 5 then do:
     {r-branch.i &proc = "bigdepstarblue"}
  end.
  if v-dep = 6 then do:
     {r-branch.i &proc = "bigdepstarred"}
  end.

 */