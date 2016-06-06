/* cif-moth.p
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
 * CHANGES
*/

def var v-mother as char label "Код кредитного учреждения" format "x(9)".
def shared var s-cif like cif.cif.
def shared var g-ofc as char.
find cif where cif.cif = s-cif.
v-mother = cif.mother.
update v-mother
    with frame a 1 columns row 12 centered.
if keyfunction(lastkey) eq "END-ERROR" then return.
def shared stream cifedt.
put stream cifedt cif.cif ", СТАРЫЙ ГОЛОВНОЙ БАНК " 
cif.mother format "x(9)"
", НОВЫЙ ГОЛОВНОЙ БАНК " v-mother " " g-ofc " " today " " string(time,"HH:MM:SS") skip.

cif.mother = v-mother.
