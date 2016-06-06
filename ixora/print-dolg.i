/* print-dolg.i
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

   def var dok as char format "x(36)" extent 4 initial
                         [" 1. Оплатить со счета          ",
                          " 2. Льготный тариф _________  ",
                          " 3. Оплачено наличными  ",
                          " 4. Бесплатно   "].
     
 Form skip(1) dok[1] skip dok[2] skip dok[3] skip dok[4]  
    With frame m CENTERED
      TITLE "выберите тип оплаты комиссии" overlay no-labels row 10.
   find tarif2 where tarif2.str5 = '101' and tarif2.stat = 'r' no-error. 
   if available tarif2 then  do: 
    v-rate = tarif2.ost.
    in_command = tarif2.ost.
   end.