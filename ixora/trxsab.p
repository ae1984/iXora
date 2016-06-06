/* trxsab.p
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
        01/09/04 sasco увеличил формат номера проводки
*/

def var v-trx as int format "zzzzzzzzz9".

update v-trx label 'Транзакция'.

find first jl where jl.jh = v-trx no-lock no-error.
if avail jl then 
   disp jl.trx label 'Шаблон' format "x(20)" . 
 else 
   message "Номера " v-trx  " нет. Проверьте номер.".
pause. 
