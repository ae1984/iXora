/* comm-ipm.p
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
        04.09.2006 - u00124 добавил условие для прочих платежей
        12.09.2006 - u00124 разделил платежи биллинг / обычные.
*/

/* KOVAL */
/* SASCO */
{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var dt1 as date.
def var dt2 as date.
def var totc as integer.
def var tots as decimal.
def temp-table tb
    field grp like commonls.grp
    field type like commonls.type
    field arp like commonls.arp
    field bn like commonls.bn
    field cnt as integer
    field sum like commonpl.sum.

define query qc for tb.
define browse bc query qc
       displ tb.bn format "x(45)"
             tb.cnt format ">>>>>>"
             tb.sum format ">>>>>>>>>>>>>>>9.99"
       with 12 down no-label
       title 
"  Организация                                  Кол-во              Сумма  ".

define frame fc
       "                      ОТЧЕТ ПО ПРИНЯТЫМ ИЗВЕЩЕНИЯМ" skip
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
message "Step one..".
for each commonpl where commonpl.txb = seltxb and commonpl.date >= dt1 and commonpl.date <= dt2 and 
         deluid = ? no-lock use-index datenum:
         
   find first commonls where commonls.txb = seltxb and commonls.grp = commonpl.grp
   and commonls.type = commonpl.type and commonls.arp = commonpl.arp no-lock no-error.

   if avail commonls then do:

       if commonpl.billing = "1" then do:
            find first tb where tb.bn = commonls.bn + " Биллинг" no-error.
            if not avail tb then
               do:
                   create tb.
                   tb.bn = commonls.bn  + " Биллинг".
                   tb.grp = commonls.grp.
                   tb.type = commonls.type.
                   tb.cnt = 0.
                   tb.sum = 0.0.
               end.
            tb.cnt = tb.cnt + 1.
            tb.sum = tb.sum + commonpl.sum.
            totc = totc + 1.
            tots = tots + commonpl.sum.

       end.
       else do:
            find first tb where tb.bn = commonls.bn no-error.
            if not avail tb then
               do:
                   create tb.
                   tb.bn = commonls.bn.
                   tb.grp = commonls.grp.
                   tb.type = commonls.type.
                   tb.cnt = 0.
                   tb.sum = 0.0.
               end.
            tb.cnt = tb.cnt + 1.
            tb.sum = tb.sum + commonpl.sum.
            totc = totc + 1.
            tots = tots + commonpl.sum.
       end.


   end.
end.                 


for each commtk where commtk.txb = seltxb and commtk.date >= dt1 and commtk.date <= dt2 and deluid = ? no-lock use-index datenum:
         
   find first commonls where commonls.txb = seltxb and commonls.grp = commtk.grp
   and commonls.type = commtk.type and commonls.arp = commtk.arp  no-lock no-error.

   if avail commonls then do:
   
   find first tb where tb.bn = commonls.bn no-error.
   if not avail tb then
      do:
          create tb.
          tb.bn = commonls.bn.
          tb.grp = commonls.grp.
          tb.type = commonls.type.
          tb.cnt = 0.
          tb.sum = 0.0.
      end.
   tb.cnt = tb.cnt + 1.
   tb.sum = tb.sum + commtk.sum.
   totc = totc + 1.
   tots = tots + commtk.sum.
   end.
end.                 

/* VODOKANAL 
find first commonls where commonls.txb = seltxb and commonls.grp = 7 no-lock.
for each w_p_payment no-error where date >= dt1 and date <= dt2 no-lock :
   find first tb where tb.grp = 7 no-error.
   if not avail tb then
      do:
          create tb.
          tb.bn = commonls.bn.
          tb.grp = commonls.grp.
          tb.type = commonls.type.
          tb.cnt = 0.
          tb.sum = 0.0.
      end.
   tb.cnt = tb.cnt + 1.
   tb.sum = tb.sum + w_p_payment.sum.
   totc = totc + 1.
   tots = tots + w_p_payment.sum.
end.  */


/* ALSEKO */
/*
find first commonls no-error where commonls.txb = seltxb and commonls.grp = 6 no-lock.
for each alsk where date >= dt1 and date <= dt2 no-lock:
   find first tb where tb.grp = 6 no-error.
   if not avail tb then
      do:
          create tb.
          tb.bn = commonls.bn.
          tb.grp = commonls.grp.
          tb.type = commonls.type.
          tb.cnt = 0.
          tb.sum = 0.0.
      end.
   tb.cnt = tb.cnt + 1.
   tb.sum = tb.sum + alsk.sum.
   totc = totc + 1.
   tots = tots + alsk.sum.
end.
*/

/* IVC */
/*
find first commonls where commonls.txb = seltxb and commonls.grp = 5 no-lock.
for each ivc where date >= dt1 and date <= dt2 no-lock no-error:
   find first tb where tb.grp = 5 no-error.
   if not avail tb then
      do:
          create tb.
          tb.bn = commonls.bn.
          tb.grp = commonls.grp.
          tb.type = commonls.type.
          tb.cnt = 0.
          tb.sum = 0.0.
      end.
   tb.cnt = tb.cnt + 1.
   tb.sum = tb.sum + ivc.sum.
   totc = totc + 1.
   tots = tots + ivc.sum.
end.
*/

/* KAZ.TEL. */
message "Step 2..".
find first commonls where commonls.txb = seltxb and commonls.grp = 3 no-lock no-error.
for each kaztel where kaztel.txb = seltxb and date >= dt1 and date <= dt2 no-lock:
   find first tb where tb.grp = 3 no-error.
   if not avail tb then
      do:
          create tb.
          tb.bn = commonls.bn.
          tb.grp = commonls.grp.
          tb.type = commonls.type.
          tb.cnt = 0.
          tb.sum = 0.0.
      end.
   tb.cnt = tb.cnt + 1.
   tb.sum = tb.sum + kaztel.sum.
   totc = totc + 1.
   tots = tots + kaztel.sum.
end.

/* ALMA.TV */
message "Step 3..".
for each almatv where almatv.txb = seltxb and dtfk >= dt1 and dtfk <= dt2 no-lock:
   find first tb where tb.bn = "Алма ТВ" no-error.
   if not avail tb then
      do:
          create tb.
          tb.bn = "Алма ТВ".
          tb.grp = 0.
          tb.type =0.
          tb.cnt = 0.
          tb.sum = 0.0.
      end.
   tb.cnt = tb.cnt + 1.
   tb.sum = tb.sum + almatv.summ.
   totc = totc + 1.
   tots = tots + almatv.summ.
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

