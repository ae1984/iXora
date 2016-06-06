/*dep_ps.p
 * MODULE
        Автоматическая регистрация платежей
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

 * BASES
        BANK COMM
 * AUTHOR
        14/12/2005 dpuchkov
 * CHANGES
        23/10/2012 id00810 - ТЗ 1554, добавлена переменная reas (new shared)
*/


def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.

define new shared var s-remtrzink like que.remtrz .
def new shared var reas as char label "Причина отвержения " format "x(40)" no-undo.
{lgps.i "new"}

m_pid = "DEP" .
u_pid = "err_ink_ps" .
v-option = "rmzer3A".

def var v-rmz8aaa like remtrz.remtrz.
def new shared var s-remtrz like remtrz.remtrz.

form skip v-rmz8aaa with frame rmzor  side-label row 3  centered .
on help of v-rmz8aaa in frame rmzor do:
   run h-rmzdep.
        v-rmz8aaa =  s-remtrzink .
   displ v-rmz8aaa with frame rmzor .
end.



repeat :
{mainhead.i ERR_3A_}
  update v-rmz8aaa label "Платеж"  validate (can-find (remtrz where remtrz.remtrz = v-rmz8aaa),
     "Платеж не найден !" ) with frame rmzor .
      s-remtrz = v-rmz8aaa.
      find first remtrz where remtrz.remtrz = s-remtrz no-lock.

  run s-remtrz.

  hide all.
  s-remtrz = "".
end.



















