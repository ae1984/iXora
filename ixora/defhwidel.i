/* defhwidel.i
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
        03/11/2004 sasco - Добавил вывод БИК банка
        06/10/2006 madiyar - добавил вывод номера договора
*/

/* ---------------- Statement's Header Creating ----------------------- */

{comm-bik.i}

find first cmp .
put cmp.name format "x(30)" at 1.
put "Изготовлен "  + string(today,"99/99/9999") + " " +
string(time,"HH:MM:SS") at 90 format "x(30)".
run pwskip(0).
put "БИН " + trim(cmp.addr[2]) + ", " +
trim(cmp.addr[3]) format "x(59)" at 1 .

put string(page_num,"zzzz9") format "x(5)" to 113 " лист" to 119 .

run pwskip(0).
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then
find first point where point.point = integer( ofc.regno / 1000 - 0.5 )
no-lock no-error.
if available point then do:
   put point.name at 1. run pwskip(0).
   put trim(point.addr[1]) format "x(50)" at 1.
      find sysc where sysc.sysc = 'REKVP' no-lock no-error.
      if avail sysc and sysc.chval = "1" then do:
        /*бик*/
        run pwskip(0).
        put "БИК " + comm-bik()  format "x(59)" at 1 .
        /*бик*/
      end.
end.

if stmsts = "CPY" then put "ДУБЛИКАТ " at 90.
run pwskip(1).

/* put branch format "x(30)".*/


if stmsts = "INF" then
  put "СПРАВКА ПО ОБОРОТАМ ССУДНОГО СЧЕТА КЛИЕНТА  " at 35.
else
  put "В Ы П И С К А   П О   С Ч Е Т У  Nr. " at 40.
/*
put trim(string(seq,"zzz9999")).
*/
run pwskip(1).

put "с  " + string(acc_list.d_from,"99/99/9999") + nf6 + string(acc_list.d_to,"99/99/9999") format "x(60)" at 40.  run pwskip(1).


define variable custname as character.
run getcv("h-custname", output custname).
define variable h-cif as character.
run getcv("h-cif", output h-cif).

if acc_list.d_to < g-today then do:

put trim(substring(custname,1,60)) format "x(60)" at 1. run pwskip(0).
if trim(substring(custname,61,60)) <> "" then do:
   put trim(substring(custname,61,60)) format "x(60)" at 1.
   run pwskip(0).
end.
put nf8 at 1 h-cif at 15.
run pwskip(0).
find first loncon where loncon.lon = acc_list.aaa no-lock no-error.
if avail loncon then do:
  put unformatted "Номер договора : " loncon.lcnt.
  run pwskip(0).
end.

end.
else do:
put substring(custname,1,60) format "x(60)" at 1. put "ВНИМАНИЕ!" at 70.
run pwskip(0).
if trim(substring(custname,61,60)) <> "" then do:
   put trim(substring(custname,61,60)) format "x(40)" at 1.
   put "ОБОРОТЫ ТЕКУЩЕГО ДНЯ ПО СЧЕТУ" at 61.
   /*   123456789012345678901234567890 */
   run pwskip(0).
   put "ЯВЛЯЮТСЯ ТОЛЬКО ИНФОРМАЦИЕЙ!" at 62.
   run pwskip(0).
end.
else do:
  put nf8 at 1 h-cif at 15.
  put "ОБОРОТЫ ТЕКУЩЕГО ДНЯ ПО СЧЕТУ " at 61.
  run pwskip(0).
  put "ЯВЛЯЮТСЯ ТОЛЬКО ИНФОРМАЦИЕЙ!" at 62.
  run pwskip(0).
end.
end.

run pwskip(1).

/* ------------------------------------------------------------------- */

