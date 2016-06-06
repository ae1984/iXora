/* ScrCourse.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        05.07.2013 dmitriy. ТЗ 1947
 * BASES
        BANK COMM
 * CHANGES
*/

def var i as int.

for each comm.txb where comm.txb.consolid = yes no-lock:
    find first sysc where sysc.sysc = "vw_" + string(comm.txb.city, "99") no-lock no-error.
    if avail sysc then do:
        do i = 1 to num-entries(sysc.chval, "|"):
            run to_stand(entry(i, sysc.chval, "|") ,"course","").
            message "Курсы валют в филиале " + comm.txb.info + " для экрана " + entry(i, sysc.chval, "|") + " запущены".
            pause 3.
        end.
    end.
end.



