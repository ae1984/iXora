/* lncomupdh.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Редактирование комиссии для бывших сотрудников
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
        30/09/2013 galina - ТЗ1337
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def shared var s-lon like lnscs.lon.
define query qts for lnscs.
define buffer b-lnscs for lnscs.
def var v-rid as rowid.

define browse bts query qts
    displ lnscs.stdat label "Дата" format "99/99/9999"
          lnscs.stval label "Сумма" format ">>>,>>>,>>9.99"
          with centered 30 down overlay no-label title " Редактирование графика комиссии ".


define frame fts bts help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl+D>-удаление, <F4>-Выход" with width 110 row 3 overlay no-box.

on "return" of bts in frame fts do:

    bts:set-repositioned-row(bts:focused-row, "always").
    v-rid = rowid(lnscs).

    find first b-lnscs where b-lnscs.lon = lnscs.lon and b-lnscs.stdat = lnscs.stdat  and b-lnscs.sch = yes exclusive-lock.
    displ b-lnscs.stdat format "99/99/9999"
          b-lnscs.stval format ">>>,>>>,>>9.99"
    with width 29 no-label overlay row bts:focused-row + 5 column 4 no-box frame fr2.

    update b-lnscs.stdat b-lnscs.stval with frame fr2.

    open query qts for each lnscs where lnscs.lon = s-lon and lnscs.sch = yes  no-lock.
    reposition qts to rowid v-rid no-error.
    bts:refresh().

end. /* on "return" of bt */

on "insert-mode" of bts in frame fts do:
    find last b-lnscs where b-lnscs.lon = s-lon and b-lnscs.sch = yes no-lock no-error.
    create lnscs.
    lnscs.lon = s-lon.
    lnscs.sch = yes.
    lnscs.stdat = if avail b-lnscs then b-lnscs.stdat + 1 else g-today.
    bts:set-repositioned-row(bts:focused-row, "always").
    v-rid = rowid(lnscs).
    open query qts for each lnscs where lnscs.lon = s-lon and lnscs.sch = yes no-lock.
    reposition qts to rowid v-rid no-error.
    bts:refresh().
    apply "return" to bts in frame fts.
end.

on "delete-line" of bts in frame fts do:
    bts:set-repositioned-row(bts:focused-row, "always").
    find first b-lnscs where b-lnscs.lon = lnscs.lon and b-lnscs.stdat = lnscs.stdat and b-lnscs.sch = yes exclusive-lock.
    delete b-lnscs.
    open query qts for each lnscs where lnscs.lon = s-lon  and lnscs.sch = yes no-lock.
    bts:refresh().
end.

open query qts for each lnscs where lnscs.lon = s-lon and lnscs.sch = yes no-lock.
enable all with frame fts.
wait-for window-close of current-window.
pause 0.



