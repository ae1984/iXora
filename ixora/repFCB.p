/* .p
 * MODULE
        Название модуля
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
        05.11.2013 evseev - tz-1952
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}



def var v-sdt as date.
def var v-edt as date.
form skip 'c: ' v-sdt ' по: ' v-edt with frame form1 no-label row 3  centered .

update v-sdt v-edt with frame form1 .

def var i as int.
def var v-txb as char.
def var v-fio as char.
def var v-product as char.
def var v-reptype as char.

def stream rep.
def var v-file  as char init "repfcb.html"  no-undo.

output to value(v-file).
{html-title.i &size-add = "x-"}

 put unformatted
   "<TABLE bordercolor=silver width=""600"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip.

put unformatted "<TR><TD colspan=8 height = 20 bgcolor=gray> Запрошенные отчеты в ПКБ </TD></TR>" skip.
put unformatted "<TR><TD colspan=8 height = 20 bgcolor=gray> c " string(v-sdt) " по " string(v-edt) " </TD></TR>" skip.

put unformatted "<TR><TD colspan=8 height = 15> </TD></TR>" skip.


put unformatted
   "<TR>" skip
     "<TD>№</TD>" skip
     "<TD>Филиал</TD>" skip
     "<TD>Дата и время запроса отчета</TD>" skip
     "<TD>Ф.И.О. клиента</TD>" skip
     "<TD>ИИН</TD>" skip
     "<TD>Вид отчета</TD>" skip
     "<TD>Продукт</TD>" skip
     "<TD>id менеджера</TD>" skip
   "</TR>" skip.

i = 0.
for each fcb where fcb.dt >= v-sdt and fcb.dt <= v-edt and xml_id > 0 no-lock:
   i = i + 1.
   v-txb     =  "".
   v-fio     =  "".
   v-reptype =  "".
   v-product =  fcb.product.
   if v-product = "" then do:
      v-product = "4".
      for each pkanketa where  pkanketa.credtype = '10' and pkanketa.rnn = fcb.bin no-lock:
          find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.ln = pkanketa.ln and pkanketh.credtype = pkanketa.credtype and pkanketh.kritcod = "fcbid234" no-lock no-error.
          if avail pkanketh then do:
             if fcb.fcb_id = int(pkanketh.value1) then v-product = "10".
          end.
      end.
   end.

   find first pkanketa where pkanketa.rnn = fcb.bin and pkanketa.credtype = v-product no-lock no-error.
   if not avail pkanketa then find first pkanketa where pkanketa.rnn = fcb.bin no-lock no-error.
   if avail pkanketa then do:
      v-txb     =  pkanketa.bank.
      v-fio     =  pkanketa.name.
   end.

   if v-product = "4" then  v-product = "Кредитный лимит".
   else if v-product = "10" then  v-product = "Экспресс кредит".

   if fcb.req_method = 'GetReport.200017' then v-reptype = "Кредитный отчет - стандарт".

   put unformatted
       "<TR>" skip
         "<TD>" + string(i) + "</TD>" skip
         "<TD>" + v-txb + "</TD>" skip
         "<TD>" + string(fcb.dt) + " " + string(fcb.tm,"HH:MM") + "</TD>" skip
         "<TD>" + v-fio + "</TD>" skip
         "<TD>'" + fcb.bin + "</TD>" skip
         "<TD>" + v-reptype + "</TD>" skip
         "<TD>" + v-product + "</TD>" skip
         "<TD>" + fcb.usr + "</TD>" skip
       "</TR>" skip.
end.


put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.


unix silent cptwin value(v-file) excel.




