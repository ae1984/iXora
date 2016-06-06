/* LCpBO1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        изменение статуса платежа по аккредитиву MD2 - BO1
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
        21/01/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        13.07.2012 Lyubov  - добавила отправку писем для подтверждения BO2
 */

{mainhead.i}

def shared var s-lc     like LC.LC.
def shared var s-namef    as char.

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

define shared variable s-paysts like lcpay.sts.
if s-paysts  = 'MD2' then do:
    pause 0.
    run LCstspay(s-paysts,'BO1').
end.

/* сообщение */
find last lcpay where lcpay.lc = s-lc no-lock no-error.
if avail lcpay and lcpay.sts = 'BO1' then do:
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'BO1' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'BO2'
               v-str = 'You have a Payment under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.