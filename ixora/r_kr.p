/* r_kr.p
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


def button  btn1  label "Сокращенный отчет".
def button  btn2  label "Полный отчет   ".
def button  btn3  label "Отчет с кред рейтингом".
def button  btn4  label "Выход ".
def frame   frame1
    skip(1) btn1 btn2 btn3  btn4 with centered title "Сделайте выбор:" row 5 .
def new shared var prz as deci.

on choose of btn1,btn2,btn3,btn4 do:
   if self:label = "Сокращенный отчет" then do: prz = 1. run r_krcom.  end.    /*без оценки кредитного риска*/
   else if self:label = "Полный отчет   "   then do: prz = 2. run r_krcom2. end. /*без оценки кредитного риска*/
   else if self:label = "Отчет с кред рейтингом" then do: prz = 3. run r_krcom2. end. /*с оценкой кредитного риска*/
  else prz = 4.
end.

enable all with frame frame1.
wait-for choose of btn1, btn2, btn3, btn4.
if prz = 4 then return.
