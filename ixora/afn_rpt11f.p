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
*/

def shared temp-table lnpr no-undo
  field id       as   int
  field kname    as   char
  field nsum     as   decimal extent 72.

def shared var v-date1 as date.
def shared var v-date2 as date.
def shared var vsel    as int.
def var vm       as   int.
def var vmm      as   int.
def var vyy      as   int.
def var num_days as   int.
def var i   as int.
def var dt  as date.
def var vid as int.

def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-duedt as date no-undo.
def var v-prov as deci no-undo.
def var v-bal as deci no-undo.

def var  dayc_od  as deci.
def var  dayc_prc  as deci.


vm = (year(v-date2) - year(v-date1)) * 12 + (month(v-date2) - month(v-date1)).
vmm = month(v-date1) - 3. vyy = year(v-date1).


i = 0.
repeat while i <= vm:
    vmm =  vmm + 3.
    if vmm > 12 then do:
      vmm = vmm - 12.
      vyy = vyy + 1.
    end.

    run mondays(vmm, vyy, output num_days).
    if num_days < day(v-date1) then dt = date(string(num_days) + '.' + string(vmm) + '.' + string(vyy)).
    else dt = date(string(day(v-date1)) + '.' + string(vmm) + '.' + string(vyy)).
    /*dt = date(string(day(v-date1)) + '.' + string(vmm) + '.' + string(vyy)).*/
    i = i + 3.

    def var rates as deci extent 3.
    rates[1] = 1.
    find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt <= dt no-lock no-error.
    if avail txb.crchis then rates[2] = txb.crchis.rate[1].
    find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt <= dt no-lock no-error.
    if avail txb.crchis then rates[3] = txb.crchis.rate[1].


    for each txb.lon no-lock:

      if txb.lon.opnamt <= 0 then next.
      run lonbalcrc_txb('lon',txb.lon.lon,dt,"1",yes,txb.lon.crc,output v-bal1).
      run lonbalcrc_txb('lon',txb.lon.lon,dt,"7",yes,txb.lon.crc,output v-bal7).
  /*run lonbalcrc_txb('lon',txb.lon.lon,dt,"2",yes,txb.lon.crc,output v-bal2).*/ v-bal2 = 0.
  /*run lonbalcrc_txb('lon',txb.lon.lon,dt,"9",yes,txb.lon.crc,output v-bal9).*/ v-bal9 = 0.
      run lonbal_txb('lon',txb.lon.lon,dt,"6,36,37",yes,output v-prov).
      v-prov = - v-prov.
      if v-bal1 + v-bal7 + v-bal2 + v-bal9 + v-prov <= 0 then next.

      run lonbalcrc_txb('lon',txb.lon.lon,dt,"6,36",yes,txb.lon.crc,output v-bal).
      v-prov = - v-bal * rates[txb.lon.crc].
      run lonbalcrc_txb('lon',txb.lon.lon,dt,"37",yes,1,output v-bal).
      v-prov = v-prov - v-bal.

      dayc_od = 0. dayc_prc = 0.
      run lndayspr_txb(txb.lon.lon,dt,yes,output dayc_od,output dayc_prc).

      vid = 0.
      if (vsel = 1 ) and (dayc_od > 30) and (dayc_od <= 60) Then vid = 1.
      if (vsel = 2 ) and (dayc_od > 60) and (dayc_od <= 90) Then vid = 1.
      if (vsel = 3 ) and (dayc_od > 90) Then vid = 1.

      if vid = 1 then do:
          If lookup(string(txb.lon.grp), "90,92") <> 0 Then vid = 1.
          If lookup(string(txb.lon.grp), "81,82") <> 0 Then vid = 2.
          If lookup(string(txb.lon.grp), "14,24,54,64") <> 0 Then vid = 3.
          If lookup(string(txb.lon.grp), "15,25,55,65") <> 0 Then vid = 4.
          If lookup(string(txb.lon.grp), "16,26,56,66") <> 0 Then vid = 5.
          If lookup(string(txb.lon.grp), "70,80") <> 0 Then vid = 6.
          If lookup(string(txb.lon.grp), "11,21") <> 0 Then vid = 7.
          If lookup(string(txb.lon.grp), "20,60") <> 0 Then vid = 8.
          If lookup(string(txb.lon.grp), "10,50") <> 0 Then vid = 9.
          If lookup(string(txb.lon.grp), "27,67") <> 0 Then vid = 10.

          find first lnpr where lnpr.id = vid no-lock no-error.
          if avail lnpr then do:
            lnpr.nsum[i] = lnpr.nsum[i] + (v-bal1 + v-bal7 + v-bal2 + v-bal9) * rates[txb.lon.crc].
          end.
      end.

    end. /* for each txb.lon */
end.



