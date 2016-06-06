/* comm-rpm.p
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
        08.07.2005 - kanat добавил условие по commonls.visible - и стали появляться платежи АЛМА ТВ 
        04.09.2006 - u00124 добавил условие для прочих платежей
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var dt1 as date.
def var dt2 as date.

def var cnts as integer init 0.
def var amts as decimal init 0.

def temp-table tb
    field arp like commonls.arp
    field bn  like commonls.bn
    field cnt as int
    field sum like remtrz.amt.

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

for each commonls no-lock where commonls.txb = seltxb and commonls.visible break by commonls.arp:
if first-of(commonls.arp) and commonls.arp <> ""
then do: /* valid ARP */
         find tb where tb.arp = commonls.arp no-error.
         if not avail tb then
         do:
            create tb.
            tb.arp = commonls.arp.
            tb.bn  = commonls.bn.
            tb.cnt = 0.
            tb.sum = 0.0.
         end. 
    end. /* valid ARP */
end.

/* ALMATV */
create tb.
tb.bn = "Алма ТВ".
tb.arp = '498904301'.
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

/*
   for each remtrz where valdt1 >= dt1 and valdt1 <= dt2 and 
   (sacc="000904883" or sacc = "000904786" or sacc = "000904184" or sacc = "000904074" or
    sacc="010904501" or sacc = "010904802" or sacc = "010904103" or sacc = "010904404" or
    sacc="010904705") no-lock:
 
     if sacc="000904883" then do: cnt1 = cnt1 + 1. amt1 = amt1 + remtrz.amt. end.
     if sacc="000904786" then do: cnt2 = cnt2 + 1. amt2 = amt2 + remtrz.amt. end.
     if sacc="000904184" then do: cnt3 = cnt3 + 1. amt3 = amt3 + remtrz.amt. end.
     if sacc="000904074" then do: cnt4 = cnt4 + 1. amt4 = amt4 + remtrz.amt. end.

     if sacc="010904501" then do: cnt5 = cnt5 + 1. amt5 = amt5 + remtrz.amt. end.
     if sacc="010904802" then do: cnt6 = cnt6 + 1. amt6 = amt6 + remtrz.amt. end.
     if sacc="010904103" then do: cnt7 = cnt7 + 1. amt7 = amt7 + remtrz.amt. end.
     if sacc="010904404" then do: cnt8 = cnt8 + 1. amt8 = amt8 + remtrz.amt. end.
     if sacc="010904705" then do: cnt9 = cnt9 + 1. amt9 = amt9 + remtrz.amt. end.
     
    end.

cnts = cnt1 + cnt2 + cnt3 + cnt4 + cnt5 + cnt6 + cnt7 + cnt8 + cnt9.
amts = amt1 + amt2 + amt3 + amt4 + amt5 + amt6 + amt7 + amt8 + amt9.

disp "|       Организация        | Кол-во платежей  |      Сумма     |"  skip
     "|" fill ("-",60) format "x(60)" "|" skip

     "| ИВЦ                      |" cnt1 format ">>>>>>>>>>>>>>>9"
     "|" (amt1)  format ">>>,>>>,>>9.99"    "|" skip

     "| Алсеко                   |" cnt2 format ">>>>>>>>>>>>>>>9"
     "|" (amt2) format ">>>,>>>,>>9.99"    "|" skip

     "| АлматыТелеком            |" cnt3 format ">>>>>>>>>>>>>>>9"
     "|" (amt3)  format ">>>,>>>,>>9.99" "|" skip

     "| Водоканал                |" cnt4 format ">>>>>>>>>>>>>>>9"
     "|" (amt4)  format ">>>,>>>,>>9.99" "|" skip

     "| ТОО Латон                |" cnt5 format ">>>>>>>>>>>>>>>9"
     "|" (amt5)  format ">>>,>>>,>>9.99" "|" skip

     "| ЗАО Алматы-Гарант-Сервис |" cnt6 format ">>>>>>>>>>>>>>>9"
     "|" (amt6)  format ">>>,>>>,>>9.99" "|" skip

     "| КГП ЦИС г.Алматы         |" cnt7 format ">>>>>>>>>>>>>>>9"
     "|" (amt7)  format ">>>,>>>,>>9.99" "|" skip

     "| АГФ Фонд БДД РК          |" cnt8 format ">>>>>>>>>>>>>>>9"
     "|" (amt8)  format ">>>,>>>,>>9.99" "|" skip

     "| ТОО Дана                 |" cnt9 format ">>>>>>>>>>>>>>>9"
     "|" (amt9)  format ">>>,>>>,>>9.99" "|" skip

     "|" fill ("-",60) format "x(60)" "|" skip
     "| Всего                    |" cnts format ">>>>>>>>>>>>>>>9"
     "|" amts format ">>>,>>>,>>9.99" "|" skip
     "|" fill ("-",60) format "x(60)" "|" skip

     with no-labels.
*/
