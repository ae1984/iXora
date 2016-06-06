/* dealst.p
 * MODULE
        Разделение модуля на МБД и РЕПО
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        deal.p, repo.p
 * MENU
        11-1 
 * BASES
        BANK 
 * AUTHOR
        22.12.03 nataly
 * CHANGES
        23/09/05 ten   добавил viewer - для возможности просмотра сделки.
        02.11.2005 marinav - МБД выделен в отдельный пункт
*/

def var prz as integer.

   def button  btn1  label "Сделки РЕПО".
   def button  btn2  label "Просмотр сделок".
   def button  btn3  label "Выход".
   def frame   frame1
   skip(1) btn1 btn2 btn3  with centered title "Выберите:" row 5 .

  on choose of btn1,btn2,btn3 do:
    if self:label = "Сделки РЕПО" then prz = 2.
    else 
    if self:label = "Просмотр сделок" then prz = 4.
    else prz = 3.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if prz = 3 then return.
 hide  frame frame1.

if prz = 2 then run repo.
if prz = 4 then run viewer.