/* corpos.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Вывод проводок
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
       18.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
define stream m-out.
def shared var s-lc      as char.
def shared var v-lcsts  as char.
def shared var s-lcprod  as char.
def shared var s-ourbank as char no-undo.

def var v-sum       as deci no-undo.
def var v-sum1      as deci no-undo.
def var v-sum2      as deci no-undo.
def var v-levD      as int  no-undo.
def var v-levC      as int  no-undo.
def var i           as int  no-undo.
def var k           as int  no-undo.
def var v-date      as date no-undo init 08/01/2011.
def var v-yes       as logi no-undo init false.
def buffer b-crc for crc.

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
    field kkk    as char
    index ind1 is primary num.

define query qt for wrk.
define browse bt query qt
    displ wrk.numdis label "№"          format "x(3)"
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
k = 0.

find lc where lc.lc = s-lc no-lock no-error.
if avail lc then if lctype = "E" then v-yes = true.


/*Commission postings*/
find first lcres where lcres.lc = s-lc no-lock no-error.
if avail lcres then do:
    for each lcres where lcres.lc = s-lc and lcres.com and lcres.amt > 0 no-lock:

        i = i + 1.
        k = k + 1.
        create wrk.
        assign wrk.acc = lcres.dacc
               wrk.dc  = 'Dt'
               wrk.num = k
               wrk.numdis = string(i)
               wrk.gl = int(wrk.acc).
               find first gl where gl.gl = wrk.gl no-lock no-error.
               if avail gl then wrk.gldes = trim(gl.des).
               wrk.sum = lcres.amt.

        find first crc where crc.crc = lcres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if lcres.jh > 0 then wrk.jdt = lcres.jdt.
        else wrk.jdt = g-today.
        wrk.rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.

        if v-yes then do:
            k = k + 1.
            create wrk.
            assign wrk.acc = '286920'
                   wrk.dc  = 'Ct'
                   wrk.num = k
                   wrk.gl = int(wrk.acc).
                   find first gl where gl.gl = wrk.gl no-lock no-error.
                   if avail gl then wrk.gldes = trim(gl.des).
                   wrk.sum = lcres.amt.

            find first crc where crc.crc = lcres.crc no-lock no-error.
            if avail crc then wrk.cur = crc.code.

            if lcres.jh > 0 then wrk.jdt = lcres.jdt.
            else wrk.jdt = g-today.
            wrk.rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.

            k = k + 1.
            create wrk.
            assign wrk.acc = '286920'
                   wrk.dc  = 'Dt'
                   wrk.num = k
                   wrk.gl = int(wrk.acc).
                   find first gl where gl.gl = wrk.gl no-lock no-error.
                   if avail gl then wrk.gldes = trim(gl.des).
                   wrk.sum = lcres.amt.
            find first crc where crc.crc = lcres.crc no-lock no-error.
            if avail crc then wrk.cur = crc.code.

            if lcres.jh > 0 then wrk.jdt = lcres.jdt.
            else wrk.jdt = g-today.
            wrk.rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.

        end.

        k = k + 1.
        create wrk.
        assign wrk.acc = lcres.cacc
               wrk.dc  = 'Ct'
               wrk.num = k.
        find first tarif2 where tarif2.num  = substr(lcres.comcode,1,1) and tarif2.kod = substr(lcres.comcode,2) and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then
            assign wrk.gl = tarif2.kont
                   wrk.gldes = tarif2.pakal.
                   wrk.sum = lcres.amt.
        find first crc where crc.crc = lcres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if lcres.jh > 0 then wrk.jdt = lcres.jdt.
        else wrk.jdt = g-today.
        wrk.rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.
    end.
end.
if v-lcsts <> 'FIN' then do:
    for each lcres where lcres.lc = s-lc and lcres.com = yes no-lock:
        v-sum1 = v-sum1 + lcres.amt.
    end.
end.
on choose of btn-e do:

    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank</h3>" skip
                                 "<p><b>Correspondence No / Номер Корреспонденции " + s-lc + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Number / ~n Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Description / Наменование Балансового счета</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount / Сумма</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency / Курс</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Narrative / Комментарии</td>" skip.

    for each wrk no-lock:
        put stream m-out unformatted
        "<tr>".

        if wrk.numdis <> '' then do:
            if v-yes then put stream m-out unformatted "<td rowspan = 4>" wrk.numdis "</td>".
            else put stream m-out unformatted "<td rowspan = 2>" wrk.numdis "</td>".
        end.

        put stream m-out unformatted
        "<td>" wrk.dc "</td>"
        "<td>`" string(wrk.acc) "</td>"

        "<td>`" string(wrk.gl) "</td>"
        "<td>" wrk.gldes "</td>"

        "<td>" replace(replace(trim(string(wrk.sum,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td>"
        "<td>" wrk.cur "</td>"
        "<td>" wrk.rem "</td>" skip.
    end.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin impl_postings.htm excel.
end.

OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW. /*or choose of btn-e.*/