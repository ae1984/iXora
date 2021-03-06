﻿/* lonstl-p3.f
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
form lnsch.mark  label " "
     lnsch.schn  format "x(10)" label "Nr"
     lnsch.stdat label "Дата"
     lnsch.stval format ">>>,>>>,>>9.99" label "Планир.погаш. "
     lnsch.paid format ">>>,>>>,>>9.99" label "Возвратить / Заплатить    "
     lnsch.jh    format "zzzzzzzz" label  "Nr транз."
   with centered overlay no-hide row 10 7 down
   title "План + История | Погаш.: " + trim(sval)
                          + " / Погасить: " + trim(svopnamt) 
   frame lonstl-p3.
form "1)План 2)Платежи" with overlay column 2 row 21
                                          no-box color messages frame msgp3. 

