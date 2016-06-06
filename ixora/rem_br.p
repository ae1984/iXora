/* rem_br.p
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

/** rem_br.p **/

{mainhead.i}

define button rem_1 label " APMAKS…TIE °EKI ".
define button rem_2 label "   INKASO °EKI   ".

define button but_1 label "N…KO№AIS".
define button but_2 label "IZPILD§T".

define new shared frame f_but
    but_1 but_2 with row 3 centered no-box.

define frame frrem 
    skip(1) 
    space(10)rem_1 rem_2 space(10) skip(1) 
    with centered row 6  side-labels title "   P…RVEDUMI UZ FILI…LЁM   ".

/** apmaks–tie ўeki **/
on choose of rem_1 do:
/*    hide frame frrem.*/
    run cash_bra.
end.

/** inkaso ўeki **/
on choose of rem_2 do:
    run inc_bra.
    hide frame f_but.
end.

enable all with frame frrem.
wait-for window-close of current-window. 



