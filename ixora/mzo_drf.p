/* crdvkf.p
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
  field cif       as   char
  field cname     as   char
  field ndog      as   char
  field dtv       as   date
  field dto       as   date
  field sz_vlt    as   char
  field sz_sum    as   decimal
  field ob_name   as   char
  field ob_adr    as   char
  field ob_zlg    as   char
  field sp_vlt    as   char
  field sp_sum    as   decimal
  field sp_dtm    as   date
  field ost       as   decimal
  field otm       as   char.

def var i as integer no-undo.
def var v-grp as integer no-undo.
def var lst_grp as char no-undo init ''.
def var v_ost as decimal.

def shared var b-dt as date.

for each txb.longrp no-lock:
  if txb.longrp.des matches '*МСБ*' then do:
    if lst_grp <> '' then lst_grp = lst_grp + ','.
    lst_grp = lst_grp + string(txb.longrp.longrp).
  end.
end.

do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp and gua <> 'CL' no-lock:

      run lonbalcrc_txb('lon',txb.lon.lon,b-dt,"1,7",no,txb.lon.crc,output v_ost).

      for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
         create lnpr.

         lnpr.cif = txb.lon.cif.

         find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
         if avail txb.cif then lnpr.cname = txb.cif.name.

         find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
         if avail txb.loncon then lnpr.ndog = txb.loncon.lcnt.

         lnpr.dtv = txb.lon.rdt.
         lnpr.dto = txb.lon.duedt.


         find first txb.crc where txb.crc.crc = txb.lonsec1.crc no-lock no-error.
         if avail txb.crc then lnpr.sz_vlt = txb.crc.des.

         lnpr.sz_sum = txb.lonsec1.secamt.
         lnpr.ob_name = txb.lonsec1.prm.
         lnpr.ob_adr = txb.lonsec1.vieta.
         lnpr.ob_zlg = txb.lonsec1.pielikums[1].

         find last txb.lnmonsrp where txb.lnmonsrp.lon = txb.lon.lon and txb.lnmonsrp.num = txb.lonsec1.ln and txb.lnmonsrp.pdt < b-dt no-lock no-error.
         if avail txb.lnmonsrp then do:
          find first txb.crc where txb.crc.crc = txb.lonsec1.crc no-lock no-error.
          if avail txb.crc then lnpr.sp_vlt = txb.crc.des.
          lnpr.sp_sum = txb.lnmonsrp.nsum.
          lnpr.sp_dtm = txb.lnmonsrp.pdt.
         end.

         lnpr.ost = v_ost.

      end. /* for each txb.lonsec1 */
    end. /* for each txb.lon */

end. /* do i = 1 to */


