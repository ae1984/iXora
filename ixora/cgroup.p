/* cgroup.p
 * MODULE
        Риски
 * DESCRIPTION
        Группы клиентов
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

{mainhead.i}

define query qt for cgroup.

define buffer b-cgroup for cgroup.
def var v-rid as rowid.

def var v-code as integer no-undo.
def var choice as logi no-undo.

define browse bt query qt
       displ cgroup.groupId label "Код" format ">>>>9"
             cgroup.groupDes label "Наименование" format "x(98)"
             with 28 down row 3 overlay no-label title " Редактирование списка групп ".

define frame ft bt help "<Enter>-Изм <Ins>-Нов <Ctrl+D>-Удалить <TAB>-Клиенты <F4>-Выход" with width 110 row 3 overlay no-label no-box.

on "return" of bt in frame ft do:
    if not avail cgroup then return.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(cgroup).
    
    find first b-cgroup where rowid(b-cgroup) = rowid(cgroup) exclusive-lock.
    displ b-cgroup.groupId format ">>>>9"
          b-cgroup.groupDes format "x(500)" view-as fill-in size 98 by 1
    with width 106 no-label overlay row bt:focused-row + 5 column 4 no-box frame fr2.
    
    update b-cgroup.groupDes with frame fr2.
    
    open query qt for each cgroup no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    
end. /* on "return" of bt */

on "insert-mode" of bt in frame ft do:
    v-code = 1.
    find last b-cgroup no-lock no-error.
    if avail b-cgroup then v-code = b-cgroup.groupId + 1.
    create cgroup.
    cgroup.groupId = v-code.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(cgroup).
    open query qt for each cgroup no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "return" to bt in frame ft.
end.

on "delete-line" of bt in frame ft do:
    if not avail cgroup then return.
    choice = no.
    message "Запрос на удаление группы с кодом " + string(cgroup.groupId) + "~n" + trim(cgroup.groupDes) + "~nПродолжить?"
              view-as alert-box question buttons yes-no title "Внимание!" update choice.
    if choice then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        v-rid = ?.
        find first b-cgroup where b-cgroup.groupId > cgroup.groupId no-lock no-error.
        if not avail b-cgroup then find last b-cgroup where b-cgroup.groupId < cgroup.groupId no-lock no-error.
        if avail b-cgroup then v-rid = rowid(b-cgroup).
        do transaction:
            for each cclient where cclient.groupId = cgroup.groupId exclusive-lock:
                delete cclient.
            end.
            find first b-cgroup where rowid(b-cgroup) = rowid(cgroup) exclusive-lock.
            delete b-cgroup.
        end.
        open query qt for each cgroup no-lock.
        if v-rid <> ? then reposition qt to rowid v-rid no-error.
        find first b-cgroup no-lock no-error.
        if avail b-cgroup then bt:refresh().
    end.
end.

on "tab" of bt in frame ft do:
    if not avail cgroup then return.
    hide frame ft.
    run cclient(cgroup.groupId).
    view frame ft.
end.

open query qt for each cgroup no-lock.
enable bt with frame ft.

wait-for window-close of current-window.
pause 0.
