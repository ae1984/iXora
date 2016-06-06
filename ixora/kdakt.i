/* kdakt.i
 * MODULE
        ЭКД
        ЭКД - Электронное кредитное досье
 * DESCRIPTION
        Внесение баланса по активу
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
        01.03.2005 marinav
 * CHANGES
      30.09.2005 marinav - изменения для бизнес-кредитов
    05/09/06   marinav - добавление индексов
*/


if s-kdcif = '' then return.

find {2} where  {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail {2} then do:
  message skip " Досье N" s-kdcif "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


define var v-sel as char.
define var v-sel1 as char.

  run uni_book ("kdbk", "*", output v-sel).
  v-sel = entry(1, v-sel).

  run sel ("Выбор :", 
           " 1. Создать новый | 2. Редактировать существующий | 3. Комментарии к балансу | 4. Выход").
  v-sel1 = return-value.

  case v-sel1:     
    when "1" then
      if s-ourbank <> {2}.bank then return.
      else run s-lnrska (v-sel1, v-sel).
    when "2" then
      if s-ourbank <> {2}.bank then return.
      else run s-lnrska (v-sel1, v-sel).
    when "3" then    run balcomm.
    when "4" then return.
  end case.
return.

procedure balcomm.

   define var v-dat as date.
   define var stitle as char.
   define var v-whn as date.
   define var v-who as char.
   define var v-info as char.
   
   define frame kdbalcomm skip(1)
       v-info  label "Комментарии   " VIEW-AS EDITOR SIZE 60 by 7 skip(1)
       v-whn   label "Проведено " v-who format "X(10)" no-label
       with overlay width 80 side-labels column 3 row 3          
       title " КОММЕНТАРИИ К БАЛАНСУ " .
   form stitle format 'x(40)' at 5 skip (1)
    "Дата" at 10 v-dat skip  
    with centered row 0 no-label frame f-cif1.

   v-dat = g-today.
   stitle = 'Комментарии к балансу на дату :'.
    display stitle with frame f-cif1.
    update v-dat with frame f-cif1.
    find first {1} where  {1}.kdcif = s-kdcif and {3} and {1}.code = '17' and {1}.dat = v-dat and 
                          ({1}.bank = s-ourbank or s-ourbank = "TXB00")  no-lock no-error.

    if not avail {1} then do:
      if s-ourbank <> {2}.bank then do:
        message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
        return.
      end.
      else do:
        create {1}.
        assign {1}.bank = s-ourbank
               {1}.code = '17'
               {1}.kdcif = s-kdcif
               {1}.dat = v-dat
               {1}.who = g-ofc
               {1}.whn = g-today.
               {3}.
        find current {1} no-lock. 
      end.
    end.
    v-info = {1}.info[1]. v-whn = {1}.whn. v-who = {1}.who.
    if s-ourbank = {2}.bank then do:
      displ v-info v-who v-whn with frame kdbalcomm.
      message 'F1 - Сохранить,   F4 - Выход без сохранения'. 
      update v-info with frame kdbalcomm.
      find current {1} exclusive-lock. 
      {1}.info[1] = v-info.
      find current {1} no-lock. 
    end.
    else do:
      displ v-info v-who v-whn with frame kdbalcomm.
      pause.
    end.

end.

