/*lcpfpost.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        IMLC: Post Finance Details - Postings
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-1-13 опция Postings
 * AUTHOR
        24/10/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
*/

{global.i}
define stream m-out.

def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.
def shared var s-sts    like lcevent.sts.
def shared var s-lcprod  as char.
def shared var s-ourbank as char no-undo.

def var v-crcc    as char no-undo.
def var v-acc     as char no-undo.
def var v-comacc  as char no-undo.
def var v-bank    as char no-undo.
def var v-nazn    as char no-undo.
def var v-sum     as deci no-undo.
def var v-dacc    as char no-undo.
def var v-cacc    as char no-undo.

def temp-table wrk
    field num    as int
    field numdis as char
    field bank   as char
    field dc     as char
    field gldes  as char
    field rem    as char
    field jdt    as date
    field acc    as char
    field gl     as int
    field sum    as deci
    field cur    as char
    index ind1 is primary num.

def var i as int.
def var k as int.

define query qt for wrk.
define browse bt query qt
    displ wrk.numdis label "№"          format "x(3)"
          wrk.bank   label "Bank"       format "x(5)"
          wrk.dc     label "Dt/Ct"      format "x(2)"
          wrk.acc    label "Client Acc" format "x(20)"
          wrk.gl     label "Ledger Acc" format "999999"
          wrk.gldes  label "Ledger Account  Description" format "x(30)"
          wrk.sum    label "Amount"     format ">>>,>>>,>>9.99"
          wrk.cur    label "CCY"        format "x(3)"
          wrk.jdt    label "Value Dt"   format "99/99/99"
          wrk.rem    label "Narrative"  format "x(30)"
          with width 115 row 8 15 down overlay no-label title "Postings" NO-ASSIGN SEPARATORS.

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
   if avail crc then v-crcc = crc.code.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'AccPay' no-lock no-error.
if not avail lch or (avail lch and lch.value1 = '') then do:
   message 'There is no deal for ' + s-lc + '!' view-as alert-box error.
   return.
end.
v-acc = lch.value1.

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then v-comacc = lch.value1.
if v-comacc = '' then do:
    message "Field Commissions Debit Account is empty!" view-as alert-box.
    return.
end.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'FinAmt' no-lock no-error.
if not avail lceventh or lceventh.value1 = '' then do:
    message "Field Financing Amount is empty!" view-as alert-box error.
    return.
end.
v-sum = deci(lceventh.value1).


/*********POSTINGS**********/
k = 0.
i = 1.
/*1-st posting*/
assign v-dacc = "185512"
       v-cacc = v-acc
       v-bank = s-ourbank
       v-nazn  = 'Оплата основного долга по ' + s-lc.

find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.
k = k + 1.
/*debit*/
create wrk.
assign wrk.numdis = string(i)
       wrk.bank   = v-bank
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lceventres then lceventres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lceventres then lceventres.amt else v-sum
       wrk.jdt    = if avail lceventres then lceventres.jdt  else g-today
       wrk.rem    = if avail lceventres then lceventres.rem  else v-nazn
       wrk.gl     = int(wrk.acc).

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*credit*/
k = k + 1.
create wrk.
assign wrk.num  = k
       wrk.bank = v-bank
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lceventres then lceventres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lceventres then lceventres.amt else v-sum
       wrk.jdt  = if avail lceventres then lceventres.jdt  else g-today
       wrk.rem  = if avail lceventres then lceventres.rem  else v-nazn.

find first fun where fun.fun = wrk.acc no-lock no-error.
if avail fun then wrk.gl = fun.gl.

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*2-nd posting*/
i = i + 1.
assign v-dacc = '650510'
       v-cacc = v-comacc
       v-bank = lc.bank
       v-nazn = 'Требования/обязательства по ' + s-lc.

find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.

/*debit*/
k = k + 1.
create wrk.
assign wrk.numdis = string(i)
       wrk.bank   = v-bank
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lceventres then lceventres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lceventres then lceventres.amt else v-sum
       wrk.jdt    = if avail lceventres then lceventres.jdt  else g-today
       wrk.rem    = if avail lceventres then lceventres.rem  else v-nazn
       wrk.gl     = int(wrk.acc).

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*credit*/
k = k + 1.
create wrk.
assign wrk.bank = v-bank
       wrk.num  = k
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lceventres then lceventres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lceventres then lceventres.amt else v-sum
       wrk.jdt  = if avail lceventres then lceventres.jdt  else g-today
       wrk.rem  = if avail lceventres then lceventres.rem  else v-nazn
       wrk.gl   = 600510.

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/* */
on choose of btn-e do:
    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
    /*put stream m-out unformatted "<h3>Future postings</h3><br>" skip*/
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Bank / Банк</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Number / Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Description / Наменование Балансового счета</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount / Сумма</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency / Курс</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Value Date/Дата операции</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Narrative / Комментарии</td></tr>" skip.

    for each wrk no-lock:
        put stream m-out unformatted
        "<tr>".
        if wrk.numdis <> '' then put stream m-out unformatted "<td rowspan = 2>" wrk.numdis "</td>" .
        put stream m-out unformatted
        "<td>" wrk.bank "</td>"
        "<td>" wrk.dc "</td>"
        "<td>`" string(wrk.acc) "</td>"

        "<td>`" string(wrk.gl) "</td>"
        "<td>" wrk.gldes "</td>"

        "<td>" replace(replace(trim(string(wrk.sum,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td>"
        "<td>" wrk.cur "</td>"
        "<td>" string(wrk.jdt,'99/99/9999') "</td>"
        "<td>" wrk.rem "</td></tr>" skip.
    end.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin impl_postings.htm excel.
end.

OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW. /*or choose of btn-e.*/
