/* sel_mt2.p
 * MODULE
        Название модуля
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
        Пункт меню
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
*/
def input parameter ttl as char.
def input parameter str as char.
def input parameter doc as inte.
def input parameter v-s as inte.
def output parameter selitem as char.

def shared temp-table t-chg no-undo
    field k as inte
    field nam as char
    field cod as char
index idx1 is primary k ascending.

define temp-table menu
    field num as int
    field itm as char
    field choice as char.

def var i as int init 0.
def var dlm as char init "|".

find first vcdocs where vcdocs.docs = doc no-lock no-error.
do i = 1 to v-s:
    create menu.
    assign menu.num = i.
    menu.itm = entry(i, str, dlm).

    find t-chg where t-chg.k = i no-lock no-error.
    if avail vcdocs and avail t-chg then do:
        if lookup(t-chg.cod,vcdocs.info2[1]) > 0 then menu.choice = "*".
    end.
    else menu.choice = "".
end.

def query q1 for menu.

def browse b1
    query q1 no-lock
    display
        menu.num label 'Код' format "99"
        menu.itm label 'Наименование' format "x(60)"
        menu.choice label 'Выбор'
        with 8 down width 75 title ttl.

def frame fr1
    b1
with no-labels centered overlay width 77 row 8 view-as dialog-box.

on "insert" of b1 in frame fr1 do:
     update menu.choice = "*".
     displ menu.choice with browse b1.
end.
on "delete" of b1 in frame fr1 do:
     update menu.choice = "".
     displ menu.choice with browse b1.
end.

on return of b1 in frame fr1 do:
    for each menu where menu.choice = "*" no-lock:
        if selitem <> "" then selitem = selitem + ','.
        selitem = selitem + string(menu.num).
    end.
    apply "endkey" to frame fr1.
end.
open query q1 for each menu no-lock.

if num-results("q1") = 0 then
do:
    MESSAGE "Записи не найдены." VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Ошибка".
    return.
end.

b1:title = ttl.
b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.