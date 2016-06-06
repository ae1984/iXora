/* parser_9.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Парсер МТ970
 * RUN
        
 * CALLER
        nmenu.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        23/03/2005 kanat
 * CHANGES
        05/04/2005 kanat - добавил дополнительные условия по референсам платежей
        11/05/2005 kanat - поменял имя хоста
        24/05/2005 kanat - добавил обработку файлов по их расширениям, которые берутся из настроек банков
        30/05/2005 kanat - добавил проверки на корр. счета банков
        07/06/2005 kanat - добавил дополнительное условие - если пользователь хочет прервать операцию
        11/08/2005 kanat - добавил обработку по ЛОРО счетам
*/

{global.i}

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
define temp-table cms-direct like direct_bank.
define variable v-unibank as char.

define variable v-ext1 as char.
define variable v-ext2 as char.

define variable v-bank1 as char.
define variable v-bank2 as char.

define variable v-result1 as char.
define variable v-result2 as char.
define variable v-resultd as char.

define variable v-bta-ip as character init "bta".
define variable v-bta-path as character init "/home/pc/branch/in/".

define variable v-unipath as character.
define variable v-unidir as character.

define variable v-loro as character.

/*
v-path =  "C:\\DIRECT\\IMPORT\\".
*/

run direct_select.
v-unibank = return-value.

if v-unibank = "" then
return.

v-host = "NTMAIN".

find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
v-path = replace(trim(direct_bank.aux_string[2]),"/","\\\\").
v-ext1 = trim(direct_bank.ext[1]).
v-ext2 = trim(direct_bank.ext[2]).
v-bank1 = trim(direct_bank.bank1).
v-bank2 = trim(direct_bank.bank2).
v-unipath = trim(direct_bank.aux_string[2]).
v-loro = trim(direct_bank.ext[3]).
end.


/* --------------------------------- */
if v-unibank = "190501319" then do:
input through value ("rm -f *" + v-ext2). 
repeat:
  import v-resultd.
end.

input through value ("rcp " + v-bta-ip + ":" + v-bta-path + "*" + v-ext2 + " ./" + ";echo $?"). 
repeat:
  import v-result1.
end.

if integer(v-result1) <> 0 then do:
message "Произошла ошибка при копировании файлов со СПЭД" view-as alert-box title "Внимание".
return.
end.

v-unidir = "NTMAIN:" + replace(v-unipath,"/","\\\\\\\\").
input through value ("rcp " + "*" + v-ext2 + " " + v-unidir + " ;echo $?" ). 
repeat:
  import v-result2.
end.

if integer(v-result2) <> 0 then do:
message "Произошла ошибка при копировании файлов на NTMAIN" view-as alert-box title "Внимание".
return.
end.
end.
/* --------------------------------- */


input through value("rsh  " + v-host + " dir /b " + v-path + "*" + v-ext2) no-echo.
/*
input through value("rsh `askhost` dir /b '" + v-path + "*.eks '") no-echo.
*/
repeat:
      import unformatted s.

              input stream m-cpfl through value("rcp " + "NTMAIN" + ":" + replace(v-path,"\\","\\\\") + trim(s) + " " + trim(s) + "; echo $?").
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
displ "Сверка финальной выписки МТ970 СРП".
else do:
message "Файл выписки не найден" view-as alert-box title "Внимание".
return.
end.

for each ttmps where ttmps.strings <> "" and
                     ttmps.strings <> ? and
                     ttmps.strings matches ':61:*' and 
                     substr(ttmps.strings,9,1) = "C" no-lock.         
                  
v-temp-date = date(substr(substr(ttmps.strings,10,6),5,2) + "/" +
                   substr(substr(ttmps.strings,10,6),3,2) + "/" +
                   substr(substr(ttmps.strings,10,6),1,2)).

find last temp-rmz where temp-rmz.valdt1 = v-temp-date and temp-rmz.t_sqn = substr(ttmps.strings,index(ttmps.strings,"S") + 13, 100)
                          no-lock no-error.
if avail temp-rmz then do:

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
end.

for each ttmps where ttmps.strings <> "" and
                     ttmps.strings <> ? and
                     ttmps.strings matches ':61:*' and 
                     substr(ttmps.strings,9,1) = "D" no-lock.         
                  
v-temp-date = date(substr(substr(ttmps.strings,10,6),5,2) + "/" +
                   substr(substr(ttmps.strings,10,6),3,2) + "/" +
                   substr(substr(ttmps.strings,10,6),1,2)).

find last temp-rmz where temp-rmz.valdt1 = v-temp-date and temp-rmz.remtrz = substr(ttmps.strings,index(ttmps.strings,"S") + 13, 100)
                          no-lock no-error.
if avail temp-rmz then do:

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
end.


output to sver_report.txt.
put unformatted "Протокол сверки платежей за " + string(g-today) skip(1).

for each que where que.pid = "DIRIN" no-lock.
find first remtrz where remtrz.remtrz = que.rem and remtrz.dracc = trim(v-bank2) no-lock no-error.
if avail remtrz then do:
v-dirin-sum = v-dirin-sum + remtrz.amt.
v-dirin-count = v-dirin-count + 1.
end.
end.

for each que where que.pid = "DRSTW" no-lock.
find first remtrz where remtrz.remtrz = que.rem and (remtrz.cracc = trim(v-bank2) or remtrz.cracc = v-loro) no-lock no-error.
if avail remtrz then do:
v-drstw-sum = v-drstw-sum + remtrz.amt.
v-drstw-count = v-drstw-count + 1.
end.
end.

put unformatted fill("=",80) skip.
put unformatted "Примечание: DIRIN - очередь входящих платежей, DRSTW - очередь исх.пл." skip.
put unformatted "для сверки платежей через корр. счета коммерческих банков 2 уровня    " skip.
put unformatted fill("=",80) skip(1).


put unformatted  "Всего входящих платежей по выписке    = " string(v-in-count) skip 
                 "Общая сумма входящих по выписке       = " string(v-in-amount, 'zzzzzzzzzzz9.99-')  skip(1) 
                 "Зарегистрировано на  DIRIN - всего    = " string(v-dirin-count) skip 
                 "Сумма платежей на очереди DIRIN       = " string(v-dirin-sum, 'zzzzzzzzzzz9.99-') skip(2).

put unformatted fill("=",80) skip(1).


put unformatted  "Всего исходящих платежей по выписке   = " string(v-out-count)  skip
                 "Общая сумма исходящих по выписке      = " string(v-out-amount, 'zzzzzzzzzzz9.99-') skip
                 "Ожидает сверки на очереди DRSTW       = " string(v-drstw-count) skip
                 "Сумма платежей для сверки на DRSTW    = " string(v-drstw-sum,  'zzzzzzzzzzz9.99-') skip.

output close.
run menu-prt ("sver_report.txt").

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



