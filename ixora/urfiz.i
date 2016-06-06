/* urfiz.i
 * MODULE
        Название модуля - Внутрибанковские операции.
 * DESCRIPTION
        Описание - Концентрация депозитной базы ЮЛ и ФЛ.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - ccdb1.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        03.10.2011 damir - changing copy ccdb1
        09.08.2012 damir - убрал все лишние, добавил расчет по subled = 'ARP'.
        16.08.2012 damir - в расчет по ЮЛ (B) и ФЛ (P) добавил счета ГК 2219,2223,2240,2237.
        05.02.2012 damir - Перекомпиляция. Обнаружены небольшие несооветствия. Все исправлено.
        17/09/2013  Luiza  - ТЗ 1945 добавление счета 2213
*/

nextAAA:
for each txb.aaa no-lock:
    find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if not avail txb.cif then next nextAAA.
    find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr and lookup(trim(txb.lgr.led),"DDA,CDA,TDA,SAV") > 0 no-lock no-error.
    if not avail txb.lgr then next nextAAA.
    find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= v-dt no-lock no-error.
    if avail txb.crchis then v-kurs = txb.crchis.rate[1].

    if not ((txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399)
         or (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499)
         or (txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599)
         or (txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699)
         or (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799)
         or (txb.aaa.gl >= 221300 and txb.aaa.gl <= 221399)
         or (txb.aaa.gl >= 221500 and txb.aaa.gl <= 221599)
         or (txb.aaa.gl >= 221700 and txb.aaa.gl <= 221799)
         or (txb.aaa.gl >= 201300 and txb.aaa.gl <= 201399)
         or (txb.aaa.gl >= 212300 and txb.aaa.gl <= 212399)
         or (txb.aaa.gl >= 212400 and txb.aaa.gl <= 212499)
         or (txb.aaa.gl >= 221900 and txb.aaa.gl <= 221999)
         or (txb.aaa.gl >= 222300 and txb.aaa.gl <= 222399)
         or (txb.aaa.gl >= 224000 and txb.aaa.gl <= 224099)
         or (txb.aaa.gl >= 223700 and txb.aaa.gl <= 223799)) then next nextAAA.

    find txb.gl where txb.gl.gl = txb.aaa.gl no-lock no-error.
    find last txb.histrxbal where txb.histrxbal.subled = "cif" and txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.crc = txb.aaa.crc and
    txb.histrxbal.lev = 1 and txb.histrxbal.dt <= v-dt no-lock no-error.
    if avail txb.histrxbal then v-bal = (txb.histrxbal.cam - txb.histrxbal.dam) * v-kurs.
    else v-bal = 0.
    if avail txb.gl and (txb.gl.type eq "A" or txb.gl.type eq "E") then v-bal = - v-bal.

    find last txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "ecdivis" no-lock no-error.
    find last t-cif where t-cif.cif = txb.aaa.cif exclusive-lock no-error.
    if not avail t-cif then do:
        create t-cif.
        t-cif.city = p-bank.
        t-cif.cif = txb.aaa.cif.
        t-cif.code = txb.sub-cod.ccode.
        t-cif.name = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
        t-cif.type = txb.cif.type.
    end.

    if trim(txb.cif.type) = "B" then do:
        if (txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399) then s_ur_i2203 = s_ur_i2203 + v-bal.
        if (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499) then s_ur_i2204 = s_ur_i2204 + v-bal.
        if (txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599) then s_ur_i2205 = s_ur_i2205 + v-bal.
        if (txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699) then s_ur_i2206 = s_ur_i2206 + v-bal.
        if (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799) then s_ur_i2207 = s_ur_i2207 + v-bal.
        if (txb.aaa.gl >= 221300 and txb.aaa.gl <= 221399) then s_ur_i2213 = s_ur_i2213 + v-bal.
        if (txb.aaa.gl >= 201300 and txb.aaa.gl <= 201399) then s_ur_i2013 = s_ur_i2013 + v-bal.
        if (txb.aaa.gl >= 212300 and txb.aaa.gl <= 212399) then s_ur_i2123 = s_ur_i2123 + v-bal.
        if (txb.aaa.gl >= 212400 and txb.aaa.gl <= 212499) then s_ur_i2124 = s_ur_i2124 + v-bal.
        if (txb.aaa.gl >= 221500 and txb.aaa.gl <= 221599) then s_ur_i2215 = s_ur_i2215 + v-bal.
        if (txb.aaa.gl >= 221700 and txb.aaa.gl <= 221799) then s_ur_i2217 = s_ur_i2217 + v-bal.
        if (txb.aaa.gl >= 221900 and txb.aaa.gl <= 221999) then s_ur_i2219 = s_ur_i2219 + v-bal.
        if (txb.aaa.gl >= 222300 and txb.aaa.gl <= 222399) then s_ur_i2223 = s_ur_i2223 + v-bal.
        if (txb.aaa.gl >= 224000 and txb.aaa.gl <= 224099) then s_ur_i2240 = s_ur_i2240 + v-bal.
        if (txb.aaa.gl >= 223700 and txb.aaa.gl <= 223799) then s_ur_i2237 = s_ur_i2237 + v-bal.
    end.
    else do:
        if (txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399) then s_fiz_i2203 = s_fiz_i2203 + v-bal.
        if (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499) then s_fiz_i2204 = s_fiz_i2204 + v-bal.
        if (txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599) then s_fiz_i2205 = s_fiz_i2205 + v-bal.
        if (txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699) then s_fiz_i2206 = s_fiz_i2206 + v-bal.
        if (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799) then s_fiz_i2207 = s_fiz_i2207 + v-bal.
        if (txb.aaa.gl >= 221300 and txb.aaa.gl <= 221399) then s_fiz_i2213 = s_fiz_i2213 + v-bal.
        if (txb.aaa.gl >= 201300 and txb.aaa.gl <= 201399) then s_fiz_i2013 = s_fiz_i2013 + v-bal.
        if (txb.aaa.gl >= 212300 and txb.aaa.gl <= 212399) then s_fiz_i2123 = s_fiz_i2123 + v-bal.
        if (txb.aaa.gl >= 212400 and txb.aaa.gl <= 212499) then s_fiz_i2124 = s_fiz_i2124 + v-bal.
        if (txb.aaa.gl >= 221500 and txb.aaa.gl <= 221599) then s_fiz_i2215 = s_fiz_i2215 + v-bal.
        if (txb.aaa.gl >= 221700 and txb.aaa.gl <= 221799) then s_fiz_i2217 = s_fiz_i2217 + v-bal.
        if (txb.aaa.gl >= 223700 and txb.aaa.gl <= 223799) then s_fiz_i2237 = s_fiz_i2237 + v-bal.
        if (txb.aaa.gl >= 224000 and txb.aaa.gl <= 224099) then s_fiz_i2240 = s_fiz_i2240 + v-bal.
    end.

    if (txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399) then t-cif.i2203 = t-cif.i2203 + v-bal.
    if (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499) then t-cif.i2204 = t-cif.i2204 + v-bal.
    if (txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599) then t-cif.i2205 = t-cif.i2205 + v-bal.
    if (txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699) then t-cif.i2206 = t-cif.i2206 + v-bal.
    if (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799) then t-cif.i2207 = t-cif.i2207 + v-bal.
    if (txb.aaa.gl >= 221300 and txb.aaa.gl <= 221399) then t-cif.i2213 = t-cif.i2213 + v-bal.
    if (txb.aaa.gl >= 221500 and txb.aaa.gl <= 221599) then t-cif.i2215 = t-cif.i2215 + v-bal.
    if (txb.aaa.gl >= 221700 and txb.aaa.gl <= 221799) then t-cif.i2217 = t-cif.i2217 + v-bal.
    if (txb.aaa.gl >= 201300 and txb.aaa.gl <= 201399) then t-cif.i2013 = t-cif.i2013 + v-bal.
    if (txb.aaa.gl >= 212300 and txb.aaa.gl <= 212399) then t-cif.i2123 = t-cif.i2123 + v-bal.
    if (txb.aaa.gl >= 212400 and txb.aaa.gl <= 212499) then t-cif.i2124 = t-cif.i2124 + v-bal.
    if (txb.aaa.gl >= 221900 and txb.aaa.gl <= 221999) then t-cif.i2219 = t-cif.i2219 + v-bal.
    if (txb.aaa.gl >= 222300 and txb.aaa.gl <= 222399) then t-cif.i2223 = t-cif.i2223 + v-bal.
    if (txb.aaa.gl >= 223700 and txb.aaa.gl <= 223799) then t-cif.i2237 = t-cif.i2237 + v-bal.
    if (txb.aaa.gl >= 224000 and txb.aaa.gl <= 224099) then t-cif.i2240 = t-cif.i2240 + v-bal.

    if trim(txb.cif.type) = "B" then t-cif.sum = t-cif.i2203 + t-cif.i2204 + t-cif.i2215 + t-cif.i2217 + t-cif.i2013 + t-cif.i2123 + t-cif.i2124 +
    t-cif.i2219 + t-cif.i2223 + t-cif.i2237 + t-cif.i2240.
    else t-cif.sum = t-cif.i2204 + t-cif.i2205 + t-cif.i2206 + t-cif.i2207 + t-cif.i2213 + t-cif.i2237 + t-cif.i2240.

    hide message no-pause.
    message p-bank " txb.aaa = " txb.aaa.aaa.
end.

for each b-trxbal no-lock:
    if b-trxbal.sub eq "arp" then do:
        find last txb.arp where txb.arp.arp eq b-trxbal.acc no-lock no-error.
        if not avail txb.arp then next.
        if Igl(txb.arp.gl,b-trxbal.lev,b-trxbal.acc,b-trxbal.sub,b-trxbal.crc) <> 0 then do:
            if string(fgl(txb.arp.gl,b-trxbal.lev)) begins "2203" then
            s_ur_i2203 = s_ur_i2203 + Igl(txb.arp.gl,b-trxbal.lev,b-trxbal.acc,b-trxbal.sub,b-trxbal.crc).

            if string(fgl(txb.arp.gl,b-trxbal.lev)) begins "2204" then
            s_fiz_i2204 = s_fiz_i2204 + Igl(txb.arp.gl,b-trxbal.lev,b-trxbal.acc,b-trxbal.sub,b-trxbal.crc).

            if string(fgl(txb.arp.gl,b-trxbal.lev)) begins "2237" then do:
                if txb.arp.des matches "*ЮЛ*" then s_ur_i2237 = s_ur_i2237 + Igl(txb.arp.gl,b-trxbal.lev,b-trxbal.acc,b-trxbal.sub,b-trxbal.crc).
                if txb.arp.des matches "*ФЛ*" then s_fiz_i2237 = s_fiz_i2237 + Igl(txb.arp.gl,b-trxbal.lev,b-trxbal.acc,b-trxbal.sub,b-trxbal.crc).
            end.
        end.
    end.
    hide message no-pause.
    message p-bank " b-trxbal.acc = " b-trxbal.acc.
end.
pause 0.