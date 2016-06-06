/* lcpfsch.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        IMLC: Post Finance Details - Repaiment Schedule
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-1-13 опция Repaiment Schedule
 * AUTHOR
        21/10/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
*/

{global.i}
define stream m-out.
def shared var s-lc       like lc.lc.
def shared var s-event    like lcevent.event.
def shared var s-number   like lcevent.number.
def shared var s-sts      like lcevent.sts.
def shared var s-lcprod   as   char.
def shared var v-cif      as   char.
def shared var v-cifname  as   char.
def shared var s-ourbank as char no-undo.

def var v-crc     as char no-undo.
def var i         as int  no-undo.
def var v-base    as int  no-undo.
def buffer b-lcevent  for lcevent.

def temp-table wrk no-undo
    field num    as int
    field cur    as char
    field famt   as deci
    field arate  as deci
    field sdate  as date
    field npdate as date
    field adays  as int
    field apay   as deci
    index ind1 is primary num.

define query qt for wrk.
define browse bt query qt
    displ wrk.num    label "№"                          format ">9"
          wrk.cur    label "CCY"                        format "x(03)"
          wrk.famt   label "Financing Amount"           format ">>>,>>>,>>9.99"
          wrk.arate  label "All in Financing Rate"      format ">9.99"
          wrk.sdate  label "Start Date"                 format "99/99/99"
          wrk.npdate label "Next Payment Date"          format "99/99/99"
          wrk.adays  label "Amount of days"             format ">>9"
          wrk.apay   label "Amount to pay"              format ">>>,>>>,>>9.99"
          with width 110 row 8 15 down overlay no-label title " Repayment Schedule " NO-ASSIGN SEPARATORS.
def button btn-e   label  " Print in Excel  ".

DEFINE FRAME ft
    bt   SKIP(1)
    btn-e SKIP
    WITH width 115 1 COLUMN SIDE-LABELS
    NO-BOX.

on "end-error" of frame ft do:
    hide frame ft no-pause.
end.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
if avail lch then do:
   find first crc where crc.crc = int(lch.value1) no-lock no-error.
   if avail crc then v-crc = crc.code.
end.

find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'base' no-lock no-error.
if avail lceventh and lceventh.value1 ne '' then v-base = int(lceventh.value1).

for each b-lcevent where b-lcevent.bank = s-ourbank and b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number <= s-number no-lock:
    i = i + 1.
    create wrk.
    assign wrk.num = i
           wrk.cur = v-crc.

    find first lceventh where lceventh.bank = b-lcevent.bank and lceventh.lc = b-lcevent.lc and lceventh.event = b-lcevent.event and lceventh.number = b-lcevent.number and lceventh.kritcode = 'FinAmt' no-lock no-error.
    if avail lceventh then wrk.famt = deci(lceventh.value1).

    find first lceventh where lceventh.bank = b-lcevent.bank and lceventh.lc = b-lcevent.lc and lceventh.event = b-lcevent.event and lceventh.number = b-lcevent.number and lceventh.kritcode = 'AllFRate' no-lock no-error.
    if avail lceventh then wrk.arate = deci(lceventh.value1).

    find first lceventh where lceventh.bank = b-lcevent.bank and lceventh.lc = b-lcevent.lc and lceventh.event = b-lcevent.event and lceventh.number = b-lcevent.number and lceventh.kritcode = 'StartDt' no-lock no-error.
    if avail lceventh then wrk.sdate = date(lceventh.value1).

    find first lceventh where lceventh.bank = b-lcevent.bank and lceventh.lc = b-lcevent.lc and lceventh.event = b-lcevent.event and lceventh.number = b-lcevent.number and lceventh.kritcode = 'NextPdt' no-lock no-error.
    if avail lceventh then wrk.npdate = date(lceventh.value1).
    assign wrk.adays =  wrk.npdate - wrk.sdate
           wrk.apay  = round(wrk.famt * wrk.arate / 100 * wrk.adays / v-base,2).
end.
on choose of btn-e do:

    output stream m-out to schedule.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc  + "</b><br>"
                                 "<b>Repayment Schedule / График погашения " + "</b></p>".

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Financing Amount </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">All in Financing Rate </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Start Date </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Next Payment Date </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount of days </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount to pay </td></tr>" skip.

    for each wrk no-lock:
        put stream m-out unformatted
        "<tr>".
        put stream m-out unformatted
        "<td>" wrk.num "</td>"
        "<td>" wrk.cur "</td>"
        "<td>" replace(replace(trim(string(wrk.famt,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td>"
        "<td>" replace(replace(trim(string(wrk.arate,'>9.99')),',',' '),'.',',') "</td>"
        "<td>" string(wrk.sdate,'99/99/9999') "</td>"
        "<td>" string(wrk.npdate,'99/99/9999') "</td>"
        "<td>" string(wrk.adays,'>>9') "</td>"
        "<td>" replace(replace(trim(string(wrk.apay,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td>"
        "</td></tr>" skip.
    end.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin schedule.htm excel.
end.

OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW. /*or choose of btn-e.*/