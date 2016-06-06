/* ispen-wrkday.i
 * MODULE
        Пенсионные платежи и соц. отчисления
* DESCRIPTION
        Пенсионные платежи и соц. отчисления
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
        20/01/2005  kanat
 * CHANGES
*/

function is-working-day returns logical (input dt as date).

def var v-weekbeg as int init 2.
def var v-weekend as int init 7. /* иногда ребята работают по субботам */

find cls where cls.whn = dt no-lock no-error.
if available cls and cls.del then return true. /* если есть запись в cls, то все ясно */

find hol where hol.hol eq dt no-lock no-error. /* праздники */
if available hol then return false.

if dt >= g-today - weekday(g-today) + 1 and dt <= g-today + 7 - weekday(g-today) then do:
if weekday(dt) >= v-weekbeg and weekday(dt) <= v-weekend then return true.
else return false.
end.

end function.