﻿/* vcrepa14.p
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
        01/07/04 saltanat - Добавлен параметр в вызыв.процедуру vcrep14 (4-й). 
                            "all" Все Контракты.
                            "exp" Контракты по экспорту отд-х товаров. тип = 5.
*/

/* vcrepa14.p - Валютный контроль 
   Приложение 14 - сводная информация за месяц о результатах - по банку

   11.11.2002 nadejda создан
*/

{mainhead.i}

run vcrep14 ("rep", "this", 0, "1").

