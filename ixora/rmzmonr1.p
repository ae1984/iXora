/* rmzmonr1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Монитор очередей
        Печать платежей
 * RUN
        plrep-br -> rmzmonr1
 * CALLER
        Список процедур, вызывающих этот файл 
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6-3-14
 * AUTHOR
        01/06/06 ten
 * CHANGES
*/
{global.i}
{get-dep.i}



define shared temp-table clrrep no-undo
  field cdep as char format "x(25)"
  field depnamelong as char format "x(25)" label "Подразделение"
  field depnameshort as char format "x(14)".

define input parameter p-dep as char.
def input parameter p-date as date.
DEFINE BUFFER bque FOR que.

def var dt as date no-undo.
def var v-name like cif.fname no-undo.
def var v-sub as int no-undo.
def var v-dep as integer no-undo.
def var tdate as date no-undo.
def var ss as decimal format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
def var i as integer no-undo.
def var v-print as logical init no no-undo.


dt = g-today.
output to rpt.txt {5}.

put unformatted string(today) " " string(time, "HH:MM:SS") " " g-ofc skip(1).
find first clrrep where clrrep.cdep = p-dep no-error.

put unformatted "Подразделение: " clrrep.depnamelong skip 
"Платежи, в очереди на "  skip
if "{5}" = "append" then "ГРОСС" else "КЛИРИНГ" 
skip(1).
F1:
for each {2} no-lock where {3}:
   if p-dep = "2" then do:
      find first remtrz where remtrz.remtrz = {4} and remtrz.cover = {6} and remtrz.valdt2 = p-date and remtrz.rcbank = "TXB00" no-lock no-error.
      if avail remtrz and remtrz.source = "PNJ" then do:
        put unformatted remtrz.remtrz {1} format "->>>,>>>,>>>,>>>,>>9.99"  skip.
        accumulate {1} (count total).
      end.
   end.
   else 
   if p-dep = "3" then do:
      find first remtrz where remtrz.remtrz = {4} and remtrz.cover = {6} and remtrz.valdt2 = p-date and remtrz.rcbank = "TXB00" no-lock no-error.
      if avail remtrz and remtrz.source = "IBH" then do:
        put unformatted remtrz.remtrz {1} format "->>>,>>>,>>>,>>>,>>9.99"  skip.
        accumulate {1} (count total).
      end.
   end.
   else
   if p-dep = "4" then do:
      find first remtrz where remtrz.remtrz = {4} and remtrz.cover = {6} and remtrz.valdt2 = p-date and remtrz.rcbank = "TXB00" no-lock no-error.
      if avail remtrz and remtrz.source = "INK" then do:
        put unformatted remtrz.remtrz {1} format "->>>,>>>,>>>,>>>,>>9.99"  skip.
        accumulate {1} (count total).
      end.
   end.
   else do:
      find first remtrz where remtrz.remtrz = {4} and remtrz.cover = {6} and remtrz.valdt2 = p-date and remtrz.rcbank = "TXB00" no-lock no-error.
      if avail remtrz then do:
         if remtrz.source <> "PNJ" and remtrz.source <> "IBH" and remtrz.source <> "INK" then do:
            put unformatted remtrz.remtrz {1} format "->>>,>>>,>>>,>>>,>>9.99"  skip.
            accumulate {1} (count total).
         end.
      end.
   end.
end.

put unformatted skip "Всего документов: " (accum count {1}) " на сумму:" (accum total {1}) format "->,>>>,>>>,>>>,>>>,>>9.99" skip(1).
ss = (accum total {1}). 
i  = (accum count {1}).
put unformatted skip(1) "ИТОГО документов : " i " на сумму:" ss format "->,>>>,>>>,>>>,>>>,>>9.99" skip(1).

