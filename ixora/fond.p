/* fond.p
 * MODULE

 * DESCRIPTION
        Фондирование активных операций
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
        17.05.2012 aigul
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
   v-dt label "На дату" format "99/99/9999" validate(v-dt <= g-today,'Дата не может быть больше операционной') skip
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
    index tgl-id1 is primary gl7.

def new shared temp-table wrk-act
    field gr as int
    field id as int
    field sum as deci
    field typ as char
    field crc as int.
def new  shared temp-table wrk-pas
    field gr as int
    field id as int
    field sum as deci
    field typ as char
    field crc as int.

define new shared variable v-gldate as date.
def new shared var v-gl1 as int no-undo.
def new shared var v-gl2 as int no-undo.
def new shared var v-gl-cl as int no-undo.
def new shared var s-tot-2act as deci.
def new shared var s-tot-2act-t as deci.
def new shared var s-tot-2act-u as deci.
def new shared var s-tot-2act-e as deci.
def new shared var s-tot-2act-r as deci.
def new shared var s-tot-2act-o as deci.
def var RepName as char.
def var RepPath as char init "/data/reports/array/".

v-gldate = v-dt - 1.

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


def buffer b-wrk-act for wrk-act.
def var v-act as deci.
def var v-pas as deci.
def var v-act-perc as deci.
def var v-pas-perc as deci.


run fond-act.
run fond-pas.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 0 no-lock:
    v-act = v-act + wrk-act.sum.
end.
for each wrk-pas where wrk-pas.typ = "total" and wrk-pas.crc = 0 no-lock:
    v-pas = v-pas + wrk-pas.sum.
end.
def stream fond.
output stream fond to fond.html.
{html-title.i
 &title = "Цена базисного пункта (BPV)" &stream = "stream fond" &size-add = "x-"}


put stream fond unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman"">"
   "<B>Фондирование активных операций АО 'ForteBank' на  " + string(v-dt, "99/99/9999") + "</FONT></P>" skip
   "<br><B><FONT size=""2"" face=""Times New Roman"">тыс.тенге" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.



/*1. Показатели структуры активов*/
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD colspan = 3><FONT size=""3"" face=""Times New Roman""><B>Активы</B></FONT></TD>" skip
    "<TD colspan = 3><FONT size=""3"" face=""Times New Roman""><B>Пассивы</B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Наименование</B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Сальдо </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Доля в валюте баланса </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Наименование</B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Сальдо </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Доля в валюте баланса </B></FONT></TD>" skip
    "</TR>" skip.
/*1-group*/
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #D8BFD8"" colspan = 6><FONT size=""2"" face=""Times New Roman""><B>Группа I</B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Касса и драг.металлы</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 1 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Счета до востребования клиентов</B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Корсчета в НБ РК и БВУ</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 2  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Межбанковские займы и вклады</B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 8 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Срочные требования  к  НБ РК</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 3  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Срочные вклады    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.

put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Межбанковские займы и вклады </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 4  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Прямое Репо    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 9 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Торговый портфель ценных бумаг  </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 5  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Прочие пассивы    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 5 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 10 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Обратное Репо</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 6  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 11 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + "</FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 7 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman"">
    <B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    v-act-perc = v-act-perc + (round(wrk-act.sum / v-act * 100,2)).
    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 6 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas  then do:
    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>" + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>" + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
    v-pas-perc = v-pas-perc + (round(wrk-pas.sum / v-pas * 100,2)).
    end.

/*2-group*/
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #D8BFD8"" colspan = 6><FONT size=""2"" face=""Times New Roman""><B>Группа II</B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Банковские займы - брутто</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 1  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Счета до востребования клиентов</B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в т.ч. займы по кредитн. карточкам и овердрафт</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 6 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 7 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Межбанковские займы и вклады </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 2  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Срочные вклады     </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 8 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Дебиторы по документарным расчетам</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 3  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Межбанковские займы и вклады    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.

put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Портфель ценных бумаг до погашения </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act   then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Обязательства п/д Правительством и проч. фин. и нефин. орган-ми</B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 9 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Заимствования путем выпуска ценных бумаг    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Субординированный долг  </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Собственный капитал   </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Кредиторы по документарным расчетам  </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 5 and wrk-act.crc = 0  no-lock no-error.
    if avail wrk-act   then
    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman"">
    <B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman"">
    <B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    v-act-perc = v-act-perc + (round(wrk-act.sum / v-act * 100,2)).

    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 9 and wrk-pas.crc = 0  no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(wrk-pas.sum / 1000),".",",") + "</B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + "</B></FONT></TD>" skip
    "</TR>" skip.
     v-pas-perc = v-pas-perc + (round(wrk-pas.sum / v-pas * 100,2)).

/*3-group*/
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #D8BFD8"" colspan = 6><FONT size=""2"" face=""Times New Roman""><B>Группа III</B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Инвестицонный портфель</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Собственный капитал </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 5 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Осн. сред-ва и нематер-ные активы  </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act   then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Прочие пассивы     </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Прочие активы</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 3  and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act   then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Счета до востребования клиентов   </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 6 no-lock no-error.
    if avail wrk-act then
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 4 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act   then
    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman"">
    <B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    v-act-perc = v-act-perc + (round(wrk-act.sum / v-act * 100,2)).
    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(wrk-pas.sum / 1000),".",",") + "</B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + "</B></FONT></TD>" skip
    "</TR>" skip.
    v-pas-perc = v-pas-perc + (round(wrk-pas.sum / v-pas * 100,2)).

put stream fond unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>Итого активы - нетто</B></FONT></TD>" skip.
    put stream fond unformatted
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>" + replace(string(v-act / 1000),".",",") +  "</B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>" + replace(string(v-act-perc),".",",") +  " </B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>Итого пассивы </B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>" + replace(string(v-pas / 1000),".",",") +  "</B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(v-pas-perc),".",",") + "  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond unformatted
"</TABLE> <br><br>" skip.

{html-end.i "stream fond" }

output stream fond close.
unix silent cptwin fond.html excel.exe.
pause 0.

/*расшифровка по курсам*/
/*run fond1.*/
