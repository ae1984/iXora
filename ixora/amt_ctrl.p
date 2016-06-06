/* amt_ctrl.p
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

/** amt_ctrl.p **/


define input  parameter amount   like joudoc.dramt.
define input  parameter currency like joudoc.drcur.
define output parameter ctrl     as logical.

define variable con_amt         like joudoc.dramt.
define variable trx_amt         like joudoc.dramt.

find sysc where sysc.sysc eq "trxcon" no-lock no-error.
    if not available sysc then do:
        message "В файле настроек  SYSC  <TRXCON>  не найден.".
        undo, return.
    end.

if currency eq 1 then do:
    con_amt = decimal (entry (1, sysc.chval, " ")).
        if amount ge con_amt then ctrl = true.
        else ctrl = false.
end.    
else do:
    con_amt = decimal (entry (2, sysc.chval, " ")).
    find crc where crc.crc eq currency no-lock no-error.
    trx_amt = amount * crc.rate[1] / crc.rate[9].
    find crc where crc.code eq "USD" no-lock no-error.
    trx_amt = trx_amt / crc.rate[1] * crc.rate[9].
        if trx_amt ge con_amt then ctrl = true.
        else ctrl = false.
end.


