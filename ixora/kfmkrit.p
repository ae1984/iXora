/* kfmkrit.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Настройка критериев операции, подлежащей фин. мониторингу
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
        30/03/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

define query qt for kfmkrit.
def var v-rid as rowid.
def var choice as logi no-undo.

define browse bt query qt
       displ kfmkrit.showOrder label "N" format ">>>>9"
             kfmkrit.dataCode label "Код" format "x(8)"
             kfmkrit.dataName label "Наименование" format "x(32)"
             kfmkrit.dataType label "Т" format "x"
             kfmkrit.dataTypeEx label "Тe" format "xx"
             kfmkrit.priz label "П" format "9"
             kfmkrit.dataSpr label "Справ" format "x(10)"
             kfmkrit.valProc label "ПроцВал" format "x(16)"
             with 29 down overlay no-label title " Признаки операции ".

define frame ft bt help "<Enter>-Редакт. <Ins>-Новый <F4>-Выход" with width 110 row 3 overlay no-box.

def buffer b-kfmkrit for kfmkrit.

on "enter" of bt in frame ft do:
    if avail kfmkrit then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        find first b-kfmkrit where rowid(b-kfmkrit) = rowid(kfmkrit) exclusive-lock no-error.
        if avail b-kfmkrit then do:
            v-rid = rowid(b-kfmkrit).
            displ b-kfmkrit.showOrder format ">>>>9"
                  b-kfmkrit.dataCode format "x(8)"
                  b-kfmkrit.dataName format "x(32)"
                  b-kfmkrit.dataType format "x"
                  b-kfmkrit.dataTypeEx format "xx"
                  b-kfmkrit.priz format "9"
                  b-kfmkrit.dataSpr format "x(10)"
                  b-kfmkrit.valProc format "x(16)"
            with width 82 no-label overlay row bt:focused-row + 5 column 4 no-box frame fr2.

            update b-kfmkrit.showOrder b-kfmkrit.dataCode b-kfmkrit.dataName b-kfmkrit.dataType b-kfmkrit.dataTypeEx b-kfmkrit.priz b-kfmkrit.dataSpr b-kfmkrit.valProc with frame fr2.

            release b-kfmkrit.

            open query qt for each kfmkrit no-lock.
            reposition qt to rowid v-rid no-error.

            find first b-kfmkrit no-lock no-error.
            if avail b-kfmkrit then bt:refresh().
        end.
    end.
end.

on "insert-mode" of bt in frame ft do:
    create kfmkrit.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(kfmkrit).
    open query qt for each kfmkrit no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "enter" to bt in frame ft.
end.

/* [Delete] - остановить процесс */
on "delete-character" of bt in frame ft do:
    if avail kfmkrit then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        find first b-kfmkrit where rowid(b-kfmkrit) = rowid(kfmkrit) no-lock no-error.
        if avail b-kfmkrit then do:
            v-rid = rowid(b-kfmkrit).
            find next b-kfmkrit no-lock no-error.
            if avail b-kfmkrit then v-rid = rowid(b-kfmkrit).
            else do:
                find first b-kfmkrit where rowid(b-kfmkrit) = rowid(kfmkrit) no-lock no-error.
                find prev b-kfmkrit no-lock no-error.
                if avail b-kfmkrit then v-rid = rowid(b-kfmkrit).
            end.
        end.

        choice = no.
        message "Вы уверены, что хотите удалить выбранную запись?" view-as alert-box question buttons yes-no title "Удаление" update choice.
        if choice then do:
            find first b-kfmkrit where rowid(b-kfmkrit) = rowid(kfmkrit) exclusive-lock no-error.
            if avail b-kfmkrit then delete b-kfmkrit.
        end.

        open query qt for each kfmkrit no-lock.
        reposition qt to rowid v-rid no-error.

        find first b-kfmkrit no-lock no-error.
        if avail b-kfmkrit then bt:refresh().
    end.
end.

open query qt for each kfmkrit no-lock.
enable bt with frame ft.

wait-for window-close of current-window.
pause 0.

