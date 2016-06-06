/* P_vccomp.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Процесс
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
        16.01.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        20.01.2012 aigul - рассылка отчетов на след день
        26.01.2012 aigul - исправила день рассылки
        30.01.2012 aigul - исправила отчет за понедельник
        29.01.2013 damir - Полностью переделал. Оптимизация кода. Внедрено Техническое Задание.
*/
{global.i}
{vccomparevar.i "new"}

p-type = "proc".

if weekday(today) = 2 then v-dt1 = g-today - 3.
else v-dt1 = g-today - 1.
v-dt2 = v-dt1.

if weekday(today) <> 7 or weekday(today) <> 1 then run vccompare.

