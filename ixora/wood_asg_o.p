/* wood_asg_o.p
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

TRIGGER PROCEDURE FOR Assign OF wood.o_amt OLD VALUE old_amount.

define variable delta as decimal.

delta = wood.o_amt - old_amount.

run wood_asgn(wood.account,wood.date,wood.o_amt,old_amount,"o",wood.acctype,wood.grp). 

if wood.acctype <> "D" then do:
   wood.balance = wood.balance - delta . /* Balance Calcuation */
end.

