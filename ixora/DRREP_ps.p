/* DIRREP.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Формирование выписок MT970 PRESENT 
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        17/03/05 kanat
 * CHANGES
        23/03/05 kanat - соединил 2 типа выписок и подправил скрипты UNIX
        19/04/05 kanat - поменял формирвоание имени файлов и добавил копирование выписок в архив
                         и после 17.00 выписки не формируются  
        21/04/05 kanat - выписки формируются с 9.00 утра
        25/04/05 kanat - выписки формируются только с понедельника по пятницу.
        20/05/05 kanat - PRESENT выписки формируются только по direct_bank.que = "y"
        24/05/2005 kanat - добавил обработку файлов по их расширениям, которые берутся из настроек банков
        02/06/2005 kanat - изменил время окончания формирования файлов
        02/08/2005 kanat - добавил дополнительные условия для LORO счетов 
        09/08/2005 kanat - добавил копирование по rcp на СПЭД БТА
        15/08/2005 kanat - убрал слово TEXAS в выписках, так как в БТА стоит ограничение на длину референса выписки
*/


{global.i}
{trim.i}
{lgps.i}

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
define variable v-rbank as char.

define variable v-ext1 as char.
define variable v-ext2 as char.
define variable v-ext3 as char init "".

define variable v-unidirc as char.
define variable v-unipath1 as char.

define variable v-bta-ip as character init "bta".
define variable v-bta-path as character init "/home/pc/branch/out/".
define variable v-result1 as character.


v-rep-date = g-today.

if weekday(today) >= 2 and weekday(today) <= 6 and time >= 32400 and time <= 63000 then do:

for each direct_bank where direct_bank.que = "y" no-lock.

if direct_bank.ext[3] <> "" and direct_bank.ext[3] <> ? then 
v-uniacct = direct_bank.ext[3].
else
v-uniacct = direct_bank.bank2.


v-unibank = direct_bank.bank1.

v-ext1 = trim(direct_bank.ext[1]).
v-ext2 = trim(direct_bank.ext[2]).
v-ext3 = trim(direct_bank.ext[3]).

/* REPORT HEAD BLOCK */

output to value("pt.dir").

put unformatted "\{1:F01" + trim(direct_bank.aux_string[5]) + "\}" skip
                "\{2:O970" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + 
                entry(1,string(time,"HH:MM:SS"),":") + entry(2,string(time,"HH:MM:SS"),":") + 
                "K059140000000000000000" + 
                substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + 
                entry(1,string(time,"HH:MM:SS"),":") + entry(2,string(time,"HH:MM:SS"),":") + "U\}" skip.

put unformatted ":20:" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + string(time) + "C" skip
                ":23:PRESENT" skip
                ":25:190501914/" + v-uniacct skip
                ":28:1" skip
                ":60F:C" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + "KZT0,00" skip. 

/* INCOMING PAYMENTS BOCK */

if v-ext3 = "" or v-ext3 = ? then do:
for each remtrz where remtrz.valdt1 = v-rep-date and remtrz.dracc = v-uniacct and remtrz.source = "DIR" and remtrz.tcrc = 1 no-lock.

put unformatted ":61:" + entry(1,string(remtrz.rtim,"HH:MM:SS"),":") + entry(2,string(remtrz.rtim,"HH:MM:SS"),":") + "D" + 
                substr(string(year(remtrz.valdt1)), 3, 2) + string(month(remtrz.valdt1), "99") + string(day(remtrz.valdt1),"99") + 
                "KZT" +  replace(trim(string(remtrz.amt, "zzzzzzzzzzzzzzz9.99-")), ".", ",") + "S100" + remtrz.sbank + remtrz.t_sqn skip.

v-dirsum1 = v-dirsum1 + remtrz.amt.
end.
end.

/* OUTGOING PAYMENTS BLOCK */

for each remtrz where remtrz.valdt1 = v-rep-date and remtrz.cracc = v-uniacct and remtrz.tcrc = 1 no-lock.
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

put unformatted ":62F:D" + substr(string(year(v-rep-date)), 3, 2) + string(month(v-rep-date), "99") + string(day(v-rep-date),"99") + 
                "KZT" + replace(string(ABS(v-dirsum2 - v-dirsum1)),".",",") skip.

put unformatted  "-\}" skip.

output close.

v-unipath = direct_bank.aux_string[3].
v-unidir = "NTMAIN:" + replace(v-unipath,"/","\\\\\\\\").

unix silent un-dos value("pt.dir" + " " + "p" + string(time, "999999") + v-ext2).
unix silent value("rm -f pt*" + v-ext2).

input through value ("rcp " + "p*" + v-ext2 + " " + v-unidir + " ;echo $?" ). 
repeat:
  import v-result.
end.

v-unipath1 = direct_bank.aux_string[4].
v-unidirc = "NTMAIN:" + replace(v-unipath1,"/","\\\\\\\\").

input through value ("rcp " + "p*" + v-ext2 + " " + v-unidirc + " ;echo $?" ). 
repeat:
  import v-result.
end.


/* -------------------------- */
if v-unibank = "190501319" then do:
input through value ("chmod 777 " + "p*" + v-ext2 + " ;echo $?"). 
repeat:
  import v-result1.
end.

input through value ("rcp " + "p*" + v-ext2 + " " + v-bta-ip + ":" + v-bta-path + " ;echo $?"). 
repeat:
  import v-result1.
end.
if integer(v-result1) <> 0 then do:
return.
end.
end.
/* -------------------------- */


unix silent value("rm -f p*" + v-ext2).
end. /* for each direct_bank ... */

pause 0.

end.


