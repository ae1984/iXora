/*lcdocse .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        формирование документов по событию
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
        08/04/2011 id00810 - добавлено событие expire
        03/06/2011 id00810 - добавлено событие Advice of Discrepancy, Authorisation to Pay
        09/08/2011 id00810 - добавлено событие Adjust
        19/08/2011 id00810 - убрала отладочное сообщение
        06/10/2011 id00810 - Adjust - добавлена проверка реквизита МТ202
        14/10/2011 id00810 - добавлены события IMLC: Authorization to Reimburse (MT740),Amendment to an Authorization to Reimburse (MT747),EXLC: Reimbursement Claim (MT742)
        28/10/2011 id00810 - добавлено событие IMLC: Post Finance Details
        07/03/2012 id00810 - добавлено событие Cancel
        29/03/2012 id00810 - добавлена печать платежного ордера по восстановлению лимита в событиях expire, cancel
*/

{global.i}
def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.
def shared var s-sts    like lcevent.sts.
def shared var v-cif    as   char.
def var v-sel    as int  no-undo.
def var v-fmt    as char no-undo.
def var v-order  as logi no-undo.
def var v-bank   as char no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var v-pr     as logi no-undo.
def new shared   var s-jh like jh.jh.
def stream out.

 find first sysc where sysc.sysc = "OURBNK" no-lock no-error.
 if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
 else return.

v-fmt = if s-event = 'discr' then '750' else if s-event = 'rclaim' then '742' else if s-event = 'authp' then '752' else if s-event = 'authr' then '740' else if s-event = 'amdauthr' then '747' else '202'.
if lookup(s-event,'intch,exp,cnl,pfind') > 0 then run sel2('Docs',' Payment Order ', output v-sel).
else if s-event = 'adjust' then do:
    find first lceventh where lceventh.bank = v-bank and lceventh.LC = s-lc and lceventh.event = s-event  and lceventh.number = s-number and lceventh.kritcode = 'Opt' no-lock no-error.

    if avail lceventh and lceventh.value1 <> '' then do:
        if lceventh.value1 = 'yes' then do:
            find first lceventh where lceventh.bank = v-bank and lceventh.LC = s-lc and lceventh.event = s-event  and lceventh.number = s-number and lceventh.kritcode = 'MT202' no-lock no-error.
            if avail lceventh and lookup(lceventh.value1,v-logsno) = 0
            then run sel2('Docs',' MT ' + v-fmt + ' | Payment Order ', output v-sel).
            else  v-order = yes.
        end.
        else v-order = yes.
        if v-order then run sel2('Docs',' Payment Order ', output v-sel).
    end.
end.
else run sel2('Docs',' MT' + v-fmt + ' ', output v-sel).

case v-sel:
    when 1 then do:
        if lookup(s-event,'intch,exp,cnl,pfind') > 0 or v-order then do:
            find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock no-error.
            if avail lceventres then do:
                for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock:
                    s-jh  = 0.
                    find first jh where jh.jh = lceventres.jh no-lock no-error.
                    if avail jh then do:
                        s-jh = jh.jh.
                        run vou_bank(1).
                        v-pr = yes.
                    end.
                end.
            end.
            if can-do('exp,cnl',s-event) then do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
                if avail lch then do:
                    find first lclimitres where lclimitres.bank = v-bank and lclimitres.cif = v-cif and lclimitres.number = int(lch.value1) and lclimitres.jh > 0 and lclimitres.lc = s-lc  and lclimitres.info[1] = 'expire' no-lock no-error.
                    if avail lclimitres then do:
                        s-jh  = 0.
                        find first jh where jh.jh = lclimitres.jh no-lock no-error.
                        if avail jh then do:
                            s-jh = jh.jh.
                            run vou_bank(1).
                            v-pr = yes.
                        end.
                    end.
                end.
            end.
            if not v-pr then message 'No postings avail!' view-as alert-box.
        end.
        else do:
            pause 0.
            run lcmtext (v-fmt,no).
        end.

    end.
    when 2 then do:
        find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock no-error.
        if avail lceventres then do:
            for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock:
                s-jh  = 0.
                find first jh where jh.jh = lceventres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.
    end.
end case.