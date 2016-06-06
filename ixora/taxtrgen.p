/* taxtrgen.p
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
        31/10/03 sasco добавил формирование 
        29/04/04 kanat уравнялись все филиалы по типу отправки платежей = 1 квитанция - 1 пачка.
*/

/* sasco - run for taxtrgen0 (TXB00, 02)  nad taxtrgen1 (TXB01) */
{comm-txb.i}

def var seltxb as int.
seltxb = comm-cod().

                   
if seltxb = 0 then run taxtrgen00. /* АЛМАТЫ */
   else
   run taxtrgen0. /* ОСТАЛЬНЫЕ ФИЛИАЛЫ */

