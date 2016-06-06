/* din.p
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

define var sele as character format "x(15)" extent 3 initial
       ["LATU BILNCE", "VAL®TAS BILANCE", "KONSOL. BILANCE"].

repeat on endkey undo, leave:
{mainhead.i}

disp sele with no-labels row 4 attr-space frame zzq centered no-box.
choose field sele with frame zzq.

    if frame-index eq 1 then do:
	hide all.
	run dinl.
    end.

    else if frame-index eq 2 then do:
	hide all.
	run dinv.
    end.

    else if frame-index eq 3 then do:
	hide all.
	run dinc.
    end.
end.
