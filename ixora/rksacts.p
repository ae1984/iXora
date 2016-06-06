/* rksacts.p
 * MODULE
       Департамент Регионального Развития
 * DESCRIPTION
       Отчет - Активность клиентов СПФ и филиалов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        24/07/04 kanat
 * CHANGES
        01/08/04 kanat - Переделал отчет - добавил проценты от дохода и в USD по каждой группе клиентов
        02/08/04 kanat - в итогах взял процент с комиссий от сумм с клиентов, по просьбе ДРР сделал отдельные разбивки по счетам
                         открытым за период и закрытым счетам без ссылок на клиентов (cif.jame)
        03/08/04 kanat - в форме ввода увеличил комментарии для Шахворостовой Ю.
                         вернул выборку по счетам по cif.jame - просьбе ...
                         вывел суммы по комиссиям за комм. платежи по обеим срокам для сверки директорами СПФ
                         берутся по самым большим оборотам только ЮЛ - при выводе на экран и выборке.
        04/08/04 kanat - По просьбе ДРР будут браться привлеченные клиенты ЮЛ - первые их открытые счета
                          а не все их счета..
        02/02/05 kanat - Переделал обработку рабочих месяцев
        04/05/2012 evseev - изменил путь к логотипу
*/
{comm-txb.i}
{get-dep.i}
{global.i}
{gl-utils.i}
def var v-profitcn as char init "103".
def var v-pcname as char.
def var sum_tax as decimal.
def var sum_pf as decimal.
def var sum_com10  as decimal.
def var sum_com20  as decimal.
def var sum_prc10  as decimal.
def var sum_prc20  as decimal.
def var s_string as char extent 5.
def temp-table temp
    field cif  like cif.cif
    field aaa like aaa.aaa
    field fdt as date
    field gl   like jl.gl
    field amt like jl.dam
    field amtkzt like jl.dam
    field jh like jl.jh
    field ofc as char
    field crc like jl.crc
    field doxras as char
    index main is primary doxras gl crc.
def temp-table temps
    field cif  like cif.cif
    field aaa like aaa.aaa
    field fdt as date
    field gl   like jl.gl
    field amt like jl.dam
    field amtkzt like jl.dam
    field jh like jl.jh
    field ofc as char
    field crc like jl.crc
    field doxras as char
    index main is primary doxras gl crc.
def new shared var v-name as char.
def new shared var v-dep as char format "x(3)".
def new shared var seltxb as int.
def var v-aaa as char.
def var v-supusr as char.
def var dt1 as date.
def var dt2 as date.
def var dt3 as date.
def var dt4 as date.
def var v-dat as date.
def var v-whole as decimal.
def buffer bjl for jl.
define temp-table cl-turnover
       field aaa   as char
       field turn_1 as decimal
       field turn_2 as decimal
       field saldo  as decimal
       field sts as integer
       field cif as char.
define temp-table cl-turnovers
       field aaa   as char
       field turn_1 as decimal
       field turn_2 as decimal
       field saldo  as decimal
       field sts as integer
       field cif as char.
def var i_count as integer.
def var v-sbal as decimal.
def var v-abal as decimal extent 2.
def temp-table final-temp
    field cif as char
    field aaa as char
    field value_0 as decimal
    field value_1 as decimal
    field value_2 as decimal
    field value_3 as decimal
    field value_4 as decimal
    field value_5 as decimal
    field value_6 as decimal
    field value_7 as decimal
    field value_8 as decimal
    field value_9 as decimal.
def temp-table final-temp1
    field cif as char
    field saldo as decimal.
def temp-table final-temp2
    field cif as char
    field saldo as decimal.
def temp-table final-temp3
    field cif as char
    field gl as integer.
def var v-gl-sum  as decimal extent 4.
def var v-logic as char.
def var i-depart as integer.
def var v-turn-cif as decimal.
def var sum1 as decimal.
def var sum5 as decimal.
def var sum7 as decimal.
def var sum8 as decimal.
def var v-itogo as decimal extent 10.
def var v-itogow as decimal extent 10.
def var v-month-init as integer.
def var v-year-init as integer.
def var v-nmbs as integer.
def var v-sdec as decimal.
def temp-table temp-gl
    field gl as integer.
def new shared frame opt
       v-dep label "Код департамента" skip
       dt1 label  "Дата начала периода (месяц) " validate (dt1 <= g-today, " Дата не может быть больше текущей!") skip
       dt2 label  "Дата конца периода (месяц) " validate (dt2 <= g-today, " Дата не может быть больше текущей!") skip
       with row 8 centered side-labels.
update v-dep
       dt1
       dt2
       with frame opt.
if dt2 < dt1 then do:
    message "Неверно задана дата конца отчета".
    undo,retry.
end.
hide frame opt.

message "Формируются данные для отчета ... ".

find ppoint where ppoint.depart = integer(v-dep) no-lock no-error.
if not available ppoint then do:
    message "Неверный код департамента".
    leave.
end.
function day_count returns int (m as int, y as int):
    if m = 2 then
    if y mod 4 > 0 then
    return 28.
    else
    return 29.
    if m > 7 then
    m = m + 1.
    return 30 + m mod 2.
end.
s_string[1] = "460111,460121,460122,460410,460712,460713,460714,460715,460716,460717,460721,460723,460811,460812,460813,460817,460823,461110,461120,461200".
s_string[2] = "440100,442900,444900".
s_string[3] = "453010,453020,460410".
s_string[4] = "453010,453020,460410,440100,442900,444900,460111,460121,460122,460410,460712,460713,460714,460715,460716,460717,460721,460723,460811,460812,460813,460817,460823,461110,461120,461200".
for each gl where string(gl.gl) begins "4" and gl.subled <> "lon" no-lock.
create temp-gl no-error.
update temp-gl.gl = gl.gl no-error.
end.
find ppoint where ppoint.dep = integer(v-dep) no-lock no-error.
if avail ppoint then v-name = ppoint.name.
find sysc where sysc.sysc = "sys1" no-lock no-error.
v-supusr = sysc.des.
v-logic = "FIRST".
run defdata.

v-logic = "SECOND".
v-month-init = month(dt1).
v-year-init = year(dt1).
dt3 = dt1.
dt4 = dt2.

if v-month-init - 1 > 0 then do:
dt1 = date(v-month-init - 1, 1, v-year-init).
dt2 = date(v-month-init - 1, day_count(v-month-init - 1,v-year-init), v-year-init).
end.

if v-month-init - 1 = 0 then do:
dt1 = date(12, 1, v-year-init - 1).
dt2 = date(12, day_count(12,v-year-init - 1), v-year-init - 1).
end.



run defdata.

for each temp no-lock.
sum1 = sum1 + temp.amtkzt.
end.
for each temps no-lock.
sum7 = sum7 + temps.amtkzt.
end.
/* Выборка оборотов по 4 ЮЛ - за текуший месяц */
i_count = 1.
for each cl-turnover no-lock break by cl-turnover.saldo descending.
find first cif where cif.cif = cl-turnover.cif and caps(cif.type) = "B" no-lock no-error.
find first aaa where aaa.aaa = cl-turnover.aaa no-lock no-error.
find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
if avail lgr and lgr.tlev = 1 then do:
if i_count < 5 then do:
create final-temp1.
update final-temp1.cif = cl-turnover.cif
       final-temp1.saldo = cl-turnover.saldo.
i_count = i_count + 1.
create final-temp2.
update final-temp2.cif = cl-turnover.cif
       final-temp2.saldo = cl-turnover.saldo.
end.
end.
end.
/* Выборка доходов по 4 ЮЛ - за текущий месяц */
for each final-temp1 no-lock break by final-temp1.saldo descending.
create final-temp no-error.
update final-temp.cif = final-temp1.cif
       final-temp.value_0 = final-temp1.saldo.
for each temp where temp.cif = final-temp1.cif no-lock break by temp.cif by temp.gl.
accumulate temp.amtkzt (sub-total by temp.gl).
if last-of (temp.gl) then do:
if lookup(string(temp.gl), s_string[1]) > 0 then
update final-temp.value_1 = final-temp.value_1 + (accum sub-total by temp.gl temp.amtkzt).
else if lookup(string(temp.gl), s_string[2]) > 0 then
update final-temp.value_2 = final-temp.value_2 + (accum sub-total by temp.gl temp.amtkzt).
else if lookup(string(temp.gl), s_string[3]) > 0 then
update final-temp.value_3 = final-temp.value_3 + (accum sub-total by temp.gl temp.amtkzt).
else if lookup(string(temp.gl), s_string[4]) = 0 then
update final-temp.value_4 = final-temp.value_4 + (accum sub-total by temp.gl temp.amtkzt).
create final-temp2 no-error.
update final-temp2.cif = temp.cif no-error.
end.
end.
end.
/* Выборка оборотов по 4 ЮЛ - за предыдущий месяц */
for each cl-turnovers no-lock.
find first final-temp1 where final-temp1.cif = cl-turnovers.cif no-lock no-error.
if avail final-temp1 then do:
find first final-temp where final-temp.cif = final-temp1.cif no-lock no-error.
if avail final-temp then do:
update final-temp.value_5 = final-temp.value_5 + cl-turnovers.saldo.
end.
end.
end.
/* Выборка доходов по 4 ЮЛ - за предыдущий месяц  */
for each final-temp1 no-lock break by final-temp1.saldo descending.
find first final-temp where final-temp.cif = final-temp1.cif no-lock no-error.
if avail final-temp then do:
for each temps where temps.cif = final-temp1.cif no-lock break by temps.cif by temps.gl.
accumulate temps.amtkzt (sub-total by temps.gl).
if last-of (temps.gl) then do:
if lookup(string(temps.gl), s_string[1]) > 0 then
update final-temp.value_6 = final-temp.value_6 + (accum sub-total by temps.gl temps.amtkzt).
else if lookup(string(temps.gl), s_string[2]) > 0 then
update final-temp.value_7 = final-temp.value_7 + (accum sub-total by temps.gl temps.amtkzt).
else if lookup(string(temps.gl), s_string[3]) > 0 then
update final-temp.value_8 = final-temp.value_8 + (accum sub-total by temps.gl temps.amtkzt).
else if lookup(string(temps.gl), s_string[4]) = 0 then
update final-temp.value_9 = final-temp.value_9 + (accum sub-total by temps.gl temps.amtkzt).
end.
end.
end.
end.
/* Общая сумма доходов по коммунальным платежам за текущий месяц */
for each temp where temp.jh = 0 no-lock.
sum5 = sum5 + temp.amtkzt.
end.
/* Выборка доходов за текущий месяц по остальным ЮЛ */
for each temp where temp.jh <> 0 no-lock.
find first final-temp1 where final-temp1.cif = temp.cif no-lock no-error.
if not avail final-temp1 then do:
find first cif where cif.cif = temp.cif and caps(cif.type) = "B" no-lock no-error.
find first aaa where aaa.cif = cif.cif no-lock no-error.
find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
if avail lgr and lgr.tlev = 1 then do:
if lookup(string(temp.gl), s_string[1]) > 0 then
       v-gl-sum[1] = v-gl-sum[1] + temp.amtkzt.
else if lookup(string(temp.gl), s_string[2]) > 0 then
       v-gl-sum[2] = v-gl-sum[2] + temp.amtkzt.
else if lookup(string(temp.gl), s_string[3]) > 0 then
       v-gl-sum[3] = v-gl-sum[3] + temp.amtkzt.
else if lookup(string(temp.gl), s_string[4]) = 0 then
       v-gl-sum[4] = v-gl-sum[4] + temp.amtkzt.
create final-temp2 no-error.
update final-temp2.cif = temp.cif no-error.
end.
end.
end.
create final-temp no-error.
update final-temp.cif = "OST"
       final-temp.value_0 = 0
       final-temp.value_1 = v-gl-sum[1]
       final-temp.value_2 = v-gl-sum[2]
       final-temp.value_3 = v-gl-sum[3]
       final-temp.value_4 = v-gl-sum[4].
/* Выборка доходов за предыдущий месяц по остальным ЮЛ */
for each temps where temps.jh <> 0 no-lock.
find first final-temp1 where final-temp1.cif = temps.cif no-lock no-error.
if not avail final-temp1 then do:
find first final-temp where final-temp.cif = "OST" no-lock no-error.
if lookup(string(temps.gl), s_string[1]) > 0 then
update final-temp.value_6 = final-temp.value_6 + temps.amtkzt.
else if lookup(string(temps.gl), s_string[2]) > 0 then
update final-temp.value_7 = final-temp.value_7 + temps.amtkzt.
else if lookup(string(temps.gl), s_string[3]) > 0 then
update final-temp.value_8 = final-temp.value_8 + temps.amtkzt.
else if lookup(string(temps.gl), s_string[4]) = 0 then
update final-temp.value_9 = final-temp.value_9 + temps.amtkzt.
create final-temp3 no-error.
update final-temp3.cif = temps.cif no-error.
end.
end.
/* Выборка по доходов за текущий месяц по ЧП и фл */
run clearvar.
for each temp where temp.jh <> 0 no-lock.
find first final-temp1 where final-temp1.cif = temp.cif no-lock no-error.
if not avail final-temp1 then do:
find first final-temp2 where final-temp2.cif = temp.cif no-lock no-error.
if not avail final-temp2 then do:
If lookup(string(temp.gl), s_string[1]) > 0 then
       v-gl-sum[1] = v-gl-sum[1] + temp.amtkzt.
else if lookup(string(temp.gl), s_string[2]) > 0 then
       v-gl-sum[2] = v-gl-sum[2] + temp.amtkzt.
else if lookup(string(temp.gl), s_string[3]) > 0 then
       v-gl-sum[3] = v-gl-sum[3] + temp.amtkzt.
else if lookup(string(temp.gl), s_string[4]) = 0 then
       v-gl-sum[4] = v-gl-sum[4] + temp.amtkzt.
end.
end.
end.
create final-temp no-error.
update final-temp.cif = "CHP"
       final-temp.value_0 = 0
       final-temp.value_1 = v-gl-sum[1]
       final-temp.value_2 = v-gl-sum[2]
       final-temp.value_3 = v-gl-sum[3]
       final-temp.value_4 = v-gl-sum[4].
/* Выборка по доходов за предыдущий месяц по ЧП и фл */
for each temps where temps.jh <> 0 no-lock.
find first final-temp1 where final-temp1.cif = temps.cif no-lock no-error.
if not avail final-temp1 then do:
find first final-temp3 where final-temp3.cif = temps.cif no-lock no-error.
if not avail final-temp3 then do:
find first final-temp where final-temp.cif = "CHP" no-lock no-error.
if lookup(string(temps.gl), s_string[1]) > 0 then
update final-temp.value_6 = final-temp.value_6 + temps.amtkzt.
else if lookup(string(temps.gl), s_string[2]) > 0 then
update final-temp.value_7 = final-temp.value_7 + temps.amtkzt.
else if lookup(string(temps.gl), s_string[3]) > 0 then
update final-temp.value_8 = final-temp.value_8 + temps.amtkzt.
else if lookup(string(temps.gl), s_string[4]) = 0 then
update final-temp.value_9 = final-temp.value_9 + temps.amtkzt.
end.
end.
end.
/* Общая сумма доходов по коммунальным платежам за предыдущий месяц */
for each temps where temps.jh = 0 no-lock.
sum8 = sum8 + temps.amtkzt.
end.
output to report.htm.
{html-start.i}
v-nmbs = 1.
find first ppoint where ppoint.depart = integer(v-dep) no-lock no-error.
put unformatted
   "<IMG border=""0"" src=""c://tmp/top_logo_bw1.jpg""><BR><BR><BR>" skip
   "<B><P align = ""left""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "Активность клиентов СПФ и филиалов с " string(dt3) " по " string(dt4) "</FONT><BR>" skip
   "СПФ: " ppoint.name "</B><BR><BR>" skip.
find last crchis where crchis.crc = 2 and crchis.regdt le dt4 no-lock no-error.
put unformatted "<TR align = ""left""> Курс доллара: " string(crchis.rate[1]) " за " string(dt4) "</TR><BR>" skip.
put unformatted "<TR align = ""left""><B><I>1. Обороты и доходы клиентов<I></B></TR><BR>" skip.
put unformatted

   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip
     "<TD  rowspan=""2"" bgcolor=""#95B2D1""><B>N</B></FONT></TD>" skip
     "<TD  rowspan=""2"" bgcolor=""#95B2D1""><B>Наименование клиента</B></FONT></TD>" skip
     "<TD  colspan=""6"" bgcolor=""#95B2D1""><B>Текущий месяц</B></FONT></TD>" skip
     "<TD  colspan=""6"" bgcolor=""#95B2D1""><B>Предыдущий месяц</B></FONT></TD>" skip
   "</TR>"
   "<TR align=""center"" valign=""top"">" skip
     "<TD  bgcolor=""#95B2D1""><B>Оборот, тенге</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Итого доход, тыс. тенге</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Опер. деятельность</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Кредитование</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Дилинговые операции</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Прочие операции</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Оборот, тенге</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Итого доход, тыс. тенге</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Опер. деятельность</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Кредитование</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Дилинговые операции</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Прочие операции</B></FONT></TD>" skip
   "</TR>".
run clearvar1.
for each final-temp1 no-lock break by final-temp1.saldo descending.
find first final-temp where final-temp.cif = final-temp1.cif no-lock no-error.
find first cif where cif.cif = final-temp.cif no-lock no-error.
put unformatted "<TR align=""center"" ><TD>" v-nmbs "</TD>" skip
                    "<TD>" cif.prefix + " " + cif.name "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_0,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_1 + final-temp.value_2 + final-temp.value_3 + final-temp.value_4,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_1,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_2,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_3,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_4,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_5,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_6 + final-temp.value_7 + final-temp.value_8 + final-temp.value_9,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_6,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_7,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_8,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_9,2)) "</TD></TR>" skip.
v-itogo[1] = v-itogo[1] + (final-temp.value_1 + final-temp.value_2 + final-temp.value_3 + final-temp.value_4).
v-itogo[2] = v-itogo[2] + final-temp.value_1.
v-itogo[3] = v-itogo[3] + final-temp.value_2.
v-itogo[4] = v-itogo[4] + final-temp.value_3.
v-itogo[5] = v-itogo[5] + final-temp.value_4.
v-itogo[6] = v-itogo[6] + (final-temp.value_6 + final-temp.value_7 + final-temp.value_8 + final-temp.value_9).
v-itogo[7] = v-itogo[7] + final-temp.value_6.
v-itogo[8] = v-itogo[8] + final-temp.value_7.
v-itogo[9] = v-itogo[9] + final-temp.value_8.
v-itogo[10] = v-itogo[10] + final-temp.value_9.
v-nmbs = v-nmbs + 1.
end.
for each final-temp where final-temp.cif = "OST" no-lock break by final-temp.value_1 descending.
put unformatted "<TR align=""center"" ><TD>" v-nmbs "</TD>" skip
                    "<TD>  Остальные клиенты </TD>" skip
                    "<TD>  </TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_1 + final-temp.value_2 + final-temp.value_3 + final-temp.value_4,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_1,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_2,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_3,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_4,2)) "</TD>" skip
                    "<TD>  </TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_6 + final-temp.value_7 + final-temp.value_8 + final-temp.value_9,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_6,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_7,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_8,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_9,2)) "</TD></TR>" skip.
v-itogo[1] = v-itogo[1] + (final-temp.value_1 + final-temp.value_2 + final-temp.value_3 + final-temp.value_4).
v-itogo[2] = v-itogo[2] + final-temp.value_1.
v-itogo[3] = v-itogo[3] + final-temp.value_2.
v-itogo[4] = v-itogo[4] + final-temp.value_3.
v-itogo[5] = v-itogo[5] + final-temp.value_4.
v-itogo[6] = v-itogo[6] + (final-temp.value_6 + final-temp.value_7 + final-temp.value_8 + final-temp.value_9).
v-itogo[7] = v-itogo[7] + final-temp.value_6.
v-itogo[8] = v-itogo[8] + final-temp.value_7.
v-itogo[9] = v-itogo[9] + final-temp.value_8.
v-itogo[10] = v-itogo[10] + final-temp.value_9.
v-nmbs = v-nmbs + 1.
end.
run outstring.
run whole-calc.
run clearvar1.
for each final-temp where final-temp.cif = "CHP" no-lock break by final-temp.value_1 descending.
put unformatted "<TR align=""center"" ><TD>" v-nmbs "</TD>" skip
                    "<TD>  ЧП и ФЛ </TD>" skip
                    "<TD>  </TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_1 + final-temp.value_2 + final-temp.value_3 + final-temp.value_4,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_1,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_2,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_3,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_4,2)) "</TD>" skip
                    "<TD>  </TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_6 + final-temp.value_7 + final-temp.value_8 + final-temp.value_9,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_6,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_7,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_8,2)) "</TD>" skip
                    "<TD>" XLS-NUMBER(round(final-temp.value_9,2)) "</TD></TR>" skip.
v-nmbs = v-nmbs + 1.
v-itogo[1] = v-itogo[1] + (final-temp.value_1 + final-temp.value_2 + final-temp.value_3 + final-temp.value_4).
v-itogo[2] = v-itogo[2] + final-temp.value_1.
v-itogo[3] = v-itogo[3] + final-temp.value_2.
v-itogo[4] = v-itogo[4] + final-temp.value_3.
v-itogo[5] = v-itogo[5] + final-temp.value_4.
v-itogo[6] = v-itogo[6] + (final-temp.value_6 + final-temp.value_7 + final-temp.value_8 + final-temp.value_9).
v-itogo[7] = v-itogo[7] + final-temp.value_6.
v-itogo[8] = v-itogo[8] + final-temp.value_7.
v-itogo[9] = v-itogo[9] + final-temp.value_8.
v-itogo[10] = v-itogo[10] + final-temp.value_9.
end.
run outstring.
run whole-calc.
run outfin.
put unformatted "</TABLE><BR>" skip.
put unformatted "<TR align=""left""><TD><I>Общая сумма доходов СПФ за период с " string(dt3) " по " string(dt4) "</TD><TD><B>:  " XLS-NUMBER(round(sum1,2)) "</B></TD></I></TR><BR>" skip.
put unformatted "<TR align=""left""><TD><I>Комиссии с кассы за коммунальные платежи за период с " string(dt3) " по " string(dt4) " </TD><TD><B>:  " XLS-NUMBER(round(sum5,2)) "</B></TD></I></TR><BR>" skip.
put unformatted "<TR align=""left""><TD><I>Общая сумма доходов СПФ за период с " string(dt1) " по " string(dt2) "</TD><TD><B>:  " XLS-NUMBER(round(sum7,2)) "</B></TD></I></TR><BR>" skip.
put unformatted "<TR align=""left""><TD><I>Комиссии с кассы за коммунальные платежи за период с " string(dt1) " по " string(dt2) " </TD><TD><B>:  " XLS-NUMBER(round(sum8,2)) "</B></TD></I></TR><BR>" skip.
v-nmbs = 1.
put unformatted "<TR align = ""left""><B><I>2. Привлечено клиентов (ЮЛ) <I></B></TR><BR>" skip.
put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""left"" valign=""top"">" skip
     "<TD  bgcolor=""#95B2D1""><B>N</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Наименование клиента</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Дата открытия</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Обороты по счетам</B></FONT></TD>" skip
   "</TR>".
for each cif where caps(cif.type) = "B" and
                   cif.regdt >= dt3 and
                   cif.regdt <= dt4 no-lock break by cif.cif.
if first-of (cif.cif) and integer (cif.jame) mod 1000 = integer(v-dep) then do:
find first aaa where aaa.cif = cif.cif and aaa.sta <> "C" no-lock no-error.
if avail aaa then do:
find last aab where aab.aaa = aaa.aaa and aab.fdt <= dt3 no-lock no-error.
if avail aab and aab.bal <> 0 then do:
if aaa.crc <> 1 then do:
find last crchis where crchis.crc = aaa.crc and crchis.regdt le dt4 no-lock no-error.
v-sbal = aab.bal.
v-abal[1] = v-sbal * crchis.rate[1].
end.
else
v-abal[1] = aab.bal.
end.
find last aab where aab.aaa = aaa.aaa and aab.fdt <= dt4 no-lock no-error.
if avail aab and aab.bal <> 0 then do:
if aaa.crc <> 1 then do:
find last crchis where crchis.crc = aaa.crc and crchis.regdt le dt4 no-lock no-error.
v-sbal = aab.bal.
v-abal[2] = v-sbal * crchis.rate[1].
end.
else
v-abal[2] = aab.bal.
end.
put unformatted "<TR><TD>" string(v-nmbs) "</TD>" skip
                    "<TD>" cif.prefix + " " cif.name "</TD>" skip
                    "<TD>" string(aaa.regdt) "</TD>" skip
                    "<TD>" string(v-abal[2] - v-abal[1]) "</TD></TR>" skip.
v-nmbs = v-nmbs + 1.
v-sdec = v-sdec + (v-abal[2] - v-abal[1]).
v-abal[1] = 0.
v-abal[2] = 0.
v-sbal = 0.
end.
end.
end.
put unformatted "<TR><TD  bgcolor=""#95B2D1""><B>Итого</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" string(v-sdec) "</TD></TR>" skip.
put unformatted "</TABLE><BR>" skip.
v-nmbs = 1.
put unformatted "<TR align = ""left""><B><I>3. Закрытые счета (ЮЛ)<I></B></TR><BR>" skip.
put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""left"" valign=""top"">" skip
     "<TD  bgcolor=""#95B2D1""><B>N</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Наименование клиента</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Дата открытия</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Дата закрытия</B></FONT></TD>" skip
   "</TR>".
for each aaa where aaa.sta = "C" and aaa.cltdt >= dt3 and aaa.cltdt <= dt4 no-lock.
find first cif where cif.cif = aaa.cif and caps(cif.type) = "B" no-lock no-error.
if avail cif and integer (cif.jame) mod 1000 = integer(v-dep) then do:
put unformatted "<TR><TD>" string(v-nmbs) "</TD>" skip
                    "<TD>" cif.prefix + " " cif.name "</TD>" skip
                    "<TD>" string(aaa.regdt) "</TD>" skip
                    "<TD>" string(aaa.cltdt) "</TD></TR>" skip.
v-nmbs = v-nmbs + 1.
end.
end.
{html-end.i}
output close.
unix silent value("cptwin report.htm excel").
pause 0.

procedure defdata.
do v-dat = dt1 to dt2:
for each temp-gl no-lock.
   for each bjl where bjl.jdt = v-dat and bjl.gl = temp-gl.gl and bjl.dc = "C" no-lock.
      find last crchis where crchis.crc = bjl.crc and crchis.regdt <= bjl.jdt no-lock no-error.
      find last ofchis where  ofchis.regdt <= v-dat and ofchis.ofc = bjl.who no-lock no-error.
      if avail ofchis and lookup(bjl.who, v-supusr) = 0 then do:
        if ofchis.depart = integer(v-dep) then do:
        if v-logic = "FIRST" then do:
          create temp.
          temp.gl = bjl.gl.
          if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
          else temp.doxras = "ras".
          temp.amtkzt = bjl.cam * crchis.rate[1].
          temp.amt = bjl.cam.
          temp.crc = bjl.crc.
          temp.ofc = bjl.who.
          temp.jh = bjl.jh.
         end.
         else do:
          create temps.
          temps.gl = bjl.gl.
          if substr(string(temps.gl),1,1) = "4" then temps.doxras = "dox".
          else temps.doxras = "ras".
          temps.amtkzt = bjl.cam * crchis.rate[1].
          temps.amt = bjl.cam.
          temps.crc = bjl.crc.
          temps.ofc = bjl.who.
          temps.jh = bjl.jh.
         end.
        end.
      end. /*avail ofchis*/
      else do:
        v-aaa = "".
        if bjl.acc <> "" then do:
          find aaa where aaa.aaa = bjl.acc no-lock no-error.
          if avail aaa then v-aaa = aaa.aaa.
        end.
        else do:
          find first jl where jl.jh = bjl.jh and substr(string(jl.gl), 1, 1) = "2" and jl.dc = "d" no-lock no-error.
          if avail jl and jl.acc <> "" then do:
            find aaa where aaa.aaa = jl.acc no-lock no-error.
            if avail aaa then v-aaa = aaa.aaa.
          end.
        end.
        if v-aaa <> "" then do:
           find cif where cif.cif = aaa.cif no-lock no-error.
           if integer (cif.jame) mod 1000 = integer(v-dep) then do:
         if v-logic = "FIRST" then do:
            create temp.
            temp.cif = aaa.cif.
            temp.gl = bjl.gl.
            if substr(string(temp.gl), 1, 1) = "4" then temp.doxras = "dox".
                                                   else temp.doxras = "ras".
            temp.amtkzt = bjl.cam * crchis.rate[1].
            temp.amt = bjl.cam.
            temp.crc = bjl.crc.
            temp.ofc = trim(substr(cif.fname, 1, 8)).
            temp.jh = bjl.jh.
         end.
         else do:
            create temps.
            temps.cif = aaa.cif.
            temps.gl = bjl.gl.
            if substr(string(temps.gl), 1, 1) = "4" then temps.doxras = "dox".
                                                    else temps.doxras = "ras".
            temps.amtkzt = bjl.cam * crchis.rate[1].
            temps.amt = bjl.cam.
            temps.crc = bjl.crc.
            temps.ofc = trim(substr(cif.fname, 1, 8)).
            temps.jh = bjl.jh.
         end.
          end. /*avail ofchis*/
        end.  /*avail aaa*/
      end.  /*else*/
   end. /* for each bjl*/  /* Выборка по данным клиентских счетов и проводок клиентов */
end. /* for each temp-gl ...*/
/*расчет доходов по налоговым платежам */
 for each tax where tax.txb = seltxb and date = v-dat and duid = ? no-lock use-index datenum.
 find first ofc where ofc.ofc = tax.uid no-lock no-error.
 if avail ofc then do:
   if get-dep(tax.uid, tax.date) = integer(v-dep)  then do:
     sum_tax =  sum_tax + tax.comsum.
   end.
 end.
 end.  /*tax*/
/*расчет доходов по пенсионным  платежам*/
  for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = v-dat and p_f_payment.deluid = ? no-lock:
  find first ofc where ofc.ofc = p_f_payment.uid no-lock no-error.
  if avail ofc then do:
    if get-dep(p_f_payment.uid, p_f_payment.date) = integer(v-dep) then do:
     sum_pf =  sum_pf + p_f_payment.comiss.
    end.
  end.
 end.  /*payment*/
  for each commonpl where commonpl.txb = seltxb and commonpl.date = v-dat and
     commonpl.deluid = ? no-lock use-index datenum.
     find first ofc where ofc.ofc = commonpl.uid no-lock no-error.
     if avail ofc then do:
    if get-dep(commonpl.uid, commonpl.date) = integer(v-dep) then do:
     find commonls where commonls.txb = commonpl.txb and
     commonls.grp = commonpl.grp and commonls.type = commonpl.type no-lock no-error.
      if avail commonls and commonls.visible then do:
       if commonls.comgl = 461110 then
         sum_com10 =  sum_com10 + commonpl.comsum.
       else if commonls.comgl = 461120 then
         sum_com20 =  sum_com20 + commonpl.comsum.
      end.
    end.
    end.
  end. /*commonpl*/
  for each commonpl where commonpl.txb = seltxb and commonpl.date = v-dat and
     commonpl.deluid = ? no-lock use-index datenum:
     find first ofc where ofc.ofc = commonpl.uid no-lock no-error.
     if avail ofc then do:
    if get-dep(commonpl.uid, commonpl.date) = integer(v-dep) then do:
     find commonls where commonls.txb = commonpl.txb and
     commonls.grp = commonpl.grp and commonls.type = commonpl.type no-lock no-error.
      if avail commonls and commonls.visible then do:
       if commonls.prcgl = 460111 then
         sum_prc10 =  sum_prc10 + (commonpl.sum * commonls.comprc).
       else if commonls.prcgl = 461110 then
         sum_prc20 =  sum_prc20 + (commonpl.sum * commonls.comprc).
      end.
    end.
  end.
  end. /*commonpl*/
end. /*v-dat*/
  if sum_tax <> 0 then do:
     if v-logic = "FIRST" then do:
       create temp.
       temp.gl = 461110.
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_tax.
       temp.amt = sum_tax.
       temp.crc = 1.
       temp.ofc = "Налоговые платежи".
       temp.jh = 0.
     end.
     else do:
       create temps.
       temps.gl = 461110.
       if substr(string(temps.gl),1,1) = "4" then temps.doxras = "dox".
       else temps.doxras = "ras".
       temps.amtkzt = sum_tax.
       temps.amt = sum_tax.
       temps.crc = 1.
       temps.ofc = "Налоговые платежи".
       temps.jh = 0.
     end.
  end.
  if sum_pf <> 0 then do:
     if v-logic = "FIRST" then do:
       create temp.
       temp.gl = 461110.
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_pf.
       temp.amt = sum_pf.
       temp.crc = 1.
       temp.ofc = "Пенсионные платежи".
       temp.jh = 0.
     end.
     else do:
       create temps.
       temps.gl = 461110.
       if substr(string(temps.gl),1,1) = "4" then temps.doxras = "dox".
       else temps.doxras = "ras".
       temps.amtkzt = sum_pf.
       temps.amt = sum_pf.
       temps.crc = 1.
       temps.ofc = "Пенсионные платежи".
       temps.jh = 0.
     end.
  end.
  if sum_com10 <> 0 then do:
     if v-logic = "FIRST" then do:
       create temp.
       temp.gl = 461110.
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_com10.
       temp.amt = sum_com10.
       temp.crc = 1.
       temp.ofc = "Прочие платежи ЮЛ".
       temp.jh = 0.
     end.
     else do:
       create temps.
       temps.gl = 461110.
       if substr(string(temps.gl),1,1) = "4" then temps.doxras = "dox".
       else temps.doxras = "ras".
       temps.amtkzt = sum_com10.
       temps.amt = sum_com10.
       temps.crc = 1.
       temps.ofc = "Прочие платежи ЮЛ".
       temps.jh = 0.
     end.
  end.
  if sum_com20 <> 0 then do:
     if v-logic = "FIRST" then do:
       create temp.
       temp.gl = 461120.
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_com20.
       temp.amt = sum_com20.
       temp.crc = 1.
       temp.ofc = "Прочие платежи ФЛ".
       temp.jh = 0.
     end.
     else do:
       create temps.
       temps.gl = 461120.
       if substr(string(temps.gl),1,1) = "4" then temps.doxras = "dox".
       else temps.doxras = "ras".
       temps.amtkzt = sum_com20.
       temps.amt = sum_com20.
       temps.crc = 1.
       temps.ofc = "Прочие платежи ФЛ".
       temps.jh = 0.
     end.
  end.
  if sum_prc10 <> 0 then do:
     if v-logic = "FIRST" then do:
       create temp.
       temp.gl = 460111.
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_prc10.
       temp.amt = sum_prc10.
       temp.crc = 1.
       temp.ofc = "Комиссии за перевод ЮЛ".
       temp.jh = 0.
     end.
     else do:
       create temps.
       temps.gl = 460111.
       if substr(string(temps.gl),1,1) = "4" then temps.doxras = "dox".
       else temps.doxras = "ras".
       temps.amtkzt = sum_prc10.
       temps.amt = sum_prc10.
       temps.crc = 1.
       temps.ofc = "Комиссии за перевод ЮЛ".
       temps.jh = 0.
     end.
  end.
  if sum_prc20 <> 0 then do:
     if v-logic = "FIRST" then do:
       create temp.
       temp.gl = 461110.
       if substr(string(temp.gl),1,1) = "4" then temp.doxras = "dox".
       else temp.doxras = "ras".
       temp.amtkzt = sum_prc20.
       temp.amt = sum_prc20.
       temp.crc = 1.
       temp.ofc = "Комиссии за перевод ЮЛ (кассовые операции)".
       temp.jh = 0.
     end.
     else do:
       create temps.
       temps.gl = 461110.
       if substr(string(temps.gl),1,1) = "4" then temps.doxras = "dox".
       else temps.doxras = "ras".
       temps.amtkzt = sum_prc20.
       temps.amt = sum_prc20.
       temps.crc = 1.
       temps.ofc = "Комиссии за перевод ЮЛ (кассовые операции)".
       temps.jh = 0.
     end.
  end.

for each aaa where aaa.sta <> "C" no-lock break by aaa.crc.
find first cif where cif.cif = aaa.cif no-lock no-error.
if avail cif and integer (cif.jame) mod 1000 = integer(v-dep) then do:
find last aab where aab.aaa = aaa.aaa and aab.fdt <= dt1 no-lock no-error.
if avail aab and aab.bal <> 0 then do:
if aaa.crc <> 1 then do:
find last crchis where crchis.crc = aaa.crc and crchis.regdt le dt1 no-lock no-error.
v-sbal = aab.bal.
v-abal[1] = v-sbal * crchis.rate[1].
end.
else
v-abal[1] = aab.bal.
end.
find last aab where aab.aaa = aaa.aaa and aab.fdt <= dt2 no-lock no-error.
if avail aab and aab.bal <> 0 then do:
if aaa.crc <> 1 then do:
find last crchis where crchis.crc = aaa.crc and crchis.regdt le dt2 no-lock no-error.
v-sbal = aab.bal.
v-abal[2] = v-sbal * crchis.rate[1].
end.
else
v-abal[2] = aab.bal.
end.
     if v-logic = "FIRST" then do:
	create cl-turnover.
        update cl-turnover.aaa = aaa.aaa
               cl-turnover.turn_1 = v-abal[1]
               cl-turnover.turn_2 = v-abal[2]
               cl-turnover.saldo  = v-abal[2] - v-abal[1]
               cl-turnover.sts = 0
               cl-turnover.cif = cif.cif.
     end.
     else do:
	create cl-turnovers.
        update cl-turnovers.aaa = aaa.aaa
               cl-turnovers.turn_1 = v-abal[1]
               cl-turnovers.turn_2 = v-abal[2]
               cl-turnovers.saldo  = v-abal[2] - v-abal[1]
               cl-turnovers.sts = 0
               cl-turnovers.cif = cif.cif.
     end.
v-abal[1] = 0.
v-abal[2] = 0.
v-sbal = 0.
end.
end.
end procedure.
procedure clearvar.
v-gl-sum[1] = 0.
v-gl-sum[2] = 0.
v-gl-sum[3] = 0.
v-gl-sum[4] = 0.
end.
procedure clearvar1.
v-itogo[1] = 0.
v-itogo[2] = 0.
v-itogo[3] = 0.
v-itogo[4] = 0.
v-itogo[5] = 0.
v-itogo[6] = 0.
v-itogo[7] = 0.
v-itogo[8] = 0.
v-itogo[9] = 0.
v-itogo[10] = 0.
end.
procedure whole-calc.
v-itogow[1] = v-itogow[1] + v-itogo[1].
v-itogow[2] = v-itogow[2] + v-itogo[2].
v-itogow[3] = v-itogow[3] + v-itogo[3].
v-itogow[4] = v-itogow[4] + v-itogo[4].
v-itogow[5] = v-itogow[5] + v-itogo[5].
v-itogow[6] = v-itogow[6] + v-itogo[6].
v-itogow[7] = v-itogow[7] + v-itogo[7].
v-itogow[8] = v-itogow[8] + v-itogo[8].
v-itogow[9] = v-itogow[9] + v-itogo[9].
v-itogow[10] = v-itogow[10] + v-itogo[10].
end.
procedure outstring.
put unformatted "<TR align=""center"" ><TD bgcolor=""#95B2D1""><B> ИТОГО </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[1],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[2],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[3],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[4],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[5],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[6],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[7],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[8],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[9],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogo[10],2)) "</B></TD></TR>" skip.
put unformatted "<TR align=""center"" ><TD bgcolor=""#95B2D1""><B> Процент от дохода </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[1] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[2] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[3] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[4] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[5] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[6] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[7] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[8] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[9] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogo[10] * 100) / sum1,1)) "</B></TD></TR>" skip.
end.
procedure outfin.
put unformatted "<TR align=""center"" ><TD bgcolor=""#95B2D1""><B> Общий доход (тыс.тенге) </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[1],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[2],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[3],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[4],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[5],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[6],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[7],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[8],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[9],2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round(v-itogow[10],2)) "</B></TD></TR>" skip.
put unformatted "<TR align=""center"" ><TD bgcolor=""#95B2D1""><B> % от общего дохода </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[1] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[2] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[3] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[4] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[5] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[6] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[7] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[8] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[9] * 100) / sum1,1)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[10] * 100) / sum1,1)) "</B></TD></TR>" skip.
find last crchis where crchis.crc = 2 and crchis.regdt le dt2 no-lock no-error.
put unformatted "<TR align=""center"" ><TD bgcolor=""#95B2D1""><B>  Общий доход в USD </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[1] / crchis.rate[1]),2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[2] / crchis.rate[1]),2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[3] / crchis.rate[1]),2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[4] / crchis.rate[1]),2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[5] / crchis.rate[1]),2)) "</TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>  </TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[6] / crchis.rate[1]),2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[7] / crchis.rate[1]),2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[8] / crchis.rate[1]),2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[9] / crchis.rate[1]),2)) "</B></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(round((v-itogow[10] / crchis.rate[1]),2)) "</B></TD></TR>" skip.
end.
