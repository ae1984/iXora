/* lnrns1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Управленческий отчет по кредитному портфелю - миграция
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
        21/07/2009 madiyar - скопировал из lnrn1.p с изменениями
 * BASES
        BANK COMM TXB
 * CHANGES
        30/07/2009 madiyar - подправил расчет фактических просрочек
*/

def shared var d as date no-undo extent 2.
def shared var v-reptype as integer no-undo. /* 1 - юр, 2 - физ (без БД), 3 - только БД, 4 - все */
def shared var g-ofc as char.
def shared var g-today as date.
def var bilance as decimal format '->,>>>,>>>,>>9.99' no-undo.
def var city as char no-undo.
def var v-days_f as integer no-undo.

def var dn1 as integer no-undo.
def var dn2 as integer no-undo.

/* группы кредитов юридических лиц */
def var lst_grp as char no-undo init ''.
def var i as integer no-undo.
def var n as integer no-undo.
def var v-grp as integer no-undo.

def var chk as logi no-undo init no.

def buffer bjl for txb.jl.

case v-reptype:
  when 1 then do:
    for each txb.longrp no-lock:
      if substr(string(txb.longrp.stn),1,1) = '2' then do:
        if lst_grp <> '' then lst_grp = lst_grp + ','.
        lst_grp = lst_grp + string(txb.longrp.longrp).
      end.
    end.
  end.
  when 2 then do:
    for each txb.longrp no-lock:
      if substr(string(txb.longrp.stn),1,1) = '1' and (txb.longrp.longrp <> 90) and (txb.longrp.longrp <> 92) then do:
        if lst_grp <> '' then lst_grp = lst_grp + ','.
        lst_grp = lst_grp + string(txb.longrp.longrp).
      end.
    end.
  end.
  when 3 then lst_grp = "90,92".
  when 4 then do:
    for each txb.longrp no-lock:
      if lst_grp <> '' then lst_grp = lst_grp + ','.
      lst_grp = lst_grp + string(txb.longrp.longrp).
    end.
  end.
  otherwise lst_grp = ''.
end case.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def shared temp-table wrk1 no-undo
  field rep_id as int
  field id as int
  field gr as char
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  field polprc as deci /* полученные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  field polpen as deci /* полученные штрафы */
  index idx is primary rep_id id.

def buffer b-wrk1 for wrk1.

def shared temp-table wrk no-undo
    field d as integer
    field bank as char
    field gl like txb.lon.gl
    field name as char
    field cif like txb.lon.cif
    field lon like txb.lon.lon
    field grp like txb.lon.grp
    field bankn as char
    field crc like txb.crc.crc
    field rdt like txb.lon.rdt
    field duedt like txb.lon.duedt
    field opnamt as deci
    field opnamt_kzt as deci
    field ostatok as deci
    field prosr_od as deci

    field dayc_od as int
    field fdayc_od as int
    field fdayc_od2 as int

    field cat as int

    field ostatok_kzt as deci
    field prosr_od_kzt as deci
    field prem as deci
    field nach_prc as deci
    field pol_prc as deci
    field prosr_prc as deci

    field dayc_prc as int
    field fdayc_prc as int

    field nach_prc_kzt as deci
    field pol_prc_kzt as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field penalty as deci
    field penalty_zabal as deci
    field penalty_pol as deci

    field processed as logi init no

    index ind is primary d bank cif lon
    index ind2 d processed.

find first txb.cmp no-lock no-error.
if avail txb.cmp then city = entry(1,txb.cmp.addr[1]).

/*
hide message no-pause.
message " Обрабатывается база " + city + " ".
*/

def var d-rates as deci no-undo extent 20.

do n = 1 to 2:
    for each txb.crc no-lock:
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < d[n] no-lock no-error.
        if avail txb.crchis then d-rates[txb.crc.crc] = txb.crchis.rate[1].
    end.

    chk = no.
    find last txb.cls where txb.cls.whn < d[n] and txb.cls.del no-lock no-error.
    if avail txb.cls and month(txb.cls.whn) <> month(d[n]) then chk = yes.

    do i = 1 to num-entries(lst_grp):
        v-grp = integer(entry(i,lst_grp)).
        for each txb.lon where txb.lon.grp = v-grp no-lock:

            if txb.lon.opnamt <= 0 then next.
            if txb.lon.rdt >= d[n] then next.

            run lonbalcrc_txb('lon',txb.lon.lon,d[n],"1,7",no,txb.lon.crc,output bilance).

            /* пропускаем если ОД=0 */
            if bilance <= 0 then next.

            create wrk.
            assign wrk.d = n
                   wrk.ostatok = bilance
                   wrk.bank = txb.cmp.name
                   wrk.gl = txb.lon.gl.

            find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
            if avail txb.cif then wrk.name = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
            else wrk.name = "НЕ НАЙДЕН".

            assign wrk.cif = txb.lon.cif
                   wrk.lon = txb.lon.lon
                   wrk.grp = txb.lon.grp
                   wrk.bankn = city
                   wrk.crc = txb.lon.crc
                   wrk.rdt = txb.lon.rdt
                   wrk.duedt = txb.lon.duedt.

            run lonbalcrc_txb('lon',txb.lon.lon,d[n],"12",no,1,output wrk.pol_prc_kzt).
            wrk.pol_prc_kzt = - wrk.pol_prc_kzt.

            wrk.opnamt = txb.lon.opnamt.
            wrk.opnamt_kzt = txb.lon.opnamt * d-rates[txb.lon.crc].

            run lonbalcrc_txb('lon',txb.lon.lon,d[n],"7",no,txb.lon.crc,output wrk.prosr_od).

            wrk.ostatok_kzt = wrk.ostatok * d-rates[txb.lon.crc].
            wrk.prosr_od_kzt = wrk.prosr_od * d-rates[txb.lon.crc].

            find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < d[n] no-lock no-error.
            if avail txb.ln%his then wrk.prem = txb.ln%his.intrate.
            else wrk.prem = txb.lon.prem.

            run lonbalcrc_txb('lon',txb.lon.lon,d[n],"2,9",no,txb.lon.crc,output wrk.nach_prc).
            run lonbalcrc_txb('lon',txb.lon.lon,d[n],"9",no,txb.lon.crc,output wrk.prosr_prc).
            run lonbalcrc_txb('lon',txb.lon.lon,d[n],"4",yes,txb.lon.crc,output wrk.prosr_prc_zabal).

            wrk.dayc_od = 0. wrk.dayc_prc = 0.
            if (wrk.prosr_od > 0) or (wrk.prosr_prc > 0) or (chk) then do:
                run lndayspr_txb(txb.lon.lon,d[n],no,output wrk.dayc_od,output wrk.dayc_prc).
                run lndaysprf_txb(txb.lon.lon,d[n],no,output wrk.fdayc_od,output wrk.fdayc_prc).
            end.

            /* фактические дни просрочки */
            if wrk.fdayc_od > wrk.fdayc_prc then v-days_f = wrk.fdayc_od. else v-days_f = wrk.fdayc_prc.
            if v-days_f = 0 then find first wrk1 where wrk1.rep_id = n and wrk1.id = 1.
            else
            if v-days_f < 31 then find first wrk1 where wrk1.rep_id = n and wrk1.id = 2.
            else
            if v-days_f < 61 then find first wrk1 where wrk1.rep_id = n and wrk1.id = 3.
            else
            if v-days_f < 91 then find first wrk1 where wrk1.rep_id = n and wrk1.id = 4.
            else
            if v-days_f < 181 then find first wrk1 where wrk1.rep_id = n and wrk1.id = 5.
            else
            if v-days_f < 361 then find first wrk1 where wrk1.rep_id = n and wrk1.id = 6.
            else
            find first wrk1 where wrk1.rep_id = n and wrk1.id = 7.

            wrk.cat = wrk1.id.

            wrk1.kol = wrk1.kol + 1.
            if txb.lon.crc = 1 then assign wrk1.od = wrk1.od + wrk.ostatok wrk1.odp = wrk1.odp + wrk.prosr_od.
            else do:
                wrk1.od = wrk1.od + wrk.ostatok * d-rates[txb.lon.crc].
                wrk1.odp = wrk1.odp + wrk.prosr_od * d-rates[txb.lon.crc].
            end.

            wrk.nach_prc_kzt = wrk.nach_prc * d-rates[txb.lon.crc].
            wrk.prosr_prc_kzt = wrk.prosr_prc * d-rates[txb.lon.crc].
            wrk.prosr_prc_zab_kzt = wrk.prosr_prc_zabal * d-rates[txb.lon.crc].

            run lonbalcrc_txb('lon',txb.lon.lon,d[n],"16",yes,1,output wrk.penalty).
            run lonbalcrc_txb('lon',txb.lon.lon,d[n],"5",yes,1,output wrk.penalty_zabal).

            for each txb.jl where txb.jl.acc = txb.lon.lon and txb.jl.dc = 'C' and txb.jl.jdt >= txb.lon.rdt and txb.jl.jdt < d[n] and txb.jl.lev = 16 no-lock:
                find first bjl where bjl.jh = txb.jl.jh and bjl.ln = txb.jl.ln - 1 no-lock no-error.
                if bjl.sub = 'CIF' then wrk.penalty_pol = wrk.penalty_pol + txb.jl.cam.
            end.

            assign wrk1.nachprc = wrk1.nachprc + wrk.nach_prc_kzt
                   wrk1.polprc = wrk1.polprc + wrk.pol_prc_kzt
                   wrk1.prosrprc = wrk1.prosrprc + wrk.prosr_prc_kzt
                   wrk1.nachprcz = wrk1.nachprcz + wrk.prosr_prc_zab_kzt
                   wrk1.pen = wrk1.pen + wrk.penalty
                   wrk1.penz = wrk1.penz + wrk.penalty_zabal
                   wrk1.polpen = wrk1.polpen + wrk.penalty_pol.

        end. /* for each txb.lon */

    end. /* do i = 1 to */
end. /* do n = 1 to 2 */

