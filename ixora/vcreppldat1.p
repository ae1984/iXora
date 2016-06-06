/* vcreppldat1.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Расчет платежей за определенный период - для реестра и Приложения 14
 * RUN
        vcreppl.p
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-3-4
 * AUTHOR
        29.11.2010 aigul - изменила vcreppldat.p
 * BASES
        BANK COMM
 * CHANGES



*/

{vc.i}


def input parameter v-reptype   as char.
def input parameter p-bank      as char.
def input parameter p-depart    as integer.
def input parameter v-dtb       as date.
def input parameter v-dte       as date.
def input parameter p-contrtype as char.
def input parameter v-cttype as char.

def shared temp-table t-docsa
  field cif as char
  field bank as char
  field  ppname as char
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field pcrc like vcdocs.pcrc
  field crckod as char
  field sum like vcdocs.sum
  field sumret like vcdocs.sum
  field knp as char
  field kod14 as char
  field kod14a as char
  field p14sum6 as deci init 0.00
  field p14sum7 as deci init 0.00
  field p14sum9 as deci init 0.00
  field p14sum10 as deci init 0.00
  field p14sum11 as deci init 0.00
  field p14sum12 as deci init 0.00
  field p14sum13 as deci init 0.00
  field info as char
  field cifname as char
  field depart as integer
  field rnn as char
  field contrnum as char
  field cttype as char
  field ctei as char
  field psnum as char
  field partname as char.

def var v-contractnum as char.
def var s-vcdoctypes as char.

def var v-contrnum as char.
def var v-partname as char.
def var v-psnum as char.
def var v-ctei as char.
def var v-ncrccod like ncrc.code.
def var v-sum as deci.
def var v-sumret as deci.
def var v-sumgtd as deci.
def var v-sumplat as deci.
def var v-sumdoc as deci.
def var v-sumavans as deci.
def var v-sumpost as deci.
def var v-sumavans0 as deci.
def var v-sumpost0 as deci.
def var v-cttype1 as char.
def var i as integer.
def var l as logical.

def new shared var v-cif like cif.cif.
def new shared var v-cifname as char.
def new shared var v-rnn as char.
def new shared var v-depart as int.
def new shared var v-ppname as char.


def buffer b-docs for vcdocs.

/* расчет */

s-vcdoctypes = "".
for each codfr where codfr.codfr = "vcdoc" and index("p", codfr.name[5]) > 0 no-lock:
  s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.

v-contractnum = p-contrtype.
/* платежи */
for each vccontrs where (vccontrs.bank = p-bank or p-bank = "ALL") and (vccontrs.cttype = v-cttype or  v-cttype = 'ALL') use-index main no-lock break by vccontrs.cif:

  if first-of(vccontrs.cif) then do:
    v-cif = vccontrs.cif.
    if connected ("txb") then disconnect "txb".
    find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run vcrepplcif.
        disconnect "txb".
    end.


  end.

  if p-depart <> 0 and v-depart <> p-depart then next.

  if v-reptype <> "A" and vccontrs.expimp <> v-reptype then next.
  if vccontrs.sts begins "c" and vccontrs.udt < v-dtb then next.

  l = false.
  do i = 1 to num-entries(s-vcdoctypes):
    find first vcdocs where vcdocs.contract = vccontrs.contract and
      vcdocs.dntype = entry(i, s-vcdoctypes) and
      vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte no-lock no-error.
    if avail vcdocs then do:
      l = true.
      leave.
    end.
  end.
  if not l then next.

  v-contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").
  v-ctei = vccontrs.expimp.
  v-cttype1 = vccontrs.cttype.

  find vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
  if avail vcps then v-psnum = vcps.dnnum + string(vcps.num). else v-psnum = "".

  find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
  if avail vcpartners then
    v-partname = trim(trim(vcpartners.name) + " " + trim(vcpartner.formasob)).
  else v-partname = "".

  do i = 1 to num-entries(s-vcdoctypes):
    c-docs:
    for each vcdocs where vcdocs.contract = vccontrs.contract and
            vcdocs.dntype = entry(i, s-vcdoctypes) no-lock:

      if not(vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte) then next c-docs.
      create t-docsa.
      t-docsa.bank = vccontrs.bank.
      t-docsa.cif = vccontrs.cif.
      t-docsa.ppname = v-ppname.
      t-docsa.docs = vcdocs.docs.
      t-docsa.dndate = vcdocs.dndate.
      t-docsa.pcrc = vcdocs.pcrc.
      t-docsa.contrnum = v-contrnum.
      t-docsa.ctei = v-ctei.
      t-docsa.cttype = v-cttype1.
      t-docsa.cifname = v-cifname.
      t-docsa.depart = v-depart.
      t-docsa.rnn = v-rnn.
      t-docsa.psnum = v-psnum.
      t-docsa.partname = v-partname.
      find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
      t-docsa.crckod = string(ncrc.stn).
      t-docsa.info = vcdocs.info[1].
      t-docsa.knp = vcdocs.knp.

      if vcdocs.payret then do: t-docsa.sumret = vcdocs.sum. t-docsa.sum = 0. end.
      else do: t-docsa.sum = vcdocs.sum. t-docsa.sumret = 0. end.

      if lookup(vccontrs.cttype, v-contractnum) > 0 then do:
        t-docsa.kod14 = vcdocs.kod14.

        /* kod14 вычисленный */

        /* строка 13 - оплаты по аккредитивам */
        if vcdocs.kod14 = "13" then do:
          t-docsa.kod14a = "13".
          if vcdocs.payret then t-docsa.p14sum13 = - vcdocs.sum.
          else t-docsa.p14sum13 = vcdocs.sum.
        end.
        else do:
          /* возвраты */
          if vcdocs.payret then do:
            t-docsa.kod14a = t-docsa.kod14a + "11".
            t-docsa.p14sum11 = vcdocs.sum.
          end.
          else do:
            /* оплачено - в валюте контракта! */
            v-sumdoc = vcdocs.sum / vcdocs.cursdoc-con.

            /* делим по КНП на проплаты за товар и иные */
            if lookup(vcdocs.knp, "710,720,819") > 0 then do:
              /* сумма ГТД ДО данного платежа */
              find first b-docs where b-docs.contract = vccontrs.contract and b-docs.dntype = "14"
                 and (b-docs.dndate < vcdocs.dndate or
                      (b-docs.dndate = vcdocs.dndate and b-docs.docs < vcdocs.docs)) no-lock no-error.
              if avail b-docs then do:
                for each b-docs where b-docs.contract = vccontrs.contract and b-docs.dntype = "14"
                   and (b-docs.dndate < vcdocs.dndate or
                        (b-docs.dndate = vcdocs.dndate and b-docs.docs < vcdocs.docs)) no-lock:
                  accumulate b-docs.sum / b-docs.cursdoc-con (total).
                end.
                v-sumgtd = (accum total b-docs.sum / b-docs.cursdoc-con).
              end.
              else v-sumgtd = 0.

              /* сумма платежей ДО данного платежа */
              find first b-docs where b-docs.contract = vccontrs.contract and
                      lookup(b-docs.dntype, s-vcdoctypes) > 0 and (not b-docs.payret) and
                      (b-docs.dndate < vcdocs.dndate or
                      (b-docs.dndate = vcdocs.dndate and b-docs.docs < vcdocs.docs)) no-lock no-error.
              if avail b-docs then do:
                for each b-docs where b-docs.contract = vccontrs.contract and
                   ((vccontrs.expimp = "e" and b-docs.dntype = "02") or
                    (vccontrs.expimp = "i" and b-docs.dntype = "03")) and
                        (b-docs.dndate < vcdocs.dndate or
                        (b-docs.dndate = vcdocs.dndate and b-docs.docs < vcdocs.docs)) no-lock:
                  accumulate b-docs.sum / b-docs.cursdoc-con (total).
                end.
                v-sumplat = (accum total b-docs.sum / b-docs.cursdoc-con).
              end.
              else v-sumplat = 0.

              if v-sumgtd <= v-sumplat then do:
              /* платеж полностью авансовый */
                v-sumavans = v-sumdoc.
                v-sumpost = 0.
              end.
              else do:
                if v-sumgtd >= v-sumplat + v-sumdoc then do:
                /* платеж после отгрузки товара */
                  v-sumavans = 0.
                  v-sumpost = v-sumdoc.
                end.
                else do:
                /* частично авансовый */
                  v-sumavans = v-sumplat + v-sumdoc - v-sumgtd.
                  v-sumpost = v-sumgtd - v-sumplat.
                end.
              end.

              if v-sumavans > 0 then do:
                t-docsa.kod14a = t-docsa.kod14a + "6, ".
                t-docsa.p14sum6 = v-sumavans / v-sumdoc * vcdocs.sum. /* по сумме в валюте контракта определить сумму в валюте платежа */

                /* сумма ГТД отчетного периода после данного платежа */
                find first b-docs where b-docs.contract = vccontrs.contract and b-docs.dntype = "14"
                   and ((b-docs.dndate > vcdocs.dndate and b-docs.dndate <= v-dte) or
                        (b-docs.dndate = vcdocs.dndate and b-docs.docs > vcdocs.docs)) no-lock no-error.
                if avail b-docs then do:
                  for each b-docs where b-docs.contract = vccontrs.contract and b-docs.dntype = "14"
                     and (b-docs.dndate > vcdocs.dndate or
                          (b-docs.dndate = vcdocs.dndate and b-docs.docs > vcdocs.docs)) no-lock:
                    accumulate b-docs.sum / b-docs.cursdoc-con (total).
                  end.
                  v-sumgtd = (accum total b-docs.sum / b-docs.cursdoc-con).
                end.
                else v-sumgtd = 0.
                if v-sumavans > v-sumgtd then do:
                  /* не было поставки товаров */
                  t-docsa.kod14a = t-docsa.kod14a + "7, ".
                  t-docsa.p14sum7 = (v-sumavans - v-sumgtd) / v-sumdoc * vcdocs.sum.
                end.
              end.

              if v-sumpost > 0 then do:
                /* сумма ГТД до отчетного периода */
                find first b-docs where b-docs.contract = vccontrs.contract and b-docs.dntype = "14"
                   and (b-docs.dndate < v-dtb) no-lock no-error.
                if avail b-docs then do:
                  for each b-docs where b-docs.contract = vccontrs.contract and b-docs.dntype = "14"
                     and (b-docs.dndate < v-dtb) no-lock:
                    accumulate b-docs.sum / b-docs.cursdoc-con (total).
                  end.
                  v-sumgtd = (accum total b-docs.sum / b-docs.cursdoc-con).
                end.
                else v-sumgtd = 0.

                if v-sumplat >= v-sumgtd then do:
                  /* предыдущий период уже был оплачен - вся оплата идет только в текущий период */
                  t-docsa.kod14a = t-docsa.kod14a + "10".
                  t-docsa.p14sum10 = v-sumpost / v-sumdoc * vcdocs.sum.
                end.
                else do:
                  if v-sumplat + v-sumpost <= v-sumgtd then do:
                    /* все за предыдущий период */
                    t-docsa.kod14a = t-docsa.kod14a + "9".
                    t-docsa.p14sum9 = v-sumpost / v-sumdoc * vcdocs.sum.
                  end.
                  else do:
                    /* часть за предыдущие, часть за текущие */
                    t-docsa.kod14a = t-docsa.kod14a + "9, 10".
                    t-docsa.p14sum9 = (v-sumgtd - v-sumplat) / v-sumdoc * vcdocs.sum.
                    t-docsa.p14sum10 = vcdocs.sum - t-docsa.p14sum9.
                  end.
                end.
              end.
            end.
            else do:
              t-docsa.kod14a = t-docsa.kod14a + "12".
              t-docsa.p14sum12 = vcdocs.sum.
            end.
          end.
        end.
      end.
    end.
  end.
end.


