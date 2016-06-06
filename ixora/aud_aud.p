/* aud_aud.p
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

/*aud_aud.p - 17.10.97*/
{mainhead.i}
{ptltrx.f}
define variable sele as character format "x(22)" extent 2 initial
    ["ATSKAITES FORMЁ№ANA" , "ATSKAITES DRUK…№ANA" /*,"   IZEJA   "*/].
/*def new shared var sum11 like jl.dam.
def new shared var sum12 like jl.dam.*/

pause 0.
hide frame aa.

display sele with no-labels row 7 attr-space frame zq centered.
choose field sele with frame zq.
repeat:
    if frame-index eq 1 then do:
        hide all.
        run auditu.
        leave.
    end.
    
    if frame-index eq 2 then do:
        hide all.
        run aud_dru.
        leave.
    end.
    
end.

pause 0.
