/* r-fiz.p
 * MODULE
        Отчет по валютным переводам ФЛ, ЮЛ        
 * DESCRIPTION
        Отчет по валютным переводам ФЛ, ЮЛ        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.12.6.8
 * AUTHOR
        15/03/2006 nataly
 * CHANGES
*/

def var v-dt1 as date no-undo.
def var v-dt2 as date no-undo.
def var v-dt as date no-undo.
def var v-dam as decimal no-undo.
def var v-prz as char no-undo.

def button  btn1  label "Юридические лица" .
def button  btn2  label "Физические лица" .
def button  btn3  label "Выход" .

def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете вариант отчета:" row 5 .

  on choose of btn1,btn2,btn3 do:
   if self:label = "Юридические лица" then v-prz = '7'.
    else
    if self:label = "Физические лица" then v-prz= '9'.
    else v-prz = '3'.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if v-prz = '3' then return.
 hide  frame frame1.

update 
         v-dt1 label 'Начало'
         v-dt2 label 'Конец' with frame ss.

def temp-table b-rem 
    field acc  like remtrz.racc
    field crc  like remtrz.tcrc
    field amt  like remtrz.amt
    field rdt like remtrz.rdt
    field rem like remtrz.remtrz
    field type like remtrz.ptype
    field sname as char
    field rname as char
    field acc2 as char
    field gl like remtrz.drgl
    field eknp as char
     index rdt rdt.

do v-dt = v-dt1 to v-dt2.
  hide message no-pause.
  message " Обработка " v-dt.
 for each remtrz no-lock where remtrz.rdt = v-dt  .
      if remtrz.fcrc = 1 then next.
    find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = 'eknp' no-lock no-error.
    if not avail sub-cod then next.
    /*отберем все исходящие*/
    if (remtrz.ptype = '6' /* or  remtrz.ptype = '2'*/) and substr(sub-cod.rcode,2,1) = v-prz then do:
      create b-rem.
       assign b-rem.acc = remtrz.sacc
              b-rem.crc = remtrz.fcrc
              b-rem.rdt = remtrz.rdt
              b-rem.rem = remtrz.remtrz
              b-rem.sname = ord
              b-rem.rname = bn[1] + bn[2]+ bn[3]
              b-rem.type = '6' /* remtrz.ptype*/
              b-rem.gl  = remtrz.drgl
              b-rem.eknp = substr(sub-cod.rcode,7,3) 
              b-rem.amt = remtrz.amt.

            if b-rem.acc = "" then b-rem.acc2 = '1'. else b-rem.acc2 = '2'.
     end.

    /*отберем все входящие*/
    if (remtrz.ptype = '7' /* or remtrz.ptype = '5'*/) and substr(sub-cod.rcode,5,1) = v-prz then do:
      create b-rem.
       assign b-rem.acc = remtrz.racc
              b-rem.crc = remtrz.fcrc
              b-rem.rdt = remtrz.rdt
              b-rem.rem = remtrz.remtrz
              b-rem.sname = ord
              b-rem.rname = bn[1] + bn[2]+ bn[3]
              b-rem.type =  '7' /*remtrz.ptype*/
              b-rem.gl  = remtrz.crgl
              b-rem.eknp = substr(sub-cod.rcode,7,3) 
              b-rem.amt = remtrz.amt.
            if b-rem.acc = "" then b-rem.acc2 = '1'. else b-rem.acc2 = '2'.
     end.

 end.
end.


def stream vcrpt.
output stream vcrpt to 'fiz.html'. 
{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted 
   "<p><B>" " Реестр по входящим и исходящим валютным переводам "  if v-prz = "7" then "юрид. лиц" else "физ. лиц"  " за период с " + 
        string(v-dt1) + " по " + string(v-dt2) + "</B></p>" skip.

for each b-rem use-index rdt break  by b-rem.acc2 by b-rem.type by b-rem.crc .

if first-of(b-rem.acc2) then do:
  put stream vcrpt unformatted
     "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
      "<TR><TD colspan = 8> <b>" if b-rem.acc2 = '1' then " Без открытия счета" else "Со счетом клиентов"  "</b> </TD></TR>" skip.

end.

if first-of(b-rem.type) then do: 
  put stream vcrpt unformatted
      "<TR><TD colspan = 8> <b>" if b-rem.type = '6' then " Исходящие" else "Входящие"  "</b> </TD></TR>" skip.
if b-rem.type = '6' then 
put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Номер счета клиента</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наим. отправ./клиента</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наим. получателя</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дата</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ЕКНП</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Remtrz</B></FONT></TD></TR>" skip.
else 
put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Номер счета клиента</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наим. получателя/клиента</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наим. отправителя</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дата</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ЕКНП</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Remtrz</B></FONT></TD></TR>" skip.

end.

   accum b-rem.amt (total by b-rem.crc).

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
if b-rem.type = '6' then 
  put stream vcrpt unformatted
      b-rem.crc  "</TD>" skip
      "<TD>"  b-rem.acc  "</TD>" skip
      "<TD>"  b-rem.sname  "</TD>" skip
      "<TD>"  b-rem.rname  "</TD>" skip
      "<TD>"  replace(string(b-rem.amt,'zzzzzzzzzzzzz9.99'),".",",") "</TD>" skip
      "<TD>"  b-rem.rdt  "</TD>" skip
      "<TD>"  b-rem.eknp  "</TD>" skip
      "<TD>"  b-rem.rem  "</TD></TR>" skip.
else 
  put stream vcrpt unformatted
      b-rem.crc  "</TD>" skip
      "<TD>"  b-rem.acc  "</TD>" skip
      "<TD>"  b-rem.rname  "</TD>" skip
      "<TD>"  b-rem.sname  "</TD>" skip
      "<TD>"  replace(string(b-rem.amt,'zzzzzzzzzzzzz9.99'),".",",") "</TD>" skip
      "<TD>"  b-rem.rdt  "</TD>" skip
      "<TD>"  b-rem.eknp  "</TD>" skip
      "<TD>"  b-rem.rem  "</TD></TR>" skip.


  if last-of(b-rem.crc) then do:
     v-dam = ACCUMulate total  by  b-rem.crc b-rem.amt.   


  put stream vcrpt unformatted
      "<TR><TD colspan = 3> <b> ИТОГО   </b></TD>" skip
      "<TD><b>"  b-rem.crc  "</b></TD>" skip
      "<TD>"  replace(string(v-dam,'zzzzzzzzzzzzz9.99'),".",",") "</TD>" skip
      "<TD colspan = 3>  &nbsp </TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.  

end.

put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i " stream vcrpt "}

output stream vcrpt close.

  unix silent value("cptwin fiz.html excel").

pause 0.
