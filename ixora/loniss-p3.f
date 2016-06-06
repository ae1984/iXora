/* loniss-p3.f
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

/* loniss-p3.f
   28-11-94
*/
form lnscg.mark  label " "
     lnscg.schn  format "x(10)"label "Номер"
     lnscg.stdat label "Datums"
     lnscg.stval format ">>>,>>>,>>>,>>9.99" label "Планир. выдать  "
     lnscg.paid  format ">>>,>>>,>>>,>>9.99" label "Выдано    / Осталось  "
     lnscg.jh    format "zzzzzzzz" label  "Транзакция"
   with centered overlay no-hide row 10 7 down
   title "План  + История | Выдано   : " + trim(sval)
                          + " / Осталось  : " + trim(svopnamt) 
   frame loniss-p3.
form "1)План  2)История" with overlay column 3 row 21
                                          no-box color messages frame msgp3. 

