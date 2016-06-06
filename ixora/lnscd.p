/* lnscd.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Пересчет графика - перенос платежей с выходных дней
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
        11/10/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        12/10/2010 madiyar - перекомпиляция
        05/03/2011 madiyar - для аннуитета пришлось сделать запрос суммы ОД для пересчета
        31/08/2011 kapar - новый алгоритм исчисления 365/366 дней в году для (овердрафт и факторинг)
        11.01.2012 aigul - добавила праздничные дни
*/

def input parameter p-sel as char.
def input parameter p-sum as decimal.
def shared var s-lon like lnsch.lnn.
def shared var g-today as date.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
    message "lon не найден!" view-as alert-box error.
    return.
end.

if lon.opnamt = 0 then do:
    message "lon.opnamt = 0!" view-as alert-box error.
    return.
end.

if lon.plan = 4 or lon.plan = 5 then return.

def temp-table t-lnsch like lnsch.
def temp-table t-lnsci like lnsci.
def temp-table t-lnscs like lnscs.

def buffer b-lnsch for t-lnsch.
def buffer b-lnsci for t-lnsci.
def buffer b-lnscs for t-lnscs.

def var v-sum0 as deci no-undo format ">>>,>>>,>>>,>>>,>>9.99".
def var v-sum as deci no-undo.
def var v-prc as deci no-undo.
def var v-dt as date no-undo.
def var v-dtc as date no-undo.
def var v-prem as deci no-undo.
def var v-prems as deci no-undo.

def var dn1 as integer no-undo.
def var dn2 as deci no-undo.

def stream rep.
/*
def var v-sel as char init ''.
run sel2 ("Выбор :", " 1. Пересчет от остатка ОД | 2. Пересчет от одобренной суммы | 3. Пересчет от произвольной суммы", output v-sel).
case v-sel:
    when '1' then run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-sum0).
    when '2' then v-sum0 = lon.opnamt.
    when '3' then do:
        run atl-dat1(input lon.lon, input g-today, input 3, output v-sum0).*/
        /*v-sum0 = lon.opnamt.*/
        /*update v-sum0 label " Введите сумму" validate(v-sum0 > 0, " Ошибка!") with centered row 5 side-label frame fr.
    end.
    otherwise do:
        message " Некорректный выбор. Пересчет не произведен." view-as alert-box.
        return.
    end.
end case.
*/

def var v_dd      as int.
def var v_basedy  as int.
def var v_day     as int.
def var v_prnmos  as int.
def var v_rdt     as date.
v_prnmos = lon.prnmos.
v_rdt = lon.rdt.

if p-sel <> "" then do:
    case p-sel:
        when '1' then run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-sum0).
        when '2' then v-sum0 = lon.opnamt.
        when '3' then do:
            v-sum0 = p-sum.
        end.
    end case.
end.
else do:
    run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-sum0).
    if v-sum0 = 0 then v-sum0 = lon.opnamt.
end.
if v-sum0 = 0 then do:
    message "Перенос платежей с выходных дней:~nНет суммы по ОД, перенос не произведен!" view-as alert-box error.
    return.
end.

v-prem = 0.
if lon.prem > 0 then v-prem = lon.prem.
else do:
    find last ln%his where ln%his.lon = lon.lon and ln%his.intrate > 0 no-lock no-error.
    if avail ln%his then v-prem = ln%his.intrate.
end.

if v-prem = 0 then do:
    message "Перенос платежей с выходных дней:~nНевозможно определить ставку по процентам, перенос не произведен!" view-as alert-box error.
    return.
end.

v-prems = 0.
find first lons where lons.lon = lon.lon no-lock no-error.
if avail lons then v-prems = lons.prem.

empty temp-table t-lnsch.
empty temp-table t-lnsci.
empty temp-table t-lnscs.

for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock:
    create t-lnsch.
    buffer-copy lnsch to t-lnsch.
end.

for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock:
    create t-lnsci.
    buffer-copy lnsci to t-lnsci.
end.

for each lnscs where lnscs.lon = lon.lon and lnscs.sch no-lock:
    create t-lnscs.
    buffer-copy lnscs to t-lnscs.
end.


for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat >= g-today no-lock:
    for each holiday where holiday.hday = day(lnsch.stdat) and holiday.hmonth = month(lnsch.stdat) no-lock:
        if lnsch.stdat <> lon.duedt then do:
            run chk-holiday(lnsch.stdat, output v-dt).
            find first t-lnsch where t-lnsch.lnn = lnsch.lnn and t-lnsch.f0 = lnsch.f0 and t-lnsch.stdat = lnsch.stdat no-lock no-error.
            if avail t-lnsch then t-lnsch.stdat = v-dt.
        end.
    end.

    if ((weekday(lnsch.stdat) = 1) or (weekday(lnsch.stdat) = 7)) and lnsch.stdat <> lon.duedt then do:
        if weekday(lnsch.stdat) = 1 then v-dt = lnsch.stdat + 1.
        else v-dt = lnsch.stdat + 2.

        /*find first t-lnsch where t-lnsch.lnn = lon.lon and t-lnsch.f0 > 0 and t-lnsch.stdat > lnsch.stdat and t-lnsch.stdat <= v-dt no-lock no-error.
        if avail t-lnsch then do:
            message lnsch.stdat t-lnsch.stdat view-as alert-box.
            message "Перенос платежей с выходных дней:~nНевозможно сдвинуть запись в графике ОД с " +
            string(lnsch.stdat,"99/99/99") + " на " + string(v-dt,"99/99/99") + "!" view-as alert-box error.
            return.
        end.*/
        find first t-lnsch where t-lnsch.lnn = lnsch.lnn and t-lnsch.f0 = lnsch.f0 and t-lnsch.stdat = lnsch.stdat no-lock no-error.
        if avail t-lnsch then t-lnsch.stdat = v-dt.
    end.
end.

for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat >= g-today no-lock:
    for each holiday where holiday.hday = day(lnsci.idat) and holiday.hmonth = month(lnsci.idat) no-lock:
        if lnsci.idat <> lon.duedt then do:
            run chk-holiday(lnsci.idat, output v-dt).
            find first t-lnsci where t-lnsci.lni = lnsci.lni and t-lnsci.f0 = lnsci.f0 and t-lnsci.idat = lnsci.idat no-lock no-error.
            if avail t-lnsci then t-lnsci.idat = v-dt.
        end.
    end.
    if ((weekday(lnsci.idat) = 1) or (weekday(lnsci.idat) = 7)) and lnsci.idat <> lon.duedt then do:

        v-dtc = lnsci.idat.

        if weekday(lnsci.idat) = 1 then v-dt = v-dtc + 1.
        else v-dt = v-dtc + 2.

        /*find first t-lnsci where t-lnsci.lni = lon.lon and t-lnsci.f0 > 0 and t-lnsci.idat > v-dtc and t-lnsci.idat <= v-dt no-lock no-error.
        if avail t-lnsci then do:
            message "Перенос платежей с выходных дней:~nНевозможно сдвинуть запись в графике %% с " + string(v-dtc,"99/99/99") + " на " + string(v-dt,"99/99/99") + "!" view-as alert-box error.
            return.
        end.*/

        v-sum = v-sum0.
        for each t-lnsch where t-lnsch.lnn = lon.lon and t-lnsch.f0 > 0 and t-lnsch.stdat >= g-today and t-lnsch.stdat <= v-dtc no-lock:
            v-sum = v-sum - t-lnsch.stval.
        end.

        if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
          run mondays(2,year(v-dtc),output v_dd).
          if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
          v_day = day(v-dtc).
        end.
        else
          v_basedy = lon.basedy.

        run day-360(v-dtc,v-dtc,v_basedy,output dn1,output dn2).
        /*v-prc = dn1 * v-sum * v-prem / 100 / 360.*/
        if (month(v-dtc) = 1) and (v_basedy = 366) then
          v-prc = (v_day * v-sum * v-prem / 100 / v_basedy) + ((dn1 - v_day) * v-sum * v-prem / 100 / v_basedy).
        else
          v-prc = dn1 * v-sum * v-prem / 100 / v_basedy.

        v-dtc = v-dtc + 1.
        if v-dtc < v-dt then do:
            for each t-lnsch where t-lnsch.lnn = lon.lon and t-lnsch.f0 > 0 and t-lnsch.stdat = v-dtc no-lock:
                v-sum = v-sum - t-lnsch.stval.
            end.

            if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
              run mondays(2,year(v-dtc),output v_dd).
              if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
              v_day = day(v-dtc).
            end.
            else
              v_basedy = lon.basedy.

            run day-360(v-dtc,v-dtc,v_basedy,output dn1,output dn2).
            /*v-prc = v-prc + dn1 * v-sum * v-prem / 100 / 360.*/
            if (month(v-dtc) = 1) and (v_basedy = 366) then
              v-prc = v-prc + (v_day * v-sum * v-prem / 100 / v_basedy) + ((dn1 - v_day) * v-sum * v-prem / 100 / v_basedy).
            else
              v-prc = v-prc + dn1 * v-sum * v-prem / 100 / v_basedy.

        end.

        find first t-lnsci where t-lnsci.lni = lnsci.lni and t-lnsci.f0 = lnsci.f0 and t-lnsci.idat = lnsci.idat no-lock no-error.
        if avail t-lnsci then do:
            t-lnsci.idat = v-dt.
            t-lnsci.iv-sc = t-lnsci.iv-sc + round(v-prc,2).
        end.
        /* скорректируем следующий платеж */
        find first t-lnsci where t-lnsci.lni = lnsci.lni and t-lnsci.f0 > 0 and t-lnsci.idat > v-dt no-error.
        if avail t-lnsci then do:
            v-prc = 0. v-dtc = v-dt.
            for each t-lnsch where t-lnsch.lnn = lon.lon and t-lnsch.f0 > 0 and t-lnsch.stdat >= v-dt and t-lnsch.stdat < t-lnsci.idat no-lock:
                v-sum = v-sum - t-lnsch.stval.

                if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
                  run mondays(2,year(t-lnsch.stdat),output v_dd).
                  if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
                  v_day = day(t-lnsch.stdat).
                end.
                else
                  v_basedy = lon.basedy.

                run day-360(v-dtc,t-lnsch.stdat - 1,v_basedy,output dn1,output dn2).
                /*v-prc = v-prc + dn1 * v-sum * v-prem / 100 / 360.*/
                if (month(t-lnsch.stdat) = 1) and (v_basedy = 366) then
                  v-prc = v-prc + (v_day * v-sum * v-prem / 100 / v_basedy) + ((dn1 - v_day) * v-sum * v-prem / 100 / v_basedy).
                else
                  v-prc = v-prc + dn1 * v-sum * v-prem / 100 / v_basedy.

                v-dtc = t-lnsch.stdat.
            end.
            if v-dtc < t-lnsci.idat then do:
                if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
                  run mondays(2,year(t-lnsci.idat),output v_dd).
                  if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
                  v_day = day(t-lnsci.idat).
                end.
                else
                  v_basedy = lon.basedy.

                run day-360(v-dtc,t-lnsci.idat - 1,v_basedy,output dn1,output dn2).
                /*v-prc = v-prc + dn1 * v-sum * v-prem / 100 / 360.*/
                if (month(t-lnsci.idat) = 1) and (v_basedy = 366) then
                  v-prc = v-prc + (v_day * v-sum * v-prem / 100 / v_basedy) + ((dn1 - v_day) * v-sum * v-prem / 100 / v_basedy).
                else
                  v-prc = v-prc + dn1 * v-sum * v-prem / 100 / v_basedy.

            end.
            t-lnsci.iv-sc = round(v-prc,2).
        end.
    end.
end.

if v-prems > 0 then do:
message "hi" view-as alert-box.
    for each lnscs where lnscs.lon = lon.lon and lnscs.sch and lnscs.stdat >= g-today no-lock:
        if ((weekday(lnscs.stdat) = 1) or (weekday(lnscs.stdat) = 7)) and lnscs.stdat <> lon.duedt then do:

            v-dtc = lnscs.stdat.

            if weekday(lnscs.stdat) = 1 then v-dt = v-dtc + 1.
            else v-dt = v-dtc + 2.

            find first t-lnscs where t-lnscs.lon = lon.lon and t-lnscs.sch and t-lnscs.stdat > v-dtc and t-lnscs.stdat <= v-dt no-lock no-error.
            if avail t-lnscs then do:
                message "Перенос платежей с выходных дней:~nНевозможно сдвинуть запись в графике %%(ком) с " + string(v-dtc,"99/99/99") + " на " + string(v-dt,"99/99/99") + "!" view-as alert-box error.
                return.
            end.

            v-sum = v-sum0.
            for each t-lnsch where t-lnsch.lnn = lon.lon and t-lnsch.f0 > 0 and t-lnsch.stdat >= g-today and t-lnsch.stdat <= v-dtc no-lock:
                v-sum = v-sum - t-lnsch.stval.
            end.

            if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
              run mondays(2,year(v-dtc),output v_dd).
              if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
              v_day = day(v-dtc).
            end.
            else
              v_basedy = lon.basedy.

            run day-360(v-dtc,v-dtc,v_basedy,output dn1,output dn2).
            /*v-prc = dn1 * v-sum * v-prems / 100 / 360.*/
            if (month(v-dtc) = 1) and (v_basedy = 366) then
              v-prc = (v_day * v-sum * v-prem / 100 / v_basedy) + ((dn1 - v_day) * v-sum * v-prem / 100 / v_basedy).
            else
              v-prc = dn1 * v-sum * v-prem / 100 / v_basedy.

            v-dtc = v-dtc + 1.
            if v-dtc < v-dt then do:
                for each t-lnsch where t-lnsch.lnn = lon.lon and t-lnsch.f0 > 0 and t-lnsch.stdat = v-dtc no-lock:
                    v-sum = v-sum - t-lnsch.stval.
                end.

                if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
                  run mondays(2,year(v-dtc),output v_dd).
                  if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
                  v_day = day(v-dtc).
                end.
                else
                  v_basedy = lon.basedy.

                run day-360(v-dtc,v-dtc,v_basedy,output dn1,output dn2).
                /*v-prc = v-prc + dn1 * v-sum * v-prems / 100 / 360.*/
                if (month(v-dtc) = 1) and (v_basedy = 366) then
                  v-prc = v-prc + (v_day * v-sum * v-prem / 100 / v_basedy) + ((dn1 - v_day) * v-sum * v-prem / 100 / v_basedy).
                else
                  v-prc = v-prc + dn1 * v-sum * v-prem / 100 / v_basedy.
            end.

            find first t-lnscs where t-lnscs.lon = lnscs.lon and t-lnscs.sch and t-lnscs.stdat = lnscs.stdat.
            t-lnscs.stdat = v-dt.
            t-lnscs.stval = t-lnscs.stval + round(v-prc,2).
            /* скорректируем следующий платеж */
            find first t-lnscs where t-lnscs.lon = lnscs.lon and t-lnscs.sch and t-lnscs.stdat > v-dt no-error.
            if avail t-lnscs then do:
                v-prc = 0. v-dtc = v-dt.
                for each t-lnsch where t-lnsch.lnn = lon.lon and t-lnsch.f0 > 0 and t-lnsch.stdat >= v-dt and t-lnsch.stdat < t-lnscs.stdat no-lock:
                    v-sum = v-sum - t-lnsch.stval.

                    if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
                      run mondays(2,year(t-lnsch.stdat),output v_dd).
                      if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
                      v_day = day(t-lnsch.stdat).
                    end.
                    else
                      v_basedy = lon.basedy.

                    run day-360(v-dtc,t-lnsch.stdat - 1,v_basedy,output dn1,output dn2).
                    /*v-prc = v-prc + dn1 * v-sum * v-prems / 100 / 360.*/
                    if (month(t-lnsch.stdat) = 1) and (v_basedy = 366) then
                      v-prc = v-prc + (v_day * v-sum * v-prem / 100 / v_basedy) + ((dn1 - v_day) * v-sum * v-prem / 100 / v_basedy).
                    else
                      v-prc = v-prc + dn1 * v-sum * v-prem / 100 / v_basedy.

                    v-dtc = t-lnsch.stdat.
                end.
                if v-dtc < t-lnscs.stdat then do:
                    if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
                      run mondays(2,year(t-lnscs.stdat),output v_dd).
                      if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
                      v_day = day(t-lnscs.stdat).
                    end.
                    else
                      v_basedy = lon.basedy.

                    run day-360(v-dtc,t-lnscs.stdat - 1,v_basedy,output dn1,output dn2).
                    /*v-prc = v-prc + dn1 * v-sum * v-prems / 100 / 360.*/
                    if (month(t-lnscs.stdat) = 1) and (v_basedy = 366) then
                      v-prc = v-prc + (v_day * v-sum * v-prem / 100 / v_basedy) + ((dn1 - v_day) * v-sum * v-prem / 100 / v_basedy).
                    else
                      v-prc = v-prc + dn1 * v-sum * v-prem / 100 / v_basedy.

                end.
                t-lnscs.stval = round(v-prc,2).
            end.
        end.
    end.
end. /* if v-prems > 0 */

/*

def temp-table wrk no-undo
  field dt as date
  field od as deci
  field prc as deci
  field prccom as deci
  index idx is primary dt.

for each t-lnsch no-lock:
    create wrk.
    assign wrk.dt = t-lnsch.stdat wrk.od = t-lnsch.stval.
end.

for each t-lnsci no-lock:
    find first wrk where wrk.dt = t-lnsci.idat.
    if not avail wrk then do:
        create wrk.
        wrk.dt = t-lnsci.idat.
    end.
    wrk.prc = wrk.prc + t-lnsci.iv-sc.
end.

for each t-lnscs no-lock:
    find first wrk where wrk.dt = t-lnscs.stdat.
    if not avail wrk then do:
        create wrk.
        wrk.dt = t-lnscs.stdat.
    end.
    wrk.prccom = wrk.prccom + t-lnscs.stval.
end.

output stream rep to rep.csv.
if v-prems > 0 then put stream rep unformatted "Дата;ОД;%%;%%(ком)" skip.
else put stream rep unformatted "Дата;ОД;%%" skip.
for each wrk no-lock:
    put stream rep unformatted
        string(wrk.dt,"99/99/9999") ';'
        replace(trim(string(wrk.od,">>>>>>>>>>>9.99")),'.',',') ';'
        replace(trim(string(wrk.prc,">>>>>>>>>>>9.99")),'.',',').
    if v-prems > 0 then put stream rep unformatted ';' replace(trim(string(wrk.prccom,">>>>>>>>>>>9.99")),'.',',').
    put stream rep unformatted skip.
end.

output stream rep close.
unix silent cptwin rep.csv excel.

*/

do transaction:
    for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 exclusive-lock:
        delete lnsch.
    end.
    for each t-lnsch no-lock:
        create lnsch.
        buffer-copy t-lnsch to lnsch.
    end.

    for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 exclusive-lock:
        delete lnsci.
    end.
    for each t-lnsci no-lock:
        create lnsci.
        buffer-copy t-lnsci to lnsci.
    end.

    if v-prems > 0 then do:
        for each lnscs where lnscs.lon = lon.lon and lnscs.sch exclusive-lock:
            delete lnscs.
        end.
        for each t-lnscs no-lock:
            create lnscs.
            buffer-copy t-lnscs to lnscs.
        end.
    end.
end.

