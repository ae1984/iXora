/* lonstl-p1.f
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
form lnsch.schn  format "x(10)" label "Nr"
     lnsch.stdat label "Дата"
     lnsch.stval format ">>>,>>>,>>9.99" label "Планируемый возврат"
     lnsch.paid  format ">>>,>>>,>>9.99" label "Фактический возврат"
   with centered overlay no-hide row 10 7 down
   title "План погашения | Всего: " + trim(svopnamt) 
   frame lonstl-p1.
form "1)Платежи 2)План+платежи" with overlay column 8 row 21
                                          no-box color messages frame msgp1. 

