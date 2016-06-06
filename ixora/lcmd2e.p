/* lcmd2e.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        акцепт второго менеджера фронт-офиса
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
        03/06/2011 id00810 - добавлены события Advice of Discrepancy, Authorisation to Pay
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        14/10/2011 id00810 - добавлены события Authorization to Reimburse, Amendment to an Authorization to Reimburse, Reimbursement Claim
        09/02/2012 id00810 - добавлено событие Advise of Refusal
        13.07.2012 Lyubov  - добавила отправку писем для подтверждения BO1
*/

{mainhead.i}
{chk-f.i}
def shared var s-lc       like lc.lc.
def shared var s-sts      like lcevent.sts.
def shared var s-event    like lcevent.event.
def shared var s-number   like lcevent.number.
def shared var s-ourbank  as char no-undo.
def shared var v-lcerrdes as char.
def shared var s-namef    as char.

def var v-yes as logi no-undo.
def var v-fmt as char no-undo.

def var v-zag    as char no-undo.
def var v-str    as char no-undo.
def var v-maillist as char no-undo.

pause 0.
if lookup(s-event,'discr,rclaim,authp,authr,amdauthr,advicer,adva,advnp') > 0 and (s-sts  = 'MD1' or s-sts = 'ERR') then do:
   message 'Do you want to change event status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
   if not v-yes then return.

    if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
        message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
        find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
        if avail lceventh then find current lceventh exclusive-lock.
        else create lceventh.
        assign lceventh.value1   = "There is no file $HOME/.ssh/id_swift!"
               lceventh.lc       = s-lc
               lceventh.event    = s-event
               lceventh.number   = s-number
               lceventh.bank     = s-ourbank
               lceventh.kritcode = 'ErrDes'.
        run lcstse(s-sts,'Err').
        return.
    end.
    v-fmt = if s-event = 'discr' then '750' else if s-event = 'rclaim' then '742'  else if s-event = 'authp' then '752' else if s-event = 'authr' then '740' else if s-event = 'advicer' then '734' else '747'.
    if v-fmt = '734' then run mt734.p no-error.
    else run lcmtext (v-fmt,yes) no-error.
    if error-status:error then do:
        find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
        if avail lceventh then find current lceventh exclusive-lock.
        else create lceventh.
        assign lceventh.value1   = "File wasn't copied to SWIFT Alliance!"
               lceventh.lc       = s-lc
               lceventh.event    = s-event
               lceventh.number   = s-number
               lceventh.bank     = s-ourbank
               lceventh.kritcode = 'ErrDes'.
        run lcstse(s-sts,'Err').
        v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
        return.
    end.

    run lcstse(s-sts,'FIN').
    if s-sts = 'ERR' then do:
        find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
        if avail lceventh then do:
            find current lceventh exclusive-lock.
            lceventh.value1 = ''.
            find current lceventh no-lock no-error.
            v-lcerrdes = ''.
        end.
    end.
end.
else if s-sts  = 'MD1' then do:
    run lcstse(s-sts,'MD2').

/* сообщение */
    find last lcevent where lcevent.lc = s-lc and lcevent.event = s-event no-lock no-error.
    if avail lcevent and lcevent.sts = 'MD2' then do:
        find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'BO1' no-lock no-error.
        if avail bookcod then do:
            v-maillist = bookcod.name.
        end.
        find first bookcod where bookcod.bookcod = 'lcevent' and bookcod.code = s-event no-lock no-error.
        if v-maillist <> '' then do:
            assign v-zag = 'BO1'
                   v-str = 'You have a ' + bookcod.name + ' under ' + s-lc + ' pending – filial ' + s-namef + '.'.
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
        end.
    end.

end.
