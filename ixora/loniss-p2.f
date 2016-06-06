/* loniss-p2.f
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

/* loniss-p2.f
   28-11-94
*/
form lnscg.schn  format "x(10)" label "Номер"
     lnscg.stdat label "Дата"
     lnscg.paid  format ">>>,>>>,>>>,>>9.99" label "Выдано"
     lnscg.jh label "Транзакция"
   with centered overlay no-hide row 10 7 down
   title "История выдачи | Сумма: " + trim(svopnamt) 
   frame loniss-p2.
form "1)План  2)План + История" with overlay column 15 row 21
                                          no-box color messages frame msgp2. 

