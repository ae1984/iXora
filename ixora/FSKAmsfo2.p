/* lnaudit1.p
 * MODULE
        Отчетность
 * DESCRIPTION
        Отчет ФС_КА_МСФО
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
        19.06.2013 dmitriy - ТЗ 1345
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def input parameter d1 as date no-undo.
def shared var v-reptype as integer no-undo. /* 1 - юр, 2 - физ (без БД), 3 - только БД, 4 - все */
def shared var g-ofc as char.
def shared var g-today as date.
def shared var d-rates as deci no-undo extent 20.
def shared var c-rates as deci no-undo extent 20.
def var bilance as decimal format '->,>>>,>>>,>>9.99' no-undo.
def var bilance_zo as decimal format '->,>>>,>>>,>>9.99' no-undo.
def var proc as deci no-undo.
def var pol_proc as deci no-undo.
def var prov_od as deci no-undo.
def var prov_prc as deci no-undo.
def var prov_pen as deci no-undo.
def var prov_afn as deci no-undo.
def var prov_zo as deci no-undo.
def var city as char no-undo.
def var tempdt  as date no-undo.
def var tempost as deci no-undo.
def var v-bal19 as deci no-undo.
def var v-bal19all as deci no-undo.
def var ll as int.

def buffer b-jl for txb.jl.
def buffer b-lon for txb.lon.
def buffer c-lon for txb.lon.
def var nm as char.
/* группы кредитов юридических лиц */
def var lst_grp as char no-undo init ''.
def var i as integer no-undo.
def var j as integer no-undo.
def var v-grp as integer no-undo.

def var dd       as int no-undo.
def var d3       as date no-undo.

if month(d1) - 3 <= 0 Then do:
 run mondays(12 + month(d1) - 3,year(d1),output dd).
 if dd > day(d1) then dd = day(d1).
 d3 = date(string(dd) + '/' + String(12 + month(d1) - 3) + '/' + string(year(d1))).
end.
else do:
 run mondays(month(d1) - 3,year(d1),output dd).
 if dd > day(d1) then dd = day(d1).
 d3 = date(string(dd) + '/' + String(month(d1) - 3) + '/' + string(year(d1))).
end.

def var bal-sum  as deci no-undo.
def var bal-dam  as deci no-undo.
def var res-sum  as deci no-undo.
def var res-dam  as deci no-undo.
def var v-nvng   as deci no-undo.

def var v-rate as deci.
def var sum_od as deci.
def var sum_korr as deci.
def var sum_vozn as deci.
def var sum_prov1 as deci.

case v-reptype:
    when 1 then do:
        for each txb.longrp no-lock:
            if substr(string(txb.longrp.stn),1,1) = '2' and not txb.longrp.des matches '*МСБ*' then do:
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
            if txb.longrp.des matches '*МСБ*' or txb.longrp.longrp = 70 or txb.longrp.longrp = 80
            or txb.longrp.longrp = 11 or txb.longrp.longrp = 21 then do:
                if lst_grp <> '' then lst_grp = lst_grp + ','.
                lst_grp = lst_grp + string(txb.longrp.longrp).
            end.
        end.
    end.
    when 5 then do:
        for each txb.longrp no-lock:
            if lst_grp <> '' then lst_grp = lst_grp + ','.
            lst_grp = lst_grp + string(txb.longrp.longrp).
        end.
    end.
    otherwise lst_grp = ''.
end case.

def var fin as char.
def var rat as decimal.
def var v-dpnv as date no-undo init ?.
def var v-tmp as date no-undo init ?.

def shared temp-table wrk2 no-undo
    field nom      as int
    field name     as char
    field stat     as int
    field od-gl    as char
    field vozn-gl  as char
    field disc-gl  as char
    field korr-gl  as char
    field prov1-gl as char
    field prov2-gl as char
    field obj      as char
    field geo      as char

    field od       as deci extent 8
    field vozn     as deci extent 8
    field disc     as deci extent 8
    field korr     as deci extent 8
    field prov1    as deci extent 8
    field prov2    as deci extent 8
    field discamt  as deci extent 8
    field obespamt as deci extent 8.

def shared temp-table wrk no-undo
    field bank as char
    field gl like txb.lon.gl
    field name as char
    field geo as char
    field schet_gk as char
    field cif like txb.lon.cif
    field ciftype like txb.cif.type
    field lon like txb.lon.lon
    field grp like txb.lon.grp
    field clnsegm as char
    field pooln as char
    field bankn as char
    field crc like txb.crc.crc
    field rdt like txb.lon.rdt
    field isdt as date
    field duedt like txb.lon.duedt
    field dprolong as date
    field prolong as int
    field opnamt as deci
    field opnamt_kzt as deci
    field ostatok as deci
    field pogosh as deci
    field prosr_od as deci
    field dayc_od as int
    field ind_od as deci
    field ostatok_kzt as deci
    field prosr_od_kzt as deci
    field ind_od_kzt as deci
    field pogashen as logi format "да/нет"
    field prem as deci
    field prem_his as deci
    field nach_prc as deci
    field pol_prc as deci
    field prosr_prc as deci
    field dayc_prc as int
    field ind_prc as deci
    field nach_prc_kzt as deci
    field pol_prc_kzt as deci
    field pol_prc_kzt_all as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field ind_prc_kzt as deci
    field prcdt_last as date
    field penalty as deci
    field penalty_zabal as deci
    field penalty_otsr as deci
    field uchastie as logi format "да/нет"
    field obessum_kzt as deci
    field obesdes as char
    field sumgarant as deci
    field sumdepcrd as deci
    field obesall as deci
    field obesall_lev19 as deci
    field neobesp as deci
    field otrasl as char
    field otrasl1 as char
    field finotrasl as char
    field finotrasl1 as char
    field rezprc_afn as deci
    field rezsum_afn as deci
    field rezsum_od as deci
    field rezsum_prc as deci
    field rezsum_pen as deci
    field rezsum_msfo as deci
    field rezprc_msfo as deci
    field num_dog like txb.loncon.lcnt  /* номер договора */
    field tgt   as char
    field dtlpay as date
    field lpaysum as deci
    field kdstsdes as char
    field kodd  as char
    field rate  as char
    field valdesc  as char
    field valdesc_ob  as char
    field dt  as date
    field rel as char
    field bal11 as deci
    field lneko as char
    field rezid as char
    field val as char
    field scode as char
    field dpnv as date
    field nvng as deci
    field amr_dk  as deci /*Амортизация дисконта*/
    field zam_dk  as deci /*Дисконт по займам*/
    field bal34 as deci
    field lnprod as char
    field napr as char
    field nsumkr as deci
    field nsumkr_kzt as deci
    field lonstat as int
    field statname as char
    field tgt_code as char
    field zcode as char
    index ind is primary bank cif.

define shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field acc-ddt as date
    field geo as character
    field dt as date
    index tgl-id1 is primary gl7.

def shared var v-pool as char no-undo extent 10.
def shared var v-poolName as char no-undo extent 10.
def shared var v-poolId as char no-undo extent 10.
def var poolIndex as integer no-undo.
def var poolDes as char no-undo.
def shared var v-sum_msb as deci no-undo.
def var v-bal     as deci no-undo.
def var v-bal_all as deci no-undo.
def var v-clmain as char.

def var v_amr_dk as deci no-undo.
def var v_zam_dk as deci no-undo.
def var v_bal34 as deci no-undo.
def var t_bal34 as deci no-undo.

find first txb.cmp no-lock no-error.
if avail txb.cmp then city = entry(2,txb.cmp.addr[1]).

message "Сбор данных : " + txb.cmp.name.

def var s-ourbank as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7,20,21",no,txb.lon.crc,output bilance).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"2,9,22,23",no,txb.lon.crc,output proc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"12",no,1,output pol_proc).
        pol_proc = - pol_proc.
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"6",no,txb.lon.crc,output prov_od).
        prov_od = - prov_od * d-rates[txb.lon.crc].
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"36",no,txb.lon.crc,output prov_prc).
        prov_prc = - prov_prc * d-rates[txb.lon.crc].
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"37",no,1,output prov_pen).
        prov_pen =  - prov_pen.
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"41",no,txb.lon.crc,output prov_afn).
        prov_afn =  - prov_afn * d-rates[txb.lon.crc].

        v-bal19all = 0.
        for each txb.crc no-lock:
            run lonbalcrc_txb('lon',txb.lon.lon,d1,"19",no,txb.crc.crc,output v-bal19).
            if v-bal19 > 0 then v-bal19all = v-bal19all + v-bal19 * d-rates[txb.crc.crc].
        end.

         /*Амортизация дисконта*/
         run lonbalcrc_txb ('lon',txb.lon.lon,d1,"31",no,txb.lon.crc,output v_amr_dk).
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
            if avail txb.crchis then v_amr_dk = v_amr_dk * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.

         /*Дисконт по займам*/
         run lonbalcrc_txb ('lon',txb.lon.lon,d1,"42",no,txb.lon.crc,output v_zam_dk).
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
            if avail txb.crchis then v_zam_dk = v_zam_dk * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.

         /*сумма в тыс. тенге (34 ур)*/
         run lonbalcrc_txb ('lon',txb.lon.lon,d1,"34",no,txb.lon.crc,output t_bal34).
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
            if avail txb.crchis then t_bal34 = t_bal34 * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.
         v_bal34 = - t_bal34.
         if txb.lon.lon = '005147811' Then do:
             run lonbalcrc_txb ('lon',txb.lon.lon,d1,"34",no,2,output t_bal34).
             find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt <= d1 no-lock no-error.
             if avail txb.crchis then t_bal34 = t_bal34 * txb.crchis.rate[1].
               else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         v_bal34 = v_bal34 - t_bal34.
         end.

        /* пропускаем если ОД=0 и нач.проценты=0 */
        if bilance <= 0 and proc <= 0 and (prov_od + prov_prc + prov_pen + prov_afn) <= 0 and v-bal19all <= 0 and pol_proc <= 0 and prov_zo <= 0 and  v_amr_dk = 0 and v_zam_dk = 0 and v_bal34=0  then next.

        poolIndex = 0.
        do j = 1 to 10:
            if lookup(string(txb.lon.grp),v-pool[j]) > 0 then poolIndex = j.
        end.

        if (poolIndex < 1) or (poolIndex > 10) then poolDes = ''.
        else
        /* по пулам МСБ проверяем на пороговую сумму */
        if (poolIndex = 7) or (poolIndex = 8) then do:
            v-bal_all = 0. v-clmain = ''.
            if d1 > date('01.07.2012') then do:
                for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                    run lonbalcrc_txb('lon',b-lon.lon,d1,"1,7",no,b-lon.crc,output v-bal).
                    if v-bal > 0 then do:
                        if b-lon.clmain <> '' then do:
                            if lookup(b-lon.clmain,v-clmain) = 0 then do:
                                v-clmain = v-clmain + string(b-lon.clmain) + ','.
                                find last c-lon where c-lon.lon = b-lon.clmain no-lock no-error.
                                if c-lon.opnamt > 0 then do:
                                    v-bal = c-lon.opnamt.
                                    if c-lon.crc <> 1 then do:
                                       find last txb.crchis where txb.crchis.crc = c-lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
                                       if avail txb.crchis then v-bal = v-bal * txb.crchis.rate[1].
                                        else message " Ошибка определения курса! cif=" + c-lon.cif + " lon=" + c-lon.lon + " crc=" + string(c-lon.crc) view-as alert-box error.
                                    end.
                                    v-bal_all = v-bal_all + v-bal.
                                end.
                            end.
                        end.
                        else do:
                            if b-lon.gua <> 'CL' then do:
                                if b-lon.opnamt > 0 then do:
                                    v-bal = b-lon.opnamt.
                                    if b-lon.crc <> 1 then do:
                                       find last txb.crchis where txb.crchis.crc = b-lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
                                       if avail txb.crchis then v-bal = v-bal * txb.crchis.rate[1].
                                        else message " Ошибка определения курса! cif=" + b-lon.cif + " lon=" + b-lon.lon + " crc=" + string(b-lon.crc) view-as alert-box error.
                                    end.
                                    v-bal_all = v-bal_all + v-bal.
                                end.
                            end.
                        end.
                    end.
                end.
            end.
            else do:
                if d1 >= date('01/01/2012') then do:
                    for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                        run lonbalcrc_txb('lon',b-lon.lon,d1,"1,7",no,b-lon.crc,output v-bal).
                        if b-lon.crc <> 1 then do:
                           find last txb.crchis where txb.crchis.crc = b-lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
                           if avail txb.crchis then v-bal = v-bal * txb.crchis.rate[1].
                            else message " Ошибка определения курса! cif=" + b-lon.cif + " lon=" + b-lon.lon + " crc=" + string(b-lon.crc) view-as alert-box error.
                        end.
                        if v-bal > 0 then v-bal_all = v-bal_all + v-bal.
                    end.
                end.
                else do:
                    run lonbalcrc_txb('lon',lon.lon,d1,"1,7",no,lon.crc,output v-bal).
                    if lon.crc <> 1 then do:
                       find last txb.crchis where txb.crchis.crc = lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
                       if avail txb.crchis then v-bal = v-bal * txb.crchis.rate[1].
                        else message " Ошибка определения курса! cif=" + lon.cif + " lon=" + lon.lon + " crc=" + string(lon.crc) view-as alert-box error.
                    end.
                    if v-bal > 0 then v-bal_all = v-bal_all + v-bal.
                end.
            end.
            if v-bal_all < v-sum_msb then poolDes = v-poolId[7]. else poolDes = v-poolId[8].
        end.
        else poolDes = v-poolId[poolIndex].

        create wrk.
        assign wrk.bank = txb.cmp.name
               wrk.gl = txb.lon.gl.
               wrk.pooln = poolDes.

        if txb.lon.grp = 13 or
           txb.lon.grp = 14 or
           txb.lon.grp = 16 or
           txb.lon.grp = 53 or
           txb.lon.grp = 54 or
           txb.lon.grp = 55 or
           txb.lon.grp = 56 or
           txb.lon.grp = 70 then wrk.zcode = "23".

        if txb.lon.grp = 24 or
           txb.lon.grp = 25 or
           txb.lon.grp = 26 or
           txb.lon.grp = 63 or
           txb.lon.grp = 64 or
           txb.lon.grp = 65 or
           txb.lon.grp = 66 or
           txb.lon.grp = 80 then wrk.zcode = "24".

        if txb.lon.grp = 10 or
           txb.lon.grp = 15 or
           txb.lon.grp = 50 then wrk.zcode = "6".

        if txb.lon.grp = 20 or
           txb.lon.grp = 60 or
           txb.lon.grp = 81 or
           txb.lon.grp = 82 or
           txb.lon.grp = 90 or
           txb.lon.grp = 92 or
           txb.lon.grp = 95 or
           txb.lon.grp = 96 then wrk.zcode = "9".

        find last b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
        if avail b-lon then do:
          wrk.nsumkr = b-lon.opnamt.
          wrk.nsumkr_kzt = b-lon.opnamt.
         if b-lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = b-lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
            if avail txb.crchis then wrk.nsumkr_kzt = wrk.nsumkr_kzt * txb.crchis.rate[1].
             else message " Ошибка определения курса! cif=" + b-lon.cif + " lon=" + b-lon.lon + " crc=" + string(b-lon.crc) view-as alert-box error.
         end.
        end.


        find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
        if avail pkanketa then do:
            find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "kdsts" no-lock no-error.
            if avail pkanketh then do:
                find first txb.codfr where txb.codfr.codfr = 'kdsts' and txb.codfr.code = pkanketh.value1 no-lock no-error.
                if avail txb.codfr then wrk.kdstsdes = pkanketh.value1 + ' ' + txb.codfr.name[1] + ' ' + pkanketh.value2.
            end.
        end.

        find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        if avail txb.cif then do:
            wrk.name = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
            wrk.geo = txb.cif.geo.
            wrk.ciftype = txb.cif.type.
            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
            if available txb.sub-cod then do:
                if txb.sub-cod.ccode <> "msc" then do:
                    find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                    if avail txb.codfr then do:
                        ll = index(txb.codfr.name[1],"(").
                        if ll > 0 then wrk.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                        else wrk.clnsegm = trim(txb.codfr.name[1]).
                    end.
                end.
            end.
        end.
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
               wrk.amr_dk = v_amr_dk.
               wrk.zam_dk = v_zam_dk.
               wrk.bal34 = v_bal34.

        find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
        if avail txb.lnscg then wrk.isdt = txb.lnscg.stdat.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"11",no,1,output wrk.bal11).
        wrk.bal11 = - wrk.bal11.

        find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.kod = 'finsost1' and kdlonkl.rdt < d1 no-lock no-error.
        if avail kdlonkl then wrk.valdesc = kdlonkl.val1 + " - " + kdlonkl.valdesc.

        find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.kod = 'obesp1' and kdlonkl.rdt < d1 no-lock no-error.
        if avail kdlonkl then wrk.valdesc_ob = kdlonkl.val1 + " - " + kdlonkl.valdesc.

        /* Рейтинг*/
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnrate' no-lock no-error.
        if avail txb.sub-cod then
            find first txb.codific where txb.codific.codfr = txb.sub-cod.d-cod no-lock no-error.
        if avail txb.codific then
            find first txb.codfr where txb.codfr.codfr = txb.codific.codfr and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
        if avail txb.codfr then do:
            wrk.kodd = txb.codfr.code.
            wrk.rate = txb.codfr.name[1].
        end.

        /* Продукт*/
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnprod' no-lock no-error.
        if avail txb.sub-cod then
            find first txb.codific where txb.codific.codfr = txb.sub-cod.d-cod no-lock no-error.
        if avail txb.codific then
            find first txb.codfr where txb.codfr.codfr = txb.codific.codfr and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
        if avail txb.codfr then do:
            wrk.lnprod = txb.codfr.name[1].
        end.

        for each txb.jl where txb.jl.acc = txb.lon.aaa and txb.jl.jdt >= txb.lon.rdt and txb.jl.lev = 1 and txb.jl.dc = 'C' no-lock:
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 and b-jl.sub <> 'LON' no-lock no-error.
            if avail b-jl then do:
                find first txb.aaa where txb.aaa.aaa = b-jl.acc no-lock no-error.
                if (avail txb.aaa and txb.aaa.lgr <> '236' and txb.aaa.lgr <> '237') or not avail txb.aaa then do:
                    wrk.dtlpay = txb.jl.jdt.
                    wrk.lpaysum = b-jl.dam.
                end.
            end.
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

        wrk.opnamt = txb.lon.opnamt.
        wrk.opnamt_kzt = txb.lon.opnamt * d-rates[txb.lon.crc].

        /*Сумма погашенного ОД */
        for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.stdat < d1 no-lock:
          wrk.pogosh = wrk.pogosh + txb.lnsch.paid.
        end.

        /*Получ. % за весь период (в тенге)*/
        for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp > 0 and txb.lnsci.idat < d1 no-lock:
          wrk.pol_prc_kzt_all = wrk.pol_prc_kzt_all + txb.lnsci.paid-iv.
        end.

        /*Дата приостановления начисления вознаграждения*/
        v-dpnv = ?.
        v-tmp = ?.
        for each txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < d1 no-lock break by txb.ln%his.stdat:
          if txb.ln%his.intrate = 0 then do:
              if v-dpnv = ? Then do:
                  if txb.ln%his.rem matches '*авт.обнуление*' then v-dpnv = txb.ln%his.stdat.
                  if txb.ln%his.rem matches '*parm=intrate*' then do:
                    if txb.ln%his.rem matches '*newval=F0*' then v-dpnv = txb.ln%his.stdat.
                    if txb.ln%his.rem matches '*newval=0*' then v-dpnv = txb.ln%his.stdat.
                  end.
              end.
          end. else do:
            If v-tmp <> txb.ln%his.stdat Then
              v-dpnv = ?.
          end.
          v-tmp = txb.ln%his.stdat.
        end.
        wrk.dpnv = v-dpnv.

        /*начисленное вознаграждение за 3 месяца*/

        /*lev = 2*/
        bal-sum = 0. bal-dam = 0.
        for each txb.histrxbal where txb.histrxbal.sub = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.lev = 2 and txb.histrxbal.dt > d3 and txb.histrxbal.dt < d1 no-lock break by txb.histrxbal.dt:
         bal-sum = bal-sum + txb.histrxbal.dam - bal-dam.
         bal-dam = txb.histrxbal.dam.
        end.
        res-sum = 0. res-dam = 0.
        for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 2 and txb.lonres.dc = 'd' and txb.lonres.jdt > d3 and txb.lonres.jdt < d1 no-lock break by txb.lonres.jdt:
         res-sum = bal-sum + txb.lonres.amt - bal-dam.
         res-dam = txb.lonres.amt.
        end.
        v-nvng = bal-sum - res-sum.

        /*lev = 4*/
        bal-sum = 0. bal-dam = 0.
        for each txb.histrxbal where txb.histrxbal.sub = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.lev = 4 and txb.histrxbal.dt > d3 and txb.histrxbal.dt < d1 no-lock break by txb.histrxbal.dt:
         bal-sum = bal-sum + txb.histrxbal.dam - bal-dam.
         bal-dam = txb.histrxbal.dam.
        end.
        res-sum = 0. res-dam = 0.
        for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 4 and txb.lonres.dc = 'd' and txb.lonres.jdt > d3 and txb.lonres.jdt < d1 no-lock break by txb.lonres.jdt:
         res-sum = bal-sum + txb.lonres.amt - bal-dam.
         res-dam = txb.lonres.amt.
        end.
        v-nvng = v-nvng + bal-sum - res-sum.

        /*lev = 9*/
        bal-sum = 0. bal-dam = 0.
        for each txb.histrxbal where txb.histrxbal.sub = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.lev = 9 and txb.histrxbal.dt > d3 and txb.histrxbal.dt < d1 no-lock break by txb.histrxbal.dt:
         bal-sum = bal-sum + txb.histrxbal.dam - bal-dam.
         bal-dam = txb.histrxbal.dam.
        end.
        res-sum = 0. res-dam = 0.
        for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 9 and txb.lonres.dc = 'd' and txb.lonres.jdt > d3 and txb.lonres.jdt < d1 no-lock break by txb.lonres.jdt:
         res-sum = bal-sum + txb.lonres.amt - bal-dam.
         res-dam = txb.lonres.amt.
        end.

        v-nvng = v-nvng + bal-sum - res-sum.
        wrk.nvng = v-nvng.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7",no,txb.lon.crc,output wrk.ostatok).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"7",no,txb.lon.crc,output wrk.prosr_od).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"20,21",no,txb.lon.crc,output wrk.ind_od).

        wrk.ostatok_kzt = wrk.ostatok * d-rates[txb.lon.crc].
        wrk.prosr_od_kzt = wrk.prosr_od * d-rates[txb.lon.crc].
        wrk.ind_od_kzt = wrk.ind_od * d-rates[txb.lon.crc].

        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7,20,21",yes,txb.lon.crc,output bilance).
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2,9,22,23",yes,txb.lon.crc,output proc).
        if bilance + proc <= 0 then wrk.pogashen = yes.
        else wrk.pogashen = no.

        find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < d1 no-lock no-error.
        if avail txb.ln%his then wrk.prem = txb.ln%his.intrate.
        else wrk.prem = txb.lon.prem.

        if txb.lon.prem > 0 then wrk.prem_his = txb.lon.prem.
        else
        if txb.lon.prem1 > 0 then wrk.prem_his = txb.lon.prem1.
        else do:
            find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.intrate > 0 no-lock no-error.
            if avail txb.ln%his then wrk.prem_his = txb.ln%his.intrate.
            else do:
                find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
                if avail pkanketa then wrk.prem_his = pkanketa.rateq.
            end.
        end.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"2,9",no,txb.lon.crc,output wrk.nach_prc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"9",no,txb.lon.crc,output wrk.prosr_prc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"22,23",no,txb.lon.crc,output wrk.ind_prc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"4",no,txb.lon.crc,output wrk.prosr_prc_zabal).

        wrk.dayc_od = 0. wrk.dayc_prc = 0.
        if wrk.prosr_od > 0 or wrk.prosr_prc > 0 then
            run lndayspr_txb(txb.lon.lon,d1,no,output wrk.dayc_od,output wrk.dayc_prc).

        wrk.nach_prc_kzt = wrk.nach_prc * d-rates[txb.lon.crc].
        wrk.prosr_prc_kzt = wrk.prosr_prc * d-rates[txb.lon.crc].
        wrk.ind_prc_kzt = wrk.ind_prc * d-rates[txb.lon.crc].
        wrk.prosr_prc_zab_kzt = wrk.prosr_prc_zabal * d-rates[txb.lon.crc].

        find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat < d1 and txb.lnsci.flp > 0 and txb.lnsci.f0 = 0 no-lock no-error.
        if avail txb.lnsci then wrk.prcdt_last = txb.lnsci.idat.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"16",no,1,output wrk.penalty).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"5",no,1,output wrk.penalty_zabal).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"33",no,1,output wrk.penalty_otsr).

        wrk.uchastie = no.

        for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
            if txb.lonsec1.crc = 0 then next.
            case txb.lonsec1.lonsec:
                when 3 then wrk.sumdepcrd = wrk.sumdepcrd + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
                when 6 then wrk.sumgarant = wrk.sumgarant + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
                otherwise wrk.obessum_kzt = wrk.obessum_kzt + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
            end case.
            find first txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
            if avail txb.lonsec then do:
                if lookup(txb.lonsec.des1,wrk.obesdes) = 0 then do:
                    if wrk.obesdes <> '' then wrk.obesdes = wrk.obesdes + ','.
                    wrk.obesdes = wrk.obesdes + txb.lonsec.des1.
                end.
            end.
        end.

        wrk.obesall = wrk.obessum_kzt + wrk.sumgarant + wrk.sumdepcrd.

        wrk.neobesp = wrk.ostatok_kzt - wrk.obesall.
        if wrk.neobesp < 0 then wrk.neobesp = 0.

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then wrk.otrasl = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
        end.
        else wrk.otrasl = "НЕ ПРОСТАВЛЕНА".

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivisg' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivisg' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then wrk.otrasl1 = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
        end.
        else wrk.otrasl1 = "НЕ ПРОСТАВЛЕНА".

        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then
            wrk.finotrasl = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
        end.
        else wrk.finotrasl = "НЕ ПРОСТАВЛЕНА".


        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivisg' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivisg' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then
            wrk.finotrasl1 = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
        end.
        else wrk.finotrasl1 = "НЕ ПРОСТАВЛЕНА".

        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lneko' no-lock no-error.
        if avail txb.sub-cod then do:
            wrk.lneko = txb.sub-cod.ccode.
        end.
        else wrk.lneko = "НЕ ПРОСТАВЛЕНА".

        wrk.rezsum_afn = prov_afn.
        wrk.rezprc_afn = round(prov_afn / wrk.ostatok_kzt * 100, 2).

        wrk.rezsum_msfo = prov_od + prov_prc + prov_pen.
        wrk.rezsum_od = prov_od.
        wrk.rezsum_prc = prov_prc.
        wrk.rezsum_pen = prov_pen.

        if (wrk.ostatok_kzt + wrk.nach_prc_kzt + wrk.penalty) <> 0 then
        wrk.rezprc_msfo = round(((prov_od + prov_prc + prov_pen) / (wrk.ostatok_kzt + wrk.nach_prc_kzt + wrk.penalty)) * 100, 2).
        else wrk.rezprc_msfo = 0.


        if wrk.rezprc_msfo = 0 then wrk.statname =                                  "Стандартные".
        if wrk.rezprc_msfo > 0 and wrk.rezprc_msfo <= 5.01 then wrk.statname =      "Сомнительные 1 категории".
        if wrk.rezprc_msfo > 5.01 and wrk.rezprc_msfo <= 10.01 then wrk.statname =  "Сомнительные 2 категории".
        if wrk.rezprc_msfo > 10.01 and wrk.rezprc_msfo <= 20.01 then wrk.statname = "Сомнительные 3 категории".
        if wrk.rezprc_msfo > 20.01 and wrk.rezprc_msfo <= 25.01 then wrk.statname = "Сомнительные 4 категории".
        if wrk.rezprc_msfo > 25.01 and wrk.rezprc_msfo <= 50.01 then wrk.statname = "Сомнительные 5 категории".
        if wrk.rezprc_msfo > 50.01 then wrk.statname =                              "Безнадежные".

        /***** Объект кредитования *****/
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lntgt' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then do:
                wrk.tgt = trim(txb.codfr.name[1]).
                if txb.codfr.code = "15" then wrk.tgt_code = "11".
                if txb.codfr.code = "13" or txb.codfr.code = "14" then wrk.tgt_code = "13".
                if txb.codfr.code = "10" or
                   txb.codfr.code = "18" or
                   txb.codfr.code = "11" or
                   txb.codfr.code = "16" or
                   txb.codfr.code = "19" or
                   txb.codfr.code = "20" or
                   txb.codfr.code = "msc" then wrk.tgt_code = "15".
            end.
        end.

        /* Семизначный счет ГК */

        if txb.lon.crc = 1 then wrk.val = "1".
        else if txb.lon.crc = 2 or txb.lon.crc = 3 or txb.lon.crc = 6 then wrk.val = "2".
        else if txb.lon.crc = 4 then wrk.val = "3".
        wrk.rezid = string (txb.cif.geo).
        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'secek' and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
        if avail txb.sub-cod then wrk.scode = string (txb.sub-cod.ccode).
        wrk.schet_gk = substring(string(wrk.gl),1,4) + substring (wrk.rezid, 3, 1) + string (wrk.scode) + string (wrk.val).

        /* Лица, связанные с банком особыми отношениями */
        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
         if avail txb.cif then do:
            if txb.cif.jss <> '' then do:
                    find first prisv where prisv.rnn = txb.cif.jss and prisv.rnn <> '' no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                         if avail txb.codfr then wrk.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrk.rel = 'Нет такого справочника'.
                    end.

                    else do:
                    if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                    find first prisv where trim(prisv.name) = nm no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                         if avail txb.codfr then wrk.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrk.rel = 'Нет такого справочника'.
                    end.
                    else wrk.rel = "Не связанное лицо".
                    end.
                end.
                if txb.cif.jss = '' then do:
                    if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                    find first prisv where trim(prisv.name) = nm no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                         if avail txb.codfr then wrk.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrk.rel = 'Нет такого справочника'.
                    end.
                    else wrk.rel = "Не связанное лицо".
                end.
         end.

        /* Отраслевая направленность займа */
        find first txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = "lntgt_1" no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then wrk.napr = trim(txb.codfr.name[1]).
        end.

    end. /* for each txb.lon */
end. /* do i = 1 to */

run av_mm2_pril(d1).

message "". pause 0.