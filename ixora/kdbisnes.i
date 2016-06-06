/* kdbisnes.i
 * MODULE
        ЭКД - Электронное кредитное досье
 * DESCRIPTION
        анализ бизнеса заемщика
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4.11.2 Бизнес 
 * AUTHOR
        01.12.2003 marinav
 * CHANGES
        30/04/2004 madiar - Просмотр клиентов филиалов в ГБ
        14/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        01.03.05 marinav - пренесено из kdbisnes.p
    05/09/06   marinav - добавление индексов
*/




if s-kdcif = '' then return.

find {2} where {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail {2} then do:
  message skip " Клиент N" s-kdcif "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define var s-info as char.
define var s-tit as char format "x(50)".


define frame fr skip(1) space(30) s-tit no-label skip(1)
       s-info  no-label VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       {1}.whn      label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " АНАЛИЗ БИЗНЕСА " .

define var v-sel as char.

repeat:

  run sel2 ("Выбор :", 
           " 1. Описание отрасли | 2. Конкуренты | 3. Описание бизнеса заемщика | 4. Инфраструктура бизнеса |
 5. Поставщики | 6. Потребители | 7. Конкурентоспособность заемщика |
 8. Перспективы развития | 9. Выход ", output v-sel).
/*  v-sel = return-value.
  */
  find first {1} where  {1}.kdcif = s-kdcif and {3} and {1}.code = '11' and ({1}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if not avail {1} then do:
    if s-ourbank = {2}.bank then do:
        create {1}. 
        {1}.bank = s-ourbank. {1}.code = '11'. {3}. 
        {1}.kdcif = s-kdcif. {1}.who = g-ofc. {1}.whn = g-today.
        find current {1} no-lock.
    end.
    else do:
      if v-sel <> "9" then message skip "Запрошенные данные не были введены" skip(1) view-as alert-box buttons ok title " Нет данных ! ".
      return.
    end.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.

  case v-sel:
    when "1" then do:
          s-tit = 'Описание отрасли'.
          s-info = {1}.info[1].
          displ s-tit s-info {1}.whn  {1}.who with frame fr.
          if s-ourbank = {1}.bank then do:
            update s-info with frame fr.
            find current {1} exclusive-lock.
            {1}.info[1] = s-info.
            find current {1} no-lock.
          end.
    end.
    when "2" then do:
          s-tit = 'Конкуренты'.
          s-info = {1}.info[2].
          displ s-tit s-info {1}.whn  {1}.who with frame fr.
          if s-ourbank = {1}.bank then do:
            update s-info with frame fr. 
            find current {1} exclusive-lock.
            {1}.info[2] = s-info.
            find current {1} no-lock.
          end.
    end.
    when "3" then do:
          s-tit = 'Описание бизнеса заемщика'. 
          s-info = {1}.info[3].
          displ s-tit s-info {1}.whn  {1}.who with frame fr.
          if s-ourbank = {1}.bank then do:
            update s-info with frame fr. 
            find current {1} exclusive-lock.
            {1}.info[3] = s-info.
            find current {1} no-lock.
          end.
    end.
    when "4" then do:
          s-tit = 'Инфраструктура бизнеса'.
          s-info = {1}.info[4].
          displ s-tit s-info {1}.whn  {1}.who with frame fr.
          if s-ourbank = {1}.bank then do:
            update s-info with frame fr. 
            find current {1} exclusive-lock.
            {1}.info[4] = s-info.
            find current {1} no-lock.
          end.
    end.
    when "5" then do:
          s-tit = 'Поставщики'.
          s-info = {1}.info[5].
          displ s-tit s-info {1}.whn  {1}.who with frame fr.
          if s-ourbank = {1}.bank then do:
            update s-info with frame fr. 
            find current {1} exclusive-lock.
            {1}.info[5] = s-info.
            find current {1} no-lock.
          end.
    end.
    when "6" then do:
          s-tit = 'Потребители'.
          s-info = {1}.info[6].
          displ s-tit s-info {1}.whn  {1}.who with frame fr.
          if s-ourbank = {1}.bank then do:
            update s-info with frame fr. 
            find current {1} exclusive-lock.
            {1}.info[6] = s-info.
            find current {1} no-lock.
          end.
    end.
    when "7" then do:
          s-tit = 'Конкурентоспособность заемщика'.
          s-info = {1}.info[8].
          displ s-tit s-info {1}.whn  {1}.who with frame fr.
          if s-ourbank = {1}.bank then do:
            update s-info with frame fr. 
            find current {1} exclusive-lock.
            {1}.info[8] = s-info.
            find current {1} no-lock.
          end.
    end.
    when "8" then do:
          s-tit = 'Перспективы развития'.
          s-info = {1}.info[9].
          displ s-tit s-info {1}.whn  {1}.who with frame fr.
          if s-ourbank = {1}.bank then do:
            update s-info with frame fr. 
            find current {1} exclusive-lock.
            {1}.info[9] = s-info.
            find current {1} no-lock.
          end.
    end.
    when "9" then do: release {1}. leave. end.
  end case.

end.


