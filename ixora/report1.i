/* report1.i
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
*/

/* report1.i
   general report variable define
   5.22.87 created by yong k. yoon
   12-11-88 revised by Simon Y. Kim
   {1} = page size

   1. Include this file rigth before entering looping statement.
   2. If included in looping statement, today's time may vary on each page.
   3. Assign vtitle = "Something you want." in main procedure.
   4. Refer to report2.i report3.i.
   5. Also need image1.i image2.i image3.i

< Example >

- macstrpt.p -

{proghead.i "Report Customer Master File"}
{image1.i rpt.img}
{image2.i}
{report1.i 63}
vtitle = "Customer Master File".
for each cst:
 {report2.i 132}
 display cst.cst cst.name cst.add[1] with width 132 no-box down frame cst.
end.
{report3.i}
{image3.i}

*/

define variable vtitle as char format "x(132)".
define variable vtoday as date.
define variable vtime  as cha format "x(8)".
vtoday = today.
vtime  = string(time,"HH:MM:SS").
output to value(vimgfname) page-size {1} append.
