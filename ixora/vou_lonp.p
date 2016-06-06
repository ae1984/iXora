/* vou_lonp.p
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
        20/06/2005 madiar - изменения в вызове vou_lon
*/

def shared var s-lon like lon.lon .
def var s-jh like jh.jh .
def var v-f as log initial no.

update s-jh label "Транзакция" with frame a row 5 centered side-label
title "Повторная печать ваучера ".

find jh where jh.jh eq s-jh no-lock no-error.
if not available jh then
message "Транзакция " + string(s-jh) + " не найдена." view-as alert-box.
else do:
for each jl of jh no-lock :
if jl.acc eq s-lon and jl.sub eq "lon" then v-f = yes.
end.
if not v-f then
message
"Транзакция " + string(s-jh) + " не связана с кредитом " + s-lon
view-as alert-box.
end.

if v-f then run vou_lon(s-jh,'').
