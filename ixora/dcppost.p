/*dcppost.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC, ODC - Payment: вывод проводок
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
        13/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
define stream m-out.

def shared var s-lc     like lc.lc.
def shared var s-lcpay  like lcpay.lcpay.
def shared var s-paysts like lcpay.sts.
def shared var s-lcprod as char.
def shared var v-cif    as char.

def var v-sum      as deci no-undo.
def var v-com      as deci no-undo.
def var v-comi     as deci no-undo.
def var v-crc      as int  no-undo.
def var v-crcc     as char no-undo.
def var v-collacc  as char no-undo.
def var v-comacc   as char no-undo.
def var v-dacc     as char no-undo.
def var v-cacc     as char no-undo.
def var v-levD     as int  no-undo.
def var v-levC     as int  no-undo.
def var v-sum2     as deci no-undo.
def var v-sum3     as deci no-undo.
def var v-arp      as char no-undo.
def var v-arp_hq   as char no-undo.
def var v-arpgl    as int  no-undo.
def var v-aaagl    as int  no-undo.
def var v-gld      as int  no-undo.
def var v-glc      as int  no-undo.
def var v-nazn     as char no-undo.
def var v-date     as char no-undo.
def var v-scorr    as char no-undo.
def var v-bank     as char no-undo.
def var v-bankd    as char no-undo.
def var v-bankc    as char no-undo.
def var i          as int  no-undo.
def var k          as int  no-undo.
def var j          as int  no-undo.
def var l          as int  no-undo.
def var m          as int  no-undo.
def var v-idc      as logi no-undo.
def var v-comacct  as char no-undo.
def var v-comaccti as char no-undo.
def var v-numlim   as int  no-undo.
def var v-revolv   as logi no-undo.
def var v-limcrc   as int  no-undo.
def var v-crcclim  as char no-undo.
def var v-lim-amt  as deci no-undo.
def var v-name     as char no-undo init "Drawer's Account".
def var v-par      as char no-undo.
def var v-glddes   as char no-undo.
def var v-glcdes   as char no-undo.

def buffer b-crc for crc.
def buffer b-crchis for crchis.

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
          wrk.gl     label "Ledger Acc" format "999999"
          wrk.gldes  label "Ledger Account  Description" format "x(30)"
          wrk.sum    label "Amount"     format ">>>,>>>,>>9.99"
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

{LC.i}
find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Currency Code is empty!" view-as alert-box error.
    return.
end.
v-crc = integer(lcpayh.value1).

find first crc where crc.crc = v-crc no-lock no-error.
if avail crc then v-crcc = crc.code.

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
find first arp where arp.arp = v-arp no-lock no-error.
if not avail arp then do:
    message "The ARP-account " + v-arp + " was not found!" view-as alert-box error.
    return.
end.
find first sub-cod where sub-cod.acc   = arp.arp
                     and sub-cod.sub   = "arp"
                     and sub-cod.d-cod = "clsa"
                     no-lock no-error.
if avail sub-cod then if sub-cod.ccode ne "msc" then do:
    message "The ARP-account " + v-arp + " is closed!" view-as alert-box error.
    return.
end.
v-arpgl = arp.gl.

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
if v-crc > 1 then do:
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'SCor202' no-lock no-error.
    if not avail lcpayh or lcpayh.value1 = '' then do:
        message "Field Correspondent Bank is empty!" view-as alert-box error.
        return.
    end.
    v-scorr = lcpayh.value1.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then v-comacc = lch.value1.
else do:
    if v-comacc = '' then do:
        message "Field Commissions Debit Account is empty!" view-as alert-box error.
        return.
    end.
end.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Amount is empty!" view-as alert-box error.
    return.
end.
v-sum = deci(lcpayh.value1).

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'Number' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Number is empty!" view-as alert-box error.
    return.
end.
v-sum2 = deci(lcpayh.value1).

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtE' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).

if v-com > 0 then do:
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAccT' no-lock no-error.
    if avail lcpayh then if lcpayh.value1 ne '' then v-comacct = lcpayh.value1.
    if v-comacct = '' then do:
        message "Field Commission Account Type(amt excl.VAT) is empty!" view-as alert-box error.
        return.
    end.
end.
find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtI' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then v-comi = deci(lcpayh.value1).

if v-comi > 0 then do:
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAccTI' no-lock no-error.
    if avail lcpayh then if lcpayh.value1 ne '' then v-comaccti = lcpayh.value1.
    if v-comaccti = '' then do:
        message "Field Commission Account Type(amt incl.VAT) is empty!" view-as alert-box error.
        return.
    end.
end.

if s-lcprod = 'idc' then v-name = 'Document Account'.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CollAcc' no-lock no-error.
if avail lcpayh then v-collacc = lcpayh.value1.
if v-collacc = '' then do:
    message "Field " + v-name + " is empty!" view-as alert-box.
    return.
end.
find first aaa where aaa.aaa = v-collacc no-lock no-error.
if not avail aaa then do:
    message "The CIF-account " + v-collacc + " was not found!" view-as alert-box error.
    return.
end.
find first sub-cod where sub-cod.acc   = aaa.aaa
                     and sub-cod.sub   = "cif"
                     and sub-cod.d-cod = "clsa"
                     no-lock no-error.
if avail sub-cod then if sub-cod.ccode ne "msc" then do:
    message "The CIF-account " + v-collacc + " is closed!" view-as alert-box error.
    return.
end.
if s-lcprod = 'idc' then do:
    run lonbalcrc('cif',aaa.aaa,g-today,'1',yes,aaa.crc, output v-sum3).
    v-sum3 = v-sum3 * (-1).
    if v-sum > v-sum3 then do:
        message "Lack of the balance of the " + v-name + "!" view-as alert-box.
        return.
    end.
end.
v-aaagl = aaa.gl.

find first pksysc where pksysc.sysc = s-lcprod + '_acc' no-lock no-error.
if not avail pksysc then do:
    message "The value " + s-lcprod + "_acc in the table pksysc is empty!" view-as alert-box error.
    return.
end.
v-par = pksysc.chval.
if num-entries(v-par) <> 4 then do:
    message "Uncorrect structure of parameter " + s-lcprod + "_acc in the table pksysc!" view-as alert-box error.
    return.
end.

/*********POSTINGS**********/
k = 0.
i = 0.
v-nazn = 'Оплата по документарному инкассо ' + s-lc.
do j = 1 to 3:
    if s-lcprod = 'odc' then do:
        if j = 1 then do:
            find first LCswtacc where LCswtacc.accout = v-scorr and LCswtacc.crc = v-crc no-lock no-error.
            if avail LCswtacc then assign v-dacc = LCswtacc.acc v-gld = lcswtacc.gl.
            assign v-cacc  = v-arp_hq
                   v-glc   = v-arpgl
                   v-bankd = 'TXB00'
                   v-bankc = 'TXB00'.
        end.
        else if j = 2 then assign v-dacc  = v-arp_hq
                                  v-gld   = v-arpgl
                                  v-cacc  = v-arp
                                  v-glc   = v-arpgl
                                  v-bankD = 'TXB00'
                                  v-bankC = s-ourbank.
        else assign v-dacc  = v-arp
                    v-gld   = v-arpgl
                    v-cacc  = v-collacc
                    v-glc   = v-aaagl
                    v-bankD = s-ourbank
                    v-bankC = s-ourbank.
    end.
    else do:
        if j = 1 then do:
            assign v-dacc  = v-collacc
                   v-gld   = v-aaagl
                   v-cacc  = v-arp
                   v-glc   = v-arpgl
                   v-bankd = s-ourbank
                   v-bankc = s-ourbank.
        end.
        else if j = 2 then assign v-dacc  = v-arp
                                  v-gld   = v-arpgl
                                  v-cacc  = v-arp_hq
                                  v-glc   = v-arpgl
                                  v-sum   = v-sum - v-com - v-comi
                                  v-bankD = s-ourbank
                                  v-bankC = 'TXB00'.
        else do:
            find first LCswtacc where LCswtacc.accout = v-scorr and LCswtacc.crc = v-crc no-lock no-error.
            if avail LCswtacc then assign v-cacc = LCswtacc.acc v-glc = lcswtacc.gl.
            assign v-dacc  = v-arp_hq
                   v-gld   = v-arpgl
                   v-bankD = 'TXB00'
                   v-bankC = 'TXB00'.
        end.
    end.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.

    i = i + 1.
    k = k + 1.
    /*debit*/
    create wrk.
    assign wrk.numdis = string(i)
           wrk.bank   = v-bankD
           wrk.num    = k
           wrk.dc     = 'Dt'
           wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
           wrk.gl     = v-gld
           wrk.cur    = v-crcc
           wrk.sum    = if avail lcpayres then lcpayres.amt  else v-sum
           wrk.jdt    = if avail lcpayres then lcpayres.jdt  else g-today
           wrk.rem    = if avail lcpayres then lcpayres.rem  else v-nazn.

    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

    /*credit*/
    k = k + 1.
    create wrk.
    assign wrk.bank = v-bankC
           wrk.num  = k
           wrk.dc   = 'Ct'
           wrk.acc  = if avail lcpayres then lcpayres.cacc else v-cacc
           wrk.gl   = v-glc
           wrk.cur  = v-crcc
           wrk.sum  = if avail lcpayres then lcpayres.amt else v-sum
           wrk.jdt  = if avail lcpayres then lcpayres.jdt  else g-today
           wrk.rem  = if avail lcpayres then lcpayres.rem  else v-nazn.

     find first gl where gl.gl = wrk.gl no-lock no-error.
     if avail gl then wrk.gldes = trim(gl.des).
end.

/* комиссии для idc */
if v-com > 0 then do:
    /* excluding VAT */
    i = i + 1.
    assign v-dacc = v-arp
           v-cacc = v-comacct.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode = '9990' and lcpayres.levC = 1 and lcpayres.dacc = v-dacc and lcpayres.cacc = v-cacc no-lock no-error.
    k = k + 1.

    create wrk.
    assign wrk.numdis = string(i)
           wrk.bank   = s-ourbank
           wrk.num    = k
           wrk.dc     = 'Dt'
           wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
           wrk.gl     = v-arpgl
           wrk.sum    = if avail lcpayres then lcpayres.amt else v-com
           wrk.cur    = v-crcc
           wrk.jdt    = if avail lcpayres then lcpayres.jdt else g-today
           wrk.rem    = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc.
    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

    k = k + 1.
    create wrk.
    assign wrk.bank   = s-ourbank
           wrk.num = k
           wrk.dc  = 'Ct'
           wrk.acc = if avail lcpayres then lcpayres.cacc else v-cacc
           wrk.sum = if avail lcpayres then lcpayres.amt else v-com
           wrk.cur = v-crcc
           wrk.jdt = if avail lcpayres then lcpayres.jdt else g-today
           wrk.rem = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc
           wrk.gl  = int(wrk.acc).

    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).
end.
if v-comi > 0 then do:
    /* including VAT */
    i = i + 1.
    assign v-dacc = v-arp
           v-cacc = v-comaccti.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode = '9990' and lcpayres.levC = 1 and lcpayres.dacc = v-dacc and lcpayres.cacc = v-cacc no-lock no-error.
    k = k + 1.

    create wrk.
    assign wrk.numdis = string(i)
           wrk.bank   = s-ourbank
           wrk.num    = k
           wrk.dc     = 'Dt'
           wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
           wrk.gl     = v-arpgl
           wrk.sum    = if avail lcpayres then lcpayres.amt else v-comi
           wrk.cur    = v-crcc
           wrk.jdt    = if avail lcpayres then lcpayres.jdt else g-today
           wrk.rem    = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc.
    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

    k = k + 1.
    create wrk.
    assign wrk.bank   = s-ourbank
           wrk.num = k
           wrk.dc  = 'Ct'
           wrk.acc = if avail lcpayres then lcpayres.cacc else v-cacc
           wrk.sum = if avail lcpayres then lcpayres.amt else v-comi
           wrk.cur = v-crcc
           wrk.jdt = if avail lcpayres then lcpayres.jdt else g-today
           wrk.rem = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc
           wrk.gl  = int(wrk.acc).

    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).
end.

v-nazn = 'Списание отправленных на инкассо документов по ' + s-lc.
do m = 1 to 4 by 2:
    find first gl where gl.gl = int(entry(m,v-par)) no-lock no-error.
    if not avail gl then do:
        message "Uncorrect account GL " + entry(m,v-par) + " (parameter " + s-lcprod + "_acc in the table pksysc)!" view-as alert-box error.
        return.
    end.
    if gl.sub = '' then do:
        if m = 1 then assign v-dacc      = string(gl.gl)
                             v-gld       = gl.gl
                             v-glddes    = trim(gl.des).
        else assign v-cacc   = string(gl.gl)
                    v-glc    = gl.gl
                    v-glcdes = trim(gl.des).
    end.
    else if gl.sub = 'arp' then do:
        if m = 1 then assign v-dacc      = entry(m + 1,v-par)
                             v-gld       = gl.gl
                             v-glddes    = trim(gl.des).
                 else assign v-cacc      = entry(m + 1,v-par)
                             v-glc       = gl.gl
                             v-glcdes = trim(gl.des).
    end.
end.

find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
i = i + 1.
k = k + 1.
/*debit*/
create wrk.
assign wrk.numdis = string(i)
       wrk.bank   = 'TXB00'
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
       wrk.cur    = 'KZT'
       wrk.sum    = if avail lcpayres then lcpayres.amt  else v-sum2
       wrk.jdt    = if avail lcpayres then lcpayres.jdt  else g-today
       wrk.rem    = if avail lcpayres then lcpayres.rem  else v-nazn
       wrk.gl     = v-gld
       wrk.gldes  = v-glddes.

/*credit*/
k = k + 1.
create wrk.
assign wrk.bank  = 'TXB00'
       wrk.num   = k
       wrk.dc    = 'Ct'
       wrk.acc   = if avail lcpayres then lcpayres.cacc else v-cacc
       wrk.cur   = 'KZT'
       wrk.sum   = if avail lcpayres then lcpayres.amt  else v-sum2
       wrk.jdt   = if avail lcpayres then lcpayres.jdt  else g-today
       wrk.rem   = if avail lcpayres then lcpayres.rem  else v-nazn
       wrk.gl    = v-glc
       wrk.gldes = v-glcdes.

/* commissions from charges */
for each lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode ne '9990' and lcpayres.amt <> 0 no-lock:
    i = i + 1.
    k = k + 1.
    create wrk.
    assign wrk.bank   = lcpayres.bank
           wrk.acc    = lcpayres.dacc
           wrk.dc     = 'Dt'
           wrk.num    = k
           wrk.numdis = string(i)
           wrk.sum    = lcpayres.amt.
    find first aaa where aaa.aaa = lcpayres.dacc no-lock no-error.
    if avail aaa then do:
        find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lcpayres.levD and trxlev.gl = aaa.gl no-lock no-error.
        if avail trxlev then do:
            wrk.gl = trxlev.glr.
            find first gl where gl.gl = aaa.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.
    find first crc where crc.crc = lcpayres.crc no-lock no-error.
    if avail crc then wrk.cur = crc.code.

    if lcpayres.jh > 0 then wrk.jdt = lcpayres.jdt.
    else wrk.jdt = g-today.
    wrk.rem = lcpayres.rem.

    k = k + 1.
    create wrk.
    assign wrk.bank = lcpayres.bank
           wrk.dc   = 'Ct'
           wrk.num  = k
           wrk.acc  = lcpayres.cacc
           wrk.sum  = lcpayres.amt.
   find first tarif2 where tarif2.str5 = lcpayres.comcode and tarif2.stat = 'r' no-lock no-error.
   if avail tarif2 then
   assign wrk.gl    = tarif2.kont
          wrk.gldes = tarif2.pakal.
   find first crc where crc.crc = lcpayres.crc no-lock no-error.
   if avail crc then wrk.cur = crc.code.

   if lcpayres.jh > 0 then wrk.jdt = lcpayres.jdt.
   else wrk.jdt = g-today.
   wrk.rem = lcpayres.rem.
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
