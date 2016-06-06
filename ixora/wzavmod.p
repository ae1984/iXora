/* wzavmodul.p
 * MODULE
        Кассовый модуль
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
        3.10.1
 * AUTHOR
        23.08.2004 tsoy
 * CHANGES
*/

{wzavkas.f}

on choose of b1 in frame mmm do:
run wzavavans.
hide all.
enable all with frame mmm.
end.

on choose of b2 in frame mmm do:
run wzavpodkr.
hide all.
enable all with frame mmm.
end.

on choose of b3 in frame mmm do:
run wzavrecas.
hide all.   
enable all with frame mmm.
end.
            
on choose of b4 in frame mmm do:
run wzavost.
hide all.
enable all with frame mmm.
end.

on choose of b5 in frame mmm do:
run wzavshow.
hide all.
enable all with frame mmm.
end.

enable all with frame mmm.

wait-for window-close of current-window.
