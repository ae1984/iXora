/* ciflgot.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Список всех льготных тарифов всех клиентов
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
        29/12/04 sasco
 * CHANGES
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

{gl-utils.i}

define shared variable g-today as date.

displ "Ждите..." with row 5 centered no-label frame wfr. pause 0.

output to cif.csv.
put unformatted "CIF;КЛИЕНТ;КОД;НАИМЕНОВАНИЕ ТАРИФА;СУММА;ПРОЦЕНТ;МИНИМУМ;МАКСИМУМ" skip.
for each tarifex where tarifex.stat = 'r' no-lock by tarifex.cif:
  find cif where cif.cif = tarifex.cif no-lock no-error.
  if not avail cif then next.
  put unformatted 
      cif.cif ";"
      trim (cif.prefix + " " + cif.name) ";"
      tarifex.str5 ";" 
      tarifex.pakalp ";" 
      XLS-NUMBER (tarifex.ost ) ";"
      XLS-NUMBER (tarifex.proc) ";" 
      XLS-NUMBER (tarifex.min1) ";"
      XLS-NUMBER (tarifex.max1)
      skip.
end.
output close.

hide frame wfr no-pause.
unix silent value ("cptwin cif.csv excel").
unix silent value ("rm cif.csv").

