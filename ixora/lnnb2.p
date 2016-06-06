/* lnnb2.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Отчет по кредитному портфелю с разбивкой по срокам до погашения
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        09/08/2006 madiyar
 * BASES
        bank, comm, txb
 * CHANGES
        21/01/2008 madiyar - добавил суммы по начисленному вознаграждению
        07/02/2008 madiyar - выбор: по срокам до погашения или по первоначальным срокам кредитов
        08/02/2008 madiyar - добавил суммы по просроченному начисленному вознаграждению
        20/02/2008 madiyar - добавил суммы по просроченному ОД
        12/03/2008 madiyar - добавил таблицу по просрочкам
        21/07/2008 madiyar - изменения в сроках
        29/08/2008 madiyar - евро 11 -> 3
        05/09/2008 madiyar - явно указал индекс lonhar-idx1 при поиске последней записи lonhar
        03/04/2009 madiyar - провизии теперь могут быть и в валюте
        05/08/2010 madiyar - подправил определение статуса по классификации
        01/02/2011 madiyar - подправил расчет провизий
        01/11/2012 kapar - ТЗ №1566,№1143
        05/12/2012 sayat - ТЗ 1605 добавление в отчет счета 140320
        05.02.2013 dmitriy - ТЗ 1701 включение счетов 910011, 910012 при расчете провизий в тенге
        28.03.2013 dmitriy - ТЗ 1781 проверка на наличие остатков по счетам 9 класса
        22.07.2013 dmitriy - ТЗ 1971
        01.08.2013 dmitriy - ТЗ 2000
*/

def shared var g-today as date.

def input parameter v-sel as char no-undo.
def input parameter dt as date no-undo.

define shared temp-table wrk no-undo
  field des as char
  field sroks as integer
  field srokf as integer
  field sts as deci
  field sum as deci extent 3
  field sum_pod as deci extent 3
  field sum_nprc as deci extent 3
  field sum_pprc as deci extent 3
  index idx is primary sroks sts
  index idx2 sroks srokf sts.

define shared temp-table wrkprov no-undo
  field sroks as integer
  field sum as deci extent 3
  field sum41 as deci extent 3
  index idx is primary sroks.

define shared temp-table wrkpr no-undo
  field sroks as int
  field srokf as int
  field sts as deci
  field sum_pod as deci extent 3
  field sum_pprc as deci extent 3
  index idx is primary sroks sts.

def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal49 as deci no-undo.
def var v-bal50 as deci no-undo.
def var v-duedt as date no-undo.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.
def var v-sts as deci no-undo.
def var v-prov as deci no-undo.
def var v-prov1 as deci no-undo.
def var v-bal as deci no-undo.

def var v-prov41 as deci no-undo.
def var v-prov37 as deci no-undo.
def var dt41 as date.

def var daysod as integer no-undo.
def var daysprc as integer no-undo.
def var daysmax as integer no-undo.

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
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"2",yes,txb.lon.crc,output v-bal2).
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"9",yes,txb.lon.crc,output v-bal9).
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"49",yes,txb.lon.crc,output v-bal49).
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"50",yes,txb.lon.crc,output v-bal50).
  run lonbal_txb('lon',txb.lon.lon,dt,"6,36,37",yes,output v-prov).
  v-prov = - v-prov.

  if dt = 01/31/13 then dt41 = 02/01/13. else dt41 = dt.
  run lonbalcrc_txb('lon',txb.lon.lon,dt41,"41",yes,txb.lon.crc,output v-prov41).
  v-prov41 = - v-prov41.

  if v-bal1 + v-bal7 + v-bal2 + v-bal9 + v-prov + v-prov41 <= 0 then next.

  run lonbalcrc_txb('lon',txb.lon.lon,dt,"6,36",yes,txb.lon.crc,output v-bal).
  v-prov = - v-bal * rates[txb.lon.crc].
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"37",yes,1,output v-prov37).
  v-prov37 =  - v-prov37 .

  v-duedt = txb.lon.duedt.
  if txb.lon.ddt[5] <> ? then v-duedt = txb.lon.ddt[5].
  if txb.lon.cdt[5] <> ? then v-duedt = txb.lon.cdt[5].

  if v-sel = '1' then do:
      if v-duedt <= g-today then dn1 = 0.
      else run day-360(g-today,v-duedt - 1,txb.lon.basedy,output dn1,output dn2).
  end.
  else if v-sel = '2' then run day-360(txb.lon.rdt,v-duedt - 1,txb.lon.basedy,output dn1,output dn2).

  find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= dt use-index lonhar-idx1 no-lock no-error.
  if avail txb.lonhar then do:
    find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    if avail txb.lonstat then v-sts = txb.lonstat.prc.
    else do:
      message "Не найден lonstat, " + txb.lon.cif + ' ' + txb.lon.lon + ", lonstat.lonstat=" + string(txb.lonhar.lonstat) view-as alert-box error.
      next.
    end.
  end.
  else do:
    message "Не найден lonhar, " + txb.lon.cif + ' ' + txb.lon.lon view-as alert-box error.
    next.
  end.

  if dn1 = 0 then dn1 = 1. /* чтобы кредиты, закрывающиеся сегодня, попали в первую группу */
  find first wrk where wrk.sroks < dn1 and wrk.srokf >= dn1 and wrk.sts = v-sts no-error.
  if avail wrk then do:
      find first wrkprov where wrkprov.sroks = wrk.sroks no-error.
      assign wrk.sum[txb.lon.crc] = wrk.sum[txb.lon.crc] + v-bal1 * rates[txb.lon.crc]
             wrk.sum_pod[txb.lon.crc] = wrk.sum_pod[txb.lon.crc] + v-bal7 * rates[txb.lon.crc]
             wrk.sum_nprc[txb.lon.crc] = wrk.sum_nprc[txb.lon.crc] + (v-bal2 + v-bal49) * rates[txb.lon.crc]
             wrk.sum_pprc[txb.lon.crc] = wrk.sum_pprc[txb.lon.crc] + (v-bal9 + v-bal50) * rates[txb.lon.crc]
             wrkprov.sum[txb.lon.crc] = wrkprov.sum[txb.lon.crc] + v-prov
             wrkprov.sum[1] = wrkprov.sum[1] + v-prov37
             wrkprov.sum41[txb.lon.crc] = wrkprov.sum41[txb.lon.crc] + (v-prov41 * rates[txb.lon.crc]).
  end.
  else message "Кредиты по срокам - нет статуса по классификации " + string(v-sts) + " " + string(dn1) view-as alert-box error.

  if v-bal7 + v-bal9 > 0 then do:
      daysmax = 0. daysod = 0. daysprc = 0.
      run lndayspr_txb(txb.lon.lon,dt + 1,no,output daysod,output daysprc).
      if daysod > daysprc then daysmax = daysod. else daysmax = daysprc.

      if daysmax = 0 or daysmax > 1000000 then message " daysmax = " + string(daysmax) + " " + txb.lon.cif + ' ' + txb.lon.lon view-as alert-box error.


      find first wrkpr where wrkpr.sroks <= daysmax and wrkpr.srokf >= daysmax and wrkpr.sts = v-sts no-error.
      if avail wrkpr then do:
          assign wrkpr.sum_pod[txb.lon.crc] = wrkpr.sum_pod[txb.lon.crc] + v-bal7 * rates[txb.lon.crc]
                 wrkpr.sum_pprc[txb.lon.crc] = wrkpr.sum_pprc[txb.lon.crc] + v-bal9 * rates[txb.lon.crc].
      end.
      else message "Просрочки - нет статуса по классификации " + string(v-sts) + " " + string(daysmax) view-as alert-box error.
  end.

end. /* for each txb.lon */

/*sayat 05/12/2012 begin*/
for each txb.arp where txb.arp.gl = 140320 no-lock:
    run lonbalcrc_txb('arp',txb.arp.arp,dt,"1",yes,txb.arp.crc,output v-bal1).
    find first wrk where wrk.sroks = 7 and wrk.srokf = 30 and wrk.sts = 0 no-error.
    assign wrk.sum[txb.arp.crc] = wrk.sum[txb.arp.crc] + v-bal1 * rates[txb.arp.crc].
end.
/*sayat 05/12/2012 end*/
