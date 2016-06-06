/* x1-cash.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        16.01.2012 damir.
*/

{global.i}

{keyord.i} /*Переход на новые и старые форматы ордеров*/

if v-noord = no then run x1-cash1.
else run x1-cash2.


