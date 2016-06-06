/* lonstl-p2.f
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
     lnsch.paid format ">>>,>>>,>>9.99" label "Погаш. "
     lnsch.jh label "Nr транз."
   with centered overlay no-hide row 10 7 down
   title "История погашения| Всего: " + trim(svopnamt) 
   frame lonstl-p2.
form "1)План 2)План+платежи" with overlay column 16 row 21
                                          no-box color messages frame msgp2. 

