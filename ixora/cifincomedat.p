/* cifincomedat.p
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
        31.08.2011 damir - добавил счет ГК 460130,461210 заменил на 461211.
        06.09.2011 aigul - добавила 2 столбца Наличие ссудного счета и Категория
        03.10.2011 damir - не отбирать сторнированные проводки.
        11.10.2012 damir - на основании С.З. от 11.10.2012 г., добавил счета ГК 460112,460715,460828,460829,461500.
        30.04.2013 damir - Внедрено Т.З. № 1805.
        14.05.2013 damir - Внедрено Т.З. № 1739.
*/
def shared temp-table tempcif1 no-undo
    field filial as char
    field cifname as char
    field gl1 as deci
    field gl2 as deci
    field gl3 as deci
    field gl4 as deci
    field gl5 as deci
    field gl6 as deci
    field gl7 as deci
    field gl8 as deci
    field itog as deci
    field lon as char
    field categ as char
    field fAccdt as date
    field CrSum as deci
    field bal as deci
    field balCL as deci.

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

def temp-table tempcif no-undo
    field cifname as char
    field gl as inte
    field gl1 as deci decimals 2
    field gl2 as deci decimals 2
    field gl3 as deci decimals 2
    field gl4 as deci decimals 2
    field gl5 as deci decimals 2
    field gl6 as deci decimals 2
    field gl7 as deci decimals 2
    field gl8 as deci decimals 2
    field itog as deci decimals 2.

def temp-table temp no-undo
    field cif as char
    field cifname as char
 	field gl like txb.jl.gl
	field amt like txb.jl.dam
    field v-tot as deci decimals 2
	field v-subtot as deci decimals 2
index idx1 v-subtot descending
index idx2 cifname ascending.

def temp-table t-wrk no-undo
    field cif as char
    field aaa as char
    field regdt as date
    field CrSum as deci
index idx1 cif ascending
           regdt ascending
index idx2 cif ascending.

def var v-lonprnlev as char initial "1;7;8".
def var v-ost as decimal.
def var v-sum as decimal.
def var v-sts as char.

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
def buffer b-lgr for txb.lgr.

empty temp-table temp.
empty temp-table t-wrk.

m1:
for each txb.cif no-lock:
    m2:
    for each txb.aaa where txb.aaa.cif = txb.cif.cif no-lock:
        find first b-lgr where b-lgr.lgr = txb.aaa.lgr no-lock no-error.
        if avail b-lgr then do: if b-lgr.led = "ODA" then next m2. end.
        else next m2.

        create t-wrk.
        t-wrk.cif = txb.cif.cif.
        t-wrk.aaa = txb.aaa.aaa.
        t-wrk.regdt = txb.aaa.regdt.

        m3:
        for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.dc = "D" and txb.jl.jdt >= v-dte and txb.jl.jdt <= v-dtb no-lock:
            if not (txb.jl.sub = "cif") then next m3.

            find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
            if avail txb.jh and txb.jh.party begins "Storn" then next m3.
            m4:
            for each bjl where bjl.jh = txb.jl.jh and bjl.crc = txb.jl.crc and bjl.dc = "C" and bjl.cam = txb.jl.dam and bjl.ln <> txb.jl.ln no-lock:
                v-gl = "460111,460122,461110,461120,460410,460430,460610,461211,461220,460713,460721,460725,460824,492130,460819,492120,460130,460112,460715,460828,460829,461500,460411".
                if lookup(string(bjl.gl),v-gl) = 0 then next m4.

                find last txb.crchis where txb.crchis.crc = bjl.crc and txb.crchis.regdt <= bjl.jdt no-lock no-error.

                create temp.
                temp.cif = txb.aaa.cif.
                temp.cifname = trim(txb.cif.name) + " " + trim(txb.cif.prefix).
                temp.gl = bjl.gl.
                temp.amt = bjl.cam * txb.crchis.rate[1].

                hide message no-pause.
                message "Сбор данных - " LN[i] " " bjl.jh "БАЗА № - " v-ourbnk.
                if i = 8 then i = 1.
                else i = i + 1.
            end.
        end.
        m5:
        for each buf-jl where buf-jl.acc = txb.aaa.aaa and buf-jl.dc = "C" and buf-jl.jdt >= v-dte and buf-jl.jdt <= v-dtb no-lock:
            find first txb.jh where txb.jh.jh = buf-jl.jh no-lock no-error.
            if avail txb.jh and txb.jh.party matches "*storn*" then next m5.

            for each b-jl where b-jl.jh = buf-jl.jh and b-jl.dc = "C" and (b-jl.gl = 453010 or b-jl.gl = 453020 or b-jl.gl = 453080) and b-jl.crc <> 0 no-lock:
                find last txb.crchis where txb.crchis.crc = b-jl.crc and txb.crchis.regdt <= b-jl.jdt no-lock no-error.

                create temp.
                temp.cif = txb.aaa.cif.
                temp.cifname = trim(txb.cif.name) + " " + trim(txb.cif.prefix).
                temp.gl = b-jl.gl.
                temp.amt = b-jl.cam * txb.crchis.rate[1].

                hide message no-pause.
                message "Сбор данных - " LN[i] " " b-jl.jh "БАЗА № - " v-ourbnk.
                if i = 8 then i = 1.
                else i = i + 1.
            end.

            if not (buf-jl.lev = 1) then next m5.

            find last txb.ncrchis where txb.ncrchis.crc = buf-jl.crc and txb.ncrchis.rdt <= buf-jl.jdt no-lock no-error.
            t-wrk.CrSum = t-wrk.CrSum + buf-jl.cam * txb.ncrchis.rate[1].
        end.

        for each filpay where filpay.iik = txb.aaa.aaa no-lock:
            create temp.
            temp.cif = txb.aaa.cif.
            temp.cifname = trim(txb.cif.name) + " " + trim(txb.cif.prefix).
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
for each temp no-lock break by temp.cifname:
    if first-of(temp.cifname) then do:
        create tempcif1.
        tempcif1.filial = v-bankname.
        tempcif1.cifname = temp.cifname.
        for each b-temp where b-temp.cifname = temp.cifname no-lock:
            if lookup(string(b-temp.gl),"460111,460122,460130,460112") > 0 then tempcif1.gl1 = tempcif1.gl1 + b-temp.amt.
            if lookup(string(b-temp.gl),"461110,461120,461500") > 0 then tempcif1.gl2 = tempcif1.gl2 + b-temp.amt.
            if lookup(string(b-temp.gl),"460410,460430,460411") > 0 then tempcif1.gl3 = tempcif1.gl3 + b-temp.amt.
            if lookup(string(b-temp.gl),"453010,453020,453080") > 0 then tempcif1.gl4 = tempcif1.gl4 + b-temp.amt.
            if lookup(string(b-temp.gl),"460610") > 0 then tempcif1.gl5 = tempcif1.gl5 + b-temp.amt.
            if lookup(string(b-temp.gl),"461211,461220") > 0 then tempcif1.gl6 = tempcif1.gl6 + b-temp.amt.
            if lookup(string(b-temp.gl),"460713,460721,460725") > 0 then tempcif1.gl7 = tempcif1.gl7 + b-temp.amt.
            if lookup(string(b-temp.gl),"460824,492130,460819,492120,460715,460828,460829") > 0 then tempcif1.gl8 = tempcif1.gl8 + b-temp.amt.
        end.
        tempcif1.itog = tempcif1.gl1 + tempcif1.gl2 + tempcif1.gl3 + tempcif1.gl4 + tempcif1.gl5 + tempcif1.gl6 + tempcif1.gl7 + tempcif1.gl8.

        find first t-wrk where t-wrk.cif = temp.cif and t-wrk.regdt <> ? no-lock no-error.
        if avail t-wrk then tempcif1.fAccdt = t-wrk.regdt.

        for each t-wrk where t-wrk.cif = temp.cif no-lock:
            tempcif1.CrSum = tempcif1.CrSum + t-wrk.CrSum.
        end.

        for each txb.lon where txb.lon.cif = temp.cif no-lock:
            v-sum = 0.
            run lonbalcrc_txb('lon',txb.lon.lon,v-dtb,"1,7",yes,txb.lon.crc,output v-sum).

            find last txb.ncrchis where txb.ncrchis.crc = txb.lon.crc and txb.ncrchis.rdt <= v-dtb no-lock no-error.
            tempcif1.bal = tempcif1.bal + v-sum * txb.ncrchis.rate[1].

            v-sum = 0.
            run lonbalcrc_txb('lon',txb.lon.lon,v-dtb,"15,35",yes,txb.lon.crc,output v-sum).
            v-sum = ABS(v-sum).
            tempcif1.balCL = tempcif1.balCL + v-sum * txb.ncrchis.rate[1].
        end.
        if tempcif1.bal + tempcif1.balCL > 0 then tempcif1.lon = "Да".
        else tempcif1.lon = "Нет".

        find first txb.cif where txb.cif.cif = temp.cif no-lock no-error.
        if avail txb.cif then do:
            find first txb.codfr where txb.codfr.codfr = 'cifkat' and txb.codfr.code = txb.cif.trw no-lock no-error.
            if avail txb.codfr then tempcif1.categ = txb.codfr.name[1].
        end.
    end.
end.

