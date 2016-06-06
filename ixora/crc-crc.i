/* crc-crc.i
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

function crc-crc returns decimal (sum as decimal, c1 as int, c2 as int).
define buffer bcrc1 for crc.
define buffer bcrc2 for crc.
    if c1 <> c2 then 
       do:
          find first bcrc1 where bcrc1.crc = c1 no-lock no-error.
          find first bcrc2 where bcrc2.crc = c2 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.    

end.

function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
define buffer bcrc1 for crchis.
define buffer bcrc2 for crchis.
    if c1 <> c2 then 
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.    

end.