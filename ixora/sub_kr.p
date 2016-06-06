/* sub_kr.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Разбивка всех кредитных счетов по уровням.
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
        30.11.2004 saltanat
 * CHANGES
*/

{mainhead.i}

def var v-dt1   as date init ?.
def var v-dt2   as date init ?.
def var v-sublv as deci extent 30.
def var i       as inte.
def var c       as char.
def var v-crc   like crc.crc init 1.
def var v-nolv  as char init '4,5,17,18,24,19'.
def var v-lcrc  as char init '1,2,7,8,9,10,13,14,15,20,21,22,23,25,28,29'.
def var v-kcrc  as char init '3,6,11,12,16,26,27,30'.
def var v-acrc  as char init '19'.
def var v-gl  as inte format 'zzzzz9' init 0.

form  skip(1)
      v-dt1 label 'С             ' format '99/99/99' skip
      v-dt2 label 'По            ' format '99/99/99' skip
      v-gl  label 'Счет гл.книги ' format 'zzzzz9'
           validate(can-find(gl where gl.gl = v-gl) or v-gl = 0,'Такого номера гл.книги нет!') skip
      with centered side-label title 'Кредитные счета открытые' row 5 frame fr.
    
def temp-table t-lon
    field grp    like lon.grp
    field gl     like lon.gl
    field cif    like lon.cif
    field lon    like lon.lon
    field name   like cif.name
    field rdt    like lon.rdt
    field duedt  like lon.duedt
    field crc    like lon.crc
    field sublv  as   deci      extent 30
index id1 grp
index id2 gl
index id3 rdt.

v-dt1 = g-today.
v-dt2 = g-today.

update v-dt1 v-dt2 v-gl with frame fr.

hide frame fr.
displ 'Ждите, идет формирование отчета...' with row 12 centered.
pause 0.

for each lon where lon.rdt >= v-dt1 and lon.rdt <= v-dt2 no-lock:

find cif where cif.cif = lon.cif no-lock no-error.
if not avail cif then next.

if lon.gl ne 0 and v-gl ne 0 then 
   if lon.gl ne v-gl then next.
   
do i = 1 to 30:

if lookup(string(i),v-nolv) > 0 then next.

if lookup(string(i),v-lcrc) > 0 then v-crc = lon.crc.

if lookup(string(i),v-kcrc) > 0 then v-crc = 1.

c = string(i).

run lonbalcrc ('lon',lon.lon,v-dt2,c,yes,v-crc,output v-sublv[i]).

v-sublv[i] = abs(v-sublv[i]).

end.

create t-lon.
assign t-lon.grp       = lon.grp
       t-lon.gl        = lon.gl
       t-lon.cif       = cif.cif
       t-lon.lon       = lon.lon
       t-lon.name      = cif.name
       t-lon.rdt       = lon.rdt
       t-lon.duedt     = lon.duedt
       t-lon.crc       = lon.crc
       t-lon.sublv[1]  = v-sublv[1]
       t-lon.sublv[2]  = v-sublv[2]
       t-lon.sublv[3]  = v-sublv[3]
       t-lon.sublv[6]  = v-sublv[6]
       t-lon.sublv[7]  = v-sublv[7]
       t-lon.sublv[8]  = v-sublv[8]
       t-lon.sublv[9]  = v-sublv[9]
       t-lon.sublv[10] = v-sublv[10]
       t-lon.sublv[11] = v-sublv[11]
       t-lon.sublv[12] = v-sublv[12]
       t-lon.sublv[13] = v-sublv[13]
       t-lon.sublv[14] = v-sublv[14]
       t-lon.sublv[15] = v-sublv[15]
       t-lon.sublv[16] = v-sublv[16]
       t-lon.sublv[20] = v-sublv[20]
       t-lon.sublv[21] = v-sublv[21]
       t-lon.sublv[22] = v-sublv[22]
       t-lon.sublv[23] = v-sublv[23]
       t-lon.sublv[25] = v-sublv[25]
       t-lon.sublv[26] = v-sublv[26]
       t-lon.sublv[27] = v-sublv[27]
       t-lon.sublv[28] = v-sublv[28]
       t-lon.sublv[29] = v-sublv[29]
       t-lon.sublv[30] = v-sublv[30].

end.


/* Вывод отчета в HTML */ 

def stream str.
output stream str to lonsublv.htm.

{html-title.i
 &stream   = "stream str"
 &title    = "Кредиты по уровням"
 &size-add = "xx-"  
}

put stream str unformatted 
   "<P align = ""left""><FONT size = ""3"" face = ""Times New Roman Cyr, Verdana, sans"">"
   "<B>Кредиты по уровням за период с " + string(v-dt1, "99/99/9999") + 
       " по " + string(v-dt2, "99/99/9999") +  " дату </B></FONT></P>" skip

   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" bordercolor=#d8e4f8>" skip.

put stream str unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>Группа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Счет гл.книги</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер<br>CIF</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Счет</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Заемщик</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата выдачи</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата окончания</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.1 <br>Основная сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.2 <br>Рассчитанные проценты</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.3 <br>Общие провизии</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.6 <br>Специальные провизии</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.7 <br>Просроченная основная сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.8 <br>Блокированная основная сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.9 <br>Просроченные %</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.10 <br>Предоплата %</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.11 <br>Начисленные %</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.12<br>Полученные % в нац.вал.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.13<br>Списанная осн. сумма кредита</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.14<br>Списанные % по кредиту</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.15<br>Остаток кредитной линии</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.16<br>Начисленная пеня</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.20<br>Сумма индексации по инд.займам</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.21<br>Сумма индексации по просроченным займам</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.22<br>Индексация %</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.23<br>Индексация просроч. %</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.25<br>Комиссия за неиспользованную линию</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.26<br>Внебаланс КИК</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.27<br>Комиссия за предоставление кредита</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.28<br>Комиссия за ведение ссудного счета</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.29<br>Комиссия за продление ссуды</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.30<br>Штрафы списанные за баланс</B></FONT></TD>" skip
   "</TR>" skip.

for each t-lon break by t-lon.grp by t-lon.gl by t-lon.rdt.
put stream str unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8>" skip
     "<TD><FONT size=""2"">" + string(t-lon.grp)    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-lon.gl)    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-lon.cif            + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-lon.lon            + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-lon.name           + "</FONT></TD>" skip
     "<TD><FONT size=""2"">&nbsp;" + if t-lon.rdt   = ? then '' else string(t-lon.rdt,"99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">&nbsp;" + if t-lon.duedt = ? then '' else string(t-lon.duedt,"99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-lon.crc)    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[1],"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[2],"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[3],"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[6],"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[7],"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[8],"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[9],"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[10],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[11],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[12],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[13],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[14],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[15],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[16],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[20],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[21],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[22],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[23],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[25],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[26],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[27],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[28],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[29],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-lon.sublv[30],"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
   "</TR>" skip.
end.

put stream str unformatted  
"</TABLE>" skip.

{html-end.i "stream str" }

output stream str close.

hide message no-pause.

unix silent cptwin lonsublv.htm excel.












