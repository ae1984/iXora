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
       01/04/2011
 * BASES
	COMM, TXB
 * CHANGES
*/


def shared temp-table lnpr no-undo
  field lon       as   char
  field cname     as   char
  field fcode     as   char
  field fname     as   char
  field ndog      as   char
  field crc       as   int
  field dtdate    as   date
  field ost       as   decimal
  field sts       as   char.

def shared var b-dt as date.
def shared var e-dt as date.
/*def shared var v-dt as date.*/


def var v-fcode as char.
def var v-fname as char.
def var v-ost   as decimal.

def var i as integer no-undo.
def var v-grp as integer no-undo.
def var lst_grp as char no-undo init ''.


for each txb.longrp no-lock:
  if txb.longrp.des matches '*МСБ*' then do:
    if lst_grp <> '' then lst_grp = lst_grp + ','.
    lst_grp = lst_grp + string(txb.longrp.longrp).
  end.
end.

find first txb.cmp no-lock no-error.
if avail txb.cmp then do:
  v-fcode = string(txb.cmp.code).
  v-fname = txb.cmp.name.
end.

for each txb.cif where  no-lock:
    for each txb.lon where txb.lon.cif =  txb.cif.cif no-lock:

        run lonbalcrc_txb('lon',txb.lon.lon,b-dt,"1",no,txb.lon.crc,output v-ost).
        If v-ost > 0 Then do:
            run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"1",no,txb.lon.crc,output v-ost).
            if v-ost = 0 then do:
               create lnpr.
                 lnpr.lon =  txb.lon.lon.
                 lnpr.cname = txb.cif.name.
                 lnpr.fcode = v-fcode.
                 lnpr.fname = v-fname.

                 find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
                 if avail txb.loncon then lnpr.ndog = txb.loncon.lcnt.

                 lnpr.crc =  txb.lon.crc.
                 lnpr.ost = v-ost.

                 find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.stdat <= e-dt no-lock no-error.
                 if avail txb.lnsch then lnpr.dtdate = txb.lnsch.stdat.


                 If txb.lon.duedt > e-dt then do:
                   lnpr.sts='Погашен досрочно'.
                 end. else do:
                   lnpr.dtdate = txb.lon.duedt.
                   lnpr.sts='Погашен по Договору'.
                 end.
            end.
        end.
    end. /*for each txb.lon*/
end. /*for each txb.cif*/

