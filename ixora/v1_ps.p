/* v1_ps.p
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
 v1_ps.p
*/

{mainhead.i v1_}
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha.
{lgps.i "new"}
m_pid = "v1" .
u_pid = "v1_ps" .
v-option = "wvdt1".
{main.i
 &head = remtrz
 &headkey = remtrz
 &framename = remtrz
 &option = REMTRZ
 &formname = rmz
 &findcon = true
 &addcon = false
 &numprg = "n-remtrz"
 &keytype = string
 &nmbrcode = remtrz
 &subprg = s-remtrz
 &clearframe = " "
 &viewframe = " "
 &postfind = "{posfnd.i}"
 &preadd = " "
 &end = " "
}
