/* getAmort.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Расчет графика амортизации дисконта
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
        25/08/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        26/08/2011 madiyar - подправил формат
        27/08/2011 madiyar - не двигаем графики на 1ые числа
        29/09/2011 madiyar - помесячный расчет эффективки
        03/10/2011 madiyar - вывод ставок в отчет
        22/12/2011 madiyar - графики для займов исходя из дат, не периодов
        26/12/2011 madiyar - корректировка периодов
        02/01/2012 madiyar - расчет графика по комиссии за изменение условий
        26/07/2013 Sayat(id01143) - ТЗ 1982 от 26/07/2013 "Доработка рассчета эффективной ставки" перекомпиляция из-за изменений в er_amort.i
*/

def shared var s-lon like lon.lon.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
    message "LON not found!" view-as alert-box error.
    return.
end.

{er_amort.i}

def shared var s-rdt as date no-undo.
def shared var s-duedt as date no-undo.
def shared var s-sum as deci no-undo.
def shared var s-com as deci no-undo.
def shared var s-comdt as date no-undo.


def shared temp-table t-grf no-undo
    field nn as integer
    field nd as deci
    field dt as date
    field od as deci
    field prc as deci

    field ost as deci
    field dbt as deci
    field com as deci
    index idx is primary dt.

def buffer bt-grf for t-grf.

def var v-bb as deci no-undo.
def shared var v-effrate as deci no-undo.
def var i as deci no-undo.


empty temp-table b2cl.
empty temp-table cl2b.

/* def buffer b-cl2b for cl2b. */

i = 0.

for each t-grf no-lock:
    if (t-grf.od > 0) or (t-grf.prc > 0) then do:
        find first cl2b where cl2b.dt = t-grf.dt no-error.
        if not avail cl2b then do:
            create cl2b.
            assign cl2b.nn = t-grf.nd
                   cl2b.dt = t-grf.dt
                   cl2b.days = t-grf.dt - s-comdt.
            /*
            if i = 0 then do:
                vyear = year(t-grf.dt).
                vmonth = month(t-grf.dt) - 1.
                if vmonth = 0 then assign vmonth = 12 vyear = vyear - 1.
                old_dt = date(vmonth,day(t-grf.dt),vyear).
                mdays = t-grf.dt - old_dt.
                message "mdays=" mdays view-as alert-box.
                i = cl2b.days / mdays.
            end.
            cl2b.nn = i.
            i = i + 1.
            */
        end.
        cl2b.sum = cl2b.sum + t-grf.od + t-grf.prc.
    end.
end.

/*
find last cl2b no-error.
find last b-cl2b where b-cl2b.dt < cl2b.dt no-error.
if avail cl2b and avail b-cl2b then do:
    vyear = year(cl2b.dt).
    vmonth = month(cl2b.dt) - 1.
    if vmonth = 0 then assign vmonth = 12 vyear = vyear - 1.
    old_dt = date(vmonth,day(cl2b.dt),vyear).
    mdays = cl2b.dt - old_dt.
    message "1 mdays2=" mdays " cl2b.nn=" cl2b.nn view-as alert-box.
    cl2b.nn = cl2b.nn - 1 + (cl2b.dt - b-cl2b.dt) / mdays.
    message "2 mdays2=" mdays " cl2b.nn=" cl2b.nn view-as alert-box.
end.
*/

/*
message "f=" f(s-sum,s-com,0.0,0.2372482732) view-as alert-box.
*/


v-effrate = get_er2(s-sum,s-com,0.0,0.0).

/*
if lon.gua = "CL" then v-effrate = get_er2(s-sum,s-com,0.0,0.0).
else v-effrate = get_er2st(s-sum,s-com,0.0,0.0).
*/

/*
message v-effrate view-as alert-box.
*/

run savelog("amort",s-lon + " EffRate=" + trim(string(v-effrate,">>>>>>>>>>>>.9<<<<<<<<<<<<"))).

/* заполним поле ost - остаток ОД после погашения */
v-bb = s-sum.
for each t-grf:
    v-bb = v-bb - t-grf.od.
    t-grf.ost = v-bb.
end.

/* расчет задолженности по эффективной ставке на дату амортизации */
for each t-grf:
    /*if t-grf.dt <= s-comdt then next.*/
    for each bt-grf where bt-grf.dt >= t-grf.dt:
        /*message "bt-grf.nd=" bt-grf.nd " t-grf.nd=" t-grf.nd " sum=" (bt-grf.od + bt-grf.prc) / exp(1 + v-effrate,(bt-grf.nd - t-grf.nd) / 12) view-as alert-box.*/
        t-grf.dbt = t-grf.dbt + (bt-grf.od + bt-grf.prc) / exp(1 + v-effrate,(bt-grf.nd - t-grf.nd) / 12).
    end.
end.

/* расчет графика амортизации */
v-bb = 0.
for each t-grf break by t-grf.dt:
    /*if t-grf.dt <= s-comdt then next.*/
    if t-grf.dt = s-duedt then do:
        t-grf.com = s-com - v-bb.
        v-bb = s-com.
    end.
    else do:
        t-grf.com = round(t-grf.dbt - (t-grf.ost - s-com + (t-grf.od + t-grf.prc) + v-bb),2).
        v-bb = v-bb + t-grf.com.
    end.
end.

