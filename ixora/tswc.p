/* tswc.p
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
        29/06/2011 madiyar - добавил детализированный вариант
*/

/* KOVAL */
{functions-def.i}
{comm-swt.i}

def shared var g-today as date.

def temp-table trmz
field rmz like remtrz.remtrz
field c as char format "x(4)"
field crc like crc.crc
field amt like remtrz.payment
field dt like remtrz.valdt2
field rbank like remtrz.rbank
index rmz  IS PRIMARY rmz
index rbank rbank.

def var v-d1 as date.
def var v-d2 as date.
def var fdt as date.
def var v-det as logi no-undo.
v-det = no.

v-d2 = g-today.
v-d1 = date(month(g-today),1,year(g-today)).

update "Укажите период с " v-d1 no-label " по " v-d2 no-label skip
       "Детализированный?" v-det no-label.
def var l as logical init false.

for each remtrz where valdt2 >= v-d1 and valdt2 <= v-d2 and tcrc <> 1 and (ptyp = '6' or ptyp = '2') no-lock:
 create trmz.
 assign trmz.rmz=remtrz.remtrz
        trmz.crc=remtrz.tcrc
        trmz.amt = remtrz.payment
        trmz.dt  = remtrz.valdt2
        trmz.rbank=remtrz.rbank.

 find first sub-cod where sub='rmz' and sub-cod.d-cod='iso3166' and
 acc=remtrz.remtrz no-lock no-error.
 if avail sub-cod then do:
                          assign trmz.c=sub-cod.ccode.
                          /*if l=false then assign fdt=remtrz.valdt2 l=true.*/
                       end.
                  else trmz.c='msc'.
end.

output to rpt.img.
put unformatted
FirstLine(1,1) skip
FirstLine(2,1) skip(1)
space (20) " В разрезе банков корреспондентов и стран получателей " skip(1)
" Период: " string(v-d1,"99/99/99") " - " string(v-d2,"99/99/99") skip(1)
fill ("-",64) format "x(64)" skip
"Страна                   Валюта    Кол-во              Сумма" skip
fill ("-",64) format "x(64)" skip
.
def var country as char init "  ".
def var corbank as char init "  ".

for each trmz no-lock break by trmz.rbank by trmz.c by trmz.crc.
 accumulate trmz.amt (count).
 accumulate trmz.amt (sub-count sub-total by trmz.c).
/* accumulate trmz.amt (sub-count sub-total by trmz.c by trmz.crc).*/
 accumulate trmz.amt (sub-count sub-total by trmz.crc).
 accumulate trmz.amt (sub-count by trmz.rbank).

 if first-of(trmz.rbank) then do:
         corbank="".
         if trmz.rbank<>"" then do:
         	  find first bankl where bank=trmz.rbank no-lock.
         	  if avail bankl then corbank = substr(bankl.name,1,55) + "(" + trmz.rbank + ")".
         end.

 	put unformatted skip(1) corbank  skip.
 end.

 if first-of(trmz.c) then do:
         country="".
         if trmz.c<>"" then do:
                  country=trmz.c.
                  run comm-swmc("iso3166", input-output country).
         end.

 	put unformatted country + "(" + trmz.c + ")" skip.
 end.

 if v-det then put unformatted space(4) trmz.rmz " " trmz.dt format "99/99/9999" space(17) trmz.amt format ">>>,>>>,>>>,>>>,>>9.99" skip.

 if last-of(trmz.crc) then do:
    find first crc no-lock where crc.crc=trmz.crc no-error.
    put unformatted space(28) crc.code "    "
    (accum sub-count by trmz.crc trmz.amt) format ">>>>>9"
    " "
    (accum sub-total by trmz.crc trmz.amt) format ">>>,>>>,>>>,>>>,>>9.99"
    skip.
 end.

 if last-of(trmz.c) then do:
 	put unformatted "Итого по " trmz.c space(26)
        (accum sub-count by trmz.c trmz.amt) format ">>>9"
        skip(1).
 end.

 if last-of(trmz.rbank) then do:
    put unformatted skip "Всего по "  corbank format "x(8)" space (27)
    (accum sub-count by trmz.rbank trmz.amt) format ">>>>>9" skip
    fill("=",64) format "x(64)" skip(1).
 end.

end.

put unformatted skip
    fill ("-",64) format "x(64)" skip
    "Всего: " space(28)
    (accum count trmz.amt) format ">>>>>9" skip
    fill ("-",64) format "x(64)" skip(5).

put unformatted
FirstLine(1,1) skip
FirstLine(2,1) skip(1)
" В разрезе валют по банкам корреспондентам " skip(1)
" Период: " string(v-d1,"99/99/99") " - " string(v-d2,"99/99/99") skip(1)
fill ("-",36) format "x(36)" skip
"Валюта    Кол-во              Сумма" skip
fill ("-",36) format "x(36)" skip
.

for each trmz no-lock break by trmz.rbank by trmz.crc.
 accumulate trmz.amt (count).
 accumulate trmz.amt (sub-count sub-total by trmz.crc).
 accumulate trmz.amt (sub-count by trmz.rbank).

 if first-of(trmz.rbank) then do:
         corbank="".
         if trmz.rbank<>"" then do:
         	  find first bankl where bank=trmz.rbank no-lock.
         	  if avail bankl then corbank = substr(bankl.name,1,55) + "(" + trmz.rbank + ")".
         end.

 	put unformatted skip corbank  skip.
 end.

 if last-of(trmz.crc) then do:
    find first crc no-lock where crc.crc=trmz.crc no-error.
    put unformatted crc.code "    "
    (accum sub-count by trmz.crc trmz.amt) format ">>>>>9" " "
    (accum sub-total by trmz.crc trmz.amt) format ">>>,>>>,>>>,>>>,>>9.99" skip.
 end.
 if last-of(trmz.rbank) then do:
 	put unformatted  "       " (accum sub-count by trmz.rbank trmz.amt) format ">>>>>9" skip
    fill (".",64) format "x(36)" skip(1).
 end.



end.

put unformatted skip fill ("-",36) format "x(36)" skip
    "Всего: "  (accum count trmz.amt) format ">>>>>9" skip
    fill ("-",36) format "x(36)" skip(1).


output close.

run menu-prt('rpt.img').
pause 0.
