/* prgpogf.p
 * MODULE
         Кредитный модуль
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
   08/11/2011 kapar - по служебной записке
*/


def shared temp-table lnpr
  field nf       as   int
  field sf       as   char
  field sum_od   as   decimal
  field sum_pr   as   decimal.

def shared var b-dt as date.
def shared var e-dt as date.


def var i       as integer no-undo.
def var v-grp   as integer no-undo.
def var lst_grp as char no-undo init ''.

def var v-kurs   as deci.
def var v_sum_od as deci.
def var v_sum_pr as deci.

/*
for each txb.longrp no-lock:
  if txb.longrp.des matches '*МСБ*' then do:
    if lst_grp <> '' then lst_grp = lst_grp + ','.
    lst_grp = lst_grp + string(txb.longrp.longrp).
  end.
end.
*/


v_sum_od = 0.
v_sum_pr = 0.
lst_grp = "10,11,14,15,16,21,24,25,26,50,54,55,56,64,65,66,70".
do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).

    for each txb.lon where txb.lon.grp = v-grp no-lock:

        if txb.lon.opnamt <= 0 then next.

        /*Курсы валют*/
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= e-dt no-lock no-error.
        if avail txb.crchis then v-kurs = txb.crchis.rate[1].
        else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.

        /*Погашение ОД за будущие периоды*/
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= b-dt and txb.lnsch.stdat < e-dt no-lock no-error.
        if avail txb.lnsch then do:
           v_sum_od = v_sum_od + txb.lnsch.stval * v-kurs .
        end.

        /*Погашение %% за будущие периоды*/
        find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat >= b-dt and txb.lnsci.idat < e-dt no-lock no-error.
        if avail txb.lnsci then do:
            v_sum_pr = v_sum_pr + txb.lnsci.iv-sc * v-kurs.
        end.

    end. /* for each txb.lon */

end. /* do i = 1 to */

/*Филиал*/
find first txb.cmp no-lock no-error.
if avail txb.cmp then do:
    create lnpr.
      lnpr.nf = int(cmp.code).
      lnpr.sf = cmp.name.
      lnpr.sum_od = v_sum_od.
      lnpr.sum_pr = v_sum_pr.
end.