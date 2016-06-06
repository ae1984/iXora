/* is-wrkday.i
 * MODULE
        Кредиты, ЦБ
* DESCRIPTION
        Погашение кредита в день зарплаты
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
        25/05/2004  madiar
        26/06/2012  id01143 Kalbagayev Sayat Добавил функции определения предыдущего (preworkday) и последующего (nextworkday) рабочего дня (ТЗ 1328)
 * CHANGES
*/

function is-working-day returns logical (input dt as date).
find cls where cls.whn = dt no-lock no-error.
if available cls and cls.del then return true. /* если есть запись в cls, то все ясно */

find hol where hol.hol eq dt no-lock no-error. /* праздники */
if available hol then return false.

def var v-weekbeg as int init 2.
def var v-weekend as int init 6.

/* если текущая неделя - то начало и конец рабочей недели из справочника, если нет - то с понедельника по пятницу */

if dt >= today - weekday(today) + 1 and dt <= today + 7 - weekday(today) then do:
  find sysc where sysc.sysc = "WKEND" no-lock no-error.
  if available sysc then v-weekend = sysc.inval.
  find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
  if available sysc then v-weekbeg = sysc.inval.
end.

if weekday(dt) >= v-weekbeg and weekday(dt) <= v-weekend then return true.
else return false.

end function.

function nextworkday returns date (input dt as date).
 def var dt1 as date.
 dt1 = dt + 1.
 repeat:
   if is-working-day(dt1) then return(dt1).
   dt1 = dt1 + 1.
 end.
 return dt1.
end function.

function preworkday returns date (input dt as date).
  def var dt1 as date.
  dt1 = dt - 1.
  repeat:
    if is-working-day(dt1) then return(dt1).
    dt1 = dt1 - 1.
  end.
 return dt1.
end function.
