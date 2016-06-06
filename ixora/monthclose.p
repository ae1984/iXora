/* monthclose.p
 * MODULE
        Модуль ЦБ
 * DESCRIPTION
        генерация проводок по операциям закрытия месяца по ЦБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        monthclose.p
 * MENU
        7-1-10
 * BASES
        BANK
 * AUTHOR
        26/06/12 id01143 Kalbagayev Sayat (ТЗ 1328)
 * CHANGES
        27/06/2012 id01143 перекомпиляция в связи с изменением cb.i
        29/06/2012 id01143 перекомпиляция из-за изменений в dates.i
        09/07/2012 id01143 корректировка расчета сумм при переоценке
        15/08/2012 id01143 Исключение из обработки ЦБ приобретенных в дату запуска операций
        20/09/2012 id01143 Добавлен вывод на печать ордеров порождаемых проводок
        26/11/2012 шв01143 Изменено использование шаблона SCU0032 по ТЗ 1374 от 23/05/2012 «Изменение счета ГК 1858»
*/


def shared var g-today  as date.
def new shared var s-jh like jh.jh.
def var dd              as integer.
def var v-select        as integer no-undo.
def var Amount          as decimal.
def var sumcosts        as decimal.
def var NKD             as decimal.
def var NKDCosts        as decimal.
def var AmortCostsNew   as decimal.
def var AmortCostsOld   as decimal.
def var AmortSum        as decimal.
def var er              as decimal.
def var BalSum          as decimal.
def var BalSumNew       as decimal.
def var PereocSum       as decimal.
def var premia          as decimal.
def var discount        as decimal.
def var PereocPlus      as decimal.
def var PereocMinus     as decimal.
def var ReservMSFO      as decimal.
def var ReservKFN       as decimal.
def var reservrateMSFO  as decimal.
def var reservrateKFN   as decimal.
def var reserv-K-M      as decimal.
def var vdel            as char no-undo initial "^".
def var v-param         as char no-undo.
def var v-chet          as char format "x(20)".
def var rcode           as int no-undo.
def var rdes            as char no-undo.
def var sum1            as decimal.
def var sum2            as decimal.
def var lvld            as int.
def var lvlc            as int.
def var crcd            as int.
def var crcc            as int.
def var schemname       as char.
def var plus            as int.
def var v-dt            as date initial today no-undo.
def var des             as char.
def var amort20         as decimal.
def var svertka         as decimal.

run sel3 (" Операции закрытия месяца ", " 1. Начисление НКД | 2. Амортизация скидки/премии | 3. Переоценка ЦБ | 4. ВЫХОД ", output v-select).
/*if v-select = 1 then run dealnew(no).
if v-select = 2 then run dealread(no).
if v-select = 3 then run dealedit(no).*/
if v-select = 5  or v-select = 0 then return.


update v-dt label "Укажите дату операции:..." format "99/99/9999" with centered frame ww row 10 NO-BOX NO-LABELS overlay. pause 0.
hide all.

{is-wrkday.i}
/*{dates.i}*/
{cb.i}
{convgl.i "bank"}

run mondays(month(v-dt),year(v-dt),output dd).
if not is-working-day(v-dt) and day(v-dt) <> dd then do:
    message "Дата операции может быть нерабочим днем только если это последний день месяца!" view-as alert-box.
    return.
end.
if not is-working-day(v-dt) and day(v-dt) = dd then do:
    if preworkday(v-dt) <> today then do:
        message "Проведение операции текущей датой за указанную дату запрещено!" view-as alert-box.
        return.
    end.
end.

if is-working-day(v-dt) and v-dt <> today then do:
    message "Проведение операции за дату являющейся рабочим днем и отличную от текущей запрещено!" view-as alert-box.
    return.
end.

if preworkday(v-dt) <> today and v-dt <> today then do:
    message "Проводить операции за указанную дату текущей датой запрещено!" view-as alert-box.
    return.
end.

for each deal where deal.nin <> "" and deal.grp <> 0 and deal.regdt < v-dt and deal.deal <> "" no-lock by deal.regdt by deal.nin:
    find first scu where scu.scu = deal.deal no-lock no-error.
    find first dealref where dealref.nin = deal.nin no-lock no-error.
    find first cbcoupon where cbcoupon.nin = deal.nin and cbcoupon.begdate <= v-dt and cbcoupon.enddate > v-dt no-lock no-error.
    find first scugrp where scugrp.scugrp = deal.grp no-lock no-error.
    find first indval where indval.nin = dealref.nin and indval.begdate <= v-dt and (indval.enddate > v-dt or indval.enddate = ?) no-lock no-error.
    find first trxbal where trxbal.acc = deal.deal and trxbal.level = 1 and trxbal.subled = "SCU" and trxbal.dam - trxbal.cam <> 0 no-lock no-error.
    if avail deal and avail dealref and avail trxbal and avail scu and avail scugrp then do:
        sumcosts = trxbal.dam - trxbal.cam.
        amount = sumcosts / dealref.ncrc.
        find first trxbal where trxbal.acc = deal.deal and trxbal.level = 2 and trxbal.subled = "SCU" no-lock no-error.
        if avail trxbal then nkdCosts = trxbal.dam - trxbal.cam. else nkdCosts = 0.
        find first trxbal where trxbal.acc = deal.deal and trxbal.level = 4 and trxbal.subled = "SCU" no-lock no-error.
        if avail trxbal then discount = trxbal.cam - trxbal.dam. else discount = 0.
        find first trxbal where trxbal.acc = deal.deal and trxbal.level = 5 and trxbal.subled = "SCU" no-lock no-error.
        if avail trxbal then premia = trxbal.dam - trxbal.cam. else premia = 0.
        find first trxbal where trxbal.acc = deal.deal and trxbal.level = 17 and trxbal.subled = "SCU" no-lock no-error.
        if avail trxbal then pereocplus = trxbal.dam - trxbal.cam. else pereocplus = 0.
        find first trxbal where trxbal.acc = deal.deal and trxbal.level = 18 and trxbal.subled = "SCU" no-lock no-error.
        if avail trxbal then pereocminus = trxbal.cam - trxbal.dam. else pereocminus = 0.
        /*find first trxbal where trxbal.acc = deal.deal and trxbal.level = 3 and trxbal.subled = "SCU" no-lock no-error.*/
        /*if avail trxbal then reservMSFO = trxbal.dam - trxbal.cam. else reservMSFO = 0.
        find first trxbal where trxbal.acc = deal.deal and trxbal.level = ? and trxbal.subled = "SCU" no-lock no-error.
        if avail trxbal then reservKFN = trxbal.dam - trxbal.cam. else reservKFN = 0.
        find first trxbal where trxbal.acc = deal.deal and trxbal.level = ? and trxbal.subled = "SCU" no-lock no-error.
        if avail trxbal then reserv-K-M = trxbal.dam - trxbal.cam. else reserv-K-M = 0.*/
        /*find first trxbal where trxbal.acc = deal.deal and trxbal.level = 20 and trxbal.subled = "SCU" no-lock no-error.
        if avail trxbal then amort20 = absolute(trxbal.dam - trxbal.cam). else amort20 = 0.*/
        er = deal.yield.
        AmortCostsOld = sumcosts + premia - discount.
        if dealref.inttype = "A" and avail cbcoupon then do:
            if cbcoupon.couponcrc = 0 then nkd = 0.01 * cbcoupon.couponrate * sumcosts * DaysInInterval(cbcoupon.begdate,v-dt,dealref.base) / DaysInYear(cbcoupon.begdate,dealref.base).
            else nkd = cbcoupon.couponrate * DaysInInterval(cbcoupon.begdate,v-dt,dealref.base) / DaysInYear(cbcoupon.begdate,dealref.base).
        end.
        else nkd = 0.
        if premia <> 0 or discount <> 0 then AmortCostsNew = cbamortcosts(dealref.nin,v-dt,er) * Amount. else AmortCostsNew = AmortCostsOld.
        /*message string(discount) + "=" + string(AmortCostsOld) + "=" + string(AmortCostsNew) + "=" + string(er) view-as alert-box.*/
        BalSum = round(sumcosts + premia - discount + pereocplus - pereocminus,2).
        if substring(string(scugrp.gl),1,4) <> "1481" and avail indval then do:
            if indval.valcrc = 0 then BalSumNew = round(0.01 * indval.rateval * dealref.ncrc * Amount,2). else BalSumNew = round(indval.rateval * Amount,2).
        end.
        else BalSumNew = BalSum.
        /*find first reservrate where indval.nin = dealref.nin and reservrate.ratetype = 1 and reservrate.begdate <= v-dt and (reservrate.enddate > v-dt or reservrate.enddate = ?) no-lock no-error by reservrate.begdate.
        if avail reservrate then reservrateMSFO = reservrate.rateval. else reservrateMSFO = 0.
        find first reservrate where indval.nin = dealref.nin and reservrate.ratetype = 2 and reservrate.begdate <= v-dt and (reservrate.enddate > v-dt or reservrate.enddate = ?) no-lock no-error by reservrate.begdate.
        if avail reservrate then reservrateKFN = reservrate.rateval. else reservrateKFN = 0.*/

        find first crc where crc.crc = scu.crc no-lock no-error.
        /*начисление НКД*/
        if v-select = 2 then do:
            if nkd - nkdCosts > 0 then do:
                lvld = 2.
                lvlc = 12.
                crcd = scu.crc.
                crcc = 1.
                sum1 = round(nkd - nkdCosts,2).
                sum2 = round((nkd - nkdCosts) * crc.rate[1],2).
            end.
            else do:
                lvld = 12.
                lvlc = 2.
                crcd = 1.
                crcc = scu.crc.
                sum1 = round(absolute(nkd - nkdCosts) * crc.rate[1],2).
                sum2 = round(absolute(nkd - nkdCosts),2).
            end.
            des = "Начисление НКД по " + deal.nin + " за " + string(v-dt,"99/99/9999").
            if crcc = crcd then do:
                v-param = string(sum1) + vdel + string(crcd) + vdel + string(lvld) + vdel + deal.deal + vdel + string(lvlc) + vdel + des.
                schemname = "scu0033".
            end.
            else do:
                v-param = string(sum1) + vdel + string(crcd) + vdel + string(lvld) + vdel + deal.deal + vdel + string(getConvGL(crcd,"C")) + vdel + des + vdel +
                          string(sum2) + vdel + string(crcc) + vdel + string(getConvGL(crcc,"D")) + vdel + string(lvlc) + vdel + des.
                schemname = "scu0032".
            end.
            s-jh = 0. rcode = 0. rdes = "".
            /*message v-param view-as alert-box.*/
            /*message deal.deal view-as alert-box.*/
            if sum1 <> 0 and sum2 <> 0 then run trxgen(schemname,vdel,v-param,"scu",deal.deal,output rcode,output rdes,input-output s-jh).
            if rcode <> 0 then message rdes + "!!!" + v-param view-as alert-box.
            if s-jh <> 0 and rcode = 0 then run vou_bankoperord(2).
        end.
        /*амортизация скидки/премии*/
        if v-select = 3 then do:
            if premia <> 0 then do:
                if AmortCostsNew - AmortCostsOld > 0 then do:
                    lvld = 5.
                    lvlc = 20.
                    crcd = scu.crc.
                    crcc = 1.
                    sum1 = round(AmortCostsNew - AmortCostsOld,2).
                    sum2 = round((AmortCostsNew - AmortCostsOld) * crc.rate[1],2).
                end.
                else do:
                    lvld = 20.
                    lvlc = 5.
                    crcd = 1.
                    crcc = scu.crc.
                    sum1 = round(minimum(absolute(AmortCostsNew - AmortCostsOld),premia) * crc.rate[1],2).
                    sum2 = round(minimum(absolute(AmortCostsNew - AmortCostsOld),premia),2).
                end.
                des = "Амортизация премии по " + deal.nin + " за " + string(v-dt,"99/99/9999").
                if crcc = crcd then do:
                    v-param = string(sum1) + vdel + string(crcd) + vdel + string(lvld) + vdel + deal.deal + vdel + string(lvlc) + vdel + des.
                    schemname = "scu0033".
                end.
                else do:
                    v-param = string(sum1) + vdel + string(crcd) + vdel + string(lvld) + vdel + deal.deal + vdel + string(getConvGL(crcd,"C")) + vdel + des + vdel +
                              string(sum2) + vdel + string(crcc) + vdel + string(getConvGL(crcc,"D")) + vdel + string(lvlc) + vdel + des.
                    schemname = "scu0032".
                end.
                /*message deal.nin + "=" + string(round(AmortCostsNew - AmortCostsOld,2)) + "=" + string(premia) + "=" + string(amort20) view-as alert-box.
                message v-param view-as alert-box.*/
                s-jh = 0. rcode = 0. rdes = "".
                if sum1 <> 0 and sum2 <> 0 then run trxgen(schemname,vdel,v-param,"scu",deal.deal,output rcode,output rdes,input-output s-jh).
                if rcode <> 0 then message rdes + "!!!" + v-param view-as alert-box.
                if s-jh <> 0 and rcode = 0 then run vou_bankoperord(2).
            end.
            if discount <> 0 then do:
                if AmortCostsNew - AmortCostsOld > 0 then do:
                    lvld = 4.
                    lvlc = 19.
                    crcd = scu.crc.
                    crcc = 1.
                    sum1 = round(minimum(AmortCostsNew - AmortCostsOld,discount),2).
                    sum2 = round(minimum(AmortCostsNew - AmortCostsOld,discount) * crc.rate[1],2).
                end.
                else do:
                    lvld = 19.
                    lvlc = 4.
                    crcd = 1.
                    crcc = scu.crc.
                    sum1 = round(absolute(AmortCostsNew - AmortCostsOld) * crc.rate[1],2).
                    sum2 = round(absolute(AmortCostsNew - AmortCostsOld),2).
                end.
                des = "Амортизация дисконта по " + deal.nin + " за " + string(v-dt,"99/99/9999").
                if crcc = crcd then do:
                    v-param = string(sum1) + vdel + string(crcd) + vdel + string(lvld) + vdel + deal.deal + vdel + string(lvlc) + vdel + des.
                    schemname = "scu0033".
                end.
                else do:
                    v-param = string(sum1) + vdel + string(crcd) + vdel + string(lvld) + vdel + deal.deal + vdel + string(getConvGL(crcd,"C")) + vdel + des + vdel +
                              string(sum2) + vdel + string(crcc) + vdel + string(getConvGL(crcc,"D")) + vdel + string(lvlc) + vdel + des.
                    schemname = "scu0032".
                end.
                /*message v-param view-as alert-box.*/
                s-jh = 0. rcode = 0. rdes = "".
                if sum1 <> 0 and sum2 <> 0 then run trxgen(schemname,vdel,v-param,"scu",deal.deal,output rcode,output rdes,input-output s-jh).
                if rcode <> 0 then message rdes + "!!!" + v-param view-as alert-box.
                if s-jh <> 0 and rcode = 0 then run vou_bankoperord(2).
            end.
        end.
        /*переоценка ЦБ*/
        if v-select = 4 then do:
            if BalSumNew - BalSum <> 0 then do:
                if BalSumNew - BalSum > 0 then do:
                    lvld = 17.
                    crcd = scu.crc.
                    sum1 = round(BalSumNew - BalSum,2).
                    if pereocminus > 0  then svertka = minimum(sum1 + pereocplus, pereocminus). else svertka = 0.
                    /*if svertka = pereocminus then sum1 = sum1 + pereocplus - pereocminus.*/
                    /*if svertka = sum1 + pereocplus then sum1 = 0.*/
                    if round(scugrp.gl / 100,0) <> 1452 then do:
                        lvlc = 21.
                        crcc = 1.
                        sum2 = round(sum1 * crc.rate[1],2).
                    end.
                    else do:
                        lvlc = 25.
                        crcc = 1.
                        sum2 = round(sum1 * crc.rate[1],2).
                    end.
                end.
                else do:
                    lvlc = 18.
                    crcc = scu.crc.
                    sum2 = round(absolute(BalSumNew - BalSum),2).
                    if pereocplus > 0  then svertka = minimum(sum2 + pereocminus,pereocplus). else svertka = 0.
                    /*if svertka = pereocplus then sum2 = sum2 + pereocminus - pereocplus.*/
                    /*if svertka = sum2 + pereocminus then sum2 = 0.*/
                    if round(scugrp.gl / 100,0) <> 1452 then do:
                        lvld = 22.
                        crcd = 1.
                        sum1 = round(sum2 * crc.rate[1],2).
                    end.
                    else do:
                        lvld = 25.
                        crcd = 1.
                        sum1 = round(sum2 * crc.rate[1],2).
                    end.
                end.
                des = "Переоценка по " + deal.nin + " за " + string(v-dt,"99/99/9999").
                if crcd = crcc then do:
                    v-param = string(sum1) + vdel + string(crcd) + vdel + string(lvld) + vdel + deal.deal + vdel + string(lvlc) + vdel + des.
                    schemname = "scu0033".
                end.
                else do:
                    v-param = string(sum1) + vdel + string(crcd) + vdel + string(lvld) + vdel + deal.deal + vdel + string(getConvGL(crcd,"C")) + vdel + des + vdel +
                              string(sum2) + vdel + string(crcc) + vdel + string(getConvGL(crcc,"D")) + vdel + string(lvlc) + vdel + des.
                    schemname = "scu0032".
                end.

                s-jh = 0. rcode = 0. rdes = "".
                if sum1 <> 0 and sum2 <> 0 then run trxgen(schemname,vdel,v-param,"scu",deal.deal,output rcode,output rdes,input-output s-jh).
                /*message string(BalSumNew) + "=" + string(BalSum) + "=" + string(pereocplus) + "=" + string(pereocminus) + "=" + string(sum1) + "=" + string(sum2) + "=" + string(svertka) view-as alert-box.*/
                if rcode <> 0 then message rdes + "!!!" + v-param view-as alert-box.
                if s-jh <> 0 and rcode = 0 then run vou_bankoperord(2).
                if round(svertka,2) <> 0  then do:
                    des = "Свертка переоценок по " + deal.nin + " за " + string(v-dt,"99/99/9999").
                    v-param = string(round(svertka,2)) + vdel + string(scu.crc) + vdel + string(18) + vdel + deal.deal + vdel + string(17) + vdel + des.
                    schemname = "scu0033".
                    /*message string(svertka) view-as alert-box.*/
                    s-jh = 0. rcode = 0. rdes = "".
                    run trxgen(schemname,vdel,v-param,"scu",deal.deal,output rcode,output rdes,input-output s-jh).
                    if rcode <> 0 then message rdes + "!!!" + v-param view-as alert-box.
                    if s-jh <> 0 and rcode = 0 then run vou_bankoperord(2).
                end.
            end.
        end.
    end.
end.
/*
run lonbalcrc_txb('lon', txb.lon.lon, bdat, "1,7", no, txb.lon.crc, output bilance).
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var v-chet as char format "x(20)".
def var rcode as int no-undo.
def var rdes as char no-undo.
define new shared variable s-jh like jh.jh.
v-param = string(v_sumk) + vdel +
                          "1" + vdel +
                          v-chet + vdel +
                          v-arp + vdel +
                          "Комиссия за выпуск электронной цифровой подписи (ЭЦП)" + vdel +
                          "840".
run trxgen ("jou0068", vdel, v-param, "cif", v-chet, output rcode, output rdes, input-output s-jh).
*/
