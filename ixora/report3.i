/* report3.i
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

/* report3.i
   end of report for general format
   5.22.87 created by yong k. yoon
   12-11-88 revised by Simon Y. Kim

   1. Refer to report1.i report2.i. report2.f

   28/01/2002, by sasco - настройка принтера из ofc
*/

hide frame rptbottom{2}.

display skip(2) {1} " =====      КОНЕЦ ДОКУМЕНТА     ====="
        with frame rptend{2} no-box no-label .  

FIND FIRST ofc where ofc.ofc = userid('bank') no-lock no-error.
IF NOT AVAIL ofc or ((AVAIL ofc) and (ofc.mday[2] = 1)) then
   PUT SKIP(15).
ELSE 
   PUT SKIP.

output {1} close.
