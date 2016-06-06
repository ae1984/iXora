/* loan31.p
 * MODULE
        3-4-2-16-19
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
        21.06.2011 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
*/
def input parameter p-bank as char.
def input parameter p-lon as char.
def output parameter p-prc as decimal.
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
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
def var v-dt as date no-undo.
def var v-regdt as date no-undo.
def var v-rate as decimal no-undo.
def var v-srok as int no-undo.
def var v-srok1 as int no-undo.
def var v-dt1 as date no-undo.
def var v-dt2 as date no-undo.
def var v-dt3 as char no-undo.
def var v-dt4 as date no-undo.
def var dn1 as integer no-undo.
def var dn2 as decimal no-undo.
def var i as integer no-undo.
def var j as integer no-undo.
def var v-psum as decimal.
def var v-psum1 as decimal.
def var v-psum2 as decimal.
def temp-table wrk no-undo
    field i as int
    field dt as date
    field day as int
    field ncr as decimal
    field od as decimal
    field prc as decimal
    field ep as decimal.
def buffer b-wrk for wrk.
def var sum-prc as decimal.
def var v-day as date.
def var v-ncr as decimal.
def var v-ncr1 as decimal.
def var v-ncr2 as decimal.
def var v-ncr3 as decimal.
def var v-mn as int.
def var v-yr as int.
def var v-ost as decimal.
def var dt as decimal.
sum-prc = 0.
find first txb.lon where txb.lon.lon = p-lon no-lock no-error.
    find first pkanketa where pkanketa.bank = p-bank and pkanketa.lon = txb.lon.lon no-lock no-error.
    if not avail pkanketa then return.
    v-regdt = pkanketa.docdt.
    v-rate = pkanketa.rateq.
    v-srok = pkanketa.srok.
    j = 0.
    i = 0.
    v-dt = txb.lon.rdt.
    dt = (today - txb.lon.rdt) / 30.
    v-srok1 = round(dt,0).
    do i = 1 to v-srok1:
        if i = 1 then do:
            if txb.lon.day > 0 then do:
            v-dt1 = date(month(txb.lon.rdt),txb.lon.day,year(txb.lon.rdt)) no-error.
            if error-status:error then do:
                message txb.lon.cif txb.lon.lon view-as alert-box.
            end.
            end.
            else do:
                find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.stdat < txb.lon.duedt no-lock no-error.
                if avail txb.lnsch then v-dt1 = date(month(txb.lon.rdt),day(txb.lnsch.stdat),year(txb.lon.rdt)) no-error.
            end.
            if v-dt1 <= txb.lon.rdt then v-dt1 = get-date(v-dt1,1).
            if v-dt1 - txb.lon.rdt <= 15 then v-dt1 = get-date(v-dt1,1).
        end.
        else
        if i = v-srok1 then v-dt1 = get-date(txb.lon.rdt,v-srok1).
        else v-dt1 = get-date(v-dt,1).
        create wrk.
        wrk.i = i.
        wrk.dt = v-dt1.
        v-dt = v-dt1.
    end.
    v-psum = 0.
    v-ncr = txb.lon.opnamt.
    v-dt2 = txb.lon.rdt.
    for each wrk no-lock:
        run day-360(v-dt2,wrk.dt - 1,lon.basedy,output dn1,output dn2).
        wrk.day = dn1.
        wrk.ep = round((txb.lon.opnamt * v-rate / 12 / 100) / ( 1 - (1 / exp(1 + (v-rate / 12 / 100), v-srok1) ) ),2).
        wrk.prc = round(wrk.day * v-ncr * v-rate / 100 / 360,2).
        wrk.od = wrk.ep - wrk.prc.
        wrk.ncr = v-ncr.
        v-ncr = v-ncr - wrk.od.
        sum-prc = sum-prc + wrk.prc.
        v-dt2 = wrk.dt.
    end.
    find last wrk no-lock no-error.
    if avail wrk then do:
        find last b-wrk where b-wrk.i < wrk.i no-lock no-error.
        if avail b-wrk then wrk.od =  wrk.ncr.
        wrk.ep = wrk.od + wrk.prc.
    end.
p-prc = sum-prc.


