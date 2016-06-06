/* lonscg.f
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
        04/05/06 marinav Увеличить размерность поля суммы
*/


/* lonscg.f
   26-09-94
*/    
form lnscg.schn format "x(9)" label "Nr"
     lnscg.stdat label "Дата"
     lnscg.stval format ">,>>>,>>>,>>9.99" label "Сумма       "
     lnscg.paid  format ">,>>>,>>>,>>9.99" label "Выдать     "
   with overlay no-hide column 14 row 6 7 down
   title "Календарь выдачи кредита | Всего: " + trim(svopnamt) 
   frame lonscg.
form "1)Клнд.погаш. 2)Клнд.плат.проц. 3)Сумма к выдаче"
     with overlay column 15 row 17 no-box color messages frame msgg.
