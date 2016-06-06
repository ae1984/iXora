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

def shared var g-today as date.

def shared temp-table lnpr no-undo
  field id       as   int
  field kname    as   char
  field nsum     as   decimal
  field psum     as   decimal.
def var vnf      as   int.

def shared var dt as date.

def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-duedt as date no-undo.
def var v-prov as deci no-undo.
def var v-bal as deci no-undo.


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

  find first lnpr where lnpr.id = txb.lon.crc no-lock no-error.
  if avail lnpr then do:
    lnpr.nsum = lnpr.nsum + (v-bal1 + v-bal7 + v-bal2 + v-bal9) * rates[txb.lon.crc].
  end.
  else do:
   find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
   if avail txb.crc then do:
    create lnpr.
     lnpr.id = txb.lon.crc.
     lnpr.kname = txb.crc.des.
     lnpr.nsum = lnpr.nsum + (v-bal1 + v-bal7 + v-bal2 + v-bal9) * rates[txb.lon.crc].
   end.
  end.


end. /* for each txb.lon */

