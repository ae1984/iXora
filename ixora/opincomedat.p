/* opincomedat.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Операционный доход
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.1.16.6.1
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        30.04.2013 damir - Внедрено Т.З. № 1805.
*/
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.
def var v-ourbnk as char.
def var v-bankname as char.
def var v-gl as char.

def shared temp-table tempod no-undo
    field filial as char
    field months as char
    field ciftype1 like txb.cif.type
    field perev-oper1 as deci decimals 2
    field kass-oper1 as deci decimals 2
    field konvert-oper1 as deci decimals 2
    field cursdoh1 as deci decimals 2
    field garants1 as deci decimals 2
    field docum-oper1 as deci decimals 2
    field other-oper1 as deci decimals 2
    field itogtype1 as deci decimals 2
    field ciftype2 like txb.cif.type
    field perev-quick2 as deci decimals 2
    field perev-bank2 as deci decimals 2
    field kass-oper2 as deci decimals 2
    field curs-convert2 as deci decimals 2
    field other-oper2 as deci decimals 2
    field itogtype2 as deci decimals 2
    field allsumm as deci decimals 2
    index main is primary ciftype1 ciftype2 months.

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

def shared var v-dte as date.
def shared var v-dtb as date.

def temp-table temp no-undo
    field filial as char
    field cif like txb.cif.cif
    field ciftype like txb.cif.type
    field gl like txb.gl.gl
    field amt like txb.jl.cam
index idx1 ciftype ascending.

def temp-table temp1 no-undo
    field ciftype like txb.cif.type
    field perev-oper as deci decimals 2
    field kass-oper as deci decimals 2
    field konvert-oper as deci decimals 2
    field cursdoh as deci decimals 2
    field garants as deci decimals 2
    field docum-oper as deci decimals 2
    field other-oper as deci decimals 2.

def temp-table temp2 no-undo
    field ciftype like txb.cif.type
    field perev-quick as deci decimals 2
    field kass-bank as deci decimals 2
    field kass-oper as deci decimals 2
    field cursconvert as deci decimals 2
    field other-oper as deci decimals 2.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then do:
    v-ourbnk = trim(txb.sysc.chval).
    find first comm.txb where comm.txb.bank = v-ourbnk no-lock no-error.
    if avail comm.txb then v-bankname = trim(comm.txb.info).
    else do: message "This isn't record in comm.txb file !!!" view-as alert-box. return. end.
end.
else do: message "This isn't record OURBNK in txb.sysc file !!!" view-as alert-box. return. end.

def buffer bjl for txb.jl.
def buffer b-jl for txb.jl.
def buffer buf-jl for txb.jl.

empty temp-table temp.
m1:
for each txb.jl where txb.jl.acc <> "" and txb.jl.dc = "D" and txb.jl.jdt >= v-dte and txb.jl.jdt <= v-dtb no-lock break by txb.jl.jh:
    find txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
    find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.

    if not (txb.jl.sub = "cif" and avail txb.aaa and avail txb.cif) then next m1.
    m2:
    for each bjl where bjl.jh = txb.jl.jh and bjl.crc = txb.jl.crc and bjl.dc = "C" and bjl.cam = txb.jl.dam and bjl.ln <> txb.jl.ln no-lock:
        v-gl = "460111,461110,460410,460430,460610,461210,461220,460713,460721,460725,460824,492130,460123,460124,460125,460126,460127,460122,461120,461130,460819,492120,460411".
        if lookup(string(bjl.gl),v-gl) = 0 then next m2.

        find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.regdt <= txb.jl.jdt no-lock no-error.

        create temp.
        temp.filial = v-bankname.
        temp.cif = txb.aaa.cif.
        temp.ciftype = txb.cif.type.
        temp.gl = bjl.gl.
        temp.amt = bjl.cam * txb.crchis.rate[1].

        hide message no-pause.
        message "Сбор данных - " LN[i] " " bjl.jh "БАЗА № - " v-ourbnk.
        if i = 8 then i = 1.
        else i = i + 1.
    end.
end.

m3:
for each txb.cif no-lock:
    m4:
    for each txb.aaa where txb.aaa.cif = txb.cif.cif no-lock:
        if txb.aaa.sta = "C" then next m4.
        m5:
        for each buf-jl where buf-jl.acc = txb.aaa.aaa and buf-jl.dc = "C" and buf-jl.jdt >= v-dte and buf-jl.jdt <= v-dtb no-lock:
            if not (buf-jl.sub = "cif") then next m5.
            for each b-jl where b-jl.jh = buf-jl.jh and b-jl.dc = "C" and (b-jl.gl = 453010 or b-jl.gl = 453020 or b-jl.gl = 453080) and b-jl.crc <> 0 no-lock:

                find last txb.crchis where txb.crchis.crc = b-jl.crc and txb.crchis.regdt <= b-jl.jdt no-lock no-error.

                create temp.
                temp.filial = v-bankname.
                temp.cif = txb.aaa.cif.
                temp.ciftype = txb.cif.type.
                temp.gl = b-jl.gl.
                temp.amt = b-jl.cam * txb.crchis.rate[1].

                hide message no-pause.
                message "Сбор данных - " LN[i] " " b-jl.jh "БАЗА № - " v-ourbnk.
                if i = 8 then i = 1.
                else i = i + 1.
            end.
        end.
        for each filpay where filpay.iik = txb.aaa.aaa no-lock:
            create temp.
            temp.filial = v-bankname.
            temp.cif = txb.aaa.cif.
            temp.ciftype = txb.cif.type.
            temp.gl = filpay.gl.
            temp.amt = filpay.jhamt.

            hide message no-pause.
            message "Сбор межфил. проводок - " LN[i] "БАЗА № - " v-ourbnk.
            if i = 8 then i = 1.
            else i = i + 1.
        end.
    end.
end.

def buffer b-temp for temp.
for each temp no-lock break by temp.ciftype:
    if first-of(temp.ciftype) then do:
        if trim(temp.ciftype) = "B" then do:
            create temp1.
            temp1.ciftype = temp.ciftype.
            for each b-temp where b-temp.ciftype = temp.ciftype no-lock:
                if lookup(string(b-temp.gl),"460111") > 0 then temp1.perev-oper = temp1.perev-oper + b-temp.amt.
                if lookup(string(b-temp.gl),"461110") > 0 then temp1.kass-oper = temp1.kass-oper + b-temp.amt.
                if lookup(string(b-temp.gl),"460410,460430") > 0 then temp1.konvert-oper = temp1.konvert-oper + b-temp.amt.
                if lookup(string(b-temp.gl),"453010") > 0 then temp1.cursdoh = temp1.cursdoh + b-temp.amt.
                if lookup(string(b-temp.gl),"460610") > 0 then temp1.garants = temp1.garants + b-temp.amt.
                if lookup(string(b-temp.gl),"461210,461220") > 0 then temp1.docum-oper = temp1.docum-oper + b-temp.amt.
                if lookup(string(b-temp.gl),"460713,460721,460725,460824,492130") > 0 then temp1.other-oper = temp1.other-oper + b-temp.amt.
            end.
        end.
        if trim(temp.ciftype) = "P" then do:
            create temp2.
            temp2.ciftype = temp.ciftype.
            for each b-temp where b-temp.ciftype = temp.ciftype no-lock:
                if lookup(string(b-temp.gl),"460123,460124,460125,460126,460127") > 0 then temp2.perev-quick = temp2.perev-quick + b-temp.amt.
                if lookup(string(b-temp.gl),"460122") > 0 then temp2.kass-bank = temp2.kass-bank + b-temp.amt.
                if lookup(string(b-temp.gl),"461120") > 0 then temp2.kass-oper = temp2.kass-oper + b-temp.amt.
                if lookup(string(b-temp.gl),"453020,453080,460411") > 0 then temp2.cursconvert = temp2.cursconvert + b-temp.amt.
                if lookup(string(b-temp.gl),"461130,460819,492120") > 0 then temp2.other-oper = temp2.other-oper + b-temp.amt.
            end.
        end.
    end.
end.

create tempod.
tempod.filial = v-bankname.
for each temp1 no-lock:
    tempod.perev-oper1 = temp1.perev-oper.
    tempod.kass-oper1 = temp1.kass-oper.
    tempod.konvert-oper1 = temp1.konvert-oper.
    tempod.cursdoh1 = temp1.cursdoh.
    tempod.garants1 = temp1.garants.
    tempod.docum-oper1 = temp1.docum-oper.
    tempod.other-oper1 = temp1.other-oper.
    tempod.itogtype1 = tempod.perev-oper1 + tempod.kass-oper1 + tempod.konvert-oper1 + tempod.cursdoh1 + tempod.garants1 + tempod.docum-oper1 + tempod.other-oper1.
end.
for each temp2 no-lock:
    tempod.perev-quick2 = temp2.perev-quick.
    tempod.perev-bank2 = temp2.kass-bank.
    tempod.kass-oper2 = temp2.kass-oper.
    tempod.curs-convert2 = temp2.cursconvert.
    tempod.other-oper2 = temp2.other-oper.
    tempod.itogtype2 = tempod.perev-quick2 + tempod.perev-bank2 + tempod.kass-oper2 + tempod.curs-convert2 + tempod.other-oper2.
    tempod.allsumm = tempod.itogtype1 + tempod.itogtype2.
end.



