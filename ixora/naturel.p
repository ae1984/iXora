/* naturel.p
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


def var v-loncat like loncat.loncat label "Вид бизнеса".
def shared var s-cif like cif.cif.
form cif.nature label "Вид бизнеса" with frame aa overlay.
find cif where cif.cif = s-cif.

v-loncat = integer(cif.nature).
/*
update v-loncat validate (can-find(loncat where loncat.loncat eq v-loncat),"")
    with frame a 1 columns row 12 centered.
if keyfunction(lastkey) eq "END-ERROR" then return.
cif.nature = string(v-loncat,"999").
*/
display cif.nature with frame aa 1 columns row 12 centered.
pause.


