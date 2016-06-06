/* day-360.p
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
        31/12/99 pragma
 * CHANGES
*/

define input parameter p-dt1 as date.
define input parameter p-dt2 as date.
define input parameter p-basedy as integer.
define output parameter p-dn1 as integer.
define output parameter p-dn2 as decimal.
define variable v-dt1 as date.
define variable v-dt2 as date.
define variable n0 as integer.
def var v-m as int.
def var v-y as int.
def var v-m0 as int.
def var v-y0 as int.
def var v-day as int.


p-dn1 = 0.
p-dn2 = 0.
if p-dt2 lt p-dt1 then return.
p-dn2 = 1.
p-dn1 = p-dt2 - p-dt1 + 1.
if p-basedy = 360
then do:
     p-dn1 = 0.
     v-m = month(p-dt1).
     v-y = year(p-dt1).
     v-day = day(p-dt1) - 1.
     v-m0 = month(p-dt2).
     v-y0 = year(p-dt2).
     do while not (v-m0 eq v-m and v-y0 eq v-y) :
         p-dn1 = p-dn1 + 30 - v-day.
         v-day = 0.
         v-m = v-m + 1.
         if v-m gt 12 then do:
            v-y = v-y + 1.
            v-m = 1.
         end.
     end.       

     if v-m eq 4 or v-m eq 6 or v-m eq 9 or v-m eq 11  
     then 
        n0 = 30.
     else if v-m ne 2 then n0 = 31.
     else n0 = day(date(3,1,v-y) - 1).
     /*
     message day(p-dt2)" " n0 " " v-day " " p-dn1 .
     */
     if day(p-dt2) eq n0 then p-dn1 = p-dn1 + 30 - v-day.
     else p-dn1 = p-dn1 + day(p-dt2) - v-day.
end.

