/* rotrz.p
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

/* remout.p
*/

{mainhead.i RO}
def var acode like crc.code.
def var bcode like crc.code.
def var ccode like crc.code.
def new shared var v-outcode as inte format "9".
def new shared var v-chg as inte format "9".
def new shared var v-priory as cha format "x(8)".
def new shared var v-pnp like aaa.aaa.
def new shared var remout like remtrz.remtrz.
{lgps.i "new"}
m_pid = "O".
{main.i
 &head = remtrz
 &headkey = remtrz
 &framename = rortrz
 &option = REM
 &formname = rortrz
 &findcon = true
 &addcon = true
 &numprg = n-remtrz
 &keytype = string
 &nmbrcode = remtrz
 &subprg = s-rotrz
 &clearframe = " "
 &viewframe = " "
 &postfind = " "
 &preadd = " "
 &postadd = "remtrz.sqn = remtrz.remtrz."
 &end = " if new remtrz and remtrz.amt eq 0 then do transaction:
	    delete remtrz.
	  end. "
}
