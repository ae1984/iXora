/* jh-trig.p
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

TRIGGER PROCEDURE FOR Assign OF jh.who.

FIND ofc WHERE ofc.ofc = jh.who USE-INDEX ofc NO-LOCK.
jh.point = ofc.regno / 1000 - 0.5.
jh.depart = ofc.regno MODULO 1000.



