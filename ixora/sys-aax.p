/* sys-aax.p
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

/* sys-aax.p
*/

{global.i}

{line-aax.i
&head = "lgr"
&line = "aax"
&start = "form aax.lgr aax.ln aax.des skip
	  aax.pct aax.amt
	  aax.nxtlgr aax.nxtln
	  aax.drcr aax.prg
	  aax.dev aax.cev aax.chk aax.stamp
	  aax.cnt aax.flt aax.dgl aax.cgl aax.cash
	  with frame xaax 2 col row 4 centered overlay
	  title "" Transaction Type ""."
&form = "aax.ln aax.des aax.trc"
&frame = "row 4 centered overlay 10 down scroll 1
	  title "" Transaction Type """
&flddisp = "aax.ln aax.des aax.trc"
&fldupdt = "aax.des aax.trc"
&posupdt = "display aax.lgr aax.ln aax.des with frame xaax.
	   update aax.pct aax.amt aax.nxtlgr aax.nxtln
		  aax.drcr aax.prg aax.dev aax.cev aax.chk aax.stamp
		  aax.cnt aax.flt aax.dgl aax.cgl aax.cash
		  with frame xaax."
&index = "aax"
&preupdt = " if new aax then do:
find xaax where xaax.lgr = ""999"" and xaax.ln = aax.ln no-error.
if available xaax then do:
aax.cash = xaax.cash. aax.cev = xaax.cev.  aax.chk = xaax.chk.
aax.cnt = xaax.cnt. aax.del = xaax.del. aax.des = xaax.des.
aax.dev = xaax.dev. aax.drcr = xaax.drcr. aax.flt = xaax.flt.
aax.lgr = s-lgr. aax.ln = xaax.ln. aax.nxtlgr = xaax.nxtlgr.
aax.nxtln = xaax.nxtln. aax.pct = xaax.pct.
aax.prg = xaax.prg. aax.regdt = g-today. aax.sic = xaax.sic.
aax.stamp = xaax.stamp. aax.tim = time. aax.trc = xaax.trc. aax.whn = g-today.
aax.who = g-ofc. end. end." }
