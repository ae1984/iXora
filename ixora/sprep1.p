/* sprep1.p
 * MODULE
        Платежи без открытия счетов
 * DESCRIPTION
        Отчет по платежам, принятым со льготными тарифами
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        14.02.2005 kanat
 * CHANGES
        19/03/2005 kanat - добавил доп. условие в запрос по группам платежей
*/                                      

{global.i}
{comm-txb.i}
{yes-no.i}
{get-dep.i}

define variable seltxb as integer.
seltxb = comm-cod().

def var v-date-begin as date.
def var v-date-fin as date.
def var v-count as integer init 1.

def var v-dep-code as integer.
def var v-dep-name as char.
def var v-mname as char.

def var v-mount as decimal extent 5 init 0.

def var v-report-name as char.

v-date-begin = g-today.
v-date-fin = v-date-begin.

update v-date-begin label "Начальная дата отчета " v-date-fin label " Конечная дата отчета" with centered side-label frame frame_for_find.
hide frame frame_for_find.

find first cmp no-lock no-error.

   v-dep-code = get-dep(g-ofc, g-today). 
   find first ppoint where ppoint.depart = v-dep-code no-lock no-error. 
   if avail ppoint then 
   v-dep-name = ppoint.name.
   else do:
   v-dep-name = "Неверный департамент".
   message "Неверный департамент" view-as alert-box title "Внимание".
   return.
   end.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then 
   v-mname = ofc.name.
else do:
   v-mname = "Неизвестный офицер".
   message "Неизвестный офицер" view-as alert-box title "Внимание".
   return.
end.


output to contrep2.htm.
{html-start.i}

put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip.

v-report-name = "Реестр принятых льготных платежей (с участников ВОВ)".

if v-date-begin < v-date-fin then 
put unformatted v-report-name " с " string(v-date-begin) " по " string(v-date-fin) " </FONT></P></B><BR>" skip.

if v-date-begin = v-date-fin then
put unformatted v-report-name " за " string(v-date-begin) " </FONT></P></B><BR>" skip.

put unformatted
   "<B>Исполнитель: </B>" v-mname ". <BR>" skip
   "<B>Дата: </B>" string(g-today) ". <BR>" skip
   "<B>Время: </B>" string(time,"HH:MM:SS") ". <BR><BR>" skip.

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip
     "<TD  bgcolor=""#95B2D1""><B>N</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Номер квитанции</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Дата</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>РНН</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>ФИО</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Номер удостоверения ветерана ВОВ и дата выдачи</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Сумма</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Комиссия</B></FONT></TD>" skip
   "</TR>".                            

v-count = 0.

   put unformatted 
    " <TR>" skip
              "<TD><B> Налоговые платежи </B></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
    " </TR>" skip.

/*налоговые*/
for each tax where tax.txb = seltxb and 
                   tax.date >= v-date-begin and 
                   tax.date <= v-date-fin and 
                   tax.duid = ? no-lock.
if tax.chval[2] <> "" then do: 
v-count = v-count + 1.
   put unformatted 
    " <TR>" skip
              "<TD>" string(v-count) "</TD>" skip
              "<TD>" string(tax.dnum) "</TD>" skip
              "<TD>" string(tax.date) "</TD>" skip
              "<TD>[" tax.rnn "]</TD>" skip
              "<TD>" tax.chval[1] "</TD>" skip
              "<TD>" tax.chval[2] "</TD>" skip
              "<TD>" string(tax.sum) "</TD>" skip
              "<TD>" string(tax.comsum) "</TD>" skip
    " </TR>" skip.
end.
end.

   put unformatted 
    " <TR bgcolor=""#95B2D1"">" skip
              "<TD><B> ИТОГО: </B></TD>" skip
              "<TD><B>" string(v-count) "</B></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
    " </TR>" skip.

   put unformatted 
    " <TR>" skip
              "<TD><B> Коммунальные платежи и станции диагностики </B></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
    " </TR>" skip.

v-count = 0.

/*станции диагностики*/
for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= v-date-begin and
                        commonpl.date <= v-date-fin and 
                        commonpl.deluid = ? and 
                       (commonpl.grp = 1 or 
                        commonpl.grp = 3 or 
                        commonpl.grp = 4 or 
                        commonpl.grp = 5 or  
                        commonpl.grp = 6 or 
                        commonpl.grp = 7 or 
                        commonpl.grp = 8) no-lock.

if (commonpl.info[3] <> "" and commonpl.comsum = 0) or 
   (commonpl.comsum = 1) then do: 

find first commonls where commonls.txb = seltxb and 
                          commonls.visible = yes and 
                          commonls.grp = commonpl.grp and 
                          commonls.arp = commonpl.arp and 
                          commonls.type = commonpl.type no-lock no-error.
if avail commonls then do:  
v-count = v-count + 1.
   put unformatted 
    " <TR>" skip
              "<TD>" string(v-count) "</TD>" skip
              "<TD>" string(commonpl.dnum) "</TD>" skip
              "<TD>" string(commonpl.date) "</TD>" skip
              "<TD>[" commonpl.rnn "]</TD>" skip
              "<TD>" commonpl.fio "</TD>" skip
              "<TD>" commonpl.info[3] "</TD>" skip
              "<TD>" string(commonpl.sum) "</TD>" skip
              "<TD>" string(commonpl.comsum) "</TD>" skip
    " </TR>" skip.
end.
end.
end.

   put unformatted 
    " <TR bgcolor=""#95B2D1"">" skip
              "<TD><B> ИТОГО: </B></TD>" skip
              "<TD><B>" string(v-count) "</B></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
    " </TR>" skip.


   put unformatted 
    " <TR>" skip
              "<TD><B> Прочие платежи </B></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
    " </TR>" skip.

v-count = 0.

/*станции диагностики*/
for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= v-date-begin and
                        commonpl.date <= v-date-fin and 
                        commonpl.deluid = ? and 
                        commonpl.grp = 9 no-lock.
if commonpl.info[5] <> "" then do:
find first commonls where commonls.txb = seltxb and 
                          commonls.visible = yes and 
                          commonls.grp = commonpl.grp and 
                          commonls.arp = commonpl.arp and 
                          commonls.type = commonpl.type no-lock no-error.
if avail commonls then do:  
v-count = v-count + 1.
   put unformatted 
    " <TR>" skip
              "<TD>" string(v-count) "</TD>" skip
              "<TD>" string(commonpl.dnum) "</TD>" skip
              "<TD>" string(commonpl.date) "</TD>" skip
              "<TD>[" commonpl.rnn "]</TD>" skip
              "<TD>" commonpl.fio "</TD>" skip
              "<TD>" commonpl.info[5] "</TD>" skip
              "<TD>" string(commonpl.sum) "</TD>" skip
              "<TD>" string(commonpl.comsum) "</TD>" skip
    " </TR>" skip.
end.
end.
end.

   put unformatted 
    " <TR bgcolor=""#95B2D1"">" skip
              "<TD><B> ИТОГО: </B></TD>" skip
              "<TD><B>" string(v-count) "</B></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
              "<TD></TD>" skip
    " </TR>" skip.

put unformatted "</TABLE>" skip.
{html-end.i}
output close.
unix silent value("cptwin contrep2.htm excel").
pause 0.





