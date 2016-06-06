/* tr-vcpartnw.p
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
 * BASES
        BANK COMM 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* tr-vcctw.p Валютный контроль
   Триггер на изменение записи в vccontrs

   09.12.2002 nadejda
*/

trigger procedure for write of vcpartners old oldvcpartners.

{vc.i}

vcpartners.udt = today.
vcpartners.uwho = userid("bank").


