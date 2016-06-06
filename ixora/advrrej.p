/* advrrej.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        отправка на корректировку
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
        17/03/2011 evseev
 * BASES
        BANK COMM
 * CHANGES

*/

{mainhead.i}
def shared var s-sts like lcevent.sts.

if s-sts <> 'NEW' and s-sts <> 'FIN' then do:
    pause 0.
    run lcstse(s-sts,'NEW').
end.
