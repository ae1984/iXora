/* LCpost2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advise of Amendment - вывод проводок
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
       07/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        21.06.2012 Lyubov  - проводки по EXPG образуются иначе, 220310 -> 286920, 286920 -> 4612(20\11)
*/

{global.i}
def stream m-out.
def shared var s-lc       as char.
def shared var s-lcamend  like lcamend.lcamend.
def shared var s-lcprod   as char.

def var v-comacc    as char no-undo.
def var v-sum       as deci no-undo.
def var i           as int  no-undo.
def var k           as int  no-undo.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com and lcamendres.amt <> 0 no-lock no-error.
if not avail lcamendres then return.

find first lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'ComAcc' no-lock no-error.
if avail lcamendh then v-comacc = lcamendh.value1.
if v-comacc = '' then do:
    message "Field Client's Account is empty!" view-as alert-box.
    return.
end.

def temp-table wrk no-undo
    field num    as int
    field numdis as char
    field dc     as char
    field gldes  as char
    field rem    as char
    field jdt    as date
    FIELD acc    AS CHAR
    FIELD gl     AS integer
    field sum    as decimal
    field cur    as char
    index ind1 is primary num.

define query qt for wrk.
define browse bt query qt
    displ wrk.numdis label "№"          format "x(3)"
          wrk.dc     label "Dt/Ct"      format "x(2)"
          wrk.acc    label "Client Acc" format "x(20)"
          wrk.gl     label "Ledger Acc" format "999999"
          wrk.gldes  label "Ledger Account Description" format "x(30)"
          wrk.sum    label "Amount"     format ">>>,>>>,>>9.99"
          wrk.cur    label "CCY"        format "x(3)"
          wrk.jdt    label "Value Dt"   format "99/99/99"
          wrk.rem    label "Narrative"  format "x(30)"
          with width 115 row 8 15 down overlay no-label title " Postings for Advise of Amendment " NO-ASSIGN SEPARATORS.
def button btn-e   label  " Print in Excel  ".

DEFINE FRAME ft
    bt   SKIP(1)
    btn-e SKIP
    WITH width 115 1 COLUMN SIDE-LABELS
    NO-BOX.

on "end-error" of frame ft do:
    hide frame ft no-pause.
end.

/* commissions */
for each lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com and lcamendres.amt <> 0 no-lock:
    i = i + 1.
    k = k + 1.
    create wrk.
    assign wrk.acc    = lcamendres.dacc
           wrk.dc     = 'Dt'
           wrk.num    = k
           wrk.numdis = string(i)
           wrk.sum    = lcamendres.amt.
    find first aaa where aaa.aaa = lcamendres.dacc no-lock no-error.
    if avail aaa then do:
        find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lcamendres.levD and trxlev.gl = aaa.gl no-lock no-error.
        if avail trxlev then do:
            wrk.gl = trxlev.glr.
            find first gl where gl.gl = aaa.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.
    find first crc where crc.crc = lcamendres.crc no-lock no-error.
    if avail crc then wrk.cur = crc.code.

    if lcamendres.jh > 0 then wrk.jdt = lcamendres.jdt.
    else wrk.jdt = g-today.
    wrk.rem = lcamendres.rem.

    k = k + 1.
    create wrk.
    assign wrk.dc   = 'Ct'
           wrk.num  = k
           wrk.acc  = lcamendres.cacc
           wrk.sum  = lcamendres.amt.
   find first tarif2 where tarif2.str5 = lcamendres.comcode and tarif2.stat = 'r' no-lock no-error.
   if avail tarif2 then do:
       if s-lcprod = 'EXPG'then do:
            assign wrk.gl = 286920
                   wrk.acc = '286920'.
                   find gl where gl.gl = wrk.gl no-lock no-error.
                   if avail gl then wrk.gldes = gl.des.
       end.
   end.
   else assign wrk.gl    = tarif2.kont
               wrk.gldes = tarif2.pakal.
   find first crc where crc.crc = lcamendres.crc no-lock no-error.
   if avail crc then wrk.cur = crc.code.

   if lcamendres.jh > 0 then wrk.jdt = lcamendres.jdt.
   else wrk.jdt = g-today.
   wrk.rem = lcamendres.rem.

   if s-lcprod = 'EXPG' then do:
    k = k + 1.
    create wrk.
    assign wrk.dc  = 'Dt'
           wrk.num = k
           wrk.gl = 286920
           wrk.acc = '286920'.
           find gl where gl.gl = wrk.gl no-lock no-error.
           if avail gl then wrk.gldes = gl.des.
           wrk.sum = lcamendres.amt.
           find first crc where crc.crc = lcamendres.crc no-lock no-error.
           if avail crc then wrk.cur = crc.code.
           if lcamendres.jh > 0 then wrk.jdt = lcamendres.jdt.
           else wrk.jdt = g-today.
           wrk.rem = if num-entries(lcamendres.rem,';') = 2 then entry(1,lcamendres.rem,';') else lcamendres.rem.

    k = k + 1.
    create wrk.
    assign wrk.dc  = 'Ct'
           wrk.num = k.
        find first tarif2 where tarif2.num  = substr(lcamendres.comcode,1,1) and tarif2.kod = substr(lcamendres.comcode,2) and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then
           assign
           wrk.gl = tarif2.kont
           wrk.acc = string(tarif2.kont)
           wrk.gldes = tarif2.pakal.
           wrk.sum = lcamendres.amt.
           find first crc where crc.crc = lcamendres.crc no-lock no-error.
           if avail crc then wrk.cur = crc.code.
           if lcamendres.jh > 0 then wrk.jdt = lcamendres.jdt.
           else wrk.jdt = g-today.
           wrk.rem = if num-entries(lcamendres.rem,';') = 2 then entry(1,lcamendres.rem,';') else lcamendres.rem.
   end.
end.

for each lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com no-lock:
    v-sum = v-sum + lcamendres.amt.
end.

find first aaa where aaa.aaa = v-comacc no-lock no-error.
if avail aaa then do:
    if v-sum > aaa.cbal - aaa.hbal then do:
        message " Lack of the balance Client's Account! " view-as alert-box.
        return.
    end.
end.

on choose of btn-e do:

    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>MetroComBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> MetroComBank</h3>" skip
    /*put stream m-out unformatted "<h3>Future postings</h3><br>" skip*/
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc + "</b><br>"
                                 "<b>Amendment No / Номер изменения " + string(s-lcamend) + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account Number / Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account Description / Наменование Балансового счета</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount / Сумма</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency / Курс</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Value Date/Дата операции</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Narrative / Комментарии</td></tr>" skip.

    for each wrk no-lock:
        put stream m-out unformatted
        "<tr>".
        if wrk.numdis <> '' then put stream m-out unformatted "<td rowspan = 2>" wrk.numdis "</td>".
        put stream m-out unformatted
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
