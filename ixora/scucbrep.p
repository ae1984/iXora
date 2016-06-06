/* scucbrep.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        Отчет о ЦБ в наличии
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK
 * AUTHOR
        20.07.2012 id01143 Sayat на основе scublrep.p
        27.08.2012 id01143 Добавлен отбор проведенных проводок на дату очета
        11.09.2012 id01143 Устранено возникновение ошибки при отсутствии котировки на дату отчета
 * CHANGES

*/


{global.i}
{nbankBik.i}
{cb.i}
{is-wrkday.i}
def var i as integer.
def var j as integer.
def var v-grpname as char.
def var v-hdr as char.

def buffer b-jl for jl.
def var vln like jl.ln.
def var nkdoper     as decimal.
def var amortoper   as decimal.
def var peroper     as decimal.
def var v-dt1       as date.

def var costssum as decimal.
def stream v-out.

def temp-table t-scu
field t-scu_scu             like scu.scu
field t-scu_grp             like scu.grp
field t-scu_cat             as integer
field t-scu_gl              like scu.gl
field t-scu_cb              as char
field t-scu_atvalueon       as char
field t-scu_nin             as char
field t-scu_issuedt         as date
field t-scu_mdate           as date
field t-scu_cbegdt          as date
field t-scu_cenddt          as date
field t-scu_intrate         as deci
field t-scu_ncrc            as deci
field t-scu_crc             like crc.crc
field t-scu_ccrc            as char
field t-scu_dealdt          as date
field t-scu_cena            as deci
field t-scu_yield           as deci
field t-scu_cnt             as integer
field t-scu_parval          as deci
field t-scu_discont         as deci
field t-scu_prem            as deci
field t-scu_nkd             as deci
field t-scu_nkdcalc         as deci
field t-scu_nkdoper         as deci
field t-scu_nkdsum          as deci
field t-scu_pol_corr        as deci
field t-scu_otr_corr        as deci
field t-scu_amort           as deci
field t-scu_amortsum        as deci
field t-scu_amortoper       as deci
field t-scu_balsum          as deci
field t-scu_indval          as deci
field t-scu_indsum          as deci
field t-scu_persum          as deci
field t-scu_peroper         as deci
field t-scu_crcrate         as deci
field t-scu_balsumrate      as deci.


def var v-date as date.

def frame f-date
    v-date label "Дата"
with side-labels centered row 7 title "Параметры отчета".


output stream v-out to scuclrep.html.

update  v-date with frame f-date.
for each deal where deal.nin <> "" and deal.deal <> "" and deal.grp <> 0 and deal.regdt <= v-date no-lock:
    find first scu where scu.scu = deal.deal no-lock no-error.
    /*не учитываем закрытые счета*/
    find sub-cod  where sub-cod.acc = scu.scu
        and sub-cod.sub = 'scu' and sub-cod.d-cod = 'clsa' no-lock no-error.
    if avail sub-cod and sub-cod.ccod <> 'msc' and sub-cod.rdt <= v-date then do:
        next.
    end.

    find first scugrp where scugrp.scugrp = deal.grp no-lock no-error.
    find first scu where scu.scu = deal.deal no-lock no-error.
    find first dealref where dealref.nin = deal.nin no-lock no-error.
    find first crc where crc.crc = dealref.crc no-lock no-error.
    find first cbcoupon where cbcoupon.nin = deal.nin and cbcoupon.begdate <= v-date and cbcoupon.enddate > v-date no-lock no-error.
    find first scugrp where scugrp.scugrp = deal.grp no-lock no-error.
    find first indval where indval.nin = dealref.nin and indval.begdate <= v-date and (indval.enddate > v-date or indval.enddate = ?) no-lock no-error.
    find last histrxbal where histrxbal.acc = deal.deal and histrxbal.level = 1 and histrxbal.subled = "SCU" and histrxbal.dt <= v-date and histrxbal.crc = crc.crc no-lock no-error.


    if avail deal and avail dealref and avail histrxbal and avail scu and avail scugrp and histrxbal.dam - histrxbal.cam <> 0 then do:

        create t-scu.
            t-scu.t-scu_scu       =  scu.scu.
            t-scu.t-scu_grp       =  scu.grp.
            t-scu.t-scu_gl        =  scu.gl.

            /* обьединяем гос. и негос. ЦБ*/
            t-scu.t-scu_cat  =  1.
            if  scu.grp = 10 or scu.grp = 20  then do:
                t-scu.t-scu_cat  =  1.
            end.

            if  scu.grp = 40 or scu.grp = 50 or scu.grp = 60  then do:
                t-scu.t-scu_cat  =  2.
            end.

            if  scu.grp = 30 or scu.grp = 70  then do:
                t-scu.t-scu_cat  =  3.
            end.


            t-scu.t-scu_cb = dealref.cb.
            t-scu.t-scu_atvalueon = dealref.atvalueon.
            t-scu.t-scu_nin = dealref.nin.
            t-scu.t-scu_issuedt  = dealref.issuedt.
            t-scu.t-scu_mdate  = dealref.maturedt.
            t-scu.t-scu_ncrc = dealref.ncrc.
            t-scu.t-scu_crc = crc.crc.
            t-scu.t-scu_ccrc = crc.code.
            t-scu.t-scu_dealdt = deal.regdt.
            t-scu.t-scu_cena = deal.ccrc.
            t-scu.t-scu_yield = deal.yield.

            if avail histrxbal then do:
                t-scu.t-scu_parval   =  histrxbal.dam - histrxbal.cam.
            end.
            t-scu.t-scu_cnt = (histrxbal.dam - histrxbal.cam) / dealref.ncrc.

            if avail cbcoupon then do:
                t-scu.t-scu_intrate = cbcoupon.couponrate.
                t-scu.t-scu_cbegdt = cbcoupon.begdate.
                t-scu.t-scu_cenddt = cbcoupon.enddate.
                if dealref.inttype = "A" then do:
                    if cbcoupon.couponcrc = 0 then t-scu.t-scu_nkdcalc = 0.01 * cbcoupon.couponrate * t-scu_parval * DaysInInterval(cbcoupon.begdate,v-date,dealref.base) / DaysInYear(cbcoupon.begdate,dealref.base).
                    else t-scu.t-scu_nkdcalc = cbcoupon.couponrate * DaysInInterval(cbcoupon.begdate,v-date,dealref.base) / DaysInYear(cbcoupon.begdate,dealref.base).
                end.
                /*t-scu.t-scu_nkdcalc = t-scu_nkdcalc - t-scu_nkd.*/
            end.



            find last histrxbal where histrxbal.dt      <=  v-date
                and histrxbal.sub = 'scu'
                and histrxbal.acc = deal.deal
                and histrxbal.crc = t-scu.t-scu_crc
                and histrxbal.lev = 2
                no-lock no-error.
            if avail histrxbal then do:
                t-scu.t-scu_nkd   =  histrxbal.dam - histrxbal.cam.
                v-dt1 = histrxbal.dt.
            end.
            else do:
                t-scu.t-scu_nkd = 0.
                if is-working-day(v-date) then v-dt1 = preworkday(v-date).
                else v-dt1 = preworkday(v-date) - 1.
            end.

            nkdoper = 0.
            for each jl where jl.acc = deal.deal and jl.lev = 2 and jl.jdt > v-dt1 and jl.jdt <= v-date no-lock:
                nkdoper = nkdoper + jl.dam - jl.cam.
            end.
            t-scu.t-scu_nkdoper = nkdoper.

            find last histrxbal where histrxbal.dt      <=  v-date
                and histrxbal.sub = 'scu'
                and histrxbal.acc = deal.deal
                and histrxbal.crc = t-scu.t-scu_crc
                and histrxbal.lev = 4
                no-lock no-error.
            if avail histrxbal then do:
                t-scu.t-scu_discont   =  histrxbal.dam - histrxbal.cam.
                v-dt1 = histrxbal.dt.
            end.
            else do:
                t-scu.t-scu_discont = 0.
                if is-working-day(v-date) then v-dt1 = preworkday(v-date).
                else v-dt1 = preworkday(v-date) - 1.
            end.

            amortoper = 0.
            for each jl where jl.acc = deal.deal and jl.lev = 4 and jl.jdt > v-dt1 and jl.jdt <= v-date no-lock:
                amortoper = amortoper + jl.dam - jl.cam.
            end.

            find last histrxbal where histrxbal.dt      <=  v-date
                and histrxbal.sub = 'scu'
                and histrxbal.acc = deal.deal
                and histrxbal.crc = t-scu.t-scu_crc
                and histrxbal.lev = 5
                no-lock no-error.
            if avail  histrxbal then do:
                t-scu.t-scu_prem    =  histrxbal.dam - histrxbal.cam.
                v-dt1 = histrxbal.dt.
            end.
            else do:
                t-scu.t-scu_prem = 0.
                if is-working-day(v-date) then v-dt1 = preworkday(v-date).
                else v-dt1 = preworkday(v-date) - 1.
            end.

            for each jl where jl.acc = deal.deal and jl.lev = 5 and jl.jdt > v-dt1 and jl.jdt <= v-date no-lock:
                amortoper = amortoper + jl.dam - jl.cam.
            end.
            t-scu.t-scu_amortoper = amortoper.

            find last histrxbal where histrxbal.dt      <=  v-date
                and histrxbal.sub = 'scu'
                and histrxbal.acc = deal.deal
                and histrxbal.crc = t-scu.t-scu_crc
                and histrxbal.lev = 17
                no-lock no-error.
            if avail  histrxbal then do:
                t-scu.t-scu_pol_corr   =  histrxbal.dam - histrxbal.cam.
                v-dt1 = histrxbal.dt.
            end.
            else do:
                t-scu.t-scu_pol_corr = 0.
                if is-working-day(v-date) then v-dt1 = preworkday(v-date).
                else v-dt1 = preworkday(v-date) - 1.
            end.

            peroper = 0.
            for each jl where jl.acc = deal.deal and jl.lev = 17 and jl.jdt > v-dt1 and jl.jdt <= v-date no-lock:
                vln = jl.ln.
                if vln mod 2 = 0 then vln = vln - 1.
                                 else vln = vln + 1.
                find first b-jl where b-jl.jh = jl.jh and b-jl.ln = vln no-lock no-error.
                if not (avail b-jl and b-jl.acc = jl.acc and b-jl.lev = 18) then do:
                    peroper = peroper + jl.dam - jl.cam.
                end.
            end.

            find last histrxbal where histrxbal.dt      <=  v-date
                and histrxbal.sub = 'scu'
                and histrxbal.acc = deal.deal
                and histrxbal.crc = t-scu.t-scu_crc
                and histrxbal.lev = 18
                no-lock no-error.
            if avail histrxbal then do:
                t-scu.t-scu_otr_corr   =  histrxbal.dam - histrxbal.cam.
                v-dt1 = histrxbal.dt.
            end.
            else do:
                t-scu.t-scu_otr_corr = 0.
                if is-working-day(v-date) then v-dt1 = preworkday(v-date).
                else v-dt1 = preworkday(v-date) - 1.
            end.

            for each jl where jl.acc = deal.deal and jl.lev = 18 and jl.jdt > v-dt1 and jl.jdt <= v-date no-lock:
                vln = jl.ln.
                if vln mod 2 = 0 then vln = vln - 1.
                                 else vln = vln + 1.
                find first b-jl where b-jl.jh = jl.jh and b-jl.ln = vln no-lock no-error.
                if not (avail b-jl and b-jl.acc = jl.acc and b-jl.lev = 17) then do:
                    peroper = peroper + jl.dam - jl.cam.
                end.
            end.
            t-scu.t-scu_peroper = peroper.

            t-scu.t-scu_amort = round(cbamortcosts(dealref.nin,v-date,deal.yield) * t-scu_cnt,2).
            if abs(t-scu_discont) + abs(t-scu_prem) <> 0 then t-scu.t-scu_amortsum = t-scu_amort - (abs(t-scu_parval) - abs(t-scu_discont) + abs(t-scu_prem)).
            else t-scu.t-scu_amortsum = 0.

            if t-scu.t-scu_cat  =  1 or t-scu.t-scu_cat  =  2 then do:
                t-scu.t-scu_balsum      = abs(t-scu.t-scu_parval)   - abs(t-scu.t-scu_discont)   + abs(t-scu.t-scu_prem) +
                                          abs(t-scu.t-scu_pol_corr) - abs(t-scu.t-scu_otr_corr) + t-scu_amortsum.
            end. else do:
                t-scu.t-scu_balsum      = abs(t-scu.t-scu_parval) - abs(t-scu.t-scu_discont) + abs(t-scu.t-scu_prem) + t-scu_amortsum.
            end.

            find last crchis where crchis.regdt  <= v-date
                and crchis.crc = t-scu.t-scu_crc no-lock no-error.

            if avail crchis then t-scu.t-scu_crcrate = crchis.rate[1].

            if avail indval then do:
                t-scu.t-scu_indval = indval.rateval.

                if indval.valcrc = 0 then t-scu.t-scu_indsum = round(t-scu_parval * indval.rateval / 100,2).
                else t-scu.t-scu_indsum = round(t-scu_parval * indval.rateval ,2).

                if t-scu.t-scu_cat = 3 then t-scu.t-scu_persum = 0.
                else t-scu.t-scu_persum = t-scu_indsum - t-scu_balsum.

            end.
            else do:
                t-scu.t-scu_indval = 0.
                t-scu.t-scu_indsum = 0.
                t-scu.t-scu_persum = 0.
            end.
            t-scu.t-scu_balsumrate = round((t-scu_balsum + t-scu_persum) * t-scu_crcrate,2).
        end.
end.

put stream v-out unformatted "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h2>Отчет по ЦБ, имеющимся в наличии</h2>" skip.
put stream v-out unformatted  "<br>" string(v-date) "<br>" skip.

find last crchis where crchis.regdt  <= v-date
    and crchis.crc = 2 no-lock no-error.

put stream v-out unformatted  "Курс USD <b>" crchis.rate[1] "</b>" skip.

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                            "<td>N</td>"
                            "<td>N счета scu</td>"
                            "<td>Торговый код</td>"
                            "<td>Эмитент</td>"
                            "<td>НИН</td>"
                            "<td>Дата эмиссии</td>"
                            "<td>Дата погашения</td>"
                            "<td>Дата начала купона</td>"
                            "<td>Дата погашения купона</td>"
                            "<td>Валюта</td>"
                            "<td>Номинал</td>"
                            "<td>Ставка купона, %</td>"
                            "<td>Дата покупки</td>"
                            "<td>Цена покупки, %</td>"
                            "<td>Эффективная ставка, %</td>"
                            "<td>Количество</td>"
                            "<td>Номинальная стоимость</td>"
                            "<td>Начисленное вознаграждение</td>"
                            "<td>Дисконт</td>"
                            "<td>Премия</td>"
                            "<td>Положительная корректировка</td>"
                            "<td>Отрицательная корректировка</td>"
                            "<td>Расчетный НКД на дату отчета</td>"
                            "<td>К начислению</td>"
                            "<td>Начислено(IXORA)</td>"
                            "<td>Амортизируемая стоимость</td>"
                            "<td>Амортизационная стоимость на дату отчета</td>"
                            "<td>Сумма амортизации</td>"
                            "<td>Самортизировано(IXORA)</td>"
                            "<td>Балансовая стоимость</td>"
                            "<td>Рыночная цена, %</td>"
                            "<td>Рыночная стоимость</td>"
                            "<td>Сумма переоценки</td>"
                            "<td>Переоценено(IXORA)</td>"
                            "<td>Курс НБ РК</td>"
                            "<td>Балансовая стоимость по учетному курсу</td>"
                            "</tr>"
                          skip.
j = 1.
for each t-scu break by t-scu.t-scu_cat by t-scu.t-scu_crc by t-scu.t-scu_mdate.

    accumulate t-scu_balsumrate (TOTAL by t-scu.t-scu_cat).

    if first-of (t-scu.t-scu_cat) then do:
        i = 0.
        v-grpname = "".

        if t-scu.t-scu_cat = 1 then do:
            v-grpname = "ЦБ, предназначенные для торговли".
            v-hdr = "<td colspan=""16""><b>" + string(j) + ". " + v-grpname + "</b></td>".
            v-hdr = v-hdr + "<td align=center ><b>120110/120120</b></td>".
            v-hdr = v-hdr + "<td align=center><b>174410/174420</b></td>".
            v-hdr = v-hdr + "<td align=center><b>120510/120520</b></td>".
            v-hdr = v-hdr + "<td align=center><b>120610/120620</b></td>".
            v-hdr = v-hdr + "<td align=center><b>120810/120820</b></td>".
            v-hdr = v-hdr + "<td align=center><b>120910/120920</b></td>".
            v-hdr = v-hdr + "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>".
        end.

        if t-scu.t-scu_cat = 2 then do:
            v-grpname = "ЦБ, имеющиеся в наличии для для продажи".
            v-hdr = "<td colspan=""16""><b>" + string(j) + ". " + v-grpname + "</b></td>".
            v-hdr = v-hdr + "<td align=center><b>145210/145220</b></td>".
            v-hdr = v-hdr + "<td align=center><b>174610/174620</b></td>".
            v-hdr = v-hdr + "<td align=center><b>145311/145312</b></td>".
            v-hdr = v-hdr + "<td align=center><b>145411/145412</b></td>".
            v-hdr = v-hdr + "<td align=center><b>145611/145612</b></td>".
            v-hdr = v-hdr + "<td align=center><b>145711/145712</b></td>".
            v-hdr = v-hdr + "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>".
        end.

        if t-scu.t-scu_cat = 3 then do:
            v-grpname = "ЦБ, удерживаемые до погашения".
            v-hdr = "<td colspan=""16""><b>" + string(j) + ". " + v-grpname + "</b></td>".
            v-hdr = v-hdr + "<td align=center><b>148130/148140</b></td>".
            v-hdr = v-hdr + "<td align=center><b>174530/174540</b></td>".
            v-hdr = v-hdr + "<td align=center><b>148210/148220</b></td>".
            v-hdr = v-hdr + "<td align=center><b>148330/148340</b></td>".
            v-hdr = v-hdr + "<td></td>".
            v-hdr = v-hdr + "<td></td>".
            v-hdr = v-hdr + "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>".
        end.

        if  v-grpname <> "" then do:
            j = j + 1.
        end.

        if v-grpname <> ""  then do:
            put stream v-out unformatted
                           "<tr>"                               skip
                           v-hdr
                           "</tr>"                              skip.
        end.

    end.

    i = i + 1.
    put stream v-out unformatted
                            "<tr>"                          skip
                            "<td>"  string (i)    "</td>"   skip
                            "<td>"  "'" string(t-scu_scu)     "</td>"   skip
                            "<td>"  t-scu_cb    "</td>"   skip
                            "<td>"  t-scu_atvalueon    "</td>"   skip
                            "<td>"  t-scu_nin     "</td>"   skip
                            "<td>"  t-scu_issuedt format "99.99.9999"  "</td>"   skip
                            "<td>"  t-scu_mdate format "99.99.9999"   "</td>"   skip
                            "<td>"  t-scu_cbegdt format "99.99.9999"   "</td>"   skip
                            "<td>"  t-scu_cenddt format "99.99.9999"   "</td>"   skip
                            "<td>"  t-scu_ccrc    "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_ncrc     ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_intrate  ),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  t-scu_dealdt format "99.99.9999"   "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_cena     ),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_yield    ),  "->>>>>>>>>>>>>>9.9999<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  t-scu_cnt     "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_parval   ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_nkd      ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_discont  ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_prem     ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_pol_corr ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_otr_corr ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_nkdcalc  ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_nkdcalc) - abs(t-scu_nkd  ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(    t-scu_nkdoper   ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_parval) - abs(t-scu_discont) + abs(t-scu_prem) ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_amort    ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(    t-scu_amortsum  ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(    t-scu_amortoper ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_balsum   ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_indval   ),  "->>>>>>>>>>>>>>9.99<<<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_indsum   ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(    t-scu_persum    ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(    t-scu_peroper   ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_crcrate  ),  "->>>>>>>>>>>>>>9.99<<<<<<<<")),".",",")  "</td>"   skip
                            "<td>"  replace(trim(string(abs(t-scu_balsumrate),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                            "</tr>" skip.
    if last-of (t-scu.t-scu_cat) then do:

        put stream v-out unformatted
                         "<tr>"                          skip
                         "<td> Всего </td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td><b>"  replace(trim(string(accum total by (t-scu.t-scu_cat) t-scu_balsumrate,  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>"   skip
                         "</tr>" skip.

    end.
end.
output stream v-out close.
unix silent value("cptwin scuclrep.html excel").




