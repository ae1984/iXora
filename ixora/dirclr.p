/* dirclr.p
 * MODULE
        Прямые корр. отношения
 * DESCRIPTION
        Отчет по прямым корр. отношениям 
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
        04/04/2005 kanat
 * CHANGES
        24/05/2005 kanat - перекомпиляция
        12/08/2005 kanat - добавил условие по ЛОРО счетам банков - респондентов
*/

{global.i}
{comm-txb.i}

define variable v-date-begin as date.
define variable v-date-fin as date.
define variable v-whole as decimal.
define variable v-unibank as character.
define variable v-uniacct as character.
define variable v-count as integer.
define temp-table cms-direct like direct_bank.

run direct_select.
v-unibank = return-value.


find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
if trim(direct_bank.ext[3]) <> "" then 
v-uniacct = trim(direct_bank.ext[3]).
else
v-uniacct = direct_bank.bank2.
end.


 update v-date-begin label ' Введите период с ' format '99/99/9999'         
        v-date-fin   label ' по '               format '99/99/9999'
        skip with side-label row 5 centered frame frame_for_date.

if v-date-begin > v-date-fin then do:
message "Задан неверный период отчета" view-as alert-box title "Внимание".
return.
end.


output to report.txt.

find first bankl where bankl.bank = return-value no-lock no-error.
put unformatted "Отчет по отправленным платежам по системе ПКО " skip.
put unformatted "БАНК: " bankl.name skip.

if v-date-begin < v-date-fin then 
put unformatted " с " v-date-begin " по " v-date-fin skip(1).

if v-date-begin = v-date-fin then 
put unformatted " за " v-date-begin skip(1).

put unformatted "Референс   "
                "Сумма          " skip.
put unformatted fill("=",40) skip.

for each clrdir where clrdir.rdt >= v-date-begin and 
                      clrdir.rdt <= v-date-fin no-lock break by clrdir.rdt.

find first remtrz where remtrz.remtrz = clrdir.rem and remtrz.cracc = v-uniacct no-lock no-error.
if avail remtrz then do:

put unformatted remtrz.remtrz format "x(10)" " " string(remtrz.amt) format "x(15)" skip.

v-whole = v-whole + clrdir.amt.
v-count = v-count + 1.
end.
end.
put unformatted fill("=",40) skip.
put unformatted "Количество платежей: " string(v-count) skip.
put unformatted "На общую сумму: " string(v-whole) skip.
put unformatted fill("=",40) skip.
output close.
run menu-prt ("report.txt").



procedure direct_select.
for each cms-direct:
delete cms-direct.
end.
  
for each direct_bank no-lock:
    do transaction on error undo, next:
        create cms-direct.
        buffer-copy direct_bank to cms-direct.
    end.
end.
        
define query q1 for cms-direct.
define browse b1 
    query q1 no-lock
    display 
        cms-direct.bank1 label "БИК" format "x(10)" 
        cms-direct.bank2 label "Корр. счет" format "x(10)" 
        cms-direct.aux_string[1] label  "Наименование" format 'x(50)'
        with 10 down title "Список банков".
                                         
define frame fr1 
    b1
    with no-labels centered overlay view-as dialog-box.  
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
                    
open query q1 for each cms-direct.
if num-results("q1") = 0 then
do:
    MESSAGE "Справочник пуст ?!"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return cms-direct.bank1.
end.

