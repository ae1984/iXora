/* omprep1.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Отчет по принимаемым платежам КГП ЦИС
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
        01/06/2005 kanat
 * CHANGES
*/

{global.i}
{get-dep.i}
{comm-txb.i}

def var seltxb as int.
seltxb = comm-cod().

def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def var v-depcode as integer.

define temp-table ttmps like commonpl
    field dep as int.

define var v-date-begin as date.
define var v-date-fin   as date.
def var v-mname as char.

v-date-begin = g-today.
v-date-fin = v-date-begin.

def frame opt 
    v-date-begin label "Введите период с "
    v-date-fin   label " по " 
    with row 8 centered side-labels title " Отчет по видам платежей ОМП ".

update v-date-begin
       v-date-fin
       with frame opt.
hide frame opt.

{comm-sel.i}

for each commonpl where commonpl.txb = ourcode and 
                        commonpl.date >= v-date-begin and 
                        commonpl.date <= v-date-fin and
                        commonpl.arp = selarp and
                        commonpl.joudoc <> ? and
                        commonpl.deluid = ? no-lock:
v-depcode = get-dep(commonpl.uid, commonpl.date).
find first ppoint where ppoint.depart = v-depcode and ppoint.name matches "*ОМП*" no-lock no-error.
if avail ppoint then do:
   create ttmps.
   buffer-copy commonpl to ttmps.
   ttmps.dep = get-dep(commonpl.uid, commonpl.date).
   end.
end.

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
   "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   " Платежи (" selbn ") в ОМП <BR> c " string(v-date-begin) " по " string(v-date-fin) " (в тенге)</FONT></P></B><BR>" 
   "<B>Исполнитель: </B>" v-mname ". <BR>" skip
   "<B>Дата: </B>" string(g-today) ". <BR>" skip
   "<B>Время: </B>" string(time,"HH:MM:SS") ". <BR><BR>" skip.

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR bgcolor=""#95B2D1"" align=""center"" valign=""top"">" skip
     "<TD><B>Подразделение</B></FONT></TD>" skip
     "<TD><B>Тип платежей</B></FONT></TD>" skip
     "<TD><B>Количество</B></FONT></TD>" skip
     "<TD><B>Сумма</B></FONT></TD>" skip
     "<TD><B>Комиссия</B></FONT></TD>" skip
   "</TR>".                            

for each ttmps no-lock break by ttmps.dep by ttmps.type.

accumulate ttmps.sum (sub-total by ttmps.dep).
accumulate ttmps.sum (sub-count by ttmps.dep).
accumulate ttmps.comsum (sub-total by ttmps.dep).

accumulate ttmps.sum (sub-total by ttmps.type).
accumulate ttmps.sum (sub-count by ttmps.type).
accumulate ttmps.comsum (sub-total by ttmps.type).

accumulate ttmps.sum (total).
accumulate ttmps.sum (count).
accumulate ttmps.comsum (total).

if first-of (ttmps.dep) then do:
find first ppoint where ppoint.depart = ttmps.dep no-lock no-error.
put unformatted "<TR bgcolor=""#95B2D1""><TD><B>" ppoint.name "<B></TD>" skip
                    "<TD><B></B></TD>" skip
                    "<TD><B></B></TD>" skip
                    "<TD><B></B></TD>" skip
                    "<TD><B></B></TD></TR>" skip.
end.


if last-of (ttmps.type) then do:
find first commonls where commonls.txb = ourcode and 
                          commonls.type = ttmps.type and 
                          commonls.arp = ttmps.arp and 
                          commonls.grp = ttmps.grp and
                          commonls.visible no-lock no-error.
put unformatted     "<TR><TD></TD>" skip     
                    "<TD>" commonls.npl "</TD>" skip
                    "<TD>" (accum sub-count by ttmps.type ttmps.sum) format ">>>,>>>,>>>,>>9.99" "</TD>" skip
                    "<TD>" (accum sub-total by ttmps.type ttmps.sum) format ">>>,>>>,>>>,>>9.99" "</TD>" skip
                    "<TD>" (accum sub-total by ttmps.type ttmps.comsum) format ">>>,>>>,>>>,>>9.99" "</TD></TR>" skip.
end.


if last-of (ttmps.dep) then do:
put unformatted     "<TR><TD></TD>" skip     
                    "<TD><B>  ИТОГО  </B></TD>" skip
                    "<TD><B>" (accum sub-count by ttmps.dep  ttmps.sum) format ">>>,>>>,>>>,>>9.99" "</B></TD>" skip
                    "<TD><B>" (accum sub-total by ttmps.dep  ttmps.sum) format ">>>,>>>,>>>,>>9.99" "</B></TD>" skip
                    "<TD><B>" (accum sub-total by ttmps.dep  ttmps.comsum) format ">>>,>>>,>>>,>>9.99" "</B></TD></TR>" skip.
end.
end.                


put unformatted     "<TR bgcolor=""#95B2D1""><TD></TD>" skip     
                    "<TD><B>  ВСЕГО  </B></TD>" skip
                    "<TD><B>" (accum count ttmps.sum) format ">>>,>>>,>>>,>>9.99" "</B></TD>" skip
                    "<TD><B>" (accum total ttmps.sum) format ">>>,>>>,>>>,>>9.99" "</B></TD>" skip
                    "<TD><B>" (accum total ttmps.comsum) format ">>>,>>>,>>>,>>9.99" "</B></TD></TR>" skip.

put unformatted "</TABLE>" skip.
{html-end.i}
output close.
unix silent value("cptwin glreport1.htm excel").
pause 0.

