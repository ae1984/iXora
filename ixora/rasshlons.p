/* rasshlons.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Расшифровка кредитного портфеля для аудита (один филиал)
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
 * BASES
        BANK COMM TXB
 * AUTHOR
        21.11.2012 Sayat (id01143)
 * CHANGES
        24/05/2013 Sayat(id01143) - перекомпиляция в связи с изменением repFS.i по ТЗ 1303 от 01/03/2012
        25.09.2013 damir - Внедрено Т.З. № 1869. Исправил Sayat(id01143).
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
def var prov_penafn as deci no-undo.
def var prov_afn41 as deci no-undo.
def var prov_zo as deci no-undo.
def var city as char no-undo.
def var tempdt  as date no-undo.
def var tempost as deci no-undo.
def var v-bal19 as deci no-undo.
def var v-bal19all as deci no-undo.
def var ll as int.
def var k as int.

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

{repFS.i}


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


def temp-table dif  /* для расчета расхождений  */
      field gl like txb.gl.gl
      field crc like txb.crc.crc
      field sum_gl as deci
      field sum_gl_kzt as deci
      field sum_lon as deci
      index gl_idx is primary gl
      index glcrc_idx is unique gl crc.

def var sum_od as deci.
def var sum_prosr as deci.
def var sum_rez as deci.
def var sum_disc as deci.


find first txb.cmp no-lock no-error.
if avail txb.cmp then city = entry(2,txb.cmp.addr[1]).

def var s-ourbank as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

/*
hide message no-pause.
message " Обрабатывается база " + city + " ".
*/

empty temp-table dif.

for each txb.gl where txb.gl.subled = 'lon' no-lock:
    for each txb.crc no-lock:
        create dif.
        dif.gl = txb.gl.gl.
        dif.crc = txb.crc.crc.
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt < d1 no-lock no-error.
        if avail txb.glday then do:
          dif.sum_gl = txb.glday.dam - txb.glday.cam.
          dif.sum_gl_kzt = dif.sum_gl * d-rates[dif.crc].
        end.
    end.
end.

find first txb.gl where txb.gl.gl = 143422 no-lock no-error.
if avail txb.gl then do:
    for each txb.crc no-lock:
        create dif.
        dif.gl = txb.gl.gl.
        dif.crc = txb.crc.crc.
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt < d1 no-lock no-error.
        if avail txb.glday then do:
            dif.sum_gl = txb.glday.dam - txb.glday.cam.
            dif.sum_gl_kzt = dif.sum_gl * d-rates[dif.crc].
            dif.sum_lon = 0.
        end.
    end.
end.

for each txb.lon no-lock:
    for each txb.trxbal where txb.trxbal.subled = "lon" and txb.trxbal.acc = txb.lon.lon no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < d1 no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.lon.gl and txb.trxlevgl.subled = 'lon' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first dif where dif.gl = txb.trxlevgl.glr and dif.crc = txb.histrxbal.crc no-error.
            dif.sum_lon = dif.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end.
sum_od = 0. sum_prosr = 0. sum_rez = 0. sum_disc = 0.
for each dif where dif.gl = 141720 /*and dif.crc = 1*/:
    sum_od = sum_od + dif.sum_gl_kzt - dif.sum_lon * d-rates[dif.crc].
end.
for each dif where dif.gl = 142420 /*and dif.crc = 1*/:
    sum_prosr = sum_prosr + dif.sum_gl_kzt - dif.sum_lon * d-rates[dif.crc].
end.
for each dif where dif.gl = 142820 /*and dif.crc = 1*/:
    sum_rez = sum_rez + dif.sum_gl_kzt - dif.sum_lon * d-rates[dif.crc].
end.

for each dif where dif.gl = 143422 /*and dif.crc = 1*/:
    sum_disc = sum_disc + dif.sum_gl - dif.sum_lon * d-rates[dif.crc].
end.

find first txb.codfr where txb.codfr.codfr = "ecdivis" and txb.codfr.code = "0" no-lock no-error.

if absolute(sum_od) + absolute(sum_prosr) + absolute(sum_rez) + absolute(sum_disc) <> 0 then do:
    create wrkFS.
    assign  wrkFS.bank = txb.cmp.name
        wrkFS.gl = 141720.
        wrkFS.name = "MKO".
        wrkFS.schet_gk = "1417191".
        wrkFS.grp = 92.
        wrkFS.bankn = city.
        wrkFS.crc = 1.
        wrkFS.rdt = ?.
        wrkFS.isdt = date(01 , 01 , 2008).
        wrkFS.duedt = ?.
        wrkFS.dprolong = ?.
        wrkFS.ostatok = sum_od + sum_prosr.
        wrkFS.prosr_od = sum_prosr.
        wrkFS.dayc_od = 30.
        wrkFS.ostatok_kzt = wrkFS.ostatok.
        wrkFS.prosr_od_kzt = wrkFS.prosr_od.
        wrkFS.obesdes = "No".

    find first txb.codfr where txb.codfr.codfr = "ecdivis" and txb.codfr.code = "0" no-lock no-error.
        wrkFS.otrasl = txb.codfr.code + " - " + txb.codfr.name[1]. /*"0 - Физические лица"*/
        wrkFS.finotrasl = txb.codfr.code + " - " + txb.codfr.name[1]. /*"0 - Физические лица"*/
        wrkFS.rezsum_afn = - sum_rez.
        wrkFS.rezsum_od = wrkFS.ostatok.
        wrkFS.rezsum_prc = 0.
        wrkFS.rezsum_pen = 0.
        wrkFS.rezsum_msfo = wrkFS.rezsum_od.

    find first txb.codfr where txb.codfr.codfr = "lntgt" and txb.codfr.code = "15" no-lock no-error.
        wrkFS.tgt = trim(txb.codfr.name[1]). /*"Гражданам на потребительские цели".*/
        wrkFS.tgtc = txb.codfr.code.
        wrkFS.zam_dk = sum_disc. /*Дисконт по займам*/
        wrkFS.OKEDcif = "0".
        wrkFS.OKEDlon = "0".
        wrkFS.rezsum_afn41 = wrkFS.rezsum_afn.
end.
do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7,20,21",no,txb.lon.crc,output bilance).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"2,9,22,23,49,50",no,txb.lon.crc,output proc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"12,52",no,1,output pol_proc).
        pol_proc = - pol_proc.
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"6",no,txb.lon.crc,output prov_od).
        prov_od = - prov_od * d-rates[txb.lon.crc].
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"36",no,txb.lon.crc,output prov_prc).
        prov_prc = - prov_prc * d-rates[txb.lon.crc].
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"37",no,1,output prov_pen).
        prov_pen =  - prov_pen.
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"6,36",no,txb.lon.crc,output prov_afn).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"37,38,39,40",no,1,output prov_penafn).
        prov_afn =  - prov_afn * d-rates[txb.lon.crc] - prov_penafn.
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"41",no,txb.lon.crc,output prov_afn41).
        prov_afn41 =  - prov_afn41 * d-rates[txb.lon.crc].
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

        /*
        if txb.lon.crc <> 1 then do:
            prov = round(prov * d-rates[txb.lon.crc],2).
            prov_zo = round(prov_zo * d-rates[txb.lon.crc],2).
        end.
        */

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

        create wrkFS.
        assign wrkFS.bank = txb.cmp.name
               wrkFS.gl = txb.lon.gl.
               wrkFS.pooln = poolDes.

        find last b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
        if avail b-lon then do:
          wrkFS.nsumkr = b-lon.opnamt.
          wrkFS.nsumkr_kzt = b-lon.opnamt.
         if b-lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = b-lon.crc and txb.crchis.rdt <= d1 no-lock no-error.
            if avail txb.crchis then wrkFS.nsumkr_kzt = wrkFS.nsumkr_kzt * txb.crchis.rate[1].
             else message " Ошибка определения курса! cif=" + b-lon.cif + " lon=" + b-lon.lon + " crc=" + string(b-lon.crc) view-as alert-box error.
         end.
        end.


        find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
        if avail pkanketa then do:
            find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "kdsts" no-lock no-error.
            if avail pkanketh then do:
                find first txb.codfr where txb.codfr.codfr = 'kdsts' and txb.codfr.code = pkanketh.value1 no-lock no-error.
                if avail txb.codfr then wrkFS.kdstsdes = pkanketh.value1 + ' ' + txb.codfr.name[1] + ' ' + pkanketh.value2.
            end.
        end.

        find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        if avail txb.cif then do:
            wrkFS.name = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
            if available txb.sub-cod then do:
                if txb.sub-cod.ccode <> "msc" then do:
                    find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                    if avail txb.codfr then do:
                        ll = index(txb.codfr.name[1],"(").
                        if ll > 0 then wrkFS.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                        else wrkFS.clnsegm = trim(txb.codfr.name[1]).
                    end.
                end.
            end.
        end.
        else wrkFS.name = "НЕ НАЙДЕН".
        assign wrkFS.cif = txb.lon.cif
               wrkFS.lon = txb.lon.lon
               wrkFS.grp = txb.lon.grp
               wrkFS.bankn = city
               wrkFS.crc = txb.lon.crc
               wrkFS.rdt = txb.lon.rdt
               wrkFS.duedt = txb.lon.duedt
               wrkFS.obesall_lev19 = v-bal19all
               wrkFS.pol_prc_kzt = pol_proc.
               wrkFS.amr_dk = v_amr_dk.
               wrkFS.zam_dk = v_zam_dk.
               wrkFS.bal34 = v_bal34.
               wrkFS.clmain = txb.lon.clmain.
               wrkFS.ciftype = txb.cif.type.


        find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
        if avail txb.lnscg then wrkFS.isdt = txb.lnscg.stdat.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"11",no,1,output wrkFS.bal11).
        wrkFS.bal11 = - wrkFS.bal11.

        find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.kod = 'finsost1' and kdlonkl.rdt < d1 no-lock no-error.
        if avail kdlonkl then wrkFS.valdesc = kdlonkl.val1 + " - " + kdlonkl.valdesc.

        find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.kod = 'obesp1' and kdlonkl.rdt < d1 no-lock no-error.
        if avail kdlonkl then wrkFS.valdesc_ob = kdlonkl.val1 + " - " + kdlonkl.valdesc.

        /* Рейтинг*/
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnrate' no-lock no-error.
        if avail txb.sub-cod then
            find first txb.codific where txb.codific.codfr = txb.sub-cod.d-cod no-lock no-error.
        if avail txb.codific then
            find first txb.codfr where txb.codfr.codfr = txb.codific.codfr and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
        if avail txb.codfr then do:
            wrkFS.kodd = txb.codfr.code.
            wrkFS.rate = txb.codfr.name[1].
        end.

        /* Продукт*/
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnprod' no-lock no-error.
        if avail txb.sub-cod then
            find first txb.codific where txb.codific.codfr = txb.sub-cod.d-cod no-lock no-error.
        if avail txb.codific then
            find first txb.codfr where txb.codfr.codfr = txb.codific.codfr and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
        if avail txb.codfr then do:
            wrkFS.lnprod = txb.codfr.name[1].
        end.

        for each txb.jl where txb.jl.acc = txb.lon.aaa and txb.jl.jdt >= txb.lon.rdt and txb.jl.lev = 1 and txb.jl.dc = 'C' no-lock:
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 and b-jl.sub <> 'LON' no-lock no-error.
            if avail b-jl then do:
                find first txb.aaa where txb.aaa.aaa = b-jl.acc no-lock no-error.
                if (avail txb.aaa and txb.aaa.lgr <> '236' and txb.aaa.lgr <> '237') or not avail txb.aaa then do:
                    wrkFS.dtlpay = txb.jl.jdt.
                    wrkFS.lpaysum = b-jl.dam.
                end.
            end.
        end.

        find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
        wrkFS.num_dog = txb.loncon.lcnt.

        if txb.lon.ddt[5] <> ? then do:
            wrkFS.dprolong = txb.lon.ddt[5].
            if txb.lon.ddt[5] >= d1 then wrkFS.prolong = 1.
        end.
        if txb.lon.cdt[5] <> ? then do:
            wrkFS.dprolong = txb.lon.cdt[5].
            if txb.lon.cdt[5] >= d1 then wrkFS.prolong = 2.
        end.
        if txb.lon.duedt >= d1 then wrkFS.prolong = 0.

        wrkFS.opnamt = txb.lon.opnamt.
        wrkFS.opnamt_kzt = txb.lon.opnamt * d-rates[txb.lon.crc].

        /*Сумма погашенного ОД */
        for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.stdat < d1 no-lock:
          wrkFS.pogosh = wrkFS.pogosh + txb.lnsch.paid.
        end.

        /*Получ. % за весь период (в тенге)*/
        for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp > 0 and txb.lnsci.idat < d1 no-lock:
          wrkFS.pol_prc_kzt_all = wrkFS.pol_prc_kzt_all + txb.lnsci.paid-iv.
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
        wrkFS.dpnv = v-dpnv.

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
        wrkFS.nvng = v-nvng.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7",no,txb.lon.crc,output wrkFS.ostatok).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"7",no,txb.lon.crc,output wrkFS.prosr_od).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"20,21",no,txb.lon.crc,output wrkFS.ind_od).

        wrkFS.ostatok_kzt = wrkFS.ostatok * d-rates[txb.lon.crc].
        wrkFS.prosr_od_kzt = wrkFS.prosr_od * d-rates[txb.lon.crc].
        wrkFS.ind_od_kzt = wrkFS.ind_od * d-rates[txb.lon.crc].

        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7,20,21",yes,txb.lon.crc,output bilance).
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2,9,22,23",yes,txb.lon.crc,output proc).
        if bilance + proc <= 0 then wrkFS.pogashen = yes.
        else wrkFS.pogashen = no.

        find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < d1 no-lock no-error.
        if avail txb.ln%his then wrkFS.prem = txb.ln%his.intrate.
        else wrkFS.prem = txb.lon.prem.

        if txb.lon.prem > 0 then wrkFS.prem_his = txb.lon.prem.
        else
        if txb.lon.prem1 > 0 then wrkFS.prem_his = txb.lon.prem1.
        else do:
            find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.intrate > 0 no-lock no-error.
            if avail txb.ln%his then wrkFS.prem_his = txb.ln%his.intrate.
            else do:
                find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
                if avail pkanketa then wrkFS.prem_his = pkanketa.rateq.
            end.
        end.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"2,9,49",no,txb.lon.crc,output wrkFS.nach_prc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"9,50",no,txb.lon.crc,output wrkFS.prosr_prc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"22,23",no,txb.lon.crc,output wrkFS.ind_prc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"4,53",no,txb.lon.crc,output wrkFS.prosr_prc_zabal).

        wrkFS.dayc_od = 0. wrkFS.dayc_prc = 0.
        if wrkFS.prosr_od > 0 or wrkFS.prosr_prc > 0 then
            run lndayspr_txb(txb.lon.lon,d1,no,output wrkFS.dayc_od,output wrkFS.dayc_prc).

        wrkFS.nach_prc_kzt = wrkFS.nach_prc * d-rates[txb.lon.crc].
        wrkFS.prosr_prc_kzt = wrkFS.prosr_prc * d-rates[txb.lon.crc].
        wrkFS.ind_prc_kzt = wrkFS.ind_prc * d-rates[txb.lon.crc].
        wrkFS.prosr_prc_zab_kzt = wrkFS.prosr_prc_zabal * d-rates[txb.lon.crc].

        find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat < d1 and txb.lnsci.flp > 0 and txb.lnsci.f0 = 0 no-lock no-error.
        if avail txb.lnsci then wrkFS.prcdt_last = txb.lnsci.idat.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"16",no,1,output wrkFS.penalty).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"5",no,1,output wrkFS.penalty_zabal).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"33",no,1,output wrkFS.penalty_otsr).

        wrkFS.uchastie = no.
        k = 0.
        repeat while k < 6:
            k = k + 1.
            wrkFS.obessum_kzt[k] = 0.
        end.
        for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
            if txb.lonsec1.crc = 0 then next.
            /*
            case txb.lonsec1.lonsec:
                when 3 then wrkFS.sumdepcrd = wrkFS.sumdepcrd + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
                when 6 then wrkFS.sumgarant = wrkFS.sumgarant + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
                otherwise wrkFS.obessum_kzt = wrkFS.obessum_kzt + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
            end case.
            */
            if txb.lonsec1.secamt <> 0 then wrkFS.obessum_kzt[integer(txb.lonsec1.lonsec)] = wrkFS.obessum_kzt[integer(txb.lonsec1.lonsec)] + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
            find first txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
            if avail txb.lonsec then do:
                if lookup(txb.lonsec.des1,wrkFS.obesdes) = 0 then do:
                    if wrkFS.obesdes <> '' then wrkFS.obesdes = wrkFS.obesdes + ','.
                    wrkFS.obesdes = wrkFS.obesdes + txb.lonsec.des1.
                end.
                if lookup(string(txb.lonsec.lonsec),wrkFS.obescod) = 0 then do:
                    if wrkFS.obescod <> '' then wrkFS.obescod = wrkFS.obescod + ','.
                    wrkFS.obescod = wrkFS.obescod + string(txb.lonsec.lonsec).
                end.
            end.

        end.

        wrkFS.obesall = wrkFS.obessum_kzt[1] + wrkFS.obessum_kzt[2] + wrkFS.obessum_kzt[3] + wrkFS.obessum_kzt[4] + wrkFS.obessum_kzt[5] + wrkFS.obessum_kzt[6]. /*wrkFS.obessum_kzt + wrkFS.sumgarant + wrkFS.sumdepcrd.*/

        wrkFS.neobesp = wrkFS.ostatok_kzt - wrkFS.obesall.
        if wrkFS.neobesp < 0 then wrkFS.neobesp = 0.

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            wrkFS.otrasl = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
            wrkFS.OKEDcif = txb.sub-cod.ccode.
        end.
        else do:
            wrkFS.otrasl = "НЕ ПРОСТАВЛЕНА".
            wrkFS.OKEDcif = "НЕ ПРОСТАВЛЕНА".
        end.

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivisg' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivisg' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            wrkFS.otrasl1 = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
        end.
        else wrkFS.otrasl1 = "НЕ ПРОСТАВЛЕНА".

        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then
            wrkFS.finotrasl = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
            wrkFS.OKEDlon = txb.sub-cod.ccode.
        end.
        else do:
            wrkFS.finotrasl = "НЕ ПРОСТАВЛЕНА".
            wrkFS.OKEDlon = "НЕ ПРОСТАВЛЕНА".
        end.


        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivisg' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivisg' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then
            wrkFS.finotrasl1 = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
        end.
        else wrkFS.finotrasl1 = "НЕ ПРОСТАВЛЕНА".

        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lneko' no-lock no-error.
        if avail txb.sub-cod then do:
            wrkFS.lneko = txb.sub-cod.ccode.
        end.
        else wrkFS.lneko = "НЕ ПРОСТАВЛЕНА".

        /*
        find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < d1 no-lock no-error.
        if avail txb.lonhar then do:
            find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
            if avail txb.lonstat then wrkFS.rezprc = txb.lonstat.prc.
        end.
        */
        wrkFS.rezsum_afn = prov_afn.
        wrkFS.rezsum_afn41 = prov_afn41.
        wrkFS.rezprc_afn = round(prov_afn / wrkFS.ostatok_kzt * 100,2).

        wrkFS.rezsum_msfo = prov_od + prov_prc + prov_pen.
        wrkFS.rezsum_od = prov_od.
        wrkFS.rezsum_prc = prov_prc.
        wrkFS.rezsum_pen = prov_pen.
        /*
        if txb.lon.rdt < 01/01/2010 then do:
            wrkFS.rezsum_zo = prov_zo.
            run lonbalcrc_txb('lon',txb.lon.lon,01/01/2010,"1,7",no,txb.lon.crc,output bilance_zo).
            if bilance_zo > 0 then do:
                if txb.lon.crc <> 1 then bilance_zo = round(bilance_zo * d-rates[txb.lon.crc],2).
                wrkFS.rezprc_zo = round(prov_zo / bilance_zo * 100,0).
            end.
        end.
        */

        /***** Объект кредитования *****/
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lntgt' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then do: wrkFS.tgt = trim(txb.codfr.name[1]). wrkFS.tgtc = txb.codfr.code. end.
        end.

        /* Семизначный счет ГК */

        if txb.lon.crc = 1 then wrkFS.val = "1".
        else if txb.lon.crc = 2 or txb.lon.crc = 3 or txb.lon.crc = 6 then wrkFS.val = "2".
        else if txb.lon.crc = 4 then wrkFS.val = "3".
        wrkFS.rezid = string (txb.cif.geo).
        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'secek' and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
        if avail txb.sub-cod then wrkFS.scode = string (txb.sub-cod.ccode).
        wrkFS.schet_gk = substring(string(wrkFS.gl),1,4) + substring (wrkFS.rezid, 3, 1) + string (wrkFS.scode) + string (wrkFS.val).

        /* Лица, связанные с банком особыми отношениями */
        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
         if avail txb.cif then do:
            if txb.cif.jss <> '' then do:
                    find first prisv where prisv.rnn = txb.cif.jss and prisv.rnn <> '' no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                         if avail txb.codfr then wrkFS.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrkFS.rel = 'Нет такого справочника'.
                    end.

                    else do:
                    if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                    find first prisv where trim(prisv.name) = nm no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                         if avail txb.codfr then wrkFS.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrkFS.rel = 'Нет такого справочника'.
                    end.
                    else wrkFS.rel = "Не связанное лицо".
                    end.
                end.
                if txb.cif.jss = '' then do:
                    if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                    find first prisv where trim(prisv.name) = nm no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                         if avail txb.codfr then wrkFS.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrkFS.rel = 'Нет такого справочника'.
                    end.
                    else wrkFS.rel = "Не связанное лицо".
                end.
         end.

        /* Отраслевая направленность займа */
        find first txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = "lntgt_1" no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then wrkFS.napr = trim(txb.codfr.name[1]).
        end.



    end. /* for each txb.lon */

end. /* do i = 1 to */

