/* late5.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

def var v-ofc as char.
def var vl as log format "Заблокирован/Блокировки нет".
def var ans as log format "да/нет" init no.
vl = ?.

def frame getofc
       v-ofc label "Введите логин офицера"
       validate (can-find(ofc where ofc.ofc = v-ofc), "Нет такого офицера!")
       vl label "Состояние"
       with row 5 centered side-labels.

update v-ofc label "Введите логин офицера"
       validate (can-find(ofc where ofc.ofc = v-ofc), "Нет такого офицера!")
       with side-labels centered frame getofc.
hide frame getofc.

find ofc where ofc.ofc = v-ofc no-error.
if ofc.late[1] >= 5 then vl = yes.
else vl = no.

displ vl with frame getofc. pause 0.
pause.

if vl then message "Снять блокировку?" update ans.
if ans then ofc.late[1] = 0.
