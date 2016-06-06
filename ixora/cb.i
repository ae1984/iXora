/* cb.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        26/06/2012 s.kalbagayev id01143 функции для расчетов по ЦБ (ТЗ 1328)
 * CHANGES
        29/06/2012 id01143 перекомпиляция из-за изменений в dates.i
*/
{dates.i}

function cbAmortCosts returns decimal (input p-nin as char, input p-dt as date, input p-er as decimal).
/*
функция возвращает амортизационную стоимость ЦБ на дату по эффективной ставке
p-nin - НИН ЦБ (ссылка на ЦБ)
p-dt  - дата расчета
p-er  - эффективная ставка


-- Формула:
-- Для купонных
--              100                         Ki
-- AP = ( -------------    )  + ( сумма -------------)   - (K*Tk/To)
--              (Mn*Tn/To)                   (Mi*Tki/To)
--        (1+Y/100*Mn)                   (1+Y/100*Mi)
-- Для Дисконтных:    исходная    преобразованная через номинальную стоимость
--               N
--    APD= --------------
--          DSM
--         -----*ERD + 1
--           B
-- N - Номинальная стоимость
-- Ki - номинальная процентная ставка на i-й период
-- Mi - базисный коэффициент вычисляется по формуле Mi=To/Ti, где Ti - продолжительность i-го купонного периода
-- P - цена приобретени
-- A - количество дней от начала периода купона до даты приобретени
-- E - количество дней в периоде купона, на который приходится дата расчета
-- Y - эффективная ставка процента по ЦБ
-- С- количество оплачиваемых купонов между датой приобретения и датой Погашени
-- k - количество неоплаченных купонов между датой приобретения и датой Погашени
-- DSС - количество дней от даты расчета до даты следующего купона.
-- DSМ - количество дней от даты расчета до даты погашения (для расчета по дисконтным облигациям).
-- В- количество дней в году,  в зависимости от используемого базиса.
*/
def var am as decimal.
def var nd as integer.
def var nb as integer.
def var nt as integer.
def var nk as decimal.
def var nt1 as integer.
def var nt2 as integer.
def var nm as decimal.
find first dealref where dealref.nin = p-nin no-lock no-error.
if not avail dealref or dealref.maturedt < p-dt then return(am).
find first cbcoupon where cbcoupon.nin = dealref.nin and cbcoupon.enddate > p-dt no-lock no-error.
/*message "1am=" + string(am, "->>>>>>>>>>99.9999<<<<<<<<<") view-as alert-box.*/
if dealref.inttype = "D" or not avail cbcoupon then do:
    nd = daysininterval(p-dt, dealref.maturedt, dealref.base).
    if dealref.base = "30/360" or dealref.base = "31/360" then nb = 360.
    else nb = monthsadd(p-dt,12) - p-dt.
    am = dealref.ncrc / (1 + 0.01 * nd * p-er / nb).
    /*message "2am=" + string(am, "->>>>>>>>>>99.9999<<<<<<<<<") view-as alert-box.*/
end.
else do:
    if dealref.base = "30/360" or dealref.base = "31/360" then nb = 360.
    else nb = monthsadd(p-dt,12) - p-dt.
    if cbcoupon.couponcrc = 0 then nk = cbcoupon.couponrate.
    else nk = (cbcoupon.couponrate / dealref.ncrc) * (12 / dealref.coupper) * 100.
    nt1 = daysininterval(cbcoupon.begdate, p-dt, dealref.base).
    am = - nk * nt1 / nb.
    /*displ 0 nk nt1 nb - nk * nt1 / nb am format "->>>>>>>>>>>>9.99<<<<<<<<<" skip.*/
    /*message "3am=" + string(am, "->>>>>>>>>>99.9999<<<<<<<<<") view-as alert-box.*/
    for each cbcoupon where cbcoupon.nin = dealref.nin and cbcoupon.enddate > p-dt no-lock:
        nt1 = daysininterval(p-dt, cbcoupon.EndDate, dealref.base).
        nt2 = daysininterval(cbcoupon.BegDate, cbcoupon.EndDate, dealref.base).
        nM = nb / nt2.
        if cbcoupon.couponcrc = 0 then nk = cbcoupon.couponrate.
        else nk = (cbcoupon.couponrate / dealref.ncrc) * (12 / dealref.coupper) * 100.
        nK = nk / nM.
        /*displ 11 nm format "->>>>>>>>>>>>>9.99<<<<<<<<<<" nT1 format "->>>>>>>>>>>>9.99<<<<<<<<<<" nb p-er am format "->>>>>>>>>>>>9.99<<<<<<<<<" exp(1 + p-er / 100 / nM, nM * nT1 / nb) skip.*/
        if exp(1 + p-er / 100 / nM, nM * nT1 / nb) = ? or exp(1 + p-er / 100 / nM, nM * nT1 / nb) = 0  then return ?.
        Am = am + nK / exp(1 + p-er / 100 / nM, nM * nT1 / nb).
        /*displ 12 am format "->>>>>>>>>>>>>9.99<<<<<<<<<<" 1 + p-er / 100 / nM nM * nT1 / nb skip.*/
    end.
    /*displ 21 nm format "->>>>>>>>>>>>>9.99<<<<<<<<" nT1 format "->>>>>>>>>>>>>9.99<<<<<<<<" nb p-er skip.*/
    am = am + 100 / exp(1 + p-er / 100 / nM, nM * nT1 / nb).
    /*displ 22 am format "->>>>>>>>>>9.99<<<<<<<<" 1 + p-er / 100 / nM nM * nT1 / nb skip.*/
    am = am * dealref.ncrc * 0.01.
    /*message "4am=" + string(am, "->>>>>>>>>>99.9999<<<<<<<<<") view-as alert-box.*/
end.
return(am).
end function.


function dfcbAmortCosts returns decimal (input p-nin as char, input p-dt as date, input p-er as decimal).
/*
функция возвращает производную первого порядка от формулы аморт. стоимости относительно эффективной ставки
p-nin - НИН ЦБ (ссылка на ЦБ)
p-dt  - дата расчета
p-er  - эффективная ставка


-- Формула:
-- Для купонных
--              100                         Ki
-- AP = ( -------------    )  + ( сумма -------------)   - (K*Tk/To)
--              (Mn*Tn/To)                   (Mi*Tki/To)
--        (1+Y/100*Mn)                   (1+Y/100*Mi)
-- Для Дисконтных:    исходная    преобразованная через номинальную стоимость
--               N                                 -1          N*B*DSM
--    APD= --------------   APD' = (N*B*(DSM*ERD+B)   )'= - -----------
--          DSM                                                       2
--         -----*ERD + 1                                    (DSM*ERD+B)
--           B
-- N - Номинальная стоимость
-- Ki - номинальная процентная ставка на i-й период
-- Mi - базисный коэффициент вычисляется по формуле Mi=To/Ti, где Ti - продолжительность i-го купонного периода
-- P - цена приобретени
-- A - количество дней от начала периода купона до даты приобретени
-- E - количество дней в периоде купона, на который приходится дата расчета
-- Y - эффективная ставка процента по ЦБ
-- С- количество оплачиваемых купонов между датой приобретения и датой Погашени
-- k - количество неоплаченных купонов между датой приобретения и датой Погашени
-- DSС - количество дней от даты расчета до даты следующего купона.
-- DSМ - количество дней от даты расчета до даты погашения (для расчета по дисконтным облигациям).
-- В- количество дней в году,  в зависимости от используемого базиса.
*/
def var am as decimal.
def var nd as integer.
def var nb as integer.
def var nt as integer.
def var nk as decimal.
def var nt1 as integer.
def var nt2 as integer.
def var nm as decimal.
find first dealref where dealref.nin = p-nin no-lock no-error.
if not avail dealref or dealref.maturedt < p-dt then return(am).
find first cbcoupon where cbcoupon.nin = dealref.nin and cbcoupon.enddate > p-dt no-lock no-error.
/*message "1am=" + string(am, "->>>>>>>>>>99.9999<<<<<<<<<") view-as alert-box.*/
if dealref.inttype = "D" or not avail cbcoupon then do:
    nd = daysininterval(p-dt, dealref.maturedt, dealref.base).
    if dealref.base = "30/360" or dealref.base = "31/360" then nb = 360.
    else nb = monthsadd(p-dt,12) - p-dt.
    /*am = dealref.ncrc / (1 + (nd * p-er / nb)).*/
    /*am = - dealref.ncrc * nb * nd / exp(nd * p-er + nb, 2).*/
    am = - dealref.ncrc * 0.01 * (nd / nb) * exp(1 + nd * 0.01 * p-er / nb, -2).

    /*message "2am=" + string(am, "->>>>>>>>>>99.9999<<<<<<<<<") view-as alert-box.*/
end.
else do:
    if dealref.base = "30/360" or dealref.base = "31/360" then nb = 360.
    else nb = monthsadd(p-dt,12) - p-dt.
    if cbcoupon.couponcrc = 0 then nk = cbcoupon.couponrate.
    else nk = (cbcoupon.couponrate / dealref.ncrc) * (12 / dealref.coupper) * 100.
    nt1 = daysininterval(cbcoupon.begdate, p-dt, dealref.base).
    am = 0.

    /*message "3am=" + string(am, "->>>>>>>>>>99.9999<<<<<<<<<") view-as alert-box.*/
    for each cbcoupon where cbcoupon.nin = dealref.nin and cbcoupon.enddate > p-dt no-lock:
        nt1 = daysininterval(p-dt, cbcoupon.EndDate, dealref.base).
        nt2 = daysininterval(cbcoupon.BegDate, cbcoupon.EndDate, dealref.base).
        nM = nb / nt2.
        if cbcoupon.couponcrc = 0 then nk = cbcoupon.couponrate.
        else nk = (cbcoupon.couponrate / dealref.ncrc) * (12 / dealref.coupper) * 100.
        nK = nk / nM.
        if 1 + p-er / 100 / nM = 0  then return ?.
        /*Am = am + nK / exp(1 + p-er / 100 / nM, nM * nT1 / nb).*/
        am = am - 0.01 * nK * nT1 / nb / exp (1 + 0.01 * p-er / nM, 1 + nM * nT1 / nb).

    end.
    /*am = am + 100 / exp(1 + p-er / 100 / nM, nM * nT1 / nb).*/
    am = am - nT1 / nb / exp (1 + 0.01 * p-er / nM, 1 + nM * nT1 / nb).
    am = am * dealref.ncrc * 0.01.
    /*message "4am=" + string(am, "->>>>>>>>>>99.9999<<<<<<<<<") view-as alert-box.*/
end.
return(am).
end function.

function cbEffRate returns decimal (input p-nin as char, input p-dt as date, input p-price as decimal).
/*
функция возвращает значение эффективной ставки по ЦБ на дату исходя из цены
p-nin - НИН ЦБ (ссылка на ЦБ)
p-dt  - дата расчета
p-price  - цена

-- Формула:
-- Для купонных
-- Рассчет производится итерационным методом (подбор) при помощи функции расчета амортизационной стоимости cbAmortCosts
-- Для Дисконтных:
--       N-P     B
--  ERD=----- * ---
--        P     DSM
-- N - Номинальная стоимость
-- P - цена
-- ERD - значение эффективной ставки
-- DSМ - количество дней от даты расчета до даты погашения (для расчета по дисконтным облигациям).
-- В- количество дней в году,  в зависимости от используемого базиса.
*/
def var er  as decimal.
def var nd  as integer.
def var nb  as integer.
def var nx  as decimal initial -100.
def var ny  as decimal initial 1.
def var nz  as decimal.
def var nz1 as decimal.
def var nk  as decimal initial 0.00000001.
def var i   as integer initial 0.
def var n   as integer initial 10.
def var nm  as decimal.

find first dealref where dealref.nin = p-nin no-lock no-error.
if not avail dealref or dealref.maturedt < p-dt then return(er).
find first cbcoupon where cbcoupon.nin = dealref.nin and cbcoupon.enddate > p-dt no-lock no-error.
/*message "1er=" + string(er, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
if dealref.inttype = "D" or not avail cbcoupon then do:
    nd = daysininterval(p-dt, dealref.maturedt, dealref.base).

    if dealref.base = "30/360" or dealref.base = "31/360" then nb = 360.
    else nb = monthsadd(p-dt,12) - p-dt.

    er = (dealref.ncrc - p-price) / p-price * nb / nd.
    er = er * 100.
    /*message "2er=" + string(er, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
end.
else do:
    if dealref.coupper = 0 then nm = 1.
    else nm = 12 / dealref.coupper.
    nx = nx * nm.
    /*message "nx=" + string(nx, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
    do while cbAmortCosts( dealref.nin, p-dt, nx) = ? :
        i = i + 1.
        nx = nx + exp(10, -10).
        if i > 10 and n > 0 then do:
            n = n - 1.
            i = 0.
        end.
    end.
    /*message "nx=" + string(nx, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
    displ nx format "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<".
    do While (p-price - cbAmortCosts( dealref.nin, p-dt, nx))*(p-price - cbAmortCosts( dealref.nin, p-dt, ny)) > 0 :
      ny = ny * 2.
    end.
    /*message "ny=" + string(ny, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
    displ ny format "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<".
    if cbAmortCosts( dealref.nin, p-dt, nx) = p-price then return(nx).
    if cbAmortCosts( dealref.nin, p-dt, ny) = p-price then return(ny).
    nz = (nx + ny) / 2.
    repeat :
        if cbAmortCosts( dealref.nin, p-dt, nz) = p-price then leave. /*return(nz).*/
        else do:
            if (p-price - cbAmortCosts( dealref.nin, p-dt, nx)) * (p-price - cbAmortCosts( dealref.nin, p-dt, nz)) <0 then ny = nz.
            else do:
                if (p-price - cbAmortCosts( dealref.nin, p-dt, ny)) * (p-price - cbAmortCosts( dealref.nin, p-dt, nz)) <0 then nx = nz.
            end.
        end.
        if absolute(p-price - cbAmortCosts( dealref.nin, p-dt, nz)) < nk then leave. /*return(nz).*/
        nz1 = nz.
        nz = (nx + ny) / 2.
        if absolute(nz1 - nz) < nk then leave. /*return(nz).*/
    end.
    er = nz.
    /*message "4er=" + string(er, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
end.
return(er).

end function.

function cbEffRateN returns decimal (input p-nin as char, input p-dt as date, input p-price as decimal).
/*
функция возвращает значение эффективной ставки по ЦБ на дату исходя из цены
p-nin - НИН ЦБ (ссылка на ЦБ)
p-dt  - дата расчета
p-price  - цена

-- Формула:
-- Для купонных
-- Рассчет производится итерационным методом (подбор) при помощи функции расчета амортизационной стоимости cbAmortCosts
-- Для Дисконтных:
--       N-P     B
--  ERD=----- * ---
--        P     DSM
-- N - Номинальная стоимость
-- P - цена
-- ERD - значение эффективной ставки
-- DSМ - количество дней от даты расчета до даты погашения (для расчета по дисконтным облигациям).
-- В- количество дней в году,  в зависимости от используемого базиса.
*/
def var er  as decimal.
def var nd  as integer.
def var nb  as integer.
def var nx  as decimal initial -100.
def var ny  as decimal initial 1.
def var nz  as decimal.
def var nz1 as decimal.
def var nk  as decimal initial 0.000000001.
def var i   as integer initial 0.
def var n   as integer initial 10.
def var nm  as decimal.

find first dealref where dealref.nin = p-nin no-lock no-error.
if not avail dealref or dealref.maturedt < p-dt then return(er).
find first cbcoupon where cbcoupon.nin = dealref.nin and cbcoupon.enddate > p-dt no-lock no-error.
/*message "1er=" + string(er, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
if dealref.inttype = "D" or not avail cbcoupon then do:
    nd = daysininterval(p-dt, dealref.maturedt, dealref.base).

    if dealref.base = "30/360" or dealref.base = "31/360" then nb = 360.
    else nb = monthsadd(p-dt,12) - p-dt.

    er = (dealref.ncrc - p-price) / p-price * nb / nd.
    er = er * 100.
    /*message "2er=" + string(er, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
end.
else do:
    if dealref.coupper = 0 then nm = 1.
    else nm = 12 / dealref.coupper.
/*    nx = nx * nm.
    do while cbAmortCosts( dealref.nin, p-dt, nx) = ? :
        i = i + 1.
        nx = nx + exp(10, - n).
        if i > 10 and n > 0 then do:
            n = n - 1.
            i = 0.
        end.
    end.
    */
    nx = 0.
    ny = nx + (p-price - cbAmortCosts( dealref.nin, p-dt, nx)) / dfcbAmortCosts( dealref.nin, p-dt, nx).

    if cbAmortCosts( dealref.nin, p-dt, nx) = p-price then return(nx).
    if cbAmortCosts( dealref.nin, p-dt, ny) = p-price then return(ny).
    repeat :
        if absolute(cbAmortCosts( dealref.nin, p-dt, nx) - cbAmortCosts( dealref.nin, p-dt, ny)) < nk or absolute(nx - ny) < nk then leave. /*return(nz).*/
        else do:
            nx = ny.
            ny = nx + (p-price - cbAmortCosts( dealref.nin, p-dt, nx)) / dfcbAmortCosts( dealref.nin, p-dt, nx).
        end.
    end.
    er = nx.
    /*message "4er=" + string(er, "->>>>>>>>>>>>>>>>>>>>9.9999<<<<<<") view-as alert-box.*/
end.
return(er).

end function.