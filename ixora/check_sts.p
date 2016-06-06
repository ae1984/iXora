/* check_sts.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        23/11/2012 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/


define variable qCount as integer init 0.
for each que where que.con = "W" and que.pid <> "ARC" and que.pid <> "ARX" and que.pid <> "F" use-index fprc no-lock break by que.pid:
    if last-of(que.pid) then
    do:
        qCount = qCount + 1. 
        find first sts where sts.pid = que.pid no-lock no-error.
        if available sts then
        do:
            if sts.nw <> qCount then 
            do:
                find first sts where sts.pid = que.pid exclusive-lock no-error.
                sts.nw = qCount.
            end.
        end.
        else 
        do:
            create sts.
            sts.pid = que.pid. 
            sts.nw = qCount. 
        end.   
        qCount = 0. 
    end.
    else qCount = qCount + 1.    
end.


