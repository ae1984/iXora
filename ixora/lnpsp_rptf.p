/* afnf.p
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
       01/04/2011
 * BASES
	COMM, TXB
 * CHANGES
    18/09/2013 galina - ТЗ1403 для отчета "Прогноз погашений" берем введеный период
*/

def shared temp-table flnpr
  field fid      as   int
  field fname    as   char.

def shared temp-table lnpr
  field id       as   int
  field fid      as   int
  field kname    as   char
  field nsum     as   decimal extent 72.

def shared var v-date1 as date.
def shared var v-date2 as date.
def shared var v_sel   as int.
def var vm      as   int.
def var vmm     as   int.
def var tmm     as   int.
def var vyy     as   int.
def var tyy     as   int.
def var i     as  int.
def var bdt   as  date.
def var edt   as  date.
def var vid   as  int.
def var rates as  deci extent 3.

def var v-bal    as  deci.
def var v-nsum1  as  deci.
def var v-nsum2  as  deci.

def var lst_grp as char no-undo init ''.
def var j as integer no-undo.
def var v-grp as integer no-undo.

find first txb.cmp no-lock no-error.

create flnpr.
 flnpr.fid = cmp.code.
 flnpr.fname = cmp.name.

if v_sel = 1 then do:
    create lnpr.
     lnpr.id = 1.
     lnpr.kname = "План".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 2.
     lnpr.kname = "Факт".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 3.
     lnpr.kname = "План МСБ".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 4.
     lnpr.kname = "Факт МСБ".
     lnpr.fid = cmp.code.
end.

if v_sel = 2 then do:
    create lnpr.
     lnpr.id = 1.
     lnpr.kname = "Выдачи".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 2.
     lnpr.kname = "Погашения".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 3.
     lnpr.kname = "Выдачи МСБ".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 4.
     lnpr.kname = "Погашения МСБ".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 5.
     lnpr.kname = "Прирост".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 6.
     lnpr.kname = "Доля погашений в процентах".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 7.
     lnpr.kname = "Прирост МСБ".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 8.
     lnpr.kname = "Доля погашений в процентах МСБ".
     lnpr.fid = cmp.code.
end.

if v_sel = 3 then do:
    create lnpr.
     lnpr.id = 1.
     lnpr.kname = "Погашение ОД".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 2.
     lnpr.kname = "Погашение %%".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 3.
     lnpr.kname = "Погашение ОД МСБ".
     lnpr.fid = cmp.code.
    create lnpr.
     lnpr.id = 4.
     lnpr.kname = "Погашение %% МСБ".
     lnpr.fid = cmp.code.
end.

vm = (year(v-date2) - year(v-date1)) * 12 + (month(v-date2) - month(v-date1)).
vmm = month(v-date1) - 1.  tmm = vmm.
vyy = year(v-date1). tyy = vyy.

i = 0. vmm = tmm. vyy = tyy.
repeat while i <= vm:
    vmm =  vmm + 1.
    if vmm > 12 then do:
      vmm = 1.
      vyy = vyy + 1.
    end.
    if v_sel = 3 then do:
        if i = 0 then bdt = v-date1.
        else bdt = date('01.' + string(vmm) + '.' + string(vyy)).
        if i = vm then edt = v-date2 + 1.
        else do:
            if (vmm + 1) > 12 then edt = date('01.01.' + string(vyy + 1)).
            else edt = date('01.' + string(vmm + 1) + '.' + string(vyy)).
        end.
    end.
    else do:
        bdt = date('01.' + string(vmm) + '.' + string(vyy)).
        if (vmm + 1) > 12 then edt = date('01.01.' + string(vyy + 1)).
        else edt = date('01.' + string(vmm + 1) + '.' + string(vyy)).
    end.

    i = i + 1.

    rates[1] = 1.
    find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < edt no-lock no-error.
    if avail txb.crchis then rates[2] = txb.crchis.rate[1].
    find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < edt no-lock no-error.
    if avail txb.crchis then rates[3] = txb.crchis.rate[1].


    if v_sel = 1 then do:
      find first lnpr where lnpr.id = 1  and lnpr.fid = cmp.code no-lock no-error.
      if avail lnpr then do:
        find first lnpsp where int(lnpsp.fid) = cmp.code and lnpsp.pdt >= bdt and lnpsp.pdt < edt no-lock no-error.
        if avail lnpsp then
          lnpr.nsum[i] = lnpr.nsum[i] + lnpsp.nsum.
      end.
    end.

    for each txb.lon no-lock:
      if txb.lon.opnamt <= 0 then next.

      if v_sel = 1 then do:
        run lonbalcrc_txb('lon',txb.lon.lon,bdt,"1,7",yes,txb.lon.crc,output v-bal).
        find first lnpr where lnpr.id = 2  and lnpr.fid = cmp.code no-lock no-error.
        if avail lnpr then
          lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * rates[txb.lon.crc]) / 1000.
      end.

      if v_sel = 2 then do:
        /*Выдачи ОД*/
        for each txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.stdat >= bdt and txb.lnscg.stdat < edt and
                                 txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock break by txb.lnscg.lng:
           find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnscg.stdat no-lock no-error.
           v-bal = txb.lnscg.paid.
           find first lnpr where lnpr.id = 1  and lnpr.fid = cmp.code no-lock no-error.
           if avail lnpr then
             lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * txb.crchis.rate[1]) / 1000.
        end.

        /*Погашение ОД*/
        for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.stdat >= bdt and txb.lnsch.stdat < edt  no-lock:
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsch.stdat no-lock no-error.
           run lonbal_txb('lon',txb.lon.lon,edt,"1,7",yes,output v-bal).
           if v-bal <= 0 then do:
               v-bal = txb.lnsch.paid.
               find first lnpr where lnpr.id = 2  and lnpr.fid = cmp.code no-lock no-error.
               if avail lnpr then
                 lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * txb.crchis.rate[1]) / 1000.
           end. else do:
               v-bal = txb.lnsch.paid.
               find first lnpr where lnpr.id = 2  and lnpr.fid = cmp.code no-lock no-error.
               if avail lnpr then
                 lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * txb.crchis.rate[1]) / 1000.
           end.
        end.

        find first lnpr where lnpr.id = 1  and lnpr.fid = cmp.code no-lock no-error.
        if avail lnpr then
          v-nsum1 = lnpr.nsum[i].
        find first lnpr where lnpr.id = 2  and lnpr.fid = cmp.code no-lock no-error.
        if avail lnpr then
          v-nsum2 = lnpr.nsum[i].
      end.

      if v_sel = 3 then do:
        /*Погашение ОД за будущие периоды*/
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= bdt and txb.lnsch.stdat < edt no-lock no-error.
        if avail txb.lnsch then do:
           v-bal = txb.lnsch.stval.
           find first lnpr where lnpr.id = 1  and lnpr.fid = cmp.code no-lock no-error.
           if avail lnpr then
             lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * rates[txb.lon.crc]) / 1000.
        end.

        /*Погашение %% за будущие периоды*/
       find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat >= bdt and txb.lnsci.idat < edt no-lock no-error.
       if avail txb.lnsci then do:
           v-bal = txb.lnsci.iv-sc.
           find first lnpr where lnpr.id = 2  and lnpr.fid = cmp.code no-lock no-error.
           if avail lnpr then
             lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * rates[txb.lon.crc]) / 1000.
        end.
      end.

    end. /* for each txb.lon */

end.


i = 0. vmm = tmm. vyy = tyy.
repeat while i <= vm:
    vmm =  vmm + 1.
    if vmm > 12 then do:
      vmm = 1.
      vyy = vyy + 1.
    end.
    if v_sel = 3 then do:
        if i = 0 then bdt = v-date1.
        else bdt = date('01.' + string(vmm) + '.' + string(vyy)).
        if i = vm then edt = v-date2 + 1.
        else do:
            if (vmm + 1) > 12 then edt = date('01.01.' + string(vyy + 1)).
            else edt = date('01.' + string(vmm + 1) + '.' + string(vyy)).
        end.
    end.
    else do:
        bdt = date('01.' + string(vmm) + '.' + string(vyy)).
        if (vmm + 1) > 12 then edt = date('01.01.' + string(vyy + 1)).
        else edt = date('01.' + string(vmm + 1) + '.' + string(vyy)).
    end.


    i = i + 1.

    rates[1] = 1.
    find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < edt no-lock no-error.
    if avail txb.crchis then rates[2] = txb.crchis.rate[1].
    find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < edt no-lock no-error.
    if avail txb.crchis then rates[3] = txb.crchis.rate[1].


    if v_sel = 1 then do:
      find first lnpr where lnpr.id = 3 and lnpr.fid = cmp.code no-lock no-error.
      if avail lnpr then do:
        find first lnpsp where int(lnpsp.fid) = cmp.code and lnpsp.pdt >= bdt and lnpsp.pdt < edt no-lock no-error.
        if avail lnpsp then
          lnpr.nsum[i] = lnpr.nsum[i] + lnpsp.nsum.
      end.
    end.

    lst_grp = '14,15,16,24,25,26,54,55,56,64,65,66'.
    do j = 1 to num-entries(lst_grp):
    v-grp = integer(entry(j,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:
      if txb.lon.opnamt <= 0 then next.

      if v_sel = 1 then do:
        run lonbalcrc_txb('lon',txb.lon.lon,bdt,"1,7",yes,txb.lon.crc,output v-bal).
        find first lnpr where lnpr.id = 4 and lnpr.fid = cmp.code no-lock no-error.
        if avail lnpr then
          lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * rates[txb.lon.crc]) / 1000.
      end.

      if v_sel = 2 then do:
        /*Выдачи ОД*/
        for each txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.stdat >= bdt and txb.lnscg.stdat < edt and
                                 txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock break by txb.lnscg.lng:
           find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnscg.stdat no-lock no-error.
           v-bal = txb.lnscg.paid.
           find first lnpr where lnpr.id = 3 and lnpr.fid = cmp.code no-lock no-error.
           if avail lnpr then
             lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * txb.crchis.rate[1]) / 1000.
        end.

        /*Погашение ОД*/
        for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.stdat >= bdt and txb.lnsch.stdat < edt  no-lock:
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsch.stdat no-lock no-error.
           run lonbal_txb('lon',txb.lon.lon,edt,"1,7",yes,output v-bal).
           if v-bal <= 0 then do:
               v-bal = txb.lnsch.paid.
               find first lnpr where lnpr.id = 4 and lnpr.fid = cmp.code no-lock no-error.
               if avail lnpr then
                 lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * txb.crchis.rate[1]) / 1000.
           end. else do:
               v-bal = txb.lnsch.paid.
               find first lnpr where lnpr.id = 4 and lnpr.fid = cmp.code no-lock no-error.
               if avail lnpr then
                 lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * txb.crchis.rate[1]) / 1000.
           end.
        end.

        find first lnpr where lnpr.id = 3 and lnpr.fid = cmp.code no-lock no-error.
        if avail lnpr then
          v-nsum1 = lnpr.nsum[i].
        find first lnpr where lnpr.id = 4 and lnpr.fid = cmp.code no-lock no-error.
        if avail lnpr then
          v-nsum2 = lnpr.nsum[i].
      end.

      if v_sel = 3 then do:
        /*Погашение ОД за будущие периоды*/
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= bdt and txb.lnsch.stdat < edt no-lock no-error.
        if avail txb.lnsch then do:
           v-bal = txb.lnsch.stval.
           find first lnpr where lnpr.id = 3 and lnpr.fid = cmp.code no-lock no-error.
           if avail lnpr then
             lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * rates[txb.lon.crc]) / 1000.
        end.

        /*Погашение %% за будущие периоды*/
       find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat >= bdt and txb.lnsci.idat < edt no-lock no-error.
       if avail txb.lnsci then do:
           v-bal = txb.lnsci.iv-sc.
           find first lnpr where lnpr.id = 4 and lnpr.fid = cmp.code no-lock no-error.
           if avail lnpr then
             lnpr.nsum[i] = lnpr.nsum[i] + (v-bal * rates[txb.lon.crc]) / 1000.
        end.
      end.

    end. /* for each txb.lon */
    end.

end.
