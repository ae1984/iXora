/* sub_dep.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Разбивка всех депозитных счетов по уровням.
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
        21.01.2005 saltanat - Включать закрытые отчеты, кот. закрылись позже последней даты заданного периода. 
        08.08.2006 dpuchkov - Оптимизация
*/

{mainhead.i}

def var v-dt1 as date.
def var v-dt2 as date.
def var sublv as deci extent 13.
def var v-gl  as inte format 'zzzzz9' init 0.
def var v-ch  as char format 'x(1)' init "A".
def var v-st  as char format 'x(1)' init "V".
def var v-sum as deci init 0.

def temp-table t-aaa
    field lgr   like lgr.lgr
    field gl    like aaa.gl
    field aaa   like aaa.aaa
    field sta   like aaa.sta 
    field cif   like cif.cif
    field name  like cif.name
    field crc   like aaa.crc
    field rate  like aaa.rate
    field regdt like aaa.regdt
    field expdt like aaa.expdt
    field cltdt like aaa.cltdt
    field sub1  as deci
    field sub2  as deci
    field sub3  as deci
    field sub4  as deci
    field sub5  as deci
    field sub6  as deci
    field sub7  as deci
    field sub8  as deci
    field sub9  as deci
    field sub11 as deci
    field sub12 as deci
    field sub13 as deci.

form 
     skip(1)
     v-dt1 label 'Счета открытые с ' format '99/99/99' skip
     v-dt2 label 'по               ' format '99/99/99' skip
     v-gl  label 'Счет гл.книги    ' format 'zzzzz9'
           validate(can-find(gl where gl.gl = v-gl) or v-gl = 0,'Такого номера гл.книги нет!') skip
     v-ch  label 'Выборка по сумме ' format 'x(1)' 
           help 'A- Все; N- нулевая сумма; С- ненулевая сумма;'
           validate( upper(v-ch) = "A" or upper(v-ch) = "N" or upper(v-ch) = "C", "Выберите: A либо N либо C !") skip
     v-st  label 'Состояние счета  ' format 'x(1)'
           help 'A- открытые на зад.дату; С- закрытые; V- Все;'
           validate( upper(v-st) = "A" or upper(v-st) = "C" or upper(v-st) = "V", "Выберите: A либо N либо V !")      
with centered side-label title 'Счета открытые' row 5 frame fr.

v-dt1 = g-today.
v-dt2 = g-today.

update v-dt1 v-dt2 v-gl v-ch v-st with frame fr.

hide frame fr.
displ "Ждите, идет формирования отчета..." with centered row 12 frame vw.
pause 0.

for each aaa where aaa.regdt >= v-dt1 and aaa.regdt <= v-dt2 no-lock.

if not avail aaa then next. 

if upper(v-st) = "A" then if aaa.sta begins 'c' and (if aaa.cltdt = ? then true else aaa.cltdt < v-dt2) then next.
if upper(v-st) = "C" then if not(aaa.sta begins 'c' and (if aaa.cltdt = ? then true else aaa.cltdt < v-dt2)) then next.
if aaa.gl ne 0 and v-gl ne 0 then if aaa.gl ne v-gl then next.
find lgr where lgr.lgr = aaa.lgr no-lock no-error.
if not avail lgr then next.
if lgr.led <> 'TDA' and lgr.led <> 'CDA' then next.
find cif where cif.cif = aaa.cif no-lock no-error.
if not avail cif then next.

run lonbal2('cif',aaa.aaa,v-dt2,"1",yes,output sublv[1]).
run lonbal2('cif',aaa.aaa,v-dt2,"2",yes,output sublv[2]).
run lonbal2('cif',aaa.aaa,v-dt2,"3",yes,output sublv[3]).
run lonbal2('cif',aaa.aaa,v-dt2,"4",yes,output sublv[4]).
run lonbal2('cif',aaa.aaa,v-dt2,"5",yes,output sublv[5]).
run lonbal2('cif',aaa.aaa,v-dt2,"6",yes,output sublv[6]).
run lonbal2('cif',aaa.aaa,v-dt2,"7",yes,output sublv[7]).
run lonbal2('cif',aaa.aaa,v-dt2,"8",yes,output sublv[8]).
run lonbal2('cif',aaa.aaa,v-dt2,"9",yes,output sublv[9]).
run lonbal2('cif',aaa.aaa,v-dt2,"11",yes,output sublv[11]).
run lonbal2('cif',aaa.aaa,v-dt2,"12",yes,output sublv[12]).
run lonbal2('cif',aaa.aaa,v-dt2,"13",yes,output sublv[13]).

v-sum = sublv[1] + sublv[2] + sublv[3] + sublv[4] + sublv[5] + sublv[6] + sublv[7] + sublv[8] + sublv[9] + sublv[11] + sublv[12] + sublv[13].

if upper(v-ch) = "N" then if v-sum ne 0 then next.
if upper(v-ch) = "C" then if v-sum = 0 then next.
    
create t-aaa.
assign t-aaa.lgr   = aaa.lgr
       t-aaa.gl    = aaa.gl
       t-aaa.aaa   = aaa.aaa
       t-aaa.sta   = aaa.sta
       t-aaa.cif   = cif.cif
       t-aaa.name  = cif.name
       t-aaa.crc   = aaa.crc
       t-aaa.rate  = aaa.rate
       t-aaa.regdt = aaa.regdt
       t-aaa.expdt = aaa.expdt
       t-aaa.cltdt = aaa.cltdt
       t-aaa.sub1  = sublv[1]
       t-aaa.sub2  = sublv[2]
       t-aaa.sub3  = sublv[3]
       t-aaa.sub4  = sublv[4]
       t-aaa.sub5  = sublv[5]
       t-aaa.sub6  = sublv[6]
       t-aaa.sub7  = sublv[7]
       t-aaa.sub8  = sublv[8]
       t-aaa.sub9  = sublv[9]
       t-aaa.sub11 = sublv[11]
       t-aaa.sub12 = sublv[12]
       t-aaa.sub13 = sublv[13].
end.

/* вывод отчета в HTML */

def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Депозиты по уровням"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""left""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Депозиты по уровням за период с " + string(v-dt1, "99/99/9999") + 
       " по " + string(v-dt2, "99/99/9999") +  " дату </B></FONT></P>" skip

   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" bordercolor=#d8e4f8>" skip.
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>Группа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Гл.книга</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Счет</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Статус</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер<br>CIF</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Клиент</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>%ставка</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Начало</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата закрытия счета</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.1 <br>Обороты по дебету кредиту</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.2 <br>Начисленные %</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.9 <br>Наличная валюта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Ур.11<br>% в нац. валюте</B></FONT></TD>" skip
   "</TR>" skip.

for each t-aaa break by t-aaa.lgr by t-aaa.regdt.
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8>" skip
     "<TD><FONT size=""2"">" + string(t-aaa.lgr)    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-aaa.gl)     + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-aaa.aaa            + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-aaa.sta            + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-aaa.cif            + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-aaa.name           + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-aaa.crc)    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">&nbsp;" + replace(string(t-aaa.rate,">>9.9"),'.',',')   + "</FONT></TD>" skip
     "<TD><FONT size=""2"">&nbsp;" + if t-aaa.regdt = ? then '' else string(t-aaa.regdt,"99.99.9999") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">&nbsp;" + if t-aaa.sta begins 'c' and (if t-aaa.cltdt = ? then true else t-aaa.cltdt < v-dt2) and t-aaa.cltdt <> ? then string(t-aaa.cltdt,"99.99.9999") else '' "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-aaa.sub1,"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-aaa.sub2,"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-aaa.sub9,"->>>>>>>>>>>9.99"),'.',',')    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + replace(string(t-aaa.sub11,"->>>>>>>>>>>9.99"),'.',',')   + "</FONT></TD>" skip
   "</TR>" skip.
end.
put stream vcrpt unformatted  
"</TABLE>" skip.
{html-end.i "stream vcrpt" }
output stream vcrpt close.
hide message no-pause.
unix silent cptwin vcreestr.htm excel.
