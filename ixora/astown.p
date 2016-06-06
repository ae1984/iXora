/* astown.p
 * MODULE
        ОС
 * DESCRIPTION
        история закрепления ОС за сотрудником
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
 * BASES
        BANK COMM
 * AUTHOR
        24/05/2013 Luiza - ТЗ 1842
 * CHANGES
            19/06/2013 Luiza - ТЗ 1902
            20/06/2013 Luiza - перекомпиляци
*/


def temp-table tmp
    field rid as rowid
    field whn as date format "99/99/9999"
    field own  as char
    field fio  as char
    field who as char
    index idx_tmp is primary whn.


def input parameter v-ast like ast.ast.
def query q1 for tmp.

def browse b1 query q1 displ
                             tmp.whn label "Дата"
                             tmp.own label "id сотруд" format "x(8)"
                             tmp.fio label "    Закреплен за ... " format "x(30)"
                             tmp.who format "x(8)" label "Исполнитель"
                       with row 1 centered 7 down  overlay title "История закрепления ОС за сотрудниками ".
def frame f1 b1 with no-label no-box column 40 row 5 width 90 overlay.

for each astown where astown.ast = v-ast no-lock:
    create tmp.
    tmp.rid = ROWID (astown).
    tmp.whn = astown.whn.
    tmp.own = astown.own.
    tmp.who = astown.who.
    find first ofc where ofc.ofc = astown.own no-lock no-error.
    if available ofc then tmp.fio = ofc.name.
    else do:
        find first astofc where astofc.id = astown.own no-lock no-error.
        if available astofc then tmp.fio = astofc.fio.
   end.
end.

on endkey of browse b1 do:
   hide frame f1.
   return.
end.

on endkey of frame f1 do:
   hide frame f1.
   return.
end.

open query q1 for each tmp.
enable all with frame f1.
wait-for window-close of current-window.
