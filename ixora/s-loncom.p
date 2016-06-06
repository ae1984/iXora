/* s-loncom.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Амортизация комиссии
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
        24/08/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        27/08/2011 madiyar - не двигаем графики на 1ые числа; исправления по КЛ
        02/09/2011 madiyar - по КЛ амортизация равномерная
        09/09/2011 madiyar - вернул амортизацию по эжффективной ставке по КЛ
        29/09/2011 madiyar - помесячный расчет эффективки
        03/10/2011 madiyar - вывод ставок в отчет
        07/10/2011 madiyar - вынес нумерацию записей в графике
        22/10/2011 madiyar - просмотр графика амортизации
        26/12/2011 madiyar - корректировка периодов
        02/01/2012 madiyar - расчет графика по комиссии за изменение условий
        08/02/2012 madiyar - выравнивающая проводка по амортизации/сторно амортизации комиссии за уже прошедший период
        28/02/2012 madiyar - поправил случай при совпадении даты комиссии и ежемесячного платежа
        29/02/2012 madiyar - поправил расчет корректировки амортизации
        29/02/2012 madiyar - поправил ошибку с датами
        19/06/2013 sayat(id01143) - ТЗ 1901 от 17/06/2013 скорректировано обработка валютных займов (порождение проводок)
        22/07/2013 Sayat(id01143) - ТЗ 1681 от 30/01/2013 "Доработка п.м. 3.1.1. «Кредиты» верхнее меню «Амортизация комиссии»" доработан подсчет количества месяцев
        26/07/2013 Sayat(id01143) - ТЗ 1982 от 26/07/2013 "Доработка рассчета эффективной ставки"
*/

{global.i}

def shared var s-lon like lon.lon.
def var v-crc as char.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then return.
find first crc  where crc.crc = lon.crc no-lock no-error.
if avail crc then v-crc = crc.code.

def new shared var s-rdt as date no-undo.
def new shared var s-duedt as date no-undo.
def new shared var s-sum as deci no-undo.
def new shared var s-com as deci no-undo.
def new shared var s-comdt as date no-undo.
def new shared var v-effrate as deci no-undo.
s-rdt = lon.rdt.
s-duedt = lon.duedt.
s-sum = lon.opnamt.

find first lnscg where lnscg.lng = lon.lon and lnscg.flp > 0 no-lock no-error.
if avail lnscg and lnscg.stdat <> s-rdt then s-rdt = lnscg.stdat.

def new shared temp-table t-grf no-undo
    field nn as integer
    field nd as deci
    field dt as date
    field od as deci
    field prc as deci

    field ost as deci
    field dbt as deci
    field com as deci
    index idx is primary dt.

def temp-table t-grfcom no-undo
    field nn as integer
    field dt as date
    field com as deci
    index idx is primary dt.

def var v-comsize as deci no-undo.
def var ja as logical no-undo.
def var v-dt0 as date no-undo.
def var v-dt as date no-undo.
def var coun as integer no-undo.
def var i as integer no-undo.
def var j as deci no-undo.
def var pp as deci no-undo.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.
def var v-ost as deci no-undo.
def var v-select as integer no-undo.

def var vyear as integer no-undo.
def var vmonth as integer no-undo.
def var vday as integer no-undo.
def var mdays as integer no-undo.
def var ch_mdays as integer no-undo.
def var old_dt as date no-undo.

def var v-lev1 as integer no-undo.
v-lev1 = 42. /* 1434 */
def var v-lev2 as integer no-undo.
v-lev2 = 31. /* 4434 */
def var v-comopl as deci no-undo.
def var v-comopl_grf as deci no-undo.
def var v-com_trx as deci no-undo.
def var v-com_rnd as deci no-undo.
def var v-sum as deci no-undo.
def var v-lcnt as char no-undo.
def var v-sumcom_full as deci no-undo.
def var v-com42 as deci no-undo.

def var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v-rem as char no-undo.
def var v-chgcon as logi no-undo.

def buffer bt-grf for t-grf.

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then do:
        /*v-datres = ?.*/
        yy = year(v-date) - integer(abs(v-num) / 12).
        if (abs(v-num) mod 12) >= month(v-date) then do: yy = yy - 1. mm = month(v-date) + 12 - (abs(v-num) mod 12). end.
        else mm = month(v-date) - (abs(v-num) mod 12).
        run mondays(mm,yy,output dd).
        if day(v-date) < dd then dd = day(v-date).
        v-datres = date(mm,dd,yy).
    end.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.

/* функция get-com возвращает сумму комиссии, которая должна быть самортизирована на сегодня */
function get-com returns deci (input p-date as date, input p-rdt as date).
    def var v-sumres as deci no-undo.
    def var v-dtlast as date no-undo.
    def var v-days as integer no-undo.
    v-sumres = 0. v-dtlast = p-rdt.
    for each t-grfcom where t-grfcom.dt <= p-date:
        v-sumres = v-sumres + t-grfcom.com.
        v-dtlast = t-grfcom.dt.
    end.
    v-days = p-date - v-dtlast.
    find first t-grfcom where t-grfcom.dt > p-date no-error.
    if avail t-grfcom then v-sumres = v-sumres + v-days * t-grfcom.com / (t-grfcom.dt - v-dtlast).
    return (v-sumres).
end function.

/* функция подсчитывает количество месяцев между датами */
function months_between returns decimal (input v-date1 as date, input v-date2 as date, input v-baseday as integer).
    def var v-res as deci.
    def var nm as integer.
    def var v-dttemp as date.
    def var dd as integer.
    def var dd1 as integer.
    def var mm as integer.
    def var yy as integer.
    def var v-check as logi initial false.
    if v-date1 > v-date2 then do:
        v-check = true.
        v-dttemp = v-date1.
        v-date1 = v-date2.
        v-date2 = v-dttemp.
        v-dttemp = ?.
    end.
    nm = (year(v-date2) - year(v-date1)) * 12 + month(v-date2) - month(v-date1).
    if v-baseday = 360 then do:
        dd = day(v-date1).
        dd1 = day(v-date2).
        if dd > 30 then dd = 30.
        if dd1 > 30 then dd1 = 30.
        if dd > dd1 then v-res = nm - 1 + (dd1 + 30 - dd) / 30.
        else v-res = nm  + (dd1 - dd) / 30.
    end.
    else do:
        if day(v-date1) > day(v-date2) then nm = nm - 1.
        v-res = nm + (v-date2 - get-date(v-date1,nm)) / (v-date2 - get-date(v-date2,-1)).
    end.
    if v-check then v-res = - v-res.
    return (v-res).
end function.



form v-comsize label "Размер комиссии (%)................." format ">9.99" skip
     s-com label "Сумма комиссии (в валюте кредита)..." format ">>>,>>>,>>9.99" skip
     s-comdt label "Дата комиссии......................." format "99/99/9999" skip
with frame fr1 row 13 centered side-labels overlay.



run sel2 (" Выберите: ", " 1. Просмотр графика амортизации | 2. Расчет графика амортизации | 3. ВЫХОД ", output v-select).
if v-select < 1 or v-select > 2 then return.


if v-select = 1 then do:
    run lnamortgrf.
    return.
end.


v-comsize = 0.
s-com = 0.
s-comdt = s-rdt.

displ v-comsize s-com s-comdt with frame fr1.

update v-comsize with frame fr1.

s-com = round(s-sum * v-comsize / 100,2).

displ s-com with frame fr1.
update s-com with frame fr1.
update s-comdt with frame fr1.

v-chgcon = no.
find first lnscc where lnscc.lon = lon.lon no-lock no-error.
if avail lnscc then do:
    if s-comdt <> s-rdt then do:
        message "График амортизации комиссии уже существует.~nВведенная комиссия является комиссией за изменение условий и новый график будет добавлен к старому." view-as alert-box information.
        v-chgcon = yes.
    end.
    else do:
        message "График амортизации комиссии уже существует.~nДата комиссии совпадает с датой выдачи кредита, старый график будет заменен новым." view-as alert-box information.
        v-chgcon = no.
    end.
end.

if lon.gua = "CL" then do:

    message "Кредитная линия! Расчет амортизации по условному графику!" view-as alert-box warning.
    v-dt0 = s-rdt.
    coun = 0.
    repeat:
        coun = coun + 1.
        v-dt = get-date(s-rdt,coun).
        if v-dt > s-duedt then v-dt = s-duedt.
        create t-grf.
        t-grf.dt = v-dt.
        if v-dt = s-duedt then leave.
        v-dt0 = v-dt.
    end.

    /* равномерная */
    /*
    pp = round(s-sum / coun,0).
    v-dt0 = s-rdt.
    v-ost = s-sum.
    for each t-grf:
        if t-grf.dt = s-duedt then t-grf.od = v-ost.
        else t-grf.od = pp.
        run day-360(v-dt0,t-grf.dt - 1,lon.basedy,output dn1,output dn2).
        t-grf.prc = round(dn1 * v-ost * lon.prem / 100 / 360,2).
        v-ost = v-ost - t-grf.od.
        v-dt0 = t-grf.dt.
    end.
    */

    /* аннуитет */
    pp = s-sum * lon.prem / 1200 / (1 - 1 / exp(1 + lon.prem / 1200,coun)).
    v-dt0 = s-rdt.
    v-ost = s-sum.
    for each t-grf:
        /*
        run day-360(v-dt0,t-grf.dt - 1,lon.basedy,output dn1,output dn2).
        */
        dn1 = 30.
        t-grf.prc = dn1 * v-ost * lon.prem / 100 / 360.
        if t-grf.dt = s-duedt then t-grf.od = v-ost.
        else t-grf.od = round(pp - t-grf.prc,2).
        t-grf.prc = round(t-grf.prc,2).
        v-ost = v-ost - t-grf.od.
        v-dt0 = t-grf.dt.
    end.


    /*
    message "Кредитная линия! Равномерный график амортизации комиссии!" view-as alert-box warning.
    create t-grf.
    t-grf.dt = s-duedt.
    t-grf.com = s-com.
    */
end.
else do:
    for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock:
        create t-grf.
        assign t-grf.dt = lnsch.stdat
               t-grf.od = lnsch.stval.
    end.

    for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock:
        find first t-grf where t-grf.dt = lnsci.idat no-error.
        if not avail t-grf then do:
            create t-grf.
            t-grf.dt = lnsci.idat.
        end.
        t-grf.prc = lnsci.iv-sc.
    end.
    /*
    run getAmort.
    */
end.

/*
def stream qq.
output stream qq to qq.csv.
for each t-grf no-lock:
put stream qq unformatted t-grf.dt ";" replace(trim(string(t-grf.od,">>>>>>>>>>>9.99")),'.',',') ";" replace(trim(string(t-grf.prc,">>>>>>>>>>>9.99")),'.',',') skip.
end.
output stream qq close.
*/

/* поправка суммы кредита на дату принятия комиссии */
if s-comdt <> s-rdt then do:
    for each t-grf where t-grf.dt <= s-comdt:
        s-sum = s-sum - t-grf.od.
        delete t-grf.
    end.
end.

/* пронумеруем записи в графике для расчета */
i = 0.
for each t-grf:
    i = i + 1.
    t-grf.nn = i.
end.

/* пронумеруем периоды */
j = 0.
for each t-grf:
    /* Sayat 22/07/2013 begin */
    /*
    if j = 0 then do:
        vyear = year(t-grf.dt).
        vmonth = month(t-grf.dt) - 1.
        vday = day(t-grf.dt).
        if vmonth = 0 then assign vmonth = 12 vyear = vyear - 1.
        run mondays(vmonth, vyear, output ch_mdays).
        if vday > ch_mdays then vday = ch_mdays.
        old_dt = date(vmonth,vday,vyear).
        mdays = t-grf.dt - old_dt.
        j = (t-grf.dt - s-comdt) / mdays.
    end.
    */
    j = months_between(s-comdt,t-grf.dt,lon.basedy).
    t-grf.nd = j.
    /*v-dt = t-grf.dt.
    j = j + 1.*/
    /* Sayat 22/07/2013 end */
end.

find last t-grf no-error.
find last bt-grf where bt-grf.dt < t-grf.dt no-error.
if avail t-grf and avail bt-grf then do:
    vyear = year(t-grf.dt).
    vmonth = month(t-grf.dt) - 1.
    vday = day(t-grf.dt).
    if vmonth = 0 then assign vmonth = 12 vyear = vyear - 1.
    run mondays(vmonth, vyear, output ch_mdays).
    if vday > ch_mdays then vday = ch_mdays.
    old_dt = date(vmonth,vday,vyear).
    mdays = t-grf.dt - old_dt.
    /* message "1 mdays2=" mdays " cl2b.nn=" t-grf.nd view-as alert-box. */
    t-grf.nd = t-grf.nd - 1 + (t-grf.dt - bt-grf.dt) / mdays.
    /* message "2 mdays2=" mdays " cl2b.nn=" t-grf.nd view-as alert-box. */
end.

run getAmort.

/* если это изменение условий - объединим старый график с новым */
if v-chgcon then do:
    for each lnscc where lnscc.lon = lon.lon no-lock:
        create t-grfcom.
        assign t-grfcom.dt = lnscc.stdat
               t-grfcom.com = lnscc.stval.
    end.
end.

for each t-grf no-lock:
    find first t-grfcom where t-grfcom.dt = t-grf.dt no-error.
    if not avail t-grfcom then do:
        create t-grfcom.
        t-grfcom.dt = t-grf.dt.
    end.
    t-grfcom.com = t-grfcom.com + t-grf.com.
end.

j = 0.
v-sumcom_full = 0.
for each t-grfcom:
    j = j + 1.
    t-grfcom.nn = j.
    v-sumcom_full = v-sumcom_full + t-grfcom.com.
end.

/* рассчитаем сумму, которая должна быть самортизирована на сегодня по графику */
v-comopl_grf = get-com(g-today, s-rdt).
/* и реально самортизированную */
/*run lonbalcrc('lon',lon.lon,g-today,string(v-lev1),yes,1,output v-com42).*/
run lonbalcrc('lon',lon.lon,g-today,string(v-lev1),yes,lon.crc,output v-com42).
v-com42 = - v-com42.
v-comopl = v-sumcom_full - v-com42. /* фактический несамортизированный остаток комиссии */
v-com_trx = v-comopl_grf - v-comopl.


output to 1.csv.
put unformatted "Номинальная ставка=" replace(trim(string(lon.prem,">>>>9.99")),'.',',') skip
                "Эффективная ставка=" replace(trim(string(v-effrate,">>>>>>>>>>>>9.9<<<<<<<<<<<<")),'.',',') skip.
put unformatted "nn;nd;Дата;ОД;%%;Остаток после погашения;Долг по эфф.ставке;Амортизация;Дней;в_день" skip
                ";;" s-comdt skip.
v-dt = s-comdt.
for each t-grf:
    put unformatted
        t-grf.nn ";"
        t-grf.nd ";"
        t-grf.dt ";"
        replace(trim(string(t-grf.od,"->>>>>>>>>>>9.99")),'.',',') ";"
        replace(trim(string(t-grf.prc,"->>>>>>>>>>>9.99")),'.',',') ";"

        replace(trim(string(t-grf.ost,"->>>>>>>>>>>9.99")),'.',',') ";"
        replace(trim(string(t-grf.dbt,"->>>>>>>>>>>9.99")),'.',',') ";"

        replace(trim(string(t-grf.com,"->>>>>>>>>>>9.99")),'.',',') ";"
        t-grf.dt - v-dt ";"
        replace(trim(string(t-grf.com / (t-grf.dt - v-dt),"->>>>>>>>>>>9.99")),'.',',') skip.
    v-dt = t-grf.dt.
end.

put unformatted skip " " skip "nn;Дата;Амортизация;Дней;в_день" skip.

v-dt = s-rdt.
for each t-grfcom:
    put unformatted
        t-grfcom.nn ";"
        t-grfcom.dt ";"
        replace(trim(string(t-grfcom.com,"->>>>>>>>>>>9.99")),'.',',') ";"
        t-grfcom.dt - v-dt ";"
        replace(trim(string(t-grfcom.com / (t-grfcom.dt - v-dt),"->>>>>>>>>>>9.99")),'.',',') skip.
    v-dt = t-grfcom.dt.
end.

output close.

unix silent cptwin 1.csv excel.

ja = no.
message "Сохранить график амортизации?~n(Будет создана проводка по амортизации комиссии на сумму " + v-crc + " " + trim(string(v-com_trx,"->>>,>>>,>>>,>>9.99")) + ")"
        view-as alert-box question buttons yes-no title "" update ja.
if not ja then return.

do transaction:
    for each lnscc where lnscc.lon = lon.lon exclusive-lock:
        delete lnscc.
    end.
    for each t-grfcom:
        create lnscc.
        assign lnscc.lon = lon.lon
               lnscc.comid = ''
               lnscc.sch = yes
               lnscc.stdat = t-grfcom.dt
               lnscc.stval = t-grfcom.com.
    end.

    /* создадим проводку */
    if abs(v-com_trx) > 0 then do:
        find first loncon where loncon.lon = lon.lon no-lock no-error.
        if avail loncon then v-lcnt = loncon.lcnt. else v-lcnt = ''.
        v-com_rnd = round(v-com_trx,2).
        v-sum = abs(v-com_rnd).
        if lon.crc = 1 then do:
            if v-com_trx > 0 then do:
                v-rem = "Доходы по амортизации комиссии за предоставление КЛ/займа по кредитному договору N " + v-lcnt.
                v-param = string(v-sum) + vdel + "1" + vdel + string(v-lev1) + vdel +
                        lon.lon + vdel + string(v-lev2) + vdel + v-rem.
            end.
            else do:
                v-rem = "Сторно доходов по амортизации комиссии за предоставление КЛ/займа по кредитному договору N " + v-lcnt.
                v-param = string(v-sum) + vdel + "1" + vdel + string(v-lev2) + vdel +
                          lon.lon + vdel + string(v-lev1) + vdel + v-rem.
            end.
            s-jh = 0.
            run trxgen("LON0152",vdel,v-param,"lon",lon.lon,output rcode,output rdes,input-output s-jh).
        end.
        else do:
            if v-com_trx > 0 then do:
                v-rem = "Доходы по амортизации комиссии за предоставление КЛ/займа по кредитному договору N " + v-lcnt.
                v-param = string(v-sum)  + vdel + string(lon.crc) + vdel + string(v-lev1) + vdel +
                          lon.lon + vdel + v-rem + vdel + string(round(v-sum * crc.rate[1],2))
                          + vdel + "1" + vdel + string(v-lev2).
            end.
            else do:
                v-rem = "Сторно доходов по амортизации комиссии за предоставление КЛ/займа по кредитному договору N " + v-lcnt.
                v-param = string(round(v-sum * crc.rate[1],2)) + vdel + "1" + vdel + string(v-lev2) + vdel +
                          lon.lon + vdel + v-rem + vdel + string(v-sum) + vdel +
                          string(lon.crc) + vdel + string(v-lev1).
            end.
            s-jh = 0.
            run trxgen("LON0178",vdel,v-param,"lon",lon.lon,output rcode,output rdes,input-output s-jh).
        end.
        if rcode <> 0 then do:
            run savelog("msfocomerr", "ERROR " + lon.cif + " " + lon.lon + " " + rdes + " " + v-param).
            message rdes.
            pause 1000.
        end.
        else do:
            find current loncon exclusive-lock.
            loncon.accrued[1] = v-com_trx - v-com_rnd.
            find current loncon no-lock.
            run lonresadd(s-jh).
        end.
    end. /* if abs(v-com_trx) > 0 */

end. /* transaction */

