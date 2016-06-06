/* rklas-akt2.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет "История классификации активов для провизий"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-5-4
 * AUTHOR
        31/01/2012 dmitriy
 * BASES
        TXB BANK COMM
 * CHANGES
        15/02/2012 dmitriy - wrk.lonpool = v-poolName[i]
        15.08.2012 kapar - ТЗ 1440
*/

def shared var dat1 as date.
def shared var v-reptype as integer no-undo.

def shared temp-table wrk
    field branch as char
    field cif as char
    field cifname as char
    field longr as inte
    field lonpool as char
    field londog as char
    field crc as char
    field opndt as date
    field duedt as date
    field opnamt as deci
    field od as deci
    field afn% as deci
    field afntg as deci
    field msfotg as deci
    field msfo% as deci
    field msfopen as deci
    field allmsfo as deci
    field msfo-afn as deci
    field bal_inter as deci
    field bal_penal as deci.

def var branch-name as char.
def var v-od as deci.
def var v-afn% as deci.
def var v-afntg as deci.
def var v-msfotg as deci.
def var v-msfo% as deci.
def var v-msfopen as deci.
def var kurs as deci.
def var v-bal_inter as deci.
def var v-bal_penal as deci.

def var i as integer no-undo.
def var j as integer no-undo.
def var lst_grp as char no-undo.
def var v-grp as integer no-undo.
lst_grp = ''.

def var v-pool as char no-undo extent 10.
def var v-poolName as char no-undo extent 10.
def var v-poolId as char no-undo extent 10.

v-pool[1] = "27,67".
v-poolName[1] = "Ипотечные займы".
v-poolId[1] = "ipoteka".
v-pool[2] = "28,68".
v-poolName[2] = "Автокредиты".
v-poolId[2] = "auto".
v-pool[3] = "20,60".
v-poolName[3] = "Прочие потребительские кредиты".
v-poolId[3] = "flobesp".
v-pool[4] = "90,92".
v-poolName[4] = "Потребительские кредиты Бланковые 'Метрокредит'".
v-poolId[4] = "metro".
v-pool[5] = "81,82".
v-poolName[5] = "Потребительские кредиты Бланковые 'Сотрудники'".
v-poolId[5] = "sotr".
v-pool[6] = "16,26,56,66".
v-poolName[6] = "Метро-экспресс МСБ".
v-poolId[6] = "express-msb".
v-pool[7] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
v-poolName[7] = "Кредиты МСБ".
v-poolId[7] = "msb".
v-pool[8] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
v-poolName[8] = "Индивид. МСБ".
v-poolId[8] = "individ-msb".
v-pool[9] = "11,21,70,80".
v-poolName[9] = "факторинг, овердрафты".
v-poolId[9] = "factover".
v-pool[10] = "95,96".
v-poolName[10] = "Ипотека «Астана бонус»".
v-poolId[10] = "astana-bonus".

find first txb.cmp no-lock no-error.
if avail txb.cmp then branch-name = txb.cmp.name.

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


do j = 1 to num-entries(lst_grp):
v-grp = integer(entry(j,lst_grp)).

for each txb.lon where txb.lon.grp = v-grp no-lock:
    create wrk.

    wrk.branch = branch-name.
    wrk.cif = txb.lon.cif.

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then
    wrk.cifname = txb.cif.prefix + " " + txb.cif.name.

    wrk.longr = txb.lon.grp.

    find last txb.lonpool where txb.lonpool.cif = txb.lon.cif and txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt <= dat1 no-lock no-error.
    if avail txb.lonpool then do:
        do i = 1 to 10:
            if txb.lonpool.poolID = v-poolId[i] then wrk.lonpool = v-poolName[i].
        end.
    end.

    find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if avail txb.loncon then
    wrk.londog = txb.loncon.lcnt.

    find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
    if avail txb.crc then
    wrk.crc = txb.crc.code.

    if txb.lon.crc <> 1 then do:
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < dat1 no-lock no-error.
        if avail txb.crchis then kurs = txb.crchis.rate[1].
    end.
    else kurs = 1.

    wrk.opndt = txb.lon.opndt.
    wrk.duedt = txb.lon.duedt.
    wrk.opnamt = txb.lon.opnamt * kurs.


    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"1,7",no,txb.lon.crc,output v-od).
    wrk.od = v-od * kurs.

    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"2,9",no,txb.lon.crc,output v-bal_inter).
    wrk.bal_inter = v-bal_inter * kurs.

    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"16",no,1,output v-bal_penal).
    wrk.bal_penal = v-bal_penal.

    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"41",no,txb.lon.crc,output v-afntg).
    wrk.afntg = - (v-afntg * kurs).

    if wrk.od <> 0 then
    wrk.afn% = (wrk.afntg * 100) / wrk.od.
    /*else
    wrk.afn% = "-".*/

    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"6",no,txb.lon.crc,output v-msfotg).
    wrk.msfotg = - (v-msfotg * kurs).

    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"36",no,txb.lon.crc,output v-msfo%).
    wrk.msfo% = - (v-msfo% * kurs).

    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"37",no,1,output v-msfopen).
    wrk.msfopen = - v-msfopen.


    wrk.allmsfo = wrk.msfotg + wrk.msfo% + wrk.msfopen.

    wrk.msfo-afn = wrk.allmsfo - wrk.afntg.

end. /* txb.lon */
end. /* j */