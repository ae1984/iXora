/* pkrklas2.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Проверка классификации по экспресс-кредитам
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
        08/07/2009 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        29/08/2009 madiyar - добавил дату погашения
*/

def shared var g-today as date.
def shared var g-ofc as char.

def shared temp-table wrk no-undo
  field bank as char
  field cif as char
  field fio as char
  field lon as char
  field crc as integer
  field sts_prolong as char
  field prolong_rating as deci
  field prosr_kzt as deci
  field prosr_val as deci
  field dayspr as integer
  field dayspr_dc as integer
  field sts_prosr as char
  field sts_prosr_des as char
  field prosr_rating as deci
  field ost_kzt as deci
  field ost_val as deci
  field prov_sts_old as integer
  field prov_sts_new as integer
  field provprc as deci
  field od as deci
  field od_pro as deci
  field progprov as deci
  field duedt as date
  index idx is primary bank crc fio cif.

def var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

hide message no-pause.
message s-ourbank.

def var v-days_od as int no-undo init 0.
def var v-days_prc as int no-undo init 0.
def var v-maxpr as int no-undo init 0.

def var v-aaabal as deci no-undo.
def var v-bilance as deci no-undo.
def var v-bilance_pro as deci no-undo.
def var v-bal1 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal16 as deci no-undo.
def var v-bal4 as deci no-undo.
def var v-bal5 as deci no-undo.
def var nach_od as deci no-undo.
def var nach_prc as deci no-undo.
def var paycom as deci no-undo.

def var dat_wrk as date no-undo.
find last txb.cls where txb.cls.whn < g-today and txb.cls.del no-lock no-error.
dat_wrk = txb.cls.whn.

for each txb.lon where txb.lon.plan = 4 or txb.lon.plan = 5 no-lock:
    if txb.lon.opnamt <= 0 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7",yes,txb.lon.crc,output v-bilance).
    if v-bilance <= 0 then next.

    create wrk.
    assign wrk.bank = s-ourbank
           wrk.cif = txb.lon.cif
           wrk.lon = txb.lon.lon
           wrk.crc = txb.lon.crc
           wrk.duedt = txb.lon.duedt
           wrk.od = v-bilance.

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then wrk.fio = trim(txb.cif.name).

    v-maxpr = 0.
    run lndayspr_txb(txb.lon.lon,g-today,yes,output v-days_od,output v-days_prc).
    if v-days_od > v-days_prc then v-maxpr = v-days_od. else v-maxpr = v-days_prc.
    wrk.dayspr = v-maxpr.
    wrk.dayspr_dc = v-maxpr.

    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1",yes,txb.lon.crc,output v-bal1).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2",yes,txb.lon.crc,output v-bal2).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"7",yes,txb.lon.crc,output v-bal7).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"9",yes,txb.lon.crc,output v-bal9).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"16",yes,1,output v-bal16).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"4",yes,txb.lon.crc,output v-bal4).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"5",yes,1,output v-bal5).

    paycom = 0.
    for each txb.bxcif where txb.bxcif.cif = txb.lon.cif and txb.bxcif.aaa = txb.lon.aaa and txb.bxcif.type = '195' no-lock:
        paycom = paycom + txb.bxcif.amount.
    end.

    if txb.lon.crc = 1 then wrk.prosr_kzt = v-bal7 + v-bal9 + v-bal4 + v-bal16 + v-bal5 + paycom.
    else assign wrk.prosr_val = v-bal7 + v-bal9 + v-bal4 + paycom
                wrk.prosr_kzt = v-bal16 + v-bal5.

    if txb.lon.duedt <= g-today then do:
        if txb.lon.crc = 1 then wrk.prosr_kzt = wrk.prosr_kzt + v-bal1 + v-bal2.
        else wrk.prosr_val = wrk.prosr_val + v-bal1 + v-bal2.
    end.

    v-aaabal = 0.
    if txb.lon.crc = 1 then do:
        find first txb.aaa where txb.aaa.aaa = txb.lon.aaa no-lock no-error.
        if avail txb.aaa then wrk.ost_kzt = txb.aaa.cr[1] - txb.aaa.dr[1].
        v-aaabal = wrk.ost_kzt.
    end.
    else do:
        find first txb.aaa where txb.aaa.aaa = txb.lon.aaa no-lock no-error.
        if avail txb.aaa then wrk.ost_val = txb.aaa.cr[1] - txb.aaa.dr[1].
        find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
        if avail pkanketa then do:
            find first txb.aaa where txb.aaa.aaa = pkanketa.aaa no-lock no-error.
            if avail txb.aaa then wrk.ost_kzt = txb.aaa.cr[1] - txb.aaa.dr[1].
        end.
        v-aaabal = wrk.ost_val.
    end.
    v-bilance_pro = v-bilance.
    if v-aaabal > 0 then do:
        nach_od = 0. nach_prc = 0.
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > dat_wrk and txb.lnsch.stdat <= g-today no-lock no-error.
        if avail txb.lnsch then nach_od = txb.lnsch.stval.
        find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat > dat_wrk and txb.lnsci.idat <= g-today no-lock no-error.
        if avail txb.lnsci then nach_prc = txb.lnsci.iv-sc.

        /* рассчитаем комиссию к оплате (долг + начисленная сегодня) */
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.stdat > dat_wrk and txb.lnsch.stdat <= g-today and txb.lnsch.f0 > 0 no-lock no-error.
        if avail txb.lnsch then do:
            find first txb.tarifex2 where txb.tarifex2.aaa = txb.lon.aaa and txb.tarifex2.cif = txb.lon.cif and txb.tarifex2.str5 = "195" and txb.tarifex2.stat = 'r' no-lock no-error.
            if avail txb.tarifex2 then paycom = paycom + txb.tarifex2.ost.
        end.

        /* штрафы */
        if v-bal16 + v-bal5 > 0 then
            if txb.lon.crc = 1 then do:
                v-aaabal = v-aaabal - v-bal16 - v-bal5.
                if v-aaabal < 0 then v-aaabal = 0.
            end.
        /* просроч. %% */
        if v-aaabal > 0 and v-bal9 + v-bal4 > 0 then do:
            v-aaabal = v-aaabal - v-bal9 - v-bal4.
            if v-aaabal < 0 then v-aaabal = 0.
        end.
        /* комиссия */
        if v-aaabal > 0 and paycom > 0 then do:
            v-aaabal = v-aaabal - paycom.
            if v-aaabal < 0 then v-aaabal = 0.
        end.

        /* проср. ОД, %% по графику, ОД по графику */
        if v-aaabal > 0 then do:
            /* если выходит из просрочки - обнуляем кол-во дней просрочки */
            if v-aaabal > v-bal7 + nach_od + nach_prc then v-maxpr = 0.
            wrk.dayspr_dc = v-maxpr.
            /* рассчитаем прогнозный ОД */
            /* просрочка ОД */
            if v-aaabal > v-bal7 then do:
                v-aaabal = v-aaabal - v-bal7.
                v-bilance_pro = v-bilance_pro - v-bal7.
            end.
            else do:
                v-bilance_pro = v-bilance_pro - v-aaabal.
                v-aaabal = 0.
            end.
            /* %% по графику */
            if v-aaabal > 0 and nach_prc > 0 then do:
                if v-aaabal > nach_prc then v-aaabal = v-aaabal - nach_prc.
                else v-aaabal = 0.
            end.
            /* ОД по графику */
            if v-aaabal > 0 and nach_od > 0 then do:
                if v-aaabal > nach_od then do:
                    v-aaabal = v-aaabal - nach_od.
                    v-bilance_pro = v-bilance_pro - nach_od.
                end.
                else do:
                    v-bilance_pro = v-bilance_pro - v-aaabal.
                    v-aaabal = 0.
                end.
            end.
        end.
    end.

    wrk.od_pro = v-bilance_pro.

    find first kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.rdt = g-today and kdlonkl.kod = 'prosr' no-lock no-error.
    if avail kdlonkl then do:
        wrk.sts_prosr = kdlonkl.val1.
        find bookcod where bookcod.bookcod = 'kdprosr' and bookcod.code = kdlonkl.val1 no-lock no-error.
        if avail bookcod then assign wrk.sts_prosr_des = bookcod.name
                                     wrk.prosr_rating = deci(trim(bookcod.info[1])).
    end.

    find first kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.rdt = g-today and kdlonkl.kod = 'long' no-lock no-error.
    if avail kdlonkl then do:
        wrk.sts_prolong = kdlonkl.val1.
        find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = '02' no-lock no-error.
        if avail bookcod then wrk.prolong_rating = decimal(kdlonkl.val1) * deci(trim(bookcod.info[1])).
    end.

    find first kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.rdt = g-today and kdlonkl.kod = 'klass' no-lock no-error.
    if avail kdlonkl then do:
        wrk.prov_sts_new = integer(kdlonkl.val1).
        find first bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlonkl.val1 no-lock no-error.
        if avail bookcod then do:
            wrk.provprc = deci(bookcod.info[1]).
            wrk.progprov = round(v-bilance_pro * wrk.provprc / 100,2).
        end.
    end.

    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < g-today no-lock no-error.
    if avail txb.lonhar then wrk.prov_sts_old = txb.lonhar.lonstat.

end. /* for each txb.lon */

