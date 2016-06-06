/* lnauditn1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Расшифровка кредитного портфеля для аудита новый (один филиал)
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
        26/11/2009 madiyar - скопировал из lnaudit1.p с изменениями
 * BASES
        BANK COMM TXB
 * CHANGES
         01/12/2009 galina - добавила Код клиента и Филиал
*/

def input parameter d1 as date no-undo.
def shared var v-reptype as integer no-undo. /* 1 - юр, 2 - физ (без БД), 3 - только БД, 4 - все */
def shared var g-ofc as char.
def shared var g-today as date.
def shared var d-rates as deci no-undo extent 20.
def shared var c-rates as deci no-undo extent 20.
def var bilance as decimal format '->,>>>,>>>,>>9.99' no-undo.
def var proc as deci no-undo.
def var pol_proc as deci no-undo.
def var prov as deci no-undo.
def var city as char no-undo.
def var v-bal19 as deci no-undo.
def var v-pen as deci no-undo.
def var v-bal19all as deci no-undo.
def var v-daysod as integer no-undo.
def var v-daysprc as integer no-undo.

/* группы кредитов юридических лиц */
def var lst_grp as char no-undo init ''.
def var i as integer no-undo.
def var v-grp as integer no-undo.

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


def shared temp-table wrk no-undo
    field bank as char
    field bankn as char
    field cif as char
    field lon as char
    field grp as integer
    field num_dog as char  /* номер договора */
    field name as char
    field tgt as char
    field rdt as date
    field duedt as date
    field gl as integer
    field crc as integer
    field rate_rdt as deci /* new - */
    field ostatok as deci
    field ostatok_kzt as deci
    field prem_init as deci /* new - */
    field prem as deci /* check - */
    field od_paid as deci /* new - */
    field od_paid_kzt as deci /* new - */
    field prolong as int
    field dprolong as date
    field dtprosr as date /* new - */
    field pnlt as deci /* new - */
    field prosr_od as deci
    field prosr_od_kzt as deci
    field nach_prc as deci
    field nach_prc_kzt as deci
    field pol_prc as deci
    field pol_prc_kzt as deci
    field prosr_prc as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field sum_prosr as deci /* new */
    field sum_prosr_kzt as deci /* new */
    field obesall_lev19 as deci
    field obesdes as char
    field rezsum as deci
    field rezprc as deci
    field otrasl as char
    field days2end as integer
    field uchastie as logi format "да/нет"
    index ind is primary bank name.


find first txb.cmp no-lock no-error.
if avail txb.cmp then city = entry(1,txb.cmp.addr[1]).

find first txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
if avail txb.sysc and txb.sysc.chval = 'TXB00' then city =  'ЦО ' + city.

hide message no-pause.
message city.

do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:

       run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7,20,21",no,txb.lon.crc,output bilance).
       run lonbalcrc_txb('lon',txb.lon.lon,d1,"2,9,22,23",no,txb.lon.crc,output proc).
       run lonbalcrc_txb('lon',txb.lon.lon,d1,"12",no,1,output pol_proc).
       pol_proc = - pol_proc.
       run lonbalcrc_txb('lon',txb.lon.lon,d1,"3,6",no,txb.lon.crc,output prov).
       prov = - prov.
       if txb.lon.crc <> 1 then prov = round(prov * d-rates[txb.lon.crc],2).

       v-bal19all = 0.
       for each txb.crc no-lock:
         run lonbalcrc_txb('lon',txb.lon.lon,d1,"19",no,txb.crc.crc,output v-bal19).
         if v-bal19 > 0 then v-bal19all = v-bal19all + v-bal19 * d-rates[txb.crc.crc].
       end.

       /* пропускаем если ОД=0 и нач.проценты=0 */
       if bilance <= 0 and proc <= 0 and prov <= 0 and v-bal19all <= 0 and pol_proc <= 0 then next.

       create wrk.
       assign wrk.bank = txb.cmp.name
              wrk.gl = txb.lon.gl.

       find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
       if avail txb.cif then wrk.name = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
       else wrk.name = "НЕ НАЙДЕН".
       assign wrk.cif = txb.lon.cif
              wrk.lon = txb.lon.lon
              wrk.grp = txb.lon.grp
              wrk.bankn = city
              wrk.crc = txb.lon.crc
              wrk.rdt = txb.lon.rdt
              wrk.duedt = txb.lon.duedt
              wrk.obesall_lev19 = v-bal19all
              wrk.pol_prc_kzt = pol_proc.

       if txb.lon.crc = 1 then wrk.rate_rdt = 1.
       else do:
           find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < txb.lon.rdt no-lock no-error.
           if avail txb.crchis then wrk.rate_rdt = txb.crchis.rate[1].
       end.

       find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
       wrk.num_dog = txb.loncon.lcnt.

       if txb.lon.ddt[5] <> ? then do:
           wrk.dprolong = txb.lon.ddt[5].
           if txb.lon.ddt[5] >= d1 then wrk.prolong = 1.
       end.
       if txb.lon.cdt[5] <> ? then do:
           wrk.dprolong = txb.lon.cdt[5].
           if txb.lon.cdt[5] >= d1 then wrk.prolong = 2.
       end.
       if txb.lon.duedt >= d1 then wrk.prolong = 0.

       run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7",no,txb.lon.crc,output wrk.ostatok).
       run lonbalcrc_txb('lon',txb.lon.lon,d1,"7",no,txb.lon.crc,output wrk.prosr_od).
       wrk.od_paid = txb.lon.opnamt - wrk.ostatok.

       if txb.lon.crc <> 1 then do:
           wrk.ostatok_kzt = wrk.ostatok * d-rates[txb.lon.crc].
           wrk.prosr_od_kzt = wrk.prosr_od * d-rates[txb.lon.crc].
           wrk.od_paid_kzt = wrk.od_paid * d-rates[txb.lon.crc].
       end.

       find first txb.ln%his where txb.ln%his.lon = txb.lon.lon no-lock no-error.
       if avail txb.ln%his then wrk.prem_init = txb.ln%his.intrate.
       else wrk.prem_init = txb.lon.prem.

       find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < d1 no-lock no-error.
       if avail txb.ln%his then do:
           wrk.prem = txb.ln%his.intrate.
           wrk.pnlt = txb.ln%his.pnlt1.
       end.
       else do:
           wrk.prem = txb.lon.prem.
           find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
           if avail txb.loncon then wrk.pnlt = txb.loncon.sods1.
       end.

       run lonbalcrc_txb('lon',txb.lon.lon,d1,"2,9",no,txb.lon.crc,output wrk.nach_prc).
       run lonbalcrc_txb('lon',txb.lon.lon,d1,"9",no,txb.lon.crc,output wrk.prosr_prc).
       run lonbalcrc_txb('lon',txb.lon.lon,d1,"4",no,txb.lon.crc,output wrk.prosr_prc_zabal).

       if wrk.prosr_od > 0 or wrk.prosr_prc > 0 then
         run lndayspr_txb(txb.lon.lon,d1,no,output v-daysod,output v-daysprc).

       if v-daysod < v-daysprc then v-daysod = v-daysprc.
       if v-daysod > 0 then wrk.dtprosr = d1 - v-daysod.
       else wrk.dtprosr = ?.

       wrk.nach_prc_kzt = wrk.nach_prc * d-rates[txb.lon.crc].
       wrk.prosr_prc_kzt = wrk.prosr_prc * d-rates[txb.lon.crc].
       wrk.prosr_prc_zab_kzt = wrk.prosr_prc_zabal * d-rates[txb.lon.crc].

       run lonbalcrc_txb('lon',txb.lon.lon,d1,"5,16",no,txb.lon.crc,output v-pen).
       /*
       v-comdolg = 0.
       for each txb.bxcif where txb.bxcif.cif = txb.lon.cif and txb.bxcif.type = '195' and txb.bxcif.aaa = txb.lon.aaa no-lock:

       end.
       */
       if txb.lon.crc = 1 then do:
           wrk.sum_prosr = wrk.prosr_od + wrk.prosr_prc + wrk.prosr_prc_zabal + v-pen.
           wrk.sum_prosr_kzt = wrk.sum_prosr.
       end.
       else do:
           wrk.sum_prosr = wrk.prosr_od + wrk.prosr_prc + wrk.prosr_prc_zabal + round(v-pen / d-rates[txb.lon.crc],2).
           wrk.sum_prosr_kzt = (wrk.prosr_od + wrk.prosr_prc + wrk.prosr_prc_zabal) * d-rates[txb.lon.crc] + v-pen.
       end.

       wrk.uchastie = no.

       find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
       if avail txb.sub-cod then do:
         find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
         wrk.otrasl = txb.codfr.name[1].
       end.
       else wrk.otrasl = "НЕ ПРОСТАВЛЕНА".

       find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < d1 no-lock no-error.
       find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
       wrk.rezprc = txb.lonstat.prc.
       wrk.rezsum = prov.

       /***** Объект кредитования *****/
      find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lntgt' no-lock no-error.
      if avail txb.sub-cod then do:
        find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
        if avail txb.codfr then wrk.tgt = trim(txb.codfr.name[1]).
      end.

    end. /* for each txb.lon */

end. /* do i = 1 to */

