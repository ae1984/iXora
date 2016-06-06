/* x-eomint.f
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
        09/08/2012 kapar - ТЗ ASTANA-BONUS
*/

/* x-eomint.v */

def var fdonm as date.
def var vexpint like jl.dam.
def var lastint like vexpint.
def var vint2mon like jl.dam label "2 MONTHS AGO".
def var vint1mon like vint2mon label "LAST MONTH".
def var vintcmon like vint2mon label "THIS MONTH".
def var vinttday like vint2mon label "PAY OFF".
def var damu_vinttday like vint2mon label "PAY OFF".
def var astana_vinttday like vint2mon label "PAY OFF".
def var lastmo  as int.
def var lastyr  as int.
define variable vsa as decimal.

lastmo = month(g-today) - 1.
lastyr = year(g-today).
if lastmo eq 0
then do:
       lastmo = 12.
       lastyr = lastyr - 1.
     end.

if month(g-today) eq 12
then fdonm = date(1,1,year(g-today) + 1).
else fdonm = date(month(g-today) + 1,1,year(g-today)).
