/* p_f_com.i
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

function p_f_com returns decimal (sum as decimal).
/*return round((sum / 1000) * 5,2).*/
/*    find last crc where crc.crc = 2.
    return round(crc.rate[1] * 0.9,2).
*/
    return 130.00.
end.
