/* vcdolg3.i
 * MODULE
        Название модуля - Проверка алгоритма п.м. 9,3,6 - 5
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

find first vccontrs where vccontrs.contract = s-contract and vccontrs.sts <> "C" no-lock no-error.
if avail vccontrs then do:
    /* сумма ГТД по контракту */
    v-sumgtd = 0.
    v-sum = 0.
    for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsgtd) > 0 and vcdocs.dndate < g-today no-lock:
        if vcdocs.payret then v-sum = - vcdocs.sum.
        else v-sum = vcdocs.sum.
        accumulate v-sum / vcdocs.cursdoc-con (total).
    end.
    v-sumgtd = (accum total v-sum / vcdocs.cursdoc-con).

    /* сумма платежных док-тов по контракту */
    v-sumplat = 0.
    v-sum = 0.
    for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsplat) > 0 and vcdocs.dndate < g-today no-lock:
        if vcdocs.payret then v-sum = - vcdocs.sum.
        else v-sum = vcdocs.sum.
        accumulate v-sum / vcdocs.cursdoc-con (total).
    end.
    v-sumplat = (accum total v-sum / vcdocs.cursdoc-con).

    /* сумма актов по контракту */
    v-sumakt = 0.
    v-sum = 0.
    for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsakt) > 0 and vcdocs.dndate < g-today no-lock:
        if vcdocs.payret then v-sum = - vcdocs.sum.
        else v-sum = vcdocs.sum.
        accumulate v-sum / vcdocs.cursdoc-con (total).
    end.
    v-sumakt = (accum total v-sum / vcdocs.cursdoc-con).

    def var v-sum-all1  as deci decimals 2.
    def var vv-sum-all1 as deci decimals 2.
    def var vv-date1    as date.
    def var vv-summa1   as deci decimals 2.
    def var vv-sum1     as deci decimals 2.
    def var vv-summ1    as deci decimals 2.
    def var vv-term1    as date.
    def var v-term1     as date.

    vv-date1 = date(g-today - check-term(vccontrs.ctterm)).
    if v-sumakt > v-sumplat then do:
        v-sum-all1 = v-sumakt - v-sumplat.
        vv-sum-all1 = konv2usd(v-sum-all1, vccontrs.ncrc, g-today - 1).
        vv-sum-dt1 = v-sum-all1.
        if vv-sum-all1 > 50000 then do:
            vv-summa1 = 0.
            if v-sumplat <> 0 then do:
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsakt) > 0 by vcdocs.dndate descending:
                    vv-sum-dt1 = vv-sum-dt1 - vcdocs.sum.
                    if konv2usd(vv-sum-dt1, vccontrs.ncrc, g-today - 1) <= 0 then do:
                        create vcdoc.
                        vcdoc.contr = vccontrs.contract.
                        vcdoc.dt = vcdocs.dndate.
                        vcdoc.sum = vv-sum-dt1.
                        vcdoc.sts = 1.
                    end.
                end.
                find first vcdoc where vcdoc.contr = vccontrs.contract and vcdoc.sts = 1 no-lock no-error.
                if avail vcdoc then do:
                    v-term1 = vcdoc.dt.
                    if vcdoc.sum < 0 then do:
                        vv-sum1   = -(vcdoc.sum).
                        vv-plus1  = vv-sum1.
                    end.
                    else if vcdoc.sum = 0 then do:
                        vv-sum1   = 0.
                        vv-plus1  = 0.
                    end.
                end.
                find first vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsakt) > 0 and
                vcdocs.dndate = v-term1 no-lock no-error.
                if avail vcdocs then do:
                    vv-plus2 = vcdocs.sum - vv-plus1.
                    if konv2usd(vv-plus2, vccontrs.ncrc, g-today - 1) > 50000 then do:
                        vv-term1 = vcdocs.dndate.
                    end.
                    else do:
                        for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsakt) > 0 and
                        vcdocs.dndate > v-term1 and vcdocs.dndate < vv-date1 by vcdocs.dndate:
                            vv-plus2 = vv-plus2 + vcdocs.sum.
                            if konv2usd(vv-plus2, vccontrs.ncrc, g-today - 1) > 50000 then do:
                                create vcdocum.
                                assign
                                vcdocum.contr = vccontrs.contract
                                vcdocum.dt    = vcdocs.dndate.
                            end.
                        end.
                        find first vcdocum where vcdocum.contr = vccontrs.contract no-lock no-error.
                        if avail vcdocum then vv-term = vcdocum.dt.
                    end.
                end.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsakt) > 0 and
                vcdocs.dndate >= v-term1 and vcdocs.dndate < vv-date1 by vcdocs.dndate:
                    vv-summa1 = vv-summa1 + vcdocs.sum.
                end.
                vv-summa1 = vv-summa1 - vv-sum1.
            end.
            else if v-sumplat = 0 then do:
                vv-summ1 = 0.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsakt) > 0 by vcdocs.dndate:
                    vv-summ1 = vv-summ1 + vcdocs.sum.
                    if konv2usd(vv-summ1, vccontrs.ncrc, g-today - 1) > 50000 then do:
                        create vcdoc.
                        vcdoc.contr = vccontrs.contract.
                        vcdoc.dt = vcdocs.dndate.
                        vcdoc.sts = 2.
                    end.
                end.
                find first vcdoc where vcdoc.contr = vccontrs.contract and vcdoc.sts = 2 no-lock no-error.
                if avail vcdoc then do:
                    v-term1 = vcdoc.dt.
                end.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsplat) > 0 and
                vcdocs.dndate < vv-date1 by vcdocs.dndate:
                    vv-summa1 = vv-summa1 + vcdocs.sum.
                end.
                vv-term1 = v-term1.
            end.

            v-dolgdays = (g-today - 1) - vv-term1.
            v-sumdolg = konv2usd(vv-summa1, vccontrs.ncrc, g-today - 1).

            if decimal(v-dolgdays) > check-term(vccontrs.ctterm) and v-sumdolg > 50000  then do:
                assign
                v-sumcon = v-sum-all1.
                v-sumusd = konv2usd(v-sumcon, vccontrs.ncrc, g-today - 1).
            end.
            else do:
                assign v-sumcon = 0 v-sumusd = 0.
            end.
        end.
    end.
end.



