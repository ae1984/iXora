/* lcrejectO799.p
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
        07/02/2011 evseev
 * BASES
        BANK COMM
 * CHANGES

*/

{mainhead.i}
def shared var s-corsts like lcswt.sts.
if s-corsts  <> 'NEW' and s-corsts  <> 'FIN' then do:
    pause 0.
    run LCcorsts(s-corsts,'NEW').
end.


