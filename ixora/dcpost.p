/*dcpost.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC,ODC - вывод проводок
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-8-1-1, 14-8-1-2 опция Postings
 * AUTHOR
        28/12/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        08/02/2012 id00810 - для ODC
        06.03.2012 Lyubov  - "dc" изменила на "idc"
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
        20/09/2013 Luiza   - ТЗ 1916 изменение поиска записи в таблице tarif2
*/

{global.i}
define stream m-out.

def shared var s-lc     like lc.lc.
def shared var s-lcprod  as char.

def var v-sum     as decimal.
def var v-crc     as integer.
def var v-crcc    as char.
def var v-dacc    as char.
def var v-cacc    as char.
def var v-arp     as char.
def var v-nazn    as char.
def var v-bank1   as char init 'TXB00'.

def temp-table wrk
    field num    as int
    field numdis as char
    field bank   as char
    field dc     as char
    field gldes  as char
    field rem    as char
    field jdt    as date
    FIELD acc    AS CHAR
    FIELD gl     AS int
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
          wrk.gl     label "Ledger Acc"  format "999999"
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

{LC.i}

v-crc = 1.
find first crc where crc.crc = v-crc no-lock no-error.
if avail crc then v-crcc = crc.code.

if s-lcprod = 'idc' then do:
    find first pksysc where pksysc.sysc = s-lcprod + 'arp' no-lock no-error.
    if avail pksysc then do:
        if num-entries(pksysc.chval) >= v-crc then v-arp = entry(v-crc,pksysc.chval).
        else do:
            message "The value " + s-lcprod + "arp in pksysc is empty!" view-as alert-box error.
            return.
        end.
    end.
    if v-arp = '' then do:
        message "The value " + s-lcprod + " in pksysc is empty!" view-as alert-box error.
        return.
    end.
end.
find first lch where lch.lc = s-lc and lch.kritcode = 'Number' no-lock no-error.
if not avail lch or lch.value1 = '' then do:
    message "Field Number is empty!" view-as alert-box error.
    return.
end.
v-sum = deci(lch.value1).

/*********POSTINGS**********/
/* number of documents*/
if s-lcprod = 'idc' then assign v-dacc = v-arp
                               v-cacc = '824000'
                               v-nazn  = 'Поступление документов на инкассо, ' + s-lc.
else assign v-dacc = '715030'
            v-cacc = '815000'
            v-nazn  = 'Отправка документов на инкассо, ' + s-lc.
find first lcres where lcres.lc = s-lc and lcres.dacc = v-dacc and lcres.cacc = v-cacc no-lock no-error.
i = 1.
k = 1.
/*debit*/
create wrk.
assign wrk.numdis = string(i)
       wrk.bank   = v-bank1
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lcres then lcres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lcres then lcres.amt  else v-sum
       wrk.jdt    = if avail lcres then lcres.jdt  else g-today
       wrk.rem    = if avail lcres then lcres.rem  else v-nazn
       wrk.gl     = if s-lcprod = 'idc' then 724000 else int(v-dacc).
find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*credit*/
k = k + 1.
create wrk.
assign wrk.bank = v-bank1
       wrk.num  = k
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lcres then lcres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lcres then lcres.amt  else v-sum
       wrk.jdt  = if avail lcres then lcres.jdt  else g-today
       wrk.rem  = if avail lcres then lcres.rem  else v-nazn
       wrk.gl   = int(v-cacc).
find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/* commissions */
find first lcres where lcres.lc = s-lc and lcres.com and lcres.amt > 0  no-lock no-error.
if avail lcres then do:
    for each lcres where lcres.lc = s-lc and lcres.com and lcres.amt > 0 no-lock:
        find first crc where crc.crc = lcres.crc no-lock no-error.
        i = i + 1.
        k = k + 1.
        create wrk.
        assign wrk.acc    = lcres.dacc
               wrk.dc     = 'Dt'
               wrk.num    = k
               wrk.bank   = s-ourbank
               wrk.numdis = string(i)
               wrk.sum    = lcres.amt
               wrk.cur    = if avail crc then crc.code else ''
               wrk.jdt    = if lcres.jh > 0 then lcres.jdt else g-today
               wrk.rem    = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.
        find first aaa where aaa.aaa = lcres.dacc no-lock no-error.
        if avail aaa then do:
            find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lcres.levD and trxlev.gl = aaa.gl no-lock no-error.
            if avail trxlev then do:
                wrk.gl = trxlev.glr.
                find first gl where gl.gl = aaa.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.
        end.

        k = k + 1.
        create wrk.
        assign wrk.dc   = 'Ct'
               wrk.num  = k
               wrk.bank = s-ourbank
               wrk.acc  = lcres.cacc
               wrk.sum  = lcres.amt
               wrk.cur  = if avail crc then crc.code else ''
               wrk.jdt  = if lcres.jh > 0 then lcres.jdt else g-today
               wrk.rem  = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.
        find first tarif2 where tarif2.str5 = trim(lcres.comcode) /*tarif2.num  = substr(lcres.comcode,1,1) and tarif2.kod = substr(lcres.comcode,2)*/ and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then do:
            assign wrk.gl = tarif2.kont.
            wrk.gldes = tarif2.pakal.
        end.
    end.
end.

/* */
on choose of btn-e do:
    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
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
