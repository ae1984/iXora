﻿/* vcdocshis.p
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

/* vccthis.p Валютный контроль
   Просмотр истории документа

   08.11.2002 nadejda создан

*/

def new shared var s-viewcommand as char.

s-viewcommand = "ps_less".
run vcdocshis0.