/* risk2.i
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

v-title = "Оценка проекта для клиента" + substr(cif.name,1,25) + " Счет " + lon.lon. 
   def frame   frame2
   skip(1)  btn9 btn10 btn11 btn12 btn13 btn14 btn8 with centered title v-title  row 5 .

  on choose of btn9,btn10,btn11,btn12, btn13, btn14, btn8 do:
    if self:label = "Больш положит потоки по всем срокам" then prz = 1.
    else
    if self:label = "Небольш положит потоки по всем срокам" then prz=2.
    else
    if self:label = "Небольш отриц потоки по некот срокам" then prz=3.
    else
    if self:label = "Больш отриц потоки по некот срокам" then prz=4.
    else
    if self:label = "Проект убыточен" then prz=5.
    else
    if self:label = "Нет достаточных данных о проекте" then prz=6.
    else prz = 7.
   end.
   enable all with frame frame2.
    wait-for choose of btn9, btn10, btn11, btn12, btn13, btn14, btn8.
    if prz = 7 then return.
 hide  frame frame2.
