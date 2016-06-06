/* vcreppldat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Расчет платежей за определенный период - для реестра и Приложения 14
 * RUN
        vcreppl.p, vvrep14dat.p
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-3-4, 15-4-x-2
 * AUTHOR
        13.01.2003 nadejda  - вырезан кусок из vcreppl.p
 * CHANGES
        01.12.2003 nadejda  - корректировка показа закрытых контрактов
        13.05.2004 nadejda  - КНП 710 считать обычными платежами
        08.07.2004 saltanat - включен shared переменная v-contrtype и переменная v-contractnum, 
                              нужны для деления контрактов типа "1" и "5".
        04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype 
*/

{vc.i}


def input parameter v-reptype   as char.
def input parameter p-bank      as char.
def input parameter p-depart    as integer.
def input parameter v-dtb       as date.
def input parameter v-dte       as date.
def input parameter p-contrtype as char.

def shared temp-table t-docsa 
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
def var v-cifname as char.
def var v-contrnum as char.
def var v-partname as char.
def var v-rnn as char.
def var v-depart as integer.
def var v-psnum as char.
def var v-ctei as char.
def var v-cttype as char.
def var v-ncrccod like txb.ncrc.code.
def var v-sum as deci.
def var v-sumret as deci.
def var v-sumgtd as deci.
def var v-sumplat as deci.
def var v-sumdoc as deci.
def var v-sumavans as deci.
def var v-sumpost as deci.
def var v-sumavans0 as deci.
def var v-sumpost0 as deci.
def var i as integer.
def var l as logical.


def buffer b-docs for vcdocs.

/* расчет */

s-vcdoctypes = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("p", txb.codfr.name[5]) > 0 no-lock:
  s-vcdoctypes = s-vcdoctypes + txb.codfr.code + ",".
end.


v-contractnum = p-contrtype.

/* платежи */
for each vccontrs where vccontrs.bank = p-bank use-index main no-lock break by vccontrs.cif:

  if first-of(vccontrs.cif) then do:
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.   
    v-cifname = trim(trim(txb.cif.sname) + " " + trim(txb.cif.prefix)).
    v-rnn = string(txb.cif.jss, "999999999999").
    v-depart = integer(txb.cif.jame) mod 1000.
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
  v-cttype = vccontrs.cttype.

  find vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
  if avail vcps then v-psnum = vcps.dnnum. else v-psnum = "".

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
      t-docsa.docs = vcdocs.docs.
      t-docsa.dndate = vcdocs.dndate.
      t-docsa.pcrc = vcdocs.pcrc.
      t-docsa.contrnum = v-contrnum.
      t-docsa.ctei = v-ctei.
      t-docsa.cttype = v-cttype.
      t-docsa.cifname = v-cifname.
      t-docsa.depart = v-depart.
      t-docsa.rnn = v-rnn.
      t-docsa.psnum = v-psnum.
      t-docsa.partname = v-partname.
      find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
      t-docsa.crckod = string(txb.ncrc.stn).
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


