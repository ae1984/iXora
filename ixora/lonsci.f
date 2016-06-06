/* lonsci.f
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

/* lonsci.f
   7-09-94
*/
form lnsci.schn format "x(9)" label "Nr"
     lnsci.idat label "Дата"
     lnsci.iv-sc format ">>>,>>>,>>9.99"   label "Сумма     "
     lnsci.paid-iv format ">>>,>>>,>>9.99" label "Оплатить  "
   with overlay no-hide column 1 row 10 7 down 
   title "Календарь платежей процентов | Всего: " + trim(svint)
   frame lonsci.
  
form "1)Клнд.выдачи 2)Клнд.погашен. 3) Ежемесяч.погаш." 
   with color messages overlay column 2 row 21 no-box frame msgi.
