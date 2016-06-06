/* subcoda.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование    
*/


{mainhead.i "SUBCODA"}


def var s-aaa like aaa.aaa.
def var v-yes as log.
def var v-s as char.
v-yes = no.
repeat while not v-yes.
    update s-aaa validate(can-find(aaa where aaa.aaa eq s-aaa),
    "Не найден счет") label "Счет"  with frame a side-label centered.
    find aaa where aaa.aaa eq s-aaa no-lock no-error.
    find cif where cif.cif eq aaa.cif no-lock no-error.
    find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
    
    v-s =  "Счет " + aaa.aaa + " \n" + lgr.des + " \n" + 
       trim(trim(cif.prefix) + " " + trim(cif.name)) + " \n". 
    message v-s view-as alert-box 
    buttons YES-NO update v-yes. 
end.



def temp-table wt like sub-cod.
for each sub-cod where sub-cod.acc eq s-aaa and sub-cod.sub eq "CIF" :
create wt.
buffer-copy sub-cod to wt.
end.

run subcodl(s-aaa,"CIF").

for each wt no-lock :
find first sub-cod where sub-cod.acc eq wt.acc
and sub-cod.sub eq wt.sub and sub-cod.d-cod eq wt.d-cod
use-index dcod  no-lock no-error .
if available sub-cod then do :
if sub-cod.ccode ne wt.ccode or sub-cod.rcode ne wt.rcode then
run wrt-cng.
end.
else run wrt-del.
end.


for each sub-cod where sub-cod.acc eq s-aaa and sub-cod.sub eq "CIF" no-lock :
find first wt where sub-cod.acc eq wt.acc
and sub-cod.sub eq wt.sub and sub-cod.d-cod eq wt.d-cod
no-lock no-error .
if not available wt then 
run wrt-cng.
end.

return.

Procedure wrt-cng.
def var v-t as int.
find last hissc where 
hissc.acc eq sub-cod.acc and 
hissc.sub eq sub-cod.sub and
hissc.d-cod eq sub-cod.d-cod and
hissc.rdt eq g-today no-lock no-error.
v-t = time.
if available hissc then if v-t le hissc.tim then v-t = hissc.tim + 1.
create hissc.
hissc.acc = sub-cod.acc.
hissc.sub = sub-cod.sub.
hissc.d-cod = sub-cod.d-cod.
hissc.rdt = g-today.
hissc.ccode = sub-cod.ccode.
hissc.rcode = sub-cod.rcode.
hissc.who = /* sub-cod.who. */ g-ofc.
hissc.tim = v-t.
end procedure.


Procedure wrt-del.
def var v-t as int.
find last hissc where 
hissc.acc eq wt.acc and 
hissc.sub eq wt.sub and
hissc.d-cod eq wt.d-cod and
hissc.rdt eq g-today no-lock no-error.
v-t = time.
if available hissc then if v-t le hissc.tim then v-t = hissc.tim + 1.
create hissc.
hissc.acc = wt.acc.
hissc.sub = wt.sub.
hissc.d-cod = wt.d-cod.
hissc.rdt = g-today.
hissc.ccode = "".
hissc.rcode = "".
hissc.who = /* wt.who. */ g-ofc.
hissc.tim = v-t.
end procedure.






