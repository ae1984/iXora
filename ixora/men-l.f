﻿/* men-l.f
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

define variable men-l  as character extent 12 format 'x(10)'.
men-l[1]  = 'январь '.
men-l[2]  = 'февраль '.
men-l[3]  = 'март '.
men-l[4]  = 'апрель'.
men-l[5]  = 'май  '.
men-l[6]  = 'июнь  '.
men-l[7]  = 'июль  '.
men-l[8]  = 'август '.
men-l[9]  = 'сентябрь '.
men-l[10] = 'октябрь'.
men-l[11] = 'ноябрь  '.
men-l[12] = 'декабрь '.
