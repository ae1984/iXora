/* PUSH_ps.p
 * MODULE
        PUSH отчеты
 * DESCRIPTION
        Процесс, запускающий все отчеты в pushrep по графику
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        25.07.05 sasco
 * CHANGES
        26.06.06 sasco Харакири по завершении процесса
        08.01.2009 galina - перенесла останов процесса в отдельную программу
        06.02.2012 aigul - добавила рассылку отчетов от ДВК
        31/07/2013 galina - ТЗ 1994 перенесла запуск программы inkclose из psrun

*/


{global.i}
{push.i "new"}

find sysc where sysc.sysc = "PUSHPS" no-lock no-error.
if not avail sysc then do transaction:
   create sysc.
   sysc.sysc = "PUSHPS".
   sysc.des = "Дата запуска PUSH отчетов".
   sysc.daval = 01/01/01.
end.

find sysc where sysc.sysc = "PUSHPS" no-lock no-error.
if sysc.daval = g-today then return.

do transaction:
   find sysc where sysc.sysc = "PUSHPS" exclusive-lock no-error.
   sysc.daval = g-today.
   release sysc.
end.

if time >= 32400 then do:
   run inkclose.
end.

run pushrun.
run P_vccomp.
run pushend.