/* loan1.p
 * MODULE
        3-4-2-16-19
 * DESCRIPTION
        Описание
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
        21.06.2011 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        29.06.2011 aigul - добавила валюту займа
*/
def shared var v-bank as char.
def shared temp-table wrk
    field i as int
    field bank as char
    field cif as char
    field cname as char
    field lon as char
    field dog as char
    field dt as date
    field sts as char
    field sum as decimal
    field prc as decimal
    field srok as int
    field prc1 as decimal
    field srok1 as int
    field n-prc as decimal
    field a-prc as decimal
    field o-prc as decimal
    field od as decimal
    field perc as decimal
    field days as int
    field a-prc1 as decimal
    field o-prc1 as decimal
    field prbal as decimal
    field przbal as decimal
    field penpog as decimal
    field pensbal as deci
    field penszbal as decimal
    field penna as deci
    field pennazbal as deci
    field prpolkzt as deci
    field prres as char
    field prod as int
    field prpr as int
    field prkol as int
    field prmax as int
    field lcrc as char.
def var dt1 as date.
def var dt2 as date.
def var month as int.
def var year as int.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.
def var i as int.
def var v-anuitet as decimal.
def var v-ost as decimal.
def var v-anuitet1 as decimal.
def var v-ost1 as decimal.
def var v-lonprnlev as char initial "1;7;8".
define variable dam1-cam1 as decimal.
def var v-perc as decimal.
def var dt as decimal.
def var v-przbal as decimal.
def shared var d-rates as deci no-undo extent 20.
def input parameter d1 as date no-undo.
def var v-pendel as decimal.
def buffer bjl for txb.jl.
def var v-ost-all as decimal.
/* Список нужных клиентов
def var LINE as char.
def temp-table list
    field cif as char.
input from "list.txt".
LOOP:
     REPEAT ON ENDKEY UNDO, LEAVE LOOP:
     IMPORT LINE.
     create list.
     list.cif = LINE.
END.*/
i = 0.
v-przbal = 0.

/*for each list no-lock:*/
for each txb.lon where (txb.lon.grp = 90 or txb.lon.grp = 92) /*and txb.lon.cif = list.cif*/ no-lock:
    i = i + 1.
    create wrk.
    wrk.i = i.
    wrk.bank = v-bank.
    wrk.cif = txb.lon.cif.
    find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
    if avail txb.crc then  wrk.lcrc = txb.crc.code.
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then wrk.cname = txb.cif.name.
    wrk.lon = txb.lon.lon.
    find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if avail loncon then  wrk.dog = txb.loncon.lcnt.
    wrk.dt = txb.lon.opndt.
    v-ost-all = 0.
    run lonbalcrc('lon',txb.lon.lon,today,"1,2,7,9",no,txb.lon.crc,output v-ost-all).
    if v-ost-all = 0 then wrk.sts = string(v-ost-all).
    else wrk.sts = txb.lon.lon + string(v-ost-all).
    wrk.sts = txb.lon.sts.
    wrk.sum = txb.lon.opnamt.
    wrk.prc = txb.lon.prem.
    find first pkanketa where pkanketa.bank = v-bank and pkanketa.lon = txb.lon.lon no-lock no-error.
    if avail pkanketa then do:
        wrk.prc1 = pkanketa.rateq.
        wrk.srok1 = pkanketa.srok.
    end.
    month = month(txb.lon.duedt) - month(txb.lon.rdt).
    year = year(txb.lon.duedt) - year(txb.lon.rdt).
    run day-360(txb.lon.rdt, txb.lon.duedt - 1,txb.lon.basedy,output dn1,output dn2).
    wrk.n-prc = round(dn1 * txb.lon.opnamt * wrk.prc1 / 100 / 360,2).
    run loan2(v-bank, txb.lon.lon, output v-ost).
    wrk.o-prc = v-ost.
    run loan21(v-bank, txb.lon.lon, output v-ost1).
    wrk.o-prc1 = v-ost1.
    run loan3(v-bank, txb.lon.lon, output v-anuitet).
    wrk.a-prc = v-anuitet.
    run loan31(v-bank, txb.lon.lon, output v-anuitet1).
    wrk.a-prc1 = v-anuitet1.
    dt = (today - txb.lon.rdt) / 30.
    wrk.days = round(dt,0).
    dam1-cam1 = 0.
    for each txb.trxbal where txb.trxbal.subled eq "LON" and txb.trxbal.acc = txb.lon.lon no-lock :
        if lookup(string(txb.trxbal.level) , v-lonprnlev , ";") > 0 then
        dam1-cam1 = dam1-cam1 + (txb.trxbal.dam - txb.trxbal.cam).
    end.
    wrk.od = dam1-cam1.
    v-perc = 0.
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp > 0 and txb.lnsci.f0 = 0 no-lock:
    v-perc = v-perc + txb.lnsci.paid.
    end.
    wrk.perc = v-perc.
    run lonbalcrc_txb('lon',txb.lon.lon,d1,"11",no,1,output wrk.prbal).
    wrk.prbal = - wrk.prbal.

    run lonbalcrc_txb('lon',txb.lon.lon,d1,"4",no,txb.lon.crc,output v-przbal).
    wrk.przbal = v-przbal * d-rates[txb.lon.crc].
    for each txb.jl where txb.jl.acc = txb.lon.lon and txb.jl.dc = 'C' and txb.jl.jdt >= txb.lon.rdt and txb.jl.jdt < d1 and txb.jl.lev = 16 no-lock:
        find first bjl where bjl.jh = txb.jl.jh and bjl.ln = txb.jl.ln - 1 no-lock no-error.
        if bjl.sub = 'CIF' then wrk.penpog = wrk.penpog + txb.jl.cam.
    end.
    run lonbalcrc_txb('lon',txb.lon.lon,d1,"16",no,1,output wrk.penna).
    run lonbalcrc_txb('lon',txb.lon.lon,d1,"5",no,1,output wrk.pennazbal).
    find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = 'LON' and sub-cod.d-cod = 'pkrst' use-index dcod no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:
    find first txb.codfr where txb.codfr.codfr = 'pkrst' and txb.codfr.code = txb.sub-cod.ccod no-lock no-error.
    if avail txb.codfr then wrk.prres = txb.codfr.name[1].
    else wrk.prres = '-'.
    end.
    else wrk.prres = '-'.
    run lonbalcrc_txb('lon',txb.lon.lon,d1,"12",no,1,output wrk.prpolkzt).
    wrk.prpolkzt = - wrk.prpolkzt.

    for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= d1 and txb.lonres.lev = 16 no-lock:
      if txb.lonres.dc = 'c' then do:
         find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.dc = 'D' no-lock no-error.
         if avail txb.jl then do:
            if txb.jl.gl = 490000 then v-pendel = v-pendel + txb.jl.dam.
         end.
      end.
    end.
    v-pendel = 0.
    for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= d1 and txb.lonres.lev = 5 no-lock:
       if txb.lonres.dc = 'c' then do:
          find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.dc = 'D' no-lock no-error.
          if avail txb.jl then do:
             if txb.jl.gl = 788000 then do:
                find first bjl where bjl.jh = txb.jl.jh and bjl.ln = txb.jl.ln + 1 no-lock no-error.
                if avail bjl and bjl.gl = 718000 then v-pendel = v-pendel + txb.jl.dam.
             end.
          end.
       end.
    end.
    wrk.pensbal = v-pendel.
    run lonbalcrc_txb('lon',txb.lon.lon,d1,"30",no,1,output wrk.penszbal).
    run lndayspr_txb(txb.lon.lon,d1,no,output wrk.prod,output wrk.prpr).
    run loanday(txb.lon.lon, no, output prkol, output prmax).

end.
/*end.*/

