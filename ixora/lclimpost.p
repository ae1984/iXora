/* lclimpost.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Limit - вывод проводок
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14.7.1.1 опция posting
 * AUTHOR
       21/09/2011 id00810
 * BASES
        BANK COMM
        06/06/12 Lyubov - не выводим удаленные проводки (если есть jh, но нет jl)
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
 * CHANGES
*/

{global.i}
define stream m-out.
def shared var s-cif       as char.
def shared var s-number    as int.
def shared var v-cifname   as char.
def shared var s-ourbank   as char no-undo.

def var v-revolv    as char no-undo.
def var v-amount    as char no-undo.
def var v-crc       as int  no-undo.
def var v-dacc      as char no-undo init '612530'.
def var v-cacc      as char no-undo init '662530'.
def var v-text      as char no-undo init 'возобновляемым'.
def var i           as int  no-undo.
def var k           as int  no-undo.
def var v-logsno    as char init "no,n,нет,н,1".
def buffer b-lclimitres for lclimitres.

find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = s-cif and lclimit.number = s-number no-lock no-error.
if not avail lclimit then return.

find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'Revolv' no-lock no-error.
if avail lclimith then v-revolv = lclimith.value1.
if lookup(v-revolv,v-logsno) > 0 then assign v-dacc = '612540' v-cacc = '662540' v-text = 'невозобновляемым'.

find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'Amount' no-lock no-error.
if avail lclimith then v-amount = lclimith.value1.
if v-amount = '' then do:
    message "Field Amount is empty!" view-as alert-box error.
    return.
end.
find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = 'lcCrc' no-lock no-error.
if avail lclimith then v-crc = int(lclimith.value1).
if v-crc = 0 then do:
    message "Field Currency Code is empty!" view-as alert-box error.
    return.
end.
find first crc where crc.crc = v-crc no-lock no-error.
if not avail crc then return.

def temp-table wrk
    field num    as int
    field numdis as char
    field dc     as char
    field gldes  as char
    field rem    as char
    field jdt    as date
    field acc    as char
    field gl     as int
    field sum    as deci
    field cur    as char
    index ind1 is primary num.

define query qt for wrk.
define browse bt query qt
    displ wrk.numdis label "№"          format "x(3)"
          wrk.dc     label "Dt/Ct"      format "x(2)"
          wrk.acc    label "Client Acc" format "x(20)"
          wrk.gl     label "Leger Acc"  format "999999"
          wrk.gldes  label "Leger Account Description" format "x(30)"
          wrk.sum    label "Amount"     format ">>>,>>>,>>>,>>9.99"
          wrk.cur    label "CCY"        format "x(3)"
          wrk.jdt    label "Value Dt"   format "99/99/99"
          wrk.rem    label "Narrative"  format "x(30)"
          with width 115 row 8 15 down overlay no-label title "Postings" NO-ASSIGN SEPARATORS.

def button btn-e   label  " Print in Excel  ".

DEFINE FRAME ft
    bt    SKIP(1)
    btn-e SKIP
    WITH width 115 1 COLUMN SIDE-LABELS
    NO-BOX.

on "end-error" of frame ft do:
    hide frame ft no-pause.
end.

empty temp-table wrk.

/*1-st posting*/
i = 1.
find first lclimitres where lclimitres.bank = s-ourbank and lclimitres.cif = s-cif and lclimitres.number = s-number and lclimitres.dacc = v-dacc and lclimitres.cacc = v-cacc no-lock no-error.
k = k + 1.
/*debit*/
create wrk.
assign wrk.numdis = string(i)
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lclimitres then lclimitres.dacc else v-dacc
       wrk.gl     = int(wrk.acc)
       wrk.cur    = crc.code
       wrk.sum    = if avail lclimitres then lclimitres.amt  else deci(v-amount)
       wrk.jdt    = if avail lclimitres then lclimitres.jdt  else g-today
       wrk.rem    = if avail lclimitres then lclimitres.rem  else 'Создание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname.
find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*Credit*/
k = k + 1.
create wrk.
assign wrk.num = k
       wrk.dc  = 'Ct'
       wrk.acc = if avail lclimitres then lclimitres.cacc else v-cacc
       wrk.gl  = int(wrk.acc)
       wrk.cur = crc.code
       wrk.sum = if avail lclimitres then lclimitres.amt  else deci(v-amount)
       wrk.jdt = if avail lclimitres then lclimitres.jdt  else g-today
       wrk.rem = if avail lclimitres then lclimitres.rem  else 'Создание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname.

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/* the rest postings */
if avail lclimitres then
    for each b-lclimitres where b-lclimitres.bank = lclimitres.bank and b-lclimitres.cif = lclimitres.cif and b-lclimitres.number = lclimitres.number and b-lclimitres.lc <> '' and b-lclimitres.jh > 0 no-lock.
    find first jl where jl.jh = b-lclimitres.jh no-lock no-error.
    if not avail jl then next.
        i = i + 1.
        k = k + 1.
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num    = k
               wrk.dc     = 'Dt'
               wrk.acc    = b-lclimitres.dacc
               wrk.gl     = int(wrk.acc)
               wrk.cur    = crc.code
               wrk.sum    = b-lclimitres.amt
               wrk.jdt    = b-lclimitres.jdt
               wrk.rem    = b-lclimitres.rem.
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

        k = k + 1.
        create wrk.
        assign wrk.num    = k
               wrk.dc     = 'Cr'
               wrk.acc    = b-lclimitres.cacc
               wrk.gl     = int(wrk.acc)
               wrk.cur    = crc.code
               wrk.sum    = b-lclimitres.amt
               wrk.jdt    = b-lclimitres.jdt
               wrk.rem    = b-lclimitres.rem.
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
end.

on choose of btn-e do:

    output stream m-out to lclim_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                 "<p><b>Client / Клиент  " + s-cif + '  ' + v-cifname skip
                                 "<p><b>Limit for Letters of Credit No / Номер лимита " + string(s-number) + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Leger Account  Number / Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Leger Account  Description / Наменование Балансового счета</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount / Сумма</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency / Курс</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Value Date/Дата операции</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Narrative / Комментарии</td></tr>" skip.

    for each wrk  no-lock:

        put stream m-out unformatted
        "<tr>".
        if wrk.numdis <> '' then put stream m-out unformatted "<td rowspan = 2>" wrk.numdis "</td>".
        put stream m-out unformatted
        "<td>" wrk.dc "</td>"
        "<td>`" string(wrk.acc) "</td>"
        "<td>`" string(wrk.gl) "</td>"
        "<td>" wrk.gldes "</td>"
        "<td>" replace(replace(trim(string(wrk.sum,'>>>,>>>,>>>,>>9.99')),',',' '),'.',',') "</td>"
        "<td>" wrk.cur "</td>"
        "<td>" string(wrk.jdt,'99/99/9999') "</td>"
        "<td>" wrk.rem "</td></tr>" skip.
    end.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin lclim_postings.htm excel.
end.

OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.