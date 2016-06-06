/* findcifg.p
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

def var v-name like cif.name.
def var f-name like cif.name.
def var lenv as int.
def var lenf as int.
def var i as int.
def var i0 as int.
def var ff as log.
def var vv-name as cha. 
v-name = "".
repeat:
update v-name label " Что искать ? " with frame aaa.
display  " Ждите ... " i0 format "zzzzzz"
        no-label with column 40 row 2 with frame aac.
pause 0.
v-name = trim(v-name).
vv-name = "*" + CAPS(v-name) + "*" . 
lenv = length(v-name).
i0 = 0.
for each cif use-index sname .
display i0 format "zzzzzz" with frame aac.
i0 = i0 + 1.
f-name = trim(name).
lenf = length(f-name).
i = 0.
ff = false.
if 
 caps(trim(trim(cif.prefix) + " " + trim(cif.sname)))  MATCHES vv-name or 
 caps(trim(trim(cif.prefix) + " " + trim(cif.name))) matches vv-name then ff = true .

/*
repeat :
i = i + 1.
if i + lenv - 1 > lenf then leave.
if substr(f-name,i,lenv) = v-name then do:
 ff = true.
 leave.
end.
end.
 */

 if ff then
 display cif.cif label " Kod " trim(trim(cif.prefix) + " " + trim(cif.name)) label " Description " format "x(60)" .
/* next .    */ 
/* if not available cif then leave.  */ 
end.
hide frame aac.
end.
