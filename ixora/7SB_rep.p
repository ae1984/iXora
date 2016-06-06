/* 7SB_rep.p
 * MODULE
        Название модуля - Кредиты.
 * DESCRIPTION
        Описание - Автоматизация отчета 7СБ <Отчет о кредитах (фермерским) хозяйствам и ставкам вознаграждения по ним>.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 3.4.2.22.
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        28.01.2013 damir - Внедрено Т.З. № 1217.
*/
{mainhead.i}
{FS_general.i "new"}

def temp-table t-Classific
    field k as inte
    field name as char
    field code as inte
    field gl_4 as char
    field short_Nat_sum as deci
    field short_Nat_Aver_num as deci
    field short_Nat_Aver_val as deci
    field short_Free_sum as deci
    field short_Free_Aver_num as deci
    field short_Free_Aver_val as deci
    field short_Other_sum as deci
    field short_Other_Aver_num as deci
    field short_Other_Aver_val as deci
    field MediumLong_Nat_sum as deci
    field MediumLong_Nat_Aver_num as deci
    field MediumLong_Nat_Aver_val as deci
    field MediumLong_Free_sum as deci
    field MediumLong_Free_Aver_num as deci
    field MediumLong_Free_Aver_val as deci
    field MediumLong_Other_sum as deci
    field MediumLong_Other_Aver_num as deci
    field MediumLong_Other_Aver_val as deci
index idx is primary k ascending.

def buffer b-crc for crc.

def var r-type1 as char.
def var r-type2 as char.
def var v-bal_1_beg as deci.
def var v-bal_1_end as deci.
def var v-bal_7_beg as deci.
def var v-bal_7_end as deci.
def var v-Sum_1424_beg as deci.
def var v-Sum_1424_end as deci.
def var v-Sum_1401_beg as deci.
def var v-Sum_1401_end as deci.
def var v-Sum_1403_beg as deci.
def var v-Sum_1403_end as deci.
def var v-Sum_1411_beg as deci.
def var v-Sum_1411_end as deci.
def var v-Sum_1417_beg as deci.
def var v-Sum_1417_end as deci.
def var v-BalSum_1_beg as deci.
def var v-BalSum_1_end as deci.
def var v-BalSum_7_beg as deci.
def var v-BalSum_7_end as deci.
def var v-RepDt as date.
def var v-month as inte.
def var v-year as inte.

def var v-file as char init "7_SB.htm".
def var v-file_1 as char init "7_SB_Rash1.htm".
def var v-file_2 as char init "7_SB_Rash2.htm".

def stream rep.
def stream rep_1.
def stream rep_2.

{FS_functions.i}
{7SB_rep.i &table = "t-Classific"}

find cmp no-lock no-error.

repeat on endkey undo,leave:
    update
        v-dtb format "99/99/9999" label "С" skip
        v-dte format "99/99/9999" label "ПО"
    with centered row 5 side-labels title "ВВЕДИТЕ ПЕРИОД" with frame Dolg.

    run sel1("Формат вывода «Расшифровка»","В тенге|В тыс.тенге").
    r-type1 = return-value.
    if r-type1 = "" then undo.

    run sel1("Формат вывода «Основная форма отчета»","В тенге|В тыс.тенге").
    r-type2 = return-value.
    if r-type2 = "" then undo.

    if r-type1 ne "" and r-type2 ne "" then leave.
end.

if month(v-dte) = 12 then do: v-month = 1. v-year = year(v-dte) + 1. end.
else do: v-month = v-month + 1. v-year = year(v-dte). end.
v-RepDt = date(v-month,1,v-year).

empty temp-table t-gldy.
empty temp-table t-wrk.
empty temp-table tgl.
empty temp-table t-TmpRep.

s-RepName = "7SB_rep".

{r-brfilial.i &proc = "FS_colldata_txb"}

display '   Ждите...   '  with row 5 frame wait centered.

output stream rep_1 to value(v-file_1).
{html-title.i &stream = "stream rep_1"}

put stream rep_1 unformatted
    "<P align=center style='font-size:12pt;font:bold'>«Расшифровка»<br>за период  с&nbsp;" string(v-dtb,"99/99/9999") "&nbsp;по&nbsp;"
    string(v-dte,"99/99/9999") "</P>" skip.

put stream rep_1 unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep_1 unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
/*1*/   "<TD>Филиал</TD>" skip
/*2*/   "<TD>№ транзакции</TD>" skip
/*3*/   "<TD>Дата транзакции</TD>" skip
/*4*/   "<TD>Шаблон транзакции</TD>" skip
/*5*/   "<TD>Счет ДТ 4-х значный</TD>" skip
/*6*/   "<TD>Счет ГК ДТ</TD>" skip
/*7*/   "<TD>Счет ДПС ДТ</TD>" skip
/*8*/   "<TD>Наименование счета ДТ</TD>" skip
/*9*/   "<TD>Гео-код ДТ</TD>" skip
/*26*/  "<TD>ОПФ ДТ</TD>" skip
/*10*/  "<TD>Счет ДТ 20-ти значный</TD>" skip
/*11*/  "<TD>Валюта Дт</TD>" skip
/*12*/  "<TD>Счет КТ 4-х значный</TD>" skip
/*13*/  "<TD>Счет ГК КТ</TD>" skip
/*14*/  "<TD>Счет ДПС КТ</TD>" skip
/*15*/  "<TD>Наименование счета КТ</TD>" skip
/*16*/  "<TD>Гео-код КТ</TD>" skip
/*27*/  "<TD>ОПФ КТ</TD>" skip
/*17*/  "<TD>Счет КТ 20-ти значный</TD>" skip
/*18*/  "<TD>Валюта Кт</TD>" skip
/*19*/  "<TD>КОД</TD>" skip
/*20*/  "<TD>КБЕ</TD>" skip
/*21*/  "<TD>КНП</TD>" skip
/*22*/  "<TD>Сумма транзакции в номинале</TD>" skip
/*23*/  "<TD>Сумма транзакции в эквиваленте (в тенге)</TD>" skip
/*24*/  "<TD>Назначение транзакции</TD>" skip
/*25*/  "<TD>Учетный курс</TD>" skip
    "</TR>" skip.

for each t-TmpRep no-lock:
    find crc where crc.crc eq t-TmpRep.D_crc no-lock no-error.
    find b-crc where b-crc.crc eq t-TmpRep.C_crc no-lock no-error.
    put stream rep_1 unformatted
        "<TR align=center style='font-size:10pt'>" skip
/*1*/   "<TD>" t-TmpRep.namebnk "</TD>" skip
/*2*/   "<TD>" string(t-TmpRep.jh) "</TD>" skip
/*3*/   "<TD>" string(t-TmpRep.whn,"99/99/9999") "</TD>" skip
/*4*/   "<TD>" t-TmpRep.trx "</TD>" skip
/*5*/   "<TD>" string(t-TmpRep.D_gl4) "</TD>" skip
/*6*/   "<TD>" string(t-TmpRep.D_gl) "</TD>" skip
/*7*/   "<TD>" string(t-TmpRep.D_gl7) "</TD>" skip
/*8*/   "<TD>" t-TmpRep.D_gldes "</TD>" skip
/*9*/   "<TD>" t-TmpRep.D_geo "</TD>" skip
/*9*/   "<TD>" t-TmpRep.D_cgrname "</TD>" skip
/*10*/  "<TD>" t-TmpRep.D_acc "</TD>" skip
/*11*/  "<TD>" trim(crc.code) "</TD>" skip
/*12*/  "<TD>" string(t-TmpRep.C_gl4) "</TD>" skip
/*13*/  "<TD>" string(t-TmpRep.C_gl) "</TD>" skip
/*14*/  "<TD>" string(t-TmpRep.C_gl7) "</TD>" skip
/*15*/  "<TD>" t-TmpRep.C_gldes "</TD>" skip
/*16*/  "<TD>" t-TmpRep.C_geo "</TD>" skip
/*27*/  "<TD>" t-TmpRep.C_cgrname "</TD>" skip
/*17*/  "<TD>" t-TmpRep.C_acc "</TD>" skip
/*18*/  "<TD>" trim(b-crc.code) "</TD>" skip
/*19*/  "<TD>" t-TmpRep.KOd "</TD>" skip
/*20*/  "<TD>" t-TmpRep.KBe "</TD>" skip
/*21*/  "<TD>" t-TmpRep.KNP "</TD>" skip
/*22*/  "<TD>" GetNormSummRash(t-TmpRep.amt) "</TD>" skip
/*23*/  "<TD>" GetNormSummRash(t-TmpRep.amtkzt) "</TD>" skip
/*24*/  "<TD>" t-TmpRep.rem "</TD>" skip
/*25*/  "<TD>" GetNormAll(t-TmpRep.crcrate) "</TD>" skip
        "</TR>" skip.

    run Distribution_Of_Amounts.

    hide message no-pause.
    message 't-TmpRep.jh = ' t-TmpRep.jh " t-TmpRep.txb = " t-TmpRep.txb.
end.
find first t-Classific no-lock no-error.

put stream rep_1 unformatted
    "</TABLE>" skip.

{html-end.i "stream rep_1"}
output stream rep_1 close.

unix silent cptwin value(v-file_1) excel.

output stream rep_2 to value(v-file_2).
{html-title.i &stream = "stream rep_2"}

put stream rep_2 unformatted
    "<P align=center style='font-size:12pt;font:bold'>«Займы клиентам»</P>" skip.

put stream rep_2 unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep_2 unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
/*1*/   "<TD>N бал.счета</TD>" skip
/*2*/   "<TD>Наименование заемщика</TD>" skip
/*3*/   "<TD>Код заемщика</TD>" skip
/*4*/   "<TD>Филиал</TD>" skip
/*5*/   "<TD>Пул МСФО</TD>" skip
/*6*/   "<TD>Группа</TD>" skip
/*7*/   "<TD>N договора, банк.займа</TD>" skip
/*8*/   "<TD>Объект кредитования</TD>" skip
/*9*/   "<TD>Валюта кредита</TD>" skip
/*10*/  "<TD>Дата выдачи</TD>" skip
/*11*/  "<TD>Срок погашения</TD>" skip
/*12*/  "<TD>Дата пролонгации</TD>" skip
/*13*/  "<TD>Дней просрочки ОД</TD>" skip
/*14*/  "<TD>Дней просрочки %</TD>" skip
/*15*/  "<TD>Остаток ОД (в тенге)<br>на начало периода</TD>" skip
/*16*/  "<TD>Просрочка ОД (в тенге)<br>на начало периода</TD>" skip
/*17*/  "<TD>Остаток ОД (в тенге)<br>на конец периода</TD>" skip
/*18*/  "<TD>Просрочка ОД (в тенге)<br>на конец периода</TD>" skip
/*19*/  "<TD>Истор.ставка</TD>" skip
/*20*/  "<TD>Номер ссудного счета</TD>" skip
/*21*/  "<TD>ОКЭД</TD>" skip
/*22*/  "<TD>ОПФ</TD>" skip
/*23*/  "<TD>Группа</TD>" skip
    "</TR>" skip.

v-BalSum_1_beg = 0. v-BalSum_1_end = 0. v-BalSum_7_beg = 0. v-BalSum_7_end = 0.

for each t-wrk where t-wrk.sub eq "lon" no-lock:
    v-bal_1_beg = 0. v-bal_1_end = 0. v-bal_7_beg = 0. v-bal_7_end = 0.

    find crc where crc.crc eq t-wrk.crc no-lock no-error.
    if not avail crc then next.

    v-bal_1_beg = t-wrk.bal_1_beg.
    v-bal_1_end = t-wrk.bal_1_end.
    v-bal_7_beg = t-wrk.bal_7_beg.
    v-bal_7_end = t-wrk.bal_7_end.

    v-BalSum_1_beg = v-BalSum_1_beg + v-bal_1_beg.
    v-BalSum_1_end = v-BalSum_1_end + v-bal_1_end.
    v-BalSum_7_beg = v-BalSum_7_beg + v-bal_7_beg.
    v-BalSum_7_end = v-BalSum_7_end + v-bal_7_end.

    if v-bal_1_beg = 0 and v-bal_1_end = 0 and v-bal_7_beg = 0 and v-bal_7_end = 0 then next.

    put stream rep_2 unformatted
        "<TR style='font-size:10pt'>" skip
/*1*/   "<TD>" string(t-wrk.gl_4) "</TD>" skip
/*2*/   "<TD>" t-wrk.acc-des "</TD>" skip
/*3*/   "<TD>" t-wrk.cif "</TD>" skip
/*4*/   "<TD>" t-wrk.namebnk "</TD>" skip
/*5*/   "<TD>" t-wrk.poolId "</TD>" skip
/*6*/   "<TD>" string(t-wrk.grp) "</TD>" skip
/*7*/   "<TD>&nbsp;" t-wrk.lcnt "</TD>" skip
/*8*/   "<TD>" t-wrk.objekts "</TD>" skip.
    if avail crc then put stream rep_2 unformatted
/*9*/   "<TD>" crc.code "</TD>" skip.
    else put stream rep_2 unformatted
/*9*/   "<TD></TD>" skip.
    put stream rep_2 unformatted
/*10*/  "<TD>" t-wrk.rdt "</TD>" skip
/*11*/  "<TD>" t-wrk.duedt "</TD>" skip
/*12*/  "<TD>" t-wrk.dprolong "</TD>" skip
/*13*/  "<TD>" string(t-wrk.overdueDay_lev_7) "</TD>" skip
/*14*/  "<TD>" string(t-wrk.overdueDay_lev_9) "</TD>" skip
/*15*/  "<TD>" GetNormSummRash(v-bal_1_beg) "</TD>" skip
/*16*/  "<TD>" GetNormSummRash(v-bal_7_beg) "</TD>" skip
/*17*/  "<TD>" GetNormSummRash(v-bal_1_end) "</TD>" skip
/*18*/  "<TD>" GetNormSummRash(v-bal_7_end) "</TD>" skip
/*19*/  "<TD>" replace(string(t-wrk.prem_his,'zzzzz9.99'),'.',',') "</TD>" skip
/*20*/  "<TD>" t-wrk.lon "</TD>" skip
/*21*/  "<TD>" t-wrk.otrasl "</TD>" skip
/*22*/  "<TD>" t-wrk.cgrname "</TD>" skip
/*23*/  "<TD>" t-wrk.codfr_lnopf "</TD>" skip
        "</TR>" skip.

    hide message no-pause.
    message 't-wrk.lon = ' t-wrk.lon " t-wrk.txb = " t-wrk.txb.
end.

v-Sum_1424_beg = 0. v-Sum_1424_end = 0. v-Sum_1401_beg = 0. v-Sum_1401_end = 0. v-Sum_1403_beg = 0. v-Sum_1403_end = 0. v-Sum_1411_beg = 0.
v-Sum_1411_end = 0. v-Sum_1417_beg = 0. v-Sum_1417_end = 0.

for each t-gldy no-lock:
    if t-gldy.gl_4 = 1424 then do:
        v-Sum_1424_beg = v-Sum_1424_beg + t-gldy.balkzt_beg.
        v-Sum_1424_end = v-Sum_1424_end + t-gldy.balkzt_end.
    end.
    if t-gldy.gl_4 = 1401 then do:
        v-Sum_1401_beg = v-Sum_1401_beg + t-gldy.balkzt_beg.
        v-Sum_1401_end = v-Sum_1401_end + t-gldy.balkzt_end.
    end.
    if t-gldy.gl_4 = 1403 then do:
        v-Sum_1403_beg = v-Sum_1403_beg + t-gldy.balkzt_beg.
        v-Sum_1403_end = v-Sum_1403_end + t-gldy.balkzt_end.
    end.
    if t-gldy.gl_4 = 1411 then do:
        v-Sum_1411_beg = v-Sum_1411_beg + t-gldy.balkzt_beg.
        v-Sum_1411_end = v-Sum_1411_end + t-gldy.balkzt_end.
    end.
    if t-gldy.gl_4 = 1417 then do:
        v-Sum_1417_beg = v-Sum_1417_beg + t-gldy.balkzt_beg.
        v-Sum_1417_end = v-Sum_1417_end + t-gldy.balkzt_end.
    end.
end.

put stream rep_2 unformatted
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
/*10*/  "<TD>" string(date(01/01/2008)) "</TD>" skip
/*11*/  "<TD></TD>" skip
/*12*/  "<TD></TD>" skip
/*13*/  "<TD>30</TD>" skip
/*14*/  "<TD></TD>" skip
/*15*/  "<TD>" GetNormSummRash((v-Sum_1401_beg + v-Sum_1403_beg + v-Sum_1411_beg + v-Sum_1417_beg) - v-BalSum_1_beg) "</TD>" skip
/*16*/  "<TD>" GetNormSummRash(v-Sum_1424_beg - v-BalSum_7_beg) "</TD>" skip
/*17*/  "<TD>" GetNormSummRash((v-Sum_1401_end + v-Sum_1403_end + v-Sum_1411_end + v-Sum_1417_end) - v-BalSum_1_end) "</TD>" skip
/*18*/  "<TD>" GetNormSummRash(v-Sum_1424_end - v-BalSum_7_end) "</TD>" skip
/*19*/  "<TD></TD>" skip
/*20*/  "<TD></TD>" skip
/*21*/  "<TD></TD>" skip
/*22*/  "<TD></TD>" skip
/*23*/  "<TD></TD>" skip
    "</TR>" skip.

put stream rep_2 unformatted
    "</TABLE>" skip.

{html-end.i "stream rep_2"}
output stream rep_2 close.

unix silent cptwin value(v-file_2) excel.

for each tgl where tgl.sub-type eq "lon" no-lock:
    if lookup(string(tgl.gl4),"1401,1403,1411,1417,1424") eq 0 then next.
    find crc where crc.crc eq tgl.crc no-lock no-error.

    run Distribution_Of_Amounts_2.

    hide message no-pause.
    message 'tgl.acc = ' tgl.acc " tgl.txb = " tgl.txb.
end.
find first t-Classific no-lock no-error.

output stream rep to value(v-file).
{html-title.i &stream = "stream rep"}

put stream rep unformatted
    "<P align=center style='font-size:10pt;font:bold;font-family:Times New Roman'>Отчет<br>о кредитах крестьянским (фермерским) хозяйствам и ставках
    вознаграждения по ним<br>на " string(v-RepDt,"99/99/9999") " года</P>" skip
    "<P align=left style='font-size:10pt;font-family:Times New Roman'>" trim(cmp.name) "</P>" skip.

put stream rep unformatted
    "<P align=right style='font-size:8pt;font:bold;font-family:Times New Roman;vertical-align:middle'>(в тысячах тенге)</P>" skip.

put stream rep unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD rowspan=3>&nbsp;</TD>" skip
    "<TD rowspan=3>Шифр<br>строки</TD>" skip
    "<TD colspan=6>краткосрочные в валюте:</TD>" skip
    "<TD colspan=6>Среднесрочные и долгосрочные в валюте:</TD>" skip
    "</TR>" skip
    "<TR align=center style='font-size:10pt;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD colspan=2>национальной</TD>" skip
    "<TD colspan=2>свободно-<br>конвертируемой</TD>" skip
    "<TD colspan=2>других видах валют</TD>" skip
    "<TD colspan=2>национальной</TD>" skip
    "<TD colspan=2>свободно-<br>конвертируемой</TD>" skip
    "<TD colspan=2>других видах валют</TD>" skip
    "</TR>" skip
    "<TR align=center style='font-size:10pt;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне-<br>годовая<br>ставка<br>вознагра-<br>ждения,%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне-<br>годовая<br>ставка<br>вознагра-<br>ждения,%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне-<br>годовая<br>ставка<br>вознагра-<br>ждения,%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне-<br>годовая<br>ставка<br>вознагра-<br>ждения,%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне-<br>годовая<br>ставка<br>вознагра-<br>ждения,%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне-<br>годовая<br>ставка<br>вознагра-<br>ждения,%</TD>" skip
    "</TR>" skip
    "<TR align=center style='font-size:10pt;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD>A</TD>" skip
    "<TD>B</TD>" skip
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
    "</TR>" skip.

for each t-Classific no-lock:
    put stream rep unformatted
        "<TR align=center style='font-size:10pt;font-family:Times New Roman'>" skip
        "<TD align=left>" t-Classific.name "</TD>" skip
        "<TD align=right>" string(t-Classific.code) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.short_Nat_sum) "</TD>" skip
        "<TD>" GetNormAll(t-Classific.short_Nat_Aver_val / t-Classific.short_Nat_Aver_num) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.short_Free_sum) "</TD>" skip
        "<TD>" GetNormAll(t-Classific.short_Free_Aver_val / t-Classific.short_Free_Aver_num) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.short_Other_sum) "</TD>" skip
        "<TD>" GetNormAll(t-Classific.short_Other_Aver_val / t-Classific.short_Other_Aver_num) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.MediumLong_Nat_sum) "</TD>" skip
        "<TD>" GetNormAll(t-Classific.MediumLong_Nat_Aver_val / t-Classific.MediumLong_Nat_Aver_num) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.MediumLong_Free_sum) "</TD>" skip
        "<TD>" GetNormAll(t-Classific.MediumLong_Free_Aver_val / t-Classific.MediumLong_Free_Aver_num) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.MediumLong_Other_sum) "</TD>" skip
        "<TD>" GetNormAll(t-Classific.MediumLong_Other_Aver_val / t-Classific.MediumLong_Other_Aver_num) "</TD>" skip
        "</TR>" skip.
end.

put stream rep unformatted
    "</TABLE>" skip.

put stream rep unformatted
    '<P align=left style="font-size:10pt;font-family:Times New Roman">Председатель Правления</P>' skip
    '<P align=left style="font-size:10pt;font-family:Times New Roman">Главный бухгалтер</P>' skip
    '<P align=left style="font-size:10pt;font-family:Times New Roman">Исполнитель</P>' skip
    '<P align=left style="font-size:10pt;font-family:Times New Roman">Дата подписания отчета&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;года</P>' skip.

{html-end.i "stream rep"}
output stream rep close.

unix silent cptwin value(v-file) excel.

return.

procedure Distribution_Of_Amounts:
    for each t-Classific exclusive-lock:
        if t-Classific.code = 2 then do:
            if lookup(string(t-TmpRep.D_gl4),"1401,1403,1411,1417") gt 0 and length(t-TmpRep.C_acc) = 20 then do:
                find t-wrk where t-wrk.txb eq t-TmpRep.txb and t-wrk.sub eq "lon" and t-wrk.lon eq t-TmpRep.D_acc no-lock no-error.
                if avail t-wrk then do:
                    if lookup(string(t-wrk.cgr),"405") gt 0 then do:
                        run Class_Distribution(GetLoansType(t-TmpRep.D_gl4),GetCrcType(trim(crc.code)),t-TmpRep.amtkzt,t-wrk.prem_his).
                    end.
                end.
            end.
        end.
        if t-Classific.code = 3 then do:
            if length(t-TmpRep.D_acc) = 20 and lookup(string(t-TmpRep.C_gl4),"1401,1403,1411,1417,1424") gt 0 then do:
                find t-wrk where t-wrk.txb eq t-TmpRep.txb and t-wrk.sub eq "lon" and t-wrk.lon eq t-TmpRep.C_acc no-lock no-error.
                if avail t-wrk then do:
                    if lookup(string(t-wrk.cgr),"405") gt 0 then do:
                        run Class_Distribution(GetLoansType(t-TmpRep.C_gl4),GetCrcType(trim(b-crc.code)),t-TmpRep.amtkzt,t-wrk.prem_his).
                    end.
                end.
            end.
        end.
        if t-Classific.code = 6 then do:
            if lookup(string(t-TmpRep.D_gl4),"1401,1403,1411,1417,1424") gt 0 and lookup(string(t-TmpRep.C_gl4),"1401,1403,1411,1417,1424") gt 0 then do:
                if (lookup(string(t-TmpRep.D_gl4),"1401,1403,1411,1417") gt 0 and lookup(string(t-TmpRep.C_gl4),"1424") gt 0) or
                (lookup(string(t-TmpRep.D_gl4),"1424") gt 0 and lookup(string(t-TmpRep.C_gl4),"1401,1403,1411,1417") gt 0) then next.

                find t-wrk where t-wrk.txb eq t-TmpRep.txb and t-wrk.sub eq "lon" and t-wrk.lon eq t-TmpRep.C_acc no-lock no-error.
                if avail t-wrk then do:
                    if lookup(string(t-wrk.cgr),"405") gt 0 then do:
                        run Class_Distribution(GetLoansType(t-TmpRep.C_gl4),GetCrcType(trim(b-crc.code)),t-TmpRep.amtkzt,t-wrk.prem_his).
                    end.
                end.
            end.
        end.
    end.
    find first t-Classific no-lock no-error.
end procedure.

procedure Distribution_Of_Amounts_2:
    for each t-Classific exclusive-lock:
        if t-Classific.code = 1 then do:
            if lookup(string(tgl.gl4),"1401,1403,1411,1417,1424") gt 0 then do:
                find t-wrk where t-wrk.txb eq tgl.txb and t-wrk.sub eq "lon" and t-wrk.lon eq tgl.acc no-lock no-error.
                if avail t-wrk then do:
                    if lookup(string(t-wrk.cgr),"405") gt 0 then do:
                        run Class_Distribution(GetLoansType(tgl.gl4),GetCrcType(trim(crc.code)),tgl.sum_beg,t-wrk.prem_his).
                    end.
                end.
            end.
        end.
        if t-Classific.code = 4 then do:
            if lookup(string(tgl.gl4),"1401,1403,1411,1417,1424") gt 0 then do:
                find t-wrk where t-wrk.txb eq tgl.txb and t-wrk.sub eq "lon" and t-wrk.lon eq tgl.acc no-lock no-error.
                if avail t-wrk then do:
                    if lookup(string(t-wrk.cgr),"405") gt 0 then do:
                        run Class_Distribution(GetLoansType(tgl.gl4),GetCrcType(trim(crc.code)),tgl.sum_end,t-wrk.prem_his).
                    end.
                end.
            end.
        end.
        if t-Classific.code = 7 then do:
            if lookup(string(tgl.gl4),"1424") gt 0 then do:
                find t-wrk where t-wrk.txb eq tgl.txb and t-wrk.sub eq "lon" and t-wrk.lon eq tgl.acc no-lock no-error.
                if avail t-wrk then do:
                    if lookup(string(t-wrk.cgr),"405") gt 0 then do:
                        run Class_Distribution(GetLoansType(tgl.gl4),GetCrcType(trim(crc.code)),tgl.sum_end,t-wrk.prem_his).
                    end.
                end.
            end.
        end.
    end.
    find first t-Classific no-lock no-error.
end procedure.

procedure Class_Distribution:
    def input parameter p-LoansType as char.
    def input parameter p-CrcType as char.
    def input parameter p-sum as deci.
    def input parameter p-prem_his as deci.

    if p-sum = 0 then return.

    if p-LoansType = "Краткосрочные" then do:
        if p-CrcType = "Национальная" then do:
            t-Classific.short_Nat_sum = t-Classific.short_Nat_sum + p-sum.
            t-Classific.short_Nat_Aver_num = t-Classific.short_Nat_Aver_num + 1.
            t-Classific.short_Nat_Aver_val = t-Classific.short_Nat_Aver_val + p-prem_his.
        end.
        if p-CrcType = "Свободно-конвертируемая" then do:
            t-Classific.short_Free_sum = t-Classific.short_Free_sum + p-sum.
            t-Classific.short_Free_Aver_num = t-Classific.short_Free_Aver_num + 1.
            t-Classific.short_Free_Aver_val = t-Classific.short_Free_Aver_val + p-prem_his.
        end.
        if p-CrcType = "Другая" then do:
            t-Classific.short_Other_sum = t-Classific.short_Other_sum + p-sum.
            t-Classific.short_Other_Aver_num = t-Classific.short_Other_Aver_num + 1.
            t-Classific.short_Other_Aver_val = t-Classific.short_Other_Aver_val + p-prem_his.
        end.
    end.
    if p-LoansType = "Долгосрочные" then do:
        if p-CrcType = "Национальная" then do:
            t-Classific.MediumLong_Nat_sum = t-Classific.MediumLong_Nat_sum + p-sum.
            t-Classific.MediumLong_Nat_Aver_num = t-Classific.MediumLong_Nat_Aver_num + 1.
            t-Classific.MediumLong_Nat_Aver_val = t-Classific.MediumLong_Nat_Aver_val + p-prem_his.
        end.
        if p-CrcType = "Свободно-конвертируемая" then do:
            t-Classific.MediumLong_Free_sum = t-Classific.MediumLong_Free_sum + p-sum.
            t-Classific.MediumLong_Free_Aver_num = t-Classific.MediumLong_Free_Aver_num + 1.
            t-Classific.MediumLong_Free_Aver_val = t-Classific.MediumLong_Free_Aver_val + p-prem_his.
        end.
        if p-CrcType = "Другая" then do:
            t-Classific.MediumLong_Other_sum = t-Classific.MediumLong_Other_sum + p-sum.
            t-Classific.MediumLong_Other_Aver_num = t-Classific.MediumLong_Other_Aver_num + 1.
            t-Classific.MediumLong_Other_Aver_val = t-Classific.MediumLong_Other_Aver_val + p-prem_his.
        end.
    end.
end procedure.

