/* rksd1.p
 * MODULE
       Департамент Регионального Развития
 * DESCRIPTION
       Отчет по изменениям оборотов клиентов с процентами (консолидированный)
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        02/08/04 kanat
 * CHANGES
        03/08/04 kanat - в форме ввода увеличил комментарии для Шахворостовой Ю.
*/
def input parameter d-name as char.
def shared var dt1 as date.
def shared var dt2 as date.
def shared var v-prc as decimal format "99".

def var v-aaa as char.
def var v-supusr as char.

def var dt3 as date.
def var dt4 as date.

def var v-sbal as decimal.
def var v-abal as decimal extent 4.

def temp-table tempf
    field cif as char
    field name as char
    field bal_1 as decimal
    field bal_2 as decimal
    field saldo_1 as decimal
    field bal_3 as decimal
    field bal_4 as decimal
    field saldo_2 as decimal
    field saldo_3 as decimal
    field prc as decimal. 

def var v-month-init as integer.
def var v-year-init as integer.

def var v-nmbs as integer.

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

find txb.sysc where txb.sysc.sysc = "sys1" no-lock no-error.
v-supusr = txb.sysc.des.

v-month-init = month(dt1).
v-year-init = year(dt1).

dt3 = date(v-month-init - 1, 1, v-year-init).
dt4 = date(v-month-init - 1, day_count(v-month-init - 1,v-year-init), v-year-init).

for each txb.aaa where txb.aaa.sta <> "C" no-lock.

find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
if avail txb.cif and caps(txb.cif.type) = "B" then do:

find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= dt1 no-lock no-error.
if avail txb.aab and txb.aab.bal <> 0 then do:
if txb.aaa.crc <> 1 then do:
find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt le dt1 no-lock no-error.                
v-sbal = txb.aab.bal.
v-abal[1] = v-sbal * txb.crchis.rate[1].
end.
else
v-abal[1] = txb.aab.bal.
end.

find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= dt2 no-lock no-error.
if avail txb.aab and txb.aab.bal <> 0 then do:
if txb.aaa.crc <> 1 then do:
find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt le dt2 no-lock no-error.                
v-sbal = txb.aab.bal.
v-abal[2] = v-sbal * txb.crchis.rate[1].
end.
else
v-abal[2] = txb.aab.bal.
end.

find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= dt3 no-lock no-error.
if avail txb.aab and txb.aab.bal <> 0 then do:
if txb.aaa.crc <> 1 then do:
find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt le dt3 no-lock no-error.                
v-sbal = txb.aab.bal.
v-abal[3] = v-sbal * txb.crchis.rate[1].
end.
else
v-abal[3] = txb.aab.bal.
end.

find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= dt4 no-lock no-error.
if avail txb.aab and txb.aab.bal <> 0 then do:
if txb.aaa.crc <> 1 then do:
find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt le dt4 no-lock no-error.                
v-sbal = txb.aab.bal.
v-abal[4] = v-sbal * txb.crchis.rate[1].
end.
else
v-abal[4] = txb.aab.bal.
end.

create tempf no-error.
update tempf.cif = txb.aaa.cif
       tempf.name = txb.cif.prefix + " " + txb.cif.name
       tempf.bal_1 = v-abal[1]
       tempf.bal_2 = v-abal[2]
       tempf.saldo_1 = v-abal[2] - v-abal[1]
       tempf.bal_3 = v-abal[3]
       tempf.bal_4 = v-abal[4]
       tempf.saldo_2 = v-abal[4] - v-abal[3]
       tempf.saldo_3 = (tempf.saldo_1 - tempf.saldo_2)
       tempf.prc = round((tempf.saldo_1 / tempf.saldo_2) * 100, 1).
      
v-abal[1] = 0.
v-abal[2] = 0.
v-abal[3] = 0.
v-abal[4] = 0.
v-sbal = 0.
end.
end.

v-nmbs = 1.
put unformatted
   "<B><I>СПФ: " d-name  "</I></B><BR><BR>" skip. 
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.regdt le dt2 no-lock no-error.                
put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""left"" valign=""top"">" skip
     "<TD  bgcolor=""#95B2D1""><B>N</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Наименование клиента</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Обороты за текущий месяц (в тенге)</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Обороты за прошлый месяц (в тенге)</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Уменьшение оборотов (в тенге)</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Процент уменьшения оборотов</B></FONT></TD>" skip
   "</TR>".               

for each tempf where tempf.prc >= v-prc and 
                     tempf.saldo_3 < 0 and 
                     tempf.saldo_1 > 0 and 
                     tempf.saldo_2 > 0 no-lock break by tempf.cif by tempf.saldo_3 descending.

accumulate tempf.saldo_1 (sub-total by tempf.cif).
accumulate tempf.saldo_2 (sub-total by tempf.cif).
accumulate tempf.saldo_3 (sub-total by tempf.cif).

accumulate tempf.saldo_1 (total).
accumulate tempf.saldo_2 (total).
accumulate tempf.saldo_3 (total).

if last-of (tempf.cif) then do:
find first txb.cif where txb.cif.cif = tempf.cif no-lock no-error.
if (accum sub-total by tempf.cif tempf.saldo_1) <> 0 or (accum sub-total by tempf.cif tempf.saldo_2) <> 0 or (accum sub-total by tempf.cif tempf.saldo_3) <> 0 then do:
put unformatted "<TR><TD>" string(v-nmbs) "</TD>" skip
                    "<TD>" cif.prefix + " " cif.name "</TD>" skip
                    "<TD>" (accum sub-total by tempf.cif tempf.saldo_1) format "->>>>>>>>>>>>>>>>>9.99" "</TD>" skip
                    "<TD>" (accum sub-total by tempf.cif tempf.saldo_2) format "->>>>>>>>>>>>>>>>>9.99" "</TD>" skip
                    "<TD>" (accum sub-total by tempf.cif tempf.saldo_3) format "->>>>>>>>>>>>>>>>>9.99" "</TD>" skip
                    "<TD>" (tempf.prc) "</TD></TR>" skip.
v-nmbs = v-nmbs + 1.
end.
end.
end.
put unformatted "<TR><TD  bgcolor=""#95B2D1""><B>  ИТОГО: </B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>  </TD></B>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" (accum total tempf.saldo_1) format "->>>>>>>>>>>>>>>>>9.99" "</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" (accum total tempf.saldo_2) format "->>>>>>>>>>>>>>>>>9.99" "</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>" (accum total tempf.saldo_3) format "->>>>>>>>>>>>>>>>>9.99" "</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""><B>  </B></TD></TR>" skip.
put unformatted "</TABLE><BR>" skip.
            



