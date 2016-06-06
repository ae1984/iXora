/* pkmygrf4.p
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
        23/09/2008 galina - скопировала из pkgrf5.p
 * BASES
     BANK COMM  
 
 * CHANGES
 
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
def var v-srok3 as integer no-undo.
def var v-month as integer no-undo.
def var v-year as integer no-undo.

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

if (pkanketa.srok mod 3) <> 0 then do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pkgrf4 - Некорректный срок!").
    else message skip " Некорректный срок !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pkgrf4 - Ссудный счет N " + s-lon + " не найден!").
    else message skip " Ссудный счет N" s-lon "не найден !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

v-regdt = pkanketa.cdt.
if day(v-regdt) < 25 then v-dt = get-date(v-regdt,1).
else do:
    v-year = year(v-regdt).
    v-month = month(v-regdt) + 2.
    if v-month > 12 then do:
        v-month = v-month - 12.
        v-year = v-year + 1.
    end.
    v-dt = date(v-month,day(v-regdt) - 25 + 1,v-year).
end.

/*
v-dt1 = get-date(v-regdt,2).
update v-dt label " Укажите дату " format "99/99/9999"
            validate (v-dt > g-today and v-dt < v-dt1, "Дата должна быть > текущей и не далее 30 дней от первичной") skip
            with side-label row 5 centered frame dat.
*/


for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0:
    delete lnsch.
end.
for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0:
    delete lnsci.
end.

v-dt1 = v-regdt.
v-srok3 = integer(pkanketa.srok / 3).
v-payprc = round(pkanketa.summa * lon.prem / 1200,2).
v-payod = truncate(pkanketa.summa / (pkanketa.srok - v-srok3), 0).

do i = 1 to pkanketa.srok:
    if i = 1 then v-dt2 = v-dt.
    else if i = pkanketa.srok then v-dt2 = get-date(v-regdt,pkanketa.srok).
    else v-dt2 = get-date(v-dt,i - 1).
    
    if i > v-srok3 then do:
        create lnsch.
        lnsch.lnn = s-lon.
        lnsch.stdat = v-dt2.
        lnsch.f0 = 1.
        if i <> pkanketa.srok then lnsch.stval = v-payod.
        else lnsch.stval = pkanketa.summa - (pkanketa.srok - v-srok3 - 1) * v-payod.
    end.
    
    if i <= v-srok3 then do:
        create lnsci.
        lnsci.lni = s-lon.
        lnsci.idat = v-dt2.
        lnsci.iv-sc = v-payprc.
        lnsci.f0 = 1.
        if i = 1 or i = pkanketa.srok then do:
            run day-360(v-dt1,v-dt2 - 1,360,output dn1,output dn2).
            if dn1 <> 30 then lnsci.iv-sc = round(dn1 * pkanketa.summa * pkanketa.rateq / 36000,2).
        end.
    end.
    
    v-dt1 = v-dt2.
end.

run lnsch-ren(s-lon).
release lnsch.

run lnsci-ren(s-lon).
release lnsci.

find current lon exclusive-lock.
lon.day = day(v-regdt).
find current lon no-lock.

