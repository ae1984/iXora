/* clpens.p
 * MODULE
        Платежи
 * DESCRIPTION
        Исправление ошибок в пенсионных платежах
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
        15/09/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{mainhead.i}

define query qt for t-102.
define buffer b-t102 for t-102.
def var v-rid as rowid.

define browse bt query qt
    displ t-102.date label "Дата" format "99/99/99"
          t-102.rem label "RMZ" format "x(10)"
          t-102.rbank label "Фил." format "x(5)"
          t-102.bn[1] label "Получатель" format "x(51)"
          t-102.racc label "Счет" format "x(20)"
          t-102.ff label "Пров?" format "да/нет"
          with centered 31 down overlay no-label title " Некорректные платежи ".

def var dt1 as date no-undo.
def var dt2 as date no-undo.
dt1 = g-today.
dt2 = g-today.
update dt1 label ' Период с ' format '99/99/9999'
       dt2 label ' по ' format '99/99/9999' skip
       with side-labels row 13 centered frame dat.

define frame ft bt help "<Enter>-Редактирование, <F4>-Выход" with width 110 row 3 overlay no-box.

on "return" of bt in frame ft do:

    bt:set-repositioned-row(bt:focused-row, "always").
    find first b-t102 where rowid(b-t102) = rowid(t-102) no-lock no-error.
    if not avail b-t102 then do:
        message "Record not found!" view-as alert-box error.
        return.
    end.
    else do:
        v-rid = rowid(b-t102).
        find next b-t102 no-lock no-error.
        if avail b-t102 then v-rid = rowid(b-t102).
        else do:
            find first b-t102 where rowid(b-t102) = rowid(t-102) no-lock no-error.
            find prev b-t102 no-lock no-error.
            if avail b-t102 then v-rid = rowid(b-t102).
        end.
    end.

    find first b-t102 where rowid(b-t102) = rowid(t-102) exclusive-lock.
    displ b-t102.date format "99/99/99"
          b-t102.rem format "x(10)"
          b-t102.rbank format "x(5)"
          b-t102.bn[1] format "x(51)"
          b-t102.racc format "x(20)"
          b-t102.ff format "да/нет"
    with width 106 no-label overlay row bt:focused-row + 5 column 4 no-box frame fr2.

    update b-t102.racc b-t102.ff with frame fr2.

    open query qt for each t-102 where t-102.racc matches "*/*" and t-102.date >= dt1 and t-102.date <= dt2 no-lock.
    reposition qt to rowid v-rid no-error.
    find first b-t102 where b-t102.racc matches "*/*" and b-t102.date >= dt1 and b-t102.date <= dt2 no-lock no-error.
    if avail b-t102 then bt:refresh().

end. /* on "return" of bt */

open query qt for each t-102 where t-102.racc matches "*/*" and t-102.date >= dt1 and t-102.date <= dt2 no-lock.
enable all with frame ft.
wait-for window-close of current-window.
pause 0.

