/* gap.p
 * MODULE

 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        3-4-5-9
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        10.04.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
*/
{global.i}
def new shared var v-dt as date no-undo.

def new shared temp-table wrk
    field num as int
    field nazv as char
    field gl as char
    field mtyp as char
    field typ as char
    field crc as int
    field t7d as deci
    field t1m as deci
    field t3m as deci
    field t6m as deci
    field t1y as deci
    field t3y as deci
    field tm3y as deci
    field tnd as deci
    field ttot as deci
    field u7d as deci
    field u1m as deci
    field u3m as deci
    field u6m as deci
    field u1y as deci
    field u3y as deci
    field um3y as deci
    field und as deci
    field utot as deci
    field eu7d as deci
    field eu1m as deci
    field eu3m as deci
    field eu6m as deci
    field eu1y as deci
    field eu3y as deci
    field eum3y as deci
    field eund as deci
    field eutot as deci
    field p7d as deci
    field p1m as deci
    field p3m as deci
    field p6m as deci
    field p1y as deci
    field p3y as deci
    field pm3y as deci
    field pnd as deci
    field ptot as deci.

def buffer b-wrk for wrk.
def var v-bank as char.


find cmp no-lock no-error.
v-bank = cmp.name.

def frame fparam
   v-dt label "Введите дату" format "99/99/9999" validate(v-dt <= g-today,'Дата не может быть больше операционной') skip
with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

v-dt = g-today.
update v-dt with frame fparam.

define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .
define new shared variable v-gldate as date.
def new shared var v-gl1 as int no-undo.
def new shared var v-gl2 as int no-undo.
def new shared var v-gl-cl as int no-undo.
def var RepName as char.
def var RepPath as char init "/data/reports/array/".


v-gldate = v-dt.
/*v-gl1 = 110000.
v-gl2 = 250000.*/
function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.

RepName = "array" + string(v-gl1) + string(v-gl2) + string(v-gl-cl) + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".
if not FileExist(RepPath + RepName) then do:
 run array-create.
end.


procedure ImportData:
  INPUT FROM value(RepPath + RepName) NO-ECHO.
  LOOP:
  REPEAT TRANSACTION:
   REPEAT ON ENDKEY UNDO, LEAVE LOOP:
   CREATE tgl.
   IMPORT
     tgl.txb
     tgl.gl
     tgl.gl4
     tgl.gl7
     tgl.gl-des
     tgl.crc
     tgl.sum
     tgl.sum-val
     tgl.type
     tgl.sub-type
     tgl.totlev
     tgl.totgl
     tgl.level
     tgl.code
     tgl.grp
     tgl.acc
     tgl.acc-des
     tgl.geo
     tgl.odt
     tgl.cdt
     tgl.perc
     tgl.prod.
   END. /*REPEAT*/
  END. /*TRANSACTION*/
  input close.
end procedure.
run ImportData.

run gap-data.
def stream gap.
output stream gap to gap.html.
{html-title.i
 &title = "Процентный ГЭП" &stream = "stream gap" &size-add = "x-"}


put stream gap unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Процентный ГЭП<BR>за дату " + string(v-dt, "99/99/9999") + "</FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Исходящие платежи, которых нет в Прагме. */
put stream gap unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Названия строк</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>до 7 дней</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>до 1 месяца</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>до 3 месяцев</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>до 6 месяцев</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>до 1 года</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>до 3 лет</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>свыше 3 лет</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Без срока</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Общий итог</B></FONT></TD>" skip
    "</TR>" skip.

for each wrk no-lock break by wrk.mtyp:
    if last-of(wrk.mtyp) then do:
        put stream gap unformatted
        "<TR align=""center"">" skip
        "<TD style=""background-color: #DA70D6""  colspan = 10><FONT size=""2"" ><B>" +  wrk.mtyp + "</B></FONT></TD>" skip
        "</TR>" skip.
        for each b-wrk where b-wrk.mtyp = wrk.mtyp no-lock break by b-wrk.num by b-wrk.typ:
            if first-of(b-wrk.typ) then do:
                put stream gap unformatted
                "<TR align=""center"">" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + b-wrk.typ + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.t7d + b-wrk.u7d + b-wrk.eu7d + b-wrk.p7d) / 1000),".",",")    + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.t1m + b-wrk.u1m + b-wrk.eu1m + b-wrk.p1m) / 1000),".",",") + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.t3m + b-wrk.u3m + b-wrk.eu3m + b-wrk.p3m) / 1000),".",",") + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.t6m + b-wrk.u6m + b-wrk.eu6m + b-wrk.p6m) / 1000),".",",") + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.t1y + b-wrk.u1y + b-wrk.eu1y + b-wrk.p1y) / 1000),".",",") + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.t3y + b-wrk.u3y + b-wrk.eu3y + b-wrk.p3y) / 1000),".",",") + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.tm3y + b-wrk.um3y + b-wrk.eum3y + b-wrk.pm3y) / 1000),".",",") + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.tnd + b-wrk.und + b-wrk.eund + b-wrk.pnd) / 1000),".",",") + "</B></FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2""><B>" + replace(string((b-wrk.ttot + b-wrk.utot + b-wrk.eutot + b-wrk.ptot) / 1000),".",",") + "</B></FONT></TD>" skip
                "</TR>" skip
                "<TR align=""center"">" skip
                "<TD><FONT size=""2"">Тенге</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.t7d / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.t1m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.t3m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.t6m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.t1y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.t3y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.tm3y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.tnd / 1000),".",",") + "</FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2"">" + replace(string(b-wrk.ttot / 1000),".",",") + "</FONT></TD>" skip
                "</TR>" skip
                "<TR align=""center"">" skip
                "<TD><FONT size=""2"">Доллар</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.u7d / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.u1m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.u3m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.u6m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.u1y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.u3y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.um3y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.und / 1000),".",",") + "</FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2"">" + replace(string(b-wrk.utot / 1000),".",",") + "</FONT></TD>" skip
                "</TR>" skip
                "<TR align=""center"">" skip
                "<TD><FONT size=""2"">Евро</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.eu7d / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.eu1m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.eu3m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.eu6m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.eu1y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.eu3y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.eum3y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.eund / 1000),".",",") + "</FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2"">" + replace(string(b-wrk.eutot / 1000),".",",") + "</FONT></TD>" skip
                "</TR>" skip
                "</TR>" skip
                "<TR align=""center"">" skip
                "<TD><FONT size=""2"">Прочие</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.p7d / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.p1m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.p3m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.p6m / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.p1y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.p3y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.pm3y / 1000),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(string(b-wrk.pnd / 1000),".",",") + "</FONT></TD>" skip
                "<TD style=""background-color: #D8BFD8""><FONT size=""2"">" + replace(string(b-wrk.ptot / 1000),".",",") + "</FONT></TD>" skip
                "</TR>" skip.
            end.
        end.
    end.
end.

put stream gap unformatted
"</TABLE>" skip.

{html-end.i "stream gap" }

output stream gap close.
unix silent cptwin gap.html excel.exe.
pause 0.
