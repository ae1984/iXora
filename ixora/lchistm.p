/* lchistm.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        History - история "жизни" продукта
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-2
 * AUTHOR
        31/10/2010 id00810
 * BASES
        BANK COMM
 * CHANGES
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
*/

{global.i}

define stream m-out.
def shared var s-lc       like lc.lc.
def shared var s-lcprod   as   char.
def shared var v-cif      as   char.
def shared var v-cifname  as   char.
def shared var s-ourbank as char no-undo.

def var v-crc     as char no-undo.
def var v-dt      as date no-undo.
def var i         as int  no-undo.
def var v-kodd    as char no-undo.
def var v-kodr    as char no-undo.
def var v-kodc    as char no-undo.
def var v-type    as char no-undo.
def var v-name    as char no-undo.
def var sp-event  as char no-undo init 'intch,extch,adjust,pfind,rclaim,authr,amdauthr,authp,discr,advicer'.
def var sp-nevent as char no-undo init 'Internal Charges,External Charges,Adjust,Post Finance Details,Reimbursement Claim,Authorisation to Reimburse,Amendment to an Authorisation to Reimburse,Authorisation to Pay, Accept or Negotiate,Advice of Discrepancy,Advice of Refusal'.
def buffer b-lcevent  for lcevent.

def temp-table wrk no-undo
    field num    as int
    field event  as char
    field number as char
    field dt     as date
    field cur    as char
    field amt    as deci
    field initby as char
    field confby as char
    index ind1 is primary num.

define query qt for wrk.
define browse bt query qt
    displ wrk.num    label "№"                          format ">9"
          wrk.event  label "Event"                      format "x(25)"
          wrk.number label "Number"                     format "x(02)"
          wrk.dt     label "Date"                       format "99/99/99"
          wrk.cur    label "CCY"                        format "x(03)"
          wrk.amt    label "Amount"                     format ">>>,>>>,>>9.99"
          wrk.initby label "Initiated by"               format "x(20)"
          wrk.confby label "Confirmed by"               format "x(20)"
          with width 110 row 8 15 down overlay no-label title " History of " + s-lc  NO-ASSIGN SEPARATORS.
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

/* create **/
i = i + 1.
create wrk.
assign wrk.num = i
       wrk.event = if lc.lctype = 'i' then 'Create' else 'Advise'
       wrk.number = ''.

v-kodd = if lc.lctype = 'i' then if s-lcprod = 'pg' then 'Date' else 'DtIs' else 'DtAdv'.
find first lch where lch.lc = s-lc and lch.kritcode = v-kodd no-lock no-error.
if avail lch then wrk.dt = date(lch.value1).

find first lch where lch.lc = s-lc and lch.kritcode = 'amount' no-lock no-error.
if avail lch then wrk.amt = deci(lch.value1).

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
if avail lch then do:
   find first crc where crc.crc = int(lch.value1) no-lock no-error.
   if avail crc then assign v-crc = crc.code wrk.cur = v-crc.
end.

find first ofc where ofc.ofc = lc.rwho no-lock no-error.
if avail ofc then wrk.initby = ofc.ofc + '/' + ofc.name.

find first lcsts where lcsts.lc = lc.lc and lcsts.sts = 'FIN' and lcsts.type = 'cre' no-lock no-error.
if avail lcsts then do:
    find first ofc where ofc.ofc = lcsts.who no-lock no-error.
    if avail ofc then wrk.confby = ofc.ofc + '/' + ofc.name.
end.
else do:
    find first lcres where lcres.lc = lc.lc and lcres.jh > 0 no-lock no-error.
    if avail lcres then do:
        find first ofc where ofc.ofc = lcres.rwho no-lock no-error.
        if avail ofc then wrk.confby = ofc.ofc + '/' + ofc.name.
    end.
end.

/* amendment */
find first lcamend where lcamend.lc = lc.lc and lcamend.sts = 'FIN' no-lock no-error.
if avail lcamend then
for each lcamend where lcamend.lc = lc.lc and lcamend.sts = 'FIN' no-lock.
    i = i + 1.
    create wrk.
    assign wrk.num    = i
           wrk.event  = if lc.lctype = 'i' then 'Amendment' else 'Advise of Amendment'
           wrk.number = string(lcamend.lcamend).

    find first lcamendh where lcamendh.bank = lcamend.bank and lcamendh.lc = lcamend.lc and lcamendh.lcamend = lcamend.lcamend and lcamendh.kritcode = 'DtAmend' no-lock no-error.
    if avail lcamendh then wrk.dt = date(lcamendh.value1).
    else wrk.dt = lcamend.rwhn.

    find first lcamendh where lcamendh.bank = lcamend.bank and lcamendh.lc = lcamend.lc and lcamendh.lcamend = lcamend.lcamend and lcamendh.kritcode = 'NewAmt' no-lock no-error.
    if avail lcamendh and lcamendh.value1 ne '' then do:
        wrk.amt = deci(lcamendh.value1).

        find first lcamendh where lcamendh.bank = lcamend.bank and lcamendh.lc = lcamend.lc and lcamendh.lcamend = lcamend.lcamend and lcamendh.kritcode = 'CrcA' no-lock no-error.
        if avail lcamendh then do:
            find first crc where crc.crc = int(lcamendh.value1) no-lock no-error.
            if avail crc then wrk.cur = crc.code.
        end.
    end.
    find first ofc where ofc.ofc = lcamend.rwho no-lock no-error.
    if avail ofc then wrk.initby = ofc.ofc + '/' + ofc.name.

    find first lcsts where lcsts.lc = lc.lc and lcsts.num = lcamend.lcamend  and lcsts.sts = 'FIN' and lcsts.type = 'amd' no-lock no-error.
    if avail lcsts then do:
        find first ofc where ofc.ofc = lcsts.who no-lock no-error.
        if avail ofc then wrk.confby = ofc.ofc + '/' + ofc.name.
    end.
end.

/* payment */
find first lcpay where lcpay.lc = lc.lc and (lcpay.sts = 'FIN' or lcpay.sts = 'PAY') no-lock no-error.
if avail lcpay then
for each lcpay where lcpay.lc = lc.lc and (lcpay.sts = 'FIN' or lcpay.sts = 'PAY') no-lock.
    i = i + 1.
    create wrk.
    assign wrk.num    = i
           wrk.event  = if s-lcprod = 'pg' then 'Claim Received' else 'Payment'
           wrk.number = string(lcpay.lcpay).
    find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'VDate' no-lock no-error.
    if avail lcpayh then wrk.dt = date(lcpayh.value1).

    find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
    if avail lcpayh then wrk.amt = deci(lcpayh.value1).

    find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
    if avail lcpayh then do:
        find first crc where crc.crc = int(lcpayh.value1) no-lock no-error.
        if avail crc then wrk.cur = crc.code.
    end.

    find first ofc where ofc.ofc = lcpay.rwho no-lock no-error.
    if avail ofc then wrk.initby = ofc.ofc + '/' + ofc.name.

    find first lcsts where lcsts.lc = lc.lc and lcsts.num = lcpay.lcpay  and lcsts.sts = lcpay.sts and lcsts.type = 'pay' no-lock no-error.
    if avail lcsts then do:
        find first ofc where ofc.ofc = lcsts.who no-lock no-error.
        if avail ofc then do:
            if ofc.ofc <> 'superman' then wrk.confby = ofc.ofc + '/' + ofc.name.
            else do:
                if lcsts.sts = 'pay' then find first lcsts where lcsts.lc = lc.lc and lcsts.num = lcpay.lcpay  and lcsts.sts = 'fin' and lcsts.type = 'pay' no-lock no-error.
                else find first lcsts where lcsts.lc = lc.lc and lcsts.num = lcpay.lcpay  and lcsts.sts = 'bo2' and lcsts.type = 'pay' no-lock no-error.
                if avail lcsts then find first ofc where ofc.ofc = lcsts.who no-lock no-error.
                if avail ofc then  wrk.confby = ofc.ofc + '/' + ofc.name.
            end.
        end.
    end.
    else do:
        find first lcpayres where lcpayres.lc = lc.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.jh > 0 no-lock no-error.
        if avail lcpayres then do:
            find first ofc where ofc.ofc = lcpayres.rwho no-lock no-error.
            if avail ofc then wrk.confby = ofc.ofc + '/' + ofc.name.
        end.
    end.
end.

/* correspondence */
for each lcswt where lcswt.lc = s-lc and lookup(lcswt.mt,'O799,I799') > 0 and lcswt.sts = 'fin' no-lock break by lcswt.mt by lcswt.lccor:
    i = i + 1.
    create wrk.
    assign wrk.num    = i
           wrk.event  = if lcswt.mt = 'O799' then 'Incoming Swift' else 'Outgoing Swift '
           wrk.number = string(lcswt.lccor)
           wrk.dt     = lcswt.rdt.
    find first ofc where ofc.ofc = lcswt.info[1] no-lock no-error.
    if avail ofc then wrk.initby = ofc.ofc + '/' + ofc.name.
    if wrk.initby = '' and lcswt.mt = 'I799' then do:
        find first lcsts where lcsts.type = '' and lcsts.lcnum = lc.lc + '_' + string(lcswt.lccor) and lcsts.sts = 'MD1' no-lock no-error.
        if avail lcsts then do:
            find first ofc where ofc.ofc = lcsts.who no-lock no-error.
            if avail ofc then  wrk.initby = ofc.ofc + '/' + ofc.name.
        end.
    end.
    if lcswt.mt = 'O799' then do:
        find first ofc where ofc.ofc = lcswt.info[2] no-lock no-error.
        if avail ofc then wrk.confby = ofc.ofc + '/' + ofc.name.
    end.
    else do:
        find first lcsts where lcsts.type = '' and lcsts.lcnum = lc.lc + '_' + string(lcswt.lccor) and lcsts.sts = 'FIN' no-lock no-error.
        if avail lcsts then do:
            find first ofc where ofc.ofc = lcsts.who no-lock no-error.
            if avail ofc then  wrk.confby = ofc.ofc + '/' + ofc.name.
        end.
    end.
end.

/* event */
find first lcevent where (lcevent.bank = lc.bank or lcevent.bank = 'TXB00') and lcevent.lc = lc.lc and lcevent.event ne 'exp' and lcevent.event ne 'cln' and lcevent.sts = 'FIN' no-lock no-error.
if avail lcevent then
for each lcevent where (lcevent.bank = lc.bank or lcevent.bank = 'TXB00') and lcevent.lc = lc.lc and lcevent.event ne 'exp' and lcevent.event ne 'cln' and lcevent.sts = 'FIN' no-lock.

    if lookup(lcevent.event,sp-event) > 0 then v-name = entry(lookup(lcevent.event,sp-event),sp-nevent).
    if lcevent.event = 'adjust' then assign v-kodr = 'PAmt'
                                            v-kodc = 'CurCode'.
    if lcevent.event = 'pfind'  then assign v-kodr = 'Amount'
                                            v-kodc = 'lcCrc'.
    if lcevent.event = 'extch'  then assign v-kodr = 'ComAmt'
                                            v-kodc = 'CurCode'.

    i = i + 1.
    create wrk.
    assign wrk.num    = i
           wrk.event  = v-name
           wrk.number = string(lcevent.number)
           wrk.dt     = lcevent.rwhn.
    if lcevent.event = 'intch' then do:
        find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = lcevent.lc and lceventh.event = lcevent.event and lceventh.number = lcevent.number and lceventh.kritcode = 'ComType' no-lock no-error.
        if avail lceventh then v-type = lceventh.value1.
        else do:
            find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = lcevent.lc and lceventh.event = lcevent.event and lceventh.number = lcevent.number and lceventh.kritcode = 'opt' no-lock no-error.
            if avail lceventh then v-type = if lceventh.value1 = 'yes' then '1' else '3'.
            else v-type = '1'.
        end.

        if v-type = '1' then do:
            for each lceventres where lceventres.lc = lcevent.lc and lceventres.event = lcevent.event and lceventres.number = lcevent.number and lceventres.com and lceventres.jh > 0 no-lock break by lceventres.crc:
                if first-of(lceventres.crc) then do:
                     find first crc where crc.crc = int(lceventres.crc) no-lock no-error.
                    if avail crc then do:
                        if wrk.cur = ''  then assign wrk.cur = crc.code.
                        else do:
                            i = i + 1.
                            create wrk.
                            assign wrk.num = i
                                   wrk.event = v-name
                                   wrk.number = string(lcevent.number)
                                   wrk.cur  = crc.code.
                        end.
                    end.
                end.
                wrk.amt = wrk.amt + lceventres.amt.
            end.
        end.
        else do:
            find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = lcevent.lc and lceventh.event = lcevent.event and lceventh.number = lcevent.number and lceventh.kritcode = 'VDate' no-lock no-error.
            if avail lceventh then wrk.dt = date(lceventh.value1).

            find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = lcevent.lc and lceventh.event = lcevent.event and lceventh.number = lcevent.number and lceventh.kritcode = 'ComAmt' no-lock no-error.
            if avail lceventh then wrk.amt = deci(lceventh.value1).

            find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = lcevent.lc and lceventh.event = lcevent.event and lceventh.number = lcevent.number and lceventh.kritcode = 'CurCode' no-lock no-error.
            if avail lceventh then do:
                find first crc where crc.crc = int(lceventh.value1) no-lock no-error.
                if avail crc then wrk.cur = crc.code.
            end.
        end.
    end.
    if lookup(lcevent.event,'adjust,pfind,extch') > 0 then do:
        find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = lcevent.lc and lceventh.event = lcevent.event and lceventh.number = lcevent.number and lceventh.kritcode = v-kodr no-lock no-error.
        if avail lceventh then wrk.amt = deci(lceventh.value1).

        find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = lcevent.lc and lceventh.event = lcevent.event and lceventh.number = lcevent.number and lceventh.kritcode = v-kodc no-lock no-error.
        if avail lceventh then do:
            find first crc where crc.crc = int(lceventh.value1) no-lock no-error.
            if avail crc then wrk.cur = crc.code.
        end.
    end.
    /*if lookup(lcevent.event,'rclaim,authr,amdauthr,advdcr,advicer') > 0 then do:
        wrk.dt = lcevent.rwhn.
    end.*/
    find first ofc where ofc.ofc = lcevent.rwho no-lock no-error.
    if avail ofc then wrk.initby = ofc.ofc + '/' + ofc.name.

    find first lcsts where lcsts.lc = lc.lc and lcsts.num = lcevent.number  and lcsts.sts = lcevent.sts and lcsts.type = lcevent.event no-lock no-error.
    if avail lcsts then do:
        find first ofc where ofc.ofc = lcsts.who no-lock no-error.
        if ofc.ofc <> 'superman' then wrk.confby = ofc.ofc + '/' + ofc.name.
        else do:
            find first lcsts where lcsts.lc = lc.lc and lcsts.num = lcevent.number  and lcsts.sts = 'bo2' and lcsts.type = lcevent.event no-lock no-error.
            if avail lcsts then find first ofc where ofc.ofc = lcsts.who no-lock no-error.
            if avail ofc then  wrk.confby = ofc.ofc + '/' + ofc.name.
        end.
    end.
end.
if lc.lcsts = 'CLS' then do:
    create wrk.
    assign wrk.num = i
           wrk.number = ''.
    find first lcevent where lcevent.bank = lc.bank and lcevent.lc = lc.lc and lookup(lcevent.event,'exp,cln') > 0 and lcevent.sts = 'FIN' no-lock no-error.
    if avail lcevent then do:
        assign wrk.event = if lcevent.event = 'exp' then 'Expire' else 'Cancel'
               /*wrk.dt    = lcevent.rwhn*/
               wrk.cur   = v-crc.
        find first lceventres where lceventres.lc = lcevent.lc and lceventres.event = lcevent.event and lceventres.number = lcevent.number and not lceventres.com no-lock no-error.
        if avail lceventres then wrk.dt = lceventres.jdt.
        find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = lcevent.lc and lceventh.event = lcevent.event and lceventh.number = lcevent.number and lceventh.kritcode = 'outbal' no-lock no-error.
        if avail lceventh then wrk.amt = deci(lceventh.value1).
        find first ofc where ofc.ofc = lcevent.rwho no-lock no-error.
        if avail ofc then wrk.initby = ofc.ofc + '/' + ofc.name.

        find first lcsts where lcsts.lc = lc.lc and lcsts.num = lcevent.number  and lcsts.sts = lcevent.sts and lcsts.type = lcevent.event no-lock no-error.
        if avail lcsts then do:
            find first ofc where ofc.ofc = lcsts.who no-lock no-error.
            if avail ofc then wrk.confby = ofc.ofc + '/' + ofc.name.
        end.
    end.
    else do:
        find first lcsts where lcsts.lc = lc.lc and lcsts.sts = 'CLS' and lcsts.type = 'cre' no-lock no-error.
        if avail lcsts then do:
            assign wrk.event = 'Expire'
                   wrk.dt    = lcsts.whn.
            find first ofc where ofc.ofc = lcsts.who no-lock no-error.
            if avail ofc then wrk.initby = ofc.ofc + '/' + ofc.name.
        end.
    end.
end.

on choose of btn-e do:

    output stream m-out to lchistory.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc  + "</b><br>"
                                 /*"<b>Repayment Schedule / График погашения " + "</b></p>"*/.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Event </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Number </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Date </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Initiated by </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Confirmed by </td></tr>" skip.

    for each wrk no-lock:
        put stream m-out unformatted
        "<tr>".
        put stream m-out unformatted
        "<td>" wrk.num "</td>"
        "<td>" wrk.event "</td>"
        "<td>" wrk.number "</td>"
        "<td>" string(wrk.dt,'99/99/9999') "</td>".
        if wrk.amt > 0 then
        put stream m-out unformatted
        "<td>" wrk.cur "</td>"
        "<td>" replace(replace(trim(string(wrk.amt,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td>".
        else put stream m-out unformatted  "<td>" "</td>"  "<td>"  "</td>".
        put stream m-out unformatted
        "<td>" wrk.initby "</td>"
        "<td>" wrk.confby "</td>"
        "</td></tr>" skip.
    end.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin lchistory.htm excel.
end.

OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW. /*or choose of btn-e.*/