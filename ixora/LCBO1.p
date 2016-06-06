/* LCBO1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        смена статуса MD2 - BO1
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
        16.07.2012 Lyubov  - испрвила lc.sts на lc.lcsts
 */

{mainhead.i}

def shared var v-lcsts as char.
def shared var s-namef as char.
def shared var s-lc  like LC.LC.

def var v-zag      as char no-undo.
def var v-event    as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

if v-lcsts  = 'MD2' then do:
    pause 0.
    run LCsts(v-lcsts,'BO1').
end.

find last lc where lc.lc = s-lc no-lock no-error.
if avail lc and lc.lcsts = 'BO1' then do:
v-event = if lc.lc begins 'EX' then 'Advise' else 'Create'.
  /* сообщение */
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'BO1' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'BO2'
               v-str = 'You have a ' + v-event + ' under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.
