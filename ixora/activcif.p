/* activcif.p
 * MODULE
        Название модуля - Активные клиенты и счета.
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def var repname   as char init "1.htm".
def var v-type    as char no-undo.

def var v-date as date.
def var v-dat1 as date.
def var v-dat2 as date.
def var vyear  as inte no-undo.
def var vmonth as inte no-undo.

def new shared temp-table newtemp1
    field filial  as char
    field month   as char
    field one1    as inte
    field one2    as inte
    field one3    as inte
    field one4    as inte
    field oneitog as inte
    field two1    as inte
    field two2    as inte
    field two3    as inte
    field two4    as inte
    field two5    as inte
    field twoitog as inte
    field three1  as deci
    field three2  as deci
    field three3  as deci
    field three4  as deci
    field three5    as deci
    field threeitog as deci
    field four1     as deci
    field four2     as deci
    field four3     as deci
    field four4     as deci
    field four5     as deci
    field fouritog  as deci
    field five      as inte
    field six       as inte
    field seven     as inte
    field eight     as inte.

def stream rep.
output stream rep to value(repname).

v-date = g-today.
v-type = "b".

form
    v-date label "Дата" format "99/99/9999" validate (v-date <= g-today, " Неверная дата!") skip
    v-type label "Тип клиентов" validate(v-type = "b" or v-type = "p", "Недопустимый тип клиента, введите P или B !") skip
with centered side-label title "Введите дату отчета(формируется помесячно)" frame aaa.

update v-date v-type with frame aaa.
displ  v-date v-type with frame aaa.

vyear  = year(v-date).
vmonth = 1.
v-dat1 = date(vmonth,1,vyear).
v-dat2 = date(month(v-date),day(v-date),year(v-date)).

{r-brfilial.i   &proc = " activcifdat(input txb.bank, '1', v-date, v-dat1, v-dat2, vyear, v-type) "}

{html-title.i}
def var caption as char init "Активные клиенты и счета.".
def var namebank as char.
def buffer b-cmp for cmp.
find first b-cmp no-lock no-error.
if avail b-cmp then do:
    namebank = trim(b-cmp.name).
end.

put stream rep unformatted
    "<html><head>
    <META content=""text/html; charset=windows-1251"" http-equiv=Content-Type>
    <META content=ru http-equiv=Content-Language>
    </head>
    <TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

put stream rep unformatted
    "<P align=center colspan=10><font size=""4""><b><a name="" ""></a>" caption "  " namebank "  сформирован на дату " v-date "</b></font></P>" skip.

put stream rep unformatted
    "<TR>" skip
    "<TD align=center rowspan=2>" "Филиал"                                                        "</TD>" skip
    "<TD align=center colspan=4>" "Общее количество клиентов(со счетами)"                         "</TD>" skip
    "<TD align=center rowspan=2>" "Итого"                                                         "</TD>" skip
    "<TD align=center colspan=5>" "Количество активных счетов"                                    "</TD>" skip
    "<TD align=center rowspan=2>" "Итого"                                                         "</TD>" skip
    "<TD align=center colspan=5>" "Обороты по кредиту"                                            "</TD>" skip
    "<TD align=center rowspan=2>" "Итого сумма в KZT"                                             "</TD>" skip
    "<TD align=center colspan=5>" "Остатки"                                                       "</TD>" skip
    "<TD align=center rowspan=2>" "Итого сумма в KZT"                                             "</TD>" skip
    "<TD align=center rowspan=2>" "Количество активных клиентов(min 3 операции по счету)"         "</TD>" skip
    "<TD align=center rowspan=2>" "Количество новых клиентов"                                     "</TD>" skip
    "<TD align=center rowspan=2>" "Количество клиентов с ссудными счетами"                        "</TD>" skip
    "<TD align=center rowspan=2>" "Количество клиентов, подключенных к сервису Internet Banking"  "</TD>" skip
    "</TR>" skip.
put stream rep unformatted
    "<TR>" skip
    "<TD align=center>" "SME,Micro"  "</TD>" skip
    "<TD align=center>" "SME,Small"  "</TD>" skip
    "<TD align=center>" "SME,Medium" "</TD>" skip
    "<TD align=center>" "Corporate"  "</TD>" skip
    "<TD align=center>" "KZT"        "</TD>" skip
    "<TD align=center>" "USD"        "</TD>" skip
    "<TD align=center>" "EUR"        "</TD>" skip
    "<TD align=center>" "RUB"        "</TD>" skip
    "<TD align=center>" "GBP"        "</TD>" skip
    "<TD align=center>" "KZT"        "</TD>" skip
    "<TD align=center>" "USD"        "</TD>" skip
    "<TD align=center>" "EUR"        "</TD>" skip
    "<TD align=center>" "RUB"        "</TD>" skip
    "<TD align=center>" "GBP"        "</TD>" skip
    "<TD align=center>" "KZT"        "</TD>" skip
    "<TD align=center>" "USD"        "</TD>" skip
    "<TD align=center>" "EUR"        "</TD>" skip
    "<TD align=center>" "RUB"        "</TD>" skip
    "<TD align=center>" "GBP"        "</TD>" skip
    "</TR>" skip.

def var t1 as deci decimals 2 init 0.
def var t2 as deci decimals 2 init 0.
def var t3 as deci decimals 2 init 0.
def var t4 as deci decimals 2 init 0.
def var t5 as deci decimals 2 init 0.
def var t6 as deci decimals 2 init 0.
def var t7 as deci decimals 2 init 0.
def var t8 as deci decimals 2 init 0.
def var t9 as deci decimals 2 init 0.
def var t10 as deci decimals 2 init 0.
def var t11 as deci decimals 2 init 0.
def var t12 as deci decimals 2 init 0.
def var t13 as deci decimals 2 init 0.
def var t14 as deci decimals 2 init 0.
def var t15 as deci decimals 2 init 0.
def var t16 as deci decimals 2 init 0.
def var t17 as deci decimals 2 init 0.
def var t18 as deci decimals 2 init 0.
def var t19 as deci decimals 2 init 0.
def var t20 as deci decimals 2 init 0.
def var t21 as deci decimals 2 init 0.
def var t22 as deci decimals 2 init 0.
def var t23 as deci decimals 2 init 0.
def var t24 as deci decimals 2 init 0.
def var t25 as deci decimals 2 init 0.
def var t26 as deci decimals 2 init 0.
def var t27 as deci decimals 2 init 0.
def var t28 as deci decimals 2 init 0.

def buffer b-newtemp1 for newtemp1.
for each newtemp1 no-lock break by newtemp1.month:
    if first-of(newtemp1.month) then do:
        put stream rep unformatted
            "<TR>" skip
            "<TD colspan=28>" "" "</TD>" skip
            "</TR>" skip
            "<TR>" skip
            "<TD align=left colspan=28>" newtemp1.month "</TD>" skip
            "</TR>" skip
            "<TR>" skip
            "<TD colspan=28>" "" "</TD>" skip
            "</TR>" skip.
        for each b-newtemp1 where b-newtemp1.month = newtemp1.month no-lock:
            put stream rep unformatted
                "<TR>" skip
                "<TD align=center>" b-newtemp1.filial "</TD>" skip
                "<TD align=center>" string(b-newtemp1.one1)   "</TD>" skip
                "<TD align=center>" string(b-newtemp1.one2)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.one3)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.one4) "</TD>" skip
                "<TD align=center>" string(b-newtemp1.oneitog)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.two1)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.two2)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.two3)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.two4)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.two5)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.twoitog) "</TD>" skip
                "<TD align=center>" string(b-newtemp1.three1) "</TD>" skip
                "<TD align=center>" string(b-newtemp1.three2)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.three3)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.three4)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.three5)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.threeitog) "</TD>" skip
                "<TD align=center>" string(b-newtemp1.four1)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.four2)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.four3)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.four4)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.four5)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.fouritog) "</TD>" skip
                "<TD align=center>" string(b-newtemp1.five)  "</TD>" skip
                "<TD align=center>" string(b-newtemp1.six)   "</TD>" skip
                "<TD align=center>" string(b-newtemp1.seven) "</TD>" skip
                "<TD align=center>" string(b-newtemp1.eight) "</TD>" skip
                "</TR>" skip.
            t1 = t1 + b-newtemp1.one1.
            t2 = t2 + b-newtemp1.one2.
            t3 = t3 + b-newtemp1.one3.
            t4 = t4 + b-newtemp1.one4.
            t5 = t5 + b-newtemp1.oneitog.
            t6 = t6 + b-newtemp1.two1.
            t7 = t7 + b-newtemp1.two2.
            t8 = t8 + b-newtemp1.two3.
            t9 = t9 + b-newtemp1.two4.
            t10 = t10 + b-newtemp1.two5.
            t11 = t11 + b-newtemp1.twoitog.
            t12 = t12 + b-newtemp1.three1.
            t13 = t13 + b-newtemp1.three2.
            t14 = t14 + b-newtemp1.three3.
            t15 = t15 + b-newtemp1.three4.
            t16 = t16 + b-newtemp1.three5.
            t17 = t17 + b-newtemp1.threeitog.
            t18 = t18 + b-newtemp1.four1.
            t19 = t19 + b-newtemp1.four2.
            t20 = t20 + b-newtemp1.four3.
            t21 = t21 + b-newtemp1.four4.
            t22 = t22 + b-newtemp1.fouritog.
            t23 = t23 + b-newtemp1.five.
            t24 = t24 + b-newtemp1.six.
            t25 = t25 + b-newtemp1.seven.
            t26 = t26 + b-newtemp1.eight.
        end.
    end.
end.
put stream rep unformatted
    "<TR>" skip
    "<TD align=center>" "Итого" "</TD>" skip
    "<TD align=center>" t1  "</TD>" skip
    "<TD align=center>" t2  "</TD>" skip
    "<TD align=center>" t3  "</TD>" skip
    "<TD align=center>" t4  "</TD>" skip
    "<TD align=center>" t5  "</TD>" skip
    "<TD align=center>" t6  "</TD>" skip
    "<TD align=center>" t7  "</TD>" skip
    "<TD align=center>" t8  "</TD>" skip
    "<TD align=center>" t9  "</TD>" skip
    "<TD align=center>" t10 "</TD>" skip
    "<TD align=center>" t11 "</TD>" skip
    "<TD align=center>" t12 "</TD>" skip
    "<TD align=center>" t13 "</TD>" skip
    "<TD align=center>" t14 "</TD>" skip
    "<TD align=center>" t15 "</TD>" skip
    "<TD align=center>" t16 "</TD>" skip
    "<TD align=center>" t17 "</TD>" skip
    "<TD align=center>" t18 "</TD>" skip
    "<TD align=center>" t19 "</TD>" skip
    "<TD align=center>" t20 "</TD>" skip
    "<TD align=center>" t21 "</TD>" skip
    "<TD align=center>" t22 "</TD>" skip
    "<TD align=center>" t23 "</TD>" skip
    "<TD align=center>" t24 "</TD>" skip
    "<TD align=center>" t25 "</TD>" skip
    "<TD align=center>" t26 "</TD>" skip
    "</TR>" skip.

put stream rep unformatted
"</TABLE>" skip.
output stream rep close.
{html-end.i }

unix silent cptwin value(repname) excel.


