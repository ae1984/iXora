/* pkfizport1.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Отчет по динамике портфеля МКО
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
        03/12/2009 galina
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def input parameter p-bank as char.
def var counter as integer no-undo.
def var bdat as date no-undo.
def var bilance as decimal no-undo.
def shared var dates as date no-undo extent 7.
def var v-sum1 as deci no-undo.
def var v-sum2 as deci no-undo.
def buffer b-jl for txb.jl.

/*выданные кредиты*/
def shared temp-table wrk no-undo
  field cif as char
  field dt as date
  field port_kzt as decimal
  field port_usd as decimal
  field sumod as decimal
  field sumdoh as decimal
  field bank as char
  field crc as integer
  field sumbal as deci.

procedure getAmounts:
    def input parameter p-aaa as char no-undo.
    def input parameter p-dt as date no-undo.
    def output parameter p-sumod as deci no-undo.
    def output parameter p-sumdoh as deci no-undo.
    assign p-sumod = 0 p-sumdoh = 0.
    for each txb.jl where txb.jl.sub = 'cif' and txb.jl.acc = p-aaa and txb.jl.dc = 'D' and txb.jl.jdt < p-dt and txb.jl.lev = 1 no-lock:
        find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
        if avail txb.jh and txb.jh.party begins "STORN" then next.
        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.sub = 'lon' and b-jl.dc = "C" and b-jl.genln = txb.jl.genln no-lock no-error.
        if avail b-jl then do:
            if b-jl.sub = 'lon' then do:
                if (b-jl.lev = 1) or (b-jl.lev = 7) then p-sumod = p-sumod + txb.jl.dam.
                else
                if (b-jl.lev = 2) or (b-jl.lev = 4) or (b-jl.lev = 5) or (b-jl.lev = 9) or (b-jl.lev = 16) then p-sumdoh = p-sumdoh + txb.jl.dam.
            end.
            else
            if b-jl.gl = 460712 then p-sumdoh = p-sumdoh + txb.jl.dam.
        end.
    end.
end procedure.


do counter = 1 to 7:
  bdat = dates[counter].
  for each txb.lon where txb.lon.grp = 90 or txb.lon.grp = 92 no-lock:
    if txb.lon.rdt >= bdat then next.
    if txb.lon.opnamt <= 0 then next.
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.
    run lonbalcrc_txb('lon', txb.lon.lon, bdat, "1,7", no, txb.lon.crc, output bilance).
    create wrk.
    assign wrk.bank = p-bank
           wrk.dt = bdat
           wrk.cif = txb.lon.cif
           wrk.crc = txb.lon.crc.

    find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < bdat no-lock no-error.
    assign wrk.port_kzt = bilance. wrk.port_usd = bilance / txb.crchis.rate[1].
    find first txb.aaa where txb.aaa.aaa = txb.lon.aaa no-lock no-error.
    if avail txb.aaa then do:
       run getAmounts(txb.aaa.aaa,bdat,output v-sum1,output v-sum2).
       assign wrk.sumod = v-sum1 wrk.sumdoh = v-sum2.
    end.
    if counter = 7 then do:
        find first bank.codfr where bank.codfr.codfr = "lnmko" and bank.codfr.code = substring(p-bank,4,2) + "-" + txb.lon.lon no-lock no-error.
        if avail bank.codfr then wrk.sumbal = deci(bank.codfr.name[2]).
    end.
  end. /*for each txb.lon*/
end. /*counter*/