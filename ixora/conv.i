/* conv.i
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

function CRC2KZT returns decimal(sum$ as dec, crc$ as int, dt$ as date).
    find last txb.crchis where txb.crchis.crc = crc$ and txb.crchis.whn <= dt$.
    return sum$ * txb.crchis.rate[1].
end.