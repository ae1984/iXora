/* valspr.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Редактирование справочника показателей для управленческой отчетности
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
        04/05/2008 madiyar
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{mainhead.i}

define query qt for valspr.

define buffer b-valspr for valspr.
def var v-rid as rowid.

def var v-code as integer no-undo.
def var v-sort as integer no-undo.
def var choice as logi no-undo.

define browse bt query qt
       displ valspr.code label "Код" format ">>>9"
             valspr.sort label "Сорт" format ">>>>9"
             valspr.sub label "Грп" format "x(3)"
             valspr.type label "Тип" format "x(5)"
             valspr.des label "Название" format "x(61)"
             valspr.proc label "Проц" format "x(16)"
             valspr.active label "Акт?" format "да/нет"
             with 31 down overlay no-label title " Редактирование справочника признаков ".

define frame ft bt help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl+D>-удаление, <F4>-Выход" with width 110 row 3 overlay no-label no-box.

on "return" of bt in frame ft do:

    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(valspr).

    find first b-valspr where b-valspr.code = valspr.code exclusive-lock.
    displ b-valspr.code format ">>>9"
          b-valspr.sort format ">>>>9"
          b-valspr.sub format "x(3)"
          b-valspr.type format "x(5)"
          b-valspr.des format "x(500)" view-as fill-in size 61 by 1
          b-valspr.proc format "x(16)"
          b-valspr.active format "да/нет"
    with width 110 no-label overlay row bt:focused-row + 5 column 4 no-box frame fr2.

    update b-valspr.sort b-valspr.sub b-valspr.type b-valspr.des b-valspr.proc b-valspr.active with frame fr2.

    open query qt for each valspr no-lock use-index sort.
    reposition qt to rowid v-rid no-error.
    bt:refresh().

end. /* on "return" of bt */

on "insert-mode" of bt in frame ft do:
    v-code = 1. v-sort = 10.
    find last b-valspr no-lock no-error.
    if avail b-valspr then v-code = b-valspr.code + 1.
    find last b-valspr use-index sort no-lock no-error.
    if avail b-valspr then v-sort = b-valspr.sort + 10.
    create valspr.
    valspr.code = v-code.
    valspr.sort = v-sort.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(valspr).
    open query qt for each valspr no-lock use-index sort.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "return" to bt in frame ft.
end.

on "delete-line" of bt in frame ft do:
    choice = no.
    message "Запрос на удаление признака с кодом " + string(valspr.code) + "~n" + trim(valspr.des) + "~nПродолжить?"
              view-as alert-box question buttons yes-no title "Внимание!" update choice.
    if choice then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        v-rid = ?.
        find first b-valspr where b-valspr.sort >= valspr.sort and b-valspr.code <> valspr.code use-index sort no-lock no-error.
        if not avail b-valspr then find last b-valspr where b-valspr.sort <= valspr.sort and b-valspr.code <> valspr.code use-index sort no-lock no-error.
        if avail b-valspr then v-rid = rowid(b-valspr).
        find first b-valspr where b-valspr.code = valspr.code exclusive-lock.
        delete b-valspr.

        open query qt for each valspr no-lock use-index sort.
        if v-rid <> ? then reposition qt to rowid v-rid no-error.
        bt:refresh().
    end.
end.

open query qt for each valspr no-lock use-index sort.
enable bt with frame ft.

wait-for window-close of current-window.
pause 0.
