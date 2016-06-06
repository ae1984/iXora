/* depqws.p
 * MODULE
       Кузмичев task
 * DESCRIPTION
       Временная структура депозитов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        13/10/04 kanat
 * CHANGES
        15/03/05 kanat - переименовал наименования дат
        15/03/12 id00810 - добавила v-bankname для печати
        04/05/2012 evseev - изменил путь к логотипу
        04/05/2012 evseev - наименование банка из banknameDgv
*/

def var v-gl-whole as decimal.
def var v-whole as decimal.
def var v-bankname as char no-undo.

def new shared temp-table ttmps
           field aaa as char
    	   field bal as decimal
           field crc as integer
           field regdt as date
           field expdt as date
           field quarter as integer
           field cif as char
           field year as integer.

def new shared temp-table ttmps1
           field aaa as char
           field bal as decimal
           field crc as integer
           field regdt as date
           field expdt as date
           field quarter as integer
           field cif as char
           field year as integer.

def new shared var v-date-begin as date.
def new shared var v-date-fin as date.
def new shared var v-date-qw as date.

find first sysc where sysc.sysc = "banknameDgv" no-lock no-error.
if avail sysc then v-bankname = sysc.chval.

form skip(1)
v-date-begin   format "99/99/9999" label " Остатки по состоянию за  " skip(1)
v-date-qw      format "99/99/9999" label " Начальная дата погашения " skip(1)
v-date-fin     format "99/99/9999" label " Конечная дата погашения  " skip(1)
with row 6 width 50 side-label centered title " Временная структура депозитов АО " + v-bankname frame report_frame.

displ v-date-begin v-date-qw v-date-fin with frame report_frame.

v-date-fin = today.
v-date-begin = today.
v-date-qw = today.

update v-date-begin v-date-qw v-date-fin with frame report_frame.

message " Wait ... ".

/* kanat */
/*
def new shared frame opt
       v-date-fin format "99/99/9999" label "Данные на " with row 8 centered side-labels title "Временная структура депозитов АО TEXAKABANK".

update v-date-fin
       with frame opt.
*/

hide frame opt.
{r-branch.i &proc = "depqw"}


output to rpqwd.htm.
{html-start.i}

put unformatted
   "<IMG border=""0"" src=""c://tmp/top_logo_bw.jpg""><BR><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "Временная структура депозитов АО " v-bankname "</FONT><BR>" skip
   "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><BR>"
   "c " + string(v-date-qw, "99/99/9999")  " по " + string(v-date-fin, "99/99/9999") "</FONT></P></B>" skip.


put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip
     "<TD  bgcolor=""#95B2D1""><B>Сроки</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Валюта<B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Физические лица (тыс.тенге)</B></FONT></TD>" skip
   "</TR>".


for each ttmps no-lock break by ttmps.year by ttmps.quarter by ttmps.crc.

if first-of (ttmps.quarter) then
put unformatted "<TR><TD>" string(ttmps.quarter) " квартал " string(ttmps.year) " года </TD>" skip
                    "<TD></TD>" skip
                    "<TD></TD></TR>" skip.

accumulate ttmps.bal (sub-total by ttmps.crc by ttmps.quarter by ttmps.year).

if last-of (ttmps.crc) then do:
find first crc where crc.crc = ttmps.crc no-lock no-error.

put unformatted "<TR><TD></TD>" skip
                "<TD>" crc.code "</TD>" skip
                "<TD>" string(round((accum sub-total by ttmps.crc ttmps.bal) / 1000, 2)) "</TD></TR>" skip.

end.
end.
put unformatted "</TABLE><BR>" skip.


put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip
     "<TD  bgcolor=""#95B2D1""><B>Сроки</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Валюта<B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Юридические лица (тыс.тенге)</B></FONT></TD>" skip
   "</TR>".

for each ttmps1 no-lock break by ttmps1.year by ttmps1.quarter by ttmps1.crc.

if first-of (ttmps1.quarter) then
put unformatted "<TR><TD>" string(ttmps1.quarter) " квартал " string(ttmps1.year) " года </TD>" skip
                    "<TD></TD>" skip
                    "<TD></TD></TR>" skip.

accumulate ttmps1.bal (sub-total by ttmps1.crc by ttmps1.quarter by ttmps1.year).

if last-of (ttmps1.crc) then do:
find first crc where crc.crc = ttmps1.crc no-lock no-error.

put unformatted "<TR><TD></TD>" skip
                "<TD>" crc.code "</TD>" skip
                "<TD>" string(round((accum sub-total by ttmps1.crc ttmps1.bal) / 1000, 2)) "</TD></TR>" skip.

end.
end.
put unformatted "</TABLE><BR>" skip.



{html-end.i}
output close.

unix silent value("cptwin rpqwd.htm excel").
pause 0.

