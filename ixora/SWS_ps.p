﻿/* SWS_ps.p
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
        20.07.2004 tsoy изменил меню c REMTRZ на rmsSWS2.
*/


/*
 err_3_ps.p
*/


{mainhead.i ERR_GW_}

def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha.

{lgps.i "new"}
m_pid = "SWS" .
u_pid = "SWS_ps" .
v-option = "rmzSWS".

{main.i
 &head = remtrz
 &headkey = remtrz
 &framename = remtrz
 &option = rmsSWS2
 &formname = rmz
 &findcon = true
 &addcon = false
 &numprg = "n-remtrz"
 &keytype = string
 &nmbrcode = remtrz
 &subprg = s-remtrzi
 &clearframe = " "
 &viewframe = " "
 &postfind = "{posfnd.i}"
 &preadd = " "
 &postadd = " remtrz.rtim = time. "
 &end = " "
}