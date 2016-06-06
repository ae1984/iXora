/* n-lon.p
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

/*
def var vacc as char.
   17/10/02 Пролонгация
*/
def shared var s-longrp like lon.grp.
def shared var s-lon like lon.lon.
def new shared var s-lgr like lgr.lgr.

{global.i}
find longrp where longrp.longrp = s-longrp no-lock.
find gl of longrp no-lock.
        
        find nmbr where nmbr.code eq gl.code no-error.
        if not available nmbr then do:
           message "Please Update reference Number file".
           undo,return.
        end.
        /*
        {nmbr-acc.i nmbr.prefix
                    nmbr.nmbr
                    nmbr.fmt
                    nmbr.sufix}
        nmbr.nmbr = nmbr.nmbr + 1.
        /*
        create lon.
        lon.lon = vacc.
        lon.who = userid('bank').
        lon.whn = g-today.
        lon.gl  = longrp.gl.
        lon.grp = s-longrp.
        */
        s-lon = vacc.
        */
run acng(input gl.gl, true, output s-lon).
