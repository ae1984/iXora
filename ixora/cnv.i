/* cnv.i
 * MODULE
        Конвертация
 * DESCRIPTION
        Данные для отчета по конвертациям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        exprconv.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        21.03.06 dpuchkov 
 * CHANGES
*/

def var v-sln1 as char no-undo.
def var v-sln2 as char no-undo.
def var v-s as integer no-undo.
    v-s = 0.
def frame sln
    v-sln1  format "x(52)"     label  "Цель покупки"  validate(v-sln1 <> "", "Необходимо ввести данные(F2-выбор)") help "F2-для выбора" skip
    v-sln2  format "x(52)"     label  "Цель покупки"  validate(v-sln2 <> "", "Необходимо ввести данные(F2-выбор)") help "F2-для выбора" skip
with side-labels centered row 6 .


on help of v-sln1 in frame sln do:
   run sel ("Выбер цели!", "Осуществление платежей в пользу резидентов|Осуществление платежей в пользу нерезидентов").
   if int(return-value) = 1 then v-sln1 = "Осуществление платежей в пользу резидентов".
   if int(return-value) = 2 then v-sln1 = "Осуществление платежей в пользу нерезидентов".
   displ v-sln1 with frame sln.
end.

on help of v-sln2 in frame sln do:
   run sel ("Выбер цели!", "Покупка товаров и нематериальных активов|Получение услуг|Выдача займов|Выполнение обязательств по займам|Расчеты по операциям с ценными бумагами|Заработная плата|Выплата командировочных и представительских расходов|Прочее").
   if int(return-value) = 1 then v-sln2 = "Покупка товаров и нематериальных активов".
   if int(return-value) = 2 then v-sln2 = "Получение услуг".
   if int(return-value) = 3 then v-sln2 = "Выдача займов".
   if int(return-value) = 4 then v-sln2 = "Выполнение обязательств по займам".
   if int(return-value) = 5 then v-sln2 = "Расчеты по операциям с ценными бумагами".
   if int(return-value) = 6 then v-sln2 = "Заработная плата".
   if int(return-value) = 7 then v-sln2 = "Выплата командировочных и представительских расходов".
   if int(return-value) = 8 then v-sln2 = "Прочее".

   displ v-sln2 with frame sln.
end.
v-sln1 = "".
v-sln2 = "".
repeat:
  v-s = 0.
  update v-sln1 v-sln2 with frame sln.
  if lookup (v-sln1, "Осуществление платежей в пользу резидентов,Осуществление платежей в пользу нерезидентов") = 0 then do:
     v-sln1 = "".
     next.
  end.
  if lookup (v-sln2, "Покупка товаров и нематериальных активов,Получение услуг,Выдача займов,Выполнение обязательств по займам,Расчеты по операциям с ценными бумагами,Заработная плата,Выплата командировочных и представительских расходов") = 0 then 
  do:
     if v-sln2 = "Прочее" then do:
        v-sln2 = "".
        update v-sln2 with frame sln. v-s = 1.  leave.
     end.
     v-sln2 = "".
     next.
  end. else
  v-s = 1.
  leave.
end.

if v-s = 0 then return.









