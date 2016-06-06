/* 3d_ps.p
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


def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.

{lgps.i "new"}
m_pid = "3D" .
u_pid = "3D".
v-option = '3d_dil'.

def var v-rmz10 like remtrz.remtrz.
def new shared var s-remtrz like remtrz.remtrz. 
def var v-sname like cif.sname.


form skip v-rmz10 label "Inward RMZ (3D): "with frame rmzor  side-label row 3
centered .

repeat :
{mainhead.i }

 update v-rmz10 validate (can-find (remtrz where remtrz.remtrz = v-rmz10), 
    "RMZ wasn't found !" )
    with frame rmzor .
  s-remtrz = v-rmz10.
   find first remtrz where remtrz.remtrz = s-remtrz no-lock.

    run  s-dilrmz.
    hide all.
    v-rmz10 = "".
    s-remtrz = "".
end.
