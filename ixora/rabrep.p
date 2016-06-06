/* rabrep.p
 * MODULE
        Коммунальные и налоговые платежи
 * DESCRIPTION
        Отчет авторизаций кассиров в системе
 * RUN
        
 * CALLER
        import.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        20/09/2004 kanat  
 * CHANGES
        29/09/2004 kanat - Перекомпиляция в новой кодировке :)
        08/10/2004 kanat - Переделал запрос на вывод даных в файл 
        26/10/2004 kanat - Изменения группировки формирования данных в выборке по кассирам
        03/11/2004 kanat - Убрал основной цикл по 13 группе так как изменились требования Заказчика
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
def var v-begin-time as integer.
def var v-finish-time as integer.

define var v-depcode as char init "1,2,3,4,35,36,37". 

def var dttemp as date.

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
v-date-begin   format "99/99/99" label " Начало периода" 
v-date-fin     format "99/99/99" label " Конец периода" skip
with row 6 side-label centered title " Учет рабочего времени сберкасс АО TEXAKABANK " color messages frame report_frame.

displ v-date-begin v-date-fin with frame report_frame.
update v-date-begin v-date-fin with frame report_frame.

message "Формируются данные для отчета ... ".

output to uchet.htm.
{html-start.i}
put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip.

put unformatted 
   "Учет рабочего времени сберкасс c " v-date-begin " по " v-date-fin "</FONT><BR>" skip
   "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><BR>".

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip
   "<B>Исполнитель: </B>" v-mname ". <BR>" skip
   "<B>в: </B>" string(g-today) ". <BR>" skip
   "<B>Время: </B>" string(time,"HH:MM:SS") ". <BR><BR>" skip.

put unformatted
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Дата</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Фамилия кассира</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Наименование СПФ</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Время прибытия на работу</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><FONT size=""2""><B>Время убытия кассира с работы</B></FONT></TD>" skip
   "</TR>".                            

do dttemp = v-date-begin to v-date-fin:
for each ofc where ofc.ofc begins "u" and ofc.titcd begins "A" no-lock.

v-dep = get-dep(ofc.ofc, v-date-begin).
find first ppoint where ppoint.depart = v-dep no-lock no-error.

if lookup(string(v-dep),v-depcode) = 0 then do:

select min(commonpl.cretime) 
      into v-begin-time
      from commonpl
     where commonpl.txb = 0 and 
           commonpl.date = dttemp and 
           commonpl.grp = 13 and
           commonpl.type = 1 and
           commonpl.uid = ofc.ofc.

select max(commonpl.cretime) 
      into v-finish-time
      from commonpl
     where commonpl.txb = 0 and 
           commonpl.date = dttemp and
           commonpl.grp = 13 and 
           commonpl.type = 2 and
           commonpl.uid = ofc.ofc.

put unformatted "<TR><TD>" dttemp "</TD>" skip
                    "<TD>" ofc.name "</TD>" skip
                    "<TD>" ppoint.name "</TD>" skip.

if v-begin-time > 0 then
put unformatted     "<TD>" string(v-begin-time,"HH:MM:SS") "</TD>" skip.
else
put unformatted     "<TD></TD>" skip.

if v-finish-time > 0 then
put unformatted     "<TD>" string(v-finish-time,"HH:MM:SS") "</TD></TR>" skip.
else
put unformatted     "<TD></TD>" skip.

v-begin-time = 0.
v-finish-time = 0.

end.
end.
end.

output close.
unix silent value("cptwin uchet.htm excel").
pause 0.







