/* clntarifex.p
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
        30.11.2004 saltanat - Внесла проверку на действующие тарифы.
        15.07.2005 saltanat - Включила поля пункта тарифа и полного наименования.
        02.02.10 marinav - расширение поля счета до 20 знаков
*/

/* clntarifex.p
   Отчет по льготным тарифам клиента

   28.04.2003 nadejda
*/

{global.i}

def input parameter p-cif as char.      /* код клиента */

find cif where cif.cif = p-cif no-lock no-error.

if not avail cif then do:
  message skip " Клиент с кодом" p-cif "не найден !" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

output to clnlgot.txt.
put " ЛЬГОТНЫЕ ТАРИФЫ КЛИЕНТА" skip(1)
    " " cif.cif " " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(60)" skip(1)
    " " g-today format "99/99/9999" skip(1)
    "КОД | УСТ | НАИМЕНОВАНИЕ ТАРИФА            |      СУММА |  ПРОЦЕНТ |    МИНИМУМ |   МАКСИМУМ | ПУНКТ ТАР|  НОМЕР СЧЕТА КЛИЕНТА " skip
    fill("-", 125) format "x(125)" skip.

for each tarifex where tarifex.cif = cif.cif and tarifex.stat = 'r' no-lock:
  find first tarif2 where tarif2.str5 = tarifex.str5 no-lock no-error.
  find first tarifex2 where tarifex2.cif = tarifex.cif and tarifex2.str5 = tarifex.str5 and tarifex2.stat = 'r' no-lock no-error.
  put tarifex.str5 format "x(3)" " | " 
      " " substr(tarifex.who, 1, 1) format "x" "  | " 
      tarifex.pakalp format "x(30)" " | " 
      tarifex.ost format "zzz,zz9.99" " | " 
      tarifex.proc format "zz9.9999" " | " 
      tarifex.min1 format "zzz,zz9.99" " | " 
      tarifex.max1 format "zzz,zz9.99" " | "
      if avail tarif2 then tarif2.punkt else " " format "x(8)" " | " 
      if avail tarifex2 then tarifex2.aaa else " " format "x(20)" skip.
end.


output close.

run menu-prt ("clnlgot.txt").



