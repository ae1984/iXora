/* vcdolg2.i
 * MODULE
        Название модуля - Проверка алгоритма п.м. 9,3,6 - 4.
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

    vv-date = date(g-today - check-term(vccontrs.ctterm)).
    v-sum-all = 0.
    if v-sumgtd + v-sumakt < v-sumplat then do:
        v-sum-all = v-sumplat - (v-sumgtd + v-sumakt).
        vv-sum-all = konv2usd(v-sum-all, vccontrs.ncrc, g-today - 1).
        vv-sum-dt = v-sum-all.
        if vv-sum-all > 50000 then do:
            vv-summa = 0.
            if v-sumgtd <> 0 or v-sumakt <> 0 then do:
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsplat) > 0 by vcdocs.dndate descending:
                    vv-sum-dt = vv-sum-dt - vcdocs.sum.
                    if vv-sum-dt <= 0 then do:
                        create vcdoc.
                        vcdoc.contr = vccontrs.contract.
                        vcdoc.dt = vcdocs.dndate.
                        vcdoc.sum = vv-sum-dt.
                        vcdoc.sts = 1.
                    end.
                end.
                find first vcdoc where vcdoc.contr = vccontrs.contract and vcdoc.sts = 1 no-lock no-error.
                if avail vcdoc then do:
                    v-term = vcdoc.dt.
                    if vcdoc.sum < 0 then do:
                        vv-sum   = -(vcdoc.sum).
                        vv-plus1 = vv-sum.
                    end.
                    else if vcdoc.sum = 0 then do:
                        vv-sum   = 0.
                        vv-plus1 = 0.
                    end.
                end.
                find first vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsplat) > 0 and
                vcdocs.dndate = v-term no-lock no-error.
                if avail vcdocs then do:
                    vv-plus2 = vcdocs.sum - vv-plus1.
                    if konv2usd(vv-plus2, vccontrs.ncrc, g-today - 1) > 50000 then do:
                        vv-term = vcdocs.dndate.
                    end.
                    else do:
                        for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsplat) > 0 and
                        vcdocs.dndate > v-term and vcdocs.dndate < vv-date by vcdocs.dndate:
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
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsplat) > 0 and
                vcdocs.dndate >= v-term and vcdocs.dndate < vv-date by vcdocs.dndate:
                    vv-summa = vv-summa + vcdocs.sum.
                end.
                vv-summa = vv-summa - vv-sum.
            end.
            else if v-sumgtd = 0 and v-sumakt = 0 then do:
                vv-summ = 0.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsplat) > 0 by vcdocs.dndate:
                    vv-summ = vv-summ + vcdocs.sum.
                    if konv2usd(vv-summ, vccontrs.ncrc, g-today - 1) > 50000 then do:
                        create vcdoc.
                        vcdoc.contr = vccontrs.contract.
                        vcdoc.dt = vcdocs.dndate.
                        vcdoc.sts = 2.
                    end.
                end.
                find first vcdoc where vcdoc.contr = vccontrs.contract and vcdoc.sts = 2 no-lock no-error.
                if avail vcdoc then do:
                    v-term = vcdoc.dt.
                end.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsplat) > 0 and
                vcdocs.dndate < vv-date by vcdocs.dndate:
                    vv-summa = vv-summa + vcdocs.sum.
                end.
                vv-term = v-term.
            end.

            v-dolgdays = (g-today - 1) - vv-term.
            v-sumdolg = konv2usd(vv-summa, vccontrs.ncrc, g-today - 1).

            if decimal(v-dolgdays) > check-term(vccontrs.ctterm) and v-sumdolg > 50000 then do:
                assign
                v-sumcon = v-sum-all
                v-sumusd = konv2usd(v-sumcon, vccontrs.ncrc, g-today - 1).
            end.
            else do:
                assign v-sumcon = 0 v-sumusd = 0.
            end.
        end.
    end.
end.
