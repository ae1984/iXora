﻿/* er_31_ps.p
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
 err_3_ps.p
*/

{mainhead.i ER_31_}
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha.
{lgps.i "new"}
m_pid = "31" .
u_pid = "er_31_ps" .
v-option = "remtrz31".
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
 /*
 &postadd = " remtrz.sqn = remtrz.remtrz. remtrz.rdt = g-today .
              remtrz.valdt1 = g-today. remtrz.valdt2 = g-today ."
 */
 &end = " "
}