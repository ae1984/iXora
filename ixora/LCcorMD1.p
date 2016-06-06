/* LCcorMD1.p
 * MODULE
        Trade Finance
 * DESCRIPTION

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
        07/02/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        18/02/2011 id00810 - изменилось значение s-lcprod, оно не нужно для определения перечня необходимых полей
        05.03.2012 Lyubov  - передаем формат сообщения шареной переменнqо s-mt
        13.07.2012 Lyubov  - добавила отправку писем для подтверждения MD2
        16.07.2012 Lyubov  - исправила текст письма
*/

{mainhead.i}

def shared var s-corsts as char.
def shared var s-lc like LC.LC.
def shared var s-lcprod as char.
def shared var s-lccor like lcswt.lccor.
def shared var s-mt as inte.
def shared var s-namef    as char.

/*тут проверка на заполнение всех необходимых полей */
def var v-mlist as char.
def var v-mlist2 as char.
def var i as integer.
def buffer b-lch for lch.

def var v-zag      as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

/*if s-lcprod = 'outswt' then*/
v-mlist = 'AdvBank,TRNum,RREF,Narrat'.

v-mlist2 = ''.
do i = 1 to num-entries(v-mlist):
    find first lch where lch.lc = s-lc and lch.kritcode = entry(i,v-mlist) and LCh.value4 = 'O' + string(s-mt) + '-' + string(s-lccor,'999999') no-lock no-error.
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


/*********************/
if s-corsts  = 'NEW' then do:
    pause 0.
    run LCcorsts(s-corsts,'MD1').
end.

find last LCswt where LCswt.lc = s-lc no-lock no-error.
if avail LCswt and LCswt.sts = 'MD1' then do:
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
end.