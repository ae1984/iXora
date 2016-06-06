/* zavmodul.p
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
        23.04.2009 galina - перекомпеляция
*/

{zavkas.f}

on choose of b1 in frame mmm do:
run zavavans.
hide all.
enable all with frame mmm.
end.

on choose of b2 in frame mmm do:
run zavpodkr.
hide all.
enable all with frame mmm.
end.

on choose of b3 in frame mmm do:
run zavrecas.
hide all.   
enable all with frame mmm.
end.
            
on choose of b4 in frame mmm do:
run zavost.
hide all.
enable all with frame mmm.
end.

on choose of b5 in frame mmm do:
run zavshow.
hide all.
enable all with frame mmm.
end.

enable all with frame mmm.

wait-for window-close of current-window.
