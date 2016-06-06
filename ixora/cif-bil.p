/* cif-bil.p
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

def var v-bic as char format "x(12)" label "SWIFT BIC".
def shared var s-cif like cif.cif.
def var okbic as log.
def var i as int.

find cif where cif.cif = s-cif.
v-bic = cif.mail.
display v-bic
    with frame a 1 columns row 12 centered.
pause.

/*
repeat:
update v-bic
    with frame a 1 columns row 12 centered.
okbic = true.
v-bic = caps(trim(v-bic)).
if length(v-bic) ne 8 and length(v-bic) ne 11 
and length(v-bic) ne 12 then okbic = false.
if okbic then do:
i = 0.
repeat:
i = i + 1.
if not ((substr(v-bic,i,1) >= "A" and substr(v-bic,i,1) <= "Z")
or ( i > 6 and substr(v-bic,i,1) >="0" and substr(v-bic,i,1) <= "9")) then
okbic = false.
if i = length(v-bic) or not (okbic) then leave.
end.
end.
if okbic then leave.
else message "WRONG BIC FORMAT".
end.
if length(v-bic) eq 11 then v-bic = substr(v-bic,1,8) + "X" +
substr(v-bic,9).
if keyfunction(lastkey) eq "END-ERROR" then return.
cif.mail = v-bic.
*/
