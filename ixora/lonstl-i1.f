/* lonstl-i1.f
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

/* lonstl-br1.f
   28-11-94
*/
form lnsci.mark label " "
     lnsci.schn  format "x(10)" label "Nr"
     lnsci.idat label "Дата"
     lnsci.iv format ">>>,>>>,>>9.99" label "Планируемая оплата "
     lnsci.paid-iv format ">>>,>>>,>>9.99" label "Фактическая оплата     "
   with centered overlay no-hide row 10 7 down
   title "План| Заплач.: " + trim(sval)
                          + " / Заплатить: " + trim(svopnamt) 
   frame lonstl-i1.
form "1)Платежи 2)План+платежи" with overlay column 7 row 21
                                          no-box color messages frame msgi1.
form "Выбор:" marked with column 44 row 21
                          color input no-label no-box frame marked. 

