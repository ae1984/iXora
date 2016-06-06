/* rksactd.p
 * MODULE
       Департамент Регионального Развития
 * DESCRIPTION
       Отчет - Изменение оборотов клиентов СПФ с выводом процентов
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        02/08/04 kanat
 * CHANGES
        03/08/04 kanat - в форме ввода увеличил комментарии для Шахворостовой Ю.
        03/12/04 kanat - переделал формулу формирования уменьшения процентов по просьбе ДРР и руководства
        06/12/04 kanat - переделал формирование оборотов по счетами клиентов на их кредитовые обороты по просьбе руководства
        07/12/04 kanat - убрал автоматическую конвертацию кредитовых остатков по счетам.
        01/02/05 kanat - добавил обработку месяцев
        17/06/05 kanat - убрал обработку месяцев - сравниваемый период задается самим пользователем
*/
{get-dep.i}
{global.i}
{msg-box.i}

def new shared var v-name as char.
def new shared var v-deps as char format "x(3)".
def new shared var v-prc as decimal format "99".
def var v-aaa as char.
def var v-supusr as char.

def var dt1 as date.
def var dt2 as date.
def var dt3 as date.
def var dt4 as date.

def var v-sbal1 as decimal.
def var v-sbal2 as decimal.

def var v-abal as decimal extent 2.

def temp-table tempf
    field cif as char
    field name as char
    field crc as integer
    field saldo_1 as decimal
    field saldo_2 as decimal
    field saldo_3 as decimal
    field prc as decimal. 

def var v-month-init as integer.
def var v-year-init as integer.

def var v-nmbs as integer.

def new shared frame opt 
        v-deps   label  "Код структурного подразделения" skip 
        v-prc    label  "Процент уменьшения оборотов" skip
        dt1      label  "Дата начала периода (текущий) " validate (dt1 <= g-today, " Дата не может быть больше текущей!") skip
        dt2      label  "Дата конца периода (текущий) " validate (dt2 <= g-today, " Дата не может быть больше текущей!") skip(1)
        dt3      label  "Дата начала периода (для сравнения)" skip
        dt4      label  "Дата конца периода  (для сравнения)" skip
        with row 8 centered side-labels.

update v-deps 
       v-prc
       dt1
       dt2
       dt3
       dt4
       with frame opt.

if dt4 < dt3 then do:
    message "Неверно задана дата конца отчета".
    undo,retry.    
end.

if dt2 < dt1 then do:
    message "Неверно задана дата конца отчета".
    undo,retry.    
end.

hide frame opt.

find ppoint where ppoint.depart = integer(v-deps) no-lock no-error.
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

find ppoint where ppoint.dep = integer(v-deps) no-lock no-error.
if avail ppoint then v-name = ppoint.name.

find bank.sysc where bank.sysc.sysc = "sys1" no-lock no-error.
v-supusr = bank.sysc.des.


/*
v-month-init = month(dt1).
v-year-init = year(dt1).

if v-month-init - 1 > 0 then do:
dt3 = date(v-month-init - 1, 1, v-year-init).
dt4 = date(v-month-init - 1, day_count(v-month-init - 1,v-year-init), v-year-init).
end.

if v-month-init - 1 = 0 then do:
dt3 = date(12, 1, v-year-init - 1).
dt4 = date(12, day_count(12, v-year-init - 1), v-year-init - 1).
end.
*/

for each aaa where aaa.sta <> "C" no-lock.

find first cif where cif.cif = aaa.cif no-lock no-error.
if avail cif and caps(cif.type) = "B" and integer (cif.jame) mod 1000 = integer(v-deps) then do:

for each jl where jl.jdt >= dt1 and
                  jl.jdt <= dt2 and
                  jl.acc = aaa.aaa and
                  jl.gl = aaa.gl and
                  jl.cam <> 0 no-lock.
v-sbal1 = v-sbal1 + jl.cam.
end.
v-abal[1] = v-sbal1.

for each jl where jl.jdt >= dt3 and
                  jl.jdt <= dt4 and
                  jl.acc = aaa.aaa and
                  jl.gl = aaa.gl and
                  jl.cam <> 0 no-lock.
v-sbal2 = v-sbal2 + jl.cam.
end.
v-abal[2] = v-sbal2.

create tempf no-error.
update tempf.cif = aaa.cif
       tempf.name = cif.prefix + " " + cif.name
       tempf.crc = aaa.crc
       tempf.saldo_1 = v-abal[1]                            /* Сумма кредитовых оборотов за текущий месяц */
       tempf.saldo_2 = v-abal[2]                            /* Сумма кредитовых оборотов за предыдущий месяц */
       tempf.saldo_3 = (tempf.saldo_1 - tempf.saldo_2)      /* Разница между ... */
       tempf.prc = round((abs(tempf.saldo_3) / tempf.saldo_2) * 100, 1).
        
v-sbal1 = 0.
v-sbal2 = 0.
v-abal[1] = 0.
v-abal[2] = 0.

end.
/*
    run SHOW-MSG-BOX ("Сбор статистики по счету: " + aaa.aaa + " CIF: " + cif.cif).
*/
end.

output to report1.htm.
{html-start.i}
v-nmbs = 1.
find first ppoint where ppoint.depart = integer(v-deps) no-lock no-error.
put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr"">" skip
   " Уменьшение оборотов клиентов СПФ на более чем " string(v-prc) " % <BR> с " string(dt1) " по " string(dt2) " <I> (в разрезе валют) </I> <BR>" skip
   " Структурное подразделение: " ppoint.name "</B></FONT><BR><BR>" skip. 
put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""left"" valign=""top"">" skip
     "<TD  bgcolor=""#95B2D1""><B>N</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Наименование клиента</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Код валюты счета</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Обороты по кредиту c " string(dt1) " по " string(dt2) " (тенге)</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Обороты по кредиту с " string(dt3) " по " string(dt4) " (тенге)</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Уменьшение оборотов по кредиту (тенге)</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Уменьшение оборотов по кредиту (%)</B></FONT></TD>" skip
   "</TR>".               

for each tempf where tempf.prc >= v-prc and 
                     tempf.saldo_3 < 0 and 
                     tempf.saldo_1 > 0 and 
                     tempf.saldo_2 > 0 no-lock break by tempf.cif by tempf.crc by tempf.saldo_3 descending.

if first-of (tempf.cif) then do:
find first cif where cif.cif = tempf.cif no-lock no-error.
put unformatted "<TR><TD>" string(v-nmbs) "</TD>" skip
                    "<TD>" cif.prefix + " " cif.name "</TD>" skip
                    "<TD>" "</TD>" skip
                    "<TD>" "</TD>" skip
                    "<TD>" "</TD>" skip
                    "<TD>" "</TD>" skip
                    "<TD>" "</TD></TR>" skip.
end.

accumulate tempf.saldo_1 (sub-total by tempf.crc).
accumulate tempf.saldo_2 (sub-total by tempf.crc).
accumulate tempf.saldo_3 (sub-total by tempf.crc).

accumulate tempf.saldo_1 (total).
accumulate tempf.saldo_2 (total).
accumulate tempf.saldo_3 (total).

if last-of (tempf.crc) then do:
find first crc where crc.crc = tempf.crc no-lock no-error.
if (accum sub-total by tempf.crc tempf.saldo_1) <> 0 or (accum sub-total by tempf.crc tempf.saldo_2) <> 0 or (accum sub-total by tempf.crc tempf.saldo_3) <> 0 then do:
put unformatted "<TR><TD>" "</TD>" skip
                    "<TD>" "</TD>" skip
                    "<TD>" crc.code "</TD>" skip
                    "<TD>" (accum sub-total by tempf.crc tempf.saldo_1) format "->>>>>>>>>>>>>>>>>9.99" "</TD>" skip
                    "<TD>" (accum sub-total by tempf.crc tempf.saldo_2) format "->>>>>>>>>>>>>>>>>9.99" "</TD>" skip
                    "<TD>" (accum sub-total by tempf.crc tempf.saldo_3) format "->>>>>>>>>>>>>>>>>9.99" "</TD>" skip
                    "<TD>" string(tempf.prc) "</TD></TR>" skip.
v-nmbs = v-nmbs + 1.
end.
end.
end.

for each tempf where tempf.prc >= v-prc and 
                     tempf.saldo_3 < 0 and 
                     tempf.saldo_1 > 0 and 
                     tempf.saldo_2 > 0 no-lock break by tempf.crc by tempf.saldo_3 descending.
accumulate tempf.saldo_1 (sub-total by tempf.crc).
accumulate tempf.saldo_2 (sub-total by tempf.crc).
accumulate tempf.saldo_3 (sub-total by tempf.crc).
if last-of (tempf.crc) then do:
find first crc where crc.crc = tempf.crc no-lock no-error.
put unformatted "<TR><TD  bgcolor=""#95B2D1""><B>  Итого: </B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>  </TD></B>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" crc.code "</TD></B>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" (accum sub-total by tempf.crc tempf.saldo_1) format "->>>>>>>>>>>>>>>>>9.99" "</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" (accum sub-total by tempf.crc tempf.saldo_2) format "->>>>>>>>>>>>>>>>>9.99" "</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" (accum sub-total by tempf.crc tempf.saldo_3) format "->>>>>>>>>>>>>>>>>9.99" "</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>  </B></TD></TR>" skip.
end.
end.

put unformatted "</TABLE><BR>" skip.
            
{html-end.i}
output close.
unix silent value("cptwin report1.htm excel").

pause 0.

