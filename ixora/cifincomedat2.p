/* cifincomedat2.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Отчет по операционным доходам за период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.1.16.6.3
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        03.10.2011 damir - не отбирать сторнированные проводки.
        30.04.2013 damir - Внедрено Т.З. № 1805.
*/
def input parameter p-bank as char.
def input parameter p-dte  as date.
def input parameter p-dtb  as date.

def shared temp-table filpay no-undo
    field filid as char
    field bankfrom as char
    field bankto as char
    field iik as char
    field cif as char
    field jhcom as inte
    field gl as inte
    field jhamt as deci decimals 2
index idx1 iik ascending.

def temp-table filtemp
    field id as char
    field bankfrom as char
    field bankto as char
    field iik as char
    field cif as char
    field jhcom as inte.

for each filpayment where filpayment.rdt >= p-dte and filpayment.rdt <= p-dtb no-lock:
    create filtemp.
    filtemp.id = filpayment.id.
    filtemp.bankfrom = filpayment.bankfrom.
    filtemp.bankto = filpayment.bankto.
    filtemp.iik = filpayment.iik.
    filtemp.cif = filpayment.cif.
    filtemp.jhcom = filpayment.jhcom.
end.

for each filtemp where filtemp.bankfrom = p-bank no-lock:
    find first txb.jl where txb.jl.jh = filtemp.jhcom and txb.jl.dc = "C" and txb.jl.gl <> 0 and txb.jl.crc <> 0 no-lock no-error.
    if avail txb.jl then do:
        find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
        if avail txb.jh and txb.jh.party matches "*storn*" then next.

        find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.regdt <= txb.jl.jdt no-lock no-error.

        create filpay.
        filpay.filid = filtemp.id.
        filpay.bankfrom = filtemp.bankfrom.
        filpay.bankto = filtemp.bankto.
        filpay.iik = filtemp.iik.
        filpay.cif = filtemp.cif.
        filpay.jhcom = filtemp.jhcom.
        filpay.gl = txb.jl.gl.
        filpay.jhamt = txb.jl.cam * txb.crchis.rate[1].
    end.
end.





