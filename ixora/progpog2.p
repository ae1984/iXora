/* progpog2.p
 * MODULE
        Кредитование
 * DESCRIPTION
        Прогноз погашения по кредитам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        25/11/2009 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        21/05/2010 madiyar - поправил учет просрочек
        15/10/2010 madiyar - при запросе более позднего периода (не начинающегося с сегодняшнего дня) данные не выводились, исправил; отчет по ЮЛ
*/

def input parameter dt1 as date no-undo.
def input parameter dt2 as date no-undo.

def shared var g-today as date.
def var bilance as deci no-undo.
def var v-prc as deci no-undo.
def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-prc_prosr as deci no-undo.
def var v-pen as deci no-undo.
def var v-segm as char no-undo.
def var v-comved as deci no-undo.
def var v-comdolg as deci no-undo.
def var v-till as integer no-undo.
def var v-ztype as integer no-undo.
def var v-ost as deci no-undo.
v-till = 4.

def shared var v-type as integer no-undo.

def var s-ourbank as char no-undo.
def var v-bankn as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).
if s-ourbank = "txb00" then v-bankn = "ЦО".
else do:
    find first txb.cmp no-lock no-error.
    if avail txb.cmp then v-bankn = entry(1,txb.cmp.addr[1]).
end.

hide message no-pause.
message s-ourbank.

function shifted returns logical (input sublon as char, input subdt as date).
    def var v-log as logical no-undo.
    v-log = no.
    def var subdt2 as date no-undo.
    def var subdec1 as deci no-undo.
    def var subdec2 as deci no-undo.
    def var subdec3 as deci no-undo.
    if day(subdt) <= v-till then do:
        subdt2 = date(month(subdt),1,year(subdt)).
        find last txb.cls where txb.cls.whn < subdt2 and txb.cls.del no-lock no-error.
        if avail txb.cls then do:
            find first txb.lonres where txb.lonres.lon = sublon and txb.lonres.jdt = txb.cls.whn and txb.lonres.lev = 7 and txb.lonres.dc= 'C' no-lock no-error.
            if avail txb.lonres and txb.lonres.who <> "bankadm" then do:
                run lonbalcrc_txb('lon',sublon,txb.cls.whn,7,no,txb.lon.crc,output subdec1).
                run lonbalcrc_txb('lon',sublon,txb.cls.whn,7,yes,txb.lon.crc,output subdec2).
                run lonbalcrc_txb('lon',sublon,txb.cls.whn,1,yes,txb.lon.crc,output subdec3).
                if subdec3 > 0 and subdec1 > 0 and subdec2 <= 0 then v-log = yes.
            end.
        end.
    end.
    return v-log.
end function.

def shared temp-table wrk no-undo
  field ztype as integer
  field bank as char
  field bankn as char
  field segm as char
  field dt as date
  field crc like txb.crc.crc
  field od as deci
  field prc as deci
  field com as deci
  field pen as deci
  field ost as deci
  index idx is primary ztype segm dt bank crc.

def buffer b-wrk for wrk.

def var i as integer no-undo.

def var rates as deci extent 3.
do i = 1 to 3:
    find last txb.crchis where txb.crchis.crc = i and txb.crchis.rdt < dt1 no-lock no-error.
    rates[i] = txb.crchis.rate[1].
end.


for each txb.lon no-lock:
    if txb.lon.rdt > dt1 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7",yes,txb.lon.crc,output bilance).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2,9",yes,txb.lon.crc,output v-prc).
    if bilance <= 0 and v-prc <= 0 then next.

    find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnsegm' no-lock no-error.
    if avail txb.sub-cod then v-segm = txb.sub-cod.ccode.
    else v-segm = "--unknown--".
    
    if (v-type = 1 and v-segm = "07") or (v-type = 2 and v-segm <> "07" and v-segm <> "--unknown--") then next.

    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1",yes,txb.lon.crc,output v-bal1).

    v-ztype = 1.
    assign v-bal7 = 0 v-prc_prosr = 0 v-pen = 0 v-comdolg = 0.
    run lonbal_txb('lon',txb.lon.lon,g-today,"7,9,16,4,5",yes,output v-bal7).

    v-comdolg = 0.
    
    for each txb.bxcif where txb.bxcif.cif = txb.lon.cif and txb.bxcif.type = '195' and txb.bxcif.aaa = txb.lon.aaa no-lock:
        v-comdolg = v-comdolg + txb.bxcif.amount.
    end.
    
    if v-bal7 + v-comdolg > 0 then do:
        v-ztype = 2.
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"7",yes,txb.lon.crc,output v-bal7).
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"4,9",yes,txb.lon.crc,output v-prc_prosr).
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"5,16",yes,txb.lon.crc,output v-pen).
    end.

    v-comved = 0.
    find first txb.tarifex2 where txb.tarifex2.aaa = txb.lon.aaa and txb.tarifex2.cif = txb.lon.cif and txb.tarifex2.str5 = "195" and txb.tarifex2.stat = 'r' no-lock no-error.
    if avail txb.tarifex2 then v-comved = txb.tarifex2.ost.

    v-ost = 0.
    find first txb.aaa where txb.aaa.aaa = txb.lon.aaa no-lock no-error.
    run lonbalcrc_txb('lon',txb.aaa.aaa,g-today,"1",yes,txb.aaa.crc,output v-ost).
    v-ost = - v-ost.

    if txb.lon.crc <> 1 then do:
        bilance = bilance * rates[txb.lon.crc].
        v-prc = v-prc * rates[txb.lon.crc].
        v-bal1 = v-bal1 * rates[txb.lon.crc].
        v-bal7 = v-bal7 * rates[txb.lon.crc].
        v-prc_prosr = v-prc_prosr * rates[txb.lon.crc].
        v-ost = v-ost * rates[txb.lon.crc].
        v-comved = v-comved * rates[txb.lon.crc].
        v-comdolg = v-comdolg * rates[txb.lon.crc].
    end.

    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0 and txb.lnsch.fpn = 0 and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= dt1 and lnsch.stdat <= dt2 no-lock:
        find first wrk where wrk.ztype = v-ztype and wrk.segm = v-segm and wrk.dt = txb.lnsch.stdat and wrk.bank = s-ourbank and wrk.crc = txb.lon.crc no-error.
        if not avail wrk then do:
            create wrk.
            assign wrk.segm = v-segm
                   wrk.dt = txb.lnsch.stdat
                   wrk.crc = txb.lon.crc
                   wrk.bank = s-ourbank
                   wrk.bankn = v-bankn
                   wrk.ztype = v-ztype.
        end.
        find first b-wrk where b-wrk.ztype = 3 and b-wrk.segm = v-segm and b-wrk.dt = txb.lnsch.stdat and b-wrk.bank = s-ourbank and b-wrk.crc = txb.lon.crc no-error.
        if not avail b-wrk then do:
            create b-wrk.
            assign b-wrk.segm = v-segm
                   b-wrk.dt = txb.lnsch.stdat
                   b-wrk.crc = txb.lon.crc
                   b-wrk.bank = s-ourbank
                   b-wrk.bankn = v-bankn
                   b-wrk.ztype = 3.
        end.
        wrk.od = wrk.od + txb.lnsch.stval * rates[txb.lon.crc].
        b-wrk.od = b-wrk.od + txb.lnsch.stval * rates[txb.lon.crc].
        if v-bal7 > 0 then do:
            wrk.od = wrk.od + v-bal7.
            b-wrk.od = b-wrk.od + v-bal7.
            v-bal7 = 0.
        end.
        if not shifted (txb.lon.lon, txb.lnsch.stdat) then do:
            wrk.com = wrk.com + v-comved.
            b-wrk.com = b-wrk.com + v-comved.
            if v-comdolg > 0 then do:
                wrk.com = wrk.com + v-comdolg.
                b-wrk.com = b-wrk.com + v-comdolg.
                v-comdolg = 0.
            end.
        end.
        if v-pen > 0 then do:
            wrk.pen = wrk.pen + v-pen.
            b-wrk.pen = b-wrk.pen + v-pen.
            v-pen = 0.
        end.
        if v-ost > 0 then do:
            wrk.ost = wrk.ost + v-ost.
            b-wrk.ost = b-wrk.ost + v-ost.
            v-ost = 0.
        end.
    end.

    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0 and txb.lnsci.fpn = 0 and txb.lnsci.f0 > 0 and txb.lnsci.idat >= dt1 and lnsci.idat <= dt2 no-lock:
        find first wrk where wrk.ztype = v-ztype and wrk.segm = v-segm and wrk.dt = txb.lnsci.idat and wrk.bank = s-ourbank and wrk.crc = txb.lon.crc no-error.
        if not avail wrk then do:
            create wrk.
            assign wrk.segm = v-segm
                   wrk.dt = txb.lnsci.idat
                   wrk.crc = txb.lon.crc
                   wrk.bank = s-ourbank
                   wrk.bankn = v-bankn
                   wrk.ztype = v-ztype.
        end.
        find first b-wrk where b-wrk.ztype = 3 and b-wrk.segm = v-segm and b-wrk.dt = txb.lnsci.idat and b-wrk.bank = s-ourbank and b-wrk.crc = txb.lon.crc no-error.
        if not avail b-wrk then do:
            create b-wrk.
            assign b-wrk.segm = v-segm
                   b-wrk.dt = txb.lnsci.idat
                   b-wrk.crc = txb.lon.crc
                   b-wrk.bank = s-ourbank
                   b-wrk.bankn = v-bankn
                   b-wrk.ztype = 3.
        end.
        wrk.prc = wrk.prc + txb.lnsci.iv-sc * rates[txb.lon.crc].
        b-wrk.prc = b-wrk.prc + txb.lnsci.iv-sc * rates[txb.lon.crc].
        if v-prc_prosr > 0 then do:
            wrk.prc = wrk.prc + v-prc_prosr.
            b-wrk.prc = b-wrk.prc + v-prc_prosr.
            v-prc_prosr = 0.
        end.
        if v-pen > 0 then do:
            wrk.pen = wrk.pen + v-pen.
            b-wrk.pen = b-wrk.pen + v-pen.
            v-pen = 0.
        end.
        if v-ost > 0 then do:
            wrk.ost = wrk.ost + v-ost.
            b-wrk.ost = b-wrk.ost + v-ost.
            v-ost = 0.
        end.
    end.

    if v-bal7 > 0 or v-prc_prosr > 0 or v-pen > 0 or v-comdolg > 0 or v-ost > 0 then do:
        find first wrk where wrk.ztype = v-ztype and wrk.segm = v-segm and wrk.dt = dt1 and wrk.bank = s-ourbank and wrk.crc = txb.lon.crc no-error.
        if not avail wrk then do:
            create wrk.
            assign wrk.segm = v-segm
                   wrk.dt = dt1
                   wrk.crc = txb.lon.crc
                   wrk.bank = s-ourbank
                   wrk.bankn = v-bankn
                   wrk.ztype = v-ztype.
        end.
        find first b-wrk where b-wrk.ztype = 3 and b-wrk.segm = v-segm and b-wrk.dt = dt1 and b-wrk.bank = s-ourbank and b-wrk.crc = txb.lon.crc no-error.
        if not avail b-wrk then do:
            create b-wrk.
            assign b-wrk.segm = v-segm
                   b-wrk.dt = dt1
                   b-wrk.crc = txb.lon.crc
                   b-wrk.bank = s-ourbank
                   b-wrk.bankn = v-bankn
                   b-wrk.ztype = 3.
        end.
        if v-bal7 > 0 then do:
            wrk.od = wrk.od + v-bal7.
            b-wrk.od = b-wrk.od + v-bal7.
        end.
        if v-prc_prosr > 0 then do:
            wrk.prc = wrk.prc + v-prc_prosr.
            b-wrk.prc = b-wrk.prc + v-prc_prosr.
        end.
        if v-pen > 0 then do:
            wrk.pen = wrk.pen + v-pen.
            b-wrk.pen = b-wrk.pen + v-pen.
        end.
        if v-comdolg > 0 then do:
            wrk.com = wrk.com + v-comdolg.
            b-wrk.com = b-wrk.com + v-comdolg.
        end.
        if v-ost > 0 then do:
            wrk.ost = wrk.ost + v-ost.
            b-wrk.ost = b-wrk.ost + v-ost.
        end.
    end.


end. /* for each txb.lon */
