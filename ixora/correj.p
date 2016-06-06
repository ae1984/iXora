/* correj.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Возврат к статусу NEW
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

def shared var v-lcsts as char.
if v-lcsts  <> 'NEW' and v-lcsts  <> 'FIN' then do:
    pause 0.
    run LCsts(v-lcsts,'NEW').
end.


