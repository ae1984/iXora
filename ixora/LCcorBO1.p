/* LCcorMD2.p
 * MODULE
        Trade Finance
 * DESCRIPTION

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
        08/02/2010 evseev
 * BASES
        BANK COMM
 * CHANGES

*/

{mainhead.i}

def shared var s-corsts as char.
if s-corsts  = 'MD2' then do:
    pause 0.
    run LCcorsts(s-corsts,'BO1').
end.

