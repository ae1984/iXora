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
def var vm    as  int.
def var vmm   as  int.
def var vyy   as  int.
def var i     as  int.
def var bdt   as  date.
def var edt   as  date.
def var vid   as  int.
def var rates as  deci extent 3.

vm = (year(v-date2) - year(v-date1)) * 12 + (month(v-date2) - month(v-date1)).
vmm = month(v-date1) - 1. vyy = year(v-date1).

i = 0.
repeat while i <= vm:
    vmm =  vmm + 1.
    if vmm > 12 then do:
      vmm = 1.
      vyy = vyy + 1.
    end.
    bdt = date('01.' + string(vmm) + '.' + string(vyy)).
    if (vmm + 1) > 12 then
      edt = date('01.01.' + string(vyy + 1)).
    else
      edt = date('01.' + string(vmm + 1) + '.' + string(vyy)).
    i = i + 1.

    rates[1] = 1.
    find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < edt no-lock no-error.
    if avail txb.crchis then rates[2] = txb.crchis.rate[1].
    find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < edt no-lock no-error.
    if avail txb.crchis then rates[3] = txb.crchis.rate[1].

    for each txb.lon no-lock:


      find last txb.longrp where txb.longrp.longrp =  txb.lon.grp no-lock no-error.
      if avail txb.longrp then do:
          If txb.longrp.stn >= 20 and txb.longrp.stn < 30  Then vid = 1.
          If txb.longrp.stn >= 10 and txb.longrp.stn < 20  Then vid = 2.

          find last txb.lnscg where txb.lnscg.lng =  txb.lon.lon and txb.lnscg.stdat >= bdt and txb.lnscg.stdat < edt and txb.lnscg.flp > 0 no-lock no-error.
          if avail txb.lnscg then do:
              find first lnpr where lnpr.id = vid no-lock no-error.
              if avail lnpr then do:
                lnpr.nsum[i] = lnpr.nsum[i] + txb.lnscg.paid * rates[txb.lon.crc].
              end.
          end.
      end.

    end. /* for each txb.lon */
end.



