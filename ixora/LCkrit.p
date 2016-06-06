/* LCkrit.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Настройка критериев
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
        09/09/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        24/11/2010 galina - автоматическое присвоение номера новому критерию
*/

{mainhead.i}

define query qt for LCkrit.
def var v-rid as rowid.
def var choice as logi no-undo.

define browse bt query qt
       displ LCkrit.showOrder label "N" format ">>>>9"
             LCkrit.dataCode label "Код" format "x(8)"
             LCkrit.dataName label "Наименование" format "x(40)"
             LCkrit.dataType label "Т" format "x"
             LCkrit.priz label "П" format "x(1)"
             LCkrit.LCtype label "E/I" format "x(1)"
             LCkrit.dataSpr label "Справ" format "x(10)"
             LCkrit.valProc label "ПроцВал" format "x(16)"
             with 29 down overlay no-label title " Признаки операции ".

define frame ft bt help "<Enter>-Редакт. <Ins>-Новый <F4>-Выход" with width 118 row 3 overlay no-box.

def buffer b-LCkrit for LCkrit.

on "enter" of bt in frame ft do:
    if avail LCkrit then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        find first b-LCkrit where rowid(b-LCkrit) = rowid(LCkrit) exclusive-lock no-error.
        if avail b-LCkrit then do:
            v-rid = rowid(b-LCkrit).
            displ b-LCkrit.showOrder format ">>>>9"
                  b-LCkrit.dataCode format "x(8)"
                  b-LCkrit.dataName format "x(40)"
                  b-LCkrit.dataType format "x"
                  b-LCkrit.priz format "x(1)"
                  b-LCkrit.LCtype format "x(1)"
                  b-LCkrit.dataSpr format "x(10)"
                  b-LCkrit.valProc format "x(16)"
            with width 100 no-label overlay row bt:focused-row + 5 column 4 no-box frame fr2.

            update b-LCkrit.showOrder b-LCkrit.dataCode b-LCkrit.dataName b-LCkrit.dataType b-LCkrit.priz b-LCkrit.LCtype b-LCkrit.dataSpr b-LCkrit.valProc with frame fr2.

            release b-LCkrit.

            open query qt for each LCkrit no-lock.
            reposition qt to rowid v-rid no-error.

            find first b-LCkrit no-lock no-error.
            if avail b-LCkrit then bt:refresh().
        end.
    end.
end.

on "insert-mode" of bt in frame ft do:
    find last b-LCkrit no-lock no-error.
    create LCkrit.
    if avail b-LCkrit then LCkrit.showOrder = b-LCkrit.showOrder + 1.
    else LCkrit.showOrder = 1.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(LCkrit).
    open query qt for each LCkrit no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "enter" to bt in frame ft.
end.

/* [Delete] - остановить процесс */
on "delete-character" of bt in frame ft do:
    if avail LCkrit then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        find first b-LCkrit where rowid(b-LCkrit) = rowid(LCkrit) no-lock no-error.
        if avail b-LCkrit then do:
            v-rid = rowid(b-LCkrit).
            find next b-LCkrit no-lock no-error.
            if avail b-LCkrit then v-rid = rowid(b-LCkrit).
            else do:
                find first b-LCkrit where rowid(b-LCkrit) = rowid(LCkrit) no-lock no-error.
                find prev b-LCkrit no-lock no-error.
                if avail b-LCkrit then v-rid = rowid(b-LCkrit).
            end.
        end.

        choice = no.
        message "Вы уверены, что хотите удалить выбранную запись?" view-as alert-box question buttons yes-no title "Удаление" update choice.
        if choice then do:
            find first b-LCkrit where rowid(b-LCkrit) = rowid(LCkrit) exclusive-lock no-error.
            if avail b-LCkrit then delete b-LCkrit.
        end.

        open query qt for each LCkrit no-lock.
        reposition qt to rowid v-rid no-error.

        find first b-LCkrit no-lock no-error.
        if avail b-LCkrit then bt:refresh().
    end.
end.

open query qt for each LCkrit no-lock.
enable bt with frame ft.

wait-for window-close of current-window.
pause 0.




