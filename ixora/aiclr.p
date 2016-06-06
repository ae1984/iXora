/* aiclr.p
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

/* aiadjust.p
*/

{global.i}

def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.

define var intrat like pri.rate.
define var vaaa like aaa.aaa.
define var voldacc like aaa.accrued label "OLD-ACC".
define var voldint as dec decimals 2.
define var vnewint as dec decimals 2.
define var vsavint as dec decimals 2.
define var vtotaip as dec decimals 2.
define var vintch  as dec decimals 2.
define var vln as int initial 1.
define var vcnt as int.
define var fv as char.
define var inc as int.

run x-jhnew.
find jh where jh.jh = s-jh.
jh.party = "ACCRUED INTEREST ADJUSTMENT".

prompt-for aaa.aaa editing: {gethelp.i} end.

find aaa using aaa.aaa.
    find lgr of aaa.

    voldacc = aaa.accrued.
    voldint = aaa.accrued.
    vsavint = aaa.accrued.
    display aaa.aaa aaa.cif voldint label "ACC. INT." with frame aaa.
    update  voldint label "ACC. INT.".
    aaa.accrued = voldint.
    vintch = vsavint - voldint.
    /* {mesg.i 0936}.  update voldint label "ACC. INTEREST". */
  /* clear data */

  if vintch eq 0 then do:
     next.
  end.

  else if vintch gt 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.crc = aaa.crc.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = vintch.
    jl.dc = "C".
    jl.gl = lgr.prfgl.
    jl.acc = "".
    jl.rem[1] = "TOTAL " + string(vcnt) + " ACCOUNTS".
    vln = vln + 1.

    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.crc = aaa.crc.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = vintch.
    jl.dc = "D".
    jl.gl = lgr.accgl.
    jl.acc = "".
    jl.rem = "".
    vln = (truncate(vln / 100,0) + 1) * 100 + 1.
  end.

  else if vintch lt 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.crc = aaa.crc.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = - vintch.
    jl.dc = "D".
    jl.gl = lgr.prfgl.
    jl.acc = "".
    jl.rem[1] = "TOTAL " + string(vcnt) + " ACCOUNTS".
    vln = vln + 1.

    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.crc = aaa.crc.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = - vintch.
    jl.dc = "C".
    jl.gl = lgr.accgl.
    jl.acc = "".
    jl.rem = "".
    vln = (truncate(vln / 100,0) + 1) * 100 + 1.
  end.
