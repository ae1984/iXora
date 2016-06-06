/* risk3.i
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
*/

v-title = "Кредитная история для клиента" + substr(cif.name,1,25) . 
   def frame   frame3
   skip(1) btn15 btn16 btn17 btn18 btn8 with centered title v-title  row 5 .

  on choose of btn15,btn16,btn17,btn18, btn8 do:
    if self:label = "Безупречная" then prz = 1.
    else
    if self:label = "Хорошая" then prz=2.
    else
    if self:label = "Плохая" then prz=3.
    else
    if self:label = "Нет" then prz=4.
    else prz = 5.
   end.
   enable all with frame frame3.
    wait-for choose of btn15, btn16, btn17, btn18, btn8.
    if prz = 5 then return.
 hide  frame frame3.
