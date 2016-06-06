/* kvitrep.p
 * MODULE
        Коммунальные и налоговые платежи
 * DESCRIPTION
        Отчет по неверным ФИО в квитанциях
 * RUN
        
 * CALLER
        import.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        20/09/2004 kanat  
 * CHANGES
        27/09/2004 kanat - добавил дополнительное условие для квитанций станций диагностик
*/

{global.i}
{comm-txb.i}
{gl-utils.i}
{get-dep.i}

def var seltxb as int.
seltxb = comm-cod().

def var v-date-begin as date.
def var v-date-fin as date.

def var v-manager-name as char.
def var v-dep-name as char.
def var cnt as integer.
def var v-mname as char.
def var v-dep as integer.

cnt = get-dep(g-ofc, g-today).

find first ppoint where ppoint.depart = cnt no-lock no-error.
if avail ppoint then
v-dep-name = ppoin.name.

find first cmp no-lock no-error.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then 
   v-mname = ofc.name.
else do:
   message "Неизвестный офицер" view-as alert-box title "Внимание".
   return.
end.

v-date-begin = today.
v-date-fin = v-date-begin.

form skip(1)
v-date-begin   format "99/99/99" label " Начало периода" skip
v-date-fin     format "99/99/99" label " Конец периода " skip(1)
with row 6 side-label centered title " Реестр квитанций с неверными ФИО " color messages frame report_frame.

displ v-date-begin v-date-fin with frame report_frame.
update v-date-begin v-date-fin with frame report_frame.

message "Формируются данные для отчета ... ".

output to uchet.htm.
{html-start.i}
put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip.

if v-date-begin = v-date-fin then do:
put unformatted 
   "Реестр квитанций с неверными ФИО за " v-date-begin "</FONT><BR>" skip
   "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><BR>".
end.

if v-date-begin < v-date-fin then do:
put unformatted 
   "Реестр квитанций с неверными ФИО c " v-date-begin " по " v-date-fin "</FONT><BR>" skip
   "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><BR>".
end.

if v-date-begin > v-date-fin then do:
message "Указан неверный период" view-as alert-box title "Внимание".
return.
end.

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip
   "<B>Исполнитель: </B>" v-mname ". <BR>" skip
   "<B>Дата: </B>" string(g-today) ". <BR>" skip
   "<B>Время: </B>" string(time,"HH:MM:SS") ". <BR><BR>" skip(1).

put unformatted
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Номер квит.</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Дата</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Фамилия кассира</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>РНН отправителя</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Тип платежа</B></FONT></TD>" skip
   "</TR>".                            

for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= v-date-begin and 
                        commonpl.date <= v-date-fin and 
                        commonpl.deluid = ? and
                        commonpl.grp <> 3 and 
                        commonpl.grp <> 4 and 
                        commonpl.grp <> 5 and 
                        commonpl.grp <> 6 and 
                        commonpl.grp <> 7 and 
                        commonpl.grp <> 8 and  
                        trim(commonpl.fio) = '' no-lock.

find first commonls where commonls.txb = seltxb and commonls.grp = commonpl.grp and commonpl.type = commonls.type and 
                          commonls.visible = yes no-lock no-error.
if avail commonls then do:

find first ofc where ofc.ofc = commonpl.uid no-lock no-error.
v-dep = get-dep(commonpl.uid, commonpl.date).
find first ppoint where ppoint.depart = v-dep no-lock no-error.
put unformatted "<TR><TD>" commonpl.dnum "</TD>" skip
                    "<TD>" commonpl.date "</TD>" skip
                    "<TD>" ofc.name "</TD>" skip
                    "<TD>`" commonpl.rnn "</TD>" skip
                    "<TD>" XLS-NUMBER(commonpl.sum) "</TD>" 
                    "<TD>" commonls.bn "</TD></TR>" skip.
end.
end.


for each tax where tax.txb = seltxb and 
                   tax.date >= v-date-begin and 
                   tax.date <= v-date-fin and 
                   tax.duid = ? and 
                   trim(replace(commonpl.chval[1],',','')) = '' no-lock.

find first ofc where ofc.ofc = tax.uid no-lock no-error.
v-dep = get-dep(tax.uid, tax.date).
find first ppoint where ppoint.depart = v-dep no-lock no-error.
put unformatted "<TR><TD>" tax.dnum "</TD>" skip
                    "<TD>" tax.date "</TD>" skip
                    "<TD>" ofc.name "</TD>" skip
                    "<TD>`" tax.rnn "</TD>" skip
                    "<TD>" XLS-NUMBER(tax.sum) "</TD>"
                    "<TD> Налоговые платежи </TD></TR>" skip.
end.

for each p_f_payment where p_f_payment.txb = seltxb and 
                           p_f_payment.date >= v-date-begin and 
                           p_f_payment.date <= v-date-fin and 
                           p_f_payment.deluid = ? and 
                           trim(p_f_payment.name) = '' no-lock.

find first ofc where ofc.ofc = p_f_payment.uid no-lock no-error.
v-dep = get-dep(p_f_payment.uid, p_f_payment.date).
find first ppoint where ppoint.depart = v-dep no-lock no-error.
put unformatted "<TR><TD>" p_f_payment.dnum "</TD>" skip
                    "<TD>" p_f_payment.date "</TD>" skip
                    "<TD>" ofc.name "</TD>" skip
                    "<TD>`" p_f_payment.rnn "</TD>" skip
                    "<TD>" XLS-NUMBER(p_f_payment.amt) "</TD>" 
                    "<TD> Пенсионные платежи </TD></TR>" skip.
end.
output close.
unix silent value("cptwin uchet.htm excel").
pause 0.


