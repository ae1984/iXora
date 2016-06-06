/* sel_mt.p
 * Модуль
     BASE
 * Назначение
     вывод вертикального меню для выбора,
     выбранное значение возвращается как параметр - в отличие от sel.p, где идет return-value
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
       14.01.2011 aigul
 * CHANGES
       26.10.2011 aigul - подправила удаление *
       29.06.2012 damir - для типа документа "04" k = 13.
       */


def input  parameter ttl      as char.
def input  parameter str      as char.
def input  parameter v-cont   as int.
def input  parameter v-psnum  as char.
def output parameter selitem  as char.
def output parameter delitem  as char.

def shared var v-chk as logi initial no.

define temp-table menu
    field num as int
    field num1 as int
    field itm as char
    field choice as char.

def var i   as inte init 0.
def var dlm as char init "|".
def var k   as inte.

find first vcps where vcps.contract = v-cont and vcps.dnnum = v-psnum no-lock no-error.
if avail vcps then do:
    if vcps.dntype = "19" then k = 18.
    else if vcps.dntype = "04" then k = 13.
end.

v-chk = no.
do i = 1 to /*num-entries(str, dlm)*/ k:
    create menu.
    assign menu.num = i.
    menu.num1 = i + 10.
    menu.itm = entry(i, str, dlm).
    find first vcps where vcps.contract = v-cont and vcps.dnnum = v-psnum no-lock no-error.
    if avail vcps then do:
        if lookup(string(menu.num1),vcps.info[3]) > 0 then do:
           menu.choice = "*".
           v-chk = yes.
        end.
    end.
    else menu.choice = "".
end.

def query q1 for menu.

def browse b1
    query q1 no-lock
    display
        menu.num label 'Код' format "99"
        menu.itm label 'Наименование' format "x(40)"
        menu.choice label 'Выбор'
        with 8 down width 70 title ttl.

def frame fr1
    b1
    with no-labels centered overlay width 75 row 8 view-as dialog-box.

on "insert" of b1 in frame fr1 do:
     v-chk = yes.
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
    for each menu where menu.choice = "" no-lock:
        if delitem <> "" then delitem = delitem + ','.
        delitem = delitem + string(menu.num).
    end.
    apply "endkey" to frame fr1.
end.
open query q1 for each menu.

if num-results("q1") = 0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Ошибка".
    return.
end.

b1:title = ttl.
b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.




