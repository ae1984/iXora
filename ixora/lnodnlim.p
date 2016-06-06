/* lnodnlim.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Проставление пороговой суммы для отнесения к портфелю однородных кредитов
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
        18/04/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def var v-sum as deci no-undo.
v-sum = 0.

find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnodnor" no-lock no-error.
if avail pksysc then v-sum = pksysc.deval.


update skip(1)
       "  Введите сумму порогового значения для классификации однородных кредитов: " skip
       ' ' v-sum format ">>>,>>>,>>>,>>9.99" skip(1)
       with row 13 centered no-label frame fr.


do transaction:
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnodnor" exclusive-lock no-error.
    if not avail pksysc then do:
        create pksysc.
        assign pksysc.credtype = '0'
               pksysc.sysc = 'lnodnor'
               pksysc.des = "Однородные кредиты".
    end.
    assign pksysc.daval = g-today
           pksysc.inval = time
           pksysc.deval = v-sum.
    find current pksysc no-lock.
end.

