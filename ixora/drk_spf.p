/* drk_spf.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-cods.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-7-3-14
 * AUTHOR
       18/06/2013 Luiza ТЗ 986
 * BASES
	BANK TXB
 * CHANGES

*/

def shared temp-table lnpr
  field pertype   as   int
  field fname     as   char
  field name      as   char
  field lon       as   char
  field cname     as   char
  field dog       as   char
  field crc       as   int
  field intrate   as   decimal
  field eintrate  as   decimal
  field rdt       as   date
  field duedt     as   date
  field klasif    as   char
  field vsum      as   decimal
  field nsum      as   decimal
  field stdat     as   date
  field paid      as   decimal
  field rpaid     as   decimal
  field dtype     as   decimal
  field provod    as   decimal
  field debtod    as   decimal
  field totalp    as   decimal
  field cur       as   decimal
  index ind is primary fname lon pertype stdat .

def shared var r-dt as date no-undo.
def shared var b-dt as date no-undo.
def shared var e-dt as date no-undo.
def shared var v-today as date no-undo.
def shared var v-pertype as int no-undo.
def shared var v-reptype as int no-undo.
def shared var v-hol as date no-undo.
def shared var g-today as date .

def var i as integer no-undo.
def var v-grp as integer no-undo.
def var lst_grp as char no-undo init ''.

def var j as int.
def var v-name as char.
def var v-rate as decimal.
def var g-rate as decimal.

def var v-cname as char.
def var v-dog as char.
def var v-intrate as decimal.

def var t as integer no-undo.
def var t-grp as integer no-undo.
def var t-lst_grp as char no-undo init ''.

def var v-fname as char.
def var v-apz as char.
def var prov_od as deci no-undo.
def var prov_prc as deci no-undo.
def var debt_od as deci no-undo.
def var debt_prc as deci no-undo.
def var prov_pen as deci no-undo.
def var v-bal as deci no-undo.
def var v-bal1 as deci no-undo.
def var v-bal2 as deci no-undo.
def var ldt    as date no-undo.

def var v-bank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then return.
v-bank = txb.sysc.chval.


lst_grp = ''.
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
      if txb.longrp.des matches '*МСБ*' or txb.longrp.longrp = 70 or txb.longrp.longrp = 80 or txb.longrp.longrp = 11 or txb.longrp.longrp = 21 then do:
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
  when 6 then do:
    for each txb.longrp no-lock:
      if substr(string(txb.longrp.stn),1,1) = '1' and (txb.longrp.longrp = 90) and (txb.longrp.longrp = 92) then do:
        if lst_grp <> '' then lst_grp = lst_grp + ','.
        lst_grp = lst_grp + string(txb.longrp.longrp).
      end.
    end.
  end.
  when 7 then do:
    for each txb.longrp no-lock:
      if substr(string(txb.longrp.stn),1,1) = '2' and  (txb.longrp.des matches '*МСБ*' or txb.longrp.longrp = 70 or txb.longrp.longrp = 80 or txb.longrp.longrp = 11 or txb.longrp.longrp = 21) then do:
        if lst_grp <> '' then lst_grp = lst_grp + ','.
        lst_grp = lst_grp + string(txb.longrp.longrp).
      end.
    end.
  end.
  otherwise lst_grp = ''.
end case.

v-fname = ''.
find first txb.cmp no-lock no-error.
if avail txb.cmp then v-fname = txb.cmp.name.


t-lst_grp = string(v-pertype).
if v-pertype = 8 then t-lst_grp = '1,2,3,4,5,6,7'.

do t = 1 to num-entries(t-lst_grp):
    t-grp = integer(entry(t,t-lst_grp)).
    case t-grp:
        when 1 then do:
          b-dt = v-hol.
          e-dt = r-dt + 7.
          v-name = 'за 7 дн.'.
        end. when 2 then do:
          b-dt = r-dt + 8.
          e-dt = r-dt + 31.
          v-name = 'от 7 дн. до 30 дн.'.
        end. when 3 then do:
          b-dt = r-dt + 32.
          e-dt = r-dt + 92.
          v-name = 'от 31 дн. до 92 дн.'.
        end. when 4 then do:
          b-dt = r-dt + 93.
          e-dt = r-dt + 180.
          v-name = 'от 92 дн. до 180 дн.'.
        end. when 5 then do:
          b-dt = r-dt + 181.
          e-dt = r-dt + 365.
          v-name = 'от 180 дн. до 365 дн.'.
        end. when 6 then do:
          b-dt = r-dt + 366.
          e-dt = r-dt + 1095.
          v-name = 'от 365 дн. до 1095 дн.'.
        end.
        when 7 then do:
          b-dt = r-dt + 1096.
          e-dt = 01/01/2050.
          v-name = 'свыше 1095 дн.'.
        end.
    end case.
    do i = 1 to num-entries(lst_grp):
        v-grp = integer(entry(i,lst_grp)).
         /* для основного долга */
       for each txb.lon where txb.lon.grp = v-grp no-lock:
            if (txb.lon.rdt > r-dt) then next.
            run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"1",no,txb.lon.crc,output v-bal1). /*основной долг остаток*/
            run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"6",no,txb.lon.crc,output prov_od). /* провиз ОД*/
            prov_od = - prov_od.
            if v-bal1 = 0 and prov_od  = 0 then next.
           /* run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"2",no,txb.lon.crc,output v-bal2).*/ /*вознагражд остаток*/

             /*Наименование заемщика*/
            find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
            if avail txb.cif then v-cname = txb.cif.name.
            v-dog = "".
            find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
            if available txb.loncon then v-dog = txb.loncon.lcnt.

            v-intrate = 0.
            find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and ln%his.stdat <= r-dt and txb.ln%his.intrate > 0 use-index ln% no-lock no-error.
            if avail txb.ln%his then v-intrate = txb.ln%his.intrate.

            v-apz = "".
            find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= r-dt use-index lonhar-idx1 no-lock no-error.
            if avail txb.lonhar then find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
            if avail txb.lonstat then do:
               v-apz = txb.lonstat.apz.
            end.
            /*find last kdlonkl where kdlonkl.bank = v-bank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon
            and kdlonkl.kod = 'finsost1' use-index bclrdt no-lock no-error.
            if available kdlonkl then do:
                if trim(kdlonkl.valdesc) <> "" then v-apz = trim(kdlonkl.valdesc).
                else do:
                    find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = kdlonkl.val1 no-lock no-error.
                    if avail bookcod then  v-apz = bookcod.name.
                end.
            end.*/
            /* курс валюты */
            v-rate = 0.
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < r-dt no-lock no-error.
            if avail txb.crchis then v-rate = txb.crchis.rate[1].

            run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"7",no,txb.lon.crc,output debt_od). /* просрочен ОД*/

            if v-bal1 = 0 and debt_od = 0 and prov_od <> 0 then do: /* у кого сумма ОД = 0 и просрочен ОД = 0, но есть провизии */
                find first lnpr where lnpr.fname = v-fname and lnpr.lon = txb.lon.lon and lnpr.dtype = 1 no-lock no-error.
                if not available lnpr then do:
                    create lnpr.
                     lnpr.pertype = t-grp.
                     lnpr.fname = v-fname.
                     lnpr.name = v-name.
                     lnpr.lon = txb.lon.lon.
                     lnpr.cname = v-cname.
                     lnpr.dog   = v-dog.
                     lnpr.crc = txb.lon.crc.

                     lnpr.klasif = v-apz.

                     lnpr.intrate = v-intrate.
                     lnpr.eintrate = 0.
                     lnpr.rdt = txb.lon.rdt.
                     lnpr.duedt = txb.lon.duedt.
                     lnpr.dtype = 1.
                     lnpr.vsum = prov_od. /* провизия в валюте */
                     lnpr.nsum = prov_od * v-rate. /* провизия в тенге */
                end.
            end.
            if v-bal1 <> 0 then do:
                v-bal = 0.
                for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0  and txb.lnsch.stdat >= b-dt and txb.lnsch.stdat <= e-dt no-lock break by txb.lnsch.stdat:
                   create lnpr.
                     lnpr.pertype = t-grp.
                     lnpr.fname = v-fname.
                     lnpr.name = v-name.
                     lnpr.lon = txb.lon.lon.
                     lnpr.cname = v-cname.
                     lnpr.dog   = v-dog.
                     lnpr.crc = txb.lon.crc.

                     lnpr.klasif = v-apz.

                     lnpr.intrate = v-intrate.
                     lnpr.eintrate = 0.
                     lnpr.rdt = txb.lon.rdt.
                     lnpr.duedt = txb.lon.duedt.
                     lnpr.dtype = 1.


                    /*find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= txb.lnsch.stdat no-lock no-error.*/

                    lnpr.stdat = txb.lnsch.stdat. /*Дата погашения основного долга*/
                    lnpr.paid = txb.lnsch.stval. /*Сумма погашения  основного долга*/
                    lnpr.rpaid = txb.lnsch.stval * v-rate. /*Эквивалент в тенге */
                    lnpr.vsum = (txb.lnsch.stval * prov_od) / (v-bal1 + debt_od). /* провизия в валюте */
                    lnpr.nsum = ((txb.lnsch.stval * prov_od) / (v-bal1 + debt_od)) * v-rate. /* провизия в тенге */
                    lnpr.provod  = prov_od.
                    lnpr.debtod  = debt_od.
                    /* lnpr.totalp  = заполним при выводе на печать */
                    lnpr.cur  = v-rate.
                end.
            end.
       end. /* for each txb.lon */

         /* для вознаграждения */
        for each txb.lon where txb.lon.grp = v-grp no-lock:
            if (txb.lon.rdt > r-dt) then next.
            run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"2,49",no,txb.lon.crc,output v-bal2). /*вознагражд остаток*/
            run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"36",no,txb.lon.crc,output prov_prc). /* провизии вознагражд */
            prov_prc = - prov_prc.
            if v-bal2 = 0 and prov_prc = 0 then next.

             /*Наименование заемщика*/
            find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
            if avail txb.cif then v-cname = txb.cif.name.
            v-dog = "".
            find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
            if available txb.loncon then v-dog = txb.loncon.lcnt.

            v-intrate = 0.
            find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and ln%his.stdat <= r-dt and txb.ln%his.intrate > 0 use-index ln% no-lock no-error.
            if avail txb.ln%his then v-intrate = txb.ln%his.intrate.

            v-apz = "".
            find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= r-dt use-index lonhar-idx1 no-lock no-error.
            if avail txb.lonhar then find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
            if avail txb.lonstat then do:
               v-apz = txb.lonstat.apz.
            end.
            /*find last kdlonkl where kdlonkl.bank = v-bank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon
            and kdlonkl.kod = 'finsost1' use-index bclrdt no-lock no-error.
            if available kdlonkl then do:
                if trim(kdlonkl.valdesc) <> "" then v-apz = trim(kdlonkl.valdesc).
                else do:
                    find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = kdlonkl.val1 no-lock no-error.
                    if avail bookcod then  v-apz = bookcod.name.
                end.
            end.*/

            /* курс валюты */
            v-rate = 0.
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < r-dt no-lock no-error.
            if avail txb.crchis then v-rate = txb.crchis.rate[1].

            run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"9,50",no,txb.lon.crc,output debt_prc). /* просрочен вознагражд*/
            debt_prc = debt_prc.
            /*run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"37",no,1,output prov_pen).
            prov_pen =  - prov_pen.*/
            if v-bal2 = 0 and debt_prc = 0 and prov_prc <> 0 then do: /* у кого сумма вознагр = 0 и просрочен вознагражд = 0, но есть провизии */
                find first lnpr where lnpr.fname = v-fname and lnpr.lon = txb.lon.lon and lnpr.dtype = 2 no-lock no-error.
                if not available lnpr then do:
                     create lnpr.
                     lnpr.pertype = t-grp.
                     lnpr.fname = v-fname.
                     lnpr.name = v-name.
                     lnpr.lon = txb.lon.lon.
                     lnpr.cname = v-cname.
                     lnpr.dog   = v-dog.
                     lnpr.crc = txb.lon.crc.

                     lnpr.klasif = v-apz.
                     lnpr.intrate = v-intrate.
                     lnpr.eintrate = 0.
                     lnpr.rdt = txb.lon.rdt.
                     lnpr.duedt = txb.lon.duedt.
                     lnpr.dtype = 2.
                     lnpr.vsum = prov_prc. /* провизия в валюте */
                     lnpr.nsum = prov_prc * v-rate. /* провизия в тенге */
                end.
            end.
            if v-bal2 <> 0 then do:
                find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0  and txb.lnsci.idat >= b-dt and txb.lnsci.idat <= e-dt no-lock no-error.
                if available  txb.lnsci then do:
                    find first lnpr where lnpr.fname = v-fname and lnpr.lon = txb.lon.lon and lnpr.dtype = 2 no-lock no-error.
                    if not available lnpr then do:
                         create lnpr.
                         lnpr.pertype = t-grp.
                         lnpr.fname = v-fname.
                         lnpr.name = v-name.
                         lnpr.lon = txb.lon.lon.
                         lnpr.cname = v-cname.
                         lnpr.dog   = v-dog.
                         lnpr.crc = txb.lon.crc.

                         lnpr.klasif = v-apz.
                         lnpr.intrate = v-intrate.
                         lnpr.eintrate = 0.
                         lnpr.rdt = txb.lon.rdt.
                         lnpr.duedt = txb.lon.duedt.
                         lnpr.dtype = 2.

                        lnpr.stdat = txb.lnsci.idat.
                        lnpr.paid = v-bal2.
                        lnpr.rpaid = v-bal2 * v-rate.
                        lnpr.vsum = (v-bal2 * prov_prc) / (v-bal2 + debt_prc). /* провизия в валюте */
                        lnpr.nsum = ((v-bal2 * prov_prc) / (v-bal2 + debt_prc)) * v-rate. /* провизия в тенге */
                    end.
                end.
            end.
        end. /* for each txb.lon */
    end. /* do i = 1 to */
end. /* do t = 1 to */

 /* просрочен долг это остатки 7 */
for each txb.lon no-lock:
    if (txb.lon.rdt > r-dt) then next.
    run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"1",no,txb.lon.crc,output v-bal1). /*основной долг остаток*/

     /*Наименование заемщика*/
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then v-cname = txb.cif.name.
    v-dog = "".
    find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if available txb.loncon then v-dog = txb.loncon.lcnt.

    v-intrate = 0.
    find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and ln%his.stdat <= r-dt and txb.ln%his.intrate > 0 use-index ln% no-lock no-error.
    if avail txb.ln%his then v-intrate = txb.ln%his.intrate.

    v-apz = "".
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= r-dt use-index lonhar-idx1 no-lock no-error.
    if avail txb.lonhar then find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    if avail txb.lonstat then do:
       v-apz = txb.lonstat.apz.
    end.
    /*find last kdlonkl where kdlonkl.bank = v-bank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon
    and kdlonkl.kod = 'finsost1' use-index bclrdt no-lock no-error.
    if available kdlonkl then do:
        if trim(kdlonkl.valdesc) <> "" then v-apz = trim(kdlonkl.valdesc).
        else do:
            find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then  v-apz = bookcod.name.
        end.
    end.*/
    /* курс валюты */
    v-rate = 0.
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < r-dt no-lock no-error.
    if avail txb.crchis then v-rate = txb.crchis.rate[1].

    run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"6",no,txb.lon.crc,output prov_od). /* провиз ОД*/
    prov_od = - prov_od.
    run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"7",no,txb.lon.crc,output debt_od). /* просрочен ОД*/
    if debt_od = 0 then next.
    /*run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"37",no,1,output prov_pen).
    prov_pen =  - prov_pen.*/
     find last txb.londebt where txb.londebt.lon = txb.lon.lon and txb.londebt.resdat <= r-dt no-lock no-error.
     create lnpr.
     lnpr.fname = v-fname.
     lnpr.name = v-name.
     lnpr.lon = txb.lon.lon.
     lnpr.cname = v-cname.
     lnpr.dog   = v-dog.
     lnpr.crc = txb.lon.crc.

     lnpr.klasif = v-apz.

     lnpr.intrate = v-intrate.
     lnpr.eintrate = 0.
     lnpr.rdt = txb.lon.rdt.
     lnpr.duedt = txb.lon.duedt.
     lnpr.dtype = 3.
     lnpr.paid = debt_od.  /*txb.londebt.od.*/
     lnpr.rpaid = debt_od * v-rate.
     if available txb.londebt then lnpr.stdat = g-today - txb.londebt.days_od.
     lnpr.vsum = (debt_od * prov_od) / (v-bal1 + debt_od). /* провизия в валюте */
     lnpr.nsum = ((debt_od * prov_od) / (v-bal1 + debt_od)) * v-rate. /* провизия в тенге */
end. /* for each txb.lon */

 /* просрочен вознаграждение это остатки 9 уровня */
for each txb.lon  no-lock:
    if (txb.lon.rdt > r-dt) then next.
    run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"2,49",no,txb.lon.crc,output v-bal2). /*вознагражд остаток*/

     /*Наименование заемщика*/
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then v-cname = txb.cif.name.
    v-dog = "".
    find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if available txb.loncon then v-dog = txb.loncon.lcnt.

    v-intrate = 0.
    find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and ln%his.stdat <= r-dt and txb.ln%his.intrate > 0 use-index ln% no-lock no-error.
    if avail txb.ln%his then v-intrate = txb.ln%his.intrate.

    v-apz = "".
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= r-dt use-index lonhar-idx1 no-lock no-error.
    if avail txb.lonhar then find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    if avail txb.lonstat then do:
       v-apz = txb.lonstat.apz.
    end.
    /*find last kdlonkl where kdlonkl.bank = v-bank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon
    and kdlonkl.kod = 'finsost1' use-index bclrdt no-lock no-error.
    if available kdlonkl then do:
        if trim(kdlonkl.valdesc) <> "" then v-apz = trim(kdlonkl.valdesc).
        else do:
            find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = kdlonkl.val1 no-lock no-error.
            if avail bookcod then  v-apz = bookcod.name.
        end.
    end.*/

    /* курс валюты */
    v-rate = 0.
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < r-dt no-lock no-error.
    if avail txb.crchis then v-rate = txb.crchis.rate[1].

    run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"9,50",no,txb.lon.crc,output debt_prc). /* просрочен вознагражд*/
    if debt_prc = 0 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"36",no,txb.lon.crc,output prov_prc). /* провизии вознагражд */
    prov_prc = - prov_prc.
     /*find last txb.londebt where txb.londebt.lon = txb.lon.lon and txb.londebt.resdat <= r-dt no-lock no-error.*/
     create lnpr.
     lnpr.fname = v-fname.
     lnpr.name = v-name.
     lnpr.lon = txb.lon.lon.
     lnpr.cname = v-cname.
     lnpr.dog   = v-dog.
     lnpr.crc = txb.lon.crc.

     lnpr.klasif = v-apz.

     lnpr.intrate = v-intrate.
     lnpr.eintrate = 0.
     lnpr.rdt = txb.lon.rdt.
     lnpr.duedt = txb.lon.duedt.
     lnpr.dtype = 4.
     lnpr.paid = debt_prc.  /*txb.londebt.prc.*/
     lnpr.rpaid = debt_prc * v-rate.
     /*if available txb.londebt then lnpr.stdat = g-today - txb.londebt.days_prc.*/

     lnpr.vsum = (debt_prc * prov_prc) / (v-bal2 + debt_prc). /* провизия в валюте */
     lnpr.nsum = ((debt_prc * prov_prc) / (v-bal2 + debt_prc)) * v-rate. /* провизия в тенге */
     run ddd(r-dt,txb.lon.lon,debt_prc, output ldt).
     lnpr.stdat = ldt.
end. /* for each txb.lon */


procedure ddd:
    define input parameter dat as date.
    define input parameter llon as char.
    define input parameter lsum as decim.
    define output parameter dtpr_prc as date.
    def var tempost as deci.
    def var dtbeg as date.
    def var v-summ as deci.

    dtpr_prc = ?.
    if lsum <> 0 then do:
        dtbeg = date(1,1,1900).
        for each txb.lonres where txb.lonres.lon = llon and txb.lonres.lev = 9 and txb.lonres.jdt < dat and txb.lonres.dc <> 'D' no-lock:
             tempost = 0.
             for each txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = llon and txb.histrxbal.level = 9 and txb.histrxbal.dt = txb.lonres.jdt no-lock:
                  tempost = tempost + txb.histrxbal.dam - txb.histrxbal.cam.
             end.
             if tempost = 0 then dtbeg = txb.lonres.jdt.
             else next.
        end.
        find first txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = llon and txb.histrxbal.level = 9 and  txb.histrxbal.dt > dtbeg and txb.histrxbal.dt < dat and txb.histrxbal.dam - txb.histrxbal.cam > 0 no-lock no-error.
        if avail txb.histrxbal then dtpr_prc = txb.histrxbal.dt.
        else do:
            tempost = 0.
            for each txb.lonres where txb.lonres.lon = llon and txb.lonres.lev = 9 and txb.lonres.jdt > dtbeg and txb.lonres.jdt < dat and txb.lonres.dc <> 'D' no-lock:
                tempost = tempost + txb.lonres.amt.
            end.
            v-summ = 0.
            for each txb.lonres where txb.lonres.lon = llon and txb.lonres.lev = 9 and txb.lonres.jdt > dtbeg and txb.lonres.jdt < dat and txb.lonres.dc = 'D' no-lock:
                v-summ = v-summ + txb.lonres.amt.
                if tempost < v-summ then do:
                    dtpr_prc = txb.lonres.jdt.
                    leave.
                end.
            end.
        end.
    end.

end procedure.


