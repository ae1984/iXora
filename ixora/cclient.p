/* cclient.p
 * MODULE
        Риски
 * DESCRIPTION
        Редактирование клиентов в группе
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        28/02/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

def input parameter p-groupId as integer no-undo.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def new shared temp-table wrk like cclient
  field clname as char.

for each cclient where cclient.groupId = p-groupId no-lock:
    create wrk.
    assign wrk.groupId = p-groupId
           wrk.bank = cclient.bank.
           wrk.clientId = cclient.clientId.
end.

find first comm.txb where comm.txb.consolid and comm.txb.bank = s-ourbank no-lock no-error.
if avail comm.txb then do:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    run cclientGetNames.
end.

find first wrk where wrk.clname = '' no-lock no-error.
if avail wrk then do:
    for each comm.txb where comm.txb.consolid and comm.txb.bank <> s-ourbank no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
        run cclientGetNames.
        find first wrk where wrk.clname = '' no-lock no-error.
        if not avail wrk then leave.
    end.
end.

if connected ("txb") then disconnect "txb".

define query qt for wrk.

define buffer b-wrk for wrk.
def var v-rid as rowid.

def var v-bank as char no-undo.
def var v-cif as char no-undo.
def var v-cifname as char no-undo.

define browse bt query qt
       displ wrk.clientId label "Код" format "x(6)"
             wrk.clname label "Наименование" format "x(95)"
             with 27 down row 4 overlay no-label title " Редактирование клиентов в группе ".

define button btn1 label "Сохранить".
define frame ft bt help "<Ins>-Добавить, <Ctrl+D>-Удалить, <F4>-Выход без сохранения" skip
             btn1
             with width 110 row 3 overlay no-label.

on "insert-mode" of bt in frame ft do:
    {itemlist.i
        &file = "comm.txb"
        &frame = "row 6 centered scroll 1 20 down overlay "
        &where = " comm.txb.consolid "
        &flddisp = " comm.txb.bank label 'Код' format 'x(5)'
                     comm.txb.name label 'Филиал' format 'x(25)'
                   "
        &chkey = "bank"
        &chtype = "string"
        &index  = "bank"
    }
    v-bank = comm.txb.bank.
    
    find first comm.txb where comm.txb.consolid and comm.txb.bank = v-bank no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
        run cclientFind(output v-cif, output v-cifname).
    end.
    else return.

    if connected ("txb") then disconnect "txb".

    create wrk.
    assign wrk.clientId = v-cif
           wrk.bank = v-bank
           wrk.clname = v-cifname
           wrk.groupId = p-groupId.

    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(wrk).
    open query qt for each wrk.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
end.

on "delete-line" of bt in frame ft do:
    if not avail wrk then return.
    /*
    choice = no.
    message "Удаление из группы клиента с кодом " + string(wrk.clientId) + "~n" + trim(wrk.clname) + "~nПродолжить?"
              view-as alert-box question buttons yes-no title "Внимание!" update choice.
    if choice then do:
    */
        bt:set-repositioned-row(bt:focused-row, "always").
        v-rid = ?.
        find first b-wrk where b-wrk.groupId > wrk.groupId no-lock no-error.
        if not avail b-wrk then find last b-wrk where b-wrk.groupId < wrk.groupId no-lock no-error.
        if avail b-wrk then v-rid = rowid(b-wrk).
        delete wrk.
        open query qt for each wrk.
        if v-rid <> ? then reposition qt to rowid v-rid no-error.
        bt:refresh().
    /*
    end.
    */
end.

on choose of btn1 in frame ft do:
    do transaction:
        for each cclient where cclient.groupId = p-groupId exclusive-lock:
            delete cclient.
        end.
        for each wrk no-lock:
            create cclient.
            assign cclient.groupId = wrk.groupId
                   cclient.bank = wrk.bank
                   cclient.clientId = wrk.clientId.
        end.
    end.
end.

on "end-error" of bt in frame ft do:
    hide frame ft.
    pause 0.
    return.
end.

open query qt for each wrk.
enable bt btn1 with frame ft.

wait-for window-close of current-window or choose of btn1 in frame ft.
hide frame ft.
pause 0.
