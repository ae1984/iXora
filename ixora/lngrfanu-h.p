/* lngrfanu-h.p
 * MODULE
        3-1-2
 * DESCRIPTION
        вывод аннуитетного графика со сдвигом по празлникам и выходным
 * RUN
        lngrfanu.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        06.01.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        09.01.2012 aigul - добавила бд COMM
        09.01.2012 aigul - добавила расчет дней для погашенных процентов в тот же день когда создавался график
        10.01.2012 aigul - изменила расчет iMonth
        13.01.2012 aigul - изменила вычисление dn3
        16.01.2012 aigul - добавила комменты
*/

{global.i}

def input parameter p-sum as decimal.
def input parameter p-sel as char.
def shared var s-lon like lnsch.lnn.

def shared var v-dt1 as date.
def shared var v-dt2 as date.

def shared temp-table wrk
    field nn as int
    field nni as int
    field stdt as date
    field days as int
    field sumb as decimal
    field od as decimal
    field percent as decimal
    field sump as decimal
    field sume as decimal
    field ch as char.

def var i as int.
def var j as int.
def var d as date.
def var iMonth as int.
def var v-sum as decimal.
def var k as decimal.
def var l as decimal.
def var dn1 as int.
def var dn2 as int.
def var dn3 as int.
def var dn4 as int.
def var prevdt as date.
def var v-ost as decimal.
def var v-dt as date.

def temp-table wrk-dt
  field d as int
  field m as int
  field y as int
  field w as int
  field dt as date.

def buffer b-wrk for wrk.
def var v-od as decimal.
def var v-perc as decimal.
def var v-avail as logical.
def var v-l2 as decimal.
def var v-ep as decimal.


find first lon where lon.lon = s-lon no-lock.

do d = v-dt1 to v-dt2:
  create wrk-dt.
  wrk-dt.d = day(v-dt1).
  wrk-dt.m = month(d).
  wrk-dt.y = year(d).
  if wrk-dt.m = 2 and day(v-dt1) > 28 then do:
    if year(d) mod 4 = 0 then wrk-dt.d = 29.
    else wrk-dt.d = 28.
  end.
  else wrk-dt.d = day(v-dt1).
  if day(v-dt1) = 31 and (month(d) = 4 or month(d) = 6 or month(d) = 9 or month(d) = 11) then wrk-dt.d = 30.
  wrk-dt.dt = date(string(wrk-dt.d) + "/" + string(wrk-dt.m) + "/" + string(wrk-dt.y)).
  if weekday(wrk-dt.dt) = 1 then wrk-dt.w = 7.
  else wrk-dt.w = weekday(wrk-dt.dt) - 1.
end.
for each wrk-dt.
  if weekday(wrk-dt.dt) = 1 then wrk-dt.w = 7.
  else wrk-dt.w = weekday(wrk-dt.dt) - 1.
  if wrk-dt.w = 6 then wrk-dt.dt = wrk-dt.dt + 2.
  if wrk-dt.w = 7 then wrk-dt.dt = wrk-dt.dt + 1.
end.
if lon.grp <> 90 or lon.grp <> 92 then do:
    for each holiday  no-lock:
      for each wrk-dt:
        if wrk-dt.dt = (date(string(holiday.hday) + "/" + string(holiday.hmonth) + "/" + string(wrk-dt.y))) then
        wrk-dt.dt = date(string(holiday.hday) + "/" + string(holiday.hmonth) + "/" + string(wrk-dt.y)) + 1.
        if weekday(wrk-dt.dt) = 1 then wrk-dt.w = 7.
        else wrk-dt.w = weekday(wrk-dt.dt) - 1.
      end.
    end.
end.

for each wrk-dt.
  if weekday(wrk-dt.dt) = 1 then wrk-dt.w = 7.
  else wrk-dt.w = weekday(wrk-dt.dt) - 1.
  if wrk-dt.w = 6 then wrk-dt.dt = wrk-dt.dt + 2.
  if wrk-dt.w = 7 then wrk-dt.dt = wrk-dt.dt + 1.
end.
find last wrk-dt exclusive-lock no-error.
if avail wrk-dt then do:
  wrk-dt.d = day(v-dt2).
  wrk-dt.m = month(v-dt2).
  wrk-dt.y = year(v-dt2).
  wrk-dt.dt = v-dt2.
end.

i = 0.
find first lnsch where lnsch.ln = lon.lon and lnsch.flp > 0 and lnsch.fpn = 0 and lnsch.f0 = 0
and stdat <= today no-lock no-error.
if avail lnsch then v-avail = yes.

/*если были предыдущие платежи*/
if v-avail = yes then do:
    i = 0.
    j = 0.
    /*график дат с предыдущими платежами*/
    for each lnsch where lnsch.ln = lon.lon and lnsch.flp > 0 and lnsch.fpn = 0 and lnsch.f0 = 0
    and lnsch.stdat <= today no-lock:
        i = i + 1.
        create wrk.
        wrk.stdt = lnsch.stdat.
        wrk.nn = i.
    end.
    /*график дат с новыми платежами*/
    for each wrk-dt break by wrk-dt.y by wrk-dt.m:
        if last-of(wrk-dt.m) then do:
            i = i + 1.
            j = j + 1.
            create wrk.
            wrk.nn = i.
            wrk.stdt = wrk-dt.dt.
            wrk.nni = j.
        end.
    end.
    iMonth = round((v-dt2 - v-dt1) * 12 / 365, 0) + 1.
    /*заполнение графика*/
    for each wrk exclusive-lock:
        /*ЕСЛИ ЕСТЬ ПРЕДЫДУЩАЯ ЗАПИСЬ*/
        find first b-wrk where b-wrk.nn = wrk.nn - 1 no-lock no-error.
        if avail b-wrk then do:
            j = j + 1.
            wrk.days = wrk.stdt - b-wrk.stdt.
            if /*wrk.stdt = v-dt1*/ wrk.nni = 1  and p-sel = "3" then wrk.sumb = p-sum.
            else wrk.sumb = b-wrk.sume.
            run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,1,output v-ost).
            if v-ost <> 0 and  /*wrk.stdt = v-dt1*/ wrk.nni = 1 and p-sel = "1" then do:
            wrk.sumb = v-ost.
            end.
            prevdt = b-wrk.stdt.
        end.
        /*ПЕРВАЯ ЗАПИСЬ*/
        else do:
            prevdt = lon.rdt.
            wrk.days = wrk.stdt - lon.rdt.
            wrk.sumb = lon.opnamt.
            l = (lon.prem / 100) / 12.
            run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,1,output v-ost).
            if p-sel = "1" then v-sum = (/*lon.opnamt*/ v-ost * l) / (1 -(1 / exp((1 + l),iMonth))).
            else v-sum = (/*lon.opnamt*/ p-sum * l) / (1 -(1 / exp((1 + l),iMonth))).
        end.

        run day-360(prevdt,wrk.stdt - 1,360,output dn1,output dn2).
        /*если старый график*/
        /*если есть предыдущая оплата по процентам*/
        find first lnsci where lnsci.lni = lon.lon and lnsci.flp > 0 and lnsci.fpn = 0 and lnsci.f0 = 0
        and lnsci.idat = wrk.stdt no-lock no-error.
        if avail lnsci then do:
            wrk.percent = lnsci.paid-iv.
            wrk.sump = wrk.od +  wrk.percent.
            wrk.sume = round(wrk.sumb - wrk.od,2).
        end.
        find first lnsch where lnsch.lnn = lon.lon and lnsch.flp > 0 and lnsch.fpn = 0 and lnsch.f0 = 0
        and lnsch.stdat = wrk.stdt no-lock no-error.
        /*если есть предыдущая оплата по од*/
        if avail lnsch then do:
            wrk.od = lnsch.paid.
            wrk.sump = wrk.od +  wrk.percent.
            wrk.sume = round(wrk.sumb - wrk.od,2).
        end.


        /*если новый график*/
        if wrk.stdt >= v-dt1 then do:
            if wrk.nni = 1 then do:
                run lonbalcrc('lon',lon.lon,g-today,"2,9,4",yes,1,output v-l2). /*проценты на уровнях*/
                if day(wrk.stdt) <> day(v-dt1) then
                v-dt = date(string(day(v-dt1)) + "/" + string(month(wrk.stdt)) + "/" + string(year(wrk.stdt))).
                else v-dt = wrk.stdt.
                /*run day-360(prevdt,v-dt - 30,360,output dn3,output dn4).
                if dn3 = 0 then run day-360(prevdt,wrk.stdt - 1,360,output dn3,output dn4).*/
                run day-360(g-today,wrk.stdt - 1,360,output dn3,output dn4).
                /*проценты с текущего дня(g-today) по след день погашения(wrk.stdt - 1)*/
                v-ep = round(wrk.sumb * lon.prem * dn3 / (360 * 100),2).
                /*проценты на уровнях  + проценты с текущего дня(g-today) по след день погашения(wrk.stdt - 1)*/
                wrk.percent = v-l2 + v-ep.
            end.
            else wrk.percent = round(wrk.sumb * lon.prem * dn1 / (360 * 100),2).
            if wrk.nni = 1 then wrk.sump =  wrk.od + wrk.percent.
            else wrk.sump = round(v-sum,2).


            if round(wrk.sump - wrk.percent,2) <= 0 then do:
                v-perc = round(wrk.sumb * lon.prem * 30 / (360 * 100),2).
                wrk.od = round(wrk.sump - v-perc,2).
                if wrk.nni = 1 then wrk.sump =  wrk.od + wrk.percent.
                else wrk.sump = wrk.sump - round(wrk.sump - wrk.percent,2).
            end.
            else  wrk.od = round(wrk.sump - wrk.percent,2).
            if wrk.nni = 1 then do:
                wrk.od = v-sum - /*(wrk.sumb * lon.prem * 30 / (360 * 100))*/ wrk.percent.
                wrk.sump =  wrk.od + wrk.percent.
            end.
            wrk.sume = round(wrk.sumb - wrk.od,2).
        end.
    end.
    /*последний платеж*/
    find last wrk exclusive-lock no-error.
    if avail wrk then do:
        wrk.od = round(wrk.sumb,2).
        wrk.sume = round(wrk.sumb - wrk.od,2).
        wrk.sump =  wrk.od + wrk.percent.
    end.
end.


if v-avail = no then do:
    i = 0.
    for each wrk-dt break by wrk-dt.y by wrk-dt.m:
        if last-of(wrk-dt.m) then do:
            i = i + 1.
            create wrk.
            wrk.nn = i.
            wrk.stdt = wrk-dt.dt.
        end.
    end.
    /*iMonth = round((v-dt2 - v-dt1) * 12 / 365, 0).*/
    find last wrk.
    iMonth = wrk.nn.
    for each wrk exclusive-lock:
        find first b-wrk where b-wrk.nn = wrk.nn - 1 no-lock no-error.
        if avail b-wrk then do:
            wrk.days = wrk.stdt - b-wrk.stdt.
            wrk.sumb = b-wrk.sume.
            prevdt = b-wrk.stdt.
        end.
        else do:
            prevdt = lon.rdt.
            wrk.days = wrk.stdt - lon.rdt.
            wrk.sumb = /*lon.opnamt*/ p-sum.

            l = (lon.prem / 100) / 12.
            v-sum = (/*lon.opnamt*/ p-sum * l) / (1 -(1 / exp((1 + l),iMonth))).
        end.
        if prevdt = ? then prevdt = wrk.stdt.
        wrk.sump = round(v-sum,2).
        run day-360(prevdt,wrk.stdt - 1,360,output dn1,output dn2).
        wrk.percent = round(wrk.sumb * lon.prem * dn1 / (360 * 100),2).
        if round(wrk.sump - wrk.percent,2) < 0 then do:
            v-perc = round(wrk.sumb * lon.prem * 30 / (360 * 100),2).
            wrk.od = round(wrk.sump - v-perc,2).
            wrk.sump = wrk.sump - round(wrk.sump - wrk.percent,2).
        end.
        else wrk.od = round(wrk.sump - wrk.percent,2).
        wrk.sume = round(wrk.sumb - wrk.od,2).
        wrk.ch = string(lon.prem / 100) + "*" + string(exp(l,iMonth)) + "/" + string(exp(l,iMonth)) + " - 1".
        v-od = v-od + wrk.od.
    end.
    find last wrk exclusive-lock no-error.
    if avail wrk then do:
        v-od = v-od - wrk.od.
        wrk.od = round(/*lon.opnamt*/ p-sum - v-od,2).
        wrk.sume = round(wrk.sumb - wrk.od,2).
        wrk.sump = wrk.od + wrk.percent.
    end.
    find first wrk exclusive-lock no-error.
    if avail wrk then wrk.sump = wrk.od + wrk.percent.
end.

