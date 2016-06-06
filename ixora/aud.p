/* aud.p
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


{mainhead.i}



{ptltrx.f}
define variable sele as character format "x(15)" extent 3 initial
    ["AKT§VI", "PAS§VI", "IZEJA"].
pause 0.
hide frame aa.

display sele with no-labels row 7 attr-space frame zq centered.
choose field sele with frame zq.

repeat:
    if frame-index eq 1 then do:
	hide all.
	run audi01.
	leave.
    end.

    if frame-index eq 2 then do:
	hide all.
	run audi02.
	leave.
    end.

    if frame-index eq 3 then do:
	return.
    end.
end.

pause 0.
