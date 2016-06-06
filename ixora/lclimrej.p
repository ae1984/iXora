/* lclimrej.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        limits - отправка cсобытия на корректировку
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-1 опция reject
 * AUTHOR
        04/10/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{mainhead.i}

def shared var v-limsts    as char.
if lookup(v-limsts,'MD1,MD2,BO1,ERR') > 0 then do:
    pause 0.
    run lclimsts(v-limsts,'NEW').
end.

