/* cormd2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Вторая авторизация МД
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
        18.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def shared var s-corsts as char.
def shared var v-lcsts  as char.
def shared var s-namef  as char.
def shared var s-lc  like LC.LC.

if v-lcsts  = 'MD1' then do:
    pause 0.
    run LCsts(v-lcsts,'MD2').
end.