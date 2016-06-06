/* sumincomedat.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Доходы в разбивке по суммам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.1.16.6.2
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        07.10.2011 damir - добавил счет ГК 461211,461220, исправил диапазон от 100000 до 1000000 тенге.
        11.10.2012 damir - на основании С.З. от 11.10.2012 г., добавил счета ГК 460112,460715,460828,460829,461500.
        30.04.2013 damir - Внедрено Т.З. № 1805.
*/
def temp-table tempaaa no-undo
    field cif like txb.cif.cif
    field gl like txb.gl.gl
    field amt as deci decimals 2
    field v-tot as deci decimals 2
index idx1 v-tot descending
index idx2 cif ascending.

def shared temp-table temptable no-undo
    field filial as char
    field i1 as inte
    field i2 as inte
    field i3 as inte
    field i4 as inte
    field i5 as inte
    field i6 as inte
    field sumamt1 as deci decimals 2
    field sumamt2 as deci decimals 2
    field sumamt3 as deci decimals 2
    field sumamt4 as deci decimals 2
    field sumamt5 as deci decimals 2
    field sumamt6 as deci decimals 2
    field srednee1 as deci decimals 2
    field srednee2 as deci decimals 2
    field srednee3 as deci decimals 2
    field srednee4 as deci decimals 2
    field srednee5 as deci decimals 2
    field srednee6 as deci decimals 2.

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
    field cif as char
    field amt as deci decimals 2.

def var v-sum as deci.
def var i1 as inte init 0.
def var i2 as inte init 0.
def var i3 as inte init 0.
def var i4 as inte init 0.
def var i5 as inte init 0.
def var i6 as inte init 0.
def var sumamt1 as deci.
def var sumamt2 as deci.
def var sumamt3 as deci.
def var sumamt4 as deci.
def var sumamt5 as deci.
def var sumamt6 as deci.
def var srednee1 as deci.
def var srednee2 as deci.
def var srednee3 as deci.
def var srednee4 as deci.
def var srednee5 as deci.
def var srednee6 as deci.

def var v-ourbnk as char.
def var v-bankname as char.
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.
def var v-gl as char.

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

empty temp-table tempaaa.

m1:
for each txb.cif no-lock:
    for each txb.aaa where txb.aaa.cif = txb.cif.cif no-lock:
        m2:
        for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.dc = "D" and txb.jl.jdt >= v-dte and txb.jl.jdt <= v-dtb no-lock:
            if not (txb.jl.sub = "cif") then next m2.

            find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
            if avail txb.jh and txb.jh.party matches "*storn*" then next m2.

            m3:
            for each bjl where bjl.jh = txb.jl.jh and bjl.crc = txb.jl.crc and bjl.dc = "C" and bjl.cam = txb.jl.dam and bjl.ln <> txb.jl.ln no-lock:
                v-gl = "460111,461110,460410,460430,461211,460713,460721,460725,460824,492130,460122,461120,460819,492120,460130,461220,460112,460715,460828,460829,461500,460411".
                if lookup(string(bjl.gl),v-gl) = 0 then next m3.

                find last txb.crchis where txb.crchis.crc = bjl.crc and txb.crchis.regdt <= bjl.jdt no-lock no-error.

                create tempaaa.
                tempaaa.cif = txb.aaa.cif.
                tempaaa.gl = bjl.gl.
                tempaaa.amt = bjl.cam * txb.crchis.rate[1].

                hide message no-pause.
                message "Сбор данных - " LN[i] " " bjl.jh "БАЗА № - " v-ourbnk.
                if i = 8 then i = 1.
                else i = i + 1.
            end.
        end.
        m4:
        for each buf-jl where buf-jl.acc = txb.aaa.aaa and buf-jl.dc = "C" and buf-jl.jdt >= v-dte and buf-jl.jdt <= v-dtb no-lock:
            if not (buf-jl.sub = "cif") then next m4.

            find first txb.jh where txb.jh.jh = buf-jl.jh no-lock no-error.
            if avail txb.jh and txb.jh.party matches "*storn*" then next m4.

            for each b-jl where b-jl.jh = buf-jl.jh and b-jl.dc = "C" and (b-jl.gl = 453010 or b-jl.gl = 453020 or b-jl.gl = 453080) and b-jl.crc <> 0 no-lock:

                find last txb.crchis where txb.crchis.crc = b-jl.crc and txb.crchis.regdt <= b-jl.jdt no-lock no-error.

                create tempaaa.
                tempaaa.cif = txb.aaa.cif.
                tempaaa.gl = b-jl.gl.
                tempaaa.amt = b-jl.cam * txb.crchis.rate[1].

                hide message no-pause.
                message "Сбор данных - " LN[i] " " b-jl.jh "БАЗА № - " v-ourbnk.
                if i = 8 then i = 1.
                else i = i + 1.
            end.
        end.
        m5:
        for each filpay where filpay.iik = txb.aaa.aaa no-lock:
            v-gl = "460111,461110,460410,460430,461211,460713,460721,460725,460824,492130,460122,461120,460819,492120,460130,461220,460112,460715,460828,460829,461500,460411," +
            "453010,453020,453080".
            if lookup(string(filpay.gl),v-gl) = 0 then next m5.

            create tempaaa.
            tempaaa.cif = txb.aaa.cif.
            tempaaa.gl = filpay.gl.
            tempaaa.amt = filpay.jhamt.

            hide message no-pause.
            message "Сбор межфил. проводок - " LN[i] "БАЗА № - " v-ourbnk.
            if i = 8 then i = 1.
            else i = i + 1.
        end.
    end.
end.

i1 = 0. i2 = 0. i3 = 0. i4 = 0. i5 = 0. i6 = 0.
sumamt1 = 0. sumamt2 = 0. sumamt3 = 0. sumamt4 = 0. sumamt5 = 0. sumamt6 = 0.
srednee1 = 0. srednee2 = 0. srednee3 = 0. srednee4 = 0. srednee5 = 0. srednee6 = 0.
v-sum = 0.

def buffer b-tempaaa for tempaaa.
empty temp-table temp.
for each tempaaa no-lock break by tempaaa.cif:
    if first-of(tempaaa.cif) then do:
        create temp.
        temp.cif = tempaaa.cif.
        for each b-tempaaa where b-tempaaa.cif = tempaaa.cif no-lock:
            temp.amt = temp.amt + b-tempaaa.amt.
        end.
    end.
end.

for each temp no-lock break by temp.amt:
    if temp.amt < 1000 then do:
        i1 = i1 + 1.
        sumamt1 = sumamt1 + temp.amt.
    end.
    if temp.amt >= 1000 and temp.amt < 10000 then do:
        i2 = i2 + 1.
        sumamt2 = sumamt2 + temp.amt.
    end.
    if temp.amt >= 10000 and temp.amt < 50000 then do:
        i3 = i3 + 1.
        sumamt3 = sumamt3 + temp.amt.
    end.
    if temp.amt >= 50000 and temp.amt < 100000 then do:
        i4 = i4 + 1.
        sumamt4 = sumamt4 + temp.amt.
    end.
    if temp.amt >= 100000 and temp.amt < 1000000 then do:
        i5 = i5 + 1.
        sumamt5 = sumamt5 + temp.amt.
    end.
    if temp.amt > 1000000 then do:
        i6 = i6 + 1.
        sumamt6 = sumamt6 + temp.amt.
    end.
end.

srednee1 = sumamt1 / i1.
srednee2 = sumamt2 / i2.
srednee3 = sumamt3 / i3.
srednee4 = sumamt4 / i4.
srednee5 = sumamt5 / i5.
srednee6 = sumamt6 / i6.

create temptable.
temptable.filial = v-bankname.
temptable.i1 = i1.
temptable.i2 = i2.
temptable.i3 = i3.
temptable.i4 = i4.
temptable.i5 = i5.
temptable.i6 = i6.
temptable.sumamt1 = sumamt1.
temptable.sumamt2 = sumamt2.
temptable.sumamt3 = sumamt3.
temptable.sumamt4 = sumamt4.
temptable.sumamt5 = sumamt5.
temptable.sumamt6 = sumamt6.
temptable.srednee1 = srednee1.
temptable.srednee2 = srednee2.
temptable.srednee3 = srednee3.
temptable.srednee4 = srednee4.
temptable.srednee5 = srednee5.
temptable.srednee6 = srednee6.



