/* lonstl-i3.f
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
     lnsci.schn format "x(10)"  label "Nr"
     lnsci.idat label "Дата"
     lnsci.iv format ">>>,>>>,>>9.99" label "Планируемый возврат "
     lnsci.paid-iv format ">>>,>>>,>9.99" label "Заплачено / Заплатить "
     lnsci.jh    format "zzzzzzzz" label  "Nr транз."
   with centered overlay no-hide row 10 7 down
   title "План + История | Заплач.: " + trim(sval)
                          + " / Заплатить: " + trim(svopnamt) 
   frame lonstl-i3.
form "1)План 2)Платежи" with overlay column 2 row 21
                                          no-box color messages frame msgi3.
form "Выбор:" marked with column 39 row 21
                          color input no-label no-box frame marked. 

