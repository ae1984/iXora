/* kredmon1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Задолжники по кредитам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r_krmon r-branch.i
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        4-4-3-8
 * AUTHOR
        01/04/03 marinav
 * CHANGES
        26.08.2003 marinav Изменен расчет задолженности
        30.09.2003 marinav Расчет суммы просрочки при окончании пролонгации
        29.12.2003 marinav Поправка расчета кол-ва дней просрочки
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        25/05/2004 madiyar - добавил входной параметр wh_fu - отчет по физ. или юр. лицам
                             В отчете по юр. лицам добавились колонки (телефоны, остатки на счетах)
        16/06/2004 madiyar - добавил индекс и поле bank в wrk
        27/07/2004 madiyar - Неправильно считалась просрочка по БД и БК
        28/07/2004 madiyar - Выдаем в отчет кредиты с суммами на уровнях просрочек > 0.01
        29/07/2004 madiyar - Кардинальная переделка отчета. Формируется только на сегодня
        30/07/2004 madiyar - Исправление ошибок
        10/08/2004 madiyar - При попадании дня погашения на предыдущие выходные - берутся нач. и проср. проценты на этот день
        12/08/2004 madiyar - Теперь не выводятся кредиты по БД и БК даже если отчет по физ. лицам - есть свои отчеты
        31/08/2004 madiyar - Исправил расчет просроченных процентов
        01/09/2004 madiyar - Еще раз исправил расчет просроченных процентов
        06/09/2004 madiyar - --||--
        28/09/2004 madiyar - Исправил ошибку - в паре мест не была указана база txb
        12.11.2004 saltanat - Добавила 2 поля: "Наличие блокировки счетов", "Номер ссудного счета".
        17/11/2004 madiyar,saltanat - Добавили поле aassum - заблокированная сумма, исправили ошибки в формате отчета
        09/12/2004 madiyar - Добавил поле bal16 - для штрафов
        13/01/2005 madiyar - Исправил небольшую проблему со штрафами
        20/01/2005 madiyar - Деление на физ/юр происходит по группам кредитов
        21/02/2005 madiyar - Добавил список тек счетов клиента
        23/02/2005 madiyar - Исправил небольшую ошибку, список тек счетов клиента - только KZT
        01/03/2005 madiyar - По КИК-кредитам - выдавался нулевой просроченный ОД, исправил
        04/03/2005 madiyar - прошлый раз исправил неправильно, исправил еще раз
        08/04/2005 madiyar - Для физ.лиц добавил список тек счетов клиента в валюте кредита и остатки по ним
        18/04/2005 madiyar - Выводится сумма спец.инструкций только кредитного департамента
        19/04/2005 madiyar - Буковка в aas.delaas для кредитного департамента не 'd', а 'k'
                            Расчет дней просрочки %% - без учета %%, начисленных на просроченный ОД
        28/04/2005 madiyar - нормальный учет пролонгации
        13/05/2005 madiyar - даже если кредит пролонгирован, но есть штрафы - показываем
        07/06/2005 madiyar - Добавил индексированный ОД и %%
        25/07/2005 sasco   - убрал все message из-за того, что этот пункт используется в PUSH-отчетах (p_kredmon*.p, PUSH_ps.p)
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        01/11/2005 madiyar - Добавил внебаланс
        02/11/2005 madiyar - Списанные кредиты отсеивались, исправил
        21/11/2005 madiyar - добавил поле wrk.respman
        01/03/2006 madiyar - убрал из отчета схему 5, изменил расчет просрочки
        15/02/2006 Natalya D. - добавлены 2 поля: Начисленные % за балансом и Начисленные штрафы за балансом
        05.04.2006 sasco  - добавил no-undo и закомментировал непонятную таблицу w-amk
        03/07/2006 u00121 - добавил индекс idx1-wrk в таблицу wrk
        10/07/2006 Natalya D. - добавила поля "Комиссия за неисполь.кред.линию" "7МРП" "Комис-я бизнес-кредит"
        17/07/2006 Natalya D. - исправила расчет комиссии по бизнес кредиту.
        14/08/2006 marinav - в отчет добавлены кредиты у которых наступил срок платежа "Комиссия за неисполь.кред.линию" "7МРП" "Комис-я бизнес-кредит"
        21/08/2006 marinav - добавила use-index lncodedt для мониторингов
        28/05/2007 madiyar - оптимизация
        24/09/2010 galina - не учитываем текущий день в колличестве дней просрочки
        10/08/2011 dmitriy - добавил поле kommis в wrk
        22/08/2011 dmitriy - обнулил переменную v-kommis
*/

/**********************************************************************************/
/*  При изменении  shared temp-table wrk  в данной программе, не забудьте внести  */
/*  соответствующие изменения как в kredmon.p, так и в p_kredmon.p (пуш-отчет)    */
/**********************************************************************************/

def var s-bank as char no-undo.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
/*  message " Нет записи OURBNK в таблице sysc !!".
  pause. */
  return.
end.
else s-bank = txb.sysc.chval.

def input parameter datums as date.
def input parameter wh_fu as char.
def shared var g-today as date.
def var dayc1 as int init 0 no-undo.
def var dayc2 as int init 0 no-undo.
def new shared var bilance as decimal format '->,>>>,>>>,>>9.99' no-undo.
define variable bilancepl as decimal format '->,>>>,>>9.99' no-undo.
define variable bil1 as decimal format '->,>>>,>>9.99' no-undo.
define variable bil2 as decimal format '->,>>>,>>9.99' no-undo.
define variable sumbil as decimal format '->,>>>,>>9.99' no-undo.
def var vcu like txb.lon.opnamt extent 6 decimals 2 no-undo.
define variable f-dat1     as date no-undo.
def var tempdt  as date no-undo.
def var tempost as deci no-undo.
def var dlong as date no-undo.
def var b1 as deci no-undo.
def var b2 as deci no-undo.
def var b11 as deci no-undo.
def var mbal as deci no-undo.
def var mname as char no-undo.
def var mphones as char no-undo.
def var mfu as char no-undo.
def var prosr_od as deci no-undo.
def var blsum as deci no-undo.

/* группы кредитов юридических лиц */
def var lst_ur as char init '' no-undo.
for each txb.longrp no-lock:
  if substr(string(txb.longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(txb.longrp.longrp).
  end.
end.

def shared temp-table wrk no-undo
    field lon    like txb.lon.lon
    field cif    like txb.lon.cif
    field name   like txb.cif.name
    field bank   as   char
    field phones as   char
    field fu     as   char
    field rdt    like txb.lon.rdt
    field duedt  like txb.lon.rdt
    field opnamt like txb.lon.opnamt
    field balans like txb.lon.opnamt
    field crc    like txb.lon.crc
    field prem   like txb.lon.prem
    field bal1   like txb.lon.opnamt
    field dt1    as   inte
    field bal2   like txb.lon.opnamt
    field dt2    as   inte
    field bal3   like txb.lon.opnamt
    field accs   as   char
    field balkzt as   deci
    field balusd as   deci
    field baleur as   deci
    field bal16  as   deci
    field bal13  as   deci
    field bal4   as   deci
    field bal14  as   deci
    field bal5   as   deci
    field bal30  as   deci
    field bal25  as   deci
    field mrp7   as   deci
    field buscr  as   deci
    field iod    as   deci
    field iprc   as   deci
    field aasbl  as   char
    field aassum as   deci
    field is-kik as   logi
    field is-today as logi
    field respman  as char
    field kommis   as   deci
    index ind1 is-kik bank crc bal3
    index ind2 is-today bank crc bal3
    index idx1-wrk bank crc.

def var v-am0 as decimal init 0 no-undo.
def var v-am1 as decimal init 0 no-undo.
def var v-am2 as decimal init 0 no-undo.
def var v-am3 as decimal init 0 no-undo.
def var v-am5 as decimal init 0 no-undo.
def var v-am16 as decimal init 0 no-undo.
def var v-am13 as decimal init 0 no-undo.
def var v-am14 as decimal init 0 no-undo.
def var v-am30 as decimal init 0 no-undo.
def var v-amt4 as decimal init 0 no-undo.
def var v-amt5 as decimal init 0 no-undo.
def var v-amt25 as decimal init 0 no-undo.
def var v-amt20 as decimal init 0 no-undo.
def var v-amt22 as decimal init 0 no-undo.
def var v-mrp7 as decimal init 0 no-undo.
def var v-buscr as decimal init 0 no-undo.
def var dat_wrk as date no-undo.
def var is-pogtoday as logi no-undo.
def var v-accs as char no-undo.

def var dn1 as integer no-undo.
def var dn2 as deci no-undo.

def var v-kommis as deci no-undo.

find last txb.cls where txb.cls.whn < datums and txb.cls.del = true no-lock no-error.
dat_wrk = txb.cls.whn.

def shared var mesa as int.

for each txb.lon where txb.lon.sts <> 'C' no-lock.

     v-kommis = 0.
     find first txb.lons where txb.lons.lon = txb.lon.lon no-lock no-error.
     if avail txb.lons then v-kommis = txb.lons.amt.

     if txb.lon.dam[1] = 0 then next.

     /* Для ускорения формирования отчета по юр. лицам - пропускаем все кредиты с 3-ей и 4-ой схемами */
     if wh_fu = '0' then if txb.lon.plan = 4 or txb.lon.plan = 5 then next.

     /* Не выводить кредиты по БД и БК даже если отчет по физ. лицам - есть свои отчеты */
     if txb.lon.grp = 90 or txb.lon.grp = 92 then next.

     /* 25/05/04 madiyar - для вывода отчета только по физ. или юр. лицам */
     if wh_fu = '0' and lookup(trim(string(txb.lon.grp)),lst_ur) = 0 then next.
     else
     if wh_fu = '1' and lookup(trim(string(txb.lon.grp)),lst_ur) > 0 then next.

     v-am16 = 0.
     run lonbalcrc_txb('lon',txb.lon.lon,datums,"16",yes,1,output v-am16).

     dlong = txb.lon.duedt.
     if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
     if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].

     if dlong > txb.lon.duedt and dlong > datums and v-am16 <= 0 then next. /* если есть пролонгация, дата пролонгации еще впереди и нет штрафов - пропускаем */

     is-pogtoday = no.

     find last txb.cif where txb.cif.cif = txb.lon.cif no-lock.
     mname = trim(txb.cif.prefix) + " " + txb.cif.name.
     mphones = txb.cif.tel.
     mfu = wh_fu.

     /* 25/05/04 madiyar end */

     v-am0 = 0. v-am1 = 0. v-am2 = 0. v-am3 = 0. prosr_od = 0.
     /* просрочка % */
     find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0
         and txb.lnsci.fpn = 0 and txb.lnsci.f0 > 0 and txb.lnsci.idat > dat_wrk and txb.lnsci.idat <= datums no-lock no-error.

     if avail txb.lnsci then do:
       is-pogtoday = yes.
       run lonbalcrc_txb('lon',txb.lon.lon,g-today,"9,10",yes,txb.lon.crc,output v-am1).
       v-am0 = v-am1.
       run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2",yes,txb.lon.crc,output v-am0).
       v-am0 = v-am0 + v-am1.
       if (txb.lnsci.idat <> datums) and (txb.lon.plan <> 4 and txb.lon.plan <> 5) then do:
         run lonbalcrc_txb('lon',txb.lon.lon,txb.lnsci.idat,"1,7",yes,txb.lon.crc,output bilance).
         run day-360(txb.lnsci.idat,datums - 1,txb.lon.basedy,output dn1,output dn2).
         v-am0 = v-am0 - dn1 * bilance * txb.lon.prem / txb.lon.basedy / 100.
         if v-am0 < 0 then v-am0 = 0.
       end.
     end.
     else do:
       run lonbalcrc_txb('lon',txb.lon.lon,g-today,"9,10",yes,txb.lon.crc,output v-am1).
       v-am0 = v-am1.
     end.

     /* просрочка ОД */

     run lonbalcrc_txb('lon',txb.lon.lon,datums,"1,7",yes,txb.lon.crc,output bilance). /* фактич остаток ОД */

     bilancepl = 0.   /* За тек день по графику погашения (ВКЛЮЧАЯ сегодня!) */
     for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0
         and txb.lnsch.fpn = 0 and txb.lnsch.f0 > 0 and txb.lnsch.stdat <= datums no-lock:
        bilancepl = bilancepl + txb.lnsch.stval.
     end.

     v-am2 = txb.lon.opnamt - bilancepl. /* остаток долга по графику */
     if v-am2 < 0 then v-am2 = 0.
     v-am3 = bilance - v-am2. /* просрочка ОД */
     if v-am3 < 0 then v-am3 = 0.

     /* чистая просрочка (уровень 7) - для расчета дней просрочки */
     run lonbalcrc_txb('lon',txb.lon.lon,g-today,"7",yes,txb.lon.crc,output prosr_od). /* фактич остаток ОД */

     find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.flp = 0 and txb.lnsch.fpn = 0 and txb.lnsch.f0 > 0
                                and txb.lnsch.stdat > dat_wrk and txb.lnsch.stdat <= datums no-lock no-error.
     if not avail txb.lnsch then v-am3 = prosr_od.
     else is-pogtoday = yes.

     run lonbalcrc_txb('lon',txb.lon.lon,datums,"13",yes,txb.lon.crc,output v-am13).
     run lonbalcrc_txb('lon',txb.lon.lon,datums,"4",yes,txb.lon.crc,output v-amt4).
     run lonbalcrc_txb('lon',txb.lon.lon,datums,"14",yes,txb.lon.crc,output v-am14).
     run lonbalcrc_txb('lon',txb.lon.lon,datums,"5",yes,1,output v-amt5).
     run lonbalcrc_txb('lon',txb.lon.lon,datums,"30",yes,1,output v-am30).
     run lonbalcrc_txb('lon',txb.lon.lon,datums,"20",yes,txb.lon.crc,output v-amt20).
     run lonbalcrc_txb('lon',txb.lon.lon,datums,"22",yes,txb.lon.crc,output v-amt22).

/*Natalya D. 30.06.2006 --- begin*/
     assign v-amt25 = 0 v-mrp7 = 0 v-buscr = 0.
     /*для юр.лиц все 3 комиссии, для физ.лиц только комиссия "За предоставление бизнес-кредита"*/
     if wh_fu = '0' then do:
        find first txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'crline' and txb.lnmoncln.edt = ? use-index lncodedt no-lock no-error.
        if avail txb.lnmoncln then do:
           if txb.lnmoncln.pdt <= datums then
              run lonbalcrc_txb('lon',txb.lon.lon,datums,"25",yes,txb.lon.crc,output v-amt25).
        end.
        find first txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'crserv' and txb.lnmoncln.edt = ? use-index lncodedt no-lock no-error.
        if avail txb.lnmoncln then do:
           if txb.lnmoncln.pdt <= datums then do:
              find txb.tarif2 where txb.tarif2.num = '9' and txb.tarif2.kod = '40' no-lock no-error.
              if avail txb.tarif2 then v-mrp7 = txb.tarif2.ost.
           end.
        end.
     end.
     find first txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'crbusi' and txb.lnmoncln.edt = ? use-index lncodedt no-lock no-error.
     if avail txb.lnmoncln then do:
        if txb.lnmoncln.pdt <= datums then do:
           run lonbalcrc_txb('lon',txb.lon.lon,datums,"1,7",yes,txb.lon.crc,output v-buscr).
           v-buscr = ((v-buscr * 0.5) / 100).
           if txb.lon.crc <> 1 then do:
              find txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
              v-buscr = v-buscr * txb.crc.rate[1].
           end.
           if v-buscr < 15000 then v-buscr = 15000 .
        end.
     end.
/*Natalya D. 30.06.2006 --- end*/

     if not (v-am0 > 0 or v-am3 > 0 or v-am16 > 0 or v-am13 > 0 or v-am14 > 0 or v-am30 > 0 or
             v-amt4 > 0 or v-amt5 > 0 or v-amt20 > 0 or v-amt22 > 0 or
             v-amt25 > 0 or v-mrp7 > 0 or v-buscr > 0) then next.

     dayc1 = 0. dayc2 = 0.
/*     run lndayspr_txb(txb.lon.lon,datums,yes,output dayc1,output dayc2).*/
     run lndayspr_txb(txb.lon.lon,datums,no,output dayc1,output dayc2).

     /* Если пролонгация закончилась, то гасить все что есть на 1 и 2 уровнях */
     if dlong > txb.lon.duedt and dlong <= datums then do:
       /* просрочка ОД */
       v-am3 = bilance.
       if v-am3 > 0 then dayc1 = datums - dlong. else dayc1 = 0.
       /* просрочка % */
       run lonbalcrc_txb('lon',txb.lon.lon,datums,"2,9,10",yes,txb.lon.crc,output v-am0).
       if v-am0 > 0 then dayc2 = datums - dlong. else dayc2 = 0.
     end.

     /* 25/05/04 madiyar - для юр. лиц - сумма остатков на счетах по KZT, USD, EUR */
     b1 = 0. b2 = 0. b11 = 0. v-accs = ''.
     if wh_fu = '0' then do:
       for each txb.aaa where txb.aaa.cif = txb.lon.cif use-index cif no-lock:
         if txb.aaa.sta <> 'c' and txb.aaa.crc = 1 then do:
           if v-accs <> '' then v-accs = v-accs + ", ".
           v-accs = v-accs + txb.aaa.aaa.
         end.
         mbal = 0.
         find txb.trxbal where txb.trxbal.sub = 'cif' and txb.trxbal.acc = txb.aaa.aaa and txb.trxbal.level = 1 no-lock no-error.
         if avail txb.trxbal then do:
             find txb.gl where txb.gl.gl = txb.aaa.gl no-lock no-error.
             if gl.type = "A" or gl.type = "E" then mbal = txb.trxbal.dam - txb.trxbal.cam.
             else mbal = txb.trxbal.cam - txb.trxbal.dam.
             case txb.aaa.crc:
               when 1 then b1 = b1 + mbal.
               when 2 then b2 = b2 + mbal.
               when 11 then b11 = b11 + mbal.
             end case.
         end. /* if avail txb.trxbal */
       end. /* for each txb.aaa */
     end.
     else do: /* для физ.лиц - список тек счетов в валюте кредита и остатки по ним */
       for each txb.aaa where txb.aaa.cif = txb.lon.cif use-index cif no-lock:
         if txb.aaa.sta <> 'c' and txb.aaa.crc = txb.lon.crc then do:
           if v-accs <> '' then v-accs = v-accs + ", ".
           v-accs = v-accs + txb.aaa.aaa.
         end.
         else next.
         mbal = 0.
         find txb.trxbal where txb.trxbal.sub = 'cif' and txb.trxbal.acc = txb.aaa.aaa and txb.trxbal.level = 1 no-lock no-error.
         if avail txb.trxbal then do:
             find txb.gl where txb.gl.gl = txb.aaa.gl no-lock no-error.
             if gl.type = "A" or gl.type = "E" then mbal = txb.trxbal.dam - txb.trxbal.cam.
             else mbal = txb.trxbal.cam - txb.trxbal.dam.
             b1 = b1 + mbal.
         end. /* if avail txb.trxbal */
       end. /* for each txb.aaa */
     end.
     /* 25/05/04 madiyar end */

     create wrk.
            wrk.lon = txb.lon.lon.
            wrk.cif = txb.lon.cif.
            wrk.name = mname.
            wrk.bank = s-bank.
            wrk.phones = mphones.
            wrk.fu = mfu.
            wrk.rdt = txb.lon.rdt.
            wrk.duedt = dlong.
            wrk.opnamt = txb.lon.opnamt.
            wrk.balans = bilance.
            wrk.crc = txb.lon.crc.
            wrk.prem = txb.lon.prem.
            wrk.bal1 = v-am3. /* полная просрочка ОД */
            wrk.dt1 = dayc1.
            wrk.bal2 = v-am0. /* полная просрочка %% */
            wrk.dt2 = dayc2.
            wrk.bal3 = v-am3 + v-am0 + v-am13 + v-am14.
            wrk.balkzt = b1.
            wrk.balusd = b2.
            wrk.baleur = b11.
            wrk.is-today = is-pogtoday.
            wrk.bal16 = v-am16.
            wrk.bal13 = v-am13.
            wrk.bal4 = v-amt4.
            wrk.bal14 = v-am14.
            wrk.bal5 = v-amt5.
            wrk.bal30 = v-am30.
            wrk.bal25 = v-amt25.
            wrk.mrp7 = v-mrp7.
            wrk.buscr = v-buscr.
            wrk.accs = v-accs.
            wrk.iod  = v-amt20.
            wrk.iprc = v-amt22.
            wrk.kommis = v-kommis.

     find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
     if avail txb.loncon then do:
       if trim(txb.loncon.pase-pier) <> '' then
         find first txb.ofc where txb.ofc.ofc = txb.loncon.pase-pier no-lock no-error.
       if avail txb.ofc then wrk.respman = trim(txb.ofc.name).
     end.


     find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = "LON" and txb.sub-cod.d-cod = "kdkik" no-lock no-error.
     if avail txb.sub-cod then do:
       if txb.sub-cod.ccode = '01' then do:
         wrk.is-kik = yes.
         wrk.bal1 = wrk.balans.
       end.
     end.

     /* 12.11.2004 saltanat - Добавила проставление логина заблокировавшего тек. счет клиента по ссудному счету */
     blsum = 0.
     for each txb.aaa where txb.aaa.cif = txb.lon.cif /*use-index cif*/ no-lock:
         if txb.aaa.crc <> txb.lon.crc then next.
         for each txb.aas where txb.aas.aaa = txb.aaa.aaa no-lock:
           if txb.aas.delaas <> 'k' then next.
           find txb.ofc where txb.ofc.ofc = txb.aas.who no-lock no-error.
           if avail txb.ofc then do:
             if wrk.aasbl = '' then wrk.aasbl = txb.ofc.name.
             else wrk.aasbl = wrk.aasbl + ',' + txb.ofc.name.
           end.
           find txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
           blsum = blsum + txb.aas.chkamt * txb.crc.rate[1].
         end.
     end.
     if blsum > 0 then wrk.aassum = blsum.

end.
