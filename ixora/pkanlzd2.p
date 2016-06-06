/* pkanlzd2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Анализ портфеля потреб. кредитов в динамике
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
        19/08/2004 madiar
 * CHANGES
        31/08/2004 madiyar - поменял кодировку на koi8
        06/09/2004 madiyar - исправил ошибку в расчете дней просрочки
        05/10/2004 madiyar - в связи с изменением lonbal_txb изменил значение параметра при вызове
        06/10/2004 madiyar - кредиты БД - проверяется наличие анкеты
        02/11/2004 madiyar - подправил расчет просрочки
        24/07/2006 madiyar - добавил колонку "Начисленные и не погашенные проценты"
        26/07/2006 madiyar - отчет немного скривился, подправил
        11/08/2006 madiyar - выданные за период
        22/09/2006 madiyar - добавил ответственного менеджера
        16/04/2007 madiyar - разбивка на программы МКО, расчет дней просрочки привел в соответствие с алгоритмами в других отчетах
        05/09/2008 madiyar - явно указал индекс lonhar-idx1 при поиске последней записи lonhar
        28/11/2008 galina - данные с разбивкой по программам берем из хранилища 
        30/12/2008 galina - переделала для формирования push-отчета
        04.06.2009 galina - находим курс валюты crchis по полю rdt
        
*/

def shared var g-today as date.
def shared var krport as deci no-undo extent 2.
def shared var dates as date no-undo extent 5.

define var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def shared temp-table wrkmain no-undo
  field datot       as   date
  field segm        as   char
  field bank        as   char
  field cif         like txb.lon.cif
  field klname      as   char
  field lon         like txb.lon.lon
  field grp         as   int
  field crc         like txb.lon.crc
  field opnamt      as   deci
  field sumvyd      as   deci
  field sumvyd_crc  as   deci /*выданная сумма в валюте кредита*/
  field ostatok     as   deci
  field ostatok_kzt as   deci
  field prosr_od    as   deci
  field prc         as   deci
  field prosr_prc   as   deci
  field pred_prc    as   deci
  field bal_acc     as   deci
  field prosr_day   as   integer
  field prem        as   deci
  field rdt         as   date
  field lastpaid_dt as   date
  field nextpog_dt  as   date
  field duedt       as   date
  field obesp_name  as   char
  field obesp_sum   as   deci
  field obesp_crc   like txb.lon.crc
  field rezervprc   as   deci
  field rezerv_form as   deci
  field srok        as   deci
  field ofc         as   char /* ответственный менеджер */
  index ind is primary datot segm bank.

def shared temp-table wrkobesp no-undo
  field cif         like txb.lon.cif
  field lon         like txb.lon.lon
  field obesp_name  as   char
  field obesp_sum   as   deci
  field obesp_crc   like txb.lon.crc
  index indo is primary cif lon.

def shared temp-table wrkvyd no-undo
    field datot like txb.lon.rdt
    field segm as char
    field name as char
    field sum as deci
    field sum_crc as deci
    field crc as char
    field kol as integer
    index main is primary segm datot.

def var bdat as date no-undo.
def var counter as integer no-undo init 1.
def var bilance as decimal no-undo.
def var v-segm as char no-undo.
def var v-output as deci no-undo.
def var first_obesp as logi no-undo.

def var dayc1 as inte no-undo.
def var dayc2 as inte no-undo.
def var dat_wrk as date no-undo.

find first txb.cmp no-lock no-error.

do counter = 1 to 5:
  
  bdat = dates[counter].
  
  dat_wrk = bdat - 1.
  find last txb.cls where txb.cls.whn < bdat and txb.cls.del no-lock no-error. /* последний рабочий день перед bdat */
  if avail txb.cls then dat_wrk = txb.cls.whn.
  
  for each txb.lon no-lock:
    
    run lonbalcrc_txb('lon', txb.lon.lon, bdat, "1,7", no, txb.lon.crc, output bilance).
    if bilance <= 0 then do:
      find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 and txb.lnscg.stdat < bdat no-lock no-error.
      if not avail txb.lnscg then next.
    end.
    if counter = 1 then do:
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < bdat no-lock no-error.
      krport[1] = krport[1] + bilance * txb.crchis.rate[1].
      if bilance > 0 then krport[2] = krport[2] + 1.
    end.
    
    find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnsegm' no-lock no-error.
    if avail txb.sub-cod then do:
        v-segm = txb.sub-cod.ccode.
        if v-segm = '07' then next. /* пропускаем кредиты юр.лиц */
        if v-segm = '01' or v-segm = '02' or v-segm = '03' then do:
            find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
            if not avail pkanketa then next. /* если анкета отсутствует, то пропускаем */
        end.
    end.
    else do:
        message " Не указан сегмент кредита, клиент " + txb.lon.cif + ", сс.счет " + txb.lon.lon view-as alert-box buttons ok title " Ошибка! ".
        next.
    end.
    
    if counter < 5 then do:
        find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
        if avail txb.lnscg and txb.lnscg.stdat >= dates[counter + 1] then do:
          find first txb.crc where txb.crc.crc =  txb.lon.crc no-lock no-error.
          find first wrkvyd where wrkvyd.crc = txb.crc.code and wrkvyd.datot = dates[counter] and wrkvyd.segm = v-segm no-lock no-error.
          if not avail wrkvyd then do:
            create wrkvyd.
            wrkvyd.datot = dates[counter].
            wrkvyd.segm = v-segm.
            wrkvyd.crc = txb.crc.code.
            find first txb.codfr where txb.codfr.codfr = "lnsegm" and txb.codfr.code = v-segm no-lock no-error.
            if avail txb.codfr then wrkvyd.name = txb.codfr.name[1].
          end.
          wrkvyd.kol = wrkvyd.kol + 1.
          for each txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 and txb.lnscg.stdat >= dates[counter + 1] and txb.lnscg.stdat < dates[counter] no-lock:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= txb.lnscg.stdat no-lock no-error.
            wrkvyd.sum_crc = wrkvyd.sum_crc + txb.lnscg.paid.
            wrkvyd.sum = wrkvyd.sum + txb.lnscg.paid * txb.crchis.rate[1].
          end.
        end.
        
    end.
    
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < bdat no-lock no-error.
    
    find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    
    create wrkmain.
    assign wrkmain.datot = bdat
           wrkmain.segm = v-segm
           wrkmain.bank = txb.cmp.name
           wrkmain.cif = txb.lon.cif.
    if avail txb.cif then wrkmain.klname = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
    else wrkmain.klname = "NOT FOUND".
    assign wrkmain.lon = txb.lon.lon
           wrkmain.grp = txb.lon.grp
           wrkmain.crc = txb.lon.crc
           wrkmain.opnamt = txb.lon.opnamt
           wrkmain.ostatok = bilance
           wrkmain.ostatok_kzt = bilance * txb.crchis.rate[1]
           wrkmain.prem = txb.lon.prem
           wrkmain.rdt = txb.lon.rdt.
    if avail txb.loncon then wrkmain.ofc = txb.loncon.pase-pier.

    for each txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 and txb.lnscg.stdat < dates[counter] no-lock:
            wrkmain.sumvyd_crc = wrkmain.sumvyd_crc + txb.lnscg.paid. 
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= txb.lnscg.stdat no-lock no-error.
            wrkmain.sumvyd = wrkmain.sumvyd + txb.lnscg.paid * txb.crchis.rate[1].
    end.
    
    /* просрочка ОД */
    run lonbalcrc_txb('lon',txb.lon.lon,bdat,"7",no,txb.lon.crc,output v-output).
    wrkmain.prosr_od = v-output.
    /* начисл. и не погаш. %% */
    run lonbalcrc_txb('lon',txb.lon.lon,bdat,"2,9",no,txb.lon.crc,output v-output).
    wrkmain.prc = v-output.
    /* просрочка %% */
    run lonbalcrc_txb('lon',txb.lon.lon,bdat,"9",no,txb.lon.crc,output v-output).
    wrkmain.prosr_prc = v-output.
    /* предоплата %% */
    run lonbalcrc_txb('lon',txb.lon.lon,bdat,"10",no,txb.lon.crc,output v-output).
    wrkmain.pred_prc = - v-output.
    /* остаток на тек. счете */
    find first txb.aaa where txb.aaa.aaa = txb.lon.aaa no-lock no-error.
    if avail txb.aaa then do:
      run lonbalcrc_txb('cif',txb.aaa.aaa,bdat,"1",no,txb.lon.crc,output v-output).
      wrkmain.bal_acc = - v-output.
    end.
    /* дней просрочки */
    dayc1 = 0. dayc2 = 0.
    run lndayspr_txb(txb.lon.lon,bdat,no,output dayc1,output dayc2).
    
    if dayc1 > dayc2 then wrkmain.prosr_day = dayc1. else wrkmain.prosr_day = dayc2.
    /* дата последней проплаты */
    find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp > 0 and txb.lnsch.fpn = 0 and txb.lnsch.f0 = 0
                              and txb.lnsch.stdat < bdat no-lock no-error.
    if avail txb.lnsch then wrkmain.lastpaid_dt = txb.lnsch.stdat.
    find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp > 0 and txb.lnsci.fpn = 0 and txb.lnsci.f0 = 0
                              and txb.lnsci.idat < bdat no-lock no-error.
    if avail txb.lnsci then if txb.lnsci.idat > wrkmain.lastpaid_dt then wrkmain.lastpaid_dt = txb.lnsci.idat.
    /* дата следующего погашения по графику */
    find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0 and txb.lnsch.fpn = 0 and txb.lnsch.f0 > 0
                               and txb.lnsch.stdat >= bdat no-lock no-error.
    if avail txb.lnsch then wrkmain.nextpog_dt = txb.lnsch.stdat.
    find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0 and txb.lnsci.fpn = 0 and txb.lnsci.f0 > 0
                               and txb.lnsci.idat >= bdat no-lock no-error.
    if avail txb.lnsci then if txb.lnsci.idat < wrkmain.nextpog_dt then wrkmain.nextpog_dt = txb.lnsci.idat.
    /* дата погашения кредита */
    wrkmain.duedt = txb.lon.duedt.
    if txb.lon.ddt[5] <> ? /* and txb.lon.ddt[5] < dat */ then wrkmain.duedt = txb.lon.ddt[5].
    if txb.lon.cdt[5] <> ? /* and txb.lon.cdt[5] < dat */ then wrkmain.duedt = txb.lon.cdt[5].
    /* обеспечение */
    if counter = 1 then do:
      first_obesp = true.
      for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
        if first_obesp then do:
          wrkmain.obesp_name = entry(1,txb.lonsec1.prm,'&').
          wrkmain.obesp_sum = txb.lonsec1.secamt.
          wrkmain.obesp_crc = txb.lonsec1.crc.
          first_obesp = false.
        end.
        else do:
          create wrkobesp.
          wrkobesp.cif = txb.cif.cif.
          wrkobesp.lon = txb.lon.lon.
          wrkobesp.obesp_name = entry(1,txb.lonsec1.prm,'&').
          wrkobesp.obesp_sum = txb.lonsec1.secamt.
          wrkobesp.obesp_crc = txb.lonsec1.crc.
        end.
      end. /* for each txb.lonsec1 */
    end.
    /* провизии */
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < bdat use-index lonhar-idx1 no-lock no-error.
    find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    if avail txb.lonstat then wrkmain.rezervprc = txb.lonstat.prc.
    run lonbalcrc_txb('lon',txb.lon.lon,bdat,"3,6",no,1,output v-output).
    wrkmain.rezerv_form = - v-output.
    
  end. /* for each txb.lon */

end. /* do counter */
