/* lcadvmd2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advise of Amendment - МД2(акцепт)
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
        17/05/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        07/02/2012 id00810 - если есть комиссии, то статус меняется на BO1 (акцепт бэк-офиса)
        13.07.2012 Lyubov  - добавила отправку писем для подтверждения BO1
*/
{mainhead.i}
{chk-f.i}
def shared var s-lc       like lc.lc.
def shared var s-lcamend  like lcamend.lcamend.
def shared var s-amdsts   like lcamend.sts.
def shared var s-lccor    like lcswt.lccor.
def shared var v-lcerrdes as char.
def shared var s-namef    as char.

def var v-yes     as logi no-undo.
def var v-file    as char no-undo.
def var v-exist1  as char no-undo.

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

pause 0.
find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

if s-amdsts <> 'MD1' and s-amdsts <> 'Err' then do:
    message "Amendment status should be MD1 or Err!" view-as alert-box error.
    return.
end.

find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'AdvBy' no-lock no-error.
if not avail lcamendh or lcamendh.value1 = '' then do:
    message 'The field Advise By is compulsory to complete!' view-as alert-box error.
    return.
end.

find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com and lcamendres.amt <> 0 no-lock no-error.
if avail lcamendres then do:
    run LCsts2(s-amdsts,'MD2').
    return.
end.

message 'Do you want to change Amendment status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

if lcamendh.value1 = '0' then do:

    if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
        message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
        find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
        if avail lcamendh then find current lcamendh exclusive-lock.
        else create lcamendh.
        assign lcamendh.value1   = "There is no file $HOME/.ssh/id_swift!"
               lcamendh.lc       = s-lc
               lcamendh.lcamend  = s-lcamend
               lcamendh.kritcode = 'ErrDes'
               lcamendh.bank     = lc.bank.
        run LCsts2(s-amdsts,'Err').
        v-lcerrdes = "There is no file $HOME/.ssh/id_swift!".
        return.
    end.
    run i799mt no-error.
    if error-status:error then do:
        find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
        if avail lcamendh then find current lcamendh exclusive-lock.
        else create lcamendh.
        assign lcamendh.value1   = "File wasn't copied to SWIFT Alliance!"
               lcamendh.lc       = s-lc
               lcamendh.lcamend  = s-lcamend
               lcamendh.kritcode = 'ErrDes'
               lcamendh.bank     = lc.bank.
        run LCsts2(s-amdsts,'Err').
        v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
        return.
    end.

    find first lch where lch.lc = s-lc and  LCh.value4 = 'O799-' + string(s-lccor,'999999') and lch.kritcode = "TRNum" and lch.value1 <> '' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then v-file = replace(lch.value1,"/", "_") + "_" + string(s-lccor,'999999').

    find first LCswt where LCswt.LC = s-lc and LCswt.LCcor = s-lccor and LCswt.mt = 'I799' exclusive-lock no-error.
    assign  LCswt.fname1 = v-file
            LCswt.dt     = g-today
            LCswt.sts    = 'FIN'.
    find current LCswt no-lock no-error.
end.

run LCsts2(s-amdsts,'FIN').

/* сообщение */
find last lcamend where lcamend.lc = s-lc no-lock no-error.
if avail lcamend and lcamend.sts = 'MD2' then do:
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'BO1' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'BO1'
               v-str = 'You have a Advise of Amendment under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.