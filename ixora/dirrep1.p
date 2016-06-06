/* dirrep1.p
 * MODULE
        Прямые корр. отношения
 * DATABASE 
        bank  
 * DESCRIPTION
        Отчет по входящим платежам системы ПКО (с возможностью сверки с финальной выпиской банков за текущий опер. день)
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
        07/07/2005 kanat
 * CHANGES
        16/08/2005 kanat - добавил информацию по входящим и исходяшим платежам
        27/08/2005 kanat - добавил условие по входящим платежам
        05/09/2005 kanat - добавил условие по входящим платежам que.pid <> "D"
        07/09/2005 kanat - убрал проверку на jh1 и jh2 при анализе входящих платежей
        15/09/2005 kanat - убрал дополнительные проверки на формирвоание временных таблиц по выпискам
        21/03/2006 suchkov - перекомпиляция
        12/06/06   ten - исправил поиск входящих платежей, теперь по remtrz.valdt1.
*/

{global.i}
{comm-txb.i}

define variable v-date-begin as date.
define variable v-date-fin as date.
define variable v-whole as decimal.
define variable v-whole1 as decimal.
define variable v-unibank as character.
define variable v-uniacct as character.
define variable v-count as integer.
define variable v-count1 as integer.
define temp-table cms-direct like direct_bank.

def temp-table ttmpsw
    field strings as char.

def temp-table ttmps
    field strings as char.

def temp-table ttmpd
    field ref as char
    field sum as decimal
    field tmp-sqn as char
    field type as char
    field whole as decimal.

def var v-temp-date as date.
def buffer temp-rmz for remtrz.

def var v-in-count as integer.
def var v-out-count as integer.

def var v-in-amount as decimal.
def var v-out-amount as decimal.

def var v-result as char.
def var s  as char init ''.
def var v-str  as char init ''.

define stream m-cpfl.
define stream m-infl.
define stream m-cpfldl.

def var v-host as char. 
def var v-path as char.

def var v-dirin-count as integer.
def var v-drstw-count as integer.

def var v-dirin-sum as decimal.
def var v-drstw-sum as decimal.

define variable v-ext1 as char.
define variable v-ext2 as char.

define variable v-bank1 as char.
define variable v-bank2 as char.

define variable v-lbol as logical init false.
define variable v-bnom as logical init false.

define variable v-sys-count as integer.
define variable v-uniacct1 as character.

run direct_select.
v-unibank = return-value.

if v-unibank = "" then
return.


find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
if trim(direct_bank.ext[3]) <> "" then do:
v-uniacct = trim(direct_bank.ext[3]).
v-uniacct1 = direct_bank.bank2.
end.
else do:
v-uniacct = direct_bank.bank2.
v-uniacct1 = v-uniacct.
end.
end.


find first bankl where bankl.bank = v-unibank no-lock no-error.
if avail bankl then 
 displ bankl.name label " Наименование банка" with frame frame_for_date.

 v-date-begin = g-today.
 v-date-fin = v-date-begin.
 
 update v-date-begin label ' Введите период с ' format '99/99/9999'         
        v-date-fin   label ' по '               format '99/99/9999'
        v-lbol       label ' Сверка по выписке' format "y/n"
        v-bnom       label ' Детальный отчет (y), сокращенный отчет (n)' format "y/n"
        skip with side-label row 5 centered frame frame_for_date.

if v-date-begin > v-date-fin then do:
message "Задан неверный период отчета" view-as alert-box title "Внимание".
return.
end.

if v-lbol then do:

/* ----------------------- парсер выписки -----------------------*/

v-host = "NTMAIN".

find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
v-path = replace(trim(direct_bank.aux_string[2]),"/","\\\\").
v-ext1 = trim(direct_bank.ext[1]).
v-ext2 = trim(direct_bank.ext[2]).
v-bank1 = trim(direct_bank.bank1).
v-bank2 = trim(direct_bank.bank2).
end.

input through value("rsh  " + v-host + " dir /b " + v-path + "*" + v-ext2) no-echo.
/*
input through value("rsh `askhost` dir /b '" + v-path + "*.eks '") no-echo.
*/
repeat:
      import unformatted s.

            input stream m-cpfl through value("rcp " + v-host + ":" + replace(v-path,"\\","\\\\") + trim(s) + " " + trim(s) + "; echo $?").
             repeat:
                import stream m-cpfl v-result.
             end.
            input stream m-cpfl close.

            input stream m-infl from value(trim(s)).
             repeat:
              do transaction:

               create ttmpsw.
               import stream m-infl ttmpsw.

              end. 
            end. 

find first ttmpsw where ttmpsw.strings <> "" and
                        ttmpsw.strings <> ? and
                        ttmpsw.strings begins ':23:' and
                        ttmpsw.strings matches '*PRESENT*' no-lock no-error.
if avail ttmpsw then do:
        for each ttmpsw.
          delete ttmpsw.
        end.
end.


find first ttmpsw where ttmpsw.strings <> "" and 
                        ttmpsw.strings <> ? and  
                        ttmpsw.strings matches "*2:O970*"  
                        no-lock no-error.
if avail ttmpsw and g-today <> date(substr(ttmpsw.strings,12,2) + "/" + substr(ttmpsw.strings,10,2) + "/" + substr(ttmpsw.strings,8,2)) then do:
        for each ttmpsw.
          delete ttmpsw.
        end.
end.


for each ttmpsw no-lock.
        create ttmps.
        buffer-copy ttmpsw to ttmps.
end.

            input stream m-infl close.
            input stream m-cpfldl through value("rm  " + trim(s)) no-echo.
end.
input close.

find ttmps where string <> "" and
                 string <> ? and
                 string begins ':23:' and
                 string matches "*FINAL*" no-lock no-error.
if avail ttmps then 
displ "Сверка финальной выписки МТ970 с платежами".
else do:
message "Файл выписки для сверки с платежами не найден" view-as alert-box title "Внимание".
return.
end.

for each ttmps where ttmps.strings <> "" and
                     ttmps.strings <> ? and
                     ttmps.strings matches ':61:*' and 
                     substr(ttmps.strings,9,1) = "C" no-lock.         
                  
v-temp-date = date(substr(substr(ttmps.strings,10,6),5,2) + "/" +
                   substr(substr(ttmps.strings,10,6),3,2) + "/" +
                   substr(substr(ttmps.strings,10,6),1,2)).

                create ttmpd.
                update ttmpd.ref = substr(ttmps.strings,index(ttmps.strings,"S") + 13, 100)
                       ttmpd.sum = decimal(replace(substr(ttmps.strings,19,index(ttmps.strings,"S") - 19),",","."))
                       ttmpd.tmp-sqn = substr(ttmps.strings,index(ttmps.strings,"S") + 13, 100)
                       ttmpd.type = "C"
                       ttmpd.whole = decimal(replace(substr(ttmps.strings,19,index(ttmps.strings,"S") - 19),",",".")).

/*
if last-of (temp-rmz.t_sqn) then do:
displ substr(ttmps.strings,19,index(ttmps.strings,"S") - 19) format "x(20)"
      substr(ttmps.strings,index(ttmps.strings,"S"),4)
      substr(ttmps.strings,index(ttmps.strings,"S") + 4,10) format "x(9)"
      substr(ttmps.strings,index(ttmps.strings,"S") + 13, 100) format "x(50)"
      (accum sub-total by temp-rmz.t_sqn temp-rmz.amt) format ">>>,>>>,>>>,>>9.99".
end.
*/


                v-in-count = v-in-count + 1.
                v-in-amount = v-in-amount + ttmpd.sum.
end.

for each ttmps where ttmps.strings <> "" and
                     ttmps.strings <> ? and
                     ttmps.strings matches ':61:*' and 
                     substr(ttmps.strings,9,1) = "D" no-lock.         
                  
v-temp-date = date(substr(substr(ttmps.strings,10,6),5,2) + "/" +
                   substr(substr(ttmps.strings,10,6),3,2) + "/" +
                   substr(substr(ttmps.strings,10,6),1,2)).

                create ttmpd.
                update ttmpd.ref = substr(ttmps.strings,index(ttmps.strings,"S") + 13, 100)
                       ttmpd.sum = decimal(replace(substr(ttmps.strings,19,index(ttmps.strings,"S") - 19),",","."))
                       ttmpd.tmp-sqn = substr(ttmps.strings,index(ttmps.strings,"S") + 13, 100)
                       ttmpd.type = "D"
                       ttmpd.whole = decimal(replace(substr(ttmps.strings,19,index(ttmps.strings,"S") - 19),",",".")).

/*
if last-of (temp-rmz.t_sqn) then do:
displ substr(ttmps.strings,19,index(ttmps.strings,"S") - 19) format "x(20)"
      substr(ttmps.strings,index(ttmps.strings,"S"),4)
      substr(ttmps.strings,index(ttmps.strings,"S") + 4,10) format "x(9)"
      substr(ttmps.strings,index(ttmps.strings,"S") + 13, 100) format "x(50)"
      (accum sub-total by temp-rmz.t_sqn temp-rmz.amt) format ">>>,>>>,>>>,>>9.99".
end.
*/

                v-out-count = v-out-count + 1.
                v-out-amount = v-out-amount + ttmpd.sum.
end.

/* --------------------------------------------------------------*/

end. /* if v-lbol then do ... */

output to dirrep1.txt.

find first bankl where bankl.bank = v-unibank no-lock no-error.
if avail bankl then do:
put unformatted "Отчет по платежам по системе ПКО " skip.
put unformatted "БАНК: " bankl.name skip.
end.

if v-date-begin < v-date-fin then 
put unformatted " с " v-date-begin " по " v-date-fin skip(1).

if v-date-begin = v-date-fin then 
put unformatted " за " v-date-begin skip(1).



if v-bnom then do:
        put unformatted "Входящие платежи" skip.
        put unformatted fill("-",60) skip.
        put unformatted "Референс     Сумма        Дата      Очередь  " skip.
        put unformatted fill("-",60) skip.
end.

if not v-lbol then do:
        for each remtrz where remtrz.valdt1 >= v-date-begin and remtrz.valdt1 <= v-date-fin and remtrz.dracc = v-uniacct1 and 
                      remtrz.source = "DIR" no-lock.
        find first que where que.rem = remtrz.remtrz and que.pid <> "D" no-lock no-error.
                if avail que then do:
                if v-bnom then 
                        put unformatted remtrz.remtrz format "x(12)" " " string(remtrz.amt) format "x(12)" " " string(remtrz.valdt1) format "x(10)" " "
                        que.pid format "x(10)" skip.
                        v-count = v-count + 1.
                        v-whole = v-whole + remtrz.amt.
        end.
        end.
end. /* if not v-lbol then do: ... */

if v-bnom then do:
        put unformatted "Исходящие платежи" skip.
        put unformatted fill("-",60) skip.
        put unformatted "Референс     Сумма        Дата      Очередь  " skip.
        put unformatted fill("-",60) skip.
end.

if not v-lbol then do:
        for each remtrz where remtrz.valdt1 >= v-date-begin and remtrz.valdt1 <= v-date-fin and remtrz.cracc = v-uniacct no-lock.
        find first que where que.rem = remtrz.remtrz no-lock no-error.
                if avail que then do:
                        if v-bnom then 
                        put unformatted remtrz.remtrz format "x(12)" " " string(remtrz.amt) format "x(12)" " " string(remtrz.valdt1) format "x(10)" " "
                        que.pid format "x(10)" skip.
                        v-count1 = v-count1 + 1.
                        v-whole1 = v-whole1 + remtrz.amt.
                end.
        end.
end. /* if not v-lbol then do: ... */

if v-lbol then do:
/* сверка платежей по исходящим и входящим выпискам */

        for each ttmpd where ttmpd.type = "C" no-lock.
        find first remtrz where remtrz.valdt1 = g-today and remtrz.sqn matches "*" + ttmpd.ref + "*" and 
                       (remtrz.ptype = "5" or remtrz.ptype = "7") no-lock no-error.
                if not avail remtrz then do:
                        put unformatted "В системе отсутствует входящий платеж: " ttmpd.ref " на сумму " ttmpd.sum skip.
                        v-sys-count = v-sys-count + 1.
                        v-count = v-count + 1.
                        v-whole = v-whole + ttmpd.sum.
                end.
        end.

        for each ttmpd where ttmpd.type = "D" no-lock.
        find first remtrz where remtrz.valdt1 = g-today and remtrz.remtrz matches "*" + ttmpd.ref + "*" and 
                       (remtrz.ptype = "2" or remtrz.ptype = "6") no-lock no-error.
                if not avail remtrz then do:
                        put unformatted "В системе отсутствует исходящий платеж - Референс: " ttmpd.ref " на сумму " ttmpd.sum skip.
                        v-sys-count = v-sys-count + 1.
                        v-count1 = v-count1 + 1.
                        v-whole1 = v-whole1 + ttmpd.sum.
                end.
        end.

end.



if v-lbol and v-sys-count = 0 then 
put unformatted "Расхождений в выписке по входящим и исходящим платежам не найдено" skip.

put unformatted fill("-",60) skip.
put unformatted "Всего входящих платежей: " v-count " платежей на сумму " v-whole skip.
put unformatted "Всего исходящих платежей: " v-count1 " платежей на сумму " v-whole1 skip.

output close.
run menu-prt ("dirrep1.txt").




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
