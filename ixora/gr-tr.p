/* gr-tr.p
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

/* ==================================================== */
/*      Kopёt visas TRANZAKCIJAS ( 1,51,21,71,.....)    */
/*            no vec–s grupas ( 202,205,.....)          */
/*            uz jauno !!!                              */
/* ==================================================== */

def buffer x-aax for aax.
def var v-lgr like lgr.lgr.
def var vv-lgr like lgr.lgr.
 repeat:
message "ievadiet grupu veco" update v-lgr.
message " jauna grupa " update vv-lgr.
    for each x-aax where x-aax.lgr = v-lgr no-lock.
     if available x-aax then do:
	create aax.
	aax.lgr = vv-lgr.
	aax.ln = x-aax.ln.
	aax.des= x-aax.des.
	aax.pct = x-aax.pct.
	aax.amt = x-aax.amt.
	aax.nxtlgr = aax.nxtlgr.
	aax.who = "bankadm".
	aax.tim = x-aax.tim.
	aax.del = x-aax.del.
	aax.nxtln = x-aax.nxtln.
	aax.prg = x-aax.prg.
	aax.drcr = x-aax.drcr.
	aax.dev = x-aax.dev.
	aax.cev = x-aax.cev.
	aax.chk = x-aax.chk.
	aax.stamp = x-aax.stamp.
	aax.cnt = x-aax.cnt.
	aax.flt = x-aax.flt.
	aax.dgl = x-aax.dgl.
	aax.cgl = x-aax.cgl.
	aax.cash = x-aax.cash.
	aax.sic = x-aax.sic.
	aax.trc = x-aax.trc.
	aax.cdgl = x-aax.cdgl.
	aax.ccgl = x-aax.ccgl.

      end.
     end.
  end.
