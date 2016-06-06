/* LCrejamd.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        отправка изменения на корректировку
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
        26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
   23/12/2010 Vera   - изменился frame framd (добавлено 1 новое поле)
   01/03/2011 id00810 - убрала фрейм, добавила статус ERR
*/

{mainhead.i}

define shared variable s-amdsts like lcamend.sts.
if lookup(s-amdsts,'MD1,MD2,BO1,BO2,MNG,ERR') > 0 then do:
    pause 0.
    run LCsts2(s-amdsts,'NEW').
end.

