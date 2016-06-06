/* otrwhl.p
 * MODULE
        Коммунальный модуль
 * DESCRIPTION
        Реестр платежей по реквизитам прочих платежей
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
        02/09/04 kanat
 * CHANGES
        10/09/04 kanat - добавил КНП и КБК в вывод отчета
*/

{global.i}
{comm-txb.i}
{gl-utils.i}
{get-dep.i}

def var seltxb as int.
seltxb = comm-cod().

def var v-date-begin as date.
def var v-date-fin as date.
def var v-benef as char.
def var d_sum as decimal.

def var v-manager-name as char.
def var v-dep-name as char.
def var cnt as integer.
def var v-mname as char.
def var v-count as integer.

def var rid as rowid.

def var v-iik as char format "x(9)".
def var v-bik like commonls.bik.
def var v-kbk like commonls.kbk.
def var v-rnnbn like commonls.rnn.
def var v-docbn like commonls.bn. 
def var v-type  like commonls.type.

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
v-benef        format "x(45)"      label " Наименование организации " help "F2 - ВЫБОР" skip
with row 6 side-label centered title " Реестр прочих платежей по организациям " color messages frame report_frame.

    on help of v-benef in frame report_frame do:
        run ChooseType.
    end.

displ v-date-begin v-date-fin v-benef with frame report_frame.
update v-date-begin v-date-fin v-benef with frame report_frame.

message "Формируются данные для реестра ... ".

output to drpr.htm.
{html-start.i}
put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip.

if v-date-begin = v-date-fin then do:
put unformatted 
   "Реестр прочих платежей " v-benef " за " v-date-begin "</FONT><BR>" skip
   "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><BR>".
end.

if v-date-begin < v-date-fin then do:
put unformatted 
   "Реестр прочих платежей " v-benef " c " v-date-begin " по " v-date-fin "</FONT><BR>" skip
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
   "<B>Время: </B>" string(time,"HH:MM:SS") ". <BR><BR>" skip.

put unformatted
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>N</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Дата</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Номер платежного поручения</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>РНН отправителя</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>ФИО</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>КНП</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>КБК</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
   "</TR>".                            

v-count = 1.

for each commonpl where commonpl.date >= v-date-begin and 
                        commonpl.date <= v-date-fin and 
                        commonpl.grp = 9 and 
                        commonpl.rmzdoc <> ? and 
                        commonpl.deluid = ? and
                        trim(commonpl.info[2]) = v-iik and
                        trim(commonpl.info[3]) = string(v-bik) and
                        commonpl.rnnbn = trim(v-rnnbn) no-lock.


find first remtrz where remtrz.remtrz = commonpl.rmzdoc no-lock no-error.
if avail remtrz then do:

put unformatted "<TR><TD bgcolor=""#95B2D1"">" string(v-count) "</TD>" skip
                    "<TD>" remtrz.valdt2 "</TD>" skip
                    "<TD>" string(commonpl.dnum) "</TD>" skip
                    "<TD>`" string(commonpl.rnn) "</TD>" skip
                    "<TD>" commonpl.fioadr "</TD>" skip
                    "<TD>" commonpl.chval[3] "</TD>" skip
                    "<TD>" string(commonpl.kb) "</TD>" skip
                    "<TD>" XLS-NUMBER(remtrz.amt) "</TD></TR>" skip.

v-count = v-count + 1.
d_sum = d_sum + remtrz.amt.
end.
end.

put unformatted "<TR><TD bgcolor=""#95B2D1""><B> ИТОГО: </B></TD>" skip
                    "<TD bgcolor=""#95B2D1""></TD>" skip
                    "<TD bgcolor=""#95B2D1""></TD>" skip
                    "<TD bgcolor=""#95B2D1""></TD>" skip
                    "<TD bgcolor=""#95B2D1""></TD>" skip
                    "<TD bgcolor=""#95B2D1""></TD>" skip
                    "<TD bgcolor=""#95B2D1""></TD>" skip
                    "<TD bgcolor=""#95B2D1""><B>" XLS-NUMBER(d_sum) "</B></TD></TR>" skip.

output close.
unix silent value("cptwin drpr.htm excel").
pause 0.


Procedure ChooseType.
 DEFINE QUERY q1 FOR commonls.
 def browse b1 
    query q1 no-lock
    display 
        fill(" ",12)  format "x(12)"
        commonls.type   format '>9'
        commonls.bn     label "Тип" format 'x(15)'
        fill(" ",12)  format "x(12)"
        with no-labels 15 down title "Получатель платежа".
 def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
 on return of b1 in frame fr1
    do: 
      rid = rowid(commonls).
      find first commonls where rowid(commonls) = rid no-lock no-error.

       assign
    	v-benef   = commonls.bn
    	v-iik     = string(commonls.iik,"999999999")
    	v-bik     = commonls.bik
    	v-kbk     = commonls.kbk
    	v-rnnbn   = commonls.rnn
    	v-type    = commonls.type
        no-error.

    	update v-benef :screen-value    = v-benef with frame report_frame.

       apply "endkey" to frame fr1.
    end.  
                    
 open query q1 for each commonls where commonls.txb = seltxb and commonls.visible = yes and commonls.grp = 9 and commonls.type <> 1
                                       use-index type no-lock.
   b1:SET-REPOSITIONED-ROW (7, "CONDITIONAL").
   ENABLE all with frame fr1.
   apply "value-changed" to b1 in frame fr1.
   WAIT-FOR endkey of frame fr1.
 hide frame fr1.
 return "ok".
end.  
