/* dates.i
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
        11/03/2011 k.gitalov
 * CHANGES
        26/06/2012 s.kalbagayev id01143 добавлены функции MonthsAdd, MonthsBetween и DaysInInterval, DaysInYear (ТЗ 1328)
        29/06/2012 id01143 скорректирован рассчет количества дней в функции DaysInInterval для базы 30/360
        03/08/2012 id01143 изменен алгоритм рассчета количества дней в функции DaysInInterval для базы 30/360
        03/01/2012 id01143 исправлена ошибка в функции DaysInInterval
*/


function DaysInMonth returns integer (input p-dt as date).
   def var res as int.
   def var mm as int.
   def var yy as int.
   def var dt1 as date.
   dt1 = date(month(p-dt),1,year(p-dt)).
   mm = month(dt1) + 1.
   yy = year(dt1).
   if mm = 13 then assign yy = yy + 1 mm = 1 .
   res =  date( mm , 1 , yy) - dt1.
   return res.
end function.

function LastDay returns log (input p-dt as date).
   if month(p-dt + 1) = month(p-dt) then return false.
   else return true.
end function.

function MonthsAdd returns date (input p-dt as date,input p-num as integer).
 /*
 функция прибавляет к заданной дате указанное количеcтво месяцев
 p-dt  - дата
 p-num - количество месяцев
 */
 def var v-date as date no-undo.
 def var mm as integer.
 def var yy as integer.
 def var dd as integer.
 def var ny as integer.
 def var nm as integer.
 def var nd as integer.
 do:
   ny = truncate(p-num / 12,0).
   nm = p-num - ny * 12.
   if nm < 0 then
     do:
       ny = ny - 1.
       nm = p-num - ny * 12.
     end.

   mm = month(p-dt).
   yy = year(p-dt) + ny.

   if mm + nm <= 12 then mm = mm + nm.
   else
     do:
       yy = yy + 1.
       mm = (mm + nm) mod 12.
     end.

   run mondays(month(p-dt),year(p-dt), output nd).
   run mondays(mm,yy, output dd).

   if not(day(p-dt) = nd and nd < dd) then
     if day(p-dt) < dd then dd = day(p-dt).
   v-date = date(mm,dd,yy).
 end.
 return(v-date).
 end function.

function MonthsBetween returns integer (input p-dt as date,input p-dt1 as date).
 /*
 функция возвращает целое количеcтво месяцев между двумя датами
 p-dt  - дата
 p-dt1 - дата
 */
 def var v-date as date no-undo.
 def var mm as integer.
 def var yy as integer.
 def var nd1 as integer.
 def var nd2 as integer.
 def var nm as integer.
 def var nd as integer.
 do:
   run mondays(month(p-dt),year(p-dt),output nd1).
   run mondays(month(p-dt1),year(p-dt1),output nd2).

   nm = 12 * (year(p-dt1) - year(p-dt)) + month(p-dt1) - month(p-dt).
   nd = p-dt1 - date(month(p-dt1), minimum(day(p-dt),nd2),year(p-dt1)).
   if day(p-dt) = nd1 and day(p-dt1) = nd2 then nd = 0.
   if nd * nm < 0 then nm = nm + 1 * (nd / abs(nd)).
 end.
   return(nm).
end function.

function DaysInInterval returns integer (input p-dt as date, input p-dt1 as date,input base as character).
 /*
 функция возвращает количество дней между датами в зависимости от базы начисления
 p-dt  - дата
 p-dt1 - дата
 base  - база (30/360, 31/360, 30/365, 31/365)
 */
def var v-date as date no-undo.
def var nb as integer.
def var yy as integer.
def var ny as integer.
def var nd1 as integer.
def var nd2 as integer.
def var nm as integer.
def var nd as integer.
def var nx as integer.
def var nz as integer.
do:
   case trim(base):
        when "30/360" then nb = 1.
        when "30/365" then nb = 2.
        when "31/360" then nb = 3.
        when "31/365" then nb = 4.
        otherwise nb = 4.
    end case.
    if p-dt > p-dt1 then return 0.
    if nb = 4 then do:
        nd = p-dt1 - p-dt.
        return(nd).
    end.
    if nb = 3 then do:
        ny = truncate(monthsbetween(p-dt,p-dt1) / 12,0).
        nd = ny * 360 + (p-dt1 - monthsadd(p-dt,ny * 12)).
        return(nd).
    end.
    if nb = 2 then do:
        ny = truncate(monthsbetween(p-dt,p-dt1) / 12,0).
        nm = monthsbetween(monthsadd(p-dt,ny * 12),p-dt1).
        if month(monthsadd(p-dt,ny * 12 + nm)) = month(p-dt1) then nd = (monthsadd(p-dt,ny * 12) - p-dt) + 30 * nm + (p-dt1 - monthsadd(p-dt,ny * 12 + nm)).
        else nd = (monthsadd(p-dt,ny * 12) - p-dt) + 30 * nm + 30 + day(p-dt1) - day(monthsadd(p-dt,ny * 12 + nm)).
        return(nd).
    end.
    if nb = 1 then do:
        nm = monthsbetween(p-dt,p-dt1).
        if lastday(p-dt1) then nx = 30. else nx = day(p-dt1).
        if day(p-dt) > 30 then nz = 30. else nz = day(p-dt).
        if month(p-dt1) <> month(monthsadd(p-dt,nm)) then nd = 30. else nd = 0.
        nd = nd + 30 * nm + nx - nz.
        return(nd).
    end.
end.
return(nd).
end function.

function DaysInYear returns integer (input p-dt as date,input base as character).
 /*
 функция возвращает количество дней в базовом году в зависимости от базы начисления
 p-dt  - дата
 p-dt1 - дата
 base  - база (30/360, 31/360, 30/365, 31/365)
 */
def var v-date as date no-undo.
def var nb as integer.
def var yy as integer.
def var ny as integer.
def var nd1 as integer.
def var nd2 as integer.
def var nm as integer.
def var nd as integer.
do:
   case trim(base):
        when "30/360" then nd = 360.
        when "30/365" then nd = 365.
        when "31/360" then nd = 360.
        when "31/365" then nd = 365.
        otherwise nd = monthsadd(p-dt,ny * 12) - p-dt.
    end case.
end.
return(nd).
end function.