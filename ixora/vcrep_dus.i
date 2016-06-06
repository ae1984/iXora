/* vcrep_dus.i
 * MODULE
        Название модуля
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
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        25.12.2012 damir - Внедрено Т.З. № 1306.
*/

def var vv-sum-dt as deci.
def var vv-date as date.
def var vv-summa as deci.
def var vv-sum as deci.
def var vv-summ as deci.
def var vv-plus1 as deci.
def var vv-plus2 as deci.
def var vv-term as date.
def var v-term as date.
def var v-payret as deci init 0.
def var v-sum_check as deci.
def var v-PayReturn as deci.

/*Экспортные контракты*/
if lookup(trim(vccontrs.cttype),string({&cttype})) > 0 and trim(vccontrs.expimp) = "E" then do: /*Алгоритм расчета п.м. 9.3.6.5*/
    vv-date = date(s-dte - check_term(vccontrs.ctterm)).
    if v-sumakt > v-sumplat then do:
        vv-sum-dt = v-sumakt - v-sumplat.
        if v-sumakt - v-sumplat > {&limitexp} then do:
            vv-summa = 0.
            if v-sumplat <> 0 then do:
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsakt) > 0 and
                vcdocs.dndate < s-dte by dndate descending:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-sum-dt = vv-sum-dt - v-payret.
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
                        vv-sum = -(vcdoc.sum).
                        vv-plus1 = vv-sum.
                    end.
                    else if vcdoc.sum = 0 then do:
                        vv-sum = 0.
                        vv-plus1 = 0.
                    end.
                end.
                find first vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsakt) > 0 and
                vcdocs.dndate = v-term no-lock no-error.
                if avail vcdocs then do:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-plus2 = v-payret - vv-plus1.
                    if vv-plus2 > {&limitexp} then vv-term = vcdocs.dndate.
                    else do:
                        for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsakt) > 0 and
                        vcdocs.dndate > v-term and vcdocs.dndate < vv-date by dndate:
                            v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                            if vcdocs.payret then v-payret = - v-sum_check.
                            else v-payret = v-sum_check.

                            vv-plus2 = vv-plus2 + v-payret.
                            if vv-plus2 > {&limitexp} then do:
                                create vcdocum.
                                vcdocum.contr = vccontrs.contract.
                                vcdocum.dt    = vcdocs.dndate.
                            end.
                        end.
                        find first vcdocum where vcdocum.contr = vccontrs.contract no-lock no-error.
                        if avail vcdocum then vv-term = vcdocum.dt.
                    end.
                end.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype, v-docsakt) > 0 and
                vcdocs.dndate >= v-term and vcdocs.dndate < vv-date by dndate:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-summa = vv-summa + v-payret.
                end.
                vv-summa = vv-summa - vv-sum.
            end.
            else if v-sumplat = 0 then do:
                vv-summ = 0.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsakt) > 0 and
                vcdocs.dndate < s-dte by dndate:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-summ = vv-summ + v-payret.
                    if vv-summ > {&limitexp} then do:
                        create vcdoc.
                        vcdoc.contr = vccontrs.contract.
                        vcdoc.dt = vcdocs.dndate.
                        vcdoc.sts = 2.
                    end.
                end.
                find first vcdoc where vcdoc.contr = vccontrs.contract and vcdoc.sts = 2 no-lock no-error.
                if avail vcdoc then v-term = vcdoc.dt.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and
                vcdocs.dndate < vv-date by dndate:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-summa = vv-summa + v-payret.
                end.
                vv-term = v-term.
            end.

            /*Возвраты*/
            v-PayReturn = 0.
            for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and
            vcdocs.dndate >= vv-date and vcdocs.dndate < s-dte by dndate:
                v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).
                if vcdocs.payret then v-PayReturn = v-PayReturn + v-sum_check.
            end.

            if deci((s-dte - 1) - vv-term) > check_term(vccontrs.ctterm) and vv-summa - v-PayReturn > {&limitexp} then do:
                v-workcond = true.
            end.
        end.
    end.
end.
/*Импортные контракты*/
else if lookup(trim(vccontrs.cttype),string({&cttype})) > 0 and trim(vccontrs.expimp) = "I" then do: /*Алгоритм расчета п.м. 9.3.6.5*/
    vv-date = date(s-dte - check_term(vccontrs.ctterm)).
    if v-sumakt < v-sumplat then do:
        vv-sum-dt = v-sumplat - v-sumakt.
        if v-sumplat - v-sumakt > {&limitimp} then do:
            vv-summa = 0.
            if v-sumakt <> 0 then do:
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and
                vcdocs.dndate < s-dte by dndate descending:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-sum-dt = vv-sum-dt - v-payret.
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
                        vv-sum = -(vcdoc.sum).
                        vv-plus1 = vv-sum.
                    end.
                    else if vcdoc.sum = 0 then do:
                        vv-sum = 0.
                        vv-plus1 = 0.
                    end.
                end.
                find first vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and
                vcdocs.dndate = v-term no-lock no-error.
                if avail vcdocs then do:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-plus2 = v-payret - vv-plus1.
                    if vv-plus2 > {&limitimp} then vv-term = vcdocs.dndate.
                    else do:
                        for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and
                        vcdocs.dndate > v-term and vcdocs.dndate < vv-date by dndate:
                            v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                            if vcdocs.payret then v-payret = - v-sum_check.
                            else v-payret = v-sum_check.

                            vv-plus2 = vv-plus2 + v-payret.
                            if vv-plus2 > {&limitimp} then do:
                                create vcdocum.
                                vcdocum.contr = vccontrs.contract.
                                vcdocum.dt    = vcdocs.dndate.
                            end.
                        end.
                        find first vcdocum where vcdocum.contr = vccontrs.contract no-lock no-error.
                        if avail vcdocum then vv-term = vcdocum.dt.
                    end.
                end.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and
                vcdocs.dndate >= v-term and vcdocs.dndate < vv-date by dndate:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-summa = vv-summa + v-payret.
                end.
                vv-summa = vv-summa - vv-sum.
            end.
            else if v-sumakt = 0 then do:
                vv-summ = 0.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and
                vcdocs.dndate < s-dte by dndate:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-summ = vv-summ + v-payret.
                    if vv-summ > {&limitimp} then do:
                        create vcdoc.
                        vcdoc.contr = vccontrs.contract.
                        vcdoc.dt = vcdocs.dndate.
                        vcdoc.sts = 2.
                    end.
                end.
                find first vcdoc where vcdoc.contr = vccontrs.contract and vcdoc.sts = 2 no-lock no-error.
                if avail vcdoc then v-term = vcdoc.dt.
                for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0
                and vcdocs.dndate < vv-date by dndate descending:
                    v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).

                    if vcdocs.payret then v-payret = - v-sum_check.
                    else v-payret = v-sum_check.

                    vv-summa = vv-summa + v-payret.
                end.
                vv-term = v-term.
            end.

            /*Возвраты*/
            v-PayReturn = 0.
            for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(trim(vcdocs.dntype),v-docsplat) > 0 and
            vcdocs.dndate >= vv-date and vcdocs.dndate < s-dte by dndate:
                v-sum_check = konv2usd_docs(vcdocs.sum,vcdocs.pcrc,vcdocs.contract,vcdocs.dntype,vcdocs.dndate,recid(vcdocs)).
                if vcdocs.payret then v-PayReturn = v-PayReturn + v-sum_check.
            end.

            if deci((s-dte - 1) - vv-term) > check_term(vccontrs.ctterm) and vv-summa - v-PayReturn > {&limitimp} then do:
                v-workcond = true.
            end.
        end.
    end.

end.