/* loniss-p1.f
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

/* loniss-p1.f
   28-11-94
*/
form lnscg.mark label " "
     lnscg.schn  format "x(10)" label "Номер"
     lnscg.stdat label "Дата  "
     lnscg.stval format ">>>,>>>,>>>,>>9.99" label "Плановое значен."
     lnscg.paid  format ">>>,>>>,>>>,>>9.99" label "Осталось выдать"
   with centered overlay no-hide row 10 7 down
   title "План выдачи | Сумма: " + trim(svopnamt) 
   frame loniss-p1.
form "1)История 2)План + История" with overlay column 7 row 21
                                          no-box color messages frame msgp1. 

