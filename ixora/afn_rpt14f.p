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

def input parameter p-bank as char.

def shared temp-table lnpr no-undo
  field id       as   int
  field kname    as   char
  field nsum1    as   decimal
  field nsum2    as   decimal
  field nsum3    as   decimal
  field nsum4    as   decimal
  field nsum5    as   decimal
  field nsum6    as   decimal.

def shared var dt as date.
def var vgeo as char.

def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal16 as deci no-undo.
def var v-duedt as date no-undo.
def var v-prov_od as decimal.
def var v-prov_prc as decimal.
def var v-prov_pen as decimal.
def var v-prov as deci no-undo.
def var v-bal as deci no-undo.


def var rates as deci extent 3.
rates[1] = 1.
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt <= dt no-lock no-error.
if avail txb.crchis then rates[2] = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt <= dt no-lock no-error.
if avail txb.crchis then rates[3] = txb.crchis.rate[1].

find first comm.txb where comm.txb.txb = integer (substr(p-bank,4,2)) no-lock no-error.
if avail comm.txb then do:
  create lnpr.
    lnpr.id = integer (substr(p-bank,4,2)).
    lnpr.kname = comm.txb.name.
end.

for each txb.lon no-lock:

  if txb.lon.opnamt <= 0 then next.
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"1",yes,txb.lon.crc,output v-bal1).
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"7",yes,txb.lon.crc,output v-bal7).
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"2",yes,txb.lon.crc,output v-bal2).
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"9",yes,txb.lon.crc,output v-bal9).

  find last txb.hislon where txb.hislon.lon = txb.lon.lon and txb.hislon.fdt <= dt no-lock no-error.
      if avail txb.hislon then
            assign v-bal16 = txb.hislon.tdam[3] - txb.hislon.tcam[3].

  /*сумма провизий*/
  run lonbalcrc_txb ('lon',txb.lon.lon,dt,"6",yes,txb.lon.crc,output v-prov_od).
  v-prov_od = - v-prov_od.
  if txb.lon.crc <> 1 then do:
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= dt no-lock no-error.
      if avail txb.crchis then v-prov_od = v-prov_od * txb.crchis.rate[1].
      else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
   end.
  run lonbalcrc_txb ('lon',txb.lon.lon,dt,"36",yes,txb.lon.crc,output v-prov_prc).
  v-prov_prc = - v-prov_prc.
   if txb.lon.crc <> 1 then do:
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= dt no-lock no-error.
      if avail txb.crchis then v-prov_prc = v-prov_prc * txb.crchis.rate[1].
      else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
   end.
  run lonbalcrc_txb ('lon',txb.lon.lon,dt,"37",yes,1,output v-prov_pen).
  v-prov_pen = - v-prov_pen.
  v-prov = v-prov_od + v-prov_prc + v-prov_pen.

  if v-bal1 + v-bal7 + v-bal2 + v-bal9 + v-prov <= 0 then next.

  find first lnpr where lnpr.id = integer (substr(p-bank,4,2)) no-lock no-error.

   lnpr.nsum1 = lnpr.nsum1 + (v-bal1 + v-bal7) * rates[txb.lon.crc].
   lnpr.nsum2 = lnpr.nsum2 + (v-bal7) * rates[txb.lon.crc].
   lnpr.nsum3 = lnpr.nsum3 + (v-bal2) * rates[txb.lon.crc].
   lnpr.nsum4 = lnpr.nsum4 + (v-bal9) * rates[txb.lon.crc].
   lnpr.nsum5 = lnpr.nsum5 + v-bal16.
   lnpr.nsum6 = lnpr.nsum6 + v-prov.

end. /* for each txb.lon */

