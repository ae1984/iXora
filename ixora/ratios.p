/* ratios.p
 * MODULE

 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        3-4-5-11
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
        27.02.2013 damir - Внедрено Т.З. № 1607.
*/
{global.i}
def new shared var v-dt as date no-undo.
def var v-dt1 as date no-undo.

def var v-bank as char.


find cmp no-lock no-error.
v-bank = cmp.name.

def frame fparam
   v-dt label "Введите дату" format "99/99/9999" validate(v-dt <= g-today,'Дата не может быть больше операционной') skip
   v-dt1 label "Введите предыдущую дату" format "99/99/9999" validate(v-dt1 <= v-dt,'Предыдущая дата не может быть больше заданной даты') skip
with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

v-dt = g-today.

update v-dt v-dt1 with frame fparam.

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
define new shared temp-table tgl1
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

def new shared temp-table arat
    field id as int
    field typ as char
    field nazv as char
    field odt as decimal
    field dolya as decimal
    field pdt as decimal
    field pdolya as decimal
    field izm as decimal
    field limit as char.

def new shared temp-table orat
    field id as int
    field typ as char
    field nazv as char
    field odt as decimal
    field dolya as decimal
    field pdt as decimal
    field pdolya as decimal
    field izm as decimal
    field limit as char.
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
    empty temp-table tgl.
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

run ratios-1(v-dt1).
run ratios-dat.


def stream rastios.
output stream rastios to rastios.html.
{html-title.i
 &title = "Цена базисного пункта (BPV)" &stream = "stream rastios" &size-add = "x-"}


put stream rastios unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Расчет внутренних коэффициентов АО «ForteBank»  на " + string(v-dt, "99/99/9999") + "</FONT></P>" skip
   "<br><B>1. Показатели структуры активов, тыс. тенге" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.



/*1. Показатели структуры активов*/
put stream rastios unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Наименование</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Отчетная дата</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Доля от общих активов, в %</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Предыдущая дата</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Доля от общих активов, в % </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Изменение  доли, в % </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Лимит</B></FONT></TD>" skip
    "</TR>" skip.

for each arat no-lock break by arat.id by arat.nazv:
    if first-of(arat.nazv) then do:
        put stream rastios unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=""2""><B>" arat.nazv  "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(arat.odt  / 1000),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(arat.dolya),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(arat.pdt / 1000),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(arat.pdolya),".",",") +  "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(arat.izm),".",",") +  "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>"  arat.limit "</B></FONT></TD></TR>" skip.
    end.
end.
put stream rastios unformatted
"</TABLE> <br><br>" skip.

/*2. Показатели структуры обязательств*/
put stream rastios unformatted
    "<br><B>2. Показатели структуры обязательств, тыс. тенге" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream rastios unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Наименование</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Отчетная дата</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Доля от общих обязательств, в %</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Предыдущая дата</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Доля от общих обязательств, в % </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Изменение  доли, в % </B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Лимит</B></FONT></TD>" skip
    "</TR>" skip.

for each orat no-lock break by orat.id by orat.nazv:
    if first-of(orat.nazv) then do:
        put stream rastios unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=""2""><B>" orat.nazv  "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>"  + replace(string(orat.odt / 1000),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(orat.dolya),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(orat.pdt / 1000),".",",") + "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(orat.pdolya),".",",") +  "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>" + replace(string(orat.izm),".",",") +  "</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>"  orat.limit "</B></FONT></TD></TR>" skip.
    end.
end.
put stream rastios unformatted
"</TABLE> <br><br>" skip.


{html-end.i "stream rastios" }

output stream rastios close.
unix silent cptwin rastios.html excel.exe.
pause 0.
