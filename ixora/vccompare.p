/* vccompare.p
 * MODULE
        Название модуля - Валютный контроль.
 * DESCRIPTION
        Описание - Сверка оборотов по счету клиента и платежей Валютного Контроля.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        16.01.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        17.01.2012 aigul - добавила бд COMM
        17.01.2012 aigul - добваила if avail txb then do:
        20.01.2012 aigul - не отправлять в рассылку если отчет пустой
        26.01.2012 aigul - email to id00661
        27.01.2012 aigul - добавила время создания отчета
        30.01.2012 aigul - добавила проверку joudoc
        02.02.2012 aigul - исправила вывод импортера и экспортера
        07.03.2012 aigul - добавила сравнение платежей рмз с филиала
        19.04.2012 aigul - исправила проверку банка
        22.05.2012 aigul - заменила macthes на begins
        29.01.2013 damir - Полностью переделал. Оптимизация кода. Внедрено Техническое Задание № 1695.
        01.02.2013 damir - Добавлены дополнительные проверки, для исключения ненужных платежей. По запросу ВалКона.
*/
{global.i}
{comm-txb.i}
{vccomparevar.i}

def var v-bank as char.
def var v-rmz1 as char.
def var v-rmz2 as char.
def var v-rmz as char.
def var v-cif as char.
def var v-cifname as char.
def var s-vcourbank as char.
def var v-chk1 as logi.
def var v-chk2 as logi.
def var v-tim as char.
def var v-chk as logical.
def var v-file_1 as char init "vccompare.htm".
def var v-file_2 as char init "vccompare.xls".
def var vv-path as char.
def var v-ourbnk as char.
def var v-txbbank as char.
def var s-filial as char.

def stream vcrpt.

find cmp no-lock no-error.
v-bank = cmp.name.

find first sysc where sysc.sysc eq "ourbnk" no-lock no-error.
if avail sysc then v-ourbnk = trim(sysc.chval).

empty temp-table wrk1.
empty temp-table wrk2.

if p-type eq "rep" then do:
    {r-brfilial.i &proc = "vccompare-dat"}
    if avail comm.txb then v-ourbnk = comm.txb.bank.
    else v-ourbnk = "".
    if v-ourbnk eq "" then v-ourbnk = "TXB00".
end.
if p-type eq "proc" then do:
    if v-ourbnk eq "TXB00" then do:
        if bank.cmp.name matches ("*МКО*") then vv-path = '/data/'.
        else vv-path = '/data/b'.

        for each comm.txb where comm.txb.consolid eq true no-lock:
            if connected ("txb") then disconnect "txb".
            if bank.cmp.name matches ("*МКО*") and (comm.txb.txb = 0 or comm.txb.txb = 3 or comm.txb.txb = 5 or comm.txb.txb = 7 or comm.txb.txb = 8
            or comm.txb.txb = 9 or comm.txb.txb = 10 or comm.txb.txb = 11 or comm.txb.txb = 12 or comm.txb.txb = 13 or comm.txb.txb = 14 or
            comm.txb.txb = 15) then next.
            connect value(" -db " + replace(comm.txb.path,'/data/',vv-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vccompare-dat.
        end.
        if connected ("txb") then disconnect "txb".
    end.
    else do:
        find first comm.txb where comm.txb.consolid eq true and comm.txb.bank eq v-ourbnk no-lock no-error.
        if avail comm.txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vccompare-dat.
        end.
        if connected ("txb") then disconnect "txb".
    end.
end.

if v-ourbnk eq "TXB00" then s-filial = "ALL".
else s-filial = "ONE".

v-tim = string(time,"HH:MM:SS").
find first cmp no-lock no-error.

if p-type eq "rep" then output stream vcrpt to value(v-file_1).
else output stream vcrpt to value(v-file_2).

{html-title.i &title = "Сверка платежей" &stream = "stream vcrpt"}

put stream vcrpt unformatted
   "<P align=center style='font-size:12pt;font:bold;font-family:Times New Roman'>Сверка текущего счета клиента и платежей ВК<BR>за дату c " +
   string(v-dt1, "99/99/9999") + " по " + string(v-dt2, "99/99/9999") + "<BR>время создания отчета " v-tim + "</P>" skip
   "<P align=center style='font-size:12pt;font:bold;font-family:Times New Roman'>Платежи, прошедшие через счет клиента, но не внесенные в базу ВК</P>" skip.

put stream vcrpt unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream vcrpt unformatted
    "<TR align=center style='font-size:10pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
/*1*/    "<TD>Филиал</TD>" skip
/*2*/    "<TD>Клиент</TD>" skip
/*3*/    "<TD>CIF-код</TD>" skip
/*4*/    "<TD>КНП</TD>" skip
/*5*/    "<TD>Дата</TD>" skip
/*6*/    "<TD>Валюта<br>платежа</TD>" skip
/*7*/    "<TD>Сумма платежа</TD>" skip
/*8*/    "<TD>Номер проводки</TD>" skip
/*9*/    "<TD>Дата проводки</TD>" skip
/*10*/   "<TD>Примечание</TD>" skip
/*11*/   "<TD>Документ</TD>" skip
/*12*/   "<TD>Счет ГК<br>по<br>дебету</TD>" skip
/*13*/   "<TD>Счет ГК<br>по<br>кредиту</TD>" skip
/*14*/   "<TD>Тип платежа</TD>" skip
    "</TR>" skip.

v-chk1 = no.
nextWRK1:
for each wrk1 where wrk1.type eq "B" and (s-filial eq "ALL" or wrk1.txb eq v-ourbnk) no-lock break by wrk1.txb:
    if substr(trim(wrk1.KOd),1,1) eq "1" and substr(trim(wrk1.KBe),1,1) eq "1" then next nextWRK1.
    if lookup(wrk1.KOd,"11,12,13") gt 0 or lookup(wrk1.KBe,"11,12,13") gt 0 then next nextWRK1.
    if wrk1.sub eq "other" then if wrk1.drgl ne 287020 then next nextWRK1.
    if wrk1.AtrContract eq "none" then next nextWRK1.
    if (string(wrk1.drgl) begins "2013" and string(wrk1.crgl) begins "1052") or (string(wrk1.drgl) begins "1052" and
    string(wrk1.crgl) begins "2013") then next nextWRK1.
    if wrk1.SendRec eq "S" then do:
        if substr(trim(wrk1.KOd),1,1) eq "2" then next nextWRK1.
    end.
    else do:
        if substr(trim(wrk1.KBe),1,1) eq "2" then next nextWRK1.
    end.
    if wrk1.crc eq 1 then if wrk1.amt lt 1500000 then next nextWRK1.

    find first wrk2 where wrk2.txb eq wrk1.txb and wrk2.cif eq wrk1.cif and wrk2.amt eq wrk1.amt and wrk2.crc eq wrk1.crc and
    wrk2.jdt eq wrk1.jdt and wrk2.dntype eq (if wrk1.SendRec eq "S" then "поручение" else "извещение") no-lock no-error.
    if avail wrk2 then next nextWRK1.
    find first crc where crc.crc eq wrk1.crc no-lock no-error.

    put stream vcrpt unformatted
        "<TR align=center style='font-size:10pt;font-family:Times New Roman'>" skip
/*1*/   "<TD align=left>" wrk1.bank "</TD>" skip
/*2*/   "<TD>" wrk1.cifname "</TD>" skip
/*3*/   "<TD>" wrk1.cif "</TD>" skip
/*4*/   "<TD>" wrk1.knp "</TD>" skip
/*5*/   "<TD>" string(wrk1.rdt,"99/99/9999") "</TD>" skip.
    if avail crc then put stream vcrpt unformatted
/*6*/   "<TD>" string(crc.code) "</TD>" skip.
    else put stream vcrpt unformatted
        "<TD></TD>" skip.
    put stream vcrpt unformatted
/*7*/   "<TD>" replace(trim(string(wrk1.amt,"->>>>>>>>>>>>>>9.99")),".",",") "</TD>" skip
/*8*/   "<TD>" string(wrk1.jh) "</TD>" skip
/*9*/   "<TD>" string(wrk1.jdt,"99/99/9999") "</TD>" skip
/*10*/  "<TD>" wrk1.note "</TD>" skip
/*11*/  "<TD>" wrk1.rmz_jou "</TD>" skip
/*12*/  "<TD>" string(wrk1.drgl) "</TD>" skip
/*13*/  "<TD>" string(wrk1.crgl) "</TD>" skip.
    if wrk1.SendRec eq "S" then put stream vcrpt unformatted
/*14*/  "<TD>Снятие средств со счета</TD>" skip.
    else put stream vcrpt unformatted
/*14*/  "<TD>Поступление средств на счет</TD>" skip.
    put stream vcrpt unformatted
        "</TR>" skip.

    v-chk1 = yes.
    hide message no-pause.
    message "Base-" wrk1.txb " Journal Header-" wrk1.jh.
end.

put stream vcrpt unformatted
    "</TABLE>" skip.

put stream vcrpt unformatted
   "<P align=center style='font-size:12pt;font:bold;font-family:Times New Roman'>Платежи внесенные в базу ВК, но не прошедшие через счет клиента</P>" skip.

put stream vcrpt unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream vcrpt unformatted
    "<TR align=center style='font-size:10pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
/*1*/    "<TD>Филиал</TD>" skip
/*2*/    "<TD>Клиент</TD>" skip
/*3*/    "<TD>CIF-код</TD>" skip
/*4*/    "<TD>КНП</TD>" skip
/*5*/    "<TD>Дата</TD>" skip
/*6*/    "<TD>Валюта<br>платежа</TD>" skip
/*7*/    "<TD>Сумма платежа</TD>" skip
/*8*/    "<TD>Контракт</TD>" skip
/*9*/    "<TD>Тип<br>контракта</TD>" skip
/*10*/   "<TD>Паспорт сделки</TD>" skip
/*11*/   "<TD>Примечание</TD>" skip
/*12*/   "<TD>Тип платежа</TD>" skip
    "</TR>" skip.

v-chk2 = no.
nextWRK2:
for each wrk2 where wrk2.type eq "B" and (s-filial eq "ALL" or wrk2.txb eq v-ourbnk) no-lock break by wrk2.txb:
    find first wrk1 where wrk1.sub eq "rmz" and wrk1.txb eq wrk2.txb and wrk1.cif eq wrk2.cif and wrk1.amt eq wrk2.amt and
    wrk1.crc eq wrk2.crc and wrk1.jdt eq wrk2.jdt and wrk1.SendRec eq (if wrk2.dntype eq "поручение" then "S" else "R") and
    wrk1.AtrContract eq "present" no-lock no-error.
    if avail wrk1 then next nextWRK2.

    find first wrk1 where wrk1.sub eq "jou" and wrk1.txb eq wrk2.txb and wrk1.cif eq wrk2.cif and wrk1.amt eq wrk2.amt and
    wrk1.crc eq wrk2.crc and wrk1.jdt eq wrk2.jdt and wrk1.SendRec eq "R" and wrk1.AtrContract eq "present" no-lock no-error.
    if avail wrk1 then next nextWRK2.

    find first wrk1 where wrk1.sub eq "other" and wrk1.txb eq wrk2.txb and wrk1.cif eq wrk2.cif and wrk1.amt eq wrk2.amt and
    wrk1.crc eq wrk2.crc and wrk1.jdt eq wrk2.jdt and wrk1.SendRec eq (if wrk2.dntype eq "поручение" then "S" else "R") and
    wrk1.AtrContract = "present" no-lock no-error.
    if avail wrk1 then next nextWRK2.

    find first crc where crc.crc eq wrk2.crc no-lock no-error.

    put stream vcrpt unformatted
        "<TR align=center style='font-size:10pt'>" skip
/*1*/   "<TD align=left>" wrk2.bank "</TD>" skip
/*2*/   "<TD>" wrk2.cifname "</TD>" skip
/*3*/   "<TD>" wrk2.cif "</TD>" skip
/*4*/   "<TD>" wrk2.knp "</TD>" skip
/*5*/   "<TD>" string(wrk2.jdt,"99/99/9999") "</TD>" skip.
    if avail crc then put stream vcrpt unformatted
/*6*/   "<TD>" string(crc.code) "</TD>" skip.
    else put stream vcrpt unformatted
        "<TD></TD>" skip.
    put stream vcrpt unformatted
/*7*/   "<TD>" replace(trim(string(wrk2.amt,"->>>>>>>>>>>>>>9.99")),".",",") "</TD>" skip
/*8*/   "<TD>" wrk2.contract "</TD>" skip
/*9*/   "<TD>" wrk2.cttype "</TD>" skip
/*10*/  "<TD>" wrk2.ps "</TD>" skip
/*11*/  "<TD>" wrk2.note "</TD>" skip
/*12*/  "<TD>" wrk2.dntype "</TD>" skip
        "</TR>" skip.

    v-chk2 = yes.
    hide message no-pause.
    message "Base-" wrk2.txb " Journal Header-" wrk2.jh.
end.

put stream vcrpt unformatted
    "</TABLE>" skip.

{html-end.i "stream vcrpt"}
output stream vcrpt close.

if p-type eq "rep" then unix silent cptwin value(v-file_1) excel.

if p-type eq "proc" then do:
    unix silent value ("cp " + v-file_2 + " rep_temp.xls").
    unix silent value ("un-win rep_temp.xls Reconciliation_of_payments.xls").

    if v-chk1 or v-chk2 then do:
        if v-ourbnk eq "TXB00" then do:
            for each ofc where trim(ofc.exp[1]) matches "*p00126*" or trim(ofc.exp[1]) matches "*p00006*" no-lock:
                run mail(ofc.ofc + "@metrocombank.kz", "BANK <abpk@metrocombank.kz>","Сообщение от ДВК",
                "ВНИМАНИЕ! В вашем филиале есть платежи, которые не прошли сверку с о счетом клиента! Устраните несоответствие!",
                "", "","Reconciliation_of_payments.xls").
            end.
        end.
        else do:
            find comm.txb where comm.txb.consolid eq true and comm.txb.bank eq v-ourbnk no-lock no-error.
            if avail comm.txb then do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                run vccompare-send(comm.txb.bank,v-file_2).
            end.
            disconnect "txb".
        end.
    end.
end.

pause 0.
