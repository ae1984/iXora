/* LCmd1A.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        акцепт первого менеджера фронт-оффиса
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
    28/02/2011 id00810 - для всех импортных аккредитивов и гарантии
    13.07.2012 Lyubov  - добавила отправку писем для подтверждения MD2
*/

{mainhead.i}

def shared var v-cif as char.
def shared var s-lc like LC.LC.
def shared var s-amdsts like lcamend.sts.
def shared var s-lcamend like lcamend.lcamend.
def shared var s-lcprod as char.
def shared var s-namef    as char.

def var v-mlist  as char.
def var v-mlist2 as char.
def var i        as int.

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

/*тут проверка на заполнение всех необходимых полей */
if s-lcprod <> 'pg' then v-mlist = 'SendRef,ReceRef,BenAmd'.
else for each codfr where codfr.codfr = 'MT767'
                    and  codfr.name[5] = 'M'
                    no-lock:
        v-mlist = v-mlist + codfr.name[3] + ',' .
        if codfr.name[4] ne '' then v-mlist = v-mlist + codfr.name[4] + ',' .
end.
v-mlist = right-trim(v-mlist,',').

do i = 1 to num-entries(v-mlist):
    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = entry(i,v-mlist) no-lock no-error.
    if not avail lcamendh or lcamendh.value1 = '' then do:
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

/*********************/
if s-amdsts  = 'NEW' then do:
    pause 0.
    run LCsts2(s-amdsts,'MD1').
end.

find last lcamend where lcamend.lc = s-lc no-lock no-error.
if avail lcamend and lcamend.sts = 'MD1' then do:

  /* сообщение */
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2-2' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'MD2'
               v-str = 'You have a Amendment under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.