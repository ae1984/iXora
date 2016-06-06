/* err_3_ps.p
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


def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.

{lgps.i "new"}
m_pid = "3" .
u_pid = "err_3_ps" .
v-option = "rmzerr3".

def var v-rmz8 like remtrz.remtrz.
def new shared var s-remtrz like remtrz.remtrz.

form skip v-rmz8 with frame rmzor  side-label row 3  centered .

repeat :
{mainhead.i ERR_3_}

  update v-rmz8 label "Платеж"
    validate (can-find (remtrz where remtrz.remtrz = v-rmz8),
     "Платеж не найден !" ) with frame rmzor .
      s-remtrz = v-rmz8.
      find first remtrz where remtrz.remtrz = s-remtrz no-lock.
  run s-remtrz.
  hide all.
  s-remtrz = "".
end.


