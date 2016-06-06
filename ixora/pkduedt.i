/* pkduedt.i
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

/* pkduedt.i 
   Расчет даты от заданной даты + заданное количество месяцев

   10.02.2003 nadejda
*/


function pkduedt returns date (p-dtb as date, p-srok as integer).
  def var v-dte as date.
  def var v-day as integer.
  def var v-month as integer.
  def var v-year as integer.
  def var v-off as integer.

  v-dte = p-dtb.
  v-day = day(v-dte).
  v-month = month(v-dte).
  v-year = year(v-dte).
  v-off = 0.
  
  v-month = v-month + p-srok.
  run offset(input-output v-month, input-output v-year).

  repeat:
    v-dte = date(v-month, v-day, v-year) no-error.
    if not error-status:error or v-day = 1 then leave.
    v-off = v-off + 1.
    v-day = v-day - 1.
  end.

  if v-off > 0 then do:
    v-day = v-off.
    v-month = v-month + 1.
    run offset(input-output v-month, input-output v-year).
  end.
  v-dte = date(v-month, v-day, v-year).                  

  return v-dte.
end.


procedure offset.
  def input-output parameter p-month as integer.
  def input-output parameter p-year as integer.

  def var v-offset as integer.

  v-offset = truncate((p-month - 1) / 12, 0).
  p-month = p-month - 12 * v-offset.
  p-year = p-year + v-offset.
end procedure.


function pkduedtm returns date (p-dtb as date, p-srok as integer).
  def var v-dte as date.
  def var v-day as integer.
  def var v-month as integer.
  def var v-year as integer.
  def var v-mdays as integer.

  v-dte = p-dtb.
  v-day = day(v-dte).
  v-month = month(v-dte).
  v-year = year(v-dte).
  
  v-month = v-month + p-srok.
  run offset(input-output v-month, input-output v-year).

  run mondays(v-month, v-year, output v-mdays).

  if v-day > v-mdays then v-day = v-mdays.
  v-dte = date(v-month, v-day, v-year).                  

  return v-dte.
end.

