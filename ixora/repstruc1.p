/* repstuc1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Сведения об изменениях в структуре активов, обязательств и капитала
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
        24/12/2012 Luiza
 * BASES
        BANK TXB
 * CHANGES
*/


def shared var dt1 as date no-undo.
def shared var dt2 as date no-undo.


DEF VAR VBANK AS CHAR.
DEF VAR vbankname AS CHAR.

FIND FIRST TXB.SYSC WHERE TXB.SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
    IF AVAIL TXB.SYSC AND TXB.SYSC.CHVAL <> '' THEN VBANK =  TXB.SYSC.CHVAL.

find first comm.txb where comm.txb.bank = VBANK no-lock no-error.
if available comm.txb then vbankname = comm.txb.info.

define shared temp-table t-salde no-undo
    field jh as int
    field jdt as date
    field tmp as char
    field dgl as int
    field dacc as char
    field dcrc as int
    field cgl as int
    field cacc as char
    field ccrc as int
    field cod as char
    field kbe as char
    field knp as char
    field dtsum as decim
    field dtsumtng as decim
    field ctsum as decim
    field ctsumtng as decim
    field rem as char
    field nameo as char
    field nameb as char
    field secek as char
    field dtop as date
    field dtcl as date
    field txb as char
    field txbname as char
    field sub as char
    field poz as int
    field ao as char
    index ind is primary txb jh.

define shared temp-table wgl no-undo
    field gl     as integer /*like gl.gl*/
    field des as character
    field lev as integer
    field subled as character /*like gl.subled*/
    field type   as character /*like gl.type*/
    field code as char
    field grp as int
    field g5 as char  /* 5 позиция балансового счета */
    field poz as int
    field ao as char
    index wgl-idx1 is unique primary gl
    index wgl-idx2  subled.

def buffer b-jl  for txb.jl.
def var kod as char.
def var kbe as char.
def var knp as char.
def var v-rem as char.
def var otp as char.
def var ben as char.
DEF VAR v-r AS CHAR.
DEF VAR v-cgr AS CHAR.
DEF VAR v-hs AS CHAR.
DEF VAR v-doc AS CHAR.
DEF VAR vop AS date.
DEF VAR vcl AS date.

function Convcrc returns decimal ( input sum as decimal, input c1 as int, input c2 as int, input d1 as date):
    define buffer bcrc1 for txb.crchis.
    define buffer bcrc2 for txb.crchis.
    if c1 <> c2 then do:
        find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
        find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
        if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
    end.
    else return sum.
end function.


/*Обороты */
    v-r = "".
    v-cgr = "".
    v-hs = "".
    otp = "".
    ben = "".
    vop = ?.
    vcl = ?.
    for each txb.jl where txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2 no-lock:
        find first wgl where wgl.gl = txb.jl.gl no-error.
        if available wgl then do:
            case wgl.subled:

                when "cif" then do:
                    find first txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
                    if available txb.aaa then do:
                        find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                        if avail txb.cif then do:
                            find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                            if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
                            find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
                            if available txb.acvolt then vcl = date(txb.acvolt.x3).
                            else vcl = txb.aaa.expdt.
                        end.
                    end. /* if available txb.aaa */
                end.
                when "ARP" then do:
                    find last txb.arp where txb.arp.arp = txb.jl.acc use-index arp no-lock no-error.
                    if available txb.arp then do:
                        find last txb.sub-cod where txb.sub-cod.sub = 'arp' and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                        if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
                        vop = txb.arp.rdt.
                        vcl = txb.arp.spdt.
                    end.
                end.
                when "fun" then do:
                    find last txb.fun where txb.fun.fun = txb.jl.acc use-index fun no-lock no-error.
                    if available txb.fun then do:
                        vop = txb.fun.rdt.
                        vcl = txb.fun.duedt.
                        find last txb.sub-cod where txb.sub-cod.sub = 'fun' and txb.sub-cod.acc = txb.fun.fun and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                        if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
                        else  v-cgr = '4'.
                    end.
                end.
                when "dfb" then do:
                    find last txb.dfb where txb.dfb.dfb = txb.jl.acc use-index dfb no-lock no-error.
                    if available txb.dfb then do:
                        if txb.dfb.gl ge 105100 and txb.dfb.gl lt 105200 then v-cgr = '3'.
                        else v-cgr = '4'.
                        vop = txb.dfb.rdt.
                        vcl = txb.dfb.duedt.
                    end.
                end.
                when "lon" then do:
                    find last txb.lon where txb.lon.lon = txb.jl.acc use-index lon no-lock no-error.
                    if available txb.lon then do:
                        find last txb.cif where txb.cif.cif eq txb.lon.cif use-index cif no-lock no-error.
                        if available txb.cif then do:
                            find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                            if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
                        end.
                        vop = txb.lon.rdt.
                        vcl = txb.lon.duedt.
                    end.
                end.
                when "scu" then do:
                    find last txb.scu where txb.scu.scu = txb.jl.acc use-index scu no-lock no-error.
                    if available txb.scu then do:
                        v-cgr = txb.scu.type. /* сектор экономики */
                        find first txb.deal where txb.deal.deal = txb.scu.scu no-lock no-error.
                        if available txb.deal then do:
                            vop = txb.deal.regdt.
                            vcl = txb.deal.maturedt.
                        end.
                        else do:
                            vop = txb.scu.ddt[1].
                            vcl = txb.scu.cdt[1].
                        end.
                    end.
                end.
            end case.
            find last txb.crchs where txb.crchs.crc = txb.jl.crc no-lock no-error.
            if txb.crchs.hs eq "L" then v-hs = "1".
            else if txb.crchs.hs eq "H" then v-hs = "2".
                else if txb.crchs.hs eq "S" then v-hs = "3".
            if wgl.g5 = "" or lookup(v-cgr,wgl.g5) > 0 then do:
                create t-salde.
                t-salde.jh = txb.jl.jh.
                t-salde.jdt = txb.jl.jdt.
                t-salde.tmp = txb.jl.trx.
                if txb.jl.dc = "d" then do:
                    t-salde.dgl = txb.jl.gl.
                    t-salde.dacc = txb.jl.acc.
                    t-salde.dcrc = txb.jl.crc.
                    t-salde.dtsum = txb.jl.dam.
                    t-salde.dtsumtng = Convcrc(txb.jl.dam,txb.jl.crc,1,txb.jl.jdt).
                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                    if available b-jl then do:
                        t-salde.cgl = b-jl.gl.
                        t-salde.cacc = b-jl.acc.
                        t-salde.ccrc = b-jl.crc.
                        t-salde.ctsum = txb.jl.cam.
                        t-salde.ctsumtng = Convcrc(txb.jl.cam,txb.jl.crc,1,txb.jl.jdt).
                    end.
                end.
                else do:
                    t-salde.cgl = txb.jl.gl.
                    t-salde.cacc = txb.jl.acc.
                    t-salde.ccrc = txb.jl.crc.
                    t-salde.ctsum = txb.jl.cam.
                    t-salde.ctsumtng = Convcrc(txb.jl.cam,txb.jl.crc,1,txb.jl.jdt).
                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                    if available b-jl then do:
                        t-salde.dgl = b-jl.gl.
                        t-salde.dacc = b-jl.acc.
                        t-salde.dcrc = b-jl.crc.
                        t-salde.dtsum = txb.jl.dam.
                        t-salde.dtsumtng = Convcrc(txb.jl.dam,txb.jl.crc,1,txb.jl.jdt).
                    end.
                end.
                v-rem = trim(trim(txb.jl.rem[1]) + " " + trim(txb.jl.rem[2]) + " " + trim(txb.jl.rem[3]) + " " + trim(txb.jl.rem[4]) + " " + trim(txb.jl.rem[5])).
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                if avail txb.jh then v-doc = txb.jh.party.
                if v-rem = '' and avail txb.jh then v-rem = txb.jh.party.
                kod = "".
                kbe = "".
                knp = "".
                if v-doc begins "JOU" or v-doc begins "RMZ" then do:
                  if v-doc begins "JOU" then do:
                    find first txb.joudoc where txb.joudoc.docnum = v-doc no-lock no-error.
                    if available txb.joudoc then do:
                        otp = txb.joudoc.info.
                        ben = txb.joudoc.benname.
                    end.
                    find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = substring(trim(v-doc),1,10) and txb.sub-cod.d-cod  = "eknp" no-lock no-error.
                    if available txb.sub-cod then do:
                        kod = substring(txb.sub-cod.rcode,1,2).
                        kbe = substring(txb.sub-cod.rcode,4,2).
                        knp = substring(txb.sub-cod.rcode,7,3).
                    end.
                  end.
                  if v-doc begins "RMZ" then do:
                    find first txb.remtrz where txb.remtrz.remtrz = v-doc no-lock no-error.
                    if available txb.remtrz then do:
                        otp = txb.remtrz.ord.
                        ben = trim(txb.remtrz.bn[1]) + " " + trim(txb.remtrz.bn[2]) + " " + trim(txb.remtrz.bn[3]).
                    end.
                    find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = substring(trim(v-doc),1,10) and txb.sub-cod.d-cod  = "eknp" no-lock no-error.
                    if available txb.sub-cod then do:
                        kod = substring(txb.sub-cod.rcode,1,2).
                        kbe = substring(txb.sub-cod.rcode,4,2).
                        knp = substring(txb.sub-cod.rcode,7,3).
                    end.
                  end.
                end.
                if kod = "" and kbe = "" and knp = "" then do:
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 1 and txb.trxcods.codfr = "locat" no-lock no-error.
                   if available txb.trxcods then do:
                      kod = txb.trxcods.code.
                   end.
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 1 and txb.trxcods.codfr = "secek" no-lock no-error.
                   if available txb.trxcods then do:
                      kod = kod + txb.trxcods.code.
                   end.
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 2 and txb.trxcods.codfr = "locat" no-lock no-error.
                   if available txb.trxcods then do:
                      kbe = txb.trxcods.code.
                   end.
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 2 and txb.trxcods.codfr = "secek" no-lock no-error.
                   if available txb.trxcods then do:
                      kbe = kbe + txb.trxcods.code.
                   end.
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 1 and txb.trxcods.codfr = "spnpl" no-lock no-error.
                   if available txb.trxcods then knp = txb.trxcods.code.
                end.
                t-salde.cod = kod.
                t-salde.kbe = kbe.
                t-salde.knp = knp.
                t-salde.rem = v-rem.
                t-salde.nameo = otp.
                t-salde.nameb = ben.
                t-salde.secek = v-cgr.
                t-salde.dtop = vop.
                /*t-salde.gl7 = int(substring(string(wgl.gl),1,4) + v-r + v-cgr + v-hs).*/
                t-salde.dtcl = vcl.
                t-salde.txb = VBANK.
                t-salde.txbname = vbankname.
                t-salde.sub = wgl.subled.
                t-salde.poz = wgl.poz.
                t-salde.ao = wgl.ao.
            end.
        end. /* if available wgl */
    end. /* for each txb.jl  */

