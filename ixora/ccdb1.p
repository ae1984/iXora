/* ccdb1.p
 * MODULE
        Название модуля - Внутрибанковские операции.
 * DESCRIPTION
        Описание - Концентрация клиентской депозитной базы.
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
        05/04/2009 evseev
 * BASES
        BANK COMM TXB
 * CHANGES
        03.10.2011 damir - добавил urfiz.i.
        09.08.2012 damir - добавил fgl,Igl, изменения в urfiz.i.
        16.08.2012 damir - поместил все в varurfiz.i, в расчет по ЮЛ (B) и ФЛ (P) добавил счета ГК 2219,2223,2240,2237,
                           изменения в urfiz.i.
        05.02.2012 damir - Перекомпиляция. Обнаружены небольшие несооветствия. Все исправлено.
        17/09/2013  Luiza  - ТЗ 1945 добавление счета 2213
*/

{conv.i}

def input parameter p-bank as char.

def var v-kurs like txb.crchis.rate[1].

{varurfiz.i}   /*Объявление переменных*/

def var v-in as char label "Собираю данные"  no-undo.
def var i as int no-undo.
def var v-bal as deci.

def temp-table wgl no-undo
    field gl     as inte
    field lev    as inte
    field subled as char
    field type   as char
    field code   as char
    field grp    as inte
    index wgl-idx1 is unique primary gl.

def buffer b-trxbal for txb.trxbal.

empty temp-table wgl.
for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and txb.gl.gl >= 220300 and txb.gl.gl < 224099 no-lock:
  create wgl.
    wgl.gl = txb.gl.gl.
    wgl.subled = txb.gl.subled.
    wgl.lev = txb.gl.level.
    wgl.type = txb.gl.type.
    wgl.code = txb.gl.code.
    wgl.grp = txb.gl.grp.
end.

function fgl return integer (input v-gl as integer, input v-lev as integer).
    def var v-glout as inte no-undo.

    v-glout = 0.
    find txb.gl where txb.gl.gl eq v-gl no-lock no-error.
    if avail txb.gl then do:
        find txb.trxlevgl where txb.trxlevgl.gl eq v-gl and txb.trxlevgl.lev eq v-lev and txb.trxlevgl.sub eq gl.subled use-index glsublev no-lock no-error.
        if available txb.trxlevgl then v-glout = txb.trxlevgl.glr.
    end.
    return v-glout.
end function.

function Igl return deci(input gl as inte,input v-lev as inte,input acc as char,input sub as char,input v-crc as integer).
    def var v-gl   as inte.
    def var v-bal  as deci.
    def var v-res  as deci.

    v-gl = fgl(gl,v-lev).
    v-bal = 0. v-res = 0.
    find wgl where wgl.gl = v-gl no-lock no-error.
    if avail wgl then do:
        find last txb.histrxbal where txb.histrxbal.acc = acc and txb.histrxbal.lev = v-lev and txb.histrxbal.subled = sub and txb.histrxbal.crc = v-crc
        and txb.histrxbal.dt <= v-dt use-index trxbal no-lock no-error.
        if avail txb.histrxbal then v-bal = CRC2KZT(txb.histrxbal.cam - txb.histrxbal.dam,v-crc,v-dt). else v-bal = 0.

        if wgl.type eq "A" or wgl.type eq "E" then v-bal = - v-bal.
        v-res = v-bal.
    end.
    return v-res.
end function.

if not v-urfiz then do:
    nextAAA:
    for each txb.aaa no-lock:
        if v-repnum = 2 then do:
            if not ((txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399)
                 or (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499)
                 or (txb.aaa.gl >= 201300 and txb.aaa.gl <= 201399)) then next.
        end.
        if v-repnum = 3 then do:
            if not ((txb.aaa.gl >= 221500 and txb.aaa.gl <= 221599)
                 or (txb.aaa.gl >= 221700 and txb.aaa.gl <= 221799)
                 or (txb.aaa.gl >= 212300 and txb.aaa.gl <= 212399)
                 or (txb.aaa.gl >= 212400 and txb.aaa.gl <= 212499)) then next.
        end.
        if v-repnum = 4 then do:
            if not ((txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499)
                 or (txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599)) then next.
        end.
        if v-repnum = 5 then do:
            if not ((txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699)
                 or (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799)) then next.
        end.

        find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr and lookup(trim(txb.lgr.led),"DDA,CDA,TDA,SAV") > 0 no-lock no-error.
        if not avail txb.lgr then next nextAAA.
        find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
        if not (avail txb.cif and txb.cif.type = v-type) then next nextAAA.
        find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= v-dt no-lock.
        v-kurs = txb.crchis.rate[1].

        find last txb.histrxbal where txb.histrxbal.subled = "cif" and  txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.crc = txb.aaa.crc and
        txb.histrxbal.lev = 1 and txb.histrxbal.dt <= v-dt no-lock no-error.
        if avail txb.histrxbal then v-bal = (txb.histrxbal.cam - txb.histrxbal.dam) * v-kurs.
        else v-bal = 0.
        if avail txb.gl and (txb.gl.type eq "A" or txb.gl.type eq "E") then v-bal = - v-bal.


        find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
        find last t-cif where t-cif.cif = txb.aaa.cif exclusive-lock no-error.
        if not avail t-cif then do:
            create t-cif.
            t-cif.city = p-bank.
            t-cif.cif = txb.aaa.cif.
            t-cif.code = txb.sub-cod.ccode.
            t-cif.name = txb.cif.name.
            t-cif.type = txb.cif.type.
        end.

        if txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399 then do:
            t-cif.i2203 = t-cif.i2203 + v-bal.
            s_i2203 = s_i2203 + v-bal.
        end.
        if txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499 then do:
            t-cif.i2204 = t-cif.i2204 + v-bal.
            s_i2204 = s_i2204 + v-bal.
        end.
        if txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599 then do:
            t-cif.i2205 = t-cif.i2205 + v-bal.
            s_i2205 = s_i2205 + v-bal.
        end.
        if txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699 then do:
            t-cif.i2206 = t-cif.i2206 + v-bal.
            s_i2206 = s_i2206 + v-bal.
        end.
        if txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799 then do:
            t-cif.i2207 = t-cif.i2207 + v-bal.
            s_i2207 = s_i2207 + v-bal.
        end.
        if txb.aaa.gl >= 221300 and txb.aaa.gl <= 221399 then do:
            t-cif.i2213 = t-cif.i2213 + v-bal.
            s_i2213 = s_i2213 + v-bal.
        end.
        if txb.aaa.gl >= 221500 and txb.aaa.gl <= 221599 then do:
            t-cif.i2215 = t-cif.i2215 + v-bal.
            s_i2215 = s_i2215 + v-bal.
        end.
        if txb.aaa.gl >= 221700 and txb.aaa.gl <= 221799 then do:
            t-cif.i2217 = t-cif.i2217 + v-bal.
            s_i2217 = s_i2217 + v-bal.
        end.
        if txb.aaa.gl >= 201300 and txb.aaa.gl <= 201399 then do:
            t-cif.i2013 = t-cif.i2013 + v-bal.
            s_i2013 = s_i2013 + v-bal.
        end.
        if txb.aaa.gl >= 212300 and txb.aaa.gl <= 212399 then do:
            t-cif.i2123 = t-cif.i2123 + v-bal.
            s_i2123 = s_i2123 + v-bal.
        end.
        if txb.aaa.gl >= 212400 and txb.aaa.gl <= 212499 then do:
            t-cif.i2124 = t-cif.i2124 + v-bal.
            s_i2124 = s_i2124 + v-bal.
        end.

        if v-repnum = 2 then do:
            if ((txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399)
             or (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499)
             or (txb.aaa.gl >= 201300 and txb.aaa.gl <= 201399)) then
            t-cif.sum = t-cif.i2203 + t-cif.i2204 + t-cif.i2013 + t-cif.i2219 + t-cif.i2223 + t-cif.i2237 + t-cif.i2240.
        end.
        if v-repnum = 3 then do:
            if ((txb.aaa.gl >= 221500 and txb.aaa.gl <= 221599)
             or (txb.aaa.gl >= 221700 and txb.aaa.gl <= 221799)
             or (txb.aaa.gl >= 212300 and txb.aaa.gl <= 212399)
             or (txb.aaa.gl >= 212400 and txb.aaa.gl <= 212499)) then
            t-cif.sum = t-cif.i2215 + t-cif.i2217 + t-cif.i2123 + t-cif.i2124 + t-cif.i2219 + t-cif.i2223 + t-cif.i2237 + t-cif.i2240.
        end.
        if v-repnum = 4 then do:
            if ((txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499)
            or (txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599)) then
            t-cif.sum = t-cif.i2204 + t-cif.i2205 + t-cif.i2240 + t-cif.i2237.
        end.
        if v-repnum = 5 then do:
            if ((txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699)
            or (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799) or (txb.aaa.gl >= 221300 and txb.aaa.gl <= 221399)) then
            t-cif.sum = t-cif.i2206 + t-cif.i2207 + t-cif.i2213 + t-cif.i2240 + t-cif.i2237.
        end.
        hide message no-pause.
        message p-bank " txb.aaa = " txb.aaa.aaa.
    end.
end.
else do:
    {urfiz.i}
end.