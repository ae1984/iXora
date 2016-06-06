/* dcls39c.p
 * MODULE
        ТЗ-1223 Переоценка активов и обязательств в ин.валюте. 100-раз видоизменено, текст с результатом не сходится
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        04/01/2012 evseev
 * BASES
        BANK
 * CHANGES
        06/01/2012 evseev - если не банк то не отрабатывать
        24/04/2012 evseev - если МКО то не отрабатывать
*/

{global.i}
def var v-city as char.
def var v-bal like jl.dam.
def var v-revers as logical.
def var s-jh like jh.jh.
def var v-templ as char.
def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
def var day_amt like jl.dam.
define shared var s-target as date.

def stream s-file.
output stream s-file to value("dcls39c2_" + string(year(g-today),"9999") + "_" + string(month(g-today),"99") + "_" + string(day(g-today),"99") + ".csv").

/*def stream s-file1.
output stream s-file1 to value("dcls39c2_" + string(year(g-today),"9999") + "_" + string(month(g-today),"99") + "_" + string(day(g-today),"99") + ".log").
*/

put stream s-file unformatted "Балансовый счет;Наименование счета;Остаток по номиналу;Вид валюты;Учетный курс;Рыночный курс;Разница между курсами;Сумма переоценки;Переоценка Дт5703;Переоценка Кт4703;Наименование филиала".
put stream s-file unformatted skip.

FUNCTION XLS-NUMBER returns char (num as decimal).
    if num ge 0 then return replace (string (num, "zzzzzzzzzzz9.99"), ".", ",").
                else return "-" + trim (replace (string (absolute(num), "zzzzzzzzzzz9.99"), ".", ",")).
END function.



find first cmp no-lock no-error.
if avail cmp then do:
   v-city = "".
   if entry(2,cmp.addr[1]) matches "*г.*" then v-city = entry(2,cmp.addr[1]).
      else if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).

   /*if cmp.name matches "*МЕТРОКОМБАНК*" then . else return.*/

   if cmp.name matches "*МКО*" then return.
end.



for each gl where gl.totact = no and gl.totlev = 1 no-lock:
  if (substr(trim(string(gl.gl)),1,1) <> "1") and (substr(trim(string(gl.gl)),1,1) <> "2") then next.
   /*
  if gl.gl >= 185800 and gl.gl <= 185899 then next.
  if gl.gl >= 135100 and gl.gl <= 135199 then next.
  if gl.gl >= 135200 and gl.gl <= 135299 then next.
  if gl.gl >= 215100 and gl.gl <= 215199 then next.
  if gl.gl >= 215200 and gl.gl <= 215299 then next.
   */
  for each crc no-lock:
     if crc.crc = 1 then next.
     /*find last crchis where crchis.crc = crc.crc and crchis.rdt < g-today no-lock no-error.*/
     find last crcpro where crcpro.crc = crc.crc and crcpro.regdt <= s-target no-lock no-error.

     find last glbal where glbal.gl = gl.gl and glbal.crc = crc.crc /*and glday.gdt <= p-dt*/ no-lock no-error.
     if avail glbal then do:
         v-bal = glbal.bal.

         v-revers = false.
         find first sub-cod where sub-cod.acc = string(glbal.gl) and sub-cod.d-cod = 'gldic' no-lock no-error.
         if avail sub-cod and sub-cod.ccode = '01' then v-revers = true.

         for each jl where jl.jdt = g-today and jl.gl = glbal.gl and jl.crc = glbal.crc no-lock:
             if substr(trim(string(jl.gl)),1,1) = "1" then do:
                v-bal = v-bal + jl.dam - jl.cam.
             end.
             if substr(trim(string(jl.gl)),1,1) = "2" then do:
                v-bal = v-bal + jl.cam - jl.dam.
             end.

         end.
         if v-bal = 0 then next.

         if substr(trim(string(glbal.gl)),1,1) = "2" then v-bal = v-bal * -1.


         day_amt = v-bal * (crcpro.rate[1] - crc.rate[1]).

         if day_amt = 0 then next.
         /*
         v-templ = "dcl0012".

         v-param = string(maximum(- day_amt,0)) + vdel + "Переоценка по счету " + string(glbal.gl) + vdel +
                   string(maximum(day_amt,0)).

         s-jh = 0.
         run trxgen (v-templ, vdel, v-param, "dcl" , "" , output rcode, output rdes, input-output s-jh).

         if rcode ne 0 then do:
             put stream s-file1 unformatted "!; rcode <> 0; " + string(glbal.gl) + "; " + string(day_amt) + "; " + rdes.
             put stream s-file1 unformatted skip.
             message rdes.
             pause.
         end. else do:
             put stream s-file1 unformatted "; rcode = 0; " + string(glbal.gl) + "; " + string(day_amt) + "; " + string(s-jh).
             put stream s-file1 unformatted skip.
         end.
         */
         if substr(trim(string(glbal.gl)),1,1) = "1"  then
            put stream s-file unformatted string(glbal.gl) + ";" + gl.des + ";" + XLS-NUMBER(v-bal) + ";" + crc.code + ";"
                 + XLS-NUMBER(crc.rate[1]) + ";" + XLS-NUMBER(crcpro.rate[1])
                 + ";" + XLS-NUMBER(crcpro.rate[1] - crc.rate[1]) + ";" + XLS-NUMBER(day_amt).
         if substr(trim(string(glbal.gl)),1,1) = "2"  then
            put stream s-file unformatted string(glbal.gl) + ";" + gl.des + ";" + XLS-NUMBER(v-bal * -1) + ";" + crc.code + ";"
                 + XLS-NUMBER(crc.rate[1]) + ";" + XLS-NUMBER(crcpro.rate[1])
                 + ";" + XLS-NUMBER(crcpro.rate[1] - crc.rate[1]) + ";" + XLS-NUMBER(day_amt).

         if day_amt > 0 then
              put stream s-file unformatted  ";0;" + XLS-NUMBER(day_amt).
         else
              put stream s-file unformatted  ";" + XLS-NUMBER(day_amt * -1) + ";0".

         put stream s-file unformatted ";" + v-city.

         put stream s-file unformatted skip.
     end.
  end.
end.

/*output stream s-file1 close.*/
output stream s-file close.