/* lcadvmd1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advise of Amendment - МД1(акцепт)
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
        13.07.2012 Lyubov  - добавила отправку писем для подтверждения MD2
*/

{mainhead.i}

def shared var s-lc      like lc.lc.
def shared var s-lcamend like lcamend.lcamend.
def shared var s-amdsts  like lcamend.sts.
def shared var s-lccor   like lcswt.lccor.
def shared var s-namef    as char.

/* проверка на заполнение всех необходимых полей */
def var v-mlist2 as char.
def var i as integer.

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'AdvBy' no-lock no-error.
if not avail lcamendh or lcamendh.value1 = '' then do:
    message 'The field Advise By is compulsory to complete!' view-as alert-box error.
    return.
end.

if lcamendh.value1 = '0' then do:
    find first pksysc where pksysc.sysc = 'outswt_criteria' no-lock no-error.
    if not avail pksysc then return.
    do i = 1 to num-entries(pksysc.chval).
        find first lckrit where lckrit.showorder = int(entry(i,pksysc.chval)) no-lock no-error.
        if not avail lckrit then next.
        find first lch where lch.lc = s-lc and lch.kritcode = lckrit.datacode and lch.value4 = 'O799-' + string(s-lccor,'999999') no-lock no-error.
        if not avail lch or lch.value1 = '' then do:
            if trim(v-mlist2) <> '' then v-mlist2 = v-mlist2 + ','.
            v-mlist2 = v-mlist2 + lckrit.dataName.
        end.
    end.
    if trim(v-mlist2) <> '' then do:
        message 'The following fields are compulsory to complete:~n~n"'  + v-mlist2 + '"' view-as alert-box.
        return.
    end.
end.
/*********************/
if s-amdsts  = 'NEW' then do:
    pause 0.
    run LCsts2(s-amdsts,'MD1').
end.

/* сообщение */
find last lcamend where lcamend.lc = s-lc no-lock no-error.
if avail lcamend and lcamend.sts = 'MD1' then do:
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2-2' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'MD2'
               v-str = 'You have a Advise of Amendment under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.