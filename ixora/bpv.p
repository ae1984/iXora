/* bpv.p
 * MODULE

 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        3-4-5-10
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        08.05.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
*/
{global.i}
def new shared var v-dt as date no-undo.


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

def new shared temp-table a-bpv
    field id as int
    field tid as int
    field typ as char
    field dur as char
    field crc as int
    field t1m as deci
    field t3m as deci
    field t6m as deci
    field t1y as deci
    field t3y as deci
    field tm3y as deci
    field ttot as deci
    field u1m as deci
    field u3m as deci
    field u6m as deci
    field u1y as deci
    field u3y as deci
    field um3y as deci
    field utot as deci
    field eu1m as deci
    field eu3m as deci
    field eu6m as deci
    field eu1y as deci
    field eu3y as deci
    field eum3y as deci
    field eund as deci
    field eutot as deci
    field p1m as deci
    field p3m as deci
    field p6m as deci
    field p1y as deci
    field p3y as deci
    field pm3y as deci
    field ptot as deci.

def new shared temp-table p-bpv
    field id as int
    field tid as int
    field typ as char
    field dur as char
    field crc as int
    field t1m as deci
    field t3m as deci
    field t6m as deci
    field t1y as deci
    field t3y as deci
    field tm3y as deci
    field ttot as deci
    field u1m as deci
    field u3m as deci
    field u6m as deci
    field u1y as deci
    field u3y as deci
    field um3y as deci
    field utot as deci
    field eu1m as deci
    field eu3m as deci
    field eu6m as deci
    field eu1y as deci
    field eu3y as deci
    field eum3y as deci
    field eund as deci
    field eutot as deci
    field p1m as deci
    field p3m as deci
    field p6m as deci
    field p1y as deci
    field p3y as deci
    field pm3y as deci
    field ptot as deci.
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

run bpv-data.
run bpv-pdata.


def var v-tot as deci.
def var v-utot as deci.
def var v-etot as deci.
def var v-ptot as deci.
def buffer b-a-bpv for a-bpv.
def buffer b-p-bpv for p-bpv.

def var v-t1m as deci.
def var v-t3m as deci.
def var v-t6m as deci.
def var v-t1y as deci.
def var v-t3y as deci.
def var v-tm3y as deci.

def var v-u1m as deci.
def var v-u3m as deci.
def var v-u6m as deci.
def var v-u1y as deci.
def var v-u3y as deci.
def var v-um3y as deci.

def var v-e1m as deci.
def var v-e3m as deci.
def var v-e6m as deci.
def var v-e1y as deci.
def var v-e3y as deci.
def var v-em3y as deci.

def var v-p1m as deci.
def var v-p3m as deci.
def var v-p6m as deci.
def var v-p1y as deci.
def var v-p3y as deci.
def var v-pm3y as deci.


def stream gap.
output stream gap to gap.html.
{html-title.i
 &title = "Цена базисного пункта (BPV)" &stream = "stream gap" &size-add = "x-"}


put stream gap unformatted
   "<FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Цена базисного пункта (BPV)<BR>за дату " + string(v-dt, "99/99/9999") + "</FONT>" skip
   "<br>"
   "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""3"">" skip
   "<TR align=""right"" border= 0><br><TD colspan = 5 ><B> тенге </TD></TR></table>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip
   "<TR align=""center""><TD colspan = 5><B> Активы </TD></TR>" skip .



/*вывод bpv активы bpv-data.p*/
put stream gap unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Maturity</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>USD</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>EUR</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>KZT</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>RUB</B></FONT></TD>" skip
    "</TR>" skip.

v-tot = 0.
v-utot = 0.
v-etot = 0.
v-ptot = 0.
for each a-bpv no-lock break by a-bpv.tid by a-bpv.dur:
    if first-of(a-bpv.dur) then do:
        put stream gap unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=""2""><B>" a-bpv.dur  "</B></FONT></TD>" skip.
        if a-bpv.dur = "0-1M" then do:
            find first b-a-bpv where b-a-bpv.crc = 2 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.u1m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = b-a-bpv.u1m.
                v-u1m = b-a-bpv.u1m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 3 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.eu1m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = b-a-bpv.eu1m.
                v-e1m = b-a-bpv.eu1m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 1 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.t1m,2)),".",",") +  "</B></FONT></TD>" skip.
                 v-tot = b-a-bpv.t1m.
                 v-t1m = b-a-bpv.t1m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 4 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.p1m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = b-a-bpv.p1m.
                v-p1m = b-a-bpv.p1m.
            end.
        end.
        if a-bpv.dur = "1M-3M" then do:
            find first b-a-bpv where b-a-bpv.crc = 2 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.u3m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-a-bpv.u3m.
                v-u3m = b-a-bpv.u3m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 3 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.eu3m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-a-bpv.eu3m.
                v-e3m = b-a-bpv.eu3m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 1 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.t3m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-a-bpv.t3m.
                v-t3m = b-a-bpv.t3m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 4 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.p3m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = v-ptot + b-a-bpv.p3m.
                v-p3m = b-a-bpv.p3m.
            end.
        end.
        if a-bpv.dur = "3M-6M" then do:
            find first b-a-bpv where b-a-bpv.crc = 2 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.u6m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-a-bpv.u6m.
                v-u6m = b-a-bpv.u6m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 3 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.eu6m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-a-bpv.eu6m.
                v-e6m = b-a-bpv.eu6m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 1 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.t6m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-a-bpv.t6m.
                v-t6m = b-a-bpv.t6m.
            end.
            find first b-a-bpv where b-a-bpv.crc = 4 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.p6m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = v-ptot + b-a-bpv.p6m.
                v-p6m = b-a-bpv.p6m.
            end.
        end.
        if a-bpv.dur = "6M-1Y" then do:
            find first b-a-bpv where b-a-bpv.crc = 2 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.u1y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-a-bpv.u1y.
                v-u1y = b-a-bpv.u1y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 3 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.eu1y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-a-bpv.eu1y.
                v-e1y = b-a-bpv.eu1y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 1 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.t1y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-a-bpv.t1y.
                v-t1y = b-a-bpv.t1y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 4 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.p1y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = v-ptot + b-a-bpv.p1y.
                v-p1y = b-a-bpv.p1y.
            end.
        end.
        if a-bpv.dur = "1Y-3Y" then do:
            find first b-a-bpv where b-a-bpv.crc = 2 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.u3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-a-bpv.u3y.
                v-u3y = b-a-bpv.u3y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 3 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.eu3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-a-bpv.eu3y.
                v-e3y = b-a-bpv.eu3y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 1 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.t3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-a-bpv.t3y.
                v-t3y = b-a-bpv.t3y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 4 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.p3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = v-ptot + b-a-bpv.p3y.
                v-p3y = b-a-bpv.p3y.
            end.
        end.
        if a-bpv.dur = "3Y-…" then do:
            find first b-a-bpv where b-a-bpv.crc = 2 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.um3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-a-bpv.um3y.
                v-um3y = b-a-bpv.um3y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 3 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.eum3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-a-bpv.eum3y.
                v-em3y = b-a-bpv.eum3y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 1 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.tm3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-a-bpv.tm3y.
                v-tm3y = b-a-bpv.tm3y.
            end.
            find first b-a-bpv where b-a-bpv.crc = 4 and b-a-bpv.dur = a-bpv.dur no-lock no-error.
            if avail b-a-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-a-bpv.pm3y,2)),".",",") +  "</B></FONT></TD></TR>" skip.
                v-ptot = v-ptot + b-a-bpv.pm3y.
                v-pm3y = b-a-bpv.pm3y.
            end.
        end.
    end.
end.

put stream gap unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=""2""><B>TOTAL</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(round(v-utot,2)),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(round(v-etot,2)),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(round(v-tot,2)),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(round(v-ptot,2)),".",",") + "</B></FONT></TD></TR>" skip.
put stream gap unformatted
"</TABLE> <br><br>" skip.

/*вывод bpv пассивы bpv-data.p*/
put stream gap unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">"
    "<TR align=""center""><TD colspan = 5><B> Обязательства </TD></TR>" skip
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Maturity</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>USD</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>EUR</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>KZT</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>RUB</B></FONT></TD>" skip
    "</TR>" skip.

v-tot = 0.
v-utot = 0.
v-etot = 0.
v-ptot = 0.
for each p-bpv no-lock break by p-bpv.tid by p-bpv.dur:
    if first-of(p-bpv.dur) then do:
        put stream gap unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=""2""><B>" p-bpv.dur  "</B></FONT></TD>" skip.
        if p-bpv.dur = "0-1M" then do:
            find first b-p-bpv where b-p-bpv.crc = 2 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.u1m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = b-p-bpv.u1m.
                v-u1m = v-u1m - b-p-bpv.u1m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 3 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.eu1m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = b-p-bpv.eu1m.
                v-e1m = v-e1m - b-p-bpv.eu1m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 1 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.t1m,2)),".",",") +  "</B></FONT></TD>" skip.
                 v-tot = b-p-bpv.t1m.
                 v-t1m = v-t1m - b-p-bpv.t1m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 4 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.p1m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = b-p-bpv.p1m.
                v-p1m = v-p1m - b-p-bpv.p1m.
            end.
        end.
        if p-bpv.dur = "1M-3M" then do:
            find first b-p-bpv where b-p-bpv.crc = 2 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.u3m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-p-bpv.u3m.
                v-u3m = v-u3m - b-p-bpv.u3m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 3 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.eu3m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-p-bpv.eu3m.
                v-e3m = v-e3m - b-p-bpv.eu3m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 1 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.t3m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-p-bpv.t3m.
                v-t3m = v-t3m - b-p-bpv.t3m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 4 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.p3m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = v-ptot + b-p-bpv.p3m.
                v-p3m = v-p3m - b-p-bpv.p3m.
            end.
        end.
        if p-bpv.dur = "3M-6M" then do:
            find first b-p-bpv where b-p-bpv.crc = 2 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.u6m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-p-bpv.u6m.
                v-u6m = v-u6m - b-p-bpv.u6m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 3 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.eu6m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-p-bpv.eu6m.
                v-e6m = v-e6m - b-p-bpv.eu6m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 1 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.t6m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-p-bpv.t6m.
                v-t6m = v-t6m - b-p-bpv.t6m.
            end.
            find first b-p-bpv where b-p-bpv.crc = 4 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.p6m,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = v-ptot + b-p-bpv.p6m.
                v-p6m = v-p6m - b-p-bpv.p6m.
            end.
        end.
        if p-bpv.dur = "6M-1Y" then do:
            find first b-p-bpv where b-p-bpv.crc = 2 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.u1y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-p-bpv.u1y.
                v-u1y = v-u1y - b-p-bpv.u1y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 3 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.eu1y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-p-bpv.eu1y.
                v-e1y = v-e1y - b-p-bpv.eu1y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 1 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.t1y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-p-bpv.t1y.
                v-t1y = v-t1y - b-p-bpv.t1y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 4 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.p1y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = v-ptot + b-p-bpv.p1y.
                v-p1y = v-p1y - b-p-bpv.p1y.
            end.
        end.
        if p-bpv.dur = "1Y-3Y" then do:
            find first b-p-bpv where b-p-bpv.crc = 2 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.u3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-p-bpv.u3y.
                v-u3y = v-u3y - b-p-bpv.u3y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 3 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.eu3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-p-bpv.eu3y.
                v-e3y = v-e3y - b-p-bpv.eu3y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 1 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.t3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-p-bpv.t3y.
                v-t3y = v-t3y - b-p-bpv.t3y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 4 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.p3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-ptot = v-ptot + b-p-bpv.p3y.
                v-p3y = v-p3y - b-p-bpv.p3y.
            end.
        end.
        if p-bpv.dur = "3Y-…" then do:
            find first b-p-bpv where b-p-bpv.crc = 2 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.um3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-utot = v-utot + b-p-bpv.um3y.
                v-um3y = v-um3y - b-p-bpv.um3y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 3 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.eum3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-etot = v-etot + b-p-bpv.eum3y.
                v-em3y = v-em3y - b-p-bpv.eum3y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 1 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.tm3y,2)),".",",") +  "</B></FONT></TD>" skip.
                v-tot = v-tot + b-p-bpv.tm3y.
                v-tm3y = v-tm3y - b-p-bpv.tm3y.
            end.
            find first b-p-bpv where b-p-bpv.crc = 4 and b-p-bpv.dur = p-bpv.dur no-lock no-error.
            if avail b-p-bpv then do:
                put stream gap unformatted
                "<TD><FONT size=""2""><B>" + replace(string(round(b-p-bpv.pm3y,2)),".",",") +  "</B></FONT></TD></TR>" skip.
                v-ptot = v-ptot + b-p-bpv.pm3y.
                v-pm3y = v-pm3y - b-p-bpv.pm3y.
            end.
        end.
    end.
end.

put stream gap unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=""2""><B>TOTAL</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(round(v-utot,2)),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(round(v-etot,2)),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(round(v-tot,2)),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(round(v-ptot,2)),".",",") + "</B></FONT></TD></TR>" skip.
put stream gap unformatted
"</TABLE> <br><br>" skip.


/*BPV*/
 put stream gap unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">"
    "<TR align=""center""><TD colspan = 5><B> Итого BPV </TD></TR>" skip
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Maturity</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>USD</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>EUR</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>KZT</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>RUB</B></FONT></TD>" skip
    "</TR>" skip.

put stream gap unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B> 0-1M  </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-u1m,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-e1m,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-t1m,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-p1m,2)),".",",") +  "</B></FONT></TD></TR>" skip
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B> 1M-3M  </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-u3m,2)),".",",") + "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-e3m,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-t3m,2)),".",",") + "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-p3m,2)),".",",") +  "</B></FONT></TD></TR>" skip
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B> 3M-6M  </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-u6m,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-e6m,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-t6m,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-p6m,2)),".",",") +  "</B></FONT></TD></TR>" skip
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B> 6M-1Y  </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-u1y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-e1y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-t1y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-p1y,2)),".",",") +  "</B></FONT></TD></TR>" skip
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B> 1Y-3Y  </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-u3y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-e3y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-t3y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-p3y,2)),".",",") +  "</B></FONT></TD></TR>" skip
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B> 3Y-… </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-um3y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-em3y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-tm3y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-pm3y,2)),".",",") +  "</B></FONT></TD></TR>" skip
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B> TOTAL  </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-u1m + v-u3m + v-u6m + v-u1y + v-u3y + v-um3y,2)),".",",") + "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-e1m + v-e3m + v-e6m + v-e1y + v-e3y + v-em3y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-t1m + v-t3m + v-t6m + v-t1y + v-t3y + v-tm3y,2)),".",",") +  "</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>" + replace(string(round(v-p1m + v-p3m + v-p6m + v-p1y + v-p3y + v-pm3y,2)),".",",") +  "</B></FONT></TD></TR>" skip.

put stream gap unformatted
"</TABLE>" skip.

{html-end.i "stream gap" }

output stream gap close.
unix silent cptwin gap.html excel.exe.
pause 0.
