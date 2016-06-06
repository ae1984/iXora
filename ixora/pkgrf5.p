        /* pkgrf5.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/05/2005 madiyar - скопировал из pkgrf4.p
 * CHANGES
        17/01/2006 madiyar - дни 5,10,15,20,24 временно запрещены
        28/02/2006 madiyar - казпочта: выбирается дата с желаемым днем погашения, ближайшая к графику до пересчета
        15/02/2007 madiyar - полностью переделал
        28/03/2007 madiyar - не проставлялось поле lon.day
        24/04/2007 madiyar - веб-анкеты
        13/09/2007 madiyar - ограничение на день погашения (до 20 числа)
        16/09/2008 galina - оставила только ограничение на день погашения (до 20 числа) 
        23/09/2008 galina - вернула ограничения на день погашения
        16/02/2009 galina - график начинаем строить с даты формирования договоров
                            выдать ообщение, если не проставлен акцепт
        20/12/2009 galina - график храним во временной таблице                    
        */

{global.i}
{pk.i}

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
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
def var v-dt1 as date no-undo.
def var v-dt2 as date no-undo.
def var v-payod as decimal no-undo.
def var v-payprc as decimal no-undo.
def var dn1 as integer no-undo.
def var dn2 as decimal no-undo.
def var i as integer no-undo.
def var v-day as integer no-undo.
def var v-dates as date no-undo extent 2.

def shared temp-table wrk no-undo
    field nn     as integer
    field stdat  like lnsch.stdat
    field od     like lnsch.stval
    field proc   like lnsch.stval
    field com    as logi init no
    index idx is primary stdat.
def buffer b-wrk for wrk.    

procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
    pkanketh.value1 = p-msg.
    find current pkanketh no-lock.
end procedure.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

def var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.

if pkanketa.lon <> '' then do:
    find first lon where lon.lon = s-lon no-lock no-error.
    if not avail lon then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pkgrf5 - Ссудный счет N " + s-lon + " не найден!").
        message skip " Ссудный счет N" s-lon "не найден !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
        return.
    end.


    if pkanketa.cdt = ? or pkanketa.cwho = "" then do:
       if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Выдача кредита еще не утверждена!").
       else message "Выдача кредита еще не утверждена!" view-as alert-box title "".
       return.
    end.
end.

v-regdt = pkanketa.docdt.
if pkanketa.lon <> ''then do:
  /*  v-dt = get-date(v-regdt,1).
    v-dt1 = get-date(v-regdt,2).*/
    
    
    if v-inet then do:
        v-day = 0.
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fmsg" no-lock no-error.
        if avail pkanketh and trim(pkanketh.value2) <> '' then v-day = integer(pkanketh.value2) no-error.
        if v-day <> 0 and v-day <> ? then do:
            v-dates[1] = date(month(v-regdt),v-day,year(v-regdt)).
            v-dates[2] = date(month(v-dt),v-day,year(v-dt)).
            if v-dates[1] <= g-today then do:
                v-dates[1] = v-dates[2]. v-dates[2] = get-date(v-dates[1],1).
            end.
            if absolute(v-dt - v-dates[1]) <= absolute(v-dt - v-dates[2]) then v-dt = v-dates[1].
            else v-dt = v-dates[2].
        end.
    end.
 /*   else do:
        update v-dt label " Укажите дату " format "99/99/9999"
                    validate (v-dt > g-today and v-dt < v-dt1 and day(v-dt) < 20, "Дата должна быть > текущей и не далее 30 дней от первичной, дни месяца от 1 до 19") skip
                    with side-label row 5 centered frame dat.
    end.

    for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0:
        delete lnsch.
    end.
    for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0:
        delete lnsci.
    end.*/
end.

v-dt1 = v-regdt.
v-dt = pkanketa.resdat[1].
v-payod = truncate(pkanketa.summa / pkanketa.srok, 0).
v-payprc = round(pkanketa.summa * pkanketa.rateq / 1200,2).
/*for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock:
    create wrk.
    wrk.stdat = lnsch.stdat.
    wrk.od = lnsch.stval.
    wrk.com = yes.
end.

for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 no-lock:
    find first wrk where wrk.stdat = lnsci.idat no-lock no-error.
    if not avail wrk then do:
        create wrk.
        wrk.stdat = lnsci.idat.
    end.
    wrk.proc = lnsci.iv-sc.
end.*/
do i = 1 to pkanketa.srok:
    if i = 1 then v-dt2 = v-dt.
    else if i = pkanketa.srok then v-dt2 = get-date(v-regdt,pkanketa.srok).
    else v-dt2 = get-date(v-dt,i - 1).
    
    create wrk.
    wrk.stdat = v-dt2.
    wrk.com = yes.
    if i <> pkanketa.srok then wrk.od = v-payod.
    else wrk.od = pkanketa.summa - (pkanketa.srok - 1) * v-payod.
    
    wrk.proc = v-payprc.
    
    if i = 1 or i = pkanketa.srok then do:
       run day-360(v-dt1,v-dt2 - 1,360,output dn1,output dn2).
       if dn1 <> 30 then wrk.proc = round(dn1 * pkanketa.summa * pkanketa.rateq / 36000,2).
       
    end.
    
    v-dt1 = v-dt2.
end.
if pkanketa.lon <> '' then do:
/*    run lnsch-ren(s-lon).
    release lnsch.
    
    run lnsci-ren(s-lon).
    release lnsci.*/


    find current lon exclusive-lock.
    lon.day = day(v-dt).
    find current lon no-lock.
end.
