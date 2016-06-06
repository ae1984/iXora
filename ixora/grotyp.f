/* grotyp.f
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

/* grotyp.f */

form grotyp.type grotyp.des grotyp.pday grotyp.scg grotyp.camt grotyp.crate
     skip
     grotyp.trn grotyp.acc  grotyp.chc grotyp.pby to 33 grotyp.pen to 38
     grotyp.pamt to 59 grotyp.prate to 68 skip(1)
     with centered row 3 down frame grotyp.
