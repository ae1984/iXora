/* FS_GA.p
 * MODULE
        Название модуля - Внутрибанковские операции.
 * DESCRIPTION
        Описание - ФС_ГА «Срок платежа, оставшийся до погашения».
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
        28.01.2013 damir - Внедрено Т.З. № 1227.
*/
{mainhead.i}
{FS_general.i "new"}

def temp-table t-Classific
    field k as inte
    field name as char
    field gl_4 as char
    field code as inte
    field do_vos as deci
    field per1-30 as deci
    field per31-90 as deci
    field per91-180 as deci
    field per181-365 as deci
    field per366-730 as deci
    field per731-1095 as deci
    field per1096-1825 as deci
    field per1826 as deci
    field restsum as deci
index idx is primary k ascending
index idx2 gl_4 ascending.

def var v-file as char init "FS_GA.htm".
def var v-file_1 as char init "FS_GA_Rash1.htm".
def var v-file_2 as char init "FS_GA_Rash2.htm".
def var v-file_3 as char init "FS_GA_Rash3.htm".

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
def var v-bal_16 as deci.
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
def var v-temp as deci extent 8.
def var v-codesrokdis as inte.
def var v-codesrok as char.
def var vv-do_vos as deci.
def var vv-per1-30 as deci.
def var vv-per31-90 as deci.
def var vv-per91-180 as deci.
def var vv-per181-365 as deci.
def var vv-per366-730 as deci.
def var vv-per731-1095 as deci.
def var vv-per1096-1825 as deci.
def var vv-per1826 as deci.
def var vv-restsum as deci.
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
def var v-Sum_143422 as deci.
def var v-Assets as logi format "да/нет".
def var v-Liabilities as logi format "да/нет".
def var v-Loans as logi format "да/нет".
def var v-seltxb as char.
def var v-disnum as inte.
def var v-perdis1-30 as logi.
def var v-perdis31-90 as logi.
def var v-perdis91-180 as logi.
def var v-perdis181-365 as logi.
def var v-perdis366-730 as logi.
def var v-perdis731-1095 as logi.
def var v-perdis1096-1825 as logi.
def var v-perdis1826 as logi.
def var v-disnumval as inte extent 9.
def var i as inte.
def var v-srokdis as char.
def var v-log_dis as logi extent 8.
def var v-temp_dis as deci extent 8.
def var v-Classific as inte.
def var v-RepDt as date.
def var v-month as inte.
def var v-year as inte.

{FS_functions.i}
{FS_GA.i &table = "t-Classific"}

find cmp no-lock no-error.
find last bank.cls.
if avail bank.cls then v-gldate = bank.cls.whn.

repeat on endkey undo,leave:
    update
        v-gldate format "99/99/9999" label 'Введите отчетную дату' validate(v-gldate <> ?, 'Дата не должна быть пустой !') skip(1)
        'Формировать отчеты:' skip
        v-Assets label "Активы" help 'Выберите да/нет' skip
        v-Liabilities label "Обязательства" help 'Выберите да/нет' skip
        v-Loans  label "Займы" help 'Выберите да/нет' skip
    with row 6 centered side-label frame FS_pay.

    run sel1("Формат вывода «Расшифровка»","В тенге|В тыс.тенге").
    r-type1 = return-value.
    if r-type1 = "" then undo.

    run sel1("Формат вывода «Основная форма отчета»","В тенге|В тыс.тенге").
    r-type2 = return-value.
    if r-type2 = "" then undo.

    if r-type1 ne "" and r-type2 ne "" then leave.
end.
v-month = month(v-gldate). v-year = year(v-gldate).
if month(v-gldate) = 12 then do: v-month = 1. v-year = year(v-gldate) + 1. end.
else do: v-month = v-month + 1. v-year = year(v-gldate). end.
v-RepDt = date(v-month,1,v-year).

hide frame FS_pay.

empty temp-table t-gldy.
empty temp-table t-wrk.
empty temp-table tgl.

s-RepName = "FS_GA".

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
/*15*/  "<TD>Остаток ОД (в тенге)</TD>" skip
/*16*/  "<TD>Просрочка ОД (в тенге)</TD>" skip
/*17*/  "<TD>Начисленные % (в тенге)</TD>" skip
/*18*/  "<TD>Просрочки % (в тенге)</TD>" skip
/*19*/  "<TD>Штрафы</TD>" skip
/*20*/  "<TD>Дисконт по займам (в тенге)</TD>" skip
/*21*/  "<TD>Срок дисконта по займам</TD>" skip
/*22*/  "<TD>% резерва КФН</TD>" skip
/*23*/  "<TD>Резерв КФН</TD>" skip
/*24*/  "<TD>% резерва МСФО</TD>" skip
/*25*/  "<TD>Резерв МСФО ОД</TD>" skip
/*26*/  "<TD>Резерв МСФО %%</TD>" skip
/*27*/  "<TD>Резерв МСФО Пеня</TD>" skip
/*28*/  "<TD>Общая сумма резерва МСФО</TD>" skip
/*29*/  "<TD>Истор.ставка</TD>" skip
/*30*/  "<TD>от 1 до 30 дней<br>ОД</TD>" skip
/*31*/  "<TD>от 31 до 90 дней<br>ОД</TD>" skip
/*32*/  "<TD>от 91 до 180 дней<br>ОД</TD>" skip
/*33*/  "<TD>от 181 до 365 дней<br>ОД</TD>" skip
/*34*/  "<TD>от 1 года до 2 лет<br>ОД</TD>" skip
/*35*/  "<TD>от 2 лет до 3 лет<br>ОД</TD>" skip
/*36*/  "<TD>от 3 лет до 5 лет<br>ОД</TD>" skip
/*37*/  "<TD>более 5 лет<br>ОД</TD>" skip
/*38*/  "<TD>Периодичность платежей ОД</TD>" skip
/*39*/  "<TD>от 1 до 30 дней<br>провизии</TD>" skip
/*40*/  "<TD>от 31 до 90 дней<br>провизии</TD>" skip
/*41*/  "<TD>от 91 до 180 дней<br>провизии</TD>" skip
/*42*/  "<TD>от 181 до 365 дней<br>провизии</TD>" skip
/*43*/  "<TD>от 1 года до 2 лет<br>провизии</TD>" skip
/*44*/  "<TD>от 2 лет до 3 лет<br>провизии</TD>" skip
/*45*/  "<TD>от 3 лет до 5 лет<br>провизии</TD>" skip
/*46*/  "<TD>более 5 лет<br>провизии</TD>" skip
/*47*/  "<TD>Код строки</TD>" skip
/*48*/  "<TD>Номер ссудного счета</TD>" skip
/*49*/  "<TD>Признак</TD>" skip
/*50*/  "<TD>от 1 до 30 дней<br>дисконт</TD>" skip
/*51*/  "<TD>от 31 до 90 дней<br>дисконт</TD>" skip
/*52*/  "<TD>от 91 до 180 дней<br>дисконт</TD>" skip
/*53*/  "<TD>от 181 до 365 дней<br>дисконт</TD>" skip
/*54*/  "<TD>от 1 года до 2 лет<br>дисконт</TD>" skip
/*55*/  "<TD>от 2 лет до 3 лет<br>дисконт</TD>" skip
/*56*/  "<TD>от 3 лет до 5 лет<br>дисконт</TD>" skip
/*57*/  "<TD>более 5 лет<br>дисконт</TD>" skip
/*58*/  "<TD>от 1 до 30 дней<br>Итого</TD>" skip
/*59*/  "<TD>от 31 до 90 дней<br>Итого</TD>" skip
/*60*/  "<TD>от 91 до 180 дней<br>Итого</TD>" skip
/*61*/  "<TD>от 181 до 365 дней<br>Итого</TD>" skip
/*62*/  "<TD>от 1 года до 2 лет<br>Итого</TD>" skip
/*63*/  "<TD>от 2 лет до 3 лет<br>Итого</TD>" skip
/*64*/  "<TD>от 3 лет до 5 лет<br>Итого</TD>" skip
/*65*/  "<TD>более 5 лет<br>Итого</TD>" skip
        "</TR>" skip.

v-BalSum_1 = 0. v-BalSum_7 = 0. v-BalSum_2 = 0. v-BalSum_49 = 0. v-BalSum_9 = 0. v-BalSum_41 = 0. v-BalSum_6 = 0. v-BalSum_36 = 0. v-BalSum_37 = 0.
v-BalSum_42 = 0.

for each t-wrk where t-wrk.sub eq "lon" exclusive-lock:
    v-bal_1 = 0. v-bal_2 = 0. v-bal_6 = 0. v-bal_7 = 0. v-bal_9 = 0. v-bal_16 = 0. v-bal_36 = 0. v-bal_37 = 0. v-bal_41 = 0. v-bal_42 = 0. v-bal_49 = 0.
    v-codesrokdis = 0.

    do i = 1 to 8:
        v-temp[i] = 0. v-temp_dis[i] = 0. v-disnumval[i] = 0. v-log_dis[i] = false.
    end.
    v-disnumval[9] = 0.

    find crc where crc.crc eq t-wrk.crc no-lock no-error.

    v-bal_1 = t-wrk.bal_1.
    v-bal_2 = t-wrk.bal_2.
    v-bal_6 = t-wrk.bal_6.
    v-bal_7 = t-wrk.bal_7.
    v-bal_9 = t-wrk.bal_9.
    v-bal_16 = t-wrk.bal_16.
    v-bal_36 = t-wrk.bal_36.
    v-bal_37 = t-wrk.bal_37.
    v-bal_41 = t-wrk.bal_41.
    v-bal_42 = t-wrk.bal_42.
    v-bal_49 = t-wrk.bal_49.

    if v-bal_1 = 0 and v-bal_7 = 0 and (v-bal_2 + v-bal_49) = 0 and v-bal_9 = 0 and v-bal_42 = 0 and v-bal_41 = 0 and v-bal_6 = 0 and v-bal_36 = 0 and
    v-bal_37 = 0 then next.

    v-BalSum_1 = v-BalSum_1 + v-bal_1.
    v-BalSum_2 = v-BalSum_2 + v-bal_2.
    v-BalSum_6 = v-BalSum_6 + v-bal_6.
    v-BalSum_7 = v-BalSum_7 + v-bal_7.
    v-BalSum_9 = v-BalSum_9 + v-bal_9.
    v-BalSum_36 = v-BalSum_36 + v-bal_36.
    v-BalSum_37 = v-BalSum_37 + v-bal_37.
    v-BalSum_41 = v-BalSum_41 + v-bal_41.
    v-BalSum_42 = v-BalSum_42 + v-bal_42.
    v-BalSum_49 = v-BalSum_49 + v-bal_49.

    v-temp[1] = (t-wrk.per1-30 + v-bal_7) / (v-bal_1 + v-bal_7) * v-bal_6.
    v-temp[2] = (t-wrk.per31-90) / (v-bal_1 + v-bal_7) * v-bal_6.
    v-temp[3] = (t-wrk.per91-180) / (v-bal_1 + v-bal_7) * v-bal_6.
    v-temp[4] = (t-wrk.per181-365) / (v-bal_1 + v-bal_7) * v-bal_6.
    v-temp[5] = (t-wrk.per366-730) / (v-bal_1 + v-bal_7) * v-bal_6.
    v-temp[6] = (t-wrk.per731-1095) / (v-bal_1 + v-bal_7) * v-bal_6.
    v-temp[7] = (t-wrk.per1096-1825) / (v-bal_1 + v-bal_7) * v-bal_6.
    v-temp[8] = (t-wrk.per1826) / (v-bal_1 + v-bal_7) * v-bal_6.

    v-codesrokdis = t-wrk.duedt - v-gldate.
    v-srokdis = "30,60,90,185,365,365,730,1826".
    do i = 1 to num-entries(v-srokdis):
        if v-disnumval[2] > 0 then v-disnumval[1] = 30.
        else v-disnumval[1] = v-codesrokdis.
        v-disnumval[i + 1] = v-disnumval[i] - inte(entry(i,v-srokdis)).
    end.

    do i = 1 to 8:
        if i > 1 then do:
            if v-disnumval[i] > 0 then do:
                if v-disnumval[i] > inte(entry(i,v-srokdis)) then v-temp_dis[i] = v-bal_42 / v-codesrokdis * inte(entry(i,v-srokdis)).
                else v-temp_dis[i] = v-bal_42 / v-codesrokdis * v-disnumval[i].
                v-log_dis[i] = true.
            end.
        end.
        else do:
            if v-disnumval[i] <> 1 then v-temp_dis[i] = v-bal_42 / v-codesrokdis * v-disnumval[i].
            else v-temp_dis[i] = v-bal_42.
            v-log_dis[i] = true.
        end.
    end.

    do i = 1 to 8:
        if v-temp[i] lt 0 or v-temp[i] eq ? then v-temp[i] = 0.
        if v-temp_dis[i] eq ? then v-temp_dis[i] = 0.
    end.

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
/*13*/  "<TD>" string(t-wrk.overdueDay_lev_7) "</TD>" skip
/*14*/  "<TD>" string(t-wrk.overdueDay_lev_9) "</TD>" skip
/*15*/  "<TD>" GetNormSummRash(v-bal_1) "</TD>" skip
/*16*/  "<TD>" GetNormSummRash(v-bal_7) "</TD>" skip
/*17*/  "<TD>" GetNormSummRash(v-bal_2 + v-bal_49) "</TD>" skip
/*18*/  "<TD>" GetNormSummRash(v-bal_9) "</TD>" skip
/*19*/  "<TD>" GetNormSummRash(v-bal_16) "</TD>" skip
/*20*/  "<TD>" GetNormSummRash(v-bal_42) "</TD>" skip
/*21*/  "<TD>" v-codesrokdis "</TD>" skip
/*22*/  "<TD>" GetNormSummRash(t-wrk.prcKfn) "</TD>" skip
/*23*/  "<TD>" GetNormSummRash(v-bal_41) "</TD>" skip
/*24*/  "<TD>" GetNormSummRash(t-wrk.procmsfo) "</TD>" skip
/*25*/  "<TD>" GetNormSummRash(v-bal_6) "</TD>" skip
/*26*/  "<TD>" GetNormSummRash(v-bal_36) "</TD>" skip
/*27*/  "<TD>" GetNormSummRash(v-bal_37) "</TD>" skip
/*28*/  "<TD>" GetNormSummRash(v-bal_6 + v-bal_36 + v-bal_37) "</TD>" skip
/*29*/  "<TD>" replace(string(t-wrk.prem_his,'zzzzz9.99'),'.',',') "</TD>" skip
/*30*/  "<TD>" GetNormSummRash(t-wrk.per1-30) "</TD>" skip
/*31*/  "<TD>" GetNormSummRash(t-wrk.per31-90) "</TD>" skip
/*32*/  "<TD>" GetNormSummRash(t-wrk.per91-180) "</TD>" skip
/*33*/  "<TD>" GetNormSummRash(t-wrk.per181-365) "</TD>" skip
/*34*/  "<TD>" GetNormSummRash(t-wrk.per366-730) "</TD>" skip
/*35*/  "<TD>" GetNormSummRash(t-wrk.per731-1095) "</TD>" skip
/*36*/  "<TD>" GetNormSummRash(t-wrk.per1096-1825) "</TD>" skip
/*37*/  "<TD>" GetNormSummRash(t-wrk.per1826) "</TD>" skip
/*38*/  "<TD>" t-wrk.lnpmt "</TD>" skip.
    do i = 1 to 8:
        put stream rep_1 unformatted
/*39-46*/ "<TD>" GetNormSummRash(v-temp[i]) "</TD>" skip.
    end.
    find first t-Classific where lookup(string(t-wrk.gl_4),t-Classific.gl_4) gt 0 exclusive-lock no-error.
    if avail t-Classific then do:
        put stream rep_1 unformatted
/*47*/      "<TD>" string(t-Classific.code) "</TD>" skip.

        if t-wrk.procmsfo ge 0 and t-wrk.procmsfo le 5 then do:
            t-Classific.per1-30 = t-Classific.per1-30 + t-wrk.per1-30 + v-bal_7 + (v-bal_2 + v-bal_49) + v-bal_9 - v-bal_36 - v-bal_37 - v-temp[1] -
            v-temp_dis[1].
            t-Classific.per31-90 = t-Classific.per31-90 + t-wrk.per31-90 - v-temp[2] - v-temp_dis[2].
            t-Classific.per91-180 = t-Classific.per91-180 + t-wrk.per91-180 - v-temp[3] - v-temp_dis[3].
            t-Classific.per181-365 = t-Classific.per181-365 + t-wrk.per181-365 - v-temp[4] - v-temp_dis[4].
            t-Classific.per366-730 = t-Classific.per366-730 + t-wrk.per366-730 - v-temp[5] - v-temp_dis[5].
            t-Classific.per731-1095 = t-Classific.per731-1095 + t-wrk.per731-1095 - v-temp[6] - v-temp_dis[6].
            t-Classific.per1096-1825 = t-Classific.per1096-1825 + t-wrk.per1096-1825 - v-temp[7] - v-temp_dis[7].
            t-Classific.per1826 = t-Classific.per1826 + t-wrk.per1826 - v-temp[8] - v-temp_dis[8].
        end.
        else do:
            if t-wrk.overdueDay_lev_7 eq 0 and t-wrk.overdueDay_lev_9 eq 0 then do:
                t-Classific.per1-30 = t-Classific.per1-30 + t-wrk.per1-30 + v-bal_7 + (v-bal_2 + v-bal_49) + v-bal_9 - v-bal_36 - v-bal_37 - v-temp[1] -
                v-temp_dis[1].
                t-Classific.per31-90 = t-Classific.per31-90 + t-wrk.per31-90 - v-temp[2] - v-temp_dis[2].
                t-Classific.per91-180 = t-Classific.per91-180 + t-wrk.per91-180 - v-temp[3] - v-temp_dis[3].
                t-Classific.per181-365 = t-Classific.per181-365 + t-wrk.per181-365 - v-temp[4] - v-temp_dis[4].
                t-Classific.per366-730 = t-Classific.per366-730 + t-wrk.per366-730 - v-temp[5] - v-temp_dis[5].
                t-Classific.per731-1095 = t-Classific.per731-1095 + t-wrk.per731-1095 - v-temp[6] - v-temp_dis[6].
                t-Classific.per1096-1825 = t-Classific.per1096-1825 + t-wrk.per1096-1825 - v-temp[7] - v-temp_dis[7].
                t-Classific.per1826 = t-Classific.per1826 + t-wrk.per1826 - v-temp[8] - v-temp_dis[8].
            end.
            else t-Classific.restsum = t-Classific.restsum + v-bal_1 + v-bal_7 + (v-bal_2 + v-bal_49) + v-bal_9 - v-bal_42 - v-bal_6 - v-bal_36 -
            v-bal_37.
        end.
    end.
    else put stream rep_1 unformatted
/*47*/  "<TD></TD>" skip.
    find first t-Classific where lookup(string(t-wrk.gl_4),t-Classific.gl_4) gt 0 no-lock no-error.

    put stream rep_1 unformatted
/*48*/  "<TD>" t-wrk.lon "</TD>" skip
/*49*/  "<TD>" t-wrk.gua "</TD>" skip.

    do i = 1 to 8:
        if v-log_dis[i] then put stream rep_1 unformatted
/*50-57*/   "<TD>" GetNormSummRash(v-temp_dis[i]) "</TD>" skip.
        else put stream rep_1 unformatted
/*50-57*/   "<TD>" GetNormAll(0) "</TD>" skip.
    end.
    put stream rep_1 unformatted
/*58*/   "<TD>" GetNormSummRash(t-wrk.per1-30 + v-bal_7 + (v-bal_2 + v-bal_49) + v-bal_9 - v-bal_36 - v-bal_37 - v-temp[1] - v-temp_dis[1]) "</TD>" skip
/*59*/   "<TD>" GetNormSummRash(t-wrk.per31-90 - v-temp[2] - v-temp_dis[2]) "</TD>" skip
/*60*/   "<TD>" GetNormSummRash(t-wrk.per91-180 - v-temp[3] - v-temp_dis[3]) "</TD>" skip
/*61*/   "<TD>" GetNormSummRash(t-wrk.per181-365 - v-temp[4] - v-temp_dis[4]) "</TD>" skip
/*62*/   "<TD>" GetNormSummRash(t-wrk.per366-730 - v-temp[5] - v-temp_dis[5]) "</TD>" skip
/*63*/   "<TD>" GetNormSummRash(t-wrk.per731-1095 - v-temp[6] - v-temp_dis[6]) "</TD>" skip
/*64*/   "<TD>" GetNormSummRash(t-wrk.per1096-1825 - v-temp[7] - v-temp_dis[7]) "</TD>" skip
/*65*/   "<TD>" GetNormSummRash(t-wrk.per1826 - v-temp[8] - v-temp_dis[8]) "</TD>" skip
         "</TR>" skip.

    hide message no-pause.
    message 'lon = ' t-wrk.lon.
end.
find first t-wrk where t-wrk.sub eq 'lon' no-lock no-error.

v-Sum_1424 = 0. v-Sum_1401 = 0. v-Sum_1403 = 0. v-Sum_1411 = 0. v-Sum_1417 = 0. v-Sum_1740 = 0. v-Sum_1741 = 0. v-Sum_910011 = 0. v-Sum_910012 = 0.
v-Sum_142810 = 0. v-Sum_142820 = 0. v-Sum_142841 = 0. v-Sum_142842 = 0. v-Sum_1428 = 0. v-Sum_143422 = 0.

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
    if t-gldy.gl = 143422 then v-Sum_143422 = v-Sum_143422 + t-gldy.balkzt.
end.

v-Sum_910011 = v-Sum_910011.
v-Sum_910012 = v-Sum_910012.
v-Sum_142810 = - v-Sum_142810.
v-Sum_142820 = - v-Sum_142820.
v-Sum_142841 = - v-Sum_142841.
v-Sum_142842 = - v-Sum_142842.
v-Sum_1428 = - v-Sum_1428.
v-Sum_143422 = - v-Sum_143422.

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
/*10*/  "<TD>" string(date(01/01/2008)) "</TD>" skip
/*11*/  "<TD></TD>" skip
/*12*/  "<TD></TD>" skip
/*13*/  "<TD>30</TD>" skip
/*14*/  "<TD></TD>" skip
/*15*/  "<TD>" GetNormSummRash((v-Sum_1401 + v-Sum_1403 + v-Sum_1411 + v-Sum_1417) - v-BalSum_1) "</TD>" skip
/*16*/  "<TD>" GetNormSummRash(v-Sum_1424 - v-BalSum_7) "</TD>" skip
/*17*/  "<TD>" GetNormSummRash(v-Sum_1740 - (v-BalSum_2 + v-BalSum_49)) "</TD>" skip
/*18*/  "<TD>" GetNormSummRash(v-Sum_1741 - v-BalSum_9) "</TD>" skip
/*19*/  "<TD></TD>" skip
/*20*/  "<TD>" GetNormSummRash(v-Sum_143422) "</TD>" skip
/*21*/  "<TD></TD>" skip
/*22*/  "<TD></TD>" skip
/*23*/  "<TD>" GetNormSummRash((v-Sum_910011 + v-Sum_910012) - v-BalSum_41) "</TD>" skip
/*24*/  "<TD>100</TD>" skip
/*25*/  "<TD>" GetNormSummRash((v-Sum_142810 + v-Sum_142820) - v-BalSum_6) "</TD>" skip
/*26*/  "<TD>" GetNormSummRash(v-Sum_142841 - v-BalSum_36) "</TD>" skip
/*27*/  "<TD>" GetNormSummRash(v-Sum_142842 - v-BalSum_37) "</TD>" skip
/*28*/  "<TD>" GetNormSummRash(v-Sum_1428 - (v-BalSum_6 + v-BalSum_36 + v-BalSum_37)) "</TD>" skip
/*29*/  "<TD></TD>" skip
/*30*/  "<TD></TD>" skip
/*31*/  "<TD></TD>" skip
/*32*/  "<TD></TD>" skip
/*33*/  "<TD></TD>" skip
/*34*/  "<TD></TD>" skip
/*35*/  "<TD></TD>" skip
/*36*/  "<TD></TD>" skip
/*37*/  "<TD></TD>" skip
/*38*/  "<TD></TD>" skip
/*39*/  "<TD>" GetNormSummRash((v-Sum_142810 + v-Sum_142820) - v-BalSum_6) "</TD>" skip
/*40*/  "<TD></TD>" skip
/*41*/  "<TD></TD>" skip
/*42*/  "<TD></TD>" skip
/*43*/  "<TD></TD>" skip
/*44*/  "<TD></TD>" skip
/*45*/  "<TD></TD>" skip
/*46*/  "<TD></TD>" skip
/*47*/  "<TD></TD>" skip
/*48*/  "<TD></TD>" skip
/*49*/  "<TD></TD>" skip
/*50*/  "<TD>" GetNormSummRash(v-Sum_143422) "</TD>" skip
/*51*/  "<TD></TD>" skip
/*52*/  "<TD></TD>" skip
/*53*/  "<TD></TD>" skip
/*54*/  "<TD></TD>" skip
/*55*/  "<TD></TD>" skip
/*56*/  "<TD></TD>" skip
/*57*/  "<TD></TD>" skip
/*58*/  "<TD>" GetNormSummRash((v-Sum_1424 - v-BalSum_7) + (v-Sum_1740 - (v-BalSum_2 + v-BalSum_49)) + (v-Sum_1741 - v-BalSum_9) - v-Sum_143422 -
               ((v-Sum_142810 + v-Sum_142820) - v-BalSum_6) - (v-Sum_142841 - v-BalSum_36) - (v-Sum_142842 - v-BalSum_37)) "</TD>" skip
/*59*/  "<TD></TD>" skip
/*60*/  "<TD></TD>" skip
/*61*/  "<TD></TD>" skip
/*62*/  "<TD></TD>" skip
/*63*/  "<TD></TD>" skip
/*64*/  "<TD></TD>" skip
/*65*/  "<TD></TD>" skip
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
/*1*/   "<TD>номер балансового счета</TD>" skip
/*2*/   "<TD>Счет ГК</TD>" skip
/*3*/   "<TD>Наименование счета ГК</TD>" skip
/*4*/   "<TD>номер лицевого счета</TD>" skip
/*5*/   "<TD>№ договора</TD>" skip
/*6*/   "<TD>НИН</TD>" skip
/*7*/   "<TD>вид валюты</TD>" skip
/*8*/   "<TD>наименование счета</TD>" skip
/*9*/   "<TD>наименование клиента</TD>" skip
/*10*/  "<TD>дата открытия</TD>" skip
/*11*/  "<TD>дата закрытия</TD>" skip
/*12*/  "<TD>*дата открытия после пролонгации</TD>" skip
/*13*/  "<TD>*дата закрытия после пролонгации</TD>" skip
/*14*/  "<TD>количество дней до погашения</TD>" skip /*из расчета 365 дней в году*/
/*15*/  "<TD>количество до погашения в месяцах</TD>" skip
/*16*/  "<TD>код срока оставшийся до погашения</TD>" skip
/*17*/  "<TD>код строки</TD>" skip
/*18*/  "<TD>Классификационная категория</TD>" skip
/*19*/  "<TD>Баланс</TD>" skip
/*20*/  "<TD>До востребования</TD>" skip
/*21*/  "<TD>от 1 до 30 дней</TD>" skip
/*22*/  "<TD>от 31 до 90 дней</TD>" skip
/*23*/  "<TD>от 91 до 180 дней</TD>" skip
/*24*/  "<TD>от 181 до 365 дней</TD>" skip
/*25*/  "<TD>от 1 года до 2 лет</TD>" skip
/*26*/  "<TD>от 2 лет до 3 лет</TD>" skip
/*27*/  "<TD>от 3 лет до 5 лет</TD>" skip
/*28*/  "<TD>более 5 лет</TD>" skip
/*29*/  "<TD>SUBLED</TD>" skip
    "</TR>" skip.

Assets:
for each tgl where tgl.sub-type ne "lon" no-lock break by tgl.gl4:
    if not (string(tgl.gl) begins "1") then next Assets.
    if tgl.sum = 0 then next Assets.
    if tgl.gl = 143422 then next Assets.

    v-codesrok = ''. v-DtLog = false. v-Classific = 0.
    find t-wrk where t-wrk.txb eq tgl.txb and t-wrk.sub eq tgl.sub-type and t-wrk.acc eq tgl.acc exclusive-lock no-error.
    if avail t-wrk then do:
        if string(tgl.gl4) begins "174" and t-wrk.sub = "SCU" then do:
            t-wrk.rdt = t-wrk.rdt_2.
            t-wrk.duedt = t-wrk.duedt_2.

            if t-wrk.duedt ne ? then t-wrk.dnpogash = t-wrk.duedt - v-gldate.
            else t-wrk.dnpogash = 0.
            if t-wrk.dnpogash ne 0 then t-wrk.mtpogash = round(t-wrk.dnpogash / 30,0).
            else t-wrk.mtpogash = 0.
        end.

        if t-wrk.duedt ne ? or t-wrk.duedt_1 ne ? then do:
            run GetPeriodClass(t-wrk.dnpogash,tgl.sum,output t-wrk.per1-30,output t-wrk.per31-90,output t-wrk.per91-180,
            output t-wrk.per181-365,output t-wrk.per366-730,output t-wrk.per731-1095,output t-wrk.per1096-1825,output t-wrk.per1826,
            output t-wrk.codesrok).
        end.
        else t-wrk.codesrok = "До востребования".
    end.
    else v-codesrok = "До востребования".
    find t-wrk where t-wrk.txb eq tgl.txb and t-wrk.sub eq tgl.sub-type and t-wrk.acc eq tgl.acc no-lock no-error.

    find crc where crc.crc eq tgl.crc no-lock no-error.

    put stream rep_2 unformatted
        "<TR style='font-size:10pt'>" skip
/*1*/   "<TD>" string(tgl.gl4) "</TD>" skip
/*2*/   "<TD>" string(tgl.gl) "</TD>" skip
/*3*/   "<TD>" string(tgl.gl-des) "</TD>" skip
/*4*/   "<TD>" tgl.acc "</TD>" skip
/*5*/   "<TD></TD>" skip.
    if avail t-wrk then put stream rep_2 unformatted
/*6*/   "<TD>" t-wrk.nin "</TD>" skip.
    else put stream rep_2 unformatted
        "<TD></TD>" skip.
    put stream rep_2 unformatted
/*7*/   "<TD>" crc.code "</TD>" skip
/*8*/   "<TD>" tgl.acc-des "</TD>" skip.
    if avail t-wrk then put stream rep_2 unformatted
/*9*/   "<TD>" t-wrk.clientname "</TD>" skip
/*10*/  "<TD>" GetTypeDate(t-wrk.rdt) "</TD>" skip
/*11*/  "<TD>" GetTypeDate(t-wrk.duedt) "</TD>" skip
/*12*/  "<TD>" GetTypeDate(t-wrk.rdt_1) "</TD>" skip
/*13*/  "<TD>" GetTypeDate(t-wrk.duedt_1) "</TD>" skip
/*14*/  "<TD>" string(t-wrk.dnpogash) "</TD>" skip
/*15*/  "<TD>" GetNormAll(t-wrk.mtpogash) "</TD>" skip
/*16*/  "<TD>" t-wrk.codesrok "</TD>" skip.
    else put stream rep_2 unformatted
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>" v-codesrok "</TD>" skip.

    find first t-Classific where lookup(string(tgl.gl4),t-Classific.gl_4) gt 0 exclusive-lock no-error.
    if avail t-Classific then do:
        put stream rep_2 unformatted
/*17*/      "<TD>" string(t-Classific.code) "</TD>" skip.

        if avail t-wrk then do:
            v-DtLog = t-wrk.dnpogash le 0.
            if v-DtLog then t-Classific.do_vos = t-Classific.do_vos + tgl.sum.

            t-Classific.per1-30 = t-Classific.per1-30 + t-wrk.per1-30.
            t-Classific.per31-90 = t-Classific.per31-90 + t-wrk.per31-90.
            t-Classific.per91-180 = t-Classific.per91-180 + t-wrk.per91-180.
            t-Classific.per181-365 = t-Classific.per181-365 + t-wrk.per181-365.
            t-Classific.per366-730 = t-Classific.per366-730 + t-wrk.per366-730.
            t-Classific.per731-1095 = t-Classific.per731-1095 + t-wrk.per731-1095.
            t-Classific.per1096-1825 = t-Classific.per1096-1825 + t-wrk.per1096-1825.
            t-Classific.per1826 = t-Classific.per1826 + t-wrk.per1826.
        end.
        else t-Classific.do_vos = t-Classific.do_vos + tgl.sum.
    end.
    else put stream rep_2 unformatted
/*17*/  "<TD>" GetTypeClass(v-Classific) "</TD>" skip.
    find first t-Classific where lookup(string(tgl.gl4),t-Classific.gl_4) gt 0 no-lock no-error.
    put stream rep_2 unformatted
/*18*/  "<TD></TD>" skip
/*19*/  "<TD>" GetNormSummRash(tgl.sum) "</TD>" skip.
    if avail t-wrk then do:
        v-DtLog = t-wrk.dnpogash le 0.

        if v-DtLog then put stream rep_2 unformatted
/*20*/      "<TD>" GetNormSummRash(tgl.sum) "</TD>" skip.
        else put stream rep_2 unformatted
/*20*/      "<TD></TD>" skip.
    end.
    else put stream rep_2 unformatted
/*20*/      "<TD>" GetNormSummRash(tgl.sum) "</TD>" skip.

    if avail t-wrk then put stream rep_2 unformatted
/*21*/  "<TD>" GetNormSummRash(t-wrk.per1-30) "</TD>" skip
/*22*/  "<TD>" GetNormSummRash(t-wrk.per31-90) "</TD>" skip
/*23*/  "<TD>" GetNormSummRash(t-wrk.per91-180) "</TD>" skip
/*24*/  "<TD>" GetNormSummRash(t-wrk.per181-365) "</TD>" skip
/*25*/  "<TD>" GetNormSummRash(t-wrk.per366-730) "</TD>" skip
/*26*/  "<TD>" GetNormSummRash(t-wrk.per731-1095) "</TD>" skip
/*27*/  "<TD>" GetNormSummRash(t-wrk.per1096-1825) "</TD>" skip
/*28*/  "<TD>" GetNormSummRash(t-wrk.per1826) "</TD>" skip.
    else put stream rep_2 unformatted
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip.
    put stream rep_2 unformatted
/*29*/  "<TD>" tgl.sub-type "</TD>" skip.
    put stream rep_2 unformatted
        "</TR>" skip.

    hide message no-pause.
    message 'Assets.acc = ' tgl.acc.
end.

put stream rep_2 unformatted
    "</TABLE>" skip.

{html-end.i "stream rep_2"}
output stream rep_2 close.

unix silent cptwin value(v-file_2) excel.

end.

if v-Liabilities then do:

output stream rep_3 to value(v-file_3).
{html-title.i &stream = "stream rep_3"}

put stream rep_3 unformatted
    "<P align=center style='font-size:12pt;font:bold'>«Обязательства»<br>за дату&nbsp;" string(v-gldate,"99/99/9999") "</P>" skip.

put stream rep_3 unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep_3 unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
/*1*/   "<TD>номер балансового счета</TD>" skip
/*2*/   "<TD>Счет ГК</TD>" skip
/*3*/   "<TD>Наименование счета ГК</TD>" skip
/*4*/   "<TD>номер лицевого счета</TD>" skip
/*5*/   "<TD>№ договора</TD>" skip
/*6*/   "<TD>вид валюты</TD>" skip
/*7*/   "<TD>наименование счета</TD>" skip
/*8*/   "<TD>наименование клиента</TD>" skip
/*9*/   "<TD>дата открытия</TD>" skip
/*10*/  "<TD>дата закрытия</TD>" skip
/*11*/  "<TD>*дата открытия после пролонгации</TD>" skip
/*12*/  "<TD>*дата закрытия после пролонгации</TD>" skip
/*13*/  "<TD>количество дней до погашения</TD>" skip /*из расчета 365 дней в году*/
/*14*/  "<TD>количество до погашения в месяцах</TD>" skip
/*15*/  "<TD>код срока оставшийся до погашения</TD>" skip
/*16*/  "<TD>код строки</TD>" skip
/*17*/  "<TD>Баланс</TD>" skip
/*18*/  "<TD>До востребования</TD>" skip
/*19*/  "<TD>от 1 до 30 дней</TD>" skip
/*20*/  "<TD>от 31 до 90 дней</TD>" skip
/*21*/  "<TD>от 91 до 180 дней</TD>" skip
/*22*/  "<TD>от 181 до 365 дней</TD>" skip
/*23*/  "<TD>от 1 года до 2 лет</TD>" skip
/*24*/  "<TD>от 2 лет до 3 лет</TD>" skip
/*25*/  "<TD>от 3 лет до 5 лет</TD>" skip
/*26*/  "<TD>более 5 лет</TD>" skip
/*27*/  "<TD>SUBLED</TD>" skip
    "</TR>" skip.

Liabilities:
for each tgl where tgl.sub-type ne "lon" no-lock break by tgl.gl4:
    if not (string(tgl.gl) begins "2") then next Liabilities.
    if tgl.sum = 0 then next.

    v-codesrok = ''. v-DtLog = false.
    find t-wrk where t-wrk.txb eq tgl.txb and t-wrk.sub eq tgl.sub-type and t-wrk.acc eq tgl.acc exclusive-lock no-error.
    if avail t-wrk then do:
        if t-wrk.duedt ne ? or t-wrk.duedt_1 ne ? then do:
            run GetPeriodClass(t-wrk.dnpogash,tgl.sum,output t-wrk.per1-30,output t-wrk.per31-90,output t-wrk.per91-180,
            output t-wrk.per181-365,output t-wrk.per366-730,output t-wrk.per731-1095,output t-wrk.per1096-1825,output t-wrk.per1826,
            output t-wrk.codesrok).
        end.
        else t-wrk.codesrok = "До востребования".
    end.
    else v-codesrok = "До востребования".
    find t-wrk where t-wrk.txb eq tgl.txb and t-wrk.sub eq tgl.sub-type and t-wrk.acc eq tgl.acc no-lock no-error.

    find crc where crc.crc eq tgl.crc no-lock no-error.

    put stream rep_3 unformatted
        "<TR style='font-size:10pt'>" skip
/*1*/   "<TD>" string(tgl.gl4) "</TD>" skip
/*2*/   "<TD>" string(tgl.gl) "</TD>" skip
/*3*/   "<TD>" string(tgl.gl-des) "</TD>" skip
/*4*/   "<TD>" tgl.acc "</TD>" skip
/*5*/   "<TD></TD>" skip
/*6*/   "<TD>" crc.code "</TD>" skip
/*7*/   "<TD>" tgl.acc-des "</TD>" skip.
    if avail t-wrk then do:
        put stream rep_3 unformatted
/*8*/       "<TD>" t-wrk.clientname "</TD>" skip
/*9*/       "<TD>" GetTypeDate(t-wrk.rdt) "</TD>" skip
/*10*/      "<TD>" GetTypeDate(t-wrk.duedt) "</TD>" skip
/*11*/      "<TD>" GetTypeDate(t-wrk.rdt_1) "</TD>" skip
/*12*/      "<TD>" GetTypeDate(t-wrk.duedt_1) "</TD>" skip
/*13*/      "<TD>" string(t-wrk.dnpogash) "</TD>" skip
/*14*/      "<TD>" string(t-wrk.mtpogash) "</TD>" skip
/*15*/      "<TD>" t-wrk.codesrok "</TD>" skip.
    end.
    else put stream rep_3 unformatted
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>" v-codesrok "</TD>" skip.

    find first t-Classific where lookup(string(tgl.gl4),t-Classific.gl_4) gt 0 exclusive-lock no-error.
    if avail t-Classific then do:
        put stream rep_3 unformatted
/*16*/      "<TD>" string(t-Classific.code) "</TD>" skip.

        if avail t-wrk then do:
            v-DtLog = t-wrk.dnpogash le 0.
            if v-DtLog then t-Classific.do_vos = t-Classific.do_vos + tgl.sum.

            t-Classific.per1-30 = t-Classific.per1-30 + t-wrk.per1-30.
            t-Classific.per31-90 = t-Classific.per31-90 + t-wrk.per31-90.
            t-Classific.per91-180 = t-Classific.per91-180 + t-wrk.per91-180.
            t-Classific.per181-365 = t-Classific.per181-365 + t-wrk.per181-365.
            t-Classific.per366-730 = t-Classific.per366-730 + t-wrk.per366-730.
            t-Classific.per731-1095 = t-Classific.per731-1095 + t-wrk.per731-1095.
            t-Classific.per1096-1825 = t-Classific.per1096-1825 + t-wrk.per1096-1825.
            t-Classific.per1826 = t-Classific.per1826 + t-wrk.per1826.
        end.
        else t-Classific.do_vos = t-Classific.do_vos + tgl.sum.
    end.
    else put stream rep_3 unformatted
/*16*/  "<TD></TD>" skip.
    find first t-Classific where lookup(string(tgl.gl4),t-Classific.gl_4) gt 0 no-lock no-error.
    put stream rep_3 unformatted
/*17*/  "<TD>" GetNormSummRash(tgl.sum) "</TD>" skip.
    if avail t-wrk then do:
        v-DtLog = t-wrk.dnpogash le 0.
        if v-DtLog then put stream rep_3 unformatted
/*18*/      "<TD>" GetNormSummRash(tgl.sum) "</TD>" skip.
        else put stream rep_3 unformatted
            "<TD></TD>" skip.
    end.
    else put stream rep_3 unformatted
        "<TD>" GetNormSummRash(tgl.sum) "</TD>" skip.
    if avail t-wrk then put stream rep_3 unformatted
/*19*/  "<TD>" GetNormSummRash(t-wrk.per1-30) "</TD>" skip
/*20*/  "<TD>" GetNormSummRash(t-wrk.per31-90) "</TD>" skip
/*21*/  "<TD>" GetNormSummRash(t-wrk.per91-180) "</TD>" skip
/*22*/  "<TD>" GetNormSummRash(t-wrk.per181-365) "</TD>" skip
/*23*/  "<TD>" GetNormSummRash(t-wrk.per366-730) "</TD>" skip
/*24*/  "<TD>" GetNormSummRash(t-wrk.per731-1095) "</TD>" skip
/*25*/  "<TD>" GetNormSummRash(t-wrk.per1096-1825) "</TD>" skip
/*26*/  "<TD>" GetNormSummRash(t-wrk.per1826) "</TD>" skip.
    else put stream rep_3 unformatted
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip.
    put stream rep_3 unformatted
/*27*/  "<TD>" tgl.sub-type "</TD>" skip.
    put stream rep_3 unformatted
        "</TR>" skip.

    hide message no-pause.
    message 'Liabilities.acc = ' tgl.acc.
end.

put stream rep_3 unformatted
    "</TABLE>" skip.

{html-end.i "stream rep_3"}
output stream rep_3 close.

unix silent cptwin value(v-file_3) excel.

end.

output stream rep to value(v-file).
{html-title.i &stream = "stream rep"}

put stream rep unformatted
    '<P align=right style="font-size:10pt;font-family:Times New Roman">Приложение 11  к Правилам<br>представления отчетности<br>банками второго уровня<br>Республики Казахстан</P>' skip
    '<P align=center style="font-size:10pt;font:bold;font-family:Times New Roman">Срок платежа, оставшийся до погашения<br>АО "ForteBank"<br>(наименование банка)<br>
    по состоянию на&nbsp;' string(v-RepDt,"99/99/9999") '</P>' skip.

put stream rep unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD rowspan=2>№</TD>" skip
    "<TD rowspan=2>Активы</TD>" skip
    "<TD colspan=9>стандартные и сомнительные 1 категории, а также сомнительные 2, 3, 4, 5 категории и безнадежные, по которым<br>отсутствует
    просроченная задолженность по основному долгу и начисленному вознаграждению</TD>" skip
    "<TD rowspan=2>сомнительные 2, 3,<br>4, 5 категории и<br>безнадежные<br>активы, по<br>которым имеется<br>просроченная<br>задолженность
    по<br>основному долгу<br>и/или<br>начисленному<br>вознаграждению</TD>" skip
    "</TR>" skip
    "<TR align=center style='font-size:10pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD>До<br>востребования</TD>" skip
    "<TD>от 1 до 30<br>дней</TD>" skip
    "<TD>от 31 до 90<br>дней</TD>" skip
    "<TD>от 91 до<br>180 дней</TD>" skip
    "<TD>от 181 до<br>365 дней</TD>" skip
    "<TD>от 1 до 2<br>лет</TD>" skip
    "<TD>от 2 до 3<br>лет</TD>" skip
    "<TD>от 3 до 5 лет</TD>" skip
    "<TD>более 5 лет</TD>" skip
    "</TR>" skip.

run AdditionalCalculation.

vv-do_vos = 0. vv-per1-30 = 0. vv-per31-90 = 0. vv-per91-180 = 0. vv-per181-365 = 0. vv-per366-730 = 0. vv-per731-1095 = 0. vv-per1096-1825 = 0.
vv-per1826 = 0. vv-restsum = 0.
for each t-Classific where t-Classific.code le 8 no-lock:
    put stream rep unformatted
        "<TR align=center style='font-size:10pt;font-family:Times New Roman;vertical-align:middle'>" skip
        "<TD>" string(t-Classific.code) "</TD>" skip
        "<TD align=left>" t-Classific.name "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.do_vos) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per1-30) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per31-90) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per91-180) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per181-365) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per366-730) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per731-1095) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per1096-1825) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per1826) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.restsum) "</TD>" skip
        "</TR>" skip.

    vv-do_vos = vv-do_vos + t-Classific.do_vos.
    vv-per1-30 = vv-per1-30 + t-Classific.per1-30.
    vv-per31-90 = vv-per31-90 + t-Classific.per31-90.
    vv-per91-180 = vv-per91-180 + t-Classific.per91-180.
    vv-per181-365 = vv-per181-365 + t-Classific.per181-365.
    vv-per366-730 = vv-per366-730 + t-Classific.per366-730.
    vv-per731-1095 = vv-per731-1095 + t-Classific.per731-1095.
    vv-per1096-1825 = vv-per1096-1825 + t-Classific.per1096-1825.
    vv-per1826 = vv-per1826 + t-Classific.per1826.
    vv-restsum = vv-restsum + t-Classific.restsum.
end.
put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD>9</TD>" skip
    "<TD align=left>Итого</TD>" skip
    "<TD>" GetNormSumm(vv-do_vos) "</TD>" skip
    "<TD>" GetNormSumm(vv-per1-30) "</TD>" skip
    "<TD>" GetNormSumm(vv-per31-90) "</TD>" skip
    "<TD>" GetNormSumm(vv-per91-180) "</TD>" skip
    "<TD>" GetNormSumm(vv-per181-365) "</TD>" skip
    "<TD>" GetNormSumm(vv-per366-730) "</TD>" skip
    "<TD>" GetNormSumm(vv-per731-1095) "</TD>" skip
    "<TD>" GetNormSumm(vv-per1096-1825) "</TD>" skip
    "<TD>" GetNormSumm(vv-per1826) "</TD>" skip
    "<TD>" GetNormSumm(vv-restsum) "</TD>" skip
    "</TR>" skip.

put stream rep unformatted
    "</TABLE>" skip.

put stream rep unformatted
    '<P width="30%"></P>' skip.

put stream rep unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD></TD>" skip
    "<TD>Обязательства</TD>" skip
    "<TD>До<br>востребования</TD>" skip
    "<TD>от 1 до 30<br>дней</TD>" skip
    "<TD>от 31 до 90<br>дней</TD>" skip
    "<TD>от 91 до<br>180 дней</TD>" skip
    "<TD>от 181 до<br>365 дней</TD>" skip
    "<TD>от 1 до 2<br>лет</TD>" skip
    "<TD>от 2 до 3<br>лет</TD>" skip
    "<TD>от 3 до 5 лет</TD>" skip
    "<TD>более 5 лет</TD>" skip
    "</TR>" skip.

vv-do_vos = 0. vv-per1-30 = 0. vv-per31-90 = 0. vv-per91-180 = 0. vv-per181-365 = 0. vv-per366-730 = 0. vv-per731-1095 = 0. vv-per1096-1825 = 0.
vv-per1826 = 0.
for each t-Classific where t-Classific.code ge 10 no-lock:
    put stream rep unformatted
        "<TR align=center style='font-size:10pt;font-family:Times New Roman;vertical-align:middle'>" skip
        "<TD>" string(t-Classific.code) "</TD>" skip
        "<TD align=left>" t-Classific.name "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.do_vos) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per1-30) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per31-90) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per91-180) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per181-365) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per366-730) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per731-1095) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per1096-1825) "</TD>" skip
        "<TD>" GetNormSumm(t-Classific.per1826) "</TD>" skip
        "</TR>" skip.

    vv-do_vos = vv-do_vos + t-Classific.do_vos.
    vv-per1-30 = vv-per1-30 + t-Classific.per1-30.
    vv-per31-90 = vv-per31-90 + t-Classific.per31-90.
    vv-per91-180 = vv-per91-180 + t-Classific.per91-180.
    vv-per181-365 = vv-per181-365 + t-Classific.per181-365.
    vv-per366-730 = vv-per366-730 + t-Classific.per366-730.
    vv-per731-1095 = vv-per731-1095 + t-Classific.per731-1095.
    vv-per1096-1825 = vv-per1096-1825 + t-Classific.per1096-1825.
    vv-per1826 = vv-per1826 + t-Classific.per1826.
end.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold;font-family:Times New Roman;vertical-align:middle'>" skip
    "<TD>20</TD>" skip
    "<TD align=left>Итого:</TD>" skip
    "<TD>" GetNormSumm(vv-do_vos) "</TD>" skip
    "<TD>" GetNormSumm(vv-per1-30) "</TD>" skip
    "<TD>" GetNormSumm(vv-per31-90) "</TD>" skip
    "<TD>" GetNormSumm(vv-per91-180) "</TD>" skip
    "<TD>" GetNormSumm(vv-per181-365) "</TD>" skip
    "<TD>" GetNormSumm(vv-per366-730) "</TD>" skip
    "<TD>" GetNormSumm(vv-per731-1095) "</TD>" skip
    "<TD>" GetNormSumm(vv-per1096-1825) "</TD>" skip
    "<TD>" GetNormSumm(vv-per1826) "</TD>" skip
    "</TR>" skip.

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

empty temp-table t-gldy.
empty temp-table t-wrk.
empty temp-table tgl.

procedure GetPeriodClass:
    def input parameter p-day as inte.
    def input parameter p-bal as deci.
    def output parameter v_1-30 as deci.
    def output parameter v_31-90 as deci.
    def output parameter v_91-180 as deci.
    def output parameter v_181-365 as deci.
    def output parameter v_366-730 as deci.
    def output parameter v_731-1095 as deci.
    def output parameter v_1096-1825 as deci.
    def output parameter v_1826 as deci.
    def output parameter v_des as char.

    def var v-dtday as inte init ?.

    v_1-30 = 0. v_31-90 = 0. v_91-180 = 0. v_181-365 = 0. v_366-730 = 0. v_731-1095 = 0. v_1096-1825 = 0. v_1826 = 0. v_des = "".

    if p-day le 0 then v_des = 'До востребования'.
    else if p-day ge 1 and p-day le 30 then do: v_des = 'от 1 до 30 дней'. v_1-30 = v_1-30 + p-bal. end.
    else if p-day ge 31 and p-day le 90 then do: v_des = 'от 31 до 90 дней'. v_31-90 = v_31-90 + p-bal. end.
    else if p-day ge 91 and p-day le 180 then do: v_des = 'от 91 до 180 дней'. v_91-180 = v_91-180 + p-bal. end.
    else if p-day ge 181 and p-day le 365 then do: v_des = 'от 181 до 365 дней'. v_181-365 = v_181-365 + p-bal. end.
    else if p-day ge 366 and p-day le 730 then do: v_des = 'от 1 года до 2 лет'. v_366-730 = v_366-730 + p-bal. end.
    else if p-day ge 731 and p-day le 1095 then do: v_des = 'от 2 лет до 3 лет'. v_731-1095 = v_731-1095 + p-bal. end.
    else if p-day ge 1096 and p-day le 1825 then do: v_des = 'от 3 лет до 5 лет'. v_1096-1825 = v_1096-1825 + p-bal. end.
    else if p-day ge 1826 then do: v_des = 'более 5 лет'. v_1826 = v_1826 + p-bal. end.
end procedure.

procedure AdditionalCalculation:
    find first t-Classific where t-Classific.code eq 1 exclusive-lock no-error.
    if avail t-Classific then t-Classific.per1-30 = t-Classific.per1-30 + ((v-Sum_1401 + v-Sum_1403 + v-Sum_1411 + v-Sum_1417) - v-BalSum_1) +
    (v-Sum_1424 - v-BalSum_7) - ((v-Sum_142810 + v-Sum_142820) - v-BalSum_6).
    find first t-Classific where t-Classific.code eq 1 no-lock no-error.
end procedure.


