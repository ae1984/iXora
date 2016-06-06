/* comm-txb.i
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

/* KOVAL */

/* Возвращает код банка, например - TXB00 */

function comm-txb returns character.

     find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error .
     if not avail bank.sysc or bank.sysc.chval = "" then do:
         display " This isn't record OURBNK in bank.sysc file !!".
         pause.
         return "".
     end.

     return trim(bank.sysc.chval).

end.

/* Возвращает числовой код банка, например - 0 */
function comm-cod returns integer.

     find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error .
     if not avail bank.sysc or bank.sysc.chval = "" then do:
         display " This isn't record OURBNK in bank.sysc file !!".
         pause.
         return ?.
     end.

     return integer(substr(trim(bank.sysc.chval),4,2)).

end.
