/* lcbo1e.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        акцепт первого менеджера бэк-офиса
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
        13.07.2012 Lyubov  - добавила отправку писем для подтверждения BO2
*/

{mainhead.i}

def shared var s-lc       like lc.lc.
def shared var s-sts      like lcevent.sts.
def shared var s-event    like lcevent.event.
def shared var s-namef    as char.

def var v-zag    as char no-undo.
def var v-str    as char no-undo.
def var v-maillist as char no-undo.

if s-sts  = 'MD2' then do:
    pause 0.
    run lcstse(s-sts,'BO1').
end.

/* сообщение */
find last lcevent where lcevent.lc = s-lc and lcevent.event = s-event no-lock no-error.
if avail lcevent and lcevent.sts = 'BO1' then do:
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'BO1' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    find first bookcod where bookcod.bookcod = 'lcevent' and bookcod.code = s-event no-lock no-error.
    if v-maillist <> '' then do:
        assign v-zag = 'BO2'
               v-str = 'You have a ' + bookcod.name + ' under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.