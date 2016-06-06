/* dcls55.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет о просроченных суммах и штрафах (по 7, 9 и 16 уровням)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        30/05/2005 madiyar - вынес из r-penal - разбранчевка
 * CHANGES
        20/06/2005 madiyar - небольшие изменения
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        15/02/2006 Natalya D. - добавлены 2 поля: Начисленные % за балансом и Начисленные штрафы за балансом
        03/04/2006 madiyar - вернул наименование клиента; расчет дней просрочки по проводкам, а не по графику
        04/09/2008 madiyar - явно указал индекс в поиске последней записи в lonhar
        04/05/09 marinav - провизии теперь в валюте кредита
        01/06/2009 madiyar - по кредитам в валюте провизии переводятся в тенге по курсу за дату отчета
        02/11/2009 galina - добавила пересчет в тенге остатка ОД
        13/09/2010 aigul - добавила сектор экономики и код займа по виду залога
        10/08/2011 dmitriy - добавил поле commis в wrk
        05/11/2011 kapar - исправил поле Комиссия
        12/04/2012 kapar - ТЗ 1340
*/


define input parameter d1 as date.

def var v-bal16 like txb.jl.dam.
def var v-bal4 like txb.jl.dam.
def var v-bal9 like txb.jl.dam.
def var v-bal7 like txb.jl.dam.
def var v-bal5 like txb.jl.dam.

def var bilance like txb.jl.dam.
def var coun as int init 1.
def var v-day7 as integer.
def var v-day9 as integer.
def var v-day4 as integer.
def var v-day5 as integer.
def var tempdt as date.
def var tempost as deci.
def var mddt as date.

def var v-sts as deci.
def var v-prov as deci.
def var v-kommis as deci.
def var v-ost as deci.

/* группы кредитов юридических лиц */
def var lst_ur as char init ''.
for each txb.longrp no-lock:
  if substr(string(txb.longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(txb.longrp.longrp).
  end.
end.

def shared temp-table wrk
  field bank as char
  field urfiz as char
  field name as char
  field cif /***like cif.cif***/ as char
  field lon like txb.lon.lon
  field grp like txb.lon.grp
  field crc like txb.crc.crc
  field opnamt as decimal
  field rdt as date
  field duedt as date
  field balance as decimal
  field od_prosr as decimal
  field od_days as integer
  field proc_prosr as decimal
  field proc_days as integer
  field proc_zabal as decimal
  field shtraf as decimal
  field shtraf_zabal as decimal
  field crstatus as decimal
  field prov as decimal
  field sec_econ as char
  field ob_cred as char
  field kommis as deci
  index idx1 bank urfiz crc cif
  index idx2 urfiz crc bank cif.

find first txb.cmp no-lock no-error.

for each txb.lon no-lock.

     v-kommis = 0.
     find last txb.lons where txb.lons.lon = txb.lon.lon no-lock no-error.
     if avail txb.lons then v-kommis = txb.lons.amt.

     assign v-bal16 = 0 v-bal9 = 0 v-bal7 = 0 v-bal4 = 0 v-bal5 = 0.

     /* остаток долга */
     run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7",yes,txb.lon.crc,output bilance).
     find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= d1 no-lock.
     if not avail txb.crchis then do:
       message " Не найдена запись в истории курсов валют, cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box buttons ok.
       return.
     end.

     bilance = bilance * txb.crchis.rate[1].
     /* остаток на 7 ур за дату */
     if d1 > 03/01/2004 then run lonbalcrc_txb('lon',txb.lon.lon,d1,"7",yes,txb.lon.crc,output v-bal7).
     else run lon_txb1 (txb.lon.lon, d1, 2, output v-bal7).

     /* 20.04.2004 nadejda */
     /*
     v-day7 = 0.
     if v-bal7 > 0 then do:
        tempdt = d1.
        tempost = 0.
        repeat:
          find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.stdat <= tempdt and txb.lnsch.f0 > 0 no-lock no-error.
          do while avail txb.lnsch and txb.lnsch.stval = 0:
            find prev txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.stdat <= tempdt and txb.lnsch.f0 > 0 no-lock no-error.
          end.
          if avail txb.lnsch then do:
             tempost = tempost + txb.lnsch.stval.
             if v-bal7 <= tempost then do:
                v-day7 = d1 - txb.lnsch.stdat.
                leave.
             end.
             tempdt = txb.lnsch.stdat - 1.
          end.
          else leave.
        end.
     end.
     */
     v-bal7 = v-bal7 * txb.crchis.rate[1].

     find last txb.hislon where txb.hislon.lon = txb.lon.lon and txb.hislon.fdt <= d1 no-lock no-error.
     if avail txb.hislon then assign v-bal9 = (txb.hislon.tdam[2] - txb.hislon.tcam[2]).

      /* 20.04.2004 nadejda */
      /*
      v-day9 = 0.
      if v-bal9 > 0 then do:
        tempdt = d1.
        tempost = 0.
        repeat:
          find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat <= tempdt and txb.lnsci.f0 > 0 no-lock no-error.
          do while avail txb.lnsci and txb.lnsci.iv-sc = 0:
            find prev txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat <= tempdt and txb.lnsci.f0 > 0 no-lock no-error.
          end.

          if avail txb.lnsci then do:
             tempost = tempost + txb.lnsci.iv-sc.
             if v-bal9 <= tempost then do:
                v-day9 = d1 - txb.lnsci.idat.
                leave.
             end.
             tempdt = txb.lnsci.idat - 1.
          end.
          else leave.
        end.
      end.
      */

     run lonbalcrc_txb('lon',txb.lon.lon,d1,"4,5,16",yes,txb.lon.crc,output v-ost).

      v-day7 = 0. v-day9 = 0.
      run lndayspr_txb(txb.lon.lon,d1,yes,output v-day7,output v-day9).

      v-bal9 = v-bal9 * txb.crchis.rate[1].

      find last txb.hislon where txb.hislon.lon = txb.lon.lon and txb.hislon.fdt <= d1 no-lock no-error.
          if avail txb.hislon then
                assign v-bal16 = txb.hislon.tdam[3] - txb.hislon.tcam[3].

      if  v-bal7 > 0 or v-bal9 > 0 or v-bal16 > 0 or v-ost > 0 then do:

          run lonbalcrc_txb('lon',txb.lon.lon,d1,"4",yes,txb.lon.crc,output v-bal4).
          run lonbalcrc_txb('lon',txb.lon.lon,d1,"5",yes,1,output v-bal5).

          /* 08/06/2004 madiar - фактически сформированные провизии и статус кредита */
          run lonbalcrc_txb('lon',txb.lon.lon,d1,"3,6",yes,txb.lon.crc,output v-prov).
          v-prov = - v-prov.
          if txb.lon.crc <> 1 then v-prov = v-prov * txb.crchis.rate[1].

          find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= d1 use-index lonhar-idx1 no-lock no-error.
          if avail txb.lonhar then do:
             find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
             if avail txb.lonstat then v-sts = txb.lonstat.prc.
             else message " Запись lonstat не найдена! " view-as alert-box buttons ok.
          end.
          /*************/

          find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.

          mddt = txb.lon.duedt.
          if txb.lon.ddt[5] <> ? /* and txb.lon.ddt[5] < dat */ then mddt = txb.lon.ddt[5].
          if txb.lon.cdt[5] <> ? /* and txb.lon.cdt[5] < dat */ then mddt = txb.lon.cdt[5].

          create wrk.
          if lookup(trim(string(txb.lon.grp)),lst_ur) > 0 then wrk.urfiz = '0'. else wrk.urfiz = '1'.
          assign wrk.bank = txb.cmp.name
                 wrk.name = txb.cif.name
                 wrk.cif = txb.lon.cif
                 wrk.lon = txb.lon.lon
                 wrk.grp = txb.lon.grp
                 wrk.crc = txb.lon.crc
                 wrk.opnamt = txb.lon.opnamt
                 wrk.rdt = txb.lon.rdt
                 wrk.duedt = mddt
                 wrk.balance = bilance
                 wrk.od_prosr = v-bal7
                 wrk.od_days = v-day7
                 wrk.proc_prosr = v-bal9
                 wrk.proc_days = v-day9
                 wrk.proc_zabal = v-bal4
                 wrk.shtraf = v-bal16
                 wrk.shtraf_zabal = v-bal5
                 wrk.crstatus = v-sts
                 wrk.prov = v-prov
                 wrk.kommis = v-kommis.
                 find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
                 if avail txb.sub-cod then do:
                     find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                     if avail txb.codfr then wrk.sec_econ = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
                 end.
                 else wrk.sec_econ = "НЕ ПРОСТАВЛЕНА".

                 find last txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.lonsec = 2 no-lock no-error.
                 if available txb.lonsec1 then wrk.ob_cred = "02".
                 else do:
                    find last txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock no-error.
                    if available txb.lonsec1 then do:
                        if txb.lonsec1.lonsec = 1 then wrk.ob_cred = "01".
                        if txb.lonsec1.lonsec = 2 then wrk.ob_cred = "02".
                        if txb.lonsec1.lonsec = 3 then wrk.ob_cred = "03".
                        if txb.lonsec1.lonsec = 5 then wrk.ob_cred = "05".
                        if txb.lonsec1.lonsec = 4 then wrk.ob_cred = "04".
                        if txb.lonsec1.lonsec = 6 then wrk.ob_cred = "06".
                    end.
                    else wrk.ob_cred = "04".
                 end.
      end.
end. /* for each lon */

