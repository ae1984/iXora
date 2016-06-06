﻿/* afnf.p
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

def input parameter p-bank as char.
def shared var g-today as date.

def shared temp-table lnpr no-undo
  field id       as   int
  field kname    as   char
  field nsum     as   decimal
  field psum     as   decimal.
def var vnf      as   int.

def shared temp-table flnpr no-undo
  field nf       as   int
  field id       as   int
  field kname    as   char
  field nsum     as   decimal
  field psum     as   decimal.


def shared var vcode as int.
def shared var dt as date.
def var vid as int.


def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-duedt as date no-undo.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.
def var v-prov as deci no-undo.
def var v-bal as deci no-undo.

if (vcode <> 0) and (vcode <> integer (substr(p-bank,4,2))) then leave.

def var rates as deci extent 3.
rates[1] = 1.
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt <= dt no-lock no-error.
if avail txb.crchis then rates[2] = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt <= dt no-lock no-error.
if avail txb.crchis then rates[3] = txb.crchis.rate[1].

find first comm.txb where comm.txb.txb = integer (substr(p-bank,4,2)) no-lock no-error.
if avail comm.txb then do:
  for each lnpr no-lock:
     create flnpr.
      flnpr.nf = integer (substr(p-bank,4,2)).
      flnpr.id = lnpr.id.
      flnpr.kname = lnpr.kname.
  end.
end.

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

  v-duedt = txb.lon.duedt.
  if txb.lon.ddt[5] <> ? then v-duedt = txb.lon.ddt[5].
  if txb.lon.cdt[5] <> ? then v-duedt = txb.lon.cdt[5].

  if v-duedt <= g-today then dn1 = 0.
  else run day-360(g-today,v-duedt - 1,txb.lon.basedy,output dn1,output dn2).

  if dn1 = 0 then dn1 = 1. /* чтобы кредиты, закрывающиеся сегодня, попали в первую группу */

  if dn1>0 and dn1<=90 Then vid = 1.
  if dn1>90 and dn1<=180 Then vid = 2.
  if dn1>180 and dn1<=360 Then vid = 3.
  if dn1>360 and dn1<=720 Then vid = 4.
  if dn1>720 and dn1<=1800 Then vid = 5.
  if dn1>1800 Then vid = 6.

  find first lnpr where lnpr.id = vid no-lock no-error.
  if avail lnpr then do:
   lnpr.nsum = lnpr.nsum + (v-bal1 + v-bal7 + v-bal2 + v-bal9) * rates[txb.lon.crc].
  end.

  find first flnpr where flnpr.id = vid and flnpr.nf = integer (substr(p-bank,4,2)) no-lock no-error.
  if avail flnpr then do:
   flnpr.nsum = flnpr.nsum + (v-bal1 + v-bal7 + v-bal2 + v-bal9) * rates[txb.lon.crc].
  end.

end. /* for each txb.lon */
