/*lnmko.p
 * MODULE

 * DESCRIPTION
     Редактирование справочника оценочной стоимости кредитов МКО
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
    07/10/2008 galina
 * BASES
        BANK
 * CHANGES
        07/10/2008 galina - добавила поле "Срок"
                          - отключила заполнение поля "срок"
        07/04/2009 madiyar - добавил ФИО
        18/11/2009 madiyar - выводим только ненулевых; быстрый поиск нужного клиента
*/

{mainhead.i}

define query qt for codfr.

define buffer b-codfr for codfr.
def var v-rid as rowid.
def var v-summ as decimal.
def var partFIO as char no-undo.

define browse bt query qt
       displ codfr.code label "Код" format "x(13)"
             codfr.name[1] label "Номер договора" format "x(18)"
             codfr.name[4] label "ФИО" format "x(44)"
             decimal(codfr.name[2]) label "Сумма" format ">>>>>>>>>>>>>>>>>9.99"
             codfr.name[3] label "Срок" format "x(2)"
             with 30 down overlay no-label title " Редактирование справочника оценочной стоимости кредитов МКО".

define frame ft bt help "<Enter>-Изменить, <CTRL+F>-Быстрый поиск по ФИО, <F4>-Выход" with width 110 row 3 overlay no-label no-box.

on "return" of bt in frame ft do:

    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(codfr).

    find first b-codfr where b-codfr.code = codfr.code exclusive-lock.
    displ b-codfr.code format "x(13)"
          b-codfr.name[1] format "x(18)"
          b-codfr.name[4] format "x(44)"
          v-summ format ">>>>>>>>>>>>>>>>>9.99"
          codfr.name[3] format "x(2)"
    with width 106 no-label overlay row bt:focused-row + 5 column 4 no-box frame fr2.
    v-summ = decimal(b-codfr.name[2]).

    update v-summ with frame fr2.
    b-codfr.name[2] = string(v-summ).
    open query qt for each codfr where codfr.codfr = "lnmko" and codfr.code <> "msc" and deci(codfr.name[2]) > 0 no-lock /*break by codfr.name[4]*/.
    reposition qt to rowid v-rid no-error.
    bt:refresh().

    hide frame fr2.

end. /* on "return" of bt */

on "find" of bt in frame ft do:
    update partFIO label "Введите часть ФИО" format "x(20)" with overlay centered row 13 frame frp
    editing:
        readkey.
        apply lastkey.
        if partFIO:screen-value <> '' then do:
            find first b-codfr where codfr.codfr = "lnmko" and codfr.code <> "msc" and deci(codfr.name[2]) > 0 and b-codfr.name[4] matches "*" + partFIO:screen-value + "*" no-lock no-error.
            if avail b-codfr then reposition qt to rowid rowid(b-codfr) no-error.
        end.
    end.
    hide frame frp.
end. /* on "find" of bt */

open query qt for each codfr where codfr.codfr = "lnmko" and codfr.code <> "msc" and deci(codfr.name[2]) > 0 no-lock /*break by codfr.name[4]*/.
enable bt with frame ft.

wait-for window-close of current-window.
pause 0.
