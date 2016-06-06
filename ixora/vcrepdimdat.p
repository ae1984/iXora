/* vcrepdimdat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Расчет должников по консигнации за определенный период - для отчета по задолжникам и Приложения 14
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
        13.01.2003 nadejda - вырезан кусок из vcrepdex.p
 * CHANGES
        31.07.2003 nadejda - добавлено поле sumdolg для совместимости
        20.01.2004 nadejda - для Приложения 14 добавлена передача параметра учитывать/нет ограничение по сумме для рег.св.
        09.02.2004 nadejda - исправлена ошибка - не обрабатывался параметр p-depart
        14.06.2004 nadejda - добавлены поля в t-dolgs для совместимости
        08.07.2004 saltanat - включен shared переменная v-contrtype и переменная v-contractnum, 
                              нужны для деления контрактов типа "1" и "5".
        04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype 
        14.03.2005 saltanat - по просьбе Жумадиллаевой сделала v-minreg = 0.01.
        23.05.2005 saltanat - Миним. остаток для рег/свид изменила на 0
*/


{vc.i}

def input parameter p-bank      as char.
def input parameter p-depart    as integer.
def input parameter v-dtb       as date.
def input parameter v-dte       as date.
def input parameter p-closed    as logical.
def input parameter p-sumrs     as logical.
def input parameter p-contrtype as char.

def shared temp-table t-dolgs
  field cif like txb.cif.cif
  field depart as integer
  field cifname as char
  field contract like vccontrs.contract
  field ctdate as date
  field ctnum as char
  field ctei as char
  field ncrc like txb.ncrc.crc
  field sumcon as decimal init 0
  field sumusd as decimal init 0
  field sumdolg as decimal init 0
  field lcnum as char
  field days as integer
  field cifrnn as char
  field cifokpo as char
  index main is primary cifname cif ctdate ctnum contract.

def var v-contractnum as char.
def var v-dt as date.
def var v-days as integer.
def var v-docsgtd as char.
def var v-docsplat as char.
def var v-sum as deci.
def var v-sumgtd as deci decimals 2.
def var v-sumplat as deci decimals 2.
def var v-cursusd as deci.
def var v-minreg as deci.
def var v-depart as integer.


function konv2usd returns decimal (p-sum as decimal, p-crc as integer, p-date as date).
  def var vp-sum as decimal.

  if p-crc = 2 then vp-sum = p-sum.
  else do:
    find last txb.ncrchis where txb.ncrchis.crc = p-crc and txb.ncrchis.rdt <= p-date no-lock no-error. 
    if avail txb.ncrchis then vp-sum = (p-sum * txb.ncrchis.rate[1]) / v-cursusd.
    else do:
      find txb.ncrc where txb.ncrc.crc = p-crc no-lock no-error.
      message skip "Не найден курс для валюты " + txb.ncrc.code + " на " + 
          string(p-date, "99/99/9999") skip (1) 
          view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
      find first txb.ncrchis where txb.ncrchis.crc = p-crc no-lock no-error. 
      vp-sum = (p-sum * txb.ncrchis.rate[1]) / v-cursusd.
    end.
  end.
  return vp-sum.
end.


/* расчет */

find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= v-dte no-lock no-error.
v-cursusd = txb.ncrchis.rate[1].

v-docsgtd = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("g", txb.codfr.name[5]) > 0 no-lock:
  v-docsgtd = v-docsgtd + txb.codfr.code + ",".
end.
v-docsplat = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("p", txb.codfr.name[5]) > 0 no-lock:
  v-docsplat = v-docsplat + txb.codfr.code + ",".
end.

find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
if avail vcparams then v-days = vcparams.valinte. 
else v-days = 120.

/* по просьбе Жумадилаевой Г. 14.03.05 saltanat
if p-sumrs then do:
  find vcparams where vcparams.parcode = "minregsv" no-lock no-error.
  if avail vcparams then v-minreg = vcparams.valdeci. 
                    else v-minreg = 100000.
end.
else v-minreg = 0.01. /* именно так, а не 0, поскольку дальше условие >= */
*/
v-minreg = 0.01.

/* * * * *  Определяем тип контракта  * * * * */
v-contractnum = p-contrtype.

/* ИМПОРТ */  
for each vccontrs where vccontrs.bank = p-bank and lookup(vccontrs.cttype, v-contractnum) > 0 and
      vccontrs.expimp = "i" 
      use-index main no-lock break by vccontrs.cif:

  if first-of(vccontrs.cif) then do:
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.   
    v-depart = integer(txb.cif.jame) mod 1000.
  end. 

  if p-depart <> 0 and v-depart <> p-depart then next.

  if vccontrs.ctdate < v-dtb then next.

  /* закрытые контракты не смотрим */
  if vccontrs.sts = "c" and ((not p-closed) or (p-closed and vccontrs.udt < v-dte)) then next.

  /* сумма ГТД по контракту */
  v-sumgtd = 0.
  for each vcdocs where vcdocs.contract = vccontrs.contract and 
        lookup(vcdocs.dntype, v-docsgtd) > 0 and vcdocs.dndate < v-dte no-lock:
    if vcdocs.payret then v-sum = - vcdocs.sum.
                     else v-sum = vcdocs.sum.

    accumulate v-sum / vcdocs.cursdoc-con (total).
  end.
  v-sumgtd = (accum total v-sum / vcdocs.cursdoc-con).

  /* сумма платежных док-тов по контракту */
  v-sumplat = 0.
  for each vcdocs where vcdocs.contract = vccontrs.contract and 
     lookup(vcdocs.dntype, v-docsplat) > 0 and vcdocs.dndate < v-dte no-lock:
    if vcdocs.payret then v-sum = - vcdocs.sum.
                     else v-sum = vcdocs.sum.

    accumulate v-sum / vcdocs.cursdoc-con (total).
  end.
  v-sumplat = (accum total v-sum / vcdocs.cursdoc-con).

  if (v-sumgtd - v-sumplat) / vccontrs.cursdoc-usd >= v-minreg then do:
    /* есть ГТД, не покрытые оплатами и сумма задолженности > 100 000 USD */
    /* задолжник! */
    create t-dolgs.

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    t-dolgs.cif = txb.cif.cif.
    t-dolgs.depart = integer(txb.cif.jame) mod 1000.
    t-dolgs.cifname = trim(trim(txb.cif.sname) + " " + trim(txb.cif.prefix)).
    t-dolgs.contract = vccontrs.contract.
    t-dolgs.ctdate = vccontrs.ctdate.
    t-dolgs.ctnum = vccontrs.ctnum.
    t-dolgs.ncrc = vccontrs.ncrc.
    t-dolgs.sumcon = v-sumgtd - v-sumplat.

    /* никакой проверки на рег/св - он все равно задолжник! рег/св просто напишем - есть или нет */
    find last vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" and
         vcrslc.dndate < v-dte and vcrslc.lastdate >= v-dte no-lock no-error.
    if avail vcrslc then 
      t-dolgs.lcnum = "N " + vcrslc.dnnum + " от " + string(vcrslc.dndate, "99/99/9999") + ", до " + string(vcrslc.lastdate, "99/99/9999").

    t-dolgs.sumusd = konv2usd(t-dolgs.sumcon, t-dolgs.ncrc, v-dte).
    t-dolgs.sumdolg = t-dolgs.sumusd.

    /* без проверки на 120 дней - просто показать количество дней */
    /* берем просто последнюю ГТД */
    /*
    find last vcdocs where vcdocs.contract = vccontrs.contract and 
       lookup(vcdocs.dntype, v-docsgtd) > 0 and vcdocs.dndate < v-dte
       use-index main no-lock no-error.

    if avail vcdocs then v-dt = vcdocs.dndate.
                    else v-dt = vccontrs.ctdate.
    */
    /* а вот и нет, надо брать первую ГТД! */
    if v-sumplat = 0 then do:
      /* нет платежей - берем просто первую ГТД */
      find first vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsgtd) > 0
         use-index main no-lock no-error.
      v-dt = vcdocs.dndate.
    end.
    else do:
      /* идем по ГТД, пока выполняется условие */
      v-sum = 0.
      for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsgtd) > 0 and 
         vcdocs.dndate < v-dte no-lock use-index main.
        if vcdocs.payret then v-sum = v-sum - vcdocs.sum / vcdocs.cursdoc-con.
                         else v-sum = v-sum + vcdocs.sum / vcdocs.cursdoc-con.
        if (v-sum - v-sumplat) / vccontrs.cursdoc-usd > 0 then do:
          v-dt = vcdocs.dndate.
          leave.
        end.
      end.
    end.
    
    t-dolgs.days = (v-dte - 1) - v-dt.
  end.
end.

