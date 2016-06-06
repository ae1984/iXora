/* LCBO1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        акцепт первого менеджера бек-оффиса
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
   01/03/2011 id00810 - убрала фрейм
   09/08/2011 id00810 - присваивается статус BO1 (аналогично другим событиям)
   13.07.2012 Lyubov  - добавила отправку писем для подтверждения BO2
*/

{mainhead.i}

def shared var s-lc          like LC.LC.
def shared variable s-amdsts like lcamend.sts.
def shared var s-namef         as char.

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

if s-amdsts = 'MD2' /*'BO1'*/ then do:
    pause 0.
    run LCsts2(s-amdsts,'BO1' /*'BO2'*/).
end.

/* сообщение */
find last lcamend where lcamend.lc = s-lc no-lock no-error.
if avail lcamend and lcamend.sts = 'BO1' then do:
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'BO1' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'BO2'
               v-str = 'You have a Amendment under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.