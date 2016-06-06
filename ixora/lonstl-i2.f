/* lonstl-i2.f
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
form lnsci.schn format "x(10)"  label "Nr"
     lnsci.idat label "Дата"
     lnsci.paid-iv  format ">>>,>>>,>>9.99" label "Заплатить   "
     lnsci.jh label "Nr транз."
   with centered overlay no-hide row 10 7 down
   title "История платежей | Всего: " + trim(svopnamt) 
   frame lonstl-i2.
form "1)План 2)План+платежи" with overlay column 15 row 21
                                          no-box color messages frame msgi2. 

