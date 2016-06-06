/* avg_curs.p
 * MODULE
        PRAGMA
 * DESCRIPTION
        Средний арифметический курс за квартал
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        28.04.2003 nadejda
 * CHANGES
*/                                      

{mainhead.i}

def var v-quart as integer.
def var v-year as integer.
def var v-month as integer.
def var v-dtb as date.
def var v-dte as date.
def var v-avg as deci.

v-year = year(g-today).

if month(g-today) < 4 then do:
  v-year = v-year - 1.
  v-quart = 4.
end.
else v-quart = (month(g-today) - 1) / 3.

v-month = v-quart * 3.

v-dtb = date(v-month - 2, 1, v-year).
if v-month < 12 then v-dte = date(v-month + 1, 1, v-year) - 1.
                else v-dte = date(12, 31, v-year).

update v-dtb label " НАЧАЛО ПЕРИОДА " skip
       v-dte label "  КОНЕЦ ПЕРИОДА "
       with centered row 6 title " СРЕДНИЕ КУРСЫ ВАЛЮТ ЗА ПЕРИОД " side-label.


output to avgcurs.txt.

put " СРЕДНИЕ КУРСЫ ЗА ПЕРИОД" skip(1) 
    " Начало периода " v-dtb skip 
    " Конец периода  " v-dte skip(1).

for each crc no-lock where crc.crc > 1:
  for each crchis where crchis.crc = crc.crc and crchis.rdt >= v-dtb and crchis.rdt <= v-dte no-lock:
    accumulate crchis.rate[1] (average).
  end.

  v-avg = (accum average crchis.rate[1]).
  if v-avg > 0 then put crc.crc " " crc.code " " v-avg format "zzzzzz9.9999" skip.
end.

output close.

run menu-prt ("avgcurs.txt").

