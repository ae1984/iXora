/* pkdebtrep.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Отчеты по работе с задожниками
 * RUN
        
 * CALLER
    pkdebts.p        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-14-6
 * AUTHOR
        18.02.2004 suchkov
 * CHANGES
        05.04.2004 tsoy новые пункты меню 
*/

def var v-select as integer.
define variable v-sort   as character extent 3 initial ["ЗАДОЛЖЕННИКУ","ОФИЦЕРУ","СТАТУСУ"].
define variable v-smod   as character extent 3 format "x(15)" initial ["pkdebtdat.lon","pkdebtdat.rwho","pkdebtdat.sts"].
define variable v-filter as character extent 4 initial ["БЕЗ ФИЛЬТРА","ПО ОФИЦЕРУ","ПО ЗАДОЛЖЕННИКУ","ПО СТАТУСУ"].
define variable v-fmod   as character extent 4 format "x(50)" initial [" ",
                                                        "where pkdebtdat.rwho = v-obraz",
                                                        "where pkdebtdat.lon = v-obraz",
                                                        "where pkdebtdat.sts = v-obraz"].
define new shared variable v-obraz  as character .
define variable v-fil    as character format "x(50)" initial " " .
define variable v-beg    as date initial 01/01/04. /*date("01/01/" + string(year(today),"99").*/
define variable v-end    as date initial today.
define variable i-sort   as integer initial 1.
define variable i-filter as integer initial 1.

define frame f-period
    v-beg label "Начало периода"
    v-end label "Конец периода"
    with side-labels overlay centered.

define frame f-obraz
    v-obraz label "Образец" with overlay centered .

v-beg = date(1,1,year(today)).

repeat:
v-select = 0.

run sel2 ("ОТЧЕТЫ ПО РАБОТЕ С ЗАДОЛЖНИКАМИ", "1. Отчет по задолжникам|2. Отчет по работам|3. Отчет вышедших из задолжников |4. ВЫХОД  ", output v-select).

if v-select = 0 then return.
  case v-select:
    when 1 then run pkdebr1.
    when 2 then run pkdebr2.
    when 3 then run pkdebr3.
    when 4 then return.

end.
