/* lclimmd1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Limits - акцепт первого менеджера фронт-офиса
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14.7.1.1 опция MD1
 * AUTHOR
        21/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def shared var s-cif       as char.
def shared var s-number    as int.
def shared var s-ourbank   as char no-undo.
def shared var v-limsts    as char.
def var v-mlist  as char no-undo init 'lcCrc,Amount,Revolv'.
def var v-mlist2 as char no-undo.
def var i        as int  no-undo.

/* проверка на заполнение всех необходимых полей */
do i = 1 to num-entries(v-mlist):
    find first lclimith where lclimith.bank = s-ourbank and lclimith.cif = s-cif and lclimith.number = s-number and lclimith.kritcode = entry(i,v-mlist) no-lock no-error.
    if not avail lclimith or lclimith.value1 = '' then do:
        find first lckrit where lckrit.datacode = entry(i,v-mlist) no-lock no-error.
        if avail lckrit then do:
            if trim(v-mlist2) <> '' then v-mlist2 = v-mlist2 + ','.
            v-mlist2 = v-mlist2 + lckrit.dataName.
        end.
    end.
end.
if trim(v-mlist2) <> '' then do:
    message 'The following fields are compulsory to complete:~n~n"'  + v-mlist2 + '"' view-as alert-box error.
    return.
end.
if v-limsts  = 'NEW' then do:
    pause 0.
    run lclimsts(v-limsts,'MD1').
end.
