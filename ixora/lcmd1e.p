/* lcmd1e.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        акцепт первого менеджера фронт-офиса
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
        30/03/2011 id00810 - добавила проверку обязательных полей для события External Charges
        01/06/2011 id00810 - добавлены события Advice of Discrepancy, Authorisation to Pay
        14/07/2011 id00810 - добавлено событие Adjust
        14/10/2011 id00810 - добавлены события Authorization to Reimburse, Amendment to an Authorization to Reimburse,Reimbursement Claim
        28/10/2011 id00810 - добавлено событие IMLC: Post Finance Details
        14/12/2011 id00810 - adjust crc = 1
        13.07.2012 Lyubov  - добавила отправку писем для подтверждения MD2
*/

{mainhead.i}
def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.
def shared var s-sts    like lcevent.sts.
def shared var s-namef    as char.

def var v-mlist  as char no-undo.
def var v-mlist2 as char no-undo.
def var i        as int  no-undo.
def var v-type   as char no-undo.
def var v-crc    as int  no-undo.
def var v-fmt    as char no-undo.
def var v-opt    as char no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

if s-event = 'extch' then do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'ComPType' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message 'The field Payment Type is compulsory to complete!' view-as alert-box error.
        return.
    end.
    v-type = lceventh.value1.
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'CurCode' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message 'The field Currency Code is compulsory to complete!' view-as alert-box error.
        return.
    end.
    v-crc = int(lceventh.value1).
    v-mlist = 'ComAmt,KBE,KNP'.
    if v-crc = 1 then v-mlist = v-mlist + ',BenPay,BenAcc,BenIns,BenRnn'.
    else do:
        if v-type = '1' then do:
            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'MT756' no-lock no-error.
            if avail lceventh and lookup(lceventh.value1,v-logsno) = 0 then assign v-fmt = 'MT202,MT756' v-mlist = v-mlist + ',InsTo202,Insto756'.
            else assign v-fmt = 'MT202' v-mlist = v-mlist + ',InsTo202'.
            for each codfr where lookup(codfr.codfr,v-fmt) > 0
                             and  codfr.name[5] = 'M'
                             no-lock:
                if lookup(codfr.name[3],v-mlist) = 0 then do:
                    v-mlist = v-mlist + codfr.name[3] + ',' .
                    if codfr.name[4] ne '' then v-mlist = v-mlist + codfr.name[4] + ',' .
                end.
            end.

        end.
    end.
end.
if s-event = 'discr' or s-event = 'rclaim' or s-event = 'authp' or s-event = 'authr' or s-event = 'amdauthr' then do:
    v-fmt = if s-event = 'discr' then '750' else if s-event = 'rclaim' then '742' else if s-event = 'authp' then '752' else if s-event = 'authr' then '740' else '747'.
    for each codfr where codfr.codfr   = 'MT' + v-fmt
                     and codfr.name[5] = 'M'
                     no-lock:
        v-mlist = v-mlist + codfr.name[3] + ',' .
        if codfr.name[4] ne '' then v-mlist = v-mlist + codfr.name[4] + ',' .
    end.
    v-mlist = v-mlist + 'InstTo'.
end.

if s-event = 'adjust' then do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'Opt' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message 'The field Option is empty!' view-as alert-box error.
        return.
    end.
    v-opt = lceventh.value1.
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'CurCode' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message 'The field Currency Code is compulsory to complete!' view-as alert-box error.
        return.
    end.
    v-crc = int(lceventh.value1).
    v-mlist = 'PAmt'.
    if v-opt = 'yes' then do:
        v-mlist = v-mlist + ',KBE,KNP'.
        if v-crc = 1 then v-mlist = v-mlist + ',BenPay,BenAcc,BenIns,BenRnn'.
        else do:
            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'MT202' no-lock no-error.
            if avail lceventh and lookup(lceventh.value1,v-logsno) = 0 then do:
                for each codfr where codfr.codfr   = 'MT202'
                                 and codfr.name[5] = 'M'
                                 no-lock:
                    if lookup(codfr.name[3],v-mlist) = 0 then do:
                        v-mlist = v-mlist + codfr.name[3] + ',' .
                        if codfr.name[4] ne '' then v-mlist = v-mlist + codfr.name[4] + ',' .
                    end.
                end.
                v-mlist = v-mlist + 'InsTo202'.
            end.
        end.
    end.
end.
if s-event = 'pfind' then v-mlist = 'FinAmt,AllFrate,StartDt,NextPDt'.

if v-mlist ne '' then do:
    v-mlist = right-trim(v-mlist,',').

    do i = 1 to num-entries(v-mlist):
        find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = entry(i,v-mlist) no-lock no-error.
        if not avail lceventh or lceventh.value1 = '' then do:
            find first lckrit where lckrit.datacode = entry(i,v-mlist) no-lock no-error.
            if avail lckrit then do:
                if trim(v-mlist2) <> '' then v-mlist2 = v-mlist2 + ','.
                v-mlist2 = v-mlist2 + lckrit.dataName.
            end.
        end.
    end.
    if trim(v-mlist2) <> '' then do:
        message 'The following fields are compulsory to complete:~n~n"'  + v-mlist2 + '"' view-as alert-box.
        return.
    end.
end.
if s-sts  = 'NEW' then do:
    pause 0.
    run lcstse(s-sts,'MD1').
end.

find last lcevent where lcevent.lc = s-lc and lcevent.event = s-event no-lock no-error.
if avail lcevent and lcevent.sts = 'MD1' then do:
  /* сообщение */
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2-2' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    find first bookcod where bookcod.bookcod = 'lcevent' and bookcod.code = s-event no-lock no-error.

    if v-maillist <> '' then do:
        assign v-zag = 'MD2'
               v-str = 'You have a ' + bookcod.name + ' under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.
