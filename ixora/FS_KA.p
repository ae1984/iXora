/* FS_KA.p
 * MODULE
        Название модуля - Внутрибанковские операции.
 * DESCRIPTION
        Описание - ФС_КА «Стандартные и классифицированные активы».
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 8.8.2.19.
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        28.01.2013 damir - Внедрено Т.З. № 1218.
*/
{mainhead.i}
{FS_general.i "new"}

def temp-table t-Classific
    field k as inte
    field name as char
    field code as inte
    field gl_4 as char
    field stand_inall as deci
    field stand_foreign as deci
    field doubt_1_inall as deci
    field doubt_1_foreign as deci
    field doubt_1_specprov as deci
    field doubt_2_inall as deci
    field doubt_2_foreign as deci
    field doubt_2_specprov as deci
    field doubt_3_inall as deci
    field doubt_3_foreign as deci
    field doubt_3_specprov as deci
    field doubt_4_inall as deci
    field doubt_4_foreign as deci
    field doubt_4_specprov as deci
    field doubt_5_inall as deci
    field doubt_5_foreign as deci
    field doubt_5_specprov as deci
    field hopeless_inall as deci
    field hopeless_foreign as deci
    field hopeless_specprov as deci
    field sumall_inall as deci
    field sumall_foreign as deci
    field sumall_specprov as deci
index idx is primary k ascending
index idx2 code ascending.

def var v-file as char init "FS_KA.htm".
def var v-file_1 as char init "FS_KA_Rash1.htm".
def var v-file_2 as char init "FS_KA_Rash2.htm".
def var v-file_3 as char init "FS_KA_Rash3.htm".

def stream rep.
def stream rep_1.
def stream rep_2.
def stream rep_3.

def var r-type1 as char.
def var r-type2 as char.
def var v-bal_1 as deci.
def var v-bal_2 as deci.
def var v-bal_9 as deci.
def var v-bal_49 as deci.
def var v-bal_42 as deci.
def var v-bal_41 as deci.
def var v-bal_7 as deci.
def var v-bal_6 as deci.
def var v-bal_36 as deci.
def var v-bal_37 as deci.
def var v-balsum as deci.
def var v-DtLog as logi.
def var v-BalSum_1 as deci.
def var v-BalSum_2 as deci.
def var v-BalSum_6 as deci.
def var v-BalSum_7 as deci.
def var v-BalSum_9 as deci.
def var v-BalSum_36 as deci.
def var v-BalSum_37 as deci.
def var v-BalSum_41 as deci.
def var v-BalSum_42 as deci.
def var v-BalSum_49 as deci.
def var v-temp1 as deci.
def var v-temp2 as deci.
def var v-temp3 as deci.
def var v-temp4 as deci.
def var v-temp5 as deci.
def var v-temp6 as deci.
def var v-temp7 as deci.
def var v-temp8 as deci.
def var v-per1-30 as deci.
def var v-per31-90 as deci.
def var v-per91-180 as deci.
def var v-per181-365 as deci.
def var v-per366-730 as deci.
def var v-per731-1095 as deci.
def var v-per1096-1825 as deci.
def var v-per1826 as deci.
def var v-codesrok as char.
def var v-Sum_1424 as deci.
def var v-Sum_1401 as deci.
def var v-Sum_1403 as deci.
def var v-Sum_1411 as deci.
def var v-Sum_1417 as deci.
def var v-Sum_1740 as deci.
def var v-Sum_1741 as deci.
def var v-Sum_910011 as deci.
def var v-Sum_910012 as deci.
def var v-Sum_142810 as deci.
def var v-Sum_142820 as deci.
def var v-Sum_142841 as deci.
def var v-Sum_142842 as deci.
def var v-Sum_1428 as deci.
def var v-DisDt as inte.
def var v-Assets as logi format "да/нет".
def var v-Loans as logi format "да/нет".

def buffer b-t-wrk for t-wrk.

{FS_functions.i}
{FS_KA.i &table = "t-Classific"}

find last bank.cls.
if avail bank.cls then v-gldate = bank.cls.whn.

repeat on endkey undo,leave:
    update
        v-gldate format "99/99/9999" label 'Введите отчетную дату' validate(v-gldate <> ?, 'Дата не должна быть пустой !') skip(1)
    with row 6 centered side-label frame FS_pay.

    run sel1("Формат вывода «Расшифровка»","В тенге|В тыс.тенге").
    r-type1 = return-value.
    if r-type1 = "" then undo.

    run sel1("Формат вывода «Основная форма отчета»","В тенге|В тыс.тенге").
    r-type2 = return-value.
    if r-type2 = "" then undo.

    if r-type1 ne "" and r-type2 ne "" then leave.
end.
v-Assets = true. v-Loans = true.
hide frame FS_pay.

empty temp-table t-gldy.
empty temp-table t-wrk.
empty temp-table tgl.

s-RepName = "FS_KA".

{r-brfilial.i &proc = "FS_colldata_txb"}

display '   Ждите...   '  with row 5 frame wait centered.

if v-Loans then do:

output stream rep_1 to value(v-file_1).
{html-title.i &stream = "stream rep_1"}

put stream rep_1 unformatted
    "<P align=center style='font-size:12pt;font:bold'>«Займы клиентам»<br>за дату&nbsp;" string(v-gldate,"99/99/9999") "</P>" skip.

put stream rep_1 unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep_1 unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
/*1*/   "<TD>Номер балансового счета</TD>" skip
/*2*/   "<TD>Наименование заемщика</TD>" skip
/*3*/   "<TD>Код заемщика</TD>" skip
/*4*/   "<TD>Филиал</TD>" skip
/*5*/   "<TD>Пул МСФО</TD>" skip
/*6*/   "<TD>Группа</TD>" skip
/*7*/   "<TD>N договора, банк.займа</TD>" skip
/*8*/   "<TD>Объект кредитования</TD>" skip
/*9*/   "<TD>Код валюты</TD>" skip
/*10*/  "<TD>Дата выдачи</TD>" skip
/*11*/  "<TD>Срок погашения</TD>" skip
/*12*/  "<TD>Дата пролонгации</TD>" skip
/*13*/  "<TD>Остаток ОД (в тенге)</TD>" skip
/*14*/  "<TD>Просрочка ОД (в тенге)</TD>" skip
/*15*/  "<TD>Начисленные % (в тенге)</TD>" skip
/*16*/  "<TD>Просрочки % (в тенге)</TD>" skip
/*17*/  "<TD>Штрафы</TD>" skip
/*18*/  "<TD>Вид залога</TD>" skip
/*19*/  "<TD>Сумма гарантий (тенге)</TD>" skip
/*20*/  "<TD>Сумма депозитов (тенге)</TD>" skip
/*21*/  "<TD>Общее обеспечение</TD>" skip
/*22*/  "<TD>Общее обеспечение (Уровень 19)</TD>" skip
/*23*/  "<TD>Необеспеченная часть (тенге)</TD>" skip
/*24*/  "<TD>Отрасль экономики</TD>" skip
/*25*/  "<TD>% резерва КФН</TD>" skip
/*26*/  "<TD>Признак</TD>" skip
/*27*/  "<TD>Резерв КФН</TD>" skip
/*28*/  "<TD>% резерва МСФО</TD>" skip
/*29*/  "<TD>Резерв МСФО ОД</TD>" skip
/*30*/  "<TD>Резерв МСФО %%</TD>" skip
/*31*/  "<TD>Резерв МСФО Пеня</TD>" skip
/*32*/  "<TD>Общая сумма резерва МСФО</TD>" skip
/*33*/  "<TD>Истор.ставка</TD>" skip
/*34*/  "<TD>Признак резиденства</TD>" skip
/*35*/  "<TD>Код заемщика(Детализация)</TD>" skip
/*36*/  "<TD>Код целевого использования</TD>" skip
/*37*/  "<TD>Код классификации</TD>" skip
/*38*/  "<TD>Номер ссудного счета</TD>" skip
/*39*/  "<TD>Признак</TD>" skip
/*40*/  "<TD>Отраслевая<br>направленность займа</TD>" skip
    "</TR>" skip.

for each t-wrk where t-wrk.sub eq "lon" no-lock:
    v-bal_1 = 0. v-bal_2 = 0. v-bal_6 = 0. v-bal_7 = 0. v-bal_9 = 0. v-bal_36 = 0. v-bal_37 = 0. v-bal_41 = 0. v-bal_42 = 0. v-bal_49 = 0.

    find crc where crc.crc eq t-wrk.crc no-lock no-error.

    v-bal_1 = t-wrk.bal_1.
    v-bal_2 = t-wrk.bal_2.
    v-bal_6 = t-wrk.bal_6.
    v-bal_7 = t-wrk.bal_7.
    v-bal_9 = t-wrk.bal_9.
    v-bal_36 = t-wrk.bal_36.
    v-bal_37 = t-wrk.bal_37.
    v-bal_41 = t-wrk.bal_41.
    v-bal_42 = t-wrk.bal_42.
    v-bal_49 = t-wrk.bal_49.

    v-BalSum_1 = v-BalSum_1 + v-bal_1.
    v-BalSum_7 = v-BalSum_7 + v-bal_7.
    v-BalSum_2 = v-BalSum_2 + v-bal_2.
    v-BalSum_49 = v-BalSum_49 + v-bal_49.
    v-BalSum_9 = v-BalSum_9 + v-bal_9.
    v-BalSum_41 = v-BalSum_41 + v-bal_41.
    v-BalSum_6 = v-BalSum_6 + v-bal_6.
    v-BalSum_36 = v-BalSum_36 + v-bal_36.
    v-BalSum_37 = v-BalSum_37 + v-bal_37.

    put stream rep_1 unformatted
        "<TR style='font-size:10pt'>" skip
/*1*/   "<TD>" string(t-wrk.gl_4) "</TD>" skip
/*2*/   "<TD>" t-wrk.acc-des "</TD>" skip
/*3*/   "<TD>" t-wrk.cif "</TD>" skip
/*4*/   "<TD>" t-wrk.namebnk "</TD>" skip
/*5*/   "<TD>" t-wrk.poolId "</TD>" skip
/*6*/   "<TD>" string(t-wrk.grp) "</TD>" skip
/*7*/   "<TD>&nbsp;" t-wrk.lcnt "</TD>" skip
/*8*/   "<TD>" t-wrk.objekts "</TD>" skip.
    if avail crc then put stream rep_1 unformatted
/*9*/   "<TD>" crc.code "</TD>" skip.
    else put stream rep_1 unformatted
        "<TD></TD>" skip.
    put stream rep_1 unformatted
/*10*/  "<TD>" t-wrk.rdt "</TD>" skip
/*11*/  "<TD>" t-wrk.duedt "</TD>" skip
/*12*/  "<TD>" t-wrk.dprolong "</TD>" skip
/*13*/  "<TD>" GetNormSummRash(v-bal_1) "</TD>" skip
/*14*/  "<TD>" GetNormSummRash(v-bal_7) "</TD>" skip
/*15*/  "<TD>" GetNormSummRash(v-bal_2 + v-bal_49) "</TD>" skip
/*16*/  "<TD>" GetNormSummRash(v-bal_9) "</TD>" skip
/*17*/  "<TD>" GetNormSummRash(t-wrk.bal_16) "</TD>" skip
/*18*/  "<TD>" t-wrk.obesdes "</TD>" skip
/*19*/  "<TD>" GetNormSummRash(t-wrk.sumgarant) "</TD>" skip
/*20*/  "<TD>" GetNormSummRash(t-wrk.sumdepcrd) "</TD>" skip
/*21*/  "<TD>" GetNormSummRash(t-wrk.obesall) "</TD>" skip
/*22*/  "<TD>" GetNormSummRash(t-wrk.obesall_lev19) "</TD>" skip
/*23*/  "<TD>" GetNormSummRash(t-wrk.neobesp) "</TD>" skip
/*24*/  "<TD>" t-wrk.otrasl "</TD>" skip
/*25*/  "<TD>" GetNormSummRash(t-wrk.prcKfn) "</TD>" skip
/*26*/  "<TD></TD>" skip
/*27*/  "<TD>" GetNormSummRash(v-bal_41) "</TD>" skip
/*28*/  "<TD></TD>" skip
/*29*/  "<TD>" GetNormSummRash(v-bal_6) "</TD>" skip
/*30*/  "<TD>" GetNormSummRash(v-bal_36) "</TD>" skip
/*31*/  "<TD>" GetNormSummRash(v-bal_37) "</TD>" skip
/*32*/  "<TD>" GetNormSummRash(v-bal_6 + v-bal_36 + v-bal_37) "</TD>" skip
/*33*/  "<TD>" replace(string(t-wrk.prem_his,'zzzzz9.99'),'.',',') "</TD>" skip
/*34*/  "<TD>" t-wrk.geo "</TD>" skip
/*35*/  "<TD>" t-wrk.cifloncode "</TD>" skip
/*36*/  "<TD>" t-wrk.codeuse "</TD>" skip
/*37*/  "<TD>" t-wrk.codeclass "</TD>" skip
/*38*/  "<TD>" t-wrk.lon "</TD>" skip
/*39*/  "<TD>" t-wrk.gua "</TD>" skip
/*40*/  "<TD>" t-wrk.orienofloan "</TD>" skip
        "</TR>" skip.

    hide message no-pause.
    message 'MainLoans = ' t-wrk.lon " t-wrk.txb = " t-wrk.txb.
end.

v-Sum_1424 = 0. v-Sum_1401 = 0. v-Sum_1403 = 0. v-Sum_1411 = 0. v-Sum_1417 = 0. v-Sum_1740 = 0. v-Sum_1741 = 0. v-Sum_910011 = 0. v-Sum_910012 = 0.
v-Sum_142810 = 0. v-Sum_142820 = 0. v-Sum_142841 = 0. v-Sum_142842 = 0. v-Sum_1428 = 0.

for each t-gldy no-lock:
    if t-gldy.gl_4 = 1424 then v-Sum_1424 = v-Sum_1424 + t-gldy.balkzt.
    if t-gldy.gl_4 = 1401 then v-Sum_1401 = v-Sum_1401 + t-gldy.balkzt.
    if t-gldy.gl_4 = 1403 then v-Sum_1403 = v-Sum_1403 + t-gldy.balkzt.
    if t-gldy.gl_4 = 1411 then v-Sum_1411 = v-Sum_1411 + t-gldy.balkzt.
    if t-gldy.gl_4 = 1417 then v-Sum_1417 = v-Sum_1417 + t-gldy.balkzt.
    if t-gldy.gl_4 = 1740 then v-Sum_1740 = v-Sum_1740 + t-gldy.balkzt.
    if t-gldy.gl_4 = 1741 then v-Sum_1741 = v-Sum_1741 + t-gldy.balkzt.
    if t-gldy.gl = 910011 then v-Sum_910011 = v-Sum_910011 + t-gldy.balkzt.
    if t-gldy.gl = 910012 then v-Sum_910012 = v-Sum_910012 + t-gldy.balkzt.
    if t-gldy.gl = 142810 then v-Sum_142810 = v-Sum_142810 + t-gldy.balkzt.
    if t-gldy.gl = 142820 then v-Sum_142820 = v-Sum_142820 + t-gldy.balkzt.
    if t-gldy.gl = 142841 then v-Sum_142841 = v-Sum_142841 + t-gldy.balkzt.
    if t-gldy.gl = 142842 then v-Sum_142842 = v-Sum_142842 + t-gldy.balkzt.
    if t-gldy.gl_4 = 1428 then v-Sum_1428 = v-Sum_1428 + t-gldy.balkzt.
end.

v-Sum_910011 = - v-Sum_910011.
v-Sum_910012 = - v-Sum_910012.
v-Sum_142810 = - v-Sum_142810.
v-Sum_142820 = - v-Sum_142820.
v-Sum_142841 = - v-Sum_142841.
v-Sum_142842 = - v-Sum_142842.
v-Sum_1428 = - v-Sum_1428.

put stream rep_1 unformatted
    "<TR style='font-size:10pt'>" skip
/*1*/   "<TD>1417</TD>" skip
/*2*/   "<TD>МКО</TD>" skip
/*3*/   "<TD></TD>" skip
/*4*/   '<TD>АО "ForteBank"</TD>' skip
/*5*/   "<TD></TD>" skip
/*6*/   "<TD>92</TD>" skip
/*7*/   "<TD></TD>" skip
/*8*/   "<TD>Гражданам на потребительские цели</TD>" skip
/*9*/   "<TD>KZT</TD>" skip
/*10*/  "<TD></TD>" skip
/*11*/  "<TD></TD>" skip
/*12*/  "<TD></TD>" skip
/*13*/  "<TD>" GetNormSummRash((v-Sum_1401 + v-Sum_1403 + v-Sum_1411 + v-Sum_1417) - v-BalSum_1) "</TD>" skip
/*14*/  "<TD>" GetNormSummRash(v-Sum_1424 - v-BalSum_7) "</TD>" skip
/*15*/  "<TD>" GetNormSummRash(v-Sum_1740 - (v-BalSum_2 + v-BalSum_49)) "</TD>" skip
/*16*/  "<TD>" GetNormSummRash(v-Sum_1741 - v-BalSum_9) "</TD>" skip
/*17*/  "<TD></TD>" skip
/*18*/  "<TD></TD>" skip
/*19*/  "<TD></TD>" skip
/*20*/  "<TD></TD>" skip
/*21*/  "<TD></TD>" skip
/*22*/  "<TD></TD>" skip
/*23*/  "<TD></TD>" skip
/*24*/  "<TD></TD>" skip
/*25*/  "<TD></TD>" skip
/*26*/  "<TD></TD>" skip
/*27*/  "<TD>" GetNormSummRash((v-Sum_910011 + v-Sum_910012) - v-BalSum_41) "</TD>" skip
/*28*/  "<TD></TD>" skip
/*29*/  "<TD>" GetNormSummRash((v-Sum_142810 + v-Sum_142820) - v-BalSum_6) "</TD>" skip
/*30*/  "<TD>" GetNormSummRash(v-Sum_142841 - v-BalSum_36) "</TD>" skip
/*31*/  "<TD>" GetNormSummRash(v-Sum_142842 - v-BalSum_37) "</TD>" skip
/*32*/  "<TD>" GetNormSummRash(v-Sum_1428 - (v-BalSum_6 + v-BalSum_36 + v-BalSum_37)) "</TD>" skip
/*33*/  "<TD></TD>" skip
/*34*/  "<TD></TD>" skip
/*35*/  "<TD></TD>" skip
/*36*/  "<TD></TD>" skip
/*37*/  "<TD></TD>" skip
/*38*/  "<TD></TD>" skip
/*39*/  "<TD></TD>" skip
/*40*/  "<TD></TD>" skip
    "</TR>" skip.

put stream rep_1 unformatted
    "</TABLE>" skip.

{html-end.i "stream rep_1"}
output stream rep_1 close.

unix silent cptwin value(v-file_1) excel.

end.

if v-Assets then do:

output stream rep_2 to value(v-file_2).
{html-title.i &stream = "stream rep_2"}

put stream rep_2 unformatted
    "<P align=center style='font-size:12pt;font:bold'>«Активы»<br>за дату&nbsp;" string(v-gldate,"99/99/9999") "</P>" skip.

put stream rep_2 unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep_2 unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
/*1*/   "<TD>Номер балансового счета</TD>" skip
/*2*/   "<TD>Счет ГК</TD>" skip
/*3*/   "<TD>7 - значный счет ГК</TD>" skip
/*4*/   "<TD>Наименование счета ГК</TD>" skip
/*5*/   "<TD>Номер лицевого счета</TD>" skip
/*6*/   "<TD>Наименование клиента</TD>" skip
/*7*/   "<TD>Признак резидентства</TD>" skip
/*8*/   "<TD>Код валюты</TD>" skip
/*9*/   "<TD>Классификационная категория</TD>" skip
/*10*/  "<TD>код строки</TD>" skip
/*11*/  "<TD>Баланс</TD>" skip
/*12*/  "<TD>subled</TD>" skip
    "</TR>" skip.

Assets:
for each tgl where tgl.sub-type ne "lon" no-lock break by tgl.gl4:
    if not (string(tgl.gl) begins "1") then next Assets.

    v-codesrok = ''. v-DtLog = false.
    find t-wrk where t-wrk.txb eq tgl.txb and t-wrk.sub eq tgl.sub-type and t-wrk.acc eq tgl.acc no-lock no-error.
    find crc where crc.crc eq tgl.crc no-lock no-error.

    put stream rep_2 unformatted
        "<TR style='font-size:10pt'>" skip
/*1*/   "<TD>" string(tgl.gl4) "</TD>" skip
/*2*/   "<TD>" string(tgl.gl) "</TD>" skip
/*3*/   "<TD>" string(tgl.gl7) "</TD>" skip
/*4*/   "<TD>" string(tgl.gl-des) "</TD>" skip
/*5*/   "<TD>" tgl.acc "</TD>" skip.
    if avail t-wrk then put stream rep_2 unformatted
/*6*/   "<TD>" t-wrk.clientname "</TD>" skip.
    else put stream rep_2 unformatted
/*6*/   "<TD></TD>" skip.
    put stream rep_2 unformatted
/*7*/   "<TD>" substr(trim(tgl.geo),3,1) "</TD>" skip.
    if avail crc then put stream rep_2 unformatted
/*8*/   "<TD>" crc.code "</TD>" skip.
    else put stream rep_2 unformatted
        "<TD></TD>" skip.
    put stream rep_2 unformatted
/*9*/   "<TD>Стандартные</TD>" skip
/*10*/  "<TD></TD>" skip
/*11*/  "<TD>" GetNormSummRash(tgl.sum) "</TD>" skip
/*12*/  "<TD>" tgl.sub-type "</TD>" skip
        "</TR>" skip.

    run Distribution_Of_Amounts(tgl.txb,tgl.sub-type,tgl.level,tgl.sum,tgl.gl4,tgl.gl7,tgl.acc).

    hide message no-pause.
    message 'Assets.acc = ' tgl.acc " tgl.txb = " tgl.txb.
end.

put stream rep_2 unformatted
    "</TABLE>" skip.

{html-end.i "stream rep_2"}
output stream rep_2 close.

unix silent cptwin value(v-file_2) excel.

end.

output stream rep_3 to value(v-file_3).
{html-title.i &stream = "stream rep_3"}

put stream rep_3 unformatted
    "<P align=center style='font-size:12pt;font:bold'>Дополнительная расшифровка по кредитным счетам Главной Книги<br>за дату&nbsp;" string(v-gldate,"99/99/9999") "</P>" skip.

put stream rep_3 unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep_3 unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
/*1*/   "<TD>Номер балансового счета</TD>" skip
/*2*/   "<TD>Счет ГК</TD>" skip
/*3*/   "<TD>7 - значный счет ГК</TD>" skip
/*4*/   "<TD>Наименование счета ГК</TD>" skip
/*5*/   "<TD>Номер лицевого счета</TD>" skip
/*6*/   "<TD>Признак резидентства</TD>" skip
/*7*/   "<TD>Код валюты</TD>" skip
/*8*/   "<TD>Классификационная категория</TD>" skip
/*9*/   "<TD>код строки</TD>" skip
/*10*/  "<TD>Баланс</TD>" skip
    "</TR>" skip.

Loans:
for each tgl where tgl.sub-type eq "lon" no-lock break by tgl.gl4:
    v-codesrok = ''. v-DtLog = false.
    find crc where crc.crc eq tgl.crc no-lock no-error.

    put stream rep_3 unformatted
        "<TR style='font-size:10pt'>" skip
/*1*/   "<TD>" string(tgl.gl4) "</TD>" skip
/*2*/   "<TD>" string(tgl.gl) "</TD>" skip
/*3*/   "<TD>" string(tgl.gl7) "</TD>" skip
/*4*/   "<TD>" string(tgl.gl-des) "</TD>" skip
/*5*/   "<TD>" tgl.acc "</TD>" skip
/*6*/   "<TD>" substr(trim(tgl.geo),3,1) "</TD>" skip.
    if avail crc then put stream rep_3 unformatted
/*7*/   "<TD>" crc.code "</TD>" skip.
    else put stream rep_3 unformatted
/*7*/   "<TD>Не найдена</TD>" skip.
    put stream rep_3 unformatted
/*8*/   "<TD></TD>" skip
/*9*/   "<TD></TD>" skip
/*10*/  "<TD>" GetNormSummRash(tgl.sum) "</TD>" skip
        "</TR>" skip.

    run Distribution_Of_Amounts(tgl.txb,tgl.sub-type,tgl.level,tgl.sum,tgl.gl4,tgl.gl7,tgl.acc).

    hide message no-pause.
    message "Loans.acc = " tgl.acc " tgl.txb = " tgl.txb.
end.

put stream rep_3 unformatted
    "</TABLE>" skip.

{html-end.i "stream rep_3"}
output stream rep_3 close.

unix silent cptwin value(v-file_3) excel.

output stream rep to value(v-file).
{html-title.i &stream = "stream rep"}

put stream rep unformatted
    '<P align=right style="font-size:8pt;font-family:Times New Roman">Приложение 3 к Правилам<br>представления отчетности банками<br>
    второго уровня Республики Казахстан</P>' skip
    '<P align=center style="font-size:9pt;font:bold;font-family:Times New Roman">Стандартные и классифицированные активы<br>
    АО "ForteBank"<br>(наименование банка)<br>
    по состоянию на&nbsp;' string(v-gldate,"99/99/9999") '</P>' skip.

put stream rep unformatted
    "<P align=right style='font-size:8pt;font:bold;font-family:Times New Roman;vertical-align:middle'>(в тысячах тенге)</P>" skip.

put stream rep unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:8pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD colspan=2 rowspan=4>Активы</TD>" skip
    "<TD colspan=2 rowspan=2>Стандартные</TD>" skip
    "<TD colspan=15>Сомнительные</TD>" skip
    "<TD colspan=2></TD>" skip
    "<TD rowspan=3>Специаль-<br>ные<br>провизии</TD>" skip
    "<TD colspan=2></TD>" skip
    "<TD rowspan=3>Итого<br>провизии</TD>" skip
    "</TR>" skip
    "<TR align=center style='font-size:8pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD colspan=2>Сомнительные 1<br>категории</TD>" skip
    "<TD rowspan=2>Специаль-<br>ные<br>провизии</TD>" skip
    "<TD colspan=2>Сомнительные 2<br>категории</TD>" skip
    "<TD rowspan=2>Специаль-<br>ные<br>провизии</TD>" skip
    "<TD colspan=2>Сомнительные 3<br>категории</TD>" skip
    "<TD rowspan=2>Специаль-<br>ные<br>провизии</TD>" skip
    "<TD colspan=2>Сомнительные 4<br>категории</TD>" skip
    "<TD rowspan=2>Специаль-<br>ные<br>провизии</TD>" skip
    "<TD colspan=2>Сомнительные 5<br>категории</TD>" skip
    "<TD rowspan=2>Специаль-<br>ные<br>провизии</TD>" skip
    "<TD colspan=2>Безнадежные</TD>" skip
    "<TD colspan=2>Всего</TD>" skip
    "</TR>" skip
    "<TR align=center style='font-size:8pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD>Всего</TD>" skip
    "<TD>из них в<br>иностранной<br>валюте</TD>" skip
    "<TD>Всего</TD>" skip
    "<TD>из них в<br>иностранной<br>валюте</TD>" skip
    "<TD>Всего</TD>" skip
    "<TD>из них в<br>иностранной<br>валюте</TD>" skip
    "<TD>Всего</TD>" skip
    "<TD>из них в<br>иностранной<br>валюте</TD>" skip
    "<TD>Всего</TD>" skip
    "<TD>из них в<br>иностранной<br>валюте</TD>" skip
    "<TD>Всего</TD>" skip
    "<TD>из них в<br>иностранной<br>валюте</TD>" skip
    "<TD>Всего</TD>" skip
    "<TD>из них в<br>иностранной<br>валюте</TD>" skip
    "<TD>Всего</TD>" skip
    "<TD>из них в<br>иностранной<br>валюте</TD>" skip
    "</TR>" skip
    "<TR align=center style='font-size:8pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD>1</TD>" skip
    "<TD>2</TD>" skip
    "<TD>3</TD>" skip
    "<TD>4</TD>" skip
    "<TD>5</TD>" skip
    "<TD>6</TD>" skip
    "<TD>7</TD>" skip
    "<TD>8</TD>" skip
    "<TD>9</TD>" skip
    "<TD>10</TD>" skip
    "<TD>11</TD>" skip
    "<TD>12</TD>" skip
    "<TD>13</TD>" skip
    "<TD>14</TD>" skip
    "<TD>15</TD>" skip
    "<TD>16</TD>" skip
    "<TD>17</TD>" skip
    "<TD>18</TD>" skip
    "<TD>19</TD>" skip
    "<TD>20</TD>" skip
    "<TD>21</TD>" skip
    "<TD>22</TD>" skip
    "<TD>23</TD>" skip
    "</TR>" skip.

run AdditionalCalculation.

for each t-Classific exclusive-lock:
    put stream rep unformatted
        "<TR align=center style='font-size:8pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
        "<TD>" string(t-Classific.code) "</TD>" skip
        "<TD>" t-Classific.name "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.stand_inall) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.stand_foreign) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_1_inall) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_1_foreign) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_1_specprov) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_2_inall) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_2_foreign) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_2_specprov) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_3_inall) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_3_foreign) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_3_specprov) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_4_inall) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_4_foreign) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_4_specprov) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_5_inall) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_5_foreign) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.doubt_5_specprov) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.hopeless_inall) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.hopeless_foreign) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.hopeless_specprov) "</TD>" skip.

    t-Classific.sumall_inall = t-Classific.stand_inall + t-Classific.doubt_1_inall + t-Classific.doubt_2_inall + t-Classific.doubt_3_inall +
    t-Classific.doubt_4_inall + t-Classific.doubt_5_inall + t-Classific.hopeless_inall.
    t-Classific.sumall_foreign = t-Classific.stand_foreign + t-Classific.doubt_1_foreign + t-Classific.doubt_2_foreign + t-Classific.doubt_3_foreign +
    t-Classific.doubt_4_foreign + t-Classific.doubt_5_foreign + t-Classific.hopeless_foreign.
    t-Classific.sumall_specprov = t-Classific.doubt_1_specprov + t-Classific.doubt_2_specprov + t-Classific.doubt_3_specprov +
    t-Classific.doubt_4_specprov + t-Classific.doubt_5_specprov + t-Classific.hopeless_specprov.

    put stream rep unformatted
        "<TD>" GetNormSumm(t-Classific.sumall_inall) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.sumall_foreign) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.sumall_specprov) "</TD>" skip
        "</TR>" skip.
end.
find first t-Classific no-lock no-error.

put stream rep unformatted
    "</TABLE>" skip.

{html-end.i "stream rep"}
output stream rep close.

unix silent cptwin value(v-file) excel.

empty temp-table t-gldy.
empty temp-table t-wrk.
empty temp-table tgl.

procedure Distribution_Of_Amounts:
    def input parameter p-txb as char.
    def input parameter p-sub-type as char.
    def input parameter p-level as inte.
    def input parameter p-sum as deci.
    def input parameter p-gl_4 as inte.
    def input parameter p-gl_7 as inte.
    def input parameter p-acc as char.

    find first b-t-wrk where b-t-wrk.txb eq p-txb and b-t-wrk.sub eq "lon" and b-t-wrk.lon eq p-acc no-lock no-error.

    for each t-Classific exclusive-lock:
        if t-Classific.code eq 1 then do:
            if lookup(string(p-gl_4),"1051,1052,1103,1254,1264") gt 0 then do:
                run Class_Distribution_Simple(p-sum,0).
                if inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution_Simple(0,p-sum).
            end.
        end.
        else if t-Classific.code eq 2 then do:
            if lookup(string(p-gl_4),"1052") gt 0 then do:
                if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution_Simple(p-sum,0).
                if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution_Simple(0,p-sum).
            end.
        end.
        else if t-Classific.code eq 4 then do:
            if avail b-t-wrk then do:
                if lookup(string(p-gl_4),"1301,1302,1303,1304,1305,1306,1309,1321,1322,1323,1326,1327,1328") gt 0 then do:
                    run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                end.
                if lookup(string(p-gl_4),"1319,1329") gt 0 then do:
                    run Class_Distribution(b-t-wrk.codeclass,0,0,p-sum).
                end.
            end.
        end.
        else if t-Classific.code eq 5 then do:
            if avail b-t-wrk then do:
                if lookup(string(p-gl_4),"1301,1302,1303,1304,1305,1306,1309,1321,1322,1323,1326,1327,1328") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                end.
                if lookup(string(p-gl_4),"1319,1329") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,0,0,p-sum).
                end.
            end.
        end.
        else if t-Classific.code eq 6 then do:
            if avail b-t-wrk then do:
                if lookup(b-t-wrk.cifloncode,"6") gt 0 then do:
                    if lookup(string(p-gl_4),"1401,1403,1405,1407,1409,1411,1417,1420,1421,1422,1423,1424,1425,1429") gt 0 then do:
                        run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                        if inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                    end.
                    if lookup(string(p-level),"41") gt 0 then do:
                        run Class_Distribution(b-t-wrk.codeclass,0,0,p-sum).
                    end.
                end.
            end.
        end.
        else if t-Classific.code eq 7 then do:
            if avail b-t-wrk then do:
                if lookup(string(p-gl_4),"1428,1451") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,0,0,p-sum).
                end.
            end.
        end.
        else if t-Classific.code eq 11 then do:
            if avail b-t-wrk then do:
                if lookup(b-t-wrk.cifloncode,"9") gt 0 and lookup(b-t-wrk.codeuse,"11") gt 0 and lookup(string(p-level),"1,7,41") gt 0 then do:
                    if lookup(string(p-level),"1,7") gt 0 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if lookup(string(p-level),"1,7") gt 0 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                    if lookup(string(p-level),"41") gt 0 then run Class_Distribution(b-t-wrk.codeclass,0,0,p-sum).
                end.
            end.
        end.
        else if t-Classific.code eq 12 then do:
            if avail b-t-wrk then do:
                if lookup(b-t-wrk.cifloncode,"9") gt 0 and lookup(b-t-wrk.codeuse,"11") gt 0 and b-t-wrk.orienofloan matches "*автотранспорт*"
                and lookup(string(p-level),"1,7") gt 0 then do:
                    run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 13 then do:
            if avail b-t-wrk then do:
                if b-t-wrk.orienofloan matches "*ипотечные жилищные займы*" and lookup(string(p-level),"1,7") gt 0 then do:
                    run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 14 then do:
            if avail b-t-wrk then do:
                if b-t-wrk.orienofloan matches "*ипотечные жилищные займы*" and lookup(string(p-level),"1,7") gt 0 then do:
                    run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 15 then do:
            if avail b-t-wrk then do:
                if lookup(b-t-wrk.cifloncode,"9") gt 0 and lookup(b-t-wrk.codeuse,"15") gt 0 and lookup(string(p-level),"1,7") gt 0 then do:
                    run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 16 then do:
            if avail b-t-wrk then do:
                if lookup(string(p-level),"1,7") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 17 then do:
            if avail b-t-wrk then do:
                if b-t-wrk.objekts matches "*гражданам на потребительские цели*" and lookup(string(p-level),"1,7") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 18 then do:
            if avail b-t-wrk then do:
                if b-t-wrk.objekts matches "*на приобретение автотранспорта*" and lookup(string(p-level),"1,7") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 19 then do:
            if avail b-t-wrk then do:
                if b-t-wrk.objekts matches "*на строительство, покупку и (или) ремонт жилья*" and lookup(string(p-level),"1,7") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 20 then do:
            if avail b-t-wrk then do:
                if b-t-wrk.objekts matches "*ипотечные жилищные займы*" and lookup(string(p-level),"1,7") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 21 then do:
            if avail b-t-wrk then do:
                if not (b-t-wrk.objekts matches "*гражданам на потребительские цели*") and lookup(string(p-level),"1,7") gt 0 then do:
                    if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                end.
            end.
        end.
        else if t-Classific.code eq 23 then do:
            if avail b-t-wrk then do:
                if lookup(b-t-wrk.cifloncode,"23") gt 0 and lookup(string(p-level),"1,7,41") gt 0 then do:
                    if lookup(string(p-level),"1,7") gt 0 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if lookup(string(p-level),"1,7") gt 0 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                    if lookup(string(p-level),"41") gt 0 then run Class_Distribution(b-t-wrk.codeclass,0,0,p-sum).
                end.
            end.
        end.
        else if t-Classific.code eq 24 then do:
            if avail b-t-wrk then do:
                if lookup(b-t-wrk.cifloncode,"24") gt 0 and lookup(string(p-level),"1,7,41") gt 0 then do:
                    if lookup(string(p-level),"1,7") gt 0 then run Class_Distribution(b-t-wrk.codeclass,p-sum,0,0).
                    if lookup(string(p-level),"1,7") gt 0 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                    run Class_Distribution(b-t-wrk.codeclass,0,p-sum,0).
                    if lookup(string(p-level),"41") gt 0 then run Class_Distribution(b-t-wrk.codeclass,0,0,p-sum).
                end.
            end.
        end.
        else if t-Classific.code eq 25 then do:
            if lookup(string(p-gl_4),"1461,1462") gt 0 then do:
                run Class_Distribution_Simple(p-sum,0).
            end.
        end.
        else if t-Classific.code eq 26 then do:
            if lookup(string(p-gl_4),"1461,1462") gt 0 then do:
                if inte(substr(string(p-gl_7),5,1)) eq 1 then run Class_Distribution_Simple(p-sum,0).
            end.
        end.
        else if t-Classific.code eq 27 then do:
            if lookup(string(p-gl_4),"1461,1462") gt 0 then do:
                if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution_Simple(p-sum,0).
            end.
        end.
        else if t-Classific.code eq 28 then do:
            if lookup(string(p-gl_4),"1201,1205,1206,1208,1209,1481,1483") gt 0 then do:
                run Class_Distribution_Simple(p-sum,0).
                if inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution_Simple(0,p-sum).
            end.
        end.
        else if t-Classific.code eq 29 then do:
            if lookup(string(p-gl_4),"1201,1205,1206,1208,1209,1481,1483") gt 0 then do:
                if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution_Simple(p-sum,0).
                if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then
                run Class_Distribution_Simple(0,p-sum).
            end.
        end.
        else if t-Classific.code eq 30 then do:
            if lookup(string(p-gl_4),"1445,1799,1851,1852,1854,1855,1856,1860,1861,1864,1867,1793") gt 0 then do:
                run Class_Distribution_Simple(p-sum,0).
                if inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution_Simple(0,p-sum).
            end.
        end.
        else if t-Classific.code eq 31 then do:
            if lookup(string(p-gl_4),"1445,1799,1851,1852,1854,1855,1856,1860,1861,1864,1867,1793") gt 0 then do:
                if inte(substr(string(p-gl_7),5,1)) eq 2 then run Class_Distribution_Simple(p-sum,0).
                if inte(substr(string(p-gl_7),5,1)) eq 2 and inte(substr(string(p-gl_7),7,1)) ne 1 then run Class_Distribution_Simple(0,p-sum).
            end.
        end.
    end.
    find first t-Classific no-lock no-error.
end procedure.

procedure Class_Distribution_Simple:
    def input parameter p-sum1 as deci.
    def input parameter p-sum2 as deci.

    t-Classific.stand_inall = t-Classific.stand_inall + p-sum1.
    t-Classific.stand_foreign = t-Classific.stand_foreign + p-sum2.
end.

procedure Class_Distribution:
    def input parameter p-codeclass as char.
    def input parameter p-sum1 as deci.
    def input parameter p-sum2 as deci.
    def input parameter p-sum3 as deci.

    if p-codeclass matches "*Стандартные*" then do:
        t-Classific.stand_inall = t-Classific.stand_inall + p-sum1.
        t-Classific.stand_foreign = t-Classific.stand_foreign + p-sum2.
    end.
    else if p-codeclass matches "*Сомнительные 1 категории*" then do:
        t-Classific.doubt_1_inall = t-Classific.doubt_1_inall + p-sum1.
        t-Classific.doubt_1_foreign = t-Classific.doubt_1_foreign + p-sum2.
        t-Classific.doubt_1_specprov = t-Classific.doubt_1_specprov + p-sum3.
    end.
    else if p-codeclass matches "*Сомнительные 2 категории*" then do:
        t-Classific.doubt_2_inall = t-Classific.doubt_2_inall + p-sum1.
        t-Classific.doubt_2_foreign = t-Classific.doubt_2_foreign + p-sum2.
        t-Classific.doubt_2_specprov = t-Classific.doubt_2_specprov + p-sum3.
    end.
    else if p-codeclass matches "*Сомнительные 3 категории*" then do:
        t-Classific.doubt_3_inall = t-Classific.doubt_3_inall + p-sum1.
        t-Classific.doubt_3_foreign = t-Classific.doubt_3_foreign + p-sum2.
        t-Classific.doubt_3_specprov = t-Classific.doubt_3_specprov + p-sum3.
    end.
    else if p-codeclass matches "*Сомнительные 4 категории*" then do:
        t-Classific.doubt_4_inall = t-Classific.doubt_4_inall + p-sum1.
        t-Classific.doubt_4_foreign = t-Classific.doubt_4_foreign + p-sum2.
        t-Classific.doubt_4_specprov = t-Classific.doubt_4_specprov + p-sum3.
    end.
    else if p-codeclass matches "*Сомнительные 5 категории*" then do:
        t-Classific.doubt_5_inall = t-Classific.doubt_5_inall + p-sum1.
        t-Classific.doubt_5_foreign = t-Classific.doubt_5_foreign + p-sum2.
        t-Classific.doubt_5_specprov = t-Classific.doubt_5_specprov + p-sum3.
    end.
    else if p-codeclass matches "*Безнадежные*" then do:
        t-Classific.hopeless_inall = t-Classific.hopeless_inall + p-sum1.
        t-Classific.hopeless_foreign = t-Classific.hopeless_foreign + p-sum2.
        t-Classific.hopeless_specprov = t-Classific.hopeless_specprov + p-sum3.
    end.
end procedure.

procedure AdditionalCalculation:
    find t-Classific where t-Classific.code eq 11 exclusive-lock no-error.
    if avail t-Classific then do:
        t-Classific.hopeless_inall = t-Classific.hopeless_inall + (v-Sum_1424 - v-BalSum_7).
        t-Classific.hopeless_specprov = t-Classific.hopeless_specprov + (v-Sum_142810 + v-Sum_142820) - v-BalSum_6.
    end.
    find t-Classific where t-Classific.code eq 11 no-lock no-error.

    find t-Classific where t-Classific.code eq 10 exclusive-lock no-error.
    if avail t-Classific then do: run AdditionalSearch("11,13,15"). end.
    find t-Classific where t-Classific.code eq 10 no-lock no-error.

    find t-Classific where t-Classific.code eq 9 exclusive-lock no-error.
    if avail t-Classific then do: run AdditionalSearch("10,16"). end.
    find t-Classific where t-Classific.code eq 9 no-lock no-error.

    find t-Classific where t-Classific.code eq 22 exclusive-lock no-error.
    if avail t-Classific then do: run AdditionalSearch("23,24"). end.
    find t-Classific where t-Classific.code eq 22 no-lock no-error.

    find t-Classific where t-Classific.code eq 3 exclusive-lock no-error.
    if avail t-Classific then do: run AdditionalSearch("4,6,9,22"). end.
    find t-Classific where t-Classific.code eq 3 no-lock no-error.

    find t-Classific where t-Classific.code eq 32 exclusive-lock no-error.
    if avail t-Classific then do: run AdditionalSearch("1,3,25,28,30"). end.
    find t-Classific where t-Classific.code eq 32 no-lock no-error.


end procedure.

procedure AdditionalSearch:
    def input parameter p-code as char.

    def buffer b-t-Classific for t-Classific.

    nextClassific:
    for each b-t-Classific no-lock:
        if lookup(string(b-t-Classific.code),p-code) eq 0 then next nextClassific.

        t-Classific.stand_inall = t-Classific.stand_inall + b-t-Classific.stand_inall.
        t-Classific.stand_foreign = t-Classific.stand_foreign + b-t-Classific.stand_foreign.
        t-Classific.doubt_1_inall = t-Classific.doubt_1_inall + b-t-Classific.doubt_1_inall.
        t-Classific.doubt_1_foreign = t-Classific.doubt_1_foreign + b-t-Classific.doubt_1_foreign.
        t-Classific.doubt_1_specprov = t-Classific.doubt_1_specprov + b-t-Classific.doubt_1_specprov.
        t-Classific.doubt_2_inall = t-Classific.doubt_2_inall + b-t-Classific.doubt_2_inall.
        t-Classific.doubt_2_foreign = t-Classific.doubt_2_foreign + b-t-Classific.doubt_2_foreign.
        t-Classific.doubt_2_specprov = t-Classific.doubt_2_specprov + b-t-Classific.doubt_2_specprov.
        t-Classific.doubt_3_inall = t-Classific.doubt_3_inall + b-t-Classific.doubt_3_inall.
        t-Classific.doubt_3_foreign = t-Classific.doubt_3_foreign + b-t-Classific.doubt_3_foreign.
        t-Classific.doubt_3_specprov = t-Classific.doubt_3_specprov + b-t-Classific.doubt_3_specprov.
        t-Classific.doubt_4_inall = t-Classific.doubt_4_inall + b-t-Classific.doubt_4_inall.
        t-Classific.doubt_4_foreign = t-Classific.doubt_4_foreign + b-t-Classific.doubt_4_foreign.
        t-Classific.doubt_4_specprov = t-Classific.doubt_4_specprov + b-t-Classific.doubt_4_specprov.
        t-Classific.doubt_5_inall = t-Classific.doubt_5_inall + b-t-Classific.doubt_5_inall.
        t-Classific.doubt_5_foreign = t-Classific.doubt_5_foreign + b-t-Classific.doubt_5_foreign.
        t-Classific.doubt_5_specprov = t-Classific.doubt_5_specprov + b-t-Classific.doubt_5_specprov.
        t-Classific.hopeless_inall = t-Classific.hopeless_inall + b-t-Classific.hopeless_inall.
        t-Classific.hopeless_foreign = t-Classific.hopeless_foreign + b-t-Classific.hopeless_foreign.
        t-Classific.hopeless_specprov = t-Classific.hopeless_specprov + b-t-Classific.hopeless_specprov.
    end.
end procedure.
