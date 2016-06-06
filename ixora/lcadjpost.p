/*lcadjpost.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Adjust - вывод проводок
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
        13/07/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        19/08/2011 id00810 - использование реквизита ArpAcc (lceventh)
        14/12/2011 id00810 - для случая crc = 1
        29/03/2012 id00810 - корректировка алгоритма опеределения счета ГК по Дт 1-ой проводки, ввод переменной v-dt для определения даты
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
*/

{global.i}
define stream m-out.

def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.
def shared var s-sts    like lcevent.sts.
def shared var s-lcprod  as char.

def var v-opt     as char no-undo.
def var v-sum     as deci no-undo.
def var v-crc     as int  no-undo.
def var v-crcc    as char no-undo.
def var v-dacc    as char no-undo.
def var v-cacc    as char no-undo.
def var v-arp     as char no-undo.
def var v-arp_hq  as char no-undo.
def var v-gld     as int  no-undo.
def var v-glc     as int  no-undo.
def var v-ptype   as char no-undo.
def var v-nazn    as char no-undo.
def var v-scorr   as char no-undo.
def var v-acctype as char no-undo.
def var v-accnum  as char no-undo.
def var v-bank1   as char no-undo.
def var v-bank2   as char no-undo.
def var v-dt      as date no-undo.
def var i         as int  no-undo.
def var k         as int  no-undo.

def temp-table wrk
    field num    as int
    field numdis as char
    field bank   as char
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
          wrk.bank   label "Bank"       format "x(5)"
          wrk.dc     label "Dt/Ct"      format "x(2)"
          wrk.acc    label "Client Acc" format "x(20)"
          wrk.gl     label "Leger Acc"  format "999999"
          wrk.gldes  label "Leger Account  Description" format "x(30)"
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
find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'Opt' no-lock no-error.
if not avail lceventh or lceventh.value1 = '' then return.
v-opt = lceventh.value1.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'CurCode' no-lock no-error.
if not avail lceventh or lceventh.value1 = '' then do:
    message "Field Currency Code is empty!" view-as alert-box error.
    return.
end.
v-crc = integer(lceventh.value1).

find first crc where crc.crc = v-crc no-lock no-error.
if avail crc then v-crcc = crc.code.

if v-opt = 'yes' then do:
    find first sysc where sysc.sysc = 'LCARP' no-lock no-error.
    if avail sysc then do:
        if num-entries(sysc.chval) >= v-crc then v-arp = entry(v-crc,sysc.chval).
        else do:
            message "The value LCARP in SYSC is empty!" view-as alert-box error.
            return.
        end.
    end.
    if v-arp = '' then do:
        message "The value LCARP in SYSC is empty!" view-as alert-box error.
        return.
    end.
end.
else do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ArpAcc' no-lock no-error.
    if avail lceventh then v-arp = lceventh.value1.
    if v-arp = '' then do:
        message "Field ARP Account is empty!" view-as alert-box error.
        return.
    end.
end.

find first pksysc where pksysc.sysc = 'ILCARP' no-lock no-error.
if avail pksysc then do:
    if num-entries(pksysc.chval) >= v-crc then v-arp_hq = entry(v-crc,pksysc.chval).
    else do:
        message "The value ILCARP in pksysc is empty!" view-as alert-box error.
        return.
    end.
end.

if v-arp_hq = '' then do:
    message "The value ILCARP in pksysc is empty!" view-as alert-box error.
    return.
end.

/*if v-crc > 1 then do:*/
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'SCor202' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message "Field Sender's Correspondent (MT 202) is empty!" view-as alert-box error.
        return.
    end.
    v-scorr = lceventh.value1.

/*end.*/

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'PAmt' no-lock no-error.
if not avail lceventh or lceventh.value1 = '' then do:
    message "Field Payment Amount is empty!" view-as alert-box error.
    return.
end.
v-sum = deci(lceventh.value1).

if v-opt = 'yes' then do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'AccType' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message "Field Account Type is empty!" view-as alert-box error.
        return.
    end.
    v-acctype = lceventh.value1.

    find first codfr where codfr.codfr = 'lcacctype'
                       and codfr.code  = v-acctype
                       no-lock no-error.

    if avail codfr then v-acctype = substr(codfr.name[1],1,6).

    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'AccNum' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message "Field Account Number is empty!" view-as alert-box error.
        return.
    end.
    v-accnum = lceventh.value1.
end.

/*********POSTINGS**********/
k = 0.
i = 1.

if v-opt = 'yes' then assign v-nazn  = 'Перевод покрытия по ' + s-lc
                             v-bank1 = s-ourbank
                             v-bank2 = 'TXB00'.
else do:
    assign v-nazn  = 'Расчеты по ' + s-lc
           v-bank1 = 'TXB00' .
    find first lc where lc.lc = s-lc no-lock no-error.
    if avail lc then v-bank2 = lc.bank.
end.

/*1-st posting*/
if v-opt = 'yes' then assign v-dacc = v-accnum
                             v-cacc = v-arp.
else do:
    if v-crc > 1 then do:
        find first LCswtacc where LCswtacc.accout = v-scorr and LCswtacc.crc = v-crc no-lock no-error.
        if avail LCswtacc then assign v-dacc = LCswtacc.acc
                                      v-gld  = lcswtacc.gl.
    end.
    else do:
        find first arp where arp.arp = v-scorr no-lock no-error.
        if avail arp then assign v-dacc = arp.arp
                                 v-gld  = arp.gl.
    end.
    assign  v-cacc = v-arp_hq
            v-glc  = 287090.
end.

find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.
v-dt = if avail lceventres then lceventres.jdt  else g-today.
k = k + 1.
/*debit*/
create wrk.
assign wrk.numdis = string(i)
       wrk.bank   = v-bank1
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lceventres then lceventres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lceventres then lceventres.amt else v-sum
       wrk.jdt    = v-dt
       wrk.rem    = if avail lceventres then lceventres.rem  else v-nazn.

if v-opt = 'yes' then wrk.gl = /*int(wrk.acc)*/ /*285511*/ int(v-acctype).
                 else wrk.gl = v-gld.
find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*credit*/
k = k + 1.
create wrk.
assign wrk.bank = v-bank1
       wrk.num  = k
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lceventres then lceventres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lceventres then lceventres.amt else v-sum
       wrk.jdt  = v-dt
       wrk.rem  = if avail lceventres then lceventres.rem  else v-nazn.

if v-opt = 'yes' then do:
    find first arp where arp.arp = wrk.acc no-lock no-error.
    if avail arp then wrk.gl = arp.gl.
end.
else wrk.gl = v-glc.

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*2-nd posting*/

i = i + 1.
if v-opt = 'yes' then assign v-dacc = v-arp
                             v-cacc = v-arp_hq
                             v-glc  = 287090.
else assign v-dacc = v-arp_hq
            v-cacc = v-arp
            v-gld  = 287090
            v-glc  = 287090.

find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.

/*debit*/
k = k + 1.
create wrk.
assign wrk.numdis = string(i)
       wrk.bank   = v-bank1
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lceventres then lceventres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lceventres then lceventres.amt else v-sum
       wrk.jdt    = v-dt
       wrk.rem    = if avail lceventres then lceventres.rem  else v-nazn.

if v-opt = 'yes' then do:
    find first arp where arp.arp = wrk.acc no-lock no-error.
    if avail arp then wrk.gl = arp.gl.
end.
else wrk.gl = v-gld.

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*credit*/
k = k + 1.
create wrk.
assign wrk.bank = v-bank2
       wrk.num  = k
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lceventres then lceventres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lceventres then lceventres.amt else v-sum
       wrk.jdt  = v-dt
       wrk.rem  = if avail lceventres then lceventres.rem  else v-nazn
       wrk.gl   = v-glc.

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/* 3-rd posting*/
i = i + 1.
if v-opt = 'yes' then do:
    assign v-dacc = v-arp_hq
           v-gld  = 287090.
    if v-crc = 1 then find first LCswtacc where LCswtacc.crc = v-crc no-lock no-error.
                 else find first LCswtacc where LCswtacc.accout = v-scorr and LCswtacc.crc = v-crc no-lock no-error.
    if avail LCswtacc then assign v-cacc = LCswtacc.acc
                                  v-glc  = lcswtacc.gl.
end.
else assign v-dacc = v-arp
            v-cacc = '186082'
            v-gld  = 287090
            v-glc  = 186082.

find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.

/*debit*/
k = k + 1.
create wrk.
assign wrk.numdis = string(i)
       wrk.bank   = v-bank2
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lceventres then lceventres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lceventres then lceventres.amt  else v-sum
       wrk.jdt    = v-dt
       wrk.rem    = if avail lceventres then lceventres.rem  else v-nazn
       wrk.gl     = v-gld.

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/*credit*/
k = k + 1.
create wrk.
assign wrk.bank = v-bank2
       wrk.num  = k
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lceventres then lceventres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lceventres then lceventres.amt  else v-sum
       wrk.jdt  = v-dt
       wrk.rem  = if avail lceventres then lceventres.rem  else v-nazn
       wrk.gl   = v-glc.

find first gl where gl.gl = wrk.gl no-lock no-error.
if avail gl then wrk.gldes = trim(gl.des).

/* */
on choose of btn-e do:
    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank</h3>" skip
    /*put stream m-out unformatted "<h3>Future postings</h3><br>" skip*/
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Bank / Банк</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Leger Account  Number / Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Leger Account  Description / Наменование Балансового счета</td>"
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
