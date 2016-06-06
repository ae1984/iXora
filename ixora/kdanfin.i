/* kdanfin.i
 * MODULE
        ЭКД - Электронное кредитное досье
 * DESCRIPTION
        финансовый анализ
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
    05/09/06   marinav - добавление индексов
*/



if s-kdcif = '' then return.

find {2} where {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00")  no-lock no-error.

if not avail {2} then do:
  message skip " Клиент N" s-kdcif "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


define var v-sel as char.

  run sel ("Фин. анализ для досье :", 
           " 1. Период для фин. анализа | 2. Комментарии относительно cross checking | 
3. Комментарии относительно коэффициентов | 4. Выход ").
  v-sel = return-value.

  case v-sel:     
    when "1" then    run kdperiod.
    when "2" then    run kdcross.
    when "3" then    run kdkoef.
    when "4" then return.
  end case.

procedure kdperiod.
   define var d1 as date.
   define var d2 as date.
   define var fl as inte init 0.

   find first {1} where  {1}.kdcif = s-kdcif and {3}  
                     and {1}.code = '18' and  ({1}.bank = s-ourbank or s-ourbank = "TXB00")  no-lock no-error.
   if avail {1} then assign d1 = {1}.datres[1] d2 = {1}.datres[2].
   else if s-ourbank <> {2}.bank then do:
          message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
          return.
        end.

   form skip(1) d1 label '        С  ' 
     d2 label '      по  '  skip(1) 
        with side-label row 5 centered 
        title 'Укажите даты начала и конца периода для фин анализа' frame dat .

   if s-ourbank = {2}.bank then do: /* madiar: в ГО - не редактируются досье филиалов. bal_cif - таблица bank */
     update d1 d2 with frame dat.
     find first bal_cif where bal_cif.cif = s-kdcif and bal_cif.rdt = d1  
          and bal_cif.nom begins 'a' use-index cif-rdt no-lock no-error.

     if not avail bal_cif then do:
        message skip " По этому клиенту нет баланса (актив) за " d1 skip(1)
          view-as alert-box buttons ok title " ОШИБКА ! ".
        fl = 1.
     end.
     find first bal_cif where bal_cif.cif = s-kdcif and bal_cif.rdt = d1  
          and bal_cif.nom begins 'p' use-index cif-rdt no-lock no-error.

     if not avail bal_cif then do:
        message skip " По этому клиенту нет баланса (пассив) за " d1 skip(1)
          view-as alert-box buttons ok title " ОШИБКА ! ".
        fl = 1.
     end.
     find first bal_cif where bal_cif.cif = s-kdcif and bal_cif.rdt = d2  
          and bal_cif.nom begins 'a' use-index cif-rdt no-lock no-error.

     if not avail bal_cif then do:
        message skip " По этому клиенту нет баланса (актив) за " d2 skip(1)
          view-as alert-box buttons ok title " ОШИБКА ! ".
        fl = 1.
     end.
     find first bal_cif where bal_cif.cif = s-kdcif and bal_cif.rdt = d2  
          and bal_cif.nom begins 'p' use-index cif-rdt no-lock no-error.

     if not avail bal_cif then do:
        message skip " По этому клиенту нет баланса (пассив) за " d2 skip(1)
          view-as alert-box buttons ok title " ОШИБКА ! ".
        fl = 1.
     end.
     find first bal_cif where bal_cif.cif = s-kdcif and bal_cif.rdt = d2  
          and bal_cif.nom begins 'z' use-index cif-rdt no-lock no-error.

     if not avail bal_cif then do:
        message skip " По этому клиенту нет фин. отчетности за " d2 skip(1)
          view-as alert-box buttons ok title " ОШИБКА ! ".
        fl = 1.
     end.

     if fl = 1 then return.
   end.
   else do:
     displ d1 d2 with frame dat. pause.
   end.
   
   if not avail {1} then do:
      create {1}.
      assign {1}.bank = s-ourbank {1}.kdcif = s-kdcif  
             {1}.code = '18' {1}.who = g-ofc {1}.whn = g-today. {3}.
      find current {1} no-lock no-error. 
   end.
   find current {1} exclusive-lock no-error. 
   assign {1}.datres[1] = d1 {1}.datres[2] = d2.
   find current {1} no-lock no-error. 

end.

procedure kdcross.

define frame fr skip(1)
       {1}.amount    label "Взнос        " skip(1)
       {1}.info[1]   label "Комментарии  " VIEW-AS EDITOR SIZE 50 by 8 skip(1)
       {1}.whn       label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " CROSS CHECKING " .
  
find first {1} where  {1}.kdcif = s-kdcif  and {3}
                  and {1}.code = '18' and ({1}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
   if not avail {1} then do:
     if s-ourbank = {2}.bank then do:
       create {1}.
       assign {1}.bank = s-ourbank {1}.kdcif = s-kdcif 
              {1}.code = '18' {1}.who = g-ofc {1}.whn = g-today. {3}.
       find current {1} no-lock no-error. 
     end.
     else do:
       message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
       return.
     end.
   end.
   displ {1}.amount {1}.info[1] {1}.whn {1}.who with frame fr.
   if s-ourbank = {2}.bank then do:
     find current {1} exclusive-lock no-error.
     update {1}.amount {1}.info[1] with frame fr.
     {1}.who = g-ofc. {1}.whn = g-today.
     find current {1} no-lock no-error.
   end.
   else do:
     display {1}.amount {1}.info[1] {1}.who {1}.whn with frame fr.
     pause.
   end.
end.


procedure kdkoef.

define frame fr skip(1)
       {1}.info[2]   label "Комментарии  " VIEW-AS EDITOR SIZE 50 by 8 skip(1)
       {1}.whn       label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " ФИНАНСОВЫЕ КОЭФФИЦИЕНТЫ " .
  
find first {1} where  {1}.kdcif = s-kdcif and {3} 
                  and {1}.code = '18' and ({1}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error. 
   if not avail {1} then do:
     if s-ourbank = {2}.bank then do:
       create {1}.
       assign {1}.bank = s-ourbank {1}.kdcif = s-kdcif 
              {1}.code = '18' {1}.who = g-ofc {1}.whn = g-today. {3}.
       find current {1} no-lock no-error.
     end.
     else do:
       message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
       return.
     end.
   end.
   displ {1}.info[2] {1}.whn {1}.who with frame fr.
   if s-ourbank = {2}.bank then do:
     find current {1} exclusive-lock no-error.
     update {1}.info[2] with frame fr.
     {1}.who = g-ofc. {1}.whn = g-today.
     find current {1} no-lock no-error.
   end.
   else do:
     displ {1}.info[2] {1}.who {1}.whn with frame fr.
     pause.
   end.
end.
