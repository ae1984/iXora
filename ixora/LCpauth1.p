/* LCpauth1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        первое авизование платежа по аккредитиву
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
   21/01/2011 id00810 - убрала фрейм, статусы MD1 - MD2
   13.07.2012 Lyubov  - добавила отправку писем для подтверждения BO1
*/

{mainhead.i}

def shared var s-lc     like LC.LC.
def shared var s-namef    as char.

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

define shared variable s-paysts like lcpay.sts.
if s-paysts  = 'MD1' then do:
    pause 0.
    run LCstspay(s-paysts,'MD2').
end.

/* сообщение */
find last lcpay where lcpay.lc = s-lc no-lock no-error.
if avail lcpay and lcpay.sts = 'MD2' then do:
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'BO1' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'BO1'
               v-str = 'You have a Payment under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.