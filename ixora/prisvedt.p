/* prisvedt.p
 * MODULE
        Особые отношения
 * DESCRIPTION
        Редактирование базы
 * BASES
        BANK
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
        30/04/2008 alex
 * CHANGES
        29/05/2008 alex
        05/10/2011 lyubov - Сортировка реестра производится по наименованию лиц, связанных с банком особыми отношениями по алфавиту.
        02/01/2013 madiyar - в поле prisv.rnn теперь ИИН/БИН
*/

{mainhead.i}

define query qp for prisv, codfr.
def var v-rid as rowid.
def var v-oldvalue as char no-undo.
def var v-iin as char.
def var v-name as char.
def var v-specrel as char.
def var v-ops as char.

define browse ps query qp
    display prisv.rnn label "ИИН/БИН" format "x(12)"
            prisv.name label "Наименование/ФИО" format "x(30)"
            prisv.specrel label "Код" format "x(2)"
            codfr.name[1] label "Отношения" format "x(57)"
    with 29 down centered width 110 title "Редактирование анкеты".

define frame ft ps help "<Enter>-Ред., <Insert>-Добавить, <Ctrl+d>-Удалить, <F4>-Выход" with width 110 row 4 overlay no-label no-box.

/*************************************************************************************************************************************************************************/

define frame fed
     v-iin label     "ИИН/БИН........." format "x(12)" skip
     v-name label    "Наименование/ФИО" format "x(200)" view-as fill-in size 50 by 1 skip
     v-specrel label "Код............." format "x(2)"
with side-labels row 12 overlay centered.

on "return" of ps in frame ft do:
    /*find current prisv no-error.*/
        if avail(prisv) then do:
            ps:set-repositioned-row(ps:focused-row, "always").
            v-rid = rowid(prisv).

            v-iin = prisv.rnn.
            v-name = prisv.name.
            v-specrel = prisv.specrel.

            update v-iin v-name v-specrel with frame fed.

            if (v-iin ne prisv.rnn) or (v-name ne prisv.name) or (v-specrel ne prisv.specrel) then do:
                        find current prisv exclusive-lock.
                        prisv.rnn = v-iin.
                        prisv.name = v-name.
                        prisv.specrel = v-specrel.
                        prisv.rdt = g-today.
                        prisv.rwho = g-ofc.

                        create svhist.
                            assign svhist.rwho = g-ofc
                                svhist.rdt = today
                                svhist.rtm = time
                                svhist.toprt = "edt".
                        find current prisv no-lock.
            end.

            hide frame fed.

            open query qp
            for each prisv no-lock,
                each codfr where (codfr.codfr eq "affil") and (codfr.code eq prisv.specrel) no-lock.

            reposition qp to rowid v-rid no-error.
            ps:refresh().
        end.
end.

on help of v-specrel in frame fed do:
    {itemlist.i
        &file = "codfr"
        &frame = "row 6 width 110 centered 28 down overlay "
        &where = " codfr.codfr = 'affil' "
        &flddisp = " codfr.code label 'КОД' format 'x(2)' codfr.name[1] label 'ЗНАЧЕНИЕ' format 'x(104)' "
        &chkey = "code"
        &chtype = "string"
        &index  = "cdco_idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-specrel = codfr.code.
    displ v-specrel with frame fed.
end.

/*************************************************************************************************************************************************************************/

on "insert" of ps in frame ft do:

    ps:set-repositioned-row(ps:focused-row, "always").
    v-rid = rowid(prisv).

    v-iin = "".
    v-name = "".
    v-specrel = "".

    repeat on endkey undo,return:

        update v-iin v-name v-specrel help "<F2>-Вызов справочника, <F4>-Выход" with frame fed.

        if v-iin eq "" then message "не введен РНН" view-as alert-box buttons ok.
        else
        if v-name eq "" then message "не введено наименование/ФИО" view-as alert-box buttons ok.
        else
        if v-specrel eq "" then message "нет признака связи" view-as alert-box buttons ok.
        else leave.
    end.

    if trim(v-iin + v-name + v-specrel) ne "" then do:
        create prisv.
            assign prisv.rnn = v-iin
                prisv.name = v-name
                prisv.specrel = v-specrel
                prisv.rdt = today
                prisv.rwho = g-ofc.
        create svhist.
            assign svhist.rwho = g-ofc
                svhist.rdt = today
                svhist.rtm = time
                svhist.toprt = "add"
                svhist.oprt = prisv.rnn + "|" + prisv.name.

        hide frame fed.

        open query qp
        for each prisv no-lock,
            each codfr where (codfr.codfr eq "affil") and (codfr.code eq prisv.specrel) no-lock.

        reposition qp to rowid v-rid no-error.
        ps:refresh().
    end.

end.

/*************************************************************************************************************************************************************************/

on "delete-line" of ps in frame ft do:
    find current prisv no-error.
        if avail(prisv) then do:
            def var choice as logical.
            choice = yes.
            message "Удалить запись?"
                view-as alert-box question buttons yes-no
                    title "" update choice.

            find current prisv exclusive-lock.
                if choice = yes then do:
                create svhist.
                    assign svhist.rwho = g-ofc
                        svhist.rdt = today
                        svhist.rtm = time
                        svhist.toprt = "del"
                        svhist.oprt = prisv.rnn + "|" + prisv.name.
                delete prisv.
                end.

            ps:refresh().
        end.
end.

/*************************************************************************************************************************************************************************/

open query qp
for each prisv no-lock use-index name,
    each codfr where (codfr.codfr eq "affil") and (codfr.code eq prisv.specrel) no-lock.
enable ps with frame ft.
apply "value-changed" to browse ps.

wait-for window-close of current-window.
pause 0.