/* cifnoacc.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.1.10
 * AUTHOR
        29/05/2008 alex
 * BASES
        BANK
 * CHANGES
*/

{mainhead.i}

define new shared temp-table temp-ofc no-undo
    field id like ofc.ofc
    field name like ofc.name.
define variable i as integer.
define variable b as char.
define variable v-sysl as logical.
def var v-rid as rowid.

find first sysc where sysc.sysc eq "idnoacc" no-lock no-error.
    if not avail(sysc) then do:
        create sysc.
        assign sysc.sysc = "idnoacc"
               sysc.des = "Работа без акцепта"
               sysc.loval = false.
    end.
    else b = sysc.chval.

do i = 1 to num-entries(b, ","):
    find first ofc where ofc.ofc eq entry(i, b, ",") no-error.
    if avail(ofc) then do:
        create temp-ofc.
        assign temp-ofc.id = ofc.ofc
               temp-ofc.name = ofc.name.
    end.
end.

define query qp for temp-ofc.

define browse ps query qp
    display temp-ofc.id label "id" format "x(8)"
            temp-ofc.name label "Наименование/ФИО" format "x(45)"
    with 15 down centered width 60 title "Редактирование списка".

define frame ft ps help "<Insert>-добавить, <Ctrl+D>-удалить, <F4>-Выход" with centered width 110 row 4 overlay no-label no-box.
define button accept.
define button edit.

define frame m
    accept label "Работа без акцепта" skip
    edit label "Редактировать список"
with width 40 row 12 overlay centered.

on choose of accept in frame m do:
    find first sysc where sysc.sysc eq "idnoacc" no-lock no-error.
        if avail(sysc) then v-sysl = sysc.loval.

    do transaction:
    v-sysl = not (v-sysl).
    find first sysc where sysc.sysc eq "idnoacc" exclusive-lock no-error.
    if avail(sysc) then sysc.loval = v-sysl.
    end.

    if v-sysl then
        message " Включена работа без акцепта" view-as alert-box title "".
        else
        message " Работа без акцепта отключена" view-as alert-box title "".
end.

on choose of edit in frame m do:
    hide frame m.
    open query qp for each temp-ofc no-lock.
    enable ps with frame ft.
    apply "value-changed" to browse ps.

    on "delete-line" of ps in frame ft do:
        find current temp-ofc no-error.
            if avail(temp-ofc) then do:
                def var choice as logical.
                choice = yes.
                message "Удалить запись?"
                    view-as alert-box question buttons yes-no
                        title "" update choice.
                delete temp-ofc.
            end.
            b = "".
            for each temp-ofc no-lock:
                if b eq "" then b = b + temp-ofc.id.
                else b = b + "," + temp-ofc.id.
            end.
            find first sysc where sysc.sysc eq "idnoacc".
                if avail(sysc) then sysc.chval = b.
            ps:refresh().
    end.

    define variable v-id as char.
    define variable v-name as char.

    define frame fed
        v-id label     "id" format "x(8)"
    with width 20 side-labels row 12 overlay centered.

    on "insert" of ps in frame ft do:
        ps:set-repositioned-row(ps:focused-row, "always").
        v-rid = rowid(temp-ofc).

            update v-id help "<F2>-Вызов справочника, <F4>-Выход" with frame fed.

            find first ofc where ofc.ofc = v-id no-error.
            if avail(ofc) then v-name = ofc.name.
                find first temp-ofc where temp-ofc.id = v-id no-error.
                    if avail(temp-ofc) then message "данный id уже существует" view-as alert-box.
                    else do:
                        create temp-ofc.
                            assign temp-ofc.id = v-id
                                   temp-ofc.name = v-name.
                            b = b + "," + v-id.
                        end.
            hide frame fed.

            open query qp for each temp-ofc no-lock.
            reposition qp to rowid v-rid no-error.
            ps:refresh().

        find first sysc where sysc.sysc = "idnoacc" no-error.
        if avail(sysc) then sysc.chval = b.
    end.

    on help of v-id in frame fed do:
        {itemlist.i
            &file = "ofc"
            &frame = "row 6 centered 28 down overlay width 60"
            &where = " ofc.ofc ne '' "
            &flddisp = " ofc.ofc label 'id' format 'x(8)' ofc.name label 'Ф.И.О.' format 'x(35)' "
            &chkey = "ofc"
            &chtype = "string"
            &index  = "ofc"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        v-id = ofc.ofc.
        displ v-id with frame fed.
    end.

    wait-for window-close of current-window.
    pause 0.
end.
enable accept edit with centered frame m.
wait-for window-close of current-window.