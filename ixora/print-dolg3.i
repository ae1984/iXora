/* print-dolg3.i
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
        28.02.05 tsoy
 * CHANGES
*/

def var dok2 as char format "x(36)" extent 4 initial
                            [" 1. Оплатить со счета          ",
                             " 2. Льготный тариф _________  ",
                             " 3. Оплачено наличными  ",
                             " 4. Бесплатно   "].
     
form skip(1) dok2[1] skip dok2[2] skip dok2[3] skip dok2[4] with frame m2 centered
      title "выберите тип оплаты комиссии ИП" overlay no-labels row 10.

find tarif2 where tarif2.str5 = {1} and tarif2.stat = 'r' no-error. 
if available tarif2 then  do: 
     v-rate     = tarif2.ost.
     in_command = tarif2.ost.
end.