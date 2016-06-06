/* elx-rpm.p
 * MODULE
        Elecsnet 
 * DESCRIPTION
        Отчет по платежам Алма-тв
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-4-16-16-6
 * AUTHOR
        22/05/2006 dpuchkov
 * CHANGES
        18.10.2006 u00124 Добавил платежи Казахтелеком.
        12.02.2007 id00004 добавил alias
*/

{comm-txb.i}
def var seltxb as int no-undo.
seltxb = comm-cod().

def var dt1 as date no-undo.
def var dt2 as date no-undo.

def var cnts as integer init 0 no-undo.
def var amts as decimal init 0 no-undo.


def buffer b-ktrekv for sysc.
find last b-ktrekv  where b-ktrekv.sysc  = "KTREKV" no-lock no-error.


def temp-table tb no-undo
    field arp like commonls.arp
    field bn  like commonls.bn
    field cnt as int
    field sum like remtrz.amt
    INDEX bn_idx  bn.

define query qc for tb.
define browse bc query qc
       displ tb.bn format "x(45)"
             tb.cnt format ">>>>>>"
             tb.sum format ">>>>>>>>>>>>>>>9.99"
       with 12 down no-label
       title 
"  Организация                                  Кол-во              Сумма  ".

define frame fc
       "                      ОТЧЕТ ПО ИСХОДЯЩИМ ПЛАТЕЖАМ" skip
       "          Начало периода:" dt1 view-as text "    конец периода:" dt2
       view-as text skip(1)
       bc help "F4 - выход, стрелки для передвижения"
       skip "ВСЕГО:" 
       cnts format ">>>>>>" at 50 view-as text
       amts format ">>>>>>>>>>>>>>>9.99" view-as text
with row 1 centered no-label no-box.


update dt1 label "Начальная дата" dt2 label "Конечная дата" 
with centered frame df.

/* ALMATV */

find last sysc where sysc.sysc = "ALMARP" no-lock no-error.
create tb.
tb.bn = "Алма ТВ".
tb.arp = sysc.chval.
tb.cnt = 0.0.
release tb.

create tb.
tb.bn = "Казахтелеком".
tb.arp = ENTRY(1, b-ktrekv.chval).
tb.cnt = 0.0.
release tb.



for each remtrz where valdt1 >= dt1 and valdt1 <= dt2 no-lock:
   find tb where tb.arp = remtrz.sacc no-error.
   if avail tb then
   do:
      tb.cnt = tb.cnt + 1.
      tb.sum = tb.sum + remtrz.amt.
      cnts = cnts + 1.
      amts = amts + remtrz.amt.
   end.
end.








open query qc for each tb where tb.sum > 0 no-lock.
enable all with frame fc.
displ dt1 dt2 cnts amts with frame fc.
wait-for window-close of frame fc focus browse bc.

hide all.
hide browse bc.
hide frame fc.
for each tb:
delete tb.
end.

