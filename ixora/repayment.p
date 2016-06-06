/* repayment.p
 * MODULE
        Управленческая отчетность
 * DESCRIPTION
        Сведения о фактическом погашении обязательств перед нерезидентами Республики Казахстан за отчетный месяц
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
        29/11/2012 Luiza
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.


def new shared temp-table wrk2 no-undo /* план факт для текущего года  */
    field Num as integer
    field vid as char
    field vid1 as char
    field vid2 as char
    field year as int
    field month as int
    field p_debt as decim extent 13
    field f_debt as decim extent 13
    field p_reward as decim extent 13
    field f_reward as decim extent 13.

def new shared temp-table wrk3 no-undo /* план факт для следующего года  */
    field Num as integer
    field vid as char
    field vid1 as char
    field vid2 as char
    field year as int
    field month as int
    field p_debt as decim extent 13
    field f_debt as decim extent 13
    field p_reward as decim extent 13
    field f_reward as decim extent 13.

def new shared temp-table wrk no-undo /* факт */
    field Num as integer
    field vid as char
    field sub as char
    field vid1 as char
    field vid2 as char
    field jh as int
    field whn as date
    field month as int
    field p_debt as decim extent 12
    field f_debt as decim extent 12
    field p_reward as decim extent 12
    field f_reward as decim extent 12
    field cif as char /* cif клиента */
    field name as char /* наименование  */
    field acc as char /* счет  */
    field geo as char /* гео код */
    field pri as char /* физ юр  */
    field gl4 as char /* балансовый счет 4 знака */
    field gl7 as char /* 7 знаков  + IBAN  */
    field crc as int /* валюта счета  */
    field dopen as date /* дата открытия счета  */
    field dclose as date /* дата закрытия  */
    field stav as decim /* проц ставки  */
    field dt4 as char /* дебет бал счет 4 знака  */
    field dt7 as char /* дебет бал счет 7 знака   */
    field ct4 as char /* кредит бал счет 4 знака  */
    field ct7 as char /* кредит бал счет 7 знака  */
    field sumd as decim /* сумма номинал дебета */
    field sumtngd as decim /* сумма в тенге  */
    field sumc as decim /* сумма номинал кредита */
    field sumtngc as decim /* сумма в тенге  */
    field fil as char /* филиал  */
    field txb as char /* филиал  */
    field df as char /* долг вознагр признак */
    index ind is primary txb num cif acc .


def new shared temp-table wrk1 no-undo /* план */
    field Num as integer
    field vid as char
    field sub as char
    field vid1 as char
    field vid2 as char
    field jh as int
    field month as int
    field p_debt as decim
    field f_debt as decim
    field p_reward as decim
    field f_reward as decim
    field cif as char /* cif клиента */
    field name as char /* наименование  */
    field acc as char /* счет  */
    field geo as char /* гео код */
    field pri as char /* физ юр  */
    field gl4 as char /* балансовый счет 4 знака */
    field gl7 as char /* 7 знаков  + IBAN  */
    field crc as int /* валюта счета  */
    field dopen as date /* дата открытия счета  */
    field dclose as date /* дата закрытия  */
    field stav as decim /* проц ставки  */
    field dt4 as char /* дебет бал счет 4 знака  */
    field dt7 as char /* дебет бал счет 7 знака   */
    field ct4 as char /* кредит бал счет 4 знака  */
    field ct7 as char /* кредит бал счет 7 знака  */
    field sum as decim /* сумма номинал  */
    field sumtngd as decim /* сумма в тенге  */
    field sumtngr as decim /* сумма в тенге  */
    field ostf as decim /* сумма в тенге  */
    field oste as decim /* сумма в тенге  */
    field fil as char /* филиал  */
    field txb as char /* филиал  */
    field df as char /* долг вознагр признак */
    index ind is primary txb acc .

def new shared var dt1 as date no-undo.
def new shared var dt2 as date no-undo.
def new shared var dt3 as date no-undo.
def new shared var dt4 as date no-undo.
def var v-dt as date no-undo.
def var i as integer.
def var v-result as char no-undo.
def var repname as char no-undo.
def new shared var v-sel as int no-undo.
def var v-select1 as int no-undo.
def var v-raz as char  no-undo.
def var vyear as int  no-undo.
def var vyear1 as int  no-undo.
def var sum as decim no-undo.
def new shared var vmonth as int  no-undo.
def var vmonth1 as int  no-undo.
def var v-ful as logic format "да/нет" no-undo.
def new shared var v-ful1 as int no-undo.
v-ful = false.
def var ii as int.
def var sumd as decim extent 13. /* для итого по дням долга*/
def var sumr as decim extent 13.  /* для итого по дням вознагражд */
def var sumd13 as decim . /* для итого по видам долга*/
def var sumr13 as decim .  /* для итого по видам вознагражд */
def var subr as decim .  /* 1)	Необходимо посадить суммы по суборд. займу как начисленное вознаграждения
                            по месяцам (янв, апр, июль, окт) указанным в плане(приложение 1) на 10 числа.*/
/*subr = 20994000.*/



v-sel = 0.
run sel2 (" ОТЧЕТ ", "1.Все  |2.Сведения о факт. погашении обязательств |3.Сведения о план. погашении обязательств  |4. ВЫХОД ", output v-sel).
if keyfunction (lastkey) = "end-error" or v-sel = 4 then return.
displ dt1 label   " С " format "99/99/9999" validate(dt1 < g-today, "Некорректная дата!") skip
      dt2 label   " По" format "99/99/9999" validate(dt2 < g-today and dt2 > dt1 , "Некорректная дата!") skip
      v-ful label " С расшифровкой" skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update dt2 v-ful with frame dat.
vyear = year(dt1).
vmonth = month(dt1).
if vmonth < 12 then dt3 = date(vmonth + 1,1,vyear).
else dt3 = date(1,1,vyear + 1).

vmonth1 = month(dt3).
if vmonth1 = 1 or vmonth1 = 4 or vmonth1 = 7 or vmonth1 = 10 then subr = 20994000. /*Необходимо посадить суммы по суборд. займу как начисленное вознаграждения
                                                                                по месяцам (янв, апр, июль, окт) указанным в плане(приложение 1) на 10 числа.*/

vyear1 = year(dt3).
if vmonth1 < 12 then dt4 = date(vmonth1 + 1,1,vyear1) - 1.
else dt4 = date(1,1,vyear1 + 1) - 1.


if v-ful then do:
    v-ful1 = 0.
    run sel2 (" Выберите расшифровка для:", "1. Для прилож.1 |2. Для прилож.2 |3. ВСЕ |4. ВЫХОД ", output v-ful1).
    if keyfunction (lastkey) = "end-error" or v-ful1 = 4 then return.
end.

v-select1 = 0.
run sel2 (" Выберите ", "1.В тыс.тенге |2.В тенге|3. ВЫХОД ", output v-select1).
if keyfunction (lastkey) = "end-error" or v-select1 = 3 then return.
if v-select1 = 1 then v-raz = "В тыс.тенге". else v-raz = "В тенге".

/* ввод плана на 2012 */
    create wrk2.
    wrk2.num = 1.
    wrk2.vid = "Займы от банков и организаций, осуществляющих отдельные виды банковских операций".
    wrk2.vid1 = "2052,2054,2056,2057,2064,2066,2067,2112,2113".
    wrk2.vid2 = "2705,2711".
    create wrk2.
    wrk2.num = 2.
    wrk2.vid = "Займы от международных финансовых организаций".
    wrk2.vid1 = "2044,2046".
    wrk2.vid2 = "2704".
    create wrk2.
    wrk2.num = 3.
    wrk2.vid = "Синдицированные займы".
    wrk2.vid1 = "2052,2054,2056,2057,2064,2066,2067,2112,2113,2044,2046".
    wrk2.vid2 = "2705,2711,2704".
    create wrk2.
    wrk2.num = 4.
    wrk2.vid = "Субординированный долг, в т.ч.:".
    wrk2.vid1 = "2401,2402,2406".
    wrk2.vid2 = "2740".
    wrk2.p_reward[1] = 20994000.
    wrk2.p_reward[4] = 20994000.
    wrk2.p_reward[7] = 20994000.
    wrk2.p_reward[10] = 20994000.
    create wrk2.
    wrk2.num = 5.
    wrk2.vid = "займы".
    wrk2.vid1 = "2401,2402".
    wrk2.vid2 = "2740".
    wrk2.p_reward[1] = 20994000.
    wrk2.p_reward[4] = 20994000.
    wrk2.p_reward[7] = 20994000.
    wrk2.p_reward[10] = 20994000.
    create wrk2.
    wrk2.num = 6.
    wrk2.vid = "облигации".
    wrk2.vid1 = "2406".
    /*wrk2.vid2 = "2740".*/
    create wrk2.
    wrk2.num = 7.
    wrk2.vid = "Вклады дочерних организаций специального назначения".
    wrk2.vid1 = "2222".
    wrk2.vid2 = "2722".
    create wrk2.
    wrk2.num = 8.
    wrk2.vid = "Межбанковские вклады".
    wrk2.vid1 = "2022,2023,2123,2124,2125,2126,2127,2131,2133".
    wrk2.vid2 = "2708,2712,2713,2714".
    create wrk2.
    wrk2.num = 9.
    wrk2.vid = "Вклады клиентов".
    wrk2.vid1 = "2206,2207,2208,2211,2213,2215,2216,2217,2219,2223,2240".
    wrk2.vid2 = "2707,2719,2721,2723".
     wrk2.p_debt[1] = 40000.
     wrk2.p_debt[3] = 78000.
     wrk2.p_debt[5] = 73000.
     wrk2.p_debt[6] = 1066000.
     wrk2.p_reward[6] = 1000.

     wrk2.p_debt[9] = 300000.
     wrk2.p_reward[9] = 42000.
     wrk2.p_debt[10] = 5407000.
     wrk2.p_reward[10] = 32000.
     wrk2.p_debt[11] = 2480000.
     wrk2.p_reward[11] = 37000.
     wrk2.p_debt[12] = 18139000.
     wrk2.p_reward[12] = 65000.
    create wrk2.
    wrk2.num = 10.
    wrk2.vid = "Операции РЕПО".
    wrk2.vid1 = "2255".
    wrk2.vid2 = "2725".
    create wrk2.
    wrk2.num = 11.
    wrk2.vid = "Выпущенные в обращение ценные бумаги".
    wrk2.vid1 = "2301,2303".
    wrk2.vid2 = "2730".
    create wrk2.
    wrk2.num = 12.
    wrk2.vid = "Прочие*".
    wrk2.vid1 = "".
    wrk2.vid2 = "".
    create wrk2.
    wrk2.num = 13.
    wrk2.vid = "Итого".
    wrk2.vid1 = "".
    wrk2.vid2 = "".

/* ввод плана на 2013 */
    create wrk3.
    wrk3.num = 1.
    wrk3.vid = "Займы от банков и организаций, осуществляющих отдельные виды банковских операций".
    wrk3.vid1 = "2052,2054,2056,2057,2064,2066,2067,2112,2113".
    wrk3.vid2 = "2705,2711".
    create wrk3.
    wrk3.num = 2.
    wrk3.vid = "Займы от международных финансовых организаций".
    wrk3.vid1 = "2044,2046".
    wrk3.vid2 = "2704".
    create wrk3.
    wrk3.num = 3.
    wrk3.vid = "Синдицированные займы".
    wrk3.vid1 = "2052,2054,2056,2057,2064,2066,2067,2112,2113,2044,2046".
    wrk3.vid2 = "2705,2711,2704".
    create wrk3.
    wrk3.num = 4.
    wrk3.vid = "Субординированный долг, в т.ч.:".
    wrk3.vid1 = "2401,2402,2406".
    wrk3.vid2 = "2740".
    wrk3.p_reward[1] = 20994000.
    wrk3.p_reward[4] = 20994000.
    wrk3.p_reward[10] = 20994000.
    wrk3.p_reward[7] = 20994000.
    create wrk3.
    wrk3.num = 5.
    wrk3.vid = "займы".
    wrk3.vid1 = "2401,2402".
    wrk3.vid2 = "2740".
    wrk3.p_reward[1] = 20994000.
    wrk3.p_reward[4] = 20994000.
    wrk3.p_reward[10] = 20994000.
    wrk3.p_reward[7] = 20994000.
    create wrk3.
    wrk3.num = 6.
    wrk3.vid = "облигации".
    wrk3.vid1 = "2406".
    /*wrk3.vid2 = "2740".*/
    create wrk3.
    wrk3.num = 7.
    wrk3.vid = "Вклады дочерних организаций специального назначения".
    wrk3.vid1 = "2222".
    wrk3.vid2 = "2722".
    create wrk3.
    wrk3.num = 8.
    wrk3.vid = "Межбанковские вклады".
    wrk3.vid1 = "2022,2023,2123,2124,2125,2126,2127,2131,2133".
    wrk3.vid2 = "2708,2712,2713,2714".
    create wrk3.
    wrk3.num = 9.
    wrk3.vid = "Вклады клиентов".
    wrk3.vid1 = "2206,2207,2208,2211,2213,2215,2216,2217,2219,2223,2240".
    wrk3.vid2 = "2707,2719,2721,2723".
    wrk3.p_debt[1] = 82000.
    wrk3.p_debt[4] = 98479000.
    wrk3.p_reward[4] = 196000.
    wrk3.p_debt[6] = 70000.
    wrk3.p_debt[10] = 22382000.
    wrk3.p_reward[10] = 29000.
    wrk3.p_debt[11] = 4984000.
    wrk3.p_reward[11] = 7000.
    create wrk3.
    wrk3.num = 10.
    wrk3.vid = "Операции РЕПО".
    wrk3.vid1 = "2255".
    wrk3.vid2 = "2725".
    create wrk3.
    wrk3.num = 11.
    wrk3.vid = "Выпущенные в обращение ценные бумаги".
    wrk3.vid1 = "2301,2303".
    wrk3.vid2 = "2730".
    create wrk3.
    wrk3.num = 12.
    wrk3.vid = "Прочие*".
    wrk3.vid1 = "".
    wrk3.vid2 = "".
    create wrk3.
    wrk3.num = 13.
    wrk3.vid = "Итого".
    wrk3.vid1 = "".
    wrk3.vid2 = "".

v-dt = dt1.
{r-brfilial.i &proc = "repayment1"}.

 message "end" view-as alert-box.

function ddd returns char (input p1 as int).
    def var res as char.
    res = string(p1).
    if string(p1) = "1" then res = " январь " .
    if string(p1) = "2" then res = " февраль " .
    if string(p1) = "3" then res = " март " .
    if string(p1) = "4" then res = " апрель " .
    if string(p1) = "5" then res = " май " .
    if string(p1) = "6" then res = " июнь " .
    if string(p1) = "7" then res = " июль " .
    if string(p1) = "8" then res = " августа " .
    if string(p1) = "9" then res = " сентябрь " .
    if string(p1) = "10" then res = " октябрь " .
    if string(p1) = "11" then res = " ноябрь " .
    if string(p1) = "12" then res = " декабрь " .
    return res.
end function.

def var j as int.
for each wrk2.
   j = 1.
   do while j <= 12 :
        wrk2.p_debt[13] = wrk2.p_debt[13] + wrk2.p_debt[j] .
        wrk2.p_reward[13] = wrk2.p_reward[13] + wrk2.p_reward[j].
        j = j + 1.
   end.
end.

for each wrk3.
   j = 1.
   do while j <= 12 :
        wrk3.p_debt[13] = wrk3.p_debt[13] + wrk3.p_debt[j] .
        wrk3.p_reward[13] = wrk3.p_reward[13] + wrk3.p_reward[j].
        j = j + 1.
   end.
end.

/* подведем итоги   */
def buffer b-wrk2 for wrk2.
find first b-wrk2 where b-wrk2.num = 13.
for each wrk2 where wrk2.num <> 4 and wrk2.num <> 13.
   j = 1.
   do while j <= 13 :
        b-wrk2.p_debt[j] = b-wrk2.p_debt[j] + wrk2.p_debt[j] .
        b-wrk2.p_reward[j] = b-wrk2.p_reward[j] + wrk2.p_reward[j].
        b-wrk2.f_debt[j] = b-wrk2.f_debt[j] + wrk2.f_debt[j] .
        b-wrk2.f_reward[j] = b-wrk2.f_reward[j] + wrk2.f_reward[j].
        j = j + 1.
   end.
end.

def buffer b-wrk3 for wrk3.
find first b-wrk3 where b-wrk3.num = 13.
for each wrk3 where wrk3.num <> 4 and wrk3.num <> 13.
   j = 1.
   do while j <= 13 :
        b-wrk3.p_debt[j] = b-wrk3.p_debt[j] + wrk3.p_debt[j] .
        b-wrk3.p_reward[j] = b-wrk3.p_reward[j] + wrk3.p_reward[j].
        b-wrk3.f_debt[j] = b-wrk3.f_debt[j] + wrk3.f_debt[j] .
        b-wrk3.f_reward[j] = b-wrk3.f_reward[j] + wrk3.f_reward[j].
        j = j + 1.
   end.
end.

if v-select1 = 1 then do:
    for each wrk2.
       j = 1.
       do while j <= 13 :
            if wrk2.p_debt[j] > 0 then  wrk2.p_debt[j] = wrk2.p_debt[j] / 1000.
            if wrk2.p_reward[j] > 0 then wrk2.p_reward[j] = wrk2.p_reward[j] / 1000.
            if wrk2.f_debt[j] > 0 then wrk2.f_debt[j] = wrk2.f_debt[j] / 1000.
            if wrk2.f_reward[j] > 0 then wrk2.f_reward[j] = wrk2.f_reward[j] / 1000.
            j = j + 1.
       end.
    end.
    for each wrk3.
       j = 1.
       do while j <= 13 :
            if wrk3.p_debt[j] > 0 then  wrk3.p_debt[j] = wrk3.p_debt[j] / 1000.
            if wrk3.p_reward[j] > 0 then wrk3.p_reward[j] = wrk3.p_reward[j] / 1000.
            if wrk3.f_debt[j] > 0 then wrk3.f_debt[j] = wrk3.f_debt[j] / 1000.
            if wrk3.f_reward[j] > 0 then wrk3.f_reward[j] = wrk3.f_reward[j] / 1000.
            j = j + 1.
       end.
    end.
    for each wrk.
       if wrk.sumd > 0 then  wrk.sumd = wrk.sumd / 1000.
       if wrk.sumtngd > 0 then wrk.sumtngd = wrk.sumtngd / 1000.
       if wrk.sumc > 0 then  wrk.sumc = wrk.sumc / 1000.
       if wrk.sumtngc > 0 then wrk.sumtngc = wrk.sumtngc / 1000.
    end.
    for each wrk1.
       if wrk1.sum > 0 then  wrk1.sum = wrk1.sum / 1000.
       if wrk1.sumtngd > 0 then wrk1.sumtngd = wrk1.sumtngd / 1000.
       if wrk1.sumtngr > 0 then wrk1.sumtngr = wrk1.sumtngr / 1000.
       if wrk1.p_debt > 0 then wrk1.p_debt = wrk1.p_debt / 1000.
       if wrk1.p_reward > 0 then wrk1.p_reward = wrk1.p_reward / 1000.
       if wrk1.f_debt > 0 then wrk1.f_debt = wrk1.f_debt / 1000.
       if wrk1.f_reward > 0 then wrk1.f_reward = wrk1.f_reward / 1000.
       if wrk1.ostf > 0 then wrk1.ostf = wrk1.ostf / 1000.
       if wrk1.oste > 0 then wrk1.oste = wrk1.oste / 1000.
    end.
    if subr > 0 then subr = subr / 1000.
end.

if v-fil-int > 1 then v-fil-cnt = "Консолидированный отчет".

def stream v-out.
output stream v-out to rep.html.
def stream v-out2.
output stream v-out2 to rep2.html.
    put stream v-out unformatted "<html><head><title>FORTEMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
if v-sel = 1 then do:
    /* текущий год */
            put stream v-out unformatted  "<h3>Сведения о погашении обязательств перед нерезидентами Республики Казахстан за период с " string(dt1) " по " string(dt2) "</h3>" skip.
            put stream v-out unformatted  "<h3>" v-fil-cnt "</h3>" skip.
            put stream v-out unformatted  "<h3>" v-raz "</h3>" skip.

            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD  rowspan=4 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> № п.п </B></FONT></TD>"  skip
                 "<TD  rowspan=4 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD colspan=24 bgcolor=""#95B2D1""><FONT size=""2""><B>" string(vyear) "</B></FONT></TD></tr>"  skip
                 "<tr><TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Январь  </B></FONT></TD>"  skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Февраль</B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Март</B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Апрель </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Май </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Июнь </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD  colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт  </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD align=center height=20 bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "</tr>"  skip.
        for each wrk2.
                if wrk2.num = 13 then put stream v-out  unformatted "<TR> <TD><align=""left"">" "</TD>" skip.
                else put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk2.num "</TD>" skip.
                put stream v-out  unformatted "<TD align=""center"">" wrk2.vid "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_debt[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_reward[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_debt[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_reward[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_debt[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_reward[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_debt[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_reward[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_debt[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_reward[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_debt[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_reward[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_debt[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_reward[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_debt[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_reward[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_debt[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_reward[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_debt[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_reward[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_debt[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.p_reward[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_debt[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" replace(trim(string(wrk2.f_reward[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
        end.

            put stream v-out unformatted "</table>".
                        put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD  rowspan=4 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> № п.п </B></FONT></TD>"  skip
                 "<TD  rowspan=4 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD colspan=24 bgcolor=""#95B2D1""><FONT size=""2""><B>" string(vyear) "</B></FONT></TD></tr>"  skip
                 "<tr><TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Июль </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Август </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Сентбрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Октябрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Ноябрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Декабрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> ИТОГО </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт  </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD align=center height=20 bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "</tr>"  skip.
        for each wrk2.
                if wrk2.num = 13 then put stream v-out  unformatted "<TR> <TD><align=""left"">" "</TD>" skip.
                else put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk2.num "</TD>" skip.
                put stream v-out  unformatted "<TD align=""center"">" wrk2.vid "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
        end.


            put stream v-out unformatted "</table>".
    /* следующий год */
            put stream v-out unformatted  "<h3>"string(vyear + 1)" год </h3>" skip.
            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD  rowspan=4 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> № п.п </B></FONT></TD>"  skip
                 "<TD  rowspan=4 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD colspan=24 bgcolor=""#95B2D1""><FONT size=""2""><B>" string(vyear + 1) "</B></FONT></TD></tr>"  skip
                 "<tr><TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Январь  </B></FONT></TD>"  skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Февраль</B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Март</B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Апрель </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Май </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Июнь </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD  colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт  </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD align=center height=20 bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "</tr>"  skip.
        for each wrk3.
                if wrk3.num = 13 then put stream v-out  unformatted "<TR> <TD><align=""left"">" "</TD>" skip.
                else put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk3.num "</TD>" skip.
                put stream v-out  unformatted "<TD align=""center"">" wrk3.vid "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip.
        end.

            put stream v-out unformatted "</table>".
                        put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD  rowspan=4 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> № п.п </B></FONT></TD>"  skip
                 "<TD  rowspan=4 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD colspan=24 bgcolor=""#95B2D1""><FONT size=""2""><B>" string(vyear + 1) "</B></FONT></TD></tr>"  skip
                 "<tr><TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Июль </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Август </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Сентбрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Октябрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Ноябрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Декабрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> ИТОГО </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт  </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD align=center height=20 bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "</tr>"  skip.
        for each wrk3.
                if wrk3.num = 13 then put stream v-out  unformatted "<TR> <TD><align=""left"">" "</TD>" skip.
                else put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk3.num "</TD>" skip.
                put stream v-out  unformatted "<TD align=""center"">" wrk3.vid "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip.
        end.


        put stream v-out unformatted "</table>".

        output stream v-out close.
        unix silent value("cptwin rep.html excel").
        hide message no-pause.

    /*  вывод плана  */
            put stream v-out2 unformatted "<html><head><title>FORTEMBANK</title>"
                             "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                             "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
            put stream v-out2 unformatted  "<h3>Сведения о планируемом погашении обязательств перед нерезидентами Республики Казахстан, за период с " string(dt3) " по " string(dt4) "</h3>" skip.
            put stream v-out2 unformatted  "<h3>" v-fil-cnt "</h3>" skip.
            put stream v-out2 unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out2 unformatted "<tr align=center>"
             "<TD  rowspan=2 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> Месяц </B></FONT></TD>"  skip
                 "<TD width=100 rowspan=2 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD width=100 rowspan=2 bgcolor=""#95B2D1""><FONT size=""2""><B> Займы от банков и организаций, осуществляющих отдельные виды банковских операций</B></FONT></TD>"  skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Займы от международных финансовых организаций  </B></FONT></TD>"  skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Синдицированные займы </B></FONT></TD>" skip
                 "<TD width=100 colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Субординированный долг, в т.ч.:</B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Вклады дочерних организаций специального назначения </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Межбанковские вклады </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Вклады клиентов </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Операции РЕПО </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Выпущенные в обращение ценные бумаги  </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Прочие* </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Итого  </B></FONT></TD></tr>" skip
                 "<tr> <td width=100 bgcolor=""#95B2D1""> займы  </td> <td width=100 bgcolor=""#95B2D1"">  облигации </td></tr>" skip.
         j = 1. /* дни  */
         do while j <= dt4 - dt3 + 2:
            if j = dt4 - dt3 + 2 then do:
                put stream v-out2  unformatted "<TR> <TD rowspan=2 ><align=""center""> ИТОГО </TD>" skip.
                put stream v-out2  unformatted "<TD align=""left""> основной долг </TD>" skip.
                ii = 1.
                do while ii <= 13:
                    if ii <> 4 then put stream v-out2  unformatted "<TD align=""right"">" replace(trim(string(sumd[ii],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    ii = ii + 1.
                end.
                put stream v-out2  unformatted "</tr>" skip.
                put stream v-out2  unformatted "<tr> <TD align=""left""> начисленное вознаграждение </TD>" skip.
                ii = 1.
                do while ii <= 13 :
                    if ii <> 4 then put stream v-out2  unformatted "<TD align=""right"">" replace(trim(string(sumr[ii],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    ii = ii + 1.
                end.
                put stream v-out2  unformatted "</tr>" skip.
            end.
            else do:
                put stream v-out2  unformatted "<TR> <TD rowspan=2 ><align=""center"">" j "</TD>" skip.
                put stream v-out2  unformatted "<TD align=""left""> основной долг </TD>" skip.
                ii = 1.
                sumd13 = 0.
                do while ii <= 13 :
                    if ii <> 4 then do:
                        sum = 0.
                        for each wrk1 where wrk1.dclose = date(month(dt3),j,year(dt3)) and wrk1.num = ii.
                            sum = sum + wrk1.sumtngd /*p_debt*/.
                            sumd[ii] = sumd[ii] + wrk1.sumtngd /*p_debt*/.
                            sumd13 = sumd13 + wrk1.sumtngd /*p_debt*/.
                        end.
                        if ii < 13 then put stream v-out2  unformatted "<TD align=""right"">" replace(trim(string(sum,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                        else  put stream v-out2  unformatted "<TD align=""right"">" replace(trim(string(sumd13,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    end.
                    ii = ii + 1.
                end.
                put stream v-out2  unformatted "</tr>" skip.

                put stream v-out2  unformatted "<tr> <TD align=""left""> начисленное вознаграждение </TD>" skip.
                ii = 1.
                sumr13 = 0.
                do while ii <= 13:
                    if ii <> 4 then do:
                        sum = 0.
                        for each wrk1 where wrk1.dclose = date(month(dt3),j,year(dt3)) and wrk1.num = ii.
                            sum = sum + wrk1.sumtngr /*p_reward*/.
                            sumr13 = sumr13 + wrk1.sumtngr /*p_reward*/.
                            sumr[ii] = sumr[ii] + wrk1.sumtngr /*p_reward*/.
                        end.
                        if ii < 13 then do:
                            if ii = 5 and j = 10 then do:
                                put stream v-out2  unformatted "<TD align=""right"">" replace(trim(string(subr,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                                sumr13 = sumr13 + subr.
                                sumr[ii] = sumr[ii] + subr.
                            end.
                            else put stream v-out2  unformatted "<TD align=""right"">" replace(trim(string(sum,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                        end.
                        else put stream v-out2  unformatted "<TD align=""right"">" replace(trim(string(sumr13,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    end.
                    ii = ii + 1.
                end.
                put stream v-out2  unformatted "</tr>" skip.
           end.
            j = j + 1.
        end.

        put stream v-out2 unformatted "</table>".
        output stream v-out2 close.
        unix silent value("cptwin rep2.html excel").
        hide message no-pause.
end.

if v-sel = 2 then do:
    /* текущий год */
            put stream v-out unformatted  "<h3>Сведения о погашении обязательств перед нерезидентами Республики Казахстан за период с " string(dt1) " по " string(dt2) "</h3>" skip.
            put stream v-out unformatted  "<h3>" v-fil-cnt "</h3>" skip.
            put stream v-out unformatted  "<h3>" v-raz "</h3>" skip.

            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD  rowspan=4 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> № п.п </B></FONT></TD>"  skip
                 "<TD  rowspan=4 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD colspan=24 bgcolor=""#95B2D1""><FONT size=""2""><B>" string(vyear) "</B></FONT></TD></tr>"  skip
                 "<tr><TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Январь  </B></FONT></TD>"  skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Февраль</B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Март</B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Апрель </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Май </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Июнь </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD  colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт  </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD align=center height=20 bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "</tr>"  skip.
        for each wrk2.

                put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk2.num "</TD>" skip
                "<TD align=""center"">" wrk2.vid "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
        end.

            put stream v-out unformatted "</table>".
                        put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD  rowspan=4 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> № п.п </B></FONT></TD>"  skip
                 "<TD  rowspan=4 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD colspan=24 bgcolor=""#95B2D1""><FONT size=""2""><B>" string(vyear) "</B></FONT></TD></tr>"  skip
                 "<tr><TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Июль </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Август </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Сентбрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Октябрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Ноябрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Декабрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> ИТОГО </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт  </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD align=center height=20 bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "</tr>"  skip.
        for each wrk2.

                put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk2.num "</TD>" skip
                "<TD align=""center"">" wrk2.vid "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_debt[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.p_reward[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_debt[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk2.f_reward[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
        end.
        put stream v-out unformatted "</table>".
    /* следующий год */
            put stream v-out unformatted  "<h3>"string(vyear + 1)" год </h3>" skip.
            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD  rowspan=4 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> № п.п </B></FONT></TD>"  skip
                 "<TD  rowspan=4 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD colspan=24 bgcolor=""#95B2D1""><FONT size=""2""><B>" string(vyear + 1) "</B></FONT></TD></tr>"  skip
                 "<tr><TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Январь  </B></FONT></TD>"  skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Февраль</B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Март</B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Апрель </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Май </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Июнь </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD  colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт  </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD align=center height=20 bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "</tr>"  skip.
        for each wrk3.

                put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk3.num "</TD>" skip
                "<TD align=""center"">" wrk3.vid "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip.
        end.

            put stream v-out unformatted "</table>".
                        put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD  rowspan=4 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> № п.п </B></FONT></TD>"  skip
                 "<TD  rowspan=4 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD colspan=24 bgcolor=""#95B2D1""><FONT size=""2""><B>" string(vyear + 1) "</B></FONT></TD></tr>"  skip
                 "<tr><TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Июль </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Август </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Сентбрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Октябрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Ноябрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Декабрь </B></FONT></TD>" skip
                 "<TD colspan=4 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> ИТОГО </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт  </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> План </B></FONT></TD>" skip
                 "<TD colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Факт </B></FONT></TD>" skip
                 "</tr>" skip
                 "<tr><TD align=center height=20 bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Основной <br> долг </B></FONT></TD>"  skip
                 "<TD align=center bgcolor=""#95B2D1""><FONT size=""2""><B> Начисленное <br> вознаграждение </B></FONT></TD>" skip
                 "</tr>"  skip.
        for each wrk3.

                put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk3.num "</TD>" skip
                "<TD align=""center"">" wrk3.vid "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_debt[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.p_reward[13],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip
                "<TD align=""right"">"  "</TD>" skip.
        end.
        put stream v-out unformatted "</table>".
        output stream v-out close.
        unix silent value("cptwin rep.html excel").
        hide message no-pause.
end.

if v-sel = 3 then do:
    /*  вывод плана  */
            put stream v-out unformatted  "<h3>Сведения о планируемом погашении обязательств перед нерезидентами Республики Казахстан, за период с " string(dt3) " по " string(dt4) "</h3>" skip.
            put stream v-out unformatted  "<h3>" v-fil-cnt "</h3>" skip.
            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
             "<TD  rowspan=2 align=center valign=""middle"" bgcolor=""#95B2D1""><FONT size=""2""><B> Месяц </B></FONT></TD>"  skip
                 "<TD width=100 rowspan=2 align=left valign=middle bgcolor=""#95B2D1""><FONT size=""2""><B> Вид заимствований </B></FONT></TD>"  skip
                 "<TD width=100 rowspan=2 bgcolor=""#95B2D1""><FONT size=""2""><B> Займы от банков и организаций, осуществляющих отдельные виды банковских операций</B></FONT></TD>"  skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Займы от международных финансовых организаций  </B></FONT></TD>"  skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Синдицированные займы </B></FONT></TD>" skip
                 "<TD width=100 colspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Субординированный долг, в т.ч.:</B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Вклады дочерних организаций специального назначения </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Межбанковские вклады </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Вклады клиентов </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Операции РЕПО </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Выпущенные в обращение ценные бумаги  </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Прочие* </B></FONT></TD>" skip
                 "<TD width=100 rowspan=2 align=center valign='middle' bgcolor=""#95B2D1""><FONT size=""2""><B> Итого  </B></FONT></TD></tr>" skip
                 "<tr> <td width=100 bgcolor=""#95B2D1""> займы  </td> <td width=100 bgcolor=""#95B2D1"">  облигации </td></tr>" skip.
         j = 1. /* дни  */
         do while j <= dt4 - dt3 + 2:
            if j = dt4 - dt3 + 2 then do:
                put stream v-out  unformatted "<TR> <TD rowspan=2 ><align=""center""> ИТОГО </TD>" skip.
                put stream v-out  unformatted "<TD align=""left""> основной долг </TD>" skip.
                ii = 1.
                do while ii <= 13:
                    if ii <> 4 then put stream v-out  unformatted "<TD align=""right"">" replace(trim(string(sumd[ii],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    ii = ii + 1.
                end.
                put stream v-out  unformatted "</tr>" skip.
                put stream v-out  unformatted "<tr> <TD align=""left""> начисленное вознаграждение </TD>" skip.
                ii = 1.
                do while ii <= 13 :
                    if ii <> 4 then put stream v-out  unformatted "<TD align=""right"">" replace(trim(string(sumr[ii],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    ii = ii + 1.
                end.
                put stream v-out  unformatted "</tr>" skip.
            end.
            else do:
                put stream v-out  unformatted "<TR> <TD rowspan=2 ><align=""center"">" j "</TD>" skip.
                put stream v-out  unformatted "<TD align=""left""> основной долг </TD>" skip.
                ii = 1.
                sumd13 = 0.
                do while ii <= 13 :
                    if ii <> 4 then do:
                        sum = 0.
                        for each wrk1 where wrk1.dclose = date(month(dt3),j,year(dt3)) and wrk1.num = ii.
                            sum = sum + wrk1.sumtngd.
                            sumd[ii] = sumd[ii] + wrk1.sumtngd.
                            sumd13 = sumd13 + wrk1.sumtngd.
                        end.
                        if ii < 13 then put stream v-out  unformatted "<TD align=""right"">" replace(trim(string(sum,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                        else  put stream v-out  unformatted "<TD align=""right"">" replace(trim(string(sumd13,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    end.
                    ii = ii + 1.
                end.
                put stream v-out  unformatted "</tr>" skip.

                put stream v-out  unformatted "<tr> <TD align=""left""> начисленное вознаграждение </TD>" skip.
                ii = 1.
                sumr13 = 0.
                do while ii <= 13:
                    if ii <> 4 then do:
                        sum = 0.
                        for each wrk1 where wrk1.dclose = date(month(dt3),j,year(dt3)) and wrk1.num = ii.
                            sum = sum + wrk1.sumtngr.
                            sumr13 = sumr13 + wrk1.sumtngr.
                            sumr[ii] = sumr[ii] + wrk1.sumtngr.
                        end.
                        if ii < 13 then do:
                            if ii = 5 and j = 10 then do:
                                put stream v-out  unformatted "<TD align=""right"">" replace(trim(string(subr,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                                sumr13 = sumr13 + subr.
                                sumr[ii] = sumr[ii] + subr.
                            end.
                            else put stream v-out  unformatted "<TD align=""right"">" replace(trim(string(sum,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                        end.
                        else put stream v-out  unformatted "<TD align=""right"">" replace(trim(string(sumr13,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                    end.
                    ii = ii + 1.
                end.
                put stream v-out  unformatted "</tr>" skip.
           end.
            j = j + 1.
        end.

        put stream v-out unformatted "</table>".
        output stream v-out close.
        unix silent value("cptwin rep.html excel").
        hide message no-pause.
end.


/* расшифровка для факта*/
if v-ful and (v-ful1 = 1 or v-ful1 = 3) then do:
    def stream v-out1.
    output stream v-out1 to rep1.html.
        put stream v-out1 unformatted "<html><head><title>FORTEBANK</title>"
                         "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                         "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        put stream v-out1 unformatted  "<h3>Сведения о погашении обязательств перед нерезидентами Республики Казахстан за период с " string(dt1) " по " string(dt2) "</h3>" skip.
        put stream v-out1 unformatted  "<h3>" v-raz "</h3>" skip.

        put stream v-out1 unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
        put stream v-out1 unformatted "<tr align=center>" skip
         "<TD >Филиал</TD>"  skip
         "<TD >Наименование клиента</TD>"  skip
             "<TD >ГЕО код клиента </TD>"  skip
             /*"<TD > sub  </TD><>"  skip*/
             "<TD > транз  </TD><>"  skip
             "<TD > дата транз  </TD><>"  skip
             "<TD > месяц  </TD><>"  skip
             "<TD > Признак  </TD><>"  skip
             "<TD > Балансовый счет <br>(4 знака) </TD>"  skip
             "<TD > Лицевой счет  </TD>"  skip
             "<TD > Валюта  <br>счета  </TD>"  skip
             "<TD > Дата  <br> открытия </TD>"  skip
             "<TD > Дата  <br> закрытия </TD>"  skip
             "<TD > Процентная  <br>ставка </TD>"  skip
             "<TD > Вид  <br> заимствования </TD>"  skip
             "<TD > Дт балансовый <br> счет (4 знака) </TD>"  skip
             "<TD > Дт лицевой  <br> счет  </TD>"  skip
             "<TD > Сумма Дт <br> номинал </TD>"  skip
             "<TD > Сумма Дт  <br> эквивалент </TD>"  skip
             "<TD > Кт балансовый <br> счет (4 знака) </TD>"  skip
             "<TD > Кт лицевой  <br> счет  </TD>"  skip
             "<TD > Сумма Кт <br> номинал </TD>"  skip
             "<TD > Сумма Кт  <br> эквивалент </TD>"  skip
             "<TD > df </TD>"  skip
            "</tr>" skip.
        for each wrk break by wrk.txb:
            /*if first-of(wrk.txb) then do:
                put stream v-out1  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk.fil "</TD></TR>" skip.
            end.*/
            put stream v-out1 unformatted   "<tr><TD >" wrk.fil "</TD>"  skip
                 "<TD >" wrk.name "</TD>"  skip
                 "<TD >" wrk.geo "</TD>"  skip
                 /*"<TD >" wrk.sub "</TD>"  skip*/
                 "<TD >" wrk.jh "</TD>"  skip
                 "<TD >" wrk.whn "</TD>"  skip
                 "<TD >" wrk.month "</TD>"  skip
                 "<TD >" wrk.pri "</TD>"  skip.
                 if wrk.gl4 begins "2" then put stream v-out1 unformatted "<TD >" wrk.gl4  "</TD>"  skip.
                 else put stream v-out1 unformatted "<TD >"  "</TD>"  skip.
                 put stream v-out1 unformatted "<TD >" wrk.gl7  "</TD>"  skip
                 "<TD >" wrk.crc  "</TD>"  skip
                 "<TD >" wrk.dopen  "</TD>"  skip
                 "<TD >" wrk.dclose  "</TD>"  skip
                 "<TD >" replace(trim(string(wrk.stav,'->>>>>>>>>>>9.99')),'.',',')  "</TD>"  skip
                  "<TD >" wrk.vid  "</TD>"  skip
                "<TD >" wrk.dt4  "</TD>"  skip
                 "<TD >" wrk.dt7  "</TD>"  skip
                 "<TD >" replace(trim(string(wrk.sumd,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip
                 "<TD >" replace(trim(string(wrk.sumtngd,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip
                 "<TD >" wrk.ct4  "</TD>"  skip
                 "<TD >" wrk.ct7 "</TD>"  skip
                 "<TD >" replace(trim(string(wrk.sumc,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip
                 "<TD >" replace(trim(string(wrk.sumtngc,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip
                 "<TD >" wrk.df "</TD>"  skip
                "</tr>" skip.

        end.
        put stream v-out1 unformatted  "</table>" skip.
        output stream v-out1 close.
        unix silent value("cptwin rep1.html excel").
        hide message no-pause.
end.

/* расшифровка для плана*/
if v-ful and (v-ful1 = 2 or v-ful1 = 3) then do:
    def stream v-out1.
    output stream v-out1 to rep1.html.
        put stream v-out1 unformatted "<html><head><title>FORTEBANK</title>"
                         "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                         "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        put stream v-out1 unformatted  "<h3>Сведения о планируемом погашении обязательств перед нерезидентами Республики Казахстан за период с " string(dt3) " по " string(dt4) "</h3>" skip.
        put stream v-out1 unformatted  "<h3>" v-raz "</h3>" skip.

        put stream v-out1 unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
        put stream v-out1 unformatted "<tr align=center>" skip
         "<TD >Филиал</TD>"  skip
         "<TD >Наименование клиента</TD>"  skip
             "<TD >ГЕО код клиента </TD>"  skip
             "<TD > Дата  <br> открытия </TD>"  skip
             "<TD > Дата  <br> закрытия </TD>"  skip
             "<TD > Процентная  <br>ставка </TD>"  skip
             "<TD > Счет </TD>"  skip
             "<TD > Валюта <br> счета </TD>"  skip
             "<TD > Балансовый счет <br> ОД </TD>"  skip
             "<TD > Лицевой счет ОД </TD>"  skip
             "<TD > Остаток  <br> на начало </TD>"  skip
             "<TD > Остаток  <br> на конец </TD>"  skip
             "<TD > Сумма  <br> номинал ОД </TD>"  skip
             "<TD > Сумма  <br> эквивалент ОД </TD>"  skip
             "<TD > Балансовый счет % </TD>"  skip
             "<TD > Лицевой счет % </TD>"  skip
             "<TD > Сумма номинал % </TD>"  skip
             "<TD > Сумма эквивалент % </TD>"  skip
             "<TD > Вид  <br> заимствования </TD>"  skip
             "<TD > призн вкл </TD>"  skip
            "</tr>" skip.

        for each wrk1 break by wrk1.txb:
            /*if first-of(wrk1.txb) then do:
                put stream v-out1  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk1.fil "</TD></TR>" skip.
            end.*/
            put stream v-out1 unformatted   "<tr><TD >" wrk1.fil "</TD>"  skip
                 "<TD >" wrk1.name "</TD>"  skip
                 "<TD >" wrk1.geo "</TD>"  skip
                 "<TD >" wrk1.dopen  "</TD>"  skip
                 "<TD >" wrk1.dclose  "</TD>"  skip
                 "<TD >" replace(trim(string(wrk1.stav,'->>>>>>>>>>>9.99')),'.',',')  "</TD>"  skip
                 "<TD >" wrk1.acc  "</TD>"  skip
                 "<TD >" wrk1.crc  "</TD>"  skip
                 "<TD >" wrk1.dt4  "</TD>"  skip
                 "<TD >" wrk1.dt7  "</TD>"  skip
                 "<TD >" replace(trim(string(wrk1.ostf,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip
                 "<TD >" replace(trim(string(wrk1.oste,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip
                 "<TD >" replace(trim(string(wrk1.p_debt,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip.
                 put stream v-out1 unformatted "<TD >"   replace(trim(string(wrk1.sumtngd,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip.
                 put stream v-out1 unformatted "<TD >" wrk1.ct4  "</TD>"  skip
                 "<TD >" wrk1.ct7 "</TD>"  skip
                 "<TD >" replace(trim(string(wrk1.p_reward,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip.
                 put stream v-out1 unformatted "<TD >" replace(trim(string(wrk1.sumtngr,'->>>>>>>>>>>9.99')),'.',',') "</TD>"  skip.
                 put stream v-out1 unformatted "<TD >" wrk1.vid  "</TD>"  skip.
                 put stream v-out1 unformatted "<TD >" wrk1.df  "</TD>"  skip
                 "</tr>" skip.

        end.
        put stream v-out1 unformatted  "</table>" skip.
        output stream v-out1 close.
        unix silent value("cptwin rep1.html excel").
        hide message no-pause.
end.
return.

