/* chkboxps.p
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

/** chkboxps.p **/

define input  parameter rmz  like remtrz.remtrz.
define input  parameter sub  like remtrz.rsub.
define output parameter rcod as logi init true.

find remtrz where remtrz.remtrz = rmz no-lock no-error.
    if not available remtrz then do:
        rcod = false. 
        message 'P–rvedums nav atrasts.'. 
    end.
    else do:
        find que of remtrz no-lock no-error.
            if que.pid ne '2L' then do:
                rcod = false. 
                message "P–rvedumu apstr–d–t nedrЁkst".
            end.

        if remtrz.rsub ne sub then do:
            rcod = false.
            message "P–rveduma <Rsub> nesakrЁt ar " + sub.
        end.
        else do: 
            if remtrz.jh1 eq ? or remtrz.jh1 eq 0 then do:
                rcod = false.
                message '1 TRX neeksistё.'.
            end.   
            else if not (remtrz.jh2 eq ? or remtrz.jh2 eq 0 ) then do:
                rcod = false.
                message ' 2 TRX eksistё.'.
            end.
        end.
    end.
