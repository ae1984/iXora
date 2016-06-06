/* lcreje.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        отправка cсобытия на корректировку
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
        16/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{mainhead.i}

def shared var s-sts like lcevent.sts.
if lookup(s-sts,'MD1,MD2,BO1,BO2,ERR') > 0 then do:
    pause 0.
    run lcstse(s-sts,'NEW').
end.

