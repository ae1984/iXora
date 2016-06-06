/* funremo.p
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

{global.i}
def shared var s-fun like fun.fun.
def shared var s-jh like jh.jh.
def shared var v-rem like rem.rem.
def new shared var s-rem like rem.rem.

find fun where fun.fun = s-fun.
find gl of fun.
find first cmp.

/*find dfb where dfb.dfb = fun.dfb.*/

run n-remout.
v-rem = s-rem.  /* sv */
create rem.
rem.rem = s-rem.
rem.grp = 2.
/*rem.dfb = dfb.dfb.*/
rem.crc = fun.crc.

if   gl.type = "A" and fun.itype = "D" then
rem.amt = fun.amt - fun.interest.
else
if   gl.type = "A" and fun.itype = "A" then
rem.amt = fun.amt.
else
if   gl.type = "L" and fun.itype = "A" then
rem.amt = fun.amt + fun.interest.
else
if   gl.type = "L" and fun.itype = "D" then
rem.amt = fun.amt + fun.interest.

rem.crc2 = fun.crc.
rem.payment = rem.amt.
rem.ord = cmp.name.
rem.rdt = g-today.
rem.jh = s-jh.
rem.cover = 1.
rem.outcode = 2.
rem.who = userid('bank').
rem.whn = g-today.
rem.tim = time.
/*
rem.valdt = fun.rdt.
rem.bank = fun.bank.
rem.tdfb = fun.dfb.
*/
