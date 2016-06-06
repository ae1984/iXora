/* LCprej.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        отправка платежа на корректировку
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
        24/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
   23/12/2010 Vera   - изменился frame frpay (добавлено 1 новое поле)
   21/01/2011 id00810 - убрала фрейм, изменила статусы
*/

{mainhead.i}

def shared var s-paysts like lcpay.sts.

if s-paysts  <> 'NEW' and s-paysts  <> 'FIN' and s-paysts  <> 'PAY' then do:
    pause 0.
    run LCstspay(s-paysts,'NEW').
end.


