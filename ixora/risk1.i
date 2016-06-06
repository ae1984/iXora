/* risk1.i
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

v-title = "Вид обеспечения для клиента " + substr(cif.name,1,25)  + " Счет " + lon.lon. 


   def frame   frame1
   skip(1) btn1 btn2 btn3 btn4 btn5 btn6 btn7 btn8 with centered title v-title   row 5 .

  on choose of btn1,btn2,btn3,btn4, btn5, btn6, btn7, btn8 do:
    if self:label = "Депозит " then prz = 1.
    else
    if self:label = "Недв-ть " then prz=2.
    else
    if self:label = "Автомобиль " then prz=3.
    else
    if self:label = "Обор-ие " then prz=4.
    else
    if self:label = "Товары в обороте " then prz=5.
    else
    if self:label = "Товары, поступ в будущем " then prz=6.
    else
    if self:label = "Без обеспечения " then prz=7.
    else prz = 8.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8.
    if prz = 8 then return.
 hide  frame frame1.
