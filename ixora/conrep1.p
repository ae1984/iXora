/* conrep1.p
 * MODULE
       Департамент Регионального Развития
 * DESCRIPTION
       Отчет о займах и ставках вознаграждениях по ним для НБРК по просьбе ДПК
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        14/12/04 kanat
 * CHANGES
*/

{global.i}
{get-dep.i}
{comm-txb.i}

def var ourbank as char.
def var ourcode as integer.

ourbank = comm-txb().
ourcode = comm-cod().

def var v-depcode as integer.

define temp-table ttmps1 like commonpl
    field dep as int.

define temp-table ttmps2 like tax
    field dep as int.

define temp-table ttmps3 like p_f_payment
    field dep as int.

define temp-table ttmps4 like commonpl
    field dep as int.

def var v-date-begin as date.
def var v-date-fin   as date.
def var v-mname as char.

def var v-com-sum as decimal extent 4.
def var v-comw-sum as decimal extent 4.
def var v-com-count as decimal.
def var v-comw-count as decimal.

def var v-tax-sum as decimal extent 4.
def var v-taxw-sum as decimal extent 4.
def var v-tax-count as decimal.
def var v-taxw-count as decimal.

def var v-pen-sum as decimal extent 4.
def var v-penw-sum as decimal extent 4.
def var v-pen-count as decimal.
def var v-penw-count as decimal.

def var v-kgp-sum as decimal extent 4.
def var v-kgpw-sum as decimal extent 4.
def var v-kgp-count as decimal.
def var v-kgpw-count as decimal.

v-date-begin = g-today.
v-date-fin = g-today.

def new shared frame opt 
        v-date-begin   label  "Дата начала периода"    validate (v-date-begin <= g-today, " Дата не может быть больше текущей! ") skip 
        v-date-fin     label  "Дата конца периода"    validate (v-date-fin <= g-today, " Дата не может быть больше текущей! ") skip 
        with row 8 centered color messages side-labels title "Займы и ставки вознаграждения по ним (ДПК)".

update v-date-begin
       v-date-fin 
       with frame opt.
hide frame opt.

displ "Идет обработка данных для отчета ... " skip.

/* public payments' amounts calculating block ... */

displ "Идет обработка коммунальных платежей ... " skip.

for each commonpl where commonpl.txb = ourcode and 
                        commonpl.date >= v-date-begin and 
                        commonpl.date <= v-date-fin and
                        commonpl.arp <> "010904103" and
                        commonpl.joudoc <> ? and
                        commonpl.deluid = ? no-lock use-index date:

v-depcode = get-dep(commonpl.uid, commonpl.date).
   create ttmps1.
   buffer-copy commonpl to ttmps1.
   ttmps1.dep = v-depcode.
end.


/* tax payments' amounts calculating block ...  */

displ "Идет обработка налоговых платежей ... " skip.

for each tax where tax.txb = ourcode and 
                   tax.date >= v-date-begin and 
                   tax.date <= v-date-fin and
                   tax.taxdoc <> ? and
                   tax.duid = ? no-lock:

v-depcode = get-dep(tax.uid, tax.date).

   create ttmps2.
   buffer-copy tax to ttmps2.
   ttmps2.dep = get-dep(tax.uid, tax.date).
end.


/* pension payments' amount calculating block ... */

displ "Идет обработка пенсионных платежей ... " skip.

for each p_f_payment where p_f_payment.txb = ourcode and 
                           p_f_payment.date >= v-date-begin and 
                           p_f_payment.date <= v-date-fin and
                           p_f_payment.stcif >= 1 and 
                           p_f_payment.deluid = ? no-lock:

v-depcode = get-dep(p_f_payment.uid, p_f_payment.date).
   create ttmps3.
   buffer-copy p_f_payment to ttmps3.
   ttmps3.dep = get-dep(p_f_payment.uid, p_f_payment.date).
end.


/* public payments' amounts calculating block (КГП ЦИС) ... */

displ "Идет обработка платежей КГП ЦИС ... " skip.

for each commonpl where commonpl.txb = ourcode and 
                        commonpl.date >= v-date-begin and 
                        commonpl.date <= v-date-fin and
                        commonpl.arp = "010904103" and
                        commonpl.joudoc <> ? and
                        commonpl.deluid = ? no-lock use-index date:

v-depcode = get-dep(commonpl.uid, commonpl.date).
   create ttmps4.
   buffer-copy commonpl to ttmps4.
   ttmps4.dep = get-dep(commonpl.uid, commonpl.date).
end.


displ "Идет подготовка данных для отчета ... " skip.

output to glreport1.htm.
{html-start.i}

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then
v-mname = ofc.name.
else do:
message "Неверный логин менеджера" view-as alert-box title "Внимание".
return.
end.

put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT color = ""#333399"" size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "Отчет по принятым налоговым, коммунальным и пенсионным платежам <BR> c " string(v-date-begin) " по " string(v-date-fin) "<BR> (в тенге, по структурным подразделениям) </FONT></P></B><BR><BR>" skip
   "<B>Исполнитель: </B>" v-mname ". <BR>" skip
   "<B>Дата: </B>" string(g-today) ". <BR>" skip
   "<B>Время: </B>" string(time,"HH:MM:SS") ". <BR>" skip.

put unformatted
   "<B><P align = ""center""><FONT color = ""#333399"" size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   " Коммунальные платежи (Станции диагностики) </FONT></P></B><BR>" skip.

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR bgcolor=""#95B2D1"" align=""center"" valign=""top"">" skip
     "<TD><B>Структурное подразделение</B></FONT></TD>" skip
     "<TD><B>Количество</B></FONT></TD>" skip
     "<TD><B>Сумма (ЮЛ)</B></FONT></TD>" skip
     "<TD><B>Комиссия (ЮЛ)</B></FONT></TD>" skip
     "<TD><B>Сумма (ФЛ)</B></FONT></TD>" skip
     "<TD><B>Комиссия (ФЛ)</B></FONT></TD>" skip
   "</TR>".                            

/* Коммунальные платежи ... */

for each ttmps1 no-lock break by ttmps1.dep.

if first-of (ttmps1.dep) then do:
find first ppoint where ppoint.depart = ttmps1.dep no-lock no-error.
put unformatted "<TR bgcolor=""#95B2D1"">" skip
                "<TD><B>" ppoint.name "</B></TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD></TR>" skip.
end.

find first rnn where rnn.trn = ttmps1.rnn no-lock no-error.
if avail rnn then do:
v-com-sum[1] = v-com-sum[1] + ttmps1.sum.
v-com-sum[2] = v-com-sum[2] + ttmps1.comsum.
end.

if ttmps1.rnn = "000000000000" then do:
v-com-sum[1] = v-com-sum[1] + ttmps1.sum.
v-com-sum[2] = v-com-sum[2] + ttmps1.comsum.
end.

find first rnnu where rnnu.trn = ttmps1.rnn no-lock no-error.
if avail rnnu then do:
v-com-sum[3] = v-com-sum[3] + ttmps1.sum.
v-com-sum[4] = v-com-sum[4] + ttmps1.comsum.
end.

v-com-count = v-com-count + 1.

if last-of (ttmps1.dep) then do:
put unformatted "<TR>" skip
                "<TD></TD>" skip
                "<TD>" v-com-count "</TD>" skip
                "<TD>" v-com-sum[1] "</TD>" skip
                "<TD>" v-com-sum[2] "</TD>" skip
                "<TD>" v-com-sum[3] "</TD>" skip
                "<TD>" v-com-sum[4] "</TD></TR>" skip.

       v-comw-sum[1] = v-comw-sum[1] + v-com-sum[1].
       v-comw-sum[2] = v-comw-sum[2] + v-com-sum[2].
       v-comw-sum[3] = v-comw-sum[3] + v-com-sum[3].
       v-comw-sum[4] = v-comw-sum[4] + v-com-sum[4].
       v-comw-count  = v-comw-count + v-com-count.

assign v-com-sum[1] = 0
       v-com-sum[2] = 0
       v-com-sum[3] = 0
       v-com-sum[4] = 0
       v-com-count  = 0.
end.
end. /* for each ttmps1 ... */

put unformatted "<TR bgcolor=""#95B2D1"">" skip
                "<TD><B>  ИТОГО </B></TD>" skip
                "<TD><B>" v-comw-count "</B></TD>" skip
                "<TD><B>" v-comw-sum[1] "</B></TD>" skip
                "<TD><B>" v-comw-sum[2] "</B></TD>" skip
                "<TD><B>" v-comw-sum[3] "</B></TD>" skip
                "<TD><B>" v-comw-sum[4] "</B></TD></TR>" skip.

put unformatted "</TABLE>" skip.
put unformatted "<BR>" skip.

/* Налоговые платежи ... */

put unformatted
   "<B><P align = ""center""><FONT color = ""#333399"" size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   " Налоговые платежи </FONT></P></B><BR>" skip.

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR bgcolor=""#95B2D1"" align=""center"" valign=""top"">" skip
     "<TD><B>Структурное подразделение</B></FONT></TD>" skip
     "<TD><B>Количество</B></FONT></TD>" skip
     "<TD><B>Сумма (ЮЛ)</B></FONT></TD>" skip
     "<TD><B>Комиссия (ЮЛ)</B></FONT></TD>" skip
     "<TD><B>Сумма (ФЛ)</B></FONT></TD>" skip
     "<TD><B>Комиссия (ФЛ)</B></FONT></TD>" skip
   "</TR>".                            


for each ttmps2 no-lock break by ttmps2.dep.

if first-of (ttmps2.dep) then do:
find first ppoint where ppoint.depart = ttmps2.dep no-lock no-error.
put unformatted "<TR bgcolor=""#95B2D1"">" skip
                "<TD><B>" ppoint.name "</B></TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD></TR>" skip.
end.

find first rnn where rnn.trn = ttmps2.rnn no-lock no-error.
if avail rnn then do:
v-tax-sum[1] = v-tax-sum[1] + ttmps2.sum.
v-tax-sum[2] = v-tax-sum[2] + ttmps2.comsum.
end.

if ttmps2.rnn = "000000000000" then do:
v-tax-sum[1] = v-tax-sum[1] + ttmps2.sum.
v-tax-sum[2] = v-tax-sum[2] + ttmps2.comsum.
end.

find first rnnu where rnnu.trn = ttmps2.rnn no-lock no-error.
if avail rnnu then do:
v-tax-sum[3] = v-tax-sum[3] + ttmps2.sum.
v-tax-sum[4] = v-tax-sum[4] + ttmps2.comsum.
end.

v-tax-count = v-tax-count + 1.

if last-of (ttmps2.dep) then do:
put unformatted "<TR>" skip
                "<TD></TD>" skip
                "<TD>" v-tax-count "</TD>" skip
                "<TD>" v-tax-sum[1] "</TD>" skip
                "<TD>" v-tax-sum[2] "</TD>" skip
                "<TD>" v-tax-sum[3] "</TD>" skip
                "<TD>" v-tax-sum[4] "</TD></TR>" skip.

       v-taxw-sum[1] = v-taxw-sum[1] + v-tax-sum[1].
       v-taxw-sum[2] = v-taxw-sum[2] + v-tax-sum[2].
       v-taxw-sum[3] = v-taxw-sum[3] + v-tax-sum[3].
       v-taxw-sum[4] = v-taxw-sum[4] + v-tax-sum[4].
       v-taxw-count  = v-taxw-count + v-tax-count.

assign v-tax-sum[1] = 0
       v-tax-sum[2] = 0
       v-tax-sum[3] = 0
       v-tax-sum[4] = 0
       v-tax-count  = 0.
end.
end. /* for each ttmps2 ... */

put unformatted "<TR bgcolor=""#95B2D1"">" skip
                "<TD><B>  ИТОГО </B></TD>" skip
                "<TD><B>" v-taxw-count "</B></TD>" skip
                "<TD><B>" v-taxw-sum[1] "</B></TD>" skip
                "<TD><B>" v-taxw-sum[2] "</B></TD>" skip
                "<TD><B>" v-taxw-sum[3] "</B></TD>" skip
                "<TD><B>" v-taxw-sum[4] "</B></TD></TR>" skip.

put unformatted "</TABLE>" skip.
put unformatted "<BR>" skip.


/* Пенсионные платежи */

put unformatted
   "<B><P align = ""center""><FONT color = ""#333399"" size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   " Пенсионные платежи </FONT></P></B><BR>" skip.

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR bgcolor=""#95B2D1"" align=""center"" valign=""top"">" skip
     "<TD><B>Структурное подразделение</B></FONT></TD>" skip
     "<TD><B>Количество</B></FONT></TD>" skip
     "<TD><B>Сумма (ЮЛ)</B></FONT></TD>" skip
     "<TD><B>Комиссия (ЮЛ)</B></FONT></TD>" skip
     "<TD><B>Сумма (ФЛ)</B></FONT></TD>" skip
     "<TD><B>Комиссия (ФЛ)</B></FONT></TD>" skip
   "</TR>".                            


for each ttmps3 no-lock break by ttmps3.dep.

if first-of (ttmps3.dep) then do:
find first ppoint where ppoint.depart = ttmps3.dep no-lock no-error.
put unformatted "<TR bgcolor=""#95B2D1"">" skip
                "<TD><B>" ppoint.name "</B></TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD></TR>" skip.
end.

find first rnn where rnn.trn = ttmps3.rnn no-lock no-error.
if avail rnn then do:
v-pen-sum[1] = v-pen-sum[1] + ttmps3.amt.
v-pen-sum[2] = v-pen-sum[2] + ttmps3.comiss.
end.

if ttmps3.rnn = "000000000000" then do:
v-pen-sum[1] = v-pen-sum[1] + ttmps3.amt.
v-pen-sum[2] = v-pen-sum[2] + ttmps3.comiss.
end.

find first rnnu where rnnu.trn = ttmps3.rnn no-lock no-error.
if avail rnnu then do:
v-pen-sum[3] = v-pen-sum[3] + ttmps3.amt.
v-pen-sum[4] = v-pen-sum[4] + ttmps3.comiss.
end.

v-pen-count = v-pen-count + 1.

if last-of (ttmps3.dep) then do:
put unformatted "<TR>" skip
                "<TD></TD>" skip
                "<TD>" v-pen-count "</TD>" skip
                "<TD>" v-pen-sum[1] "</TD>" skip
                "<TD>" v-pen-sum[2] "</TD>" skip
                "<TD>" v-pen-sum[3] "</TD>" skip
                "<TD>" v-pen-sum[4] "</TD></TR>" skip.

       v-penw-sum[1] = v-penw-sum[1] + v-pen-sum[1].
       v-penw-sum[2] = v-penw-sum[2] + v-pen-sum[2].
       v-penw-sum[3] = v-penw-sum[3] + v-pen-sum[3].
       v-penw-sum[4] = v-penw-sum[4] + v-pen-sum[4].
       v-penw-count  = v-penw-count + v-pen-count.

assign v-pen-sum[1] = 0
       v-pen-sum[2] = 0
       v-pen-sum[3] = 0
       v-pen-sum[4] = 0
       v-pen-count  = 0.
end.
end. /* for each ttmps3 ... */

put unformatted "<TR bgcolor=""#95B2D1"">" skip
                "<TD><B>  ИТОГО </B></TD>" skip
                "<TD><B>" v-penw-count "</B></TD>" skip
                "<TD><B>" v-penw-sum[1] "</B></TD>" skip
                "<TD><B>" v-penw-sum[2] "</B></TD>" skip
                "<TD><B>" v-penw-sum[3] "</B></TD>" skip
                "<TD><B>" v-penw-sum[4] "</B></TD></TR>" skip.

put unformatted "</TABLE>" skip.
put unformatted "<BR>" skip.


/* Платежи КГП ЦИС */

put unformatted
   "<B><P align = ""center""><FONT color = ""#333399"" size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   " Платежи КГП ЦИС </FONT></P></B><BR>" skip.

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR bgcolor=""#95B2D1"" align=""center"" valign=""top"">" skip
     "<TD><B>Структурное подразделение</B></FONT></TD>" skip
     "<TD><B>Количество</B></FONT></TD>" skip
     "<TD><B>Сумма (ЮЛ)</B></FONT></TD>" skip
     "<TD><B>Комиссия (ЮЛ)</B></FONT></TD>" skip
     "<TD><B>Сумма (ФЛ)</B></FONT></TD>" skip
     "<TD><B>Комиссия (ФЛ)</B></FONT></TD>" skip
   "</TR>".                            


for each ttmps4 no-lock break by ttmps4.dep.

if first-of (ttmps4.dep) then do:
find first ppoint where ppoint.depart = ttmps4.dep no-lock no-error.
put unformatted "<TR bgcolor=""#95B2D1"">" skip
                "<TD><B>" ppoint.name "</B></TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD>" skip
                "<TD>" "</TD></TR>" skip.
end.

find first rnn where rnn.trn = ttmps4.rnn no-lock no-error.
if avail rnn then do:
v-kgp-sum[1] = v-kgp-sum[1] + ttmps4.sum.
v-kgp-sum[2] = v-kgp-sum[2] + ttmps4.comsum.
end.

if ttmps4.rnn = "000000000000" then do:
v-kgp-sum[1] = v-kgp-sum[1] + ttmps4.sum.
v-kgp-sum[2] = v-kgp-sum[2] + ttmps4.comsum.
end.

find first rnnu where rnnu.trn = ttmps4.rnn no-lock no-error.
if avail rnnu then do:
v-kgp-sum[3] = v-kgp-sum[3] + ttmps4.sum.
v-kgp-sum[4] = v-kgp-sum[4] + ttmps4.comsum.
end.

v-kgp-count = v-kgp-count + 1.

if last-of (ttmps4.dep) then do:
put unformatted "<TR>" skip
                "<TD></TD>" skip
                "<TD>" v-kgp-count "</TD>" skip
                "<TD>" v-kgp-sum[1] "</TD>" skip
                "<TD>" v-kgp-sum[2] "</TD>" skip
                "<TD>" v-kgp-sum[3] "</TD>" skip
                "<TD>" v-kgp-sum[4] "</TD></TR>" skip.

       v-kgpw-sum[1] = v-kgpw-sum[1] + v-kgp-sum[1].
       v-kgpw-sum[2] = v-kgpw-sum[2] + v-kgp-sum[2].
       v-kgpw-sum[3] = v-kgpw-sum[3] + v-kgp-sum[3].
       v-kgpw-sum[4] = v-kgpw-sum[4] + v-kgp-sum[4].
       v-kgpw-count  = v-kgpw-count + v-kgp-count.

assign v-kgp-sum[1] = 0
       v-kgp-sum[2] = 0
       v-kgp-sum[3] = 0
       v-kgp-sum[4] = 0
       v-kgp-count  = 0.
end.
end. /* for each ttmps3 ... */

put unformatted "<TR bgcolor=""#95B2D1"">" skip
                "<TD><B>  ИТОГО </B></TD>" skip
                "<TD><B>" v-kgpw-count "</B></TD>" skip
                "<TD><B>" v-kgpw-sum[1] "</B></TD>" skip
                "<TD><B>" v-kgpw-sum[2] "</B></TD>" skip
                "<TD><B>" v-kgpw-sum[3] "</B></TD>" skip
                "<TD><B>" v-kgpw-sum[4] "</B></TD></TR>" skip.

put unformatted "</TABLE>" skip.
put unformatted "<BR>" skip.


{html-end.i}
output close.
unix silent value("cptwin glreport1.htm excel").
pause 0.

