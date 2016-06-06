/* dirsend.p
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
        26/01/2005 kanat
 * CHANGES
        28/02/2005 kanat - изменил формирование в кодировке
        01/03/2005 kanat - DROUT -> DROUF
        03/03/2005 kanat - изменил формат вывода в файл
        14/03/2005 kanat - добавил дополнительное условие по clrdir
        15/03/2005 kanat - добавил обработку 2 блока
        23/03/2005 kanat - переделал формирование файлов и их копирование
        28/03/2005 kanat - добавил в поля заполнения РНН проверку на присутствие данных в дополнительных екстентах или
                           на случай если при вбивании наименования или РНН произвели перенос символов на 
                           дополнительный екстент   
        30/03/2005 kanat - добавил условие - если менеджер неверно забил наименование клиента с большим количеством пробелов и переносами.
        31/03/2005 kanat - добавил букву Н в слове ДАНЫХ и обработку нового значения в таблце sysc.sysc = "POKSTR" - Счета 
                           исключения при формировании МТ100 - платеж с транзитного счета - но как клиентский. 
        01/04/2005 kanat - добавил дополнительные условия на платежи с клиентов банка по полю ord
        05/04/2005 kanat - добавил дополнительное условие по дате валютирования платежей
        12/04/2005 kanat - добавил дополнительное условие по отправителям платежей extents ordcst[1..3]
        14/04/2005 kanat - добавил копирование платежей для архива исходящих документов
        24/05/2005 kanat - добавил обработку файлов по их расширениям, которые берутся из настроек банков
        30/05/2005 kanat - добавил дополнительные условия при формировании РНН и Наименования получателя.
        31/05/2005 kanat - доюавил дополнительные условия на РНН отправителя - на случай если пользователь неверно 
                           вбил наименование отправителя с многочисленными /////
        07/06/2005 kanat - добавил паузу после отправки платежей перед их очисткой с home пользователя
                           добавил дополнительное условие - если пользователь хочет прервать операцию
        10/06/2005 kanat - если копирование или формирование соток не прошло успешно - то эти платежи на очередь сверки не попадут
        15/07/2005 kanat - добавил дополнительную очистку домашнего каталога
        02/08/2005 kanat - добавил обработку LORO - счетов банков
        04/08/2005 kanat - по просьбе АО Центркредита поставил формирование информации по полям 53C и 54B
        10/08/2005 kanat - добавил копирование по rcp на СПЭД БТА
        12/08/2005 kanat - очистку файлов вынес в другую процедуру
        15/08/2005 kanat - добавил условие на копирование исходящих форматов в БТА для архива платежей
        17/08/2005 kanat - добавил отсылку файлов на NTMAIN и СПЭД через For each ... 
        19/08/2005 kanat - добавил счетчик скопированных файлов при отправке соток на OUT
        23.11.2005 suсhkov - Детали платежа 412 символов
        23.11.2005 suсhkov - Исправлены ошибки
*/

{global.i}
{trim.i}
{lgps.i "new"}
{comm-txb.i}

define variable v-ref-details as character.
define variable v-ref-knp as character.

define variable v-our-rnn as character.
define variable v-our-chief as character.
define variable v-our-mainbk as character.
define variable v-our-bank as character.

define variable v-head-temp as character.

define variable vdetpay as character .
define variable v-temp-assign as character.

define variable v-det-temp as character extent 6 .
define variable i as integer. 

define variable v-cnt as integer.

define variable v-txb as character.

define variable v-unidir as character.
define variable v-unidirc as character.

define variable v-unipath as character.
define variable v-unipath1 as character.

define variable v-unibank as character.
define variable v-count as integer.
define variable v-whole as decimal.
define variable v-path as character.

define variable v-uniacct as char.
define variable v-member as char.
define variable v-pkostr as char.

define variable v-ext1 as char.
define variable v-ext2 as char.
define variable v-result as character.
define variable v-resultx as character.
define variable v-resultd as character.

define temp-table ttmpd 
       field ref as char.

define variable v-bta-ip as character init "bta".
define variable v-bta-path as character init "/home/pc/branch/out/".
define variable v-result1 as character.

define variable v-cnt1 as decimal.
define variable v-cnt2 as decimal.

define variable v-resultx1 as character.
define variable v-resultx2 as character.
define variable v-resultx3 as character.
define variable v-resultx4 as character.
define variable v-resultx5 as character.

v-txb = comm-txb().

FUNCTION ToNumber returns character (inchar as character).
   DEF variable tt as int.
   DEF variable oc as character.
   oc = inchar.
   DO tt = 0 to 255:
      IF tt < 48 or tt > 57 THEN oc = GReplace (oc, CHR(tt), "").
   END.
   DO WHILE LENGTH (oc) > 9:
      oc = SUBSTR (oc, 2).
   END.
   RETURN oc.
END FUNCTION.


find first cmp no-lock.
v-our-rnn = trim(cmp.addr[2]).

find first sysc where sysc.sysc = "CHIEF" no-lock.
if avail sysc then 
v-our-chief = sysc.chval.

find first sysc where sysc.sysc = "MAINBK" no-lock.
if avail sysc then 
v-our-mainbk = sysc.chval.

find first sysc where sysc.sysc = "clecod" no-lock no-error.
if avail sysc then 
v-our-bank = trim(sysc.chval).

find first sysc where sysc.sysc = "PKOSTR" no-lock no-error.
if avail sysc then 
v-pkostr = trim(sysc.chval).

define temp-table cms-direct like direct_bank.
define variable v-copy-count as integer.

define temp-table ttmps 
       field ref as character
       field rdt as date.   


        find first que where que.pid = "DROUF" no-lock no-error.
        if not avail que then do:
        message "Данные для выгрузки отсутствуют" view-as alert-box title "Внимание".
        return.
        end.

run direct_select.
v-unibank = return-value.

if v-unibank = "" then
return.


find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
v-uniacct = direct_bank.bank2.
v-member = trim(direct_bank.aux_string[5]).
v-ext1 = trim(direct_bank.ext[1]).
v-ext2 = trim(direct_bank.ext[2]).
end.

run dirrem(input v-ext1).

       output to term.txt.
        find first bankl where bankl.bank = return-value no-lock no-error.
        put unformatted "Реестр платежей для отправки в: " bankl.name skip.
        put unformatted fill("=",100) skip.
        put unformatted "Референс    Сумма                         БИК отправ. БИК получ. Счет получателя" skip.
        for each clrdir where clrdir.rdt = g-today.
        find first remtrz where remtrz.remtrz = clrdir.rem and remtrz.valdt1 = g-today no-lock no-error.
        if avail remtrz then do:
        find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
        if avail bankl and bankl.cbank = return-value then do:
        find first que where que.remtrz = remtrz.remtrz and que.pid = "DROUF" no-lock no-error.
        if avail que then do:
        put unformatted remtrz.remtrz      format "x(10)" " " 
                        string(remtrz.amt) format "x(30)" " " 
                        remtrz.sbank       format "x(11)" " " 
                        remtrz.rbank       format "x(11)" " " 
                        remtrz.cracc       format "x(12)" skip.
        create ttmps.
        update ttmps.ref = remtrz.remtrz
               ttmps.rdt = remtrz.valdt1. 

        clrdir.sts = 1.

        v-count = v-count + 1.
        v-whole = v-whole + remtrz.amt.
        v-cnt1 = v-cnt1 + 1.
        end.
        end.
        end.
        end.
        put unformatted fill("=",100) skip.
        put unformatted "ИТОГО платежей : " string(v-cnt1) " на сумму " string(v-whole) skip.
       output close.
       run menu-prt ("term.txt").

       release clrdir.

/*
       if v-count = 0 then do:
       message "Данные для выгрузки отсутствуют" view-as alert-box title "Внимание".
       return.
       end.
*/

       if v-count <> 0 then do:
       MESSAGE "Сформировать файлы MT100 для отправки ?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "" UPDATE choice1 as logical.
       if not choice1 then return.
       end.
       else do:
       message "Данные для выгрузки отсутствуют" view-as alert-box title "Внимание".
       return.
       end.

for each ttmps no-lock.
output to value("r" + replace(ttmps.ref,"RMZ","") + v-ext1).
find first clrdir where clrdir.rem = ttmps.ref and clrdir.sts = 1 no-lock no-error.
if avail clrdir then do:
find first remtrz where remtrz.remtrz = ttmps.ref no-lock no-error.
if avail remtrz then do:
find first que where que.remtrz = remtrz.remtrz and que.pid = "DROUF" no-error.
if avail que then do:

v-cnt = v-cnt + 1.
v-cnt2 = v-cnt2 + 1.

v-head-temp = "\{1:F01" + v-member + "\}" + chr(10) + 
              "\{2:O100" + substr(string(year(g-today)), 3, 2) + string(month(g-today), "99") + string(day(g-today),"99") + 
              entry(1,string(time,"HH:MM:SS"),":") + entry(2,string(time,"HH:MM:SS"),":") + "K059140000000000000000" + 
              substr(string(year(g-today)), 3, 2) + string(month(g-today), "99") + string(day(g-today),"99") + 
              entry(1,string(time,"HH:MM:SS"),":") + entry(2,string(time,"HH:MM:SS"),":") + "U\}" + chr(10).

/*
              "\{2:I100K05914000000N3003\}" + chr(10).
*/

put unformatted  v-head-temp.

put unformatted  "\{4:" skip.
put unformatted  ":20:" remtrz.remtrz skip.

put unformatted  ":32A:" substr(string(year(remtrz.valdt1)), 3, 2)  
                                         string(month(remtrz.valdt1), "99")  
                                         string(day(remtrz.valdt1),"99")
                                         "KZT"  
                                         replace(trim(string(remtrz.amt, "zzzzzzzzzzzzzzz9.99-")), ".", ",") skip.

put unformatted  ":50:/D/" remtrz.sacc skip.




find first aaa where aaa.aaa = trim(remtrz.dracc) no-lock no-error.
if avail aaa then do:


if replace(trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]),"/RNN/", "#") <> "" then 
put unformatted  "/NAME/" entry(1, replace(trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]), "/RNN/", "#"), "#") skip.
else
put unformatted  "/NAME/" entry(1, replace(trim(remtrz.ord), "/RNN/", "#"), "#") skip.


if replace(trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]),"/RNN/", "#") <> "" then 
put unformatted  "/RNN/" substr(entry(2, replace(trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]), "/RNN/", "#"), "#"), 1, 12) skip.
else
put unformatted  "/RNN/" substr(entry(2, replace(trim(remtrz.ord), "/RNN/", "#"), "#"), 1, 12) skip. 
                                                 
end.

else do:

if replace(trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]),"/RNN/", "#") <> "" then 
put unformatted  "/NAME/" entry(1, replace(trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]), "/RNN/", "#"), "#") skip.
else
put unformatted  "/NAME/" entry(1, replace(trim(remtrz.ord), "/RNN/", "#"), "#") skip.


if lookup(remtrz.dracc, v-pkostr) <> 0 and trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]) <> trim(remtrz.ord) then
do:
if replace(trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]),"/RNN/", "#") <> "" then 
put unformatted  "/RNN/" substr(entry(2, replace(trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]), "/RNN/", "#"), "#"), 1, 12) skip.
else
put unformatted  "/RNN/" substr(entry(2, replace(trim(remtrz.ord), "/RNN/", "#"), "#"), 1, 12) skip.
end.
else 
put unformatted  "/RNN/" v-our-rnn skip.

end.


find first aaa where aaa.aaa = trim(remtrz.dracc) no-lock no-error.
if avail aaa then do:

find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnchf" no-lock no-error.
if avail sub-cod and trim(sub-cod.rcode) <> "" then 
put unformatted  "/CHIEF/" caps(trim(sub-cod.rcode)) skip.
else
put unformatted  "/CHIEF/" "НЕТ ДАННЫХ" skip.


find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnbk" no-lock no-error.  
if avail sub-cod and trim(sub-cod.rcode) <> "" then 
put unformatted  "/MAINBK/" caps(trim(sub-cod.rcode)) skip.
else
put unformatted  "/MAINBK/" "НЕТ ДАННЫХ" skip.

end.
else do:
put unformatted  "/CHIEF/" caps(v-our-chief) skip.
put unformatted  "/MAINBK/" caps(v-our-mainbk) skip.
end.

                       
     find first sub-cod where sub-cod.d-cod = "eknp" and
            sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error.
     if avail sub-cod and sub-cod.rcod <> "" and sub-cod.rcod matches "*,*,*" 
     then do:
       put unformatted  "/IRS/" + substr(entry(1, sub-cod.rcod, ","), 1, 1) skip.
       put unformatted  "/SECO/" + substr(entry(1, sub-cod.rcod, ","), 2, 1) skip.
     end.




if remtrz.sbank = "TXB00" then 
put unformatted  ":52B:" v-our-bank skip.
else do:

find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
if avail bankl then do:
find first bankt where bankt.cbank = remtrz.sbank and bankt.subl = "CIF" and bankt.crc = 1 no-lock no-error.
if avail bankt then do:
put unformatted  ":52B:" bankl.crbank skip.
put unformatted  ":53C:" v-our-bank "/" bankt.acc skip.
end.
end.

end.

if remtrz.sbank <> "TXB00" then 
put unformatted  ":54B:" remtrz.rcbank skip.


put unformatted  ":57B:" remtrz.rbank skip.
put unformatted  ":59:" replace(remtrz.ba,"/","") skip.


if replace(trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]),"/RNN/", "#") <> "" then
put unformatted  "/NAME/" entry(1, replace(trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]), "/RNN/", "#"), "#") skip.
else
put unformatted  "/NAME/" entry(1, replace(trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]), "/RNN/", "#"), "#") skip.


if replace(trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]),"/RNN/", "#") <> "" then
put unformatted  "/RNN/" entry(2, replace(trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]), "/RNN/", "#"), "#") skip.
else
put unformatted  "/RNN/" entry(2, replace(trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]), "/RNN/", "#"), "#") skip.


/*
if trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]) <> "" then
put unformatted  "/NAME/" caps(entry(1, trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]),"/")) skip.
else
put unformatted  "/NAME/" entry(1, trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]),"/") skip.


if trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]) <> "" then
put unformatted  "/RNN/" entry(3, trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]),"/") skip.
else
put unformatted  "/RNN/" entry(3, trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]),"/") skip.
*/


     find first sub-cod where sub-cod.d-cod = "eknp" and
            sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error .
     if avail sub-cod and sub-cod.rcod <> "" and sub-cod.rcod matches "*,*,*"
     then do :
       put unformatted  "/IRS/" + substr(entry(2, sub-cod.rcod, ","), 1, 1) skip.
       put unformatted  "/SECO/" + substr(entry(2, sub-cod.rcod, ","), 2, 1) skip.
     end.

put unformatted  ":70:/NUM/" + ToNumber (substr(remtrz.sqn, 19)) skip.

put unformatted  "/DATE/" + substr(string(year(remtrz.valdt1)), 3, 2) 
                           string(month(remtrz.valdt1), "99")  
                           string(day(remtrz.valdt1),"99") skip.

put unformatted  "/SEND/07" skip.

put unformatted  "/VO/01" skip.

     find first sub-cod where sub-cod.d-cod = "eknp" and
        sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error .
     if avail sub-cod and sub-cod.rcod <> "" and sub-cod.rcod matches "*,*,*"
        then v-ref-knp =  entry(3, sub-cod.rcod).
        else v-ref-knp = "000".

put unformatted  "/KNP/" v-ref-knp skip.
put unformatted  "/PSO/01" skip.
put unformatted  "/PRT/50" skip.

v-temp-assign = "/ASSIGN/". 
 
     vdetpay = "" .
     do i = 1 to 4:
        vdetpay = vdetpay + trim(remtrz.detpay[i]).
     end.

     if vdetpay <> "" then do:
       if length (vdetpay) > 62 then do:
          if length (vdetpay) > 132 then do:
             if length (vdetpay) > 202 then do:
                if length (vdetpay) > 272 then do:
                   if length (vdetpay) > 342 then do:
                      if length (vdetpay) > 412 then
                        v-temp-assign = v-temp-assign + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273,70) 
                          + chr(10) + substring (vdetpay,343,70) .
                   else v-temp-assign = v-temp-assign + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273,70) 
                          + chr(10) + substring (vdetpay,343).
                   end.
                   else v-temp-assign = v-temp-assign + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273).
                end.
                else v-temp-assign = v-temp-assign + substring (vdetpay,1,62) 
                       + chr(10) + substring (vdetpay,63,70) 
                       + chr(10) + substring (vdetpay,133,70) 
                       + chr(10) + substring (vdetpay,202).
             end.
             else v-temp-assign = v-temp-assign + substring (vdetpay,1,62) 
                    + chr(10) + substring (vdetpay,63,70) 
                    + chr(10) + substring (vdetpay,133).
          end.
          else v-temp-assign = v-temp-assign + substring (vdetpay,1,62) + chr(10) + substring (vdetpay,63).
       end.
       else v-temp-assign = v-temp-assign + vdetpay .
     end.
     v-temp-assign = v-temp-assign + chr(10).

put unformatted  v-temp-assign.
put unformatted  "-\}" skip.

end.
end.
output close.

create ttmpd.
update ttmpd.ref = ttmps.ref.

/*
     assign 
     que.rcod = "0"
     que.con = "W".
     que.pid = "DRSTW".
*/

unix silent un-dos value("r" + replace(ttmps.ref,"RMZ","") + v-ext1) value("d" + replace(ttmps.ref,"RMZ","") + v-ext1).

v-text = ttmps.ref + " отправлен (прямые корр. отношения)".
run lgps.

end.
end. /* for each ttmps ... */
        

find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
v-unipath = direct_bank.aux_string[3].
v-unipath1 = direct_bank.aux_string[4].
end.


v-unidirc = "NTMAIN:" + replace(v-unipath1,"/","\\\\\\\\").

for each ttmps no-lock.
input through value ("rcp " + "d" + replace(ttmps.ref,"RMZ","") + v-ext1 + " " + v-unidirc + " ;echo $?" ). 
repeat:
  import v-resultx2.
end.
if integer(v-resultx2) <> 0 then do:
message "Произошла ошибка при копировании файла в ARC " view-as alert-box title "Внимание".
return.
end.
end.


if v-unibank <> "190501319" then do:
v-unidir = "NTMAIN:" + replace(v-unipath,"/","\\\\\\\\").

for each ttmps no-lock.
input through value ("rcp " + "d" + replace(ttmps.ref,"RMZ","") + v-ext1 + " " + v-unidir + " ;echo $?" ). 
repeat:
  import v-resultx1.
end.
if integer(v-resultx1) <> 0 then do:
message "Произошла ошибка при копировании файла в OUT " view-as alert-box title "Внимание".
return.
end.
v-copy-count = v-copy-count + 1.
end. /* for each ttmps ... */
end.

v-text =  string(time, "HH:MM:SS") + " Begin copy to " + v-unidir.
run lgps .


/* -------------------------- */
if v-unibank = "190501319" then do:

for each ttmps no-lock.
input through value ("chmod 777 " + "d" + replace(ttmps.ref,"RMZ","") + v-ext1 + " ;echo $?"). 
repeat:
  import v-resultx3.
end.
if integer(v-resultx3) <> 0 then do:
message "Произошла ошибка при Формировании файлов для копирования на СПЭД" view-as alert-box title "Внимание".
return.
end.
end.

for each ttmps no-lock.
input through value ("rcp " + "d" + replace(ttmps.ref,"RMZ","") + v-ext1 + " " + v-bta-ip + ":" + v-bta-path + " ;echo $?"). 
repeat:
  import v-resultx4.
end.
if integer(v-resultx4) <> 0 and v-cnt <> 0 then do:
message "Произошла ошибка при копировании файла на СПЭД" view-as alert-box title "Внимание".
return.
end.
end.

end.
/* -------------------------- */


v-text =  string(time, "HH:MM:SS") + " Finish copy ".
run lgps.

for each ttmpd no-lock.
find first que where que.rem = ttmpd.ref exclusive-lock no-error.
if avail que then do:
     assign 
     que.rcod = "0"
     que.con = "W".
     que.pid = "DRSTW".
end.
end.
       release que.

if v-count <> 0 then do:
if v-unibank <> "190501319" then 
message " Отправка платежей завершена. В отчете " string(v-cnt1) " RMZ платежей. " skip
        " Скопировано на выгрузку " string(v-copy-count) " файлов MT100" view-as alert-box title "Внимание".
else
message " Отправка платежей завершена. В отчете " string(v-cnt1) " RMZ платежей. " skip
        " Скопировано на выгрузку " string(v-cnt2) " файлов MT100" view-as alert-box title "Внимание".
end.


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



