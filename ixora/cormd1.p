/* cormd1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Первая авторизация МД
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
        22.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def shared var s-corsts as char.
def shared var v-lcsts  as char.
def shared var s-lc     like LC.LC.
def shared var s-lcprod as char.
def shared var s-lctype as char.
def shared var s-lccor  like lcswt.lccor.
def shared var s-mt     as inte.
def shared var s-namef  as char.

/*тут проверка на заполнение всех необходимых полей */
def var v-mlist  as char.
def var v-mlist2 as char.
def var v-maillist as char.
def var v-zag as char.
def var v-str as char.
def var i        as integer.
def buffer b-lch for lch.

if s-lctype = 'I' then
v-mlist = 'AdvBank,TRNum,Narrat'.
else do:
    v-mlist = 'Sender,SeqTot,FurId,AppRule,DetGar'.
    find first lch where lch.lc = s-lc and lch.kritcode = 'MT768' no-lock.
    if avail lch and lch.value1 = 'Yes' then v-mlist = v-mlist + 'TRNum,BankRef,DtAdv'.

    find first lch where lch.lc = s-lc and lch.kritcode = 'MT799' no-lock.
    if avail lch and lch.value1 = 'Yes' then v-mlist = v-mlist + 'BankRef,TRNum,Narrat'.
end.
v-mlist2 = ''.
do i = 1 to num-entries(v-mlist):
    find first lch where lch.lc = s-lc and lch.kritcode = entry(i,v-mlist) no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
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

if v-lcsts  = 'NEW' then do:
    pause 0.
    run LCsts(v-lcsts,'MD1').
end.

/* сообщение */
find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2-2' no-lock no-error.
if avail bookcod then do:
    v-maillist = bookcod.name.
end.
if v-maillist <> '' then do:
    assign v-zag = 'MD2'
           v-str = 'You have a Outgoing Swift under ' + s-lc + ' pending – filial ' + s-namef + '.'.
    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
end.