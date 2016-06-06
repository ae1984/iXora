/* sprvizors.p
 * MODULE
        Название модуля - Администратор
 * DESCRIPTION
        Описание - Контролирующие лица
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 10.8.17
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        29.02.2012 damir.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        08.11.2012 damir - убрал команду chmod. Начало выдавать ошибку после перехода на новые сервера.
*/
{global.i}

def var v-accept   as logi format "да/нет".

def sub-menu sub_cre
    menu-item d_ope  label "Просмотр"
    menu-item d_add  label "Добавить пользователя"
    menu-item d_del  label "Удалить пользователя"
    menu-item d_cha  label "Замена файла загрузки"
    menu-item d_exit label "Выход".

def menu u_menu menubar
    sub-menu sub_cre label "Операции по добавлению подписей".

def temp-table t-temp
    field ofcname as char
    field ofc     as char
    field sign    as logi
    field who     as char
    field whn     as date
    field tim     as inte
    field checks  as char
    index indx is primary whn ascending.

def query q_link for ordsignat scrolling.
def query q_link2 for ordsignat,t-temp scrolling.

def browse b_link
    query q_link no-lock displ
    ordsignat.ofcname label "ФИО" format "x(30)"
    ordsignat.ofc     label "Логин" format "x(7)"
    ordsignat.sign    label "Подпись" format "да/нет"
    ordsignat.who     label "Кто добавил" format "x(7)"
    ordsignat.whn     label "Дата добавления" format "99/99/9999"
with 12 down separators no-assign no-hide.

def browse b_link2
    query q_link2 no-lock displ
    ordsignat.ofcname label "ФИО" format "x(30)"
    ordsignat.ofc     label "Логин" format "x(7)"
    ordsignat.sign    label "Подпись" format "да/нет"
    ordsignat.who     label "Кто добавил" format "x(7)"
    ordsignat.whn     label "Дата добавления" format "99/99/9999"
    t-temp.checks     label "Отметить" format "x(6)"
with 12 down separators no-assign no-hide.

def frame openus
    skip(1)
    b_link skip(2)
with side-labels width 105 no-box no-hide.

def frame delus
    skip(1)
    b_link2 skip(2)
    v-accept label "Удалить" format "да/нет" skip(1)
with side-labels width 105 no-box no-hide.

def var v-ofcname  as char.
def var v-ofcid    as char.
def var v-ofcidd   as char.
def var v-ofcidddd as char.
def var v-logi     as logi.
def var v-file     as char.
def var v-path     as char.
def var v-pathdir  as char.
def var v-dcpath   as char.
def var v-res      as char.
def var v-filename as char.

find first pksysc where pksysc.credtype = "6" and pksysc.sysc = "dcpath" no-lock no-error.
if avail pksysc then v-dcpath = pksysc.chval.
def frame podpis
    v-ofcname  label "ФИО сотрудника"     colon 20 format "x(60)" skip
    v-ofcid    label "Логин менеджера"    colon 20 format "x(7)" validate(can-find(ofc where ofc.ofc = v-ofcid no-lock), "Офицер не найден !!!")
    help "Введите ID пользователя !" skip
    v-logi     label "Подпись"            colon 20 format "да/нет" skip(2)
    v-filename label "Введите имя файла"  colon 20 format "x(12)" skip
    v-path     label "Директория файла" colon 20 format "x(80)" help "Файл должен находится на диске C !" skip
with centered row 8 side-labels width 105 overlay.

def frame podpisdel
    v-ofcidd label "Логин менеджера" format "x(7)" help "Нажмите < F2 > для отображения всего списка !" skip
with centered row 8 side-labels width 105 overlay.

def frame podpischa
    v-ofcidddd label "Логин менеджера" format "x(7)" skip
with centered row 8 side-labels width 105 overlay.

function ns_check returns character (input parm as character).
    def var v-str as char no-undo.
    v-str = parm.
    v-str = replace(v-str,"/","\\\\").
    return trim(v-str).
end function.

for each ordsignat no-lock:
    create t-temp.
    assign
    t-temp.ofcname  = ordsignat.ofcname
    t-temp.ofc      = ordsignat.ofc
    t-temp.sign     = ordsignat.sign
    t-temp.who      = ordsignat.who
    t-temp.whn      = ordsignat.whn
    t-temp.tim      = ordsignat.tim.
end.

on "insert" of b_link2 in frame delus do:
    update t-temp.checks = "delete".
    displ t-temp.checks with browse b_link2.
end.

on "delete" of b_link2 in frame delus do:
    update t-temp.checks = "".
    displ t-temp.checks with browse b_link2.
end.

on "return" of b_link2 in frame delus do:
    apply "go" to frame delus.
end.

on "return" of b_link in frame openus do:
    apply "go" to frame openus.
    hide frame openus.
end.

on "end-error" of frame podpis do:
    hide frame podpis.
end.

on "end-error" of frame podpisdel do:
    hide frame podpisdel.
end.

on "end-error" of frame podpischa do:
    hide frame podpischa.
end.

on "end-error" of browse b_link do:
    hide frame openus.
    hide browse b_link.
end.

on "end-error" of browse b_link2 do:
    hide frame delus.
    hide browse b_link2.
end.

on help of frame podpisdel do:
    hide frame podpisdel.
    hide frame delus.
    open query q_link2 for each ordsignat no-lock, each t-temp where t-temp.ofcname = ordsignat.ofcname and
    t-temp.ofc = ordsignat.ofc and t-temp.who = ordsignat.who and t-temp.whn = ordsignat.whn and t-temp.tim = ordsignat.tim no-lock.
    enable b_link2 with frame delus.
    browse b_link2:sensitive = true.
    update b_link2 with frame delus.
    update v-accept with frame delus.
    displ v-accept with frame delus.
    if v-accept = yes then do:
        for each t-temp no-lock, each ordsignat where ordsignat.ofcname = t-temp.ofcname and ordsignat.ofc = t-temp.ofc and
        ordsignat.who = t-temp.who and ordsignat.whn = t-temp.whn and ordsignat.tim = t-temp.tim exclusive-lock.
            if t-temp.checks = "delete" then do:
                delete ordsignat.
            end.
        end.
    end.
    apply "go" to frame delus.
    hide frame podpisdel.
    hide frame delus.
end.

on choose of menu-item d_ope do:
    open query q_link for each ordsignat no-lock.
    enable b_link with frame openus.
    browse b_link:sensitive = true.
    update b_link with frame openus.
end.

on choose of menu-item d_add do:
    hide frame podpis.
    assign v-ofcname = "" v-ofcid = "" v-logi = no.
    update v-ofcname v-ofcid with frame podpis.
    find first ordsignat where ordsignat.ofc = v-ofcid no-lock no-error.
    if avail ordsignat then do:
        message "Пользователь уже добавлен !!!" view-as alert-box.
        hide frame podpis.
        leave.
    end.
    update v-logi with frame podpis.
    do transaction:
        create ordsignat.
        assign
        ordsignat.ofcname = v-ofcname
        ordsignat.ofc     = v-ofcid
        ordsignat.sign    = v-logi
        ordsignat.who     = g-ofc
        ordsignat.whn     = g-today
        ordsignat.tim     = time.
    end.
    message "Название загружаемого файла, должно соответствовать ID пользователя + < order >" view-as alert-box.
    v-pathdir = g-dbdir + v-dcpath.
    assign v-path = "c:/*.jpg".
    update v-filename with frame podpis.
    v-path = replace(v-path,"*",trim(v-filename)).
    update v-path with frame podpis.
    v-path = ns_check(v-path).
    unix silent value("scp " + " Administrator@`askhost`:" + v-path + " " + v-pathdir).
    /*unix silent value("chmod a+rwx " + v-pathdir + v-filename + ".jpg").*/

    hide frame podpis.
end.
on choose of menu-item d_del do:
    hide frame podpisdel.
    update v-ofcidd with frame podpisdel.
    for each ordsignat where ordsignat.ofc = v-ofcidd exclusive-lock:
        delete ordsignat.
    end.
    hide frame podpisdel.
end.

on choose of menu-item d_cha do:
    hide frame podpischa.
    update v-ofcidddd with frame podpischa.
    find first ordsignat where ordsignat.ofc = v-ofcidddd no-lock no-error.
    if avail ordsignat then do:
        assign
        v-ofcname = ordsignat.ofcname
        v-ofcid   = ordsignat.ofc
        v-logi    = ordsignat.sign.
        displ v-ofcname v-ofcid v-logi with frame podpis.
        message "Название загружаемого файла, должно соответствовать ID пользователя + < order >" view-as alert-box.
        v-pathdir = g-dbdir + v-dcpath.
        assign v-path = "c:/*.jpg".
        update v-filename with frame podpis.
        v-path = replace(v-path,"*",trim(v-filename)).
        update v-path with frame podpis.
        v-path = ns_check(v-path).
        unix silent value("scp " + " Administrator@`askhost`:" + v-path + " " + v-pathdir).
        /*unix silent value("chmod a+rwx " + v-pathdir + v-filename + ".jpg").*/
        hide frame podpischa.
        hide frame podpis.
    end.
    else do:
        message "Пользователь не найден !!!" view-as alert-box.
        hide frame podpisdel.
        leave.
    end.
end.

on choose of menu-item d_exit do:
    return.
end.

assign current-window:menubar = menu u_menu:handle.
wait-for choose of menu-item d_exit.












