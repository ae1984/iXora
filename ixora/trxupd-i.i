/* trxupd-i.i
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

/******************Balance update for all subled all levels**************/
PROCEDURE trxupd+.
find trxbal where trxbal.sub = jl.subled
              and trxbal.acc = jl.acc
              and trxbal.level = jl.lev 
              and trxbal.crc = jl.crc exclusive-lock no-error.
     if not available trxbal then do:
        create trxbal.
        trxbal.sub = jl.subled.
        trxbal.acc = jl.acc.
        trxbal.level = jl.lev.
        trxbal.crc = jl.crc.
     end.
        trxbal.dam = trxbal.dam + vdam.
        trxbal.cam = trxbal.cam + vcam.
END procedure.

/******************Balance update for all subled all levels**************/
PROCEDURE trxupd-.
find trxbal where trxbal.sub = jl.subled
              and trxbal.acc = jl.acc
              and trxbal.level = jl.lev 
              and trxbal.crc = jl.crc exclusive-lock no-error.
     if available trxbal then do:
        trxbal.dam = trxbal.dam - vdam.
        trxbal.cam = trxbal.cam - vcam.
        if trxbal.dam = 0 and trxbal.cam = 0 then delete trxbal.
     end.
END procedure.


