/* report2.i
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
 * BASES
        BANK
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* report2.i
   report head and page bottom form define
   5.22.87 created by yong k. yoon
   12-11-88 revised by Simon Y. Kim
   {1} = width(132, 80 or etc.)
   {2} = additional head
   {3} = reserved for frame
   {4} = stream
   1. Include this file in looping statement.
   2. Refer report1.i and report3.i
*/
form header
  skip(3)  g-comp vtoday vtime  "Исп."  caps(g-ofc) skip(1)
  vtitle format "x({1})" skip 
  vtitle3 format "x({1})"  "стр." + string(page-number, "zzz9") format "x(10)" to {1} skip
  fill("=",{1}) format "x({1})" skip  {2}
  with width {1} page-top no-box no-label frame rpthead{3}.
view {4} frame rpthead{3}.

form header  "Продолжение следует ..."  with page-bottom no-box no-label frame rptbottom{3}.
view {4} frame rptbottom{3}.

