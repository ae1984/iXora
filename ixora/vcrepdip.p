﻿/* vcrepdip.p
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

/* vcrepdip.p Валютный контроль
   Отчет по задолжникам на дату - отсутствуют ГТД - импорт

   19.12.2002 nadejda создан
   31.03.2011 damir   - небольшие корректировки.
*/

{vc.i}

run vcrepdpl ("all", 0, "rep", "i").
