/* rmz_ps.p
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
 rmz_ps.p
*/

{mainhead.i RMZ_PS}

def shared var s-remtrz like remtrz.remtrz.
def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.


{lgps.i "new"}
m_pid = "PS_" .
u_pid = "rmz_ps".
v-option = "remps_m".
run s-remtrz.
