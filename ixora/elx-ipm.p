/* elx-ipm.p
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
        5-4-16-16-5
 * AUTHOR
        05/05/2006 dpuchkov.
 * CHANGES
        18.10.2006 u00124 добавил платежи Казахтелеком.
        12.02.2007 id00004 добавил alias
*/


{comm-txb.i}
def var seltxb as int no-undo.
seltxb = comm-cod().

def var dt1 as date     no-undo.
def var dt2 as date     no-undo. 
def var totc as integer no-undo.
def var tots as decimal no-undo.



def temp-table tb no-undo 
    field grp like commonls.grp
    field type like commonls.type
    field arp like commonls.arp
    field bn like commonls.bn
    field cnt as integer
    field sum like commonpl.sum
    INDEX bn_idx  bn .


define query qc for tb.
define browse bc query qc
       displ tb.bn format "x(45)"
             tb.cnt format ">>>>>>"
             tb.sum format ">>>>>>>>>>>>>>>9.99"
       with 12 down no-label
       title 
"  Организация                                  Кол-во              Сумма  ".

define frame fc
       "                      ОТЧЕТ ПО ПРИНЯТЫМ ПЛАТЕЖАМ(Elecsnet)" skip
       "          Начало периода:" dt1 view-as text "    конец периода:" dt2
       view-as text skip(1)
       bc help "F4 - выход, стрелки для передвижения"
       skip "ВСЕГО:" 
       totc format ">>>>>>" at 50 view-as text
       tots format ">>>>>>>>>>>>>>>9.99" view-as text
with row 1 centered no-label no-box.

update dt1 label "Начальная дата" dt2 label "Конечная дата" 
with centered frame df.
totc = 0.
tots = 0.0.



for each mobi-almatv where mobi-almatv.rdt >= dt1  and mobi-almatv.rdt <= dt2 no-lock:
   find first tb where tb.bn = "Алма ТВ(Elecsnet)" no-error.
   if not avail tb then
      do:
          create tb.
          assign
          tb.bn = "Алма ТВ(Elecsnet)"
          tb.grp = 0
          tb.type =0
          tb.cnt = 0
          tb.sum = 0.0.
      end.
   tb.cnt = tb.cnt + 1.
   tb.sum = tb.sum + mobi-almatv.summ.
   totc = totc + 1.
   tots = tots + mobi-almatv.summ.

end.


for each mobi-telecom where mobi-telecom.rdt >= dt1  and mobi-telecom.rdt <= dt2 no-lock:
   find first tb where tb.bn = "Казахтелеком(Elecsnet)" no-error.
   if not avail tb then
      do:
          create tb.
          assign
          tb.bn = "Казахтелеком(Elecsnet)"
          tb.grp = 0
          tb.type =0
          tb.cnt = 0
          tb.sum = 0.0.
      end.
   tb.cnt = tb.cnt + 1.
   tb.sum = tb.sum + mobi-telecom.amt.
   totc = totc + 1.
   tots = tots + mobi-telecom.amt.

end.


hide message.
open query qc for each tb no-lock.
enable all with frame fc.
displ dt1 dt2 totc tots with frame fc.
wait-for window-close of frame fc focus browse bc.

hide all.
hide browse bc.
hide frame fc.
for each tb:
delete tb.
end.

