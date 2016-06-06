/* sel4.p
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        copy sel2.p - небольшие изменения.
*/

def input parameter ttl as char.
def input parameter str as char.
def output parameter selitem as char init "".


define temp-table menu
    field num as char
    field itm as char.

def var i as int init 0.
def var dlm as char init "|".

do i = 1 to num-entries(str, dlm):
    create menu.
    assign
    menu.num = entry(1, trim(entry(i, str, dlm)),"")
    menu.itm = entry(i, str, dlm).
end.

def query q1 for menu.

def browse b1
    query q1 no-lock
    display
        menu.itm label ' ' format "x(40)"
        with 8 down title ttl.

def frame fr1
    b1
    with no-labels centered overlay row 8 view-as dialog-box.

on return of b1 in frame fr1
    do:
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

selitem = menu.num.


