/* vcrepdim.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
        18.05.2004 nadejda - изменение описания таблицы t-dolgs для совместимости
        23.05.2005 saltanat - Миним. остаток для рег/свид изменила на 0
        17.05.2006 u00600 - суммы ГТД и Платежей переводим в доллары на дату отчета (v-gtdusd v-platusd)
*/

/* vcrepdim.p Валютный контроль
   Отчет по задолжникам на дату - предоплата (импорт)

   14.12.2002 nadejda создан
   28.07.2003 nadejda - поставила условие на последнюю дату рег/свид-ва : просроченные не показывать
   31.07.2003 nadejda - добавлено поле sumdolg для совместимости
   06,04,2011 дамир - просто исправил ошибки.ненужная программа
    */

{vc.i}

{global.i}
{comm-txb.i}

def new shared var s-vcourbank as char.

def new shared temp-table t-dolgs
  field cif like cif.cif
  field namefil as char
  field depart as integer
  field cifname as char
  field contract like vccontrs.contract
  field ctdate as date
  field ctnum as char
  field ctei as char
  field ncrc like ncrc.crc
  field sumcon as decimal init 0
  field sumusd as decimal init 0
  field sumdolg as decimal init 0
  field lcnum as char
  field days as integer
  field cifrnn as char
  field cifokpo as char
  field ctterm  as char
  field cardnum as char
  field carddt as char
  field srokrep as decimal
  index main is primary cifname cif ctdate ctnum contract.

/*
def var v-dtb as date.
def var v-dte as date.
*/
def var v-dt as date.
def var v-days as integer.
def var v-docsgtd as char.
def var v-docsplat as char.
def var v-sum as deci.
def var v-sumgtd as deci decimals 2.
def var v-sumplat as deci decimals 2.
def var v-gtdusd as deci decimals 2 no-undo.
def var v-platusd as deci decimals 2 no-undo.
def var v-sumdoc as deci.
def var v-cursusd as deci.
def var v-filename as char init "vcdolgpred.htm".
def var v-title as char.
def var v-minreg as deci.

function konv2usd returns decimal (p-sum as decimal, p-crc as integer, p-date as date).
  def var vp-sum as decimal.

  if p-crc = 2 then vp-sum = p-sum.
  else do:
    find last ncrchis where ncrchis.crc = p-crc and ncrchis.rdt <= p-date no-lock no-error.
    if avail ncrchis then vp-sum = (p-sum * ncrchis.rate[1]) / v-cursusd.
    else do:
      find ncrc where ncrc.crc = p-crc no-lock no-error.
      message skip "Не найден курс для валюты " + ncrc.code + " на " +
          string(p-date, "99/99/9999") skip (1)
          view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
      find first ncrchis where ncrchis.crc = p-crc no-lock no-error.
      vp-sum = (p-sum * ncrchis.rate[1]) / v-cursusd.
    end.
  end.
  return vp-sum.
end.

{vcrepdt.i " ЗАДОЛЖНИКИ ПО РЕГ.СВИДЕТЕЛЬСТВАМ "}

s-vcourbank = comm-txb().

find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= v-dte no-lock no-error.
v-cursusd = ncrchis.rate[1].


v-docsgtd = "".
for each codfr where codfr.codfr = "vcdoc" and index("g", codfr.name[5]) > 0 no-lock:
  v-docsgtd = v-docsgtd + codfr.code + ",".
end.
v-docsplat = "".
for each codfr where codfr.codfr = "vcdoc" and index("p", codfr.name[5]) > 0 no-lock:
  v-docsplat = v-docsplat + codfr.code + ",".
end.

find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
if avail vcparams then v-days = vcparams.valinte.
                  else v-days = 120.
find vcparams where vcparams.parcode = "minregsv" no-lock no-error.
if avail vcparams then v-minreg = vcparams.valdeci.
                  else v-minreg = 100000.

/* ИМПОРТ */
for each vccontrs where vccontrs.bank = s-vcourbank and vccontrs.cttype = "1" and
      vccontrs.expimp = "i" and vccontrs.ctdate >= v-dtb
      use-index main no-lock break by vccontrs.cif:

  /* закрытые контракты не смотрим */
  if vccontrs.sts = "c" and ((not v-closed) or (v-closed and vccontrs.udt < v-dte)) then next.

  /* сумма ГТД по контракту */
  v-sumgtd = 0. v-gtdusd = 0. v-sum = 0.
  for each vcdocs where vcdocs.contract = vccontrs.contract and
        lookup(vcdocs.dntype, v-docsgtd) > 0 and vcdocs.dndate < v-dte no-lock:
    if vcdocs.payret then v-sum = - vcdocs.sum.
                     else v-sum = vcdocs.sum.

    accumulate v-sum / vcdocs.cursdoc-con (total).
  end.

  v-sumgtd = (accum total v-sum / vcdocs.cursdoc-con).

  /* сумма платежных док-тов по контракту */
  v-sumplat = 0. v-platusd = 0. v-sum = 0.
  for each vcdocs where vcdocs.contract = vccontrs.contract and
     lookup(vcdocs.dntype, v-docsplat) > 0 and vcdocs.dndate < v-dte no-lock:
    if vcdocs.payret then v-sum = - vcdocs.sum.
                     else v-sum = vcdocs.sum.
    accumulate v-sum / vcdocs.cursdoc-con (total).
  end.
  v-sumplat = (accum total v-sum / vcdocs.cursdoc-con).

  v-gtdusd = konv2usd(v-sumgtd, vccontrs.ncrc, v-dte).     /*18.04.2006 u00600 - суммы ГТД и Платежей переводим в доллары на дату отчета*/
  v-platusd = konv2usd(v-sumplat, vccontrs.ncrc, v-dte).

  /*if (v-sumgtd - v-sumplat) / vccontrs.cursdoc-usd >= v-minreg then do:       */
  if (v-gtdusd - v-platusd) >= v-minreg then do:

    /* есть ГТД, не покрытые оплатами и сумма задолженности > 100 000 USD */
    /* задолжник! */
    create t-dolgs.

    find cif where cif.cif = vccontrs.cif no-lock no-error.
    t-dolgs.cif = cif.cif.
    t-dolgs.depart = integer(cif.jame) mod 1000.
    t-dolgs.cifname = trim(trim(cif.sname) + " " + trim(cif.prefix)).
    t-dolgs.contract = vccontrs.contract.
    t-dolgs.ctdate = vccontrs.ctdate.
    t-dolgs.ctnum = vccontrs.ctnum.
    t-dolgs.ncrc = vccontrs.ncrc.
    t-dolgs.sumcon = v-sumgtd - v-sumplat.
    t-dolgs.cifrnn = cif.jss.
    t-dolgs.cifokpo = cif.ssn.


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


def stream vcrpt.
output stream vcrpt to value(v-filename).

{html-title.i
 &stream = " stream vcrpt "
 &title = "Задолжники по рег.свидетельствам"
 &size-add = "x-"
}

v-title = "РЕГ.СВИДЕТЕЛЬСТВАМ<BR><BR>сумма ГТД превышает сумму проплат<BR>и задолженность больше " +
           replace(trim(string(v-minreg, ">>>,>>>,>>9.99")), ",", "&nbsp;") + "&nbsp;USD<BR>".

{vcrepdout.i
 &rslccell = "Последнее рег.св-во"
 &days120 = " false "
 &sumdolg = " false "
 &cln = " true "
 &ei = " false "
}

output stream vcrpt close.

unix silent value("cptwin " + v-filename + " iexplore").

pause 0.
