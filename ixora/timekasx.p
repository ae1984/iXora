/* timkasx.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        ИНформация по операциям кассира - по времени проведения операций	
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        22/07/2005 kanat
 * CHANGES
*/

{global.i}
{comm-txb.i}

define variable seltxb as integer.
def var v-whole as decimal.

def temp-table ttmps 
    field fio as char
    field rnn as char
    field sum as decimal
    field npl as char
    field dt as date
    field tim as integer.

def var v-date-begin as date.
def var v-date-finish as date.
def var v-ofcname as char.
def var v-ofc as char.

seltxb = comm-cod().

update v-date-begin label "Введите период с " v-date-finish label " по " skip 
       v-ofc  label "Логин кассира" with centered side-label frame frame_for_edit.

if v-date-begin = ? or v-date-finish = ? then do:
message "Неверно заданы даты периода" view-as alert-box title "Внимание".
return.
end.

if v-date-begin > v-date-finish then do:
message "Неверно заданы даты периода" view-as alert-box title "Внимание".
return.
end.

for each commonpl where commonpl.txb = seltxb and 
                  commonpl.date >= v-date-begin and 
                  commonpl.date <= v-date-finish and 
                  commonpl.uid = v-ofc and
                  commonpl.deluid = ? no-lock.

find first commonls where commonls.txb = seltxb and 
                          commonls.grp = commonpl.grp and 
                          commonls.arp = commonpl.arp and 
                          visible no-lock no-error.

if avail commonls then do:
create ttmps.
update ttmps.fio = commonpl.fio
       ttmps.dt = commonpl.date
       ttmps.rnn = commonpl.rnn
       ttmps.sum = commonpl.sum
       ttmps.npl = commonls.npl
       ttmps.tim = commonpl.cretime.
v-whole = v-whole + ttmps.sum.       
end.
end.                   


for each commonpl where commonpl.txb = seltxb and 
                  commonpl.date >= v-date-begin and 
                  commonpl.date <= v-date-finish and 
                  commonpl.uid = v-ofc and
                  commonpl.deluid = ? and 
                  commonpl.grp = 15 no-lock.

create ttmps.
update ttmps.fio = commonpl.fio
       ttmps.dt = commonpl.date
       ttmps.rnn = commonpl.rnn
       ttmps.sum = commonpl.sum
       ttmps.npl = commonpl.npl
       ttmps.tim = commonpl.cretime.
v-whole = v-whole + ttmps.sum.       
end.                   


for each tax where tax.txb = seltxb and
                   tax.date >= v-date-begin and
                   tax.date <= v-date-finish and
                   tax.uid = v-ofc and
                   tax.duid = ? no-lock.
create ttmps.
update ttmps.fio = tax.chval[1]
       ttmps.dt = tax.date
       ttmps.rnn = tax.rnn
       ttmps.sum = tax.sum
       ttmps.npl = string(tax.kb)
       ttmps.tim = tax.created.
v-whole = v-whole + ttmps.sum.
end.                    


for each almatv where almatv.dtfk >= v-date-begin and
                      almatv.dtfk <= v-date-finish and 
                      almatv.uid = v-ofc and 
                      almatv.deluid = ? no-lock.
create ttmps.
update ttmps.fio = almatv.f + " " + almatv.io
       ttmps.dt  = almatv.dtfk
       ttmps.rnn = string(almatv.ndoc)
       ttmps.sum = almatv.summfk
       ttmps.npl = "Платеж АЛМАТВ, счет " + string(ndoc) 
       ttmps.tim = almatv.cretime.
v-whole = v-whole + ttmps.sum.
end.


output to timekasx.htm.
{html-start.i}

   find first ofc where ofc.ofc = v-ofc no-lock no-error.
   if avail ofc then 
   v-ofcname = ofc.name.
   else do:
   message "Неверный логин кассира" view-as alert-box title "Внимание".
   return.
   end.

put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr"">" skip
   " Отчет по операциям кассира " v-ofcname " с " string(v-date-begin) " по " string(v-date-finish) " (кроме пенсионных платежей) <BR></FONT><BR><BR>" skip. 

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""left"" valign=""top"">" skip
     "<TD bgcolor=""#95B2D1""><B>Дата</B></TD>" skip
     "<TD bgcolor=""#95B2D1""><B>ФИО клиента</B></TD>" skip
     "<TD bgcolor=""#95B2D1""><B>РНН</B></TD>" skip
     "<TD bgcolor=""#95B2D1""><B>Сумма</B></TD>" skip
     "<TD bgcolor=""#95B2D1""><B>Назначение платежа</B></TD>" skip
     "<TD bgcolor=""#95B2D1""><B>Время</B></TD>" skip
   "</TR>".               

for each ttmps no-lock break by ttmps.dt by ttmps.tim.
if first-of (ttmps.dt) then 
put unformatted "<TR><TD>" string(ttmps.dt) "</TD>" skip
                    "<TD></TD>" skip
                    "<TD></TD>" skip
                    "<TD></TD>" skip
                    "<TD></TD>" skip
                    "<TD></TD></TR>" skip.

put unformatted "<TR><TD></TD>" skip
                    "<TD>" ttmps.fio "</TD>" skip
                    "<TD>[" ttmps.rnn "]</TD>" skip
                    "<TD>" ttmps.sum "</TD>" skip
                    "<TD>" ttmps.npl "</TD>" skip
                    "<TD>" string(ttmps.tim, "HH:MM:SS") "</TD></TR>" skip.
end.
put unformatted "<TR><TD  bgcolor=""#95B2D1""><B>ИТОГО " v-whole "</B></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD>" skip
                    "<TD  bgcolor=""#95B2D1""></TD></TR>" skip.

put unformatted "</TABLE>" skip.
{html-end.i}
output close.
unix silent value("cptwin timekasx.htm excel").
pause 0.
