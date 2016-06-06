/* dirvbc.p
 * MODULE
        Кор. отношения
 * DESCRIPTION
        Формирование выписки MT970 (кредитовая часть)
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
        03/03/2005 kanat
 * CHANGES
        15/03/2005 kanat - добавил дополнительные условие по входящим платежам
        17/03/2005 kanat - переделал префиксы операций с кредита на дебет
        01/04/2005 kanat - подправил выводимые сообщения
        05/04/2005 kanat - добавил условие по очереди ARC
        24/05/2005 kanat - добавил обработку файлов по их расширениям, которые берутся из настроек банков
        27/05/2005 kanat - добавил инициализацию 4 блока {4:
        04/08/2005 kanat - добавил обработку LORO - счетов банков
        09/08/2005 kanat - добавил копирование по rcp на СПЭД БТА
        15/08/2005 kanat - убрал слово TEXAS в выписках, так как в БТА стоит ограничение на длину референса выписки
        16/08/2005 kanat - в формирование чистых позиций добавил дополнительное условие по дебету
*/

/*   --- MT970 ----
{1:F01K059140000000010903365}
{2:O9700503021507SCLEAR00000000000000000503021507U}
{4:
:20:CL1429639
:23:FINAL
:25:190201125/900161414
:28:1
:60F:C050302KZT0,00
:61:1453C050302KZT14073,70S100190501781000403869
:61:1547D050302KZT210,00S102190501914RMZ6228214
:62F:D050302KZT99580157,96        
-}
*/

{global.i}
{trim.i}
{lgps.i "new"}
{comm-txb.i}

define variable v-txb as character.
define variable v-unibank as character.
define variable v-dirsum1 as decimal.
define variable v-dirsum2 as decimal.
define variable v-unipath as character.
define variable v-result as integer.
define variable v-unidir as character.
define variable v-bank-sender as character.
define variable v-uniacct as character.
define variable v-rep-date as date.
define variable v-member as char.
define variable v-rbank as char.

define variable v-ext1 as char.
define variable v-ext2 as char.
define variable v-ext3 as char.

define variable v-unipath1 as char.
define variable v-unidirc  as char.

define temp-table cms-direct like direct_bank.

define variable v-bta-ip as character init "bta".
define variable v-bta-path as character init "/home/pc/branch/out/".
define variable v-result1 as character.
define variable v-resultx as character.

v-txb = comm-txb().

v-rep-date = g-today.
update v-rep-date label "Дата выписки (dd/mm/yy)" with frame frame_for_edit centered.

run direct_select.
v-unibank = return-value.

if v-unibank = "" then
return.

find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:


if direct_bank.ext[3] <> "" and direct_bank.ext[3] <> ? then 
v-uniacct = direct_bank.ext[3].
else
v-uniacct = direct_bank.bank2.


v-member = trim(direct_bank.aux_string[5]).
v-ext1 = trim(direct_bank.ext[1]).
v-ext2 = trim(direct_bank.ext[2]).
v-ext3 = trim(direct_bank.ext[3]).
end.

/* REPORT HEAD BLOCK */

output to value("ft" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + v-ext2).

put unformatted "\{1:F01" + v-member + "\}" skip
                "\{2:O970" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + 
                entry(1,string(time,"HH:MM:SS"),":") + entry(2,string(time,"HH:MM:SS"),":") + 
                "K059140000000000000000" + 
                substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + 
                entry(1,string(time,"HH:MM:SS"),":") + entry(2,string(time,"HH:MM:SS"),":") + "U\}" skip.

put unformatted "\{4:" skip.
put unformatted ":20:" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + string(time) + "C" skip
                ":23:FINAL" skip
                ":25:190501914/" + v-uniacct skip
                ":28:1" skip
                ":60F:C" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + "KZT0,00" skip. 

/* INCOMING PAYMENTS BLOCK */

if v-ext3 = "" or v-ext3 = ? then do:
if v-unibank <> "190501856" then do:
for each remtrz where remtrz.valdt1 = v-rep-date and remtrz.dracc = v-uniacct and remtrz.source = "DIR" no-lock.
find first que where que.rem = remtrz.remtrz and que.pid <> "ARC" no-lock no-error.
if avail que then do:
put unformatted ":61:" + entry(1,string(remtrz.rtim,"HH:MM:SS"),":") + entry(2,string(remtrz.rtim,"HH:MM:SS"),":") + "D" + 
                substr(string(year(remtrz.valdt1)), 3, 2) + string(month(remtrz.valdt1), "99") + string(day(remtrz.valdt1),"99") + 
                "KZT" +  replace(trim(string(remtrz.amt, "zzzzzzzzzzzzzzz9.99-")), ".", ",") + "S100" + remtrz.sbank + remtrz.t_sqn skip.
v-dirsum1 = v-dirsum1 + remtrz.amt.
end.
end.
end.
end.

/* OUTGOING PAYMENTS BLOCK */

for each remtrz where remtrz.valdt1 = v-rep-date and remtrz.cracc = v-uniacct no-lock.
find first que where que.rem = remtrz.remtrz and que.pid <> "ARC" no-lock no-error.
if avail que then do:
find first clrdir where clrdir.rem = remtrz.remtrz no-lock no-error.
if avail clrdir then do:

find first bankl where bankl.acct = remtrz.sbank no-lock no-error.
  if avail bankl then
  v-bank-sender = bankl.bank.

put unformatted ":61:" + entry(1,string(remtrz.rtim,"HH:MM:SS"),":") + entry(2,string(remtrz.rtim,"HH:MM:SS"),":") + "C" + substr(string(year(remtrz.valdt1)), 3, 2) + string(month(remtrz.valdt1), "99") + 
                string(day(remtrz.valdt1),"99") + "KZT" +  replace(trim(string(remtrz.amt, "zzzzzzzzzzzzzzz9.99-")), ".", ",") + 
                "S100" + v-bank-sender + remtrz.remtrz skip.

v-dirsum2 = v-dirsum2 + remtrz.amt.
end.
end.
end.


if v-dirsum2 > v-dirsum1 then do:
put unformatted ":62F:C" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + 
                "KZT" + replace(string(ABS(v-dirsum2 - v-dirsum1)),".",",") skip.
end.

if v-dirsum2 < v-dirsum1 then do:
put unformatted ":62F:D" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + 
                "KZT" + replace(string(ABS(v-dirsum2 - v-dirsum1)),".",",") skip.
end.

if v-dirsum2 = v-dirsum1 then do:
put unformatted ":62F:" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + 
                "KZT" + replace(string(ABS(v-dirsum2 - v-dirsum1)),".",",") skip.
end.


put unformatted  "-\}" skip.

output close.


/* REPORT REMOTE COPY BLOCK */

if v-dirsum1 <> 0 or v-dirsum2 <> 0 then do:

       MESSAGE "Сформировать файл MT970 для отправки ?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "" UPDATE choice1 as logical.

       if not choice1 then return.

unix silent un-dos value("ft" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + v-ext2)  value("f" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + v-ext2).

unix silent value("rm -f ft*" + v-ext2).

find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
v-unipath = direct_bank.aux_string[3].
v-unidir = "NTMAIN:" + replace(v-unipath,"/","\\\\\\\\").
v-unipath1 = direct_bank.aux_string[4].
v-unidirc = "NTMAIN:" + replace(v-unipath1,"/","\\\\\\\\").
end.


/* -------------------------- */
if v-unibank = "190501319" then do:
input through value ("chmod 777 " + "f*" + v-ext2 + " ;echo $?"). 
repeat:
  import v-resultx.
end.

input through value ("rcp " + "f*" + v-ext2 + " " + v-bta-ip + ":" + v-bta-path + " ;echo $?"). 
repeat:
  import v-result1.
end.
if integer(v-result1) <> 0 then do:
message "Произошла ошибка при копировании файла на СПЭД" view-as alert-box title "Внимание".
return.
end.
end.
/* -------------------------- */


input through value ("rcp " + "f*" + v-ext2 + " " + v-unidir + " ;echo $?" ). 
repeat:
  import v-result.
end.

input through value ("rcp " + "f*" + v-ext2 + " " + v-unidirc + " ;echo $?" ). 
repeat:
  import v-result.
end.

unix silent value("rm -f f*" + v-ext2).

if integer(v-result) <> 0 then 
message "Произошла ошибка при копировании файла" view-as alert-box title "Внимание".

message "Выписка отправлена" view-as alert-box title "Внимание".

v-text = " Выписка MT970 за " + string(v-rep-date) + " отправлена (прямые корр. отношения) - " + v-unibank.
run lgps.

end.
else do:
message "Отсутствуют данные для выписки" view-as alert-box title "Внимание".
return.
end.



/* BANK DFB NOSTRO ACCOUNT SELECT PROCEDURE */

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












