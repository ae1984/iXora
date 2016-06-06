/*lcpost3.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        External Charges - вывод проводок
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    18/04/2011 id00810 - перекомпиляция
    14/06/2011 id00810 - назначение платежа
    22/07/2011 id00810 - добавлены новые виды оплат комиссий
    23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
*/

{global.i}
{LC.i}

define stream m-out.
def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.
def shared var s-sts    like lcevent.sts.
def var v-mlist1 as char no-undo init 'ComPType,Curcode,ComAmt'.
def var v-mlist2 as char no-undo.
def var v-krit   as char no-undo.
def var v-sum    as deci no-undo extent 3.
def var v-crc    as int  no-undo.
def var v-type   as char no-undo.
def var v-spgl   as char no-undo.
def var v-pair   as char no-undo.
def var v-acc    as char no-undo.
def var v-dacc   as char no-undo.
def var v-cacc   as char no-undo.
def var v-gl     as int  no-undo.
def var v-gldes  as char no-undo.
def var v-dgl    as int  no-undo.
def var v-cgl    as int  no-undo.
def var v-dgldes as char no-undo.
def var v-cgldes as char no-undo.
def var v-sumt   as deci no-undo.
def var v-nazn   as char no-undo.
def var v-nazn1  as char no-undo.
def var i        as int  no-undo.
def var k        as int  no-undo.
def var l        as int  no-undo.

def temp-table wrk  no-undo
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

find first lcevent where lcevent.bank = s-ourbank and lcevent.lc = s-lc and lcevent.event = s-event and lcevent.number = s-number no-lock no-error.
if not avail lcevent then return.

do i = 1 to num-entries(v-mlist1):
    v-krit = entry(i,v-mlist1).
    find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = v-krit no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        find first lckrit where lckrit.datacode = v-krit no-lock no-error.
        if avail lckrit then do:
            if trim(v-mlist2) <> '' then v-mlist2 = v-mlist2 + ','.
            v-mlist2 = v-mlist2 + lckrit.dataName.
        end.
    end.
end.
if trim(v-mlist2) <> '' then do:
    message 'The following fields are compulsory to complete:~n~n"'  + v-mlist2 + '"' view-as alert-box.
    return.
end.

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'ComPtype' no-lock no-error.
v-type = lceventh.value1.

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'CurCode' no-lock no-error.
v-crc = int(lceventh.value1).

find first crc where crc.crc = v-crc no-lock no-error.
if not avail crc then return.

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'ComAmt' no-lock no-error.
v-sum[1] = deci(lceventh.value1).

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'AmtTax' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-sum[2] = deci(lceventh.value1).

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'PAmt' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-sum[3] = deci(lceventh.value1). else v-sum[3] = v-sum[1] - v-sum[2].

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'SCor202' no-lock no-error.
if v-crc > 1 and v-type <> '5' then
if not avail lceventh or (avail lceventh and lceventh.value1 = '') then do:
    message "The field Sender's Correspondent (MT 202) or Correspondent Bank is compulsory to complete!" view-as alert-box.
    return.
end.

find first pksysc where pksysc.sysc = 'extch_trx' + v-type + (if v-crc = 1 then string(v-crc) else '') no-lock no-error.
if not avail pksysc then do:
    message "There is no record extch_trx" + v-type + (if v-crc = 1 then string(v-crc) else "") + " in pksysc file!" view-as alert-box error.
    return.
end.
assign v-spgl  = pksysc.chval
       v-nazn  = 'Оплата комиссии инобанка ' + s-lc
       v-nazn1 = 'Корпоративный подоходный налог у источника выплаты с доходов нерезидента '  + s-lc.

do i = 1 to num-entries(v-spgl,';'):
    if v-crc > 1  then do:
        if v-type = '1' and v-sum[i] = 0 then next.
        if v-type = '2' then v-sum[i] = v-sum[1].
        if v-type = '3' and i < 3 then v-sum[i] = v-sum[i + 1].
        if v-type = '4' and i = 1 then v-sum[1] = v-sum[3].
    end.
    else v-sum[i] = v-sum[1].
    v-sumt = 0.
    v-pair = entry(i,v-spgl,';').
    do l = 1 to 2:
        find first gl where gl.gl = int(entry(l,v-pair)) no-lock no-error.
        if not avail gl then return.
        assign v-gl =  gl.gl v-gldes = gl.des.
        if gl.subled = '' then v-acc = string(gl.gl).
        else if gl.subled = 'arp' then do:
            if v-gl <> 285110 then do:
                find first pksysc where pksysc.sysc = 'ILCARP' no-lock no-error.
                if avail pksysc then do:
                    if num-entries(pksysc.chval) >= v-crc then v-acc = entry(v-crc,pksysc.chval).
                    else do:
                        message "The value ILCARP in pksysc is empty!" view-as alert-box error.
                        return.
                    end.
                end.
            end.
            else do:
                find first sysc where sysc.sysc = 'nlg022' no-lock no-error.
                if not avail sysc then do:
                    message "There is no record nlg022 in bank.sysc file!" view-as alert-box error.
                    return.
                end.
                v-acc = sysc.chval.
            end.
            find first arp where arp.arp = v-acc no-lock no-error.
            if not avail arp then return.
        end.
        else if gl.subled = 'fun' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'AccPay' no-lock no-error.
            if not avail lch or lch.value1 = '' then do:
                message 'There is no deal for ' + s-lc + '!' view-as alert-box error.
                return.
            end.
            v-acc = lch.value1.
            find first fun where fun.fun = v-acc no-lock no-error.
            if not avail fun then return.
        end.
        else if gl.subled = 'dfb' then do:
            if v-crc > 1 then do:
                find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'SCor202' no-lock no-error.
                if avail lceventh and lceventh.value1 <> '' then do:
                    find first LCswtacc where LCswtacc.accout = lceventh.value1 and LCswtacc.crc = v-crc no-lock no-error.
                    if avail LCswtacc then v-acc = LCswtacc.acc.
                    else return.
                end.
                else return.
            end.
            else do:
                find first LCswtacc where LCswtacc.crc = v-crc no-lock no-error.
                if avail LCswtacc then v-acc = LCswtacc.acc.
                else return.
            end.
            find first dfb where dfb.dfb = v-acc no-lock no-error.
            if not avail dfb then return.
            v-gl = dfb.gl.
        end.
        if l = 1 then assign v-dacc   = v-acc
                             v-dgl    = v-gl
                             v-dgldes = v-gldes.
                 else assign v-cacc   = v-acc
                             v-cgl    = v-gl
                             v-cgldes = v-gldes.
    end.

    find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.
    k = k + 1.
    /*debit*/
    create wrk.
    assign wrk.numdis = string(i)
           wrk.num    = k
           wrk.dc     = 'Dt'
           wrk.acc    = if avail lceventres then lceventres.dacc else v-dacc
           wrk.gl     = v-dgl
           wrk.gldes  = v-dgldes
           wrk.jdt    = if avail lceventres then lceventres.jdt else g-today
           wrk.rem    = if avail lceventres then lceventres.rem else if v-cgl = 285110 then v-nazn1 else v-nazn.

    if v-crc > 1 and (v-cgl = 285110 or string(v-dgl) begins '5' or string(v-cgl) begins '4') then do:
        if avail lceventres then do:
            if lceventres.jdt  = g-today then v-sumt = round(v-sum[i] * crc.rate[1],2).
            else do:
                find first crchis where crchis.crc = v-crc and crchis.rdt = lceventres.jdt no-lock no-error.
                if not avail crchis then return.
                v-sumt = round(lceventres.amt * crchis.rate[1],2).
            end.
        end.
        else v-sumt = round(v-sum[i] * crc.rate[1],2).
        if string(v-dgl) begins '5' then
        assign wrk.cur = 'KZT'
               wrk.sum = v-sumt.
    end.
    if v-crc > 1 and string(v-dgl) begins '5' then assign wrk.cur = 'KZT'
                                                          wrk.sum = v-sumt.
    else assign wrk.sum    = if avail lceventres then lceventres.amt else v-sum[i]
                wrk.cur    = crc.code.

    /*Credit*/
    k = k + 1.
    create wrk.
    assign wrk.num    = k
           wrk.dc     = 'Ct'
           wrk.acc    = if avail lceventres then lceventres.cacc else v-cacc
           wrk.gl     = v-cgl
           wrk.gldes  = v-cgldes
           wrk.jdt    = if avail lceventres then lceventres.jdt else g-today
           wrk.rem    = if avail lceventres then lceventres.rem else if v-cgl = 285110 then v-nazn1 else v-nazn.
    if v-crc > 1 and (v-cgl = 285110 or string(v-cgl) begins '4') then assign wrk.cur = 'KZT'
                                                                              wrk.sum = v-sumt.
    else assign wrk.sum    = if avail lceventres then lceventres.amt else v-sum[i]
                wrk.cur    = crc.code.
end.

on choose of btn-e do:

    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
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
