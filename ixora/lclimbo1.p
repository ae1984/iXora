/* lclimbo1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Limits - акцепт первого менеджера бэк-офиса
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14.7.1.1 опция BO1
 * AUTHOR
        21/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}
def shared var v-limsts as char.
if v-limsts  = 'MD2' then do:
    pause 0.
    run lclimsts(v-limsts,'BO1').
end.
